scope KazuyaSpecial {
    scope OnActionChanged: {
        OS.routine_begin(0x20)
        lw a0, 0x4(a0) // a0 = player object
        sw a0, 0x18(sp) // save player object
        lw s0, 0x84(a0) // s0 = player struct
        sw s0, 0x1c(sp) // save player struct

        // Some of this character's grounded attacks don't have their own
        // turnaround check (unlike a dash/walk direction change), so on
        // entering one of these actions we manually search for the nearest
        // opponent and snap the character to face them - see
        // auto_turnaround below.
        scope _auto_turnaround_check: {
            lli t0, Kazuya.Action.JAB1
            beq a1, t0, _continue
            lli t0, Kazuya.Action.TILTU1
            beq a1, t0, _continue
            lli t0, Kazuya.Action.SMASHD
            beq a1, t0, _continue
            lli t0, Action.DTilt
            beq a1, t0, _continue
            lli t0, Action.USmash
            beq a1, t0, _continue
            lli t0, Kazuya.Action.WHILE_STAND
            beq a1, t0, _continue
            lli t0, Kazuya.Action.CROUCH_JAB
            beq a1, t0, _continue
            lli t0, Kazuya.Action.CROUCH_TILT
            beq a1, t0, _continue
            nop
            b _end // action isn't one of the auto-turnaround actions above
            nop

            _continue:
            jal KazuyaSpecial.auto_turnaround
            lw a0, 0x18(sp) // a0 = player object

            _end:
        }

        // 0x0AE4 is shared by DASH and TURN's check_wavedash_input_
        // gesture tracking - a dedicated scratch field (same one Snake
        // uses for its own up-B flag) rather than one of the "tmp
        // variable" slots, since those can be read/written by Dash/Turn's
        // own kept-native physics/interrupt logic and we don't want to
        // collide with that. Only reset it here, once, when actually
        // entering the DASH/TURN pair from outside it, so progress
        // carries over seamlessly if Kazuya transitions directly between
        // the two (e.g. Turn into Dash) without ever losing track of how
        // far into the gesture the player already got
        scope _dash_turn_reset_check: {
            lli t0, Kazuya.Action.DASH
            beq a1, t0, _entering
            nop
            lli t0, Kazuya.Action.TURN
            bne a1, t0, _end
            nop

            _entering:
            lli t0, Kazuya.Action.DASH
            beq a2, t0, _end // came from the sibling action - keep the state
            nop
            lli t0, Kazuya.Action.TURN
            beq a2, t0, _end // came from the sibling action - keep the state
            nop

            lli t0, 0x1
            sw t0, 0x0AE4(s0) // fresh entry from outside the pair - reset to state 1

            _end:
        }

        _end:
        OS.routine_end(0x20)
    }
    // Set on_action_changed function
    Character.table_patch_start(on_action_changed, Character.id.KAZUYA, 0x4)
    dw OnActionChanged
    OS.patch_end()

    // @ Description
    // Finds the closest opponent, and separately the closest overall
    // target (an opponent, or - whichever is actually closer - an item
    // with an active hurtbox), for auto_turnaround and any other feature
    // that wants the plain closest target regardless of category (e.g. a
    // proximity-triggered move). Items can never affect the opponent-only
    // result: it's captured before items are even searched, so
    // auto_turnaround (which only ever turns towards an opponent) is
    // completely unaffected by nearby items.
    // a0 - player object
    // returns
    // v0 - closest overall target - opponent or item (NULL if none found)
    // v1 - closest overall target's X_DIFF (signed distance, positive = in
    //      front of the character's current facing direction)
    // a1 - closest opponent (NULL if no opponent was found)
    // a2 - closest opponent's X_DIFF
    // a3 - number of opponents in the match (excludes self and teammates)
    scope check_for_targets_: {
        // search cone shape, relative to the character's current facing
        // direction. note TURNAROUND_X_RANGE_BACK is deliberately much
        // larger than MAX_X_RANGE_BACK: once the character is already
        // facing a target, it's allowed to fall much further behind before
        // losing that target.
        constant MAX_X_RANGE_FORWARD(0x43C8) // float: 400.0 - search range in front of the character
        constant MAX_X_RANGE_BACK(0x4370) // float: 240.0 - search range behind the character, before a target is found
        constant TURNAROUND_X_RANGE_BACK(0x44C8) // float: 1600.0 - search range behind the character, once already facing a target
        constant MAX_Y_RANGE_UP(0x447A) // float: 1000.0 - search range above the character
        constant MAX_Y_RANGE_DOWN(0x4348) // float: 200.0 - search range below the character

        addiu sp, sp,-0x0050 // allocate stack space
        sw ra, 0x001C(sp) // ~
        sw s0, 0x0020(sp) // ~
        sw s1, 0x0024(sp) // ~
        sw s2, 0x0028(sp) // ~
        sw s3, 0x002C(sp) // ~
        sw s4, 0x0030(sp) // ~
        sw s5, 0x0034(sp) // store ra, s0-s5

        or v0, r0, r0 // clear return registers - v0 = target object = NULL
        or v1, r0, r0 // clear return registers - v1 = target X_DIFF = 0

        or s0, a0, r0 // s0 = this character's own player object
        li s1, 0x800466FC // s1 = player object head
        lw s1, 0x0000(s1) // s1 = first player object
        lw s2, 0x0084(s0) // s2 = this character's player struct
        or s3, r0, r0 // s3 = opponent count, tallied by the loop below

        // pass 1: look for the closest valid opponent among all players
        _player_loop:
        beqz s1, _player_loop_exit // exit loop when s1 no longer holds an object pointer
        nop
        beql s1, s0, _player_loop // skip this character's own player object...
        lw s1, 0x0004(s1) // ...and load next object into s1

        _team_check:
        li t0, Global.match_info // ~
        lw t0, 0x0000(t0) // t0 = match info struct
        lbu t1, 0x0002(t0) // t1 = team battle flag
        beqz t1, _action_check // branch if this isn't a team battle
        lbu t1, 0x0009(t0) // t1 = team attack flag
        bnez t1, _action_check // branch if friendly fire is enabled
        nop

        // if the match is a team battle with team attack disabled,
        // teammates aren't opponents - not counted, not a turnaround target
        lw t0, 0x0084(s1) // t0 = target player struct
        lbu t0, 0x000C(t0) // t0 = target team
        lbu t1, 0x000C(s2) // t1 = this character's team
        beq t0, t1, _player_loop_end // skip if player and target are on the same team
        nop

        _action_check:
        addiu s3, s3, 0x0001 // opponent count++ (s1 is neither self nor a teammate at this point)
        lw t0, 0x0084(s1) // t0 = target player struct
        lw t0, 0x0024(t0) // t0 = target player action
        sltiu at, t0, 0x0007 // at = 1 if action id < 7, else at = 0
        bnez at, _player_loop_end // skip if target is in a dead/respawning action (id < 7)
        nop

        _target_check:
        or a0, s2, r0 // a0 = this character's player struct
        lw a1, 0x0074(s1) // a1 = target top joint struct
        jal check_target_ // check if target is in range and closer than the current best
        or a2, s1, r0 // a2 = target object struct
        beqz v0, _player_loop_end // branch if this target isn't a new best match
        nop

        // remember the new best opponent match so far
        sw v0, 0x0B18(s2) // store target object
        sw v1, 0x0B1C(s2) // store target X_DIFF

        _player_loop_end:
        b _player_loop // loop
        lw s1, 0x0004(s1) // s1 = next object

        // pass 1 is done - capture the best opponent match now, before
        // pass 2 (items) gets a chance to overwrite it. auto_turnaround
        // uses this opponent-only result, so items can never affect it
        _player_loop_exit:
        lw s4, 0x0B18(s2) // s4 = closest opponent (NULL if none found)
        lw s5, 0x0B1C(s2) // s5 = closest opponent's X_DIFF

        // pass 2: also check items, continuing the comparison from
        // wherever pass 1 left off, so the true overall closest target
        // (opponent or item) is still available for other features
        li s1, 0x80046700 // s1 = item object head
        lw s1, 0x0000(s1) // s1 = first item object

        _item_loop:
        beqz s1, _end // exit loop when s1 no longer holds an object pointer
        nop

        lw t0, 0x0084(s1) // t0 = item special struct
        lw t0, 0x0248(t0) // t0 = bit field with hurtbox state
        andi t0, t0, 0x0001 // t0 = 1 if hurtbox is enabled, else t0 = 0
        beqz t0, _item_loop_end // skip if item doesn't have an active hurtbox
        nop
        or a0, s2, r0 // a0 = this character's player struct
        lw a1, 0x0074(s1) // a1 = target top joint struct
        jal check_target_ // check if item is in range and closer than the current best
        or a2, s1, r0 // a2 = target object struct
        beqz v0, _item_loop_end // branch if this item isn't a new best match
        nop

        // remember the new overall best match so far
        sw v0, 0x0B18(s2) // store target object
        sw v1, 0x0B1C(s2) // store target X_DIFF

        _item_loop_end:
        b _item_loop // loop
        lw s1, 0x0004(s1) // s1 = next object

        _end:
        // reload the overall best match rather than trusting v0/v1 to
        // still hold it - the last check_target_ call made above may have
        // rejected its candidate (returning NULL), which would otherwise
        // clobber an earlier, still-valid winner
        lw v0, 0x0B18(s2) // v0 = overall best target (opponent or item)
        lw v1, 0x0B1C(s2) // v1 = overall best target's X_DIFF
        or a1, s4, r0 // a1 = closest opponent
        or a2, s5, r0 // a2 = closest opponent's X_DIFF
        or a3, s3, r0 // a3 = opponent count
        lw ra, 0x001C(sp) // ~
        lw s0, 0x0020(sp) // ~
        lw s1, 0x0024(sp) // ~
        lw s2, 0x0028(sp) // ~
        lw s3, 0x002C(sp) // ~
        lw s4, 0x0030(sp) // ~
        lw s5, 0x0034(sp) // load ra, s0-s5
        addiu sp, sp, 0x0050 // deallocate stack space
        jr ra // return
        nop

        // @ Description
        // Helper for check_for_targets_ above. Checks whether a single
        // candidate (a player or an item) is within this character's
        // search cone and, if so, whether it's closer than the current
        // best match.
        // Private to check_for_targets_ - not called from anywhere else.
        // a0 - this character's player struct
        // a1 - candidate's top joint struct
        // a2 - candidate object struct
        // returns
        // v0 - candidate object if it's the new best match, else NULL
        // v1 - candidate's X_DIFF (only valid when v0 is non-NULL)
        scope check_target_: {
            lw t8, 0x0078(a0) // t8 = this character's x/y/z coordinates
            addiu t9, a1, 0x001C // t9 = candidate x/y/z coordinates

            // check if the candidate is within x range
            mtc1 r0, f0 // f0 = 0
            lwc1 f2, 0x0000(t8) // f2 = this character's x coordinate
            lwc1 f4, 0x0000(t9) // f4 = candidate x coordinate
            sub.s f10, f4, f2 // f10 = X_DIFF (candidate x - this character's x)
            lwc1 f8, 0x0044(a0) // ~
            cvt.s.w f8, f8 // f8 = DIRECTION
            mul.s f10, f10, f8 // f10 = X_DIFF * DIRECTION (positive = in front)
            lui at, MAX_X_RANGE_FORWARD // at = MAX_X_RANGE_FORWARD
            mtc1 at, f8 // f8 = MAX_X_RANGE_FORWARD
            c.le.s f10, f8 // ~
            nop // ~
            bc1fl _end // end if candidate is beyond MAX_X_RANGE_FORWARD
            or v0, r0, r0 // and return NULL
            lui at, TURNAROUND_X_RANGE_BACK // at = TURNAROUND_X_RANGE_BACK
            mtc1 at, f8 // f8 = TURNAROUND_X_RANGE_BACK
            neg.s f8, f8 // f8 = -TURNAROUND_X_RANGE_BACK
            c.le.s f8, f10 // ~
            nop // ~
            bc1fl _end // end if candidate is behind TURNAROUND_X_RANGE_BACK
            or v0, r0, r0 // and return NULL

            // check if there is already a closer best match
            lw t0, 0x0B18(a0) // t0 = current best match
            beq t0, r0, _check_y // branch if there is no current best match yet
            lwc1 f8, 0x0B1C(a0) // f8 = current best match's X_DIFF

            // compare by absolute distance, not signed X_DIFF - otherwise a
            // target behind us (however far) would always beat a target in
            // front of us (however close), since the search cone extends
            // much further behind than in front
            abs.s f14, f10 // f14 = abs(candidate X_DIFF)
            abs.s f8, f8 // f8 = abs(current best match's X_DIFF)
            c.le.s f14, f8 // ~
            nop // ~
            bc1fl _end // end if the current best match is closer or equal
            or v0, r0, r0 // return NULL

            _check_y:
            // calculate Y_RANGE based on X_DIFF, creating a cone shaped range
            lwc1 f2, 0x0004(t8) // f2 = this character's y coordinate
            lwc1 f4, 0x0004(t9) // f4 = candidate y coordinate
            sub.s f12, f4, f2 // f12 = Y_DIFF (candidate y - this character's y)

            lui at, MAX_Y_RANGE_UP // at = MAX_Y_RANGE_UP
            mtc1 at, f8 // f8 = MAX_Y_RANGE_UP
            c.le.s f12, f8 // ~
            nop // ~
            bc1fl _end // end if candidate is above MAX_Y_RANGE_UP
            or v0, r0, r0 // and return NULL

            lui at, MAX_Y_RANGE_DOWN // at = MAX_Y_RANGE_DOWN
            mtc1 at, f8 // f8 = MAX_Y_RANGE_DOWN
            neg.s f8, f8 // f8 = -MAX_Y_RANGE_DOWN
            c.le.s f8, f12 // ~
            nop // ~
            bc1fl _end // end if candidate is below MAX_Y_RANGE_DOWN
            or v0, r0, r0 // return NULL

            // candidate is in range and closer than the current best match
            or v0, a2, r0 // v0 = candidate object
            mfc1 v1, f10 // v1 = X_DIFF

            _end:
            jr ra // return
            nop
        }
    }

    // @ Description
    // Turns the character to face the nearest opponent found by
    // check_for_targets_, if any (see _auto_turnaround_check above for when
    // this runs). Items never factor into this at all - check_for_targets_
    // hands back the closest opponent separately from its overall
    // (opponent-or-item) result, and this function only ever looks at the
    // opponent-only one. Only actually turns around when there's exactly
    // one opponent in the match.
    // 0x0B18/0x0B1C on the player struct are borrowed as scratch space for
    // the search - their real contents are saved and restored around the
    // call so nothing else on the struct is disturbed.
    // a0 = player object
    scope auto_turnaround: {
        OS.routine_begin(0x20)

        sw a0, 0x0004(sp) // ~
        sw a1, 0x0008(sp) // ~
        sw a2, 0x000C(sp) // ~
        // sw ra, 0x0010(sp) // ~
        // sw a1, 0x0014(sp) // save registers

        lw t0, 0x0084(a0) // t0 = player struct

        lw t6, 0x0B18(t0) //
        lw t7, 0x0B1C(t0) // save the struct's real 0x0B18/0x0B1C contents

        sw r0, 0x0B18(t0) // target = NULL
        sw r0, 0x0B1C(t0) // X_DIFF = 0

        jal check_for_targets_ // search for the nearest valid target
        nop

        or t9, a1, r0 // t9 = closest opponent (copy out before a1 gets restored below)
        or t8, a2, r0 // t8 = closest opponent's X_DIFF (copy out before a2 gets restored below)

        lw a0, 0x0004(sp) // ~
        lw a1, 0x0008(sp) // ~
        lw a2, 0x000C(sp) // ~ restore a0, a1, a2

        lw t0, 0x0084(a0) // t0 = player struct

        sw t6, 0x0B18(t0) //
        sw t7, 0x0B1C(t0) // restore the struct's real 0x0B18/0x0B1C contents

        beq t9, r0, _end // branch if no opponent was found
        nop

        // only actually turn around when there's exactly one opponent in
        // the match - the target above is still found/reported (for other
        // features) even when this doesn't apply
        lli t7, 0x0001
        bne a3, t7, _end
        nop

        // target found and behind the character - turn to face it
        mtc1 t8, f0 // f0 = opponent's xdiff
        mtc1 r0, f2 // f2 = 0
        c.le.s f2, f0
        bc1t _end

        lw t7, 0x0044(t0) // t7 = DIRECTION
        subu t7, r0, t7 // ~
        sw t7, 0x0044(t0) // reverse and update DIRECTION

        mtc1 t7, f6 // ~
        cvt.s.w f6, f6 // f6 = direction
        lui t2, 0x8013 // ~
        lwc1 f8, 0xFE90(t2) // t2 = rotation constant
        mul.s f8, f8, f6 // f8 = rotation constant * direction
        lw t7, 0x08E8(t0) // t6 = character control joint struct
        swc1 f8, 0x0034(t7) // update character rotation to match direction

        _end:
        OS.routine_end(0x20)
    }

    scope SMASHD: {
        scope main: {
            OS.routine_begin(0x20)

            lw at, 0x78(a0) // load current animation frame into at

            bgtz at, _end // if animation is not over, skip
            nop

            jal 0x80144294 // ftCommon_DownWait_SetStatus
            nop

            _end:
            OS.routine_end(0x20)
        }
    }

    scope CROUCHWAIT: {
        scope interrupt: {
            OS.routine_begin(0x20)

            lw a1, 0x84(a0) // load player struct into a1

            lhu t1, 0x01BE(a1) // load button press buffer
            andi t2, t1, Joypad.A // t2 = 0x80 if (A_PRESSED); else t2 = 0
            beq t2, r0, _default_interrupt // skip if (!A_PRESSED)
            nop

            _resolve_crouch_move:
            // we're using t2 to set the action to change to
            lb t2, 0x01C2(a1) // t2 = stick_x
            bgez t2, _continue	// branch if positive value
            nop
            subu t2, r0, t2 // t2 = abs(stick.x)
            _continue:
            slti t1, t2, 40 // t1 = 1 if abs(stick_x) < 40
            lli t2, Kazuya.Action.CROUCH_TILT
            beq t1, r0, _apply_move
            nop
            // else, crouch jab
            lli t2, Kazuya.Action.CROUCH_JAB
            b _apply_move
            nop

            _apply_move:
            addiu sp, sp,-0x30 // allocate stack space
            sw ra, 0x4(sp)
            sw a1, 0x8(sp)
            sw a2, 0xC(sp) // store variables
            sw a3, 0x10(sp) // store variables
            addiu sp, sp,-0x30 // allocate stack space
            
            sw r0, 0x10(sp) // argument 4 = 0
            or a1, r0, t2
            lui a2, 0x3F80 // a2 = float: 0.0
            jal 0x800E6F24 // change action
            lui a3, 0x3F80 // a3 = float: 1.0
            nop

            addiu sp, sp, 0x30 // deallocate stack space
            lw ra, 0x4(sp) // restore ra
            lw a1, 0x8(sp) // restore a1
            lw a2, 0xC(sp) // restore a2
            lw a3, 0x10(sp) // restore a3
            addiu sp, sp, 0x30 // deallocate stack space
            b _end
            nop

            _default_interrupt:
            jal 0x80143154
            nop

            _end:
            OS.routine_end(0x20)
        }
    }

    scope CROUCHEND: {
        scope interrupt: {
            OS.routine_begin(0x20)

            lw a1, 0x84(a0) // load player struct into a1

            lhu t1, 0x01BE(a1) // load button press buffer
            andi t2, t1, Joypad.A // t2 = 0x80 if (A_PRESSED); else t2 = 0
            beq t2, r0, _default_interrupt // skip if (!A_PRESSED)
            nop

            _apply_move:
            addiu sp, sp,-0x30 // allocate stack space
            sw ra, 0x4(sp)
            sw a1, 0x8(sp)
            sw a2, 0xC(sp) // store variables
            sw a3, 0x10(sp) // store variables
            addiu sp, sp,-0x30 // allocate stack space
            
            sw r0, 0x10(sp) // argument 4 = 0
            lli a1, Kazuya.Action.WHILE_STAND
            lui a2, 0x3F80 // a2 = float: 0.0
            jal 0x800E6F24 // change action
            lui a3, 0x3F80 // a3 = float: 1.0
            nop

            addiu sp, sp, 0x30 // deallocate stack space
            lw ra, 0x4(sp) // restore ra
            lw a1, 0x8(sp) // restore a1
            lw a2, 0xC(sp) // restore a2
            lw a3, 0x10(sp) // restore a3
            addiu sp, sp, 0x30 // deallocate stack space
            b _end
            nop

            _default_interrupt:
            jal 0x80143394
            nop

            _end:
            OS.routine_end(0x20)
        }
    }
    
    scope CROUCH_JAB: {
        constant A_PRESSED(0x8000) // bitmask for a press

        // tmp variable 3 0x0184 -- used to check if A was ever pressed down during the move
        scope main: {
            OS.routine_begin(0x20)

            lw v0, 0x0084(a0) // v0 = player struct

            lw t0, 0x0078(a0) // t0 = current animation frame
            lui t1, 0x4000 // t1 = 1.0F

            // if frame != 1, skip
            bne t0, t1, main_continue
            nop
            
            sw r0, 0x0184(v0) // reset tmp variable 3 = 0

            main_continue:
            lw v0, 0x0084(a0) // loads player struct into v0
            lhu t1, 0x01BE(v0) // load button press buffer
            andi t2, t1, A_PRESSED // t2 = 0x80 if (A_PRESSED); else t2 = 0
            beq t2, r0, normal // if A is not pressed, skip
            nop

            check_neutral:
            lb t2, 0x01C2(a2) // t2 = stick_x
            bgez t2, check_neutral_continue			 // branch if positive value
            nop
            subu t2, r0, t2					 // t2 = abs(stick.x)
            check_neutral_continue:

            slti t1, t2, 20 // t1 = 1 if abs(stick_x) < 20
            beq t1, r0, normal // stick must be neutral in X
            nop

            lb t0, 0x01C3(v0) // t0 = stick_y
            slti t1, t0, -19 // at = 1 if stick_y < -19, else at = 0
            bnel t1, r0, register_press // branch if stick_y >= -20
            nop

            b normal
            nop

            register_press:
            lli t0, 0x1
            sw t0, 0x0184(v0)

            b normal
            nop

            normal:
            lw t0, 0x0078(a0) // t0 = current animation frame
            mtc1 t0, f6
            lui t1, 0x4160 // t1 = 14.0F
            mtc1 t1, f8

            c.le.s f6, f8
            nop
            bc1tl main_normal
            nop

            lw t0, 0x0184(v0) // was A or B ever pressed during the move?
            beq t0, r0, main_normal // If not, main_normal
            nop

            lw t0, 0x0024(a2) // t0 = current action
            lli t1, Kazuya.Action.CROUCH_JAB // Are we performing crouch jab?
            bne t0, t1, main_normal
            nop

            // all conditions are met
            b cancel_itself
            nop

            cancel_itself:
            OS.save_registers()
            lli a1, Kazuya.Action.CROUCH_JAB // a1 = Action.CROUCH_JAB
            lui a2, 0x3F80 // a2(starting frame) = 1.0
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            sw r0, 0x0010(sp) // argument 4 = 0
            jal 0x800E6F24 // change action
            nop
            OS.restore_registers()
            OS.routine_end(0x20)

            main_normal:
            li a1, 0x8014329C // Argument 1 = ftCommon_SquatWait_SetStatus (set crouched state)
            jal 0x800D9480 // ftStatus_IfAnimEnd_ProcStatus: Subroutine that waits for animation end to call argument 1
            nop

            OS.routine_end(0x20)
        }
    }

    // Tekken/FGC-style names for the 8 directions + neutral, relative to
    // facing (f = towards opponent, b = away), used by classify_zone_
    // below. Shared by DASH (going into a wavedash) and WAVEDASH
    // (cancelling out of one).
    scope Input {
        constant n(0)  // neutral
        constant f(1)  // forward
        constant b(2)  // back
        constant d(3)  // down
        constant u(4)  // up
        constant df(5) // down-forward
        constant db(6) // down-back
        constant uf(7) // up-forward
        constant ub(8) // up-back
    }

    // magnitude a stick axis must reach (facing-relative for X) to count
    // as tilted towards a direction, for classify_zone_ below - adjust
    // here to retune every wavedash-related direction check at once
    constant TILT_RANGE(20)

    // @ Description
    // Classifies a raw stick reading into one of Input's 9 directions.
    // Used by DASH.main (detecting the wavedash trigger input) and
    // WAVEDASH.main.cancel_check's _zone_transition_check (comparing this
    // frame's stick reading against last frame's).
    // a0 - raw stick_x
    // a1 - raw stick_y
    // a2 - facing direction (lr)
    // returns
    // v0 - Input.n/f/b/d/u/df/db/uf/ub
    scope classify_zone_: {
        // horizontal component (facing-relative): t1 = -1 back,
        // 0 level, 1 forward
        mult a0, a2
        mflo t0 // t0 = stick_x * facing direction (positive = forward, negative = backward)
        or t1, r0, r0 // t1 = 0 (level)
        slti t2, t0, -(TILT_RANGE-1) // t2 = 1 if tilted back
        beqz t2, _check_forward
        nop
        addiu t1, r0, -1 // t1 = -1 (back)
        b _horizontal_done
        nop
        _check_forward:
        slti t2, t0, TILT_RANGE // t2 = 1 if NOT tilted forward
        bnez t2, _horizontal_done
        nop
        lli t1, 1 // t1 = 1 (forward)
        _horizontal_done:

        // vertical component: t2 = -1 down, 0 level, 1 up
        or t2, r0, r0 // t2 = 0 (level)
        slti t3, a1, -(TILT_RANGE-1) // t3 = 1 if tilted down
        beqz t3, _check_up
        nop
        addiu t2, r0, -1 // t2 = -1 (down)
        b _vertical_done
        nop
        _check_up:
        slti t3, a1, TILT_RANGE // t3 = 1 if NOT tilted up
        bnez t3, _vertical_done
        nop
        lli t2, 1 // t2 = 1 (up)
        _vertical_done:

        // combine (horizontal, vertical) into an Input direction
        bgtz t2, _up // vertical = up
        nop
        bltz t2, _down // vertical = down
        nop

        // vertical = level
        beqz t1, _n
        nop
        bgtz t1, _f
        nop
        b _b
        nop

        _up:
        beqz t1, _u
        nop
        bgtz t1, _uf
        nop
        b _ub
        nop

        _down:
        beqz t1, _d
        nop
        bgtz t1, _df
        nop
        b _db
        nop

        _n:
        lli v0, Input.n
        jr ra
        nop
        _f:
        lli v0, Input.f
        jr ra
        nop
        _b:
        lli v0, Input.b
        jr ra
        nop
        _u:
        lli v0, Input.u
        jr ra
        nop
        _d:
        lli v0, Input.d
        jr ra
        nop
        _uf:
        lli v0, Input.uf
        jr ra
        nop
        _ub:
        lli v0, Input.ub
        jr ra
        nop
        _df:
        lli v0, Input.df
        jr ra
        nop
        _db:
        lli v0, Input.db
        jr ra
        nop
    }

    scope WAVEDASH: {
        constant A_PRESSED(0x8000) // bitmask for a press
        constant B_PRESSED(0x4000) // bitmask for b press

        scope main: {
            OS.routine_begin(0x20)

            sw a0, 0x10(sp)

            lw v0, 0x0084(a0) // v0 = player struct

            // tmp variable 3 (0x0184) tracks whether the stick has
            // returned to neutral (X and Y both within TILT_RANGE of
            // center, checked independently) at some point since we
            // entered the wavedash; all the stick-based cancels below
            // require this to have happened first (jump is exempt, see
            // cancel_check). Reset at the DASH->WAVEDASH transition itself
            // (cancel_wavedash), not here on frame 1 - checking the frame
            // here instead would lose a frame, since by the time this
            // code runs on frame 1 it's already a frame too late.
            scope check_neutral: {
                lb t0, 0x01C2(v0) // t0 = stick_x
                bgez t0, _x_positive
                nop
                subu t0, r0, t0 // t0 = abs(stick_x)
                _x_positive:
                slti t1, t0, TILT_RANGE // t1 = 1 if abs(stick_x) < TILT_RANGE
                beqz t1, _end // not neutral: stick_x tilted
                nop

                lb t0, 0x01C3(v0) // t0 = stick_y
                bgez t0, _y_positive
                nop
                subu t0, r0, t0 // t0 = abs(stick_y)
                _y_positive:
                slti t1, t0, TILT_RANGE // t1 = 1 if abs(stick_y) < TILT_RANGE
                beqz t1, _end // not neutral: stick_y tilted
                nop

                lli t0, 1
                sw t0, 0x0184(v0) // mark as returned to neutral

                _end:
            }

            // frames 1-12: check for common cancels (dash/jump/crouch), and
            // cancel to idle if the stick is pushed backward past the
            // threshold that would register as a forward-tilt input
            scope cancel_check: {
                addiu sp, sp, -0x20 // allocate stack space
                lw t0, 0x0078(a0) // t0 = current animation frame (float bits)
                lui t1, 0x4140 // t1 = 12.0F
                sltu t2, t1, t0
                bnez t2, _end // skip if frame > 12
                nop

                // jump is always allowed, regardless of whether the stick
                // has returned to neutral
                lw a0, 0x0030(sp) // a0 = fighter_gobj
                jal 0x8013F4D0 // ftCommonKneeBendCheckInterruptCommon(fighter_gobj)
                nop
                bnez v0, _cancelled
                nop

                // zone transition cancels: compares this frame's stick
                // reading (0x01C2/0x01C3) against last frame's - read
                // directly from the native prev_stick_x/prev_stick_y
                // fields (0x01C4/0x01C5) rather than tracking it
                // ourselves - via classify_zone_. db/b/ub/uf -> neutral
                // cancels (db/ub/uf -> idle, b -> back dash); neutral ->
                // db/ub/uf/df/f also cancels to idle immediately, without
                // needing to return to neutral again first - for forward
                // specifically, cancelling to idle regardless of how hard
                // the input is works fine, since idle's own input handling
                // already decides between a walk and a dash from there. b
                // is deliberately not handled here on the "entering" side -
                // the existing dash-magnitude check and _check_backward_cancel
                // further below already give a hard neutral->back a dash
                // and a soft one an idle cancel.
                scope _zone_transition_check: {
                    lw a0, 0x0030(sp) // a0 = fighter_gobj
                    lw t0, 0x0084(a0) // t0 = player struct

                    lb a0, 0x01C4(t0) // a0 = prev_stick_x
                    lb a1, 0x01C5(t0) // a1 = prev_stick_y
                    lw a2, 0x0044(t0) // a2 = facing direction (lr)
                    jal classify_zone_
                    nop
                    or t4, v0, r0 // t4 = previous input (t0/t1 are clobbered by classify_zone_, so keep this out of their way)

                    lw a0, 0x0030(sp) // a0 = fighter_gobj
                    lw t0, 0x0084(a0) // t0 = player struct
                    lb a0, 0x01C2(t0) // a0 = stick_x
                    lb a1, 0x01C3(t0) // a1 = stick_y
                    lw a2, 0x0044(t0) // a2 = facing direction (lr)
                    jal classify_zone_
                    nop
                    or t5, v0, r0 // t5 = current input

                    bnez t5, _check_enter // not neutral now - check the "entering a zone" cases
                    nop

                    // now neutral - what were we just holding?
                    lli t3, Input.b
                    beq t4, t3, _backdash
                    nop
                    lli t3, Input.db
                    beq t4, t3, _idle
                    nop
                    lli t3, Input.ub
                    beq t4, t3, _idle
                    nop
                    lli t3, Input.uf
                    beq t4, t3, _idle
                    nop
                    b _end
                    nop

                    _check_enter:
                    bnez t4, _end // wasn't neutral last frame either, nothing to do
                    nop
                    lli t3, Input.db
                    beq t5, t3, _idle
                    nop
                    lli t3, Input.ub
                    beq t5, t3, _idle
                    nop
                    lli t3, Input.uf
                    beq t5, t3, _idle
                    nop
                    lli t3, Input.df
                    beq t5, t3, _idle
                    nop
                    lli t3, Input.f
                    beq t5, t3, _idle
                    nop
                    b _end
                    nop

                    _idle:
                    lw a0, 0x0030(sp) // a0 = fighter_gobj
                    jal 0x8013E1C8 // ftCommonWaitSetStatus(fighter_gobj)
                    nop
                    b _cancelled
                    nop

                    _backdash:
                    lw a0, 0x0030(sp) // a0 = fighter_gobj
                    lw t0, 0x0084(a0) // t0 = player struct
                    lwc1 f0, 0x60(t0) // f0 = current ground x velocity
                    neg.s f0, f0
                    swc1 f0, 0x60(t0)

                    OS.save_registers()
                    lli a1, Kazuya.Action.DASHBACK // a1 = Action.DASHBACK
                    or a2, r0, r0 // a2(starting frame) = 0.0
                    lui a3, 0x3FC0 // a3(frame speed multiplier) = 1.5
                    sw r0, 0x0010(sp) // argument 4 = 0
                    jal 0x800E6F24 // change action
                    nop
                    OS.restore_registers()
                    b _cancelled
                    nop

                    _end:
                }

                // everything else below requires the stick to have
                // returned to neutral first (tmp variable 3)
                lw a0, 0x0030(sp) // a0 = fighter_gobj
                lw t0, 0x0084(a0) // t0 = player struct
                lw t1, 0x0184(t0)
                beqz t1, _end
                nop

                // dash input: same magnitude + recency check the stock
                // dash-check uses internally (abs(stick_x) >= 56 and the
                // native horizontal stick hold buffer < 3), just without
                // calling that function directly, since it has side
                // effects (inverting our facing to start a Turn on a
                // backward input) that caused problems being invoked from
                // here. Direction relative to facing then decides backdash
                // vs a plain cancel to idle (forward doesn't need its own
                // dash-starting code - see _forward_cancel below).
                lw a0, 0x0030(sp) // a0 = fighter_gobj
                lw t0, 0x0084(a0) // t0 = player struct
                lb t1, 0x01C2(t0) // t1 = stick_x
                bgez t1, _stickx_positive
                nop
                subu t2, r0, t1 // t2 = abs(stick_x)
                b _range_check
                nop
                _stickx_positive:
                or t2, t1, r0 // t2 = abs(stick_x)
                _range_check:
                slti t3, t2, 56 // t3 = 1 if abs(stick_x) < 56 (not dash range)
                bnez t3, _check_backward_cancel // not far enough for a dash input, check the lighter cancels instead
                nop

                lbu t3, 0x026A(t0) // t3 = horizontal stick hold buffer
                slti t3, t3, 3 // t3 = 1 if buffer < 3 (recent enough)
                beqz t3, _check_backward_cancel // not recent enough for a dash input, check the lighter cancels instead
                nop

                lw t2, 0x0044(t0) // t2 = facing direction (lr)
                mult t1, t2
                mflo t1 // t1 = stick_x * facing direction (positive = forward, negative = backward)
                bgez t1, _forward_cancel
                nop

                // backward: negate our current ground velocity (dash
                // speed in whatever direction we were already moving) so
                // we keep the same speed but move backwards, still facing
                // the same way
                lwc1 f0, 0x60(t0) // f0 = current ground x velocity
                neg.s f0, f0
                swc1 f0, 0x60(t0)

                lw a0, 0x0030(sp) // a0 = fighter_gobj
                OS.save_registers()
                lli a1, Kazuya.Action.DASHBACK // a1 = Action.DASHBACK
                or a2, r0, r0 // a2(starting frame) = 0.0
                lui a3, 0x3FC0 // a3(frame speed multiplier) = 1.5
                sw r0, 0x0010(sp) // argument 4 = 0
                jal 0x800E6F24 // change action
                nop
                OS.restore_registers()
                b _cancelled
                nop

                _forward_cancel:
                // cancel to idle rather than explicitly starting a dash -
                // the game's own idle input handling should pick the hard
                // forward input back up and start a real dash on its own,
                // the same way neutral -> f is handled in
                // _zone_transition_check above
                b _wait_cancel
                nop

                _check_backward_cancel:
                lw a0, 0x0030(sp) // a0 = fighter_gobj
                lw t0, 0x0084(a0) // t0 = player struct
                lb t1, 0x01C2(t0) // t1 = stick_x
                lw t2, 0x0044(t0) // t2 = facing direction (lr)
                mult t1, t2
                mflo t1 // t1 = stick_x * facing direction (positive = forward, negative = backward)
                slti t2, t1, -19 // t2 = 1 if stick is backward past the FTilt threshold (20)
                beqz t2, _end
                nop

                // backward input detected: cancel to idle - the game's
                // own logic takes it from there (e.g. crouching, if the
                // stick is still held down)
                b _wait_cancel
                nop

                _wait_cancel:
                lw a0, 0x20+0x10(sp) // a0 = fighter_gobj
                jal 0x8013E1C8 // ftCommonWaitSetStatus(fighter_gobj)
                nop

                _cancelled:
                addiu sp, sp, 0x20 // undo this scope's own stack allocation
                OS.routine_end(0x20)

                _end:
                addiu sp, sp, 0x20 // undo this scope's own stack allocation
            }

            lw a0, 0x0010(sp) // restore a0 = fighter_gobj (clobbered by the checks above)

            lw v0, 0x0084(a0) // loads player struct into v0
            lhu t1, 0x01BE(v0) // load button press buffer
            andi t2, t1, A_PRESSED // t2 = 0x80 if (A_PRESSED); else t2 = 0
            bne t2, r0, cancel_a // if A is pressed
            nop

            andi t2, t1, B_PRESSED // t2 = 0x80 if (A_PRESSED); else t2 = 0
            bne t2, r0, cancel_b // if A is pressed
            nop

            b normal
            nop

            cancel_a:
            lw t0, 0x0084(a0) // t0 = player struct
            
            OS.save_registers()
            lli a1, Kazuya.Action.GODFIST // a1 = Action.GODFIST
            lui a2, 0x3F80 // a2(starting frame) = 1.0
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            sw r0, 0x0010(sp) // argument 4 = 0
            jal 0x800E6F24 // change action
            nop
            OS.restore_registers()

            li at, GODFIST.proc_shield
            sw at, 0x09F4(t0) // on hit shield function
            li at, GODFIST.proc_hitlag_start
            sw at, 0xA04(t0) // on hit function

            OS.routine_end(0x20)

            cancel_b:
            OS.save_registers()
            lli a1, Kazuya.Action.SWEEP1 // a1 = Action.SWEEP1
            lui a2, 0x3F80 // a2(starting frame) = 1.0
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            sw r0, 0x0010(sp) // argument 4 = 0
            jal 0x800E6F24 // change action
            nop
            OS.restore_registers()
            
            OS.routine_end(0x20)

            normal:
            // if not holding down
            // jal 0x800D94C4 // original routine

            // if holding down
            lw a0, 0x0010(sp) // Argument 0 = fighter_gobj
            li a1, 0x8014329C // Argument 1 = ftCommon_SquatWait_SetStatus (set crouched state)
            jal 0x800D9480 // ftStatus_IfAnimEnd_ProcStatus: Subroutine that waits for animation end to call argument 1
            nop

            OS.routine_end(0x20)
        }
    }

    scope GODFIST: {
        scope proc_shield: {
            OS.routine_begin(0x20)

            // a0 = fighter object
            lw a1, 0x84(a0) // a1 = fighter struct

            scope _check_collision: {
                // for each hitbox
                addiu t6, a1, 0x294 // t6 = first hitbox struct
                addiu t7, t6, 0xC4*3 // t7 = last hitbox struct
                scope _loop_hitbox: {
                    lw at, 0x0(t6) // at = hitbox state
                    beqz at, _next_hitbox // skip if hitbox is disabled
                    nop
                    addiu t8, t6, 0x5C // t8 = hitbox->GMAttackRecord[0]
                    addiu t9, t8, 0x8*3 // t9 = last GMAttackRecord entry
                    scope _loop_attackrecord: {
                        lbu t0, 0x4(t8) // t0 = hitbox collision flags
                        // GMHitFlags bits: hurtbox, shield, reflect, absorb
                        andi t0, t0, 0b01000000 // t0 != 0 if a shield collision occured
                        beqz t0, _next_attackrecord // skip if no collision is detected
                        nop
                        lw t0, 0x0(t8) // t0 = victim object
                        // not checking object type here since shield interaction could
                        // only have happened from a player object
                        found: {
                            addiu sp, sp, -0x30
                            sw t6, 0x20(sp)
                            sw t7, 0x24(sp)
                            sw t8, 0x28(sp)
                            sw t9, 0x2C(sp)
                            jal shield_push
                            nop
                            lw t6, 0x20(sp)
                            lw t7, 0x24(sp)
                            lw t8, 0x28(sp)
                            lw t9, 0x2C(sp)
                            addiu sp, sp, 0x30
                        }
                        _next_attackrecord:
                        bne t8, t9, _loop_attackrecord
                        addiu t8, t8, 0x8
                    }
                    _next_hitbox:
                    bne t6, t7, _loop_hitbox // loop while t7 != last hitbox struct
                    addiu t6, t6, 0xC4 // t6 = next hitbox struct
                }
            }

            OS.routine_end(0x20)
        }

        scope shield_push: {
            OS.routine_begin(0x50)
            // t0 = victim object
            lw t1, 0x84(t0) // t1 = victim struct

            sw t0, 0x30(sp)
            sw t1, 0x34(sp)
            sw a0, 0x3C(sp)
            sw a1, 0x40(sp)

            // check if the opponent is shielding
            lw t0, 0x24(t1) // t0 = opponent's current action
            addiu at, r0, Action.Shield
            beq t0, at, _continue
            addiu at, r0, Action.ShieldStun
            beq t0, at, _continue
            addiu at, r0, Action.ShieldOn
            beq t0, at, _continue
            nop
            b _end
            nop
            
            _continue:
            lw a0, 0x3C(sp) // a0 = attacker object
            lw at, 0x84(a0) // at = attacker struct

            sw r0, 0x7C8(t1) // shield damage = 0
            lw a0, 0x7BC(at) // a0 = attacker->attack_damage
            lw a1, 0x24(t1) // a1 = current action
            jal 0x800EA1C0 // gmCommon_DamageCalcHitLag(s32 damage, s32 status_id, f32 hitlag_mul)
            lui a2, 0x3F80 // TODO: should load hitlag multiplier
            lw t1, 0x34(sp) // restore t1 = defender struct

            sw v0, 0x40(t1) // save hitlag to defender

            jal 0x800DEEC8 // mpCommonSetFighterAir(FTStruct *fp)
            lw a0, 0x34(sp) // a0 = defender struct
            lw t1, 0x34(sp) // restore t1 = defender struct

            _knockback:
            lw a0, 0x3C(sp) // a0 = attacker object
            lw t0, 0x84(a0) // t0 = attacker struct
            lui at, 0x4200 // 32.0 (knockback Y)
            sw at, 0x4C(t1) // save new Y velocity
            lw at, 0x44(t0) // at = attacker facing direction
            mtc1 at, f2 // f2 = facing direction
            negu at, at
            sw at, 0x44(t1) // facing direction = opposite of attacker direction
            cvt.s.w f2, f2 // f2 = facing direction (float)
            lui at, 0x4200 // 32.0 (knockback X)
            mtc1 at, f4
            mul.s f2, f2, f4
            swc1 f2, 0x48(t1) // save new X velocity

            lw a0, 0x30(sp) // a0 = defender object
            lli a1, Action.DamageHigh3 // a1 = Action.DamageHigh3
            or a2, r0, r0 // a2(starting frame) = 0.0
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            jal 0x800E6F24 // change action
            sw r0, 0x10(sp) // argument 4 = 0
            jal 0x800E0830 // unknown common subroutine
            lw a0, 0x30(sp) // a0 = other player object

            _end:
            lw a0, 0x3C(sp)
            lw a1, 0x40(sp)
            OS.routine_end(0x50)
        }

        scope proc_hitlag_start: {
            OS.routine_begin(0x20)

            // a0 = fighter object
            lw a1, 0x84(a0)
            
            // lw at, 0x7B0(a1) // at = fp->attack_damage (how much damage we're dealing)
            // Set hitlag to 0 frames
            lw at, 0x40(a1) // at = current hitlag
            srl at, at, 3 // at = current hitlag / 8
            sw at, 0x40(a1) // set new hitlag value

            OS.routine_end(0x20)
        }
    }

    scope SWEEP: {
        constant A_PRESSED(0x8000) // bitmask for a press
        constant B_PRESSED(0x4000) // bitmask for b press

        // tmp variable 3 0x0184 -- used to check if A or B was ever pressed down during the move

        scope main: {
            OS.routine_begin(0x20)

            lw v0, 0x0084(a0) // v0 = player struct

            lw t0, 0x0078(a0) // t0 = current animation frame
            lui t1, 0x4000 // t1 = 1.0F

            // if frame != 1, skip
            bne t0, t1, main_continue
            nop
            
            sw r0, 0x0184(v0) // reset tmp variable 3 = 0

            main_continue:
            sw a0, 0x0010(sp)
            
            lw v0, 0x0084(a0) // loads player struct into v0
            lhu t1, 0x01BE(v0) // load button press buffer
            andi t2, t1, A_PRESSED // t2 = 0x80 if (A_PRESSED); else t2 = 0
            bne t2, r0, register_press // if A is pressed
            nop

            andi t2, t1, B_PRESSED // t2 = 0x80 if (A_PRESSED); else t2 = 0
            bne t2, r0, register_press // if A is pressed
            nop

            b normal
            nop

            register_press:
            lli t0, 0x1
            sw t0, 0x0184(v0)

            b normal
            nop

            normal:
            lw t0, 0x0078(a0) // t0 = current animation frame
            mtc1 t0, f6
            lui t1, 0x4150 // t1 = 13.0F
            mtc1 t1, f8

            c.eq.s f6, f8
            nop
            bc1fl main_normal
            nop

            lw t0, 0x0184(v0) // was A or B ever pressed during the move?
            beq t0, r0, main_normal // If not, main_normal
            nop

            // all conditions are met
            b cancel_spin_2
            nop

            cancel_spin_2:
            OS.save_registers()
            lli a1, Kazuya.Action.SWEEP2 // a1 = Action.SWEEP1
            or a2, r0, r0 // a2(starting frame) = 0.0
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            lli t6, 0x0003 // ~
            sw t6, 0x0010(sp) // argument 4 = 0x0003 keep hitboxes
            jal 0x800E6F24 // change action
            nop
            OS.restore_registers()
            OS.routine_end(0x20)

            main_normal:
            jal 0x800D94C4 // original routine
            nop
            OS.routine_end(0x20)
        }
    }

    scope RR3KICKS: {
        constant A_PRESSED(0x8000) // bitmask for a press
        constant B_PRESSED(0x4000) // bitmask for b press

        // tmp variable 3 0x0184 -- used to check if A or B was ever pressed down during the move

        scope main: {
            OS.routine_begin(0x20)

            lw v0, 0x0084(a0) // v0 = player struct

            lw t0, 0x0078(a0) // t0 = current animation frame
            lui t1, 0x4000 // t1 = 1.0F

            // if frame != 1, skip
            bne t0, t1, main_continue
            nop
            
            sw r0, 0x0184(v0) // reset tmp variable 3 = 0

            main_continue:
            sw a0, 0x0010(sp)
            
            lw v0, 0x0084(a0) // loads player struct into v0
            lhu t1, 0x01BE(v0) // load button press buffer
            andi t2, t1, A_PRESSED // t2 = 0x80 if (A_PRESSED); else t2 = 0
            bne t2, r0, register_press // if A is pressed
            nop

            andi t2, t1, B_PRESSED // t2 = 0x80 if (A_PRESSED); else t2 = 0
            bne t2, r0, register_press // if A is pressed
            nop

            b normal
            nop

            register_press:
            lli t0, 0x1
            sw t0, 0x0184(v0)

            b normal
            nop

            normal:
            lw t3, 0x0024(v0) // t3 = current action

            // Here, we load into t1 the frame in which each step of the move should check for a transition
            lli t2, Action.FTiltMidHigh
            beq t2, t3, normal_continue
            lui t1, 0x41A0 // t1 = 20.0F

            lli t2, Action.FTiltHigh
            beq t2, t3, normal_continue
            lui t1, 0x41A0 // t1 = 20.0F

            lli t2, Kazuya.Action.RR3KICKS2
            beq t2, t3, normal_continue
            lui t1, 0x4198 // t1 = 19.0F

            lli t2, Kazuya.Action.RR3KICKS3
            beq t2, t3, normal_continue
            lui t1, 0x41B0 // t1 = 22.0F

            normal_continue:
            lw t0, 0x0078(a0) // t0 = current animation frame
            mtc1 t0, f6
            mtc1 t1, f8

            c.eq.s f6, f8
            nop
            bc1fl main_normal
            nop

            lw t0, 0x0184(v0) // was A or B ever pressed during the move?
            beq t0, r0, main_normal // If not, main_normal
            nop

            // all conditions are met
            b cancel_next
            nop

            cancel_next:
            lw t1, 0x0024(v0) // t1 = current action

            // we'll use t2 to store the next action as we jump

            lli t2, Action.FTiltMidHigh
            beq t1, t2, cancel_next_change_action
            lli t2, Kazuya.Action.RR3KICKS2

            lli t2, Action.FTiltHigh
            beq t1, t2, cancel_next_change_action
            lli t2, Kazuya.Action.RR3KICKS2

            lli t2, Kazuya.Action.RR3KICKS2
            beq t1, t2, cancel_next_change_action
            lli t2, Kazuya.Action.RR3KICKS3

            lli t2, Kazuya.Action.RR3KICKS3
            beq t1, t2, cancel_next_change_action
            lli t2, Kazuya.Action.RR3KICKS4

            cancel_next_change_action:
            OS.save_registers()
            or a1, r0, t2 // a1 = t2 = next action
            or a2, r0, r0 // a2(starting frame) = 0.0
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            sw r0, 0x0010(sp) // argument 4 = 0
            jal 0x800E6F24 // change action
            nop
            OS.restore_registers()
            OS.routine_end(0x20)

            main_normal:
            jal 0x800D94C4 // original routine
            nop
            OS.routine_end(0x20)
        }
    }

    scope UTILT: {
        constant A_PRESSED(0x8000) // bitmask for a press

        // tmp variable 3 0x0184 -- used to check if A was ever pressed down during the move

        scope main: {
            OS.routine_begin(0x20)

            lw v0, 0x0084(a0) // v0 = player struct

            lw t0, 0x0078(a0) // t0 = current animation frame
            lui t1, 0x4000 // t1 = 1.0F

            // if frame != 1, skip
            bne t0, t1, main_continue
            nop
            
            sw r0, 0x0184(v0) // reset tmp variable 3 = 0

            main_continue:
            sw a0, 0x0010(sp)
            
            lw v0, 0x0084(a0) // loads player struct into v0
            lhu t1, 0x01BE(v0) // load button press buffer
            andi t2, t1, A_PRESSED // t2 = 0x80 if (A_PRESSED); else t2 = 0
            bne t2, r0, register_press // if A is pressed
            nop

            b normal
            nop

            register_press:
            lli t0, 0x1
            sw t0, 0x0184(v0)

            b normal
            nop

            normal:
            lw t0, 0x0078(a0) // t0 = current animation frame
            mtc1 t0, f6
            lui t1, 0x41A0 // t1 = 20.0F
            mtc1 t1, f8

            c.eq.s f6, f8
            nop
            bc1fl main_normal
            nop

            lw t0, 0x0184(v0) // was A or B ever pressed during the move?
            beq t0, r0, main_normal // If not, main_normal
            nop

            // all conditions are met
            b cancel_utilt_2
            nop

            cancel_utilt_2:
            OS.save_registers()
            lli a1, Kazuya.Action.TILTU2 // a1 = Action.SWEEP1
            or a2, r0, r0 // a2(starting frame) = 0.0
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            lli t6, 0x0003 // ~
            sw t6, 0x0010(sp) // argument 4 = 0x0003 keep hitboxes
            jal 0x800E6F24 // change action
            nop
            OS.restore_registers()
            OS.routine_end(0x20)

            main_normal:
            jal 0x800D94C4 // original routine
            nop
            OS.routine_end(0x20)
        }
    }

    // @ Description
    // Checks for the down/down-back -> down-forward wavedash-trigger
    // gesture. Shared by DASH.main and TURN.main below, so wavedashing
    // works the same regardless of which of the two Kazuya is coming out
    // of. Progress (0x0AE4 - see OnActionChanged._dash_turn_reset_check
    // for why this isn't one of the "tmp variable" slots) is reset once,
    // in OnActionChanged._dash_turn_reset_check, only when actually
    // entering the DASH/TURN pair from outside it - not here.
    // states: 1 = waiting for Input.d or Input.db (down or down-back)
    //         2 = Input.d/Input.db seen, waiting for Input.df
    //             (down-forward, facing-relative) to trigger the
    //             action change
    // a0 - fighter_gobj
    // returns
    // v0 - 1 if the wavedash was triggered (the action was already
    //      changed - the caller should return immediately rather than
    //      running its own normal per-frame handling), 0 otherwise
    scope check_wavedash_input_: {
        OS.routine_begin(0x20)
        sw a0, 0x10(sp)

        lw v0, 0x0084(a0) // v0 = player struct
        lw t0, 0x0AE4(v0)

        lli t1, 0x1
        beq t0, t1, check_down
        nop

        lli t1, 0x2
        beq t0, t1, check_diagonal
        nop

        b _not_triggered
        nop

        check_down:
        lb a0, 0x01C2(v0) // a0 = stick_x
        lb a1, 0x01C3(v0) // a1 = stick_y
        lw a2, 0x0044(v0) // a2 = facing direction (lr)
        jal classify_zone_
        nop
        or t1, v0, r0 // t1 = classified input
        lw a0, 0x0010(sp) // a0 = fighter_gobj (re-establish after the call)
        lw v0, 0x0084(a0) // v0 = player struct

        lli t2, Input.d
        beq t1, t2, _down_ok
        nop
        lli t2, Input.db
        bne t1, t2, _not_triggered
        nop
        _down_ok:

        lli t0, 0x2
        sw t0, 0x0AE4(v0) // Input.d/Input.db seen, set state to 2 (waiting for Input.df)

        b _not_triggered
        nop

        check_diagonal:
        lb a0, 0x01C2(v0) // a0 = stick_x
        lb a1, 0x01C3(v0) // a1 = stick_y
        lw a2, 0x0044(v0) // a2 = facing direction (lr)
        jal classify_zone_
        nop
        or t1, v0, r0 // t1 = classified input
        lw a0, 0x0010(sp) // a0 = fighter_gobj (re-establish after the call)
        lw v0, 0x0084(a0) // v0 = player struct

        lli t2, Input.df
        bne t1, t2, _not_triggered
        nop

        // all conditions are met
        // explicitly clear the neutral-tracking flag here rather than
        // relying solely on WAVEDASH.main's own frame-1 reset - it was
        // just set to 1 by our own check_neutral above, and if the
        // reset there doesn't land precisely on frame 1, WAVEDASH
        // would incorrectly start out thinking the stick already
        // returned to neutral, letting it retrigger every frame while
        // down+forward is held
        sw r0, 0x0184(v0) // tmp variable 3 (neutral-tracking, WAVEDASH's own meaning for this field)

        OS.save_registers()
        lli a1, Kazuya.Action.WAVEDASH // a1 = Action.SWEEP1
        or a2, r0, r0 // a2(starting frame) = 0.0
        lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
        lli t6, 0x0003 // ~
        sw t6, 0x0010(sp) // argument 4 = 0x0003 keep hitboxes
        jal 0x800E6F24 // change action
        nop
        OS.restore_registers()

        lli v0, 1
        OS.routine_end(0x20)

        _not_triggered:
        lli v0, 0
        OS.routine_end(0x20)
    }

    scope DASH: {
        scope main: {
            OS.routine_begin(0x20)

            jal check_wavedash_input_
            nop
            bnez v0, _end // wavedash was triggered - action already changed
            nop

            jal 0x800D94C4 // original routine
            nop

            _end:
            OS.routine_end(0x20)
        }
    }

    scope TURN: {
        scope main: {
            OS.routine_begin(0x20)

            jal check_wavedash_input_
            nop
            bnez v0, _end // wavedash was triggered - action already changed
            nop

            jal 0x8013E690 // original Turn main/update routine
            nop

            _end:
            OS.routine_end(0x20)
        }
    }

    scope DASHBACK: {
        // Copy of Dash, but entered while already moving backwards relative
        // to our facing (see DASH.cancel_dashback). Only cancellable into
        // jump (no dash attack); on animation end, goes to Wait instead of
        // continuing into Run.

        scope main: {
            OS.routine_begin(0x20)

            lw at, 0x0078(a0) // at = current animation frame (counts down)
            bgtz at, _end // skip if animation hasn't ended yet
            nop

            jal 0x8013E1C8 // ftCommonWaitSetStatus(fighter_gobj)
            nop

            _end:
            OS.routine_end(0x20)
        }

        scope interrupt: {
            OS.routine_begin(0x20)

            jal 0x8013F4D0 // ftCommonKneeBendCheckInterruptCommon(fighter_gobj) - jump cancel only
            nop

            OS.routine_end(0x20)
        }
    }

    scope TSUNAMI: {
        constant A_PRESSED(0x8000) // bitmask for a press

        // tmp variable 3 0x0184 -- used to check if A was ever pressed down during the move

        scope main: {
            OS.routine_begin(0x20)

            lw v0, 0x0084(a0) // v0 = player struct

            lw t0, 0x0078(a0) // t0 = current animation frame
            lui t1, 0x4000 // t1 = 1.0F

            // if frame != 1, skip
            bne t0, t1, main_continue
            nop
            
            sw r0, 0x0184(v0) // reset tmp variable 3 = 0

            main_continue:
            sw a0, 0x0010(sp)
            
            lw v0, 0x0084(a0) // loads player struct into v0
            lhu t1, 0x01BE(v0) // load button press buffer
            andi t2, t1, A_PRESSED // t2 = 0x80 if (A_PRESSED); else t2 = 0
            bne t2, r0, register_press // if A is pressed
            nop

            b normal
            nop

            register_press:
            lli t0, 0x1
            sw t0, 0x0184(v0)

            b normal
            nop

            normal:
            lw t0, 0x0078(a0) // t0 = current animation frame
            mtc1 t0, f6
            lui t1, 0x4180 // t1 = 16.0F
            mtc1 t1, f8

            c.eq.s f6, f8
            nop
            bc1fl main_normal
            nop

            lw t0, 0x0184(v0) // was A or B ever pressed during the move?
            beq t0, r0, main_normal // If not, main_normal
            nop

            // all conditions are met
            b cancel_tsunami_2
            nop

            cancel_tsunami_2:
            OS.save_registers()
            lli a1, Kazuya.Action.TSUNAMI2 // a1 = Action.SWEEP1
            or a2, r0, r0 // a2(starting frame) = 0.0
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            lli t6, 0x0003 // ~
            sw t6, 0x0010(sp) // argument 4 = 0x0003 keep hitboxes
            jal 0x800E6F24 // change action
            nop
            OS.restore_registers()
            OS.routine_end(0x20)

            main_normal:
            jal 0x800D94C4 // original routine
            nop
            OS.routine_end(0x20)
        }
    }

    scope NSP: {
        // The original electric effect function code does:
        // [ pos = (random() * deviation) + (deviation_neg) ]
        constant POS_DEVIATION(0x4120) // 10.0F (original is 300.0F)
        constant POS_DEVIATION_NEG(0xC0A0) // -5.0 (negative deviation/2)

        constant SCALE_MULTI(0x3FC0) // Scale multiplier = 1.5F

        scope main: {
            OS.routine_begin(0x20)

            lw t0, 0x0078(a0) // t0 = current animation frame
            mtc1 t0, f0

            lui t0, 0x41F0 // t0 = 30.0f
            mtc1 t0, f2

            c.lt.s f0, f2 // Compare f0 < f2?
            bc1f normal // Branch if current frame > 30
            nop

            mtc1 r0, f2 // f2 = 0
            c.lt.s f2, f0 // Compare f2 < f0?
            bc1f normal // Branch if current frame < 0
            nop

            // Here we check if current frame % (N) == 0
            // So we generate an effect every N frames

            lui t0, 0x4040 // t0 = 6.0f
            mtc1 t0, f2

            div.s f1, f0, f2 // Divide f0 by f2
            nop
            floor.w.s f2, f1 // f2 = floor(f1)
            cvt.s.w f2, f2
            c.eq.s f2, f1 // Check if the original float is equal to its floor
            nop
            bc1f normal // Branch if false
            nop

            OS.save_registers()

            addiu sp, sp, -0x30

            // Get hand position vector using a vanilla function
            lw v0, 0x0084(a0) // loads player struct into v0
            mtc1 r0, f0
            addiu a1, sp, 0x0020
            swc1 f0, 0x0020(sp) // x origin point
            swc1 f0, 0x0024(sp) // y origin point
            swc1 f0, 0x0028(sp) // z origin point
            lw a0, 0x0910(v0) // argument 0: object = Captain Falcon left hand joint
            sw a3, 0x0030(sp)

            jal 0x800EDF24 // determine origin point of object in argument 0
            sw v0, 0x002C(sp)

            lw v0, 0x002C(sp)
            lw a3, 0x0030(sp)
            sw r0, 0x001C(sp)
            or a0, a3, r0
            addiu a0, sp, 0x0020

            // Reimplement subroutine 0x800FEEB0 (efParticle_ShockSmall_MakeEffect)
            OS.copy_segment(0x7A6B0, 0x44)

            lui at, POS_DEVIATION // X deviation
            mtc1 at, f4
            lui at, POS_DEVIATION_NEG // X deviation neg
            mtc1 at, f8

            OS.copy_segment(0x7A6B0+0x54, 0x6C-0x54)

            lui at, POS_DEVIATION // Y deviation
            mtc1 at, f4
            lui at, POS_DEVIATION_NEG // Y deviation neg
            mtc1 at, f8

            OS.copy_segment(0x7A6B0+0x7C, 0x108-0x7C)

            lui t0, SCALE_MULTI // scale multiplier
            mtc1 t0, f6
            mul.s f2, f2, f6
            nop
            swc1 f2,0x40(s1)
            swc1 f2,0x44(s1)

            OS.copy_segment(0x7A6B0+0x108, 0x124-0x108)

            addiu sp,sp,0x38 // final function line
            
            addiu sp, sp, 0x30

            OS.restore_registers()

            normal:
            lw t0, 0x014C(v0) // t0 = kinetic state
            bnez t0, aerial // branch if kinetic state !grounded
            nop

            grounded:
            jal 0x800D94C4 // original routine
            nop
            b end
            nop

            aerial:
            jal 0x800D94E8
            nop
            
            end:
            OS.routine_end(0x20)
        }

        scope light_to_hard: {
            OS.routine_begin(0x20)

            lwc1 f8, 0x0078(a0) // load current animation frame
            lui		at, 0x4100					// at = 8.0
            mtc1 at, f6 // ~
            c.eq.s f8, f6 // f8 == f6 (current frame == 8) ?
            nop
            bc1fl _end // skip if frame isn't greater than 6
            nop

            lhu t0, 0x01BC(a2) // load button press buffer
            andi t1, t0, 0x4000 // t1 = 0x40 if (B_PRESSED); else t1 = 0
            beq t1, r0, _end // skip if (!B_PRESSED)
            nop

            addiu sp, sp,-0x0038 // allocate stack space
            sw ra, 0x0004(sp)
            sw a0, 0x0008(sp)
            sw a1, 0x000C(sp) // store variables
            sw a2, 0x0010(sp) // store variables
            sw a3, 0x0014(sp) // store variables
            sw v0, 0x0018(sp) // store variables
            addiu sp, sp,-0x0030 // allocate stack space

            lw v0, 0x0034(a2) // v0 = player struct

            lli a1, Kazuya.Action.SPECIALN2 // a1 = Action
            lw a2, 0x0078(a0) // a2(starting frame) = current animation frame
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            sw r0, 0x0010(sp) // argument 4 = 0
            jal 0x800E6F24 // change action
            nop

            addiu sp, sp, 0x0030 // allocate stack space
            lw ra, 0x0004(sp) // restore ra
            lw a0, 0x0008(sp)
            lw a1, 0x000C(sp) // restore a2
            lw a2, 0x0010(sp) // restore a2
            lw a3, 0x0014(sp) // restore a2
            lw v0, 0x0018(sp) // restore a2
            addiu sp, sp, 0x0038 // deallocate stack space

            _end:
            OS.routine_end(0x20)
        }
    }

    scope DSP: {
        scope air_collision: {
            OS.routine_begin(0x20)
            sw ra, 0x0014(sp) // store ra
            li a1, air_to_ground // a1(transition subroutine) = air_to_ground
            jal 0x800DE80C // common air collision subroutine (transition on landing, allow ledge grab)
            nop 
            lw ra, 0x0014(sp) // load ra
            OS.routine_end(0x20)
        }

        scope air_to_ground: {
            addiu sp, sp,-0x0038 // allocate stack space
            sw ra, 0x001C(sp) // store ra
            sw a0, 0x0038(sp) // 0x0038(sp) = player object
            lw a0, 0x0084(a0) // a0 = player struct
            jal 0x800DEE98 // set grounded state
            sw a0, 0x0034(sp) // 0x0034(sp) = player struct
            lw v0, 0x0034(sp) // v0 = player struct
            lw a0, 0x0038(sp) // a0 = player object
            
            addiu a1, r0, 0xE6 // a1 = equivalent ground action for current air action
            
            lw a2, 0x0078(a0) // a2(starting frame) = current animation frame
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            lli t6, 0x0001 // ~
            jal 0x800E6F24 // change action
            sw t6, 0x0010(sp) // argument 4 = 1 (continue hitbox)
            lw ra, 0x001C(sp) // load ra
            addiu sp, sp, 0x0038 // deallocate stack space
            jr ra // return
            nop
        }
    }

    scope USP: {
        constant MOVE_SPEED_Y(0x42C8) // float 100
        constant MOVE_SPEED_X(0x3F00) // float 0.5

        scope main: {
            OS.routine_begin(0x20)

            lw v0, 0x0084(a0) // v0 = player struct

            lw t0, 0x0078(a0) // t0 = current animation frame
            lui t1, 0x3F80 // t1 = 1.0F

            // if frame != 1, skip
            bne t0, t1, main_continue
            nop
            
            lui at, MOVE_SPEED_Y // load y velocity
            sw at, 0x004C(v0) // save updated y velocity

            lb t0, 0x01C2(v0) // t0 = stick_x
            mtc1 t0, f14 // ~
            cvt.s.w f14, f14 // f14 = stick x
            lui t0, MOVE_SPEED_X // load move speed into t0
            mtc1 t0, f12 // move move speed to fp register
            mul.s f10, f14, f12 // multiply move speed by stick_x input
            swc1 f10, 0x0048(v0) // store updated x velocity

            main_continue:
            jal 0x800D90E0 // original routine
            nop

            OS.routine_end(0x20)
        }

        scope collision: {
            OS.routine_begin(0x20)

            sw ra, 0x001c (sp) // save return address to stack
            lw a1, 0x0084 (a0) // load player struct
            sw a0, 0x0028 (sp) // save player object to stack

            jal 0x800de87c // check to see if player has collided with clipping
            sw a1, 0x0024(sp) // save player struct

            beqz v0, _end // if no collision, skip to end
            lw a1, 0x0024(sp) // load player struct

            lhu v0, 0x00d2(a1) // load collision clipping flag
            andi t6, v0, Surface.GROUND // check if colliding with a floor

            beqz t6, _cliff_check // branch not colliding with a wall
            andi t7, v0, 0x3000 // check if colliding with cliff

            _ground:
            jal 0x800dee98
            or a0, a1, r0 // place player struct in a0

            lw a0, 0x0028 (sp) // load player object
            addiu a1, r0, Kazuya.Action.USP_LAND // load action ID
            addiu a2, r0, 0x0000
            lui a3, 0x3f80 // 1.0 placed in a3

            lli t6, 0x0001 // ~
            sw t6, 0x0010(sp) // argument 4 = 1 (continue hitbox)

            jal 0x800e6f24 // change action routine
            nop

            b _end_2
            lw ra, 0x001c (sp) // load return address

            _cliff_check:
            beqzl t7, _end // branch if not a cliff
            andi t6, v0, Surface.CEILING // check if colliding with a ceiling
            jal 0x80144c24 // cliff catch routine
            lw a0, 0x0028 (sp) // load player object

            _end:
            lw ra, 0x001c (sp) // load return address
            _end_2:
            OS.routine_end(0x20)
        }
    }

    scope NSP_AIR: {
        constant AIR_Y_SPEED(0x4248) // current setting - float32 50
        constant AIR_ACCELERATION(0x3C65) // current setting - float32 0.014
        constant AIR_SPEED(0x41A0) // current setting - float32 20
        // @ Description
        // Subroutine which handles movement for Marina's up special.
        // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
        // This command's purpose appears to be setting a temporary variable in the player struct.
        // The most common use of this variable is to determine when a throw should be applied.
        // Variable values used by this subroutine:
        // 0x2 = begin movement
        // 0x3 = movement
        // 0x4 = ending
        scope physics: {
            // s0 = player struct
            // s1 = attributes pointer
            // 0x184 in player struct = temp variable 3
            addiu sp, sp,-0x0038 // allocate stack space
            sw ra, 0x001C(sp) // ~
            sw s0, 0x0014(sp) // ~
            sw s1, 0x0018(sp) // store ra, s0, s1

            lw s0, 0x0084(a0) // s0 = player struct
            lw t0, 0x014C(s0) // t0 = kinetic state

            OS.copy_segment(0x548F0, 0x40) // copy from original air physics subroutine
            li t8, air_control_ // t8 = air_control_

            _apply_air_physics:
            or a0, s0, r0 // a0 = player struct
            jalr t8 // air control subroutine
            or a1, s1, r0 // a1 = attributes pointer
            or a0, s0, r0 // a0 = player struct
            jal 0x800D9074 // air friction subroutine?
            or a1, s1, r0 // a1 = attributes pointer

            _check_begin:
            lw t0, 0x4(s0) // t1 = player object
            lwc1 f8, 0x0078(t0) // load current animation frame

            lui		at, 0x4040					// at = 1.0
            mtc1 at, f6 // ~
            c.eq.s f8, f6 // f8 == f6 (current frame == 1) ?
            nop
            bc1fl _check_hop // skip if frame isn't 1
            nop

            // sw r0, 0x0048(s0) // x velocity = 0
            // sw r0, 0x004C(s0) // y velocity = 0

            _check_hop:
            lwc1 f8, 0x0078(t0) // load current animation frame
            lui		at, 0x41C0					// at = 24.0
            mtc1 at, f6 // ~
            c.eq.s f8, f6 // f8 == f6 (current frame == 10) ?
            nop
            bc1fl _end // skip if frame isn't 10
            nop

            lui t1, AIR_Y_SPEED // t1 = AIR_Y_SPEED
            sw t1, 0x004C(s0) // store y velocity

            lui t1, AIR_SPEED // t1 = AIR_Y_SPEED
            lw t2, 0x0044(s0) // t2 = facing direction (1 = right, -1 = left)

            slti t3, t2, 0
            beq t3, r0, set_x_speed
            nop

            facing_left:
            mtc1 t1, f6
            neg.s f6, f6
            mfc1 t1, f6

            set_x_speed:
            sw t1, 0x0048(s0) // store x velocity

            _end:
            lw ra, 0x001C(sp) // ~
            lw s0, 0x0014(sp) // ~
            lw s1, 0x0018(sp) // loar ra, s0, s1
            addiu sp, sp, 0x0038 // deallocate stack space
            jr ra // return
            nop
        }

        // @ Description
        // Subroutine which handles Marina's horizontal control for up special.
        scope air_control_: {
            addiu sp, sp,-0x0028 // allocate stack space
            sw a1, 0x001C(sp) // ~
            sw ra, 0x0014(sp) // ~
            sw t0, 0x0020(sp) // ~
            sw t1, 0x0024(sp) // store a1, ra, t0, t1
            addiu a1, r0, 0x0008 // a1 = 0x8 (original line)
            lw t6, 0x001C(sp) // t6 = attribute pointer
            // load an immediate value into a2 instead of the air acceleration from the attributes
            lui a2, AIR_ACCELERATION // a2 = AIR_ACCELERATION
            lui a3, AIR_SPEED // a3 = AIR_SPEED
            jal 0x800D8FC8 // air drift subroutine?
            nop
            lw ra, 0x0014(sp) // ~
            lw t0, 0x0020(sp) // ~
            lw t1, 0x0024(sp) // load ra, t0, t1
            addiu sp, sp, 0x0028 // deallocate stack space
            jr ra // return
            nop
        }

        // @ Description
        // Subroutine which allows a direction change
        // Uses the moveset data command 580000XX (orignally identified as "set flag" by toomai)
        // This command's purpose appears to be setting a temporary variable in the player struct.
        // Variable values used by this subroutine:
        // 0x2 = change direction
        scope change_direction_: {
            // begin by checking for turn inputs
            lw a1, 0x0084(a0) // a1 = player struct

            lui		at, 0x4000					// at = 1.0
            mtc1 at, f6 // ~
            lwc1 f8, 0x0078(a0) // ~
            c.eq.s f8, f6 // ~
            nop
            bc1fl _end // skip if haven't reached frame 3
            nop

            lb t6, 0x01C2(a1) // t6 = stick_x
            lw t7, 0x0044(a1) // t7 = DIRECTION
            multu t6, t7 // ~
            mflo t6 // t6 = stick_x * DIRECTION
            slti at, t6, -39 // at = 1 if stick_x < -39, else at = 0
            beqz at, _end // branch if stick_x >= -39
            nop

            // if we're here, stick_x is opposite the facing direction, so turn the character around
            subu t7, r0, t7 // ~
            sw t7, 0x0044(a1) // reverse and update DIRECTION

            mtc1 t7, f6 // ~
            cvt.s.w f6, f6 // f6 = direction
            lui at, 0x8013 // ~
            lwc1 f8, 0xFE90(at) // at = rotation constant
            mul.s f8, f8, f6 // f8 = rotation constant * direction
            lw t7, 0x08E8(a1) // t6 = character control joint struct
            swc1 f8, 0x0034(t7) // update character rotation to match direction

            _end:
            jr ra // return
            nop
        }

        scope collision: {
            OS.routine_begin(0x20)
            sw ra, 0x0014(sp) // store ra
            li a1, air_to_ground // a1(transition subroutine) = air_to_ground
            jal 0x800DE80C // common air collision subroutine (transition on landing, allow ledge grab)
            nop 
            lw ra, 0x0014(sp) // load ra
            OS.routine_end(0x20)
        }

        scope air_to_ground: {
            addiu sp, sp,-0x0038 // allocate stack space
            sw ra, 0x001C(sp) // store ra
            sw a0, 0x0038(sp) // 0x0038(sp) = player object
            lw a0, 0x0084(a0) // a0 = player struct
            jal 0x800DEE98 // set grounded state
            sw a0, 0x0034(sp) // 0x0034(sp) = player struct
            lw v0, 0x0034(sp) // v0 = player struct
            lw a0, 0x0038(sp) // a0 = player object
            
            addiu a1, r0, 0xE4 // a1 = equivalent ground action for current air action
            
            lw a2, 0x0078(a0) // a2(starting frame) = current animation frame
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            lli t6, 0x0001 // ~
            jal 0x800E6F24 // change action
            sw t6, 0x0010(sp) // argument 4 = 1 (continue hitbox)
            lw ra, 0x001C(sp) // load ra
            addiu sp, sp, 0x0038 // deallocate stack space
            jr ra // return
            nop
        }
    }
}

scope KazuyaUSP {
    // floating point constants for physics and fsm
    constant AIR_Y_SPEED(0x0) // current setting - float32 92
    constant GROUND_Y_SPEED(0x0) // current setting - float32 98
    constant X_SPEED(0x4120) // current setting - float32 10
    constant AIR_ACCELERATION(0x3E4C) // current setting - float32 0.2
    constant AIR_SPEED(0x41B0) // current setting - float32 22
    constant LANDING_FSM(0x3EC0) // current setting - float32 0.375
    // temp variable 3 constants for movement states
    constant BEGIN(0x1)
    constant BEGIN_MOVE(0x2)
    constant MOVE(0x3)

    // @ Description
    // Subroutine which runs when Cloud initiates an aerial up special.
    // Changes action, and sets up initial variable values.
    scope air_initial_: {
        addiu sp, sp, 0xFFE0 // ~
        sw ra, 0x001C(sp) // ~
        sw a0, 0x0020(sp) // original lines 1-3
        sw r0, 0x0010(sp) // argument 4 = 0
        lli a1, Kazuya.Action.USP // a1 = Action.USPA
        or a2, r0, r0 // a2 = float: 0.0
        jal 0x800E6F24 // change action
        lui a3, 0x3F80 // a3 = float: 1.0
        jal 0x800E0830 // unknown common subroutine
        lw a0, 0x0020(sp) // a0 = player object
        lw a0, 0x0020(sp) // ~
        lw a0, 0x0084(a0) // a0 = player struct
        sw r0, 0x017C(a0) // temp variable 1 = 0
        sw r0, 0x0180(a0) // temp variable 2 = 0
        ori v1, r0, 0x0002 // ~
        sw v1, 0x0184(a0) // temp variable 3 = 0x1(BEGIN)
        // reset fall speed
        lbu v1, 0x018D(a0) // v1 = fast fall flag
        ori t6, r0, 0x0007 // t6 = bitmask (01111111)
        and v1, v1, t6 // ~
        sb v1, 0x018D(a0) // disable fast fall flag
        // freeze y position
        lw v1, 0x09C8(a0) // v1 = attribute pointer
        lw v1, 0x0058(v1) // v1 = gravity
        sw v1, 0x004C(a0) // y velocity = gravity
        lw ra, 0x001C(sp) // ~
        addiu sp, sp, 0x0020 // ~
        jr ra // original return logic
        nop
    }

    // @ Description
    // Subroutine which runs when Cloud initiates a grounded up special.
    // Changes action, and sets up initial variable values.
    scope ground_initial_: {
        addiu sp, sp, 0xFFE0 // ~
        sw ra, 0x001C(sp) // ~
        sw a0, 0x0020(sp) // original lines 1-3

        lw a0, 0x0084(a0) // a0 = player struct
        lw t7, 0x014C(a0) // t7 = kinetic state
        bnez t7, _change_action // skip if kinetic state !grounded
        nop
        jal 0x800DEEC8 // set aerial state
        nop
        lw a0, 0x0020(sp)

        _change_action:
        sw r0, 0x0010(sp) // argument 4 = 0
        lli a1, Kazuya.Action.USP // a1 = Action.USPG
        or a2, r0, r0 // a2 = float: 0.0
        jal 0x800E6F24 // change action
        lui a3, 0x3F80 // a3 = float: 1.0
        jal 0x800E0830 // unknown common subroutine
        lw a0, 0x0020(sp) // a0 = player object
        lw a0, 0x0020(sp) // ~
        lw a0, 0x0084(a0) // a0 = player struct
        sw r0, 0x017C(a0) // temp variable 1 = 0
        sw r0, 0x0180(a0) // temp variable 2 = 0
        ori v1, r0, 0x0002 // ~
        sw v1, 0x0184(a0) // temp variable 3 = 0x1(BEGIN)
        lw ra, 0x001C(sp) // ~
        addiu sp, sp, 0x0020 // ~
        jr ra // original return logic
        nop
    }

    // @ Description
    // Subroutine which controls the physics of the movement stage of Dedede's Up Special.
    scope physics2_: {
        // a0 = player object
        addiu sp, sp, -0x10 // allocate stack
        sw ra, 0x0008 (sp) // save return address

        jal apply_vertical_movement2_
        nop

        _end:
        lw ra, 0x0008 (sp) // save return address
        jr ra
        addiu sp, sp, 0x10
    }

    constant BEGIN_SPEED(0x3F00) // float 0.5
    constant MOVE_SPEED_X(0x3F30) // float 0.6875
    constant MOVE_SPEED_Y(0x4310) // float 144
    constant GRAVITY(0x4040) // float 3
    constant GRAVITY_PEAK(0x4000) // float -2.0
    constant MAX_FALLING(0x4348) // float 200
    constant B_PRESSED(0x40) // bitmask for b press

    // @ Description
    // Subroutine which controls vertical movement during Dedede's Up Special.
    scope apply_vertical_movement2_: {
        // a0 = player object
        addiu sp, sp, -0x20 // allocate stack
        sw ra, 0x001c (sp) // save return address
        sw s0, 0x0018 (sp)
        lw s0, 0x0084 (a0) // load player struct
        sw a0, 0x0020 (sp) // save player object
        or a0, s0, r0 // place player struct in a0
        lw v0, 0x09c8 (s0) // load attribute pointer
        addiu t5, r0, 0x0001

        lw at, 0x0020(sp) // at = player object
        lw t0, 0x0078(at) // load current frame to t0

        lui		at, 0x0					 // at = last animation frame
		beq t0, at, _apply_speed
        lui at, MAX_FALLING // apply fast fall speed

        b _apply_speed
        lui at, GRAVITY_PEAK // apply fast fall speed

        _apply_speed:
        mtc1 at, f6
        lwc1 f4, 0x0058 (v0) // load player gravity
        mul.s f0, f4, f6 // multiply player gravity by aerial boost multiplier
        nop
        mfc1 a1, f0 // move gravity to a1
        jal 0x800d8d68 // determine vertical lift amount, a1=gravity, a2=max falling speed
        lui a2, MAX_FALLING // load max falling speed

        _move:
        or a0, s0, r0 // player struct moved to a0
        jal 0x800d8fa8
        lw a1, 0x09c8 (s0) // loads attribute pointer
        lw ra, 0x001c (sp) // load return address

        _end:
        lw s0, 0x0018 (sp)
        jr ra
        addiu sp, sp, 0x20
    }

    // @ Description
    // Subroutine which controls the collision of the movement stage of Dedede's Up Special.
    scope usp2_collision_: {
        addiu sp, sp, -0x28 // allocate stack space
        sw ra, 0x001c (sp) // save return address to stack
        lw a1, 0x0084 (a0) // load player struct
        sw a0, 0x0028 (sp) // save player object to stack

        jal 0x800de87c // check to see if player has collided with clipping
        sw a1, 0x0024 (sp) // save player struct

        beqz v0, _end // if no collision, skip to end
        lw a1, 0x0024 (sp) // load player struct

        lhu v0, 0x00d2 (a1) // load collision clipping flag
        andi t6, v0, Surface.GROUND // check if colliding with a floor

        beqz t6, _cliff_check // branch not colliding with a wall
        andi t7, v0, 0x3000 // check if colliding with cliff

		_ground:
        jal 0x800dee98
        or a0, a1, r0 // place player struct in a0

        lw a0, 0x0028 (sp) // load player object
        addiu a1, r0, Kazuya.Action.USP_LAND // load action ID
        addiu a2, r0, 0x0000
        lui a3, 0x3f80 // 1.0 placed in a3

        jal 0x800e6f24 // change action routine
        sw r0, 0x0010 (sp)

        b _end_2
        lw ra, 0x001c (sp) // load return address

        _cliff_check:
        beqzl t7, _end // branch if not a cliff
        andi t6, v0, Surface.CEILING // check if colliding with a ceiling
        jal 0x80144c24 // cliff catch routine
        lw a0, 0x0028 (sp) // load player object

        _end:
        lw ra, 0x001c (sp) // load return address
		_end_2:
        jr ra // return
        addiu sp, sp, 0x28 // deallocate stack space
    }

    // @ Description
    // Main subroutine for Cloud's up special.
    // Based on subroutine 0x8015C750, which is the main subroutine of Fox's up special ending.
    // Modified to load Cloud's landing FSM value and disable the interrupt flag.
    scope main_: {
        lwc1 f8, 0x0078(a0) // load current frame

        lui		at, 0x4040					// at = 3.0
		mtc1 at, f6 // ~
        c.eq.s f8, f6 // f8 >= f6 (current frame >= 3) ?
        nop
        bc1tl _change_temp2 // skip if haven't reached frame 3
        nop

        lui		at, 0x4000					// at = 2.0
		mtc1 at, f6 // ~
        c.eq.s f8, f6 // f8 >= f6 (current frame >= 2) ?
        nop
        bc1tl _change_temp2 // skip if haven't reached frame 2
        nop

        _change_temp2:
        ori v1, r0, 0x0002 // ~
        sw v1, 0x0184(a0) // temp variable 3 = 0x2(BEGIN_MOVE)

        _change_temp3:
        ori v1, r0, 0x0003 // ~
        sw v1, 0x0184(a0) // temp variable 3 = 0x2(BEGIN_MOVE)

        _check_input_for_part_2:
        lw t7, 0x0024(a2) // t7 = current action
        lli t2, Kazuya.Action.USP
        bne t7, t2, _main_normal // if not performing USP(1), skip
        nop

        lui		at, 0x41F0					// at = 2.0
		mtc1 at, f6 // ~
        c.lt.s f8, f6 // f8 >= f6 (current frame >= 2) ?
        nop
        bc1fl _main_normal // skip if haven't reached frame 2
        nop

        lui		at, 0x41A0					// at = 2.0
		mtc1 at, f6 // ~
        c.lt.s f6, f8 // f8 >= f6 (current frame >= 2) ?
        nop
        bc1fl _main_normal // skip if haven't reached frame 2
        nop

        lhu t0, 0x01BE(a2) // load button press buffer
        andi t1, t0, 0x4000 // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq t1, r0, _main_normal // skip if (!B_PRESSED)
        nop

        // Change into upB2
        addiu sp, sp,-0x0038 // allocate stack space
        sw ra, 0x0004(sp)
        sw a0, 0x0008(sp)
        sw a1, 0x000C(sp) // store variables
        sw a2, 0x0010(sp) // store variables
        sw a3, 0x0014(sp) // store variables
        sw v0, 0x0018(sp) // store variables
        addiu sp, sp,-0x0030 // allocate stack space

        lw v0, 0x0034(a2) // v0 = player struct

        lli a1, Kazuya.Action.USP // a1 = Action.USP2
        lui a2, 0x3F80 // a2(starting frame) = 0.0
        lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
        sw r0, 0x0010(sp) // argument 4 = 0
        jal 0x800E6F24 // change action
        nop

        addiu sp, sp, 0x0030 // allocate stack space
        lw ra, 0x0004(sp) // restore ra
        lw a0, 0x0008(sp)
        lw a1, 0x000C(sp) // restore a2
        lw a2, 0x0010(sp) // restore a2
        lw a3, 0x0014(sp) // restore a2
        lw v0, 0x0018(sp) // restore a2
        addiu sp, sp, 0x0038 // deallocate stack space
        or a1, a0, r0 // restore a0 = player object

        jr ra
        nop

        j _main_normal
        nop

        _main_normal:

        // On frame 15, set tmp variable 1 to 1
        // This is needed for the collision function
        // so we transition to special landing on grounded transition
        lui		at, 0x4170					// at = 15
		mtc1 at, f6 // ~
        c.eq.s f8, f6 // f8 >= f6 (current frame >= 3) ?
        nop
        bc1fl _change_temp1_continue // skip if haven't reached frame 3
        nop

        lli t0, 0x1
        sw t0, 0x0180(a2)

        _change_temp1_continue:

        // Copy the first 8 lines of subroutine 0x8015C750
        OS.copy_segment(0xD7190, 0x20)
        bc1fl _end // skip if animation end has not been reached
        lw ra, 0x0024(sp) // restore ra
        sw r0, 0x0010(sp) // unknown argument = 0
        sw r0, 0x0018(sp) // interrupt flag = FALSE
        lui t6, LANDING_FSM // t6 = LANDING_FSM
        jal 0x801438F0 // begin special fall
        sw t6, 0x0014(sp) // store LANDING_FSM
        lw ra, 0x0024(sp) // restore ra

        _end:
        addiu sp, sp, 0x0028 // deallocate stack space

        jr ra // return
        nop
    }

    // @ Description
    // Subroutine which allows a direction change for Cloud's up special.
    // Uses the moveset data command 580000XX (orignally identified as "set flag" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // Variable values used by this subroutine:
    // 0x2 = change direction
    scope change_direction_: {
        // 0x180 in player struct = temp variable 2
        lw a1, 0x0084(a0) // a1 = player struct
        addiu sp, sp,-0x0010 // allocate stack space
        sw t0, 0x0004(sp) // ~
        sw t1, 0x0008(sp) // ~
        sw ra, 0x000C(sp) // store t0, t1, ra

        ori t1, r0, 0x0000 // t1 = 0x0
        //sw t1, 0x0180(a1) // t0 = temp variable 2

        lui		at, 0x4040					// at = 3.0
		mtc1 at, f6 // ~
        lwc1 f8, 0x0078(a0) // ~
        c.eq.s f8, f6 // ~
        nop
        bc1tl _set_temp_var // skip if haven't reached frame 3
        nop

        _main:
        lw t0, 0x0180(a1) // t0 = temp variable 2
        ori t1, r0, 0x0002 // t1 = 0x2
        bne t1, t0, _end // skip if temp variable 2 != 2
        nop

        jal 0x80160370 // turn subroutine (copied from captain falcon)
        nop

        lw a1, 0x0010(sp) // load a1
        ori t1, r0, 0x0001 // t1 = 0x1
        sw t1, 0x0180(a1) // temp variable 2 = 1

        j _end
        nop

        _set_temp_var:
        ori t1, r0, 0x0002 // t1 = 0x2
        sw t1, 0x0180(a1) // t0 = temp variable 2

        j _main
        nop

        _end:
        lw t0, 0x0004(sp) // ~
        lw t1, 0x0008(sp) // ~
        lw ra, 0x000C(sp) // load t0, t1, ra
        addiu sp, sp, 0x0010 // deallocate stack space
        jr ra // return
        nop
    }

    // @ Description
    // Subroutine which handles movement for Cloud's up special.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x2 = begin movement
    // 0x3 = movement
    // 0x4 = ending
    scope physics_: {
        // s0 = player struct
        // s1 = attributes pointer
        // 0x184 in player struct = temp variable 3
        addiu sp, sp,-0x0038 // allocate stack space
        sw ra, 0x001C(sp) // ~
        sw s0, 0x0014(sp) // ~
        sw s1, 0x0018(sp) // store ra, s0, s1

        lw s0, 0x0084(a0) // s0 = player struct
        lw t0, 0x014C(s0) // t0 = kinetic state
        bnez t0, _aerial // branch if kinetic state !grounded
        nop

        _grounded:
        jal 0x800DEEC8 // set aerial state
        nop
        
        jal 0x800D93E4 // grounded physics subroutine
        nop
        b _end // end subroutine
        nop

        _aerial:
        // Check if reached min frame where air control is possible
        lw at, 0x4(s0) // at = player object
        lwc1 f8, 0x0078(at) // f8 = current animation frame
        lw t7, 0x0024(s0) // t7 = current action
        lli t2, Kazuya.Action.USP
        bne t7, t2, _end // if not performing USP(1), skip
        nop

        lui		at, 0x41F0					// at = 2.0
		mtc1 at, f6 // ~
        c.lt.s f6, f8 // f8 >= f6 (current frame >= 2) ?
        nop
        bc1fl _root_motion // skip if haven't reached frame 2
        nop

        b _apply_air_physics
        nop

        _root_motion:
        jal 0x800D93E4 // grounded physics subroutine
        nop

        b _end
        nop

        _apply_air_physics:
        lw s0, 0x0014(sp) // restore s0 for this one
        lw t0, 0x0084(a0) // t0 = player struct
        lw t1, 0x0180(t0) // t1 = temp variable 2
        li t8, 0x800D90E0 // t8 = physics subroutine which allows player control

        jalr t8
        nop

        or a1, s1, r0 // a1 = attributes pointer
        or a0, s0, r0 // a0 = player struct

        // jal 0x800D9074 // air friction subroutine?
        // or a1, s1, r0 // a1 = attributes pointer

        b _end // end subroutine
        nop

        _check_begin:
        lw t0, 0x0184(s0) // t0 = temp variable 3
        ori t1, r0, BEGIN // t1 = BEGIN
        bne t0, t1, _check_begin_move // skip if temp variable 3 != BEGIN
        lw t0, 0x0024(s0) // t0 = current action
        lli t1, Kazuya.Action.USP // t1 = Action.USPG
        beq t0, t1, _check_begin_move // skip if current action = USP_GROUND
        nop
        // freeze x movement
        sw r0, 0x0048(s0) // x velocity = 0
        // freeze y position
        sw r0, 0x004C(s0) // y velocity = 0

        _check_begin_move:
        lw t0, 0x0184(s0) // t0 = temp variable 3
        ori t1, r0, BEGIN_MOVE // t1 = BEGIN_MOVE
        bne t0, t1, _end // skip if temp variable 3 != BEGIN_MOVE
        nop
        // initialize x/y velocity
        lw t0, 0x0024(s0) // t0 = current action
        lli t1, Kazuya.Action.USP // t1 = Action.USPG
        beq t0, t1, _apply_velocity // branch if current action = USP_GROUND
        lui t1, GROUND_Y_SPEED // t1 = GROUND_Y_SPEED
        // if current action != USP_GROUND
        lui t1, AIR_Y_SPEED // t1 = AIR_Y_SPEED

        _apply_velocity:
        lui t0, X_SPEED // ~
        mtc1 t0, f2 // f2 = X_SPEED
        lwc1 f0, 0x0044(s0) // ~
        cvt.s.w f0, f0 // f0 = direction
        mul.s f2, f0, f2 // f2 = x velocity * direction
        ori t0, r0, MOVE // t0 = MOVE
        sw t0, 0x0184(s0) // temp variable 3 = MOVE
        // take mid-air jumps away at this point
        lw t0, 0x09C8(s0) // t0 = attribute pointer
        lw t0, 0x0064(t0) // t0 = max jumps
        sb t0, 0x0148(s0) // jumps used = max jumps

        // og
        //swc1 f2, 0x0048(s0) // store x velocity
        //sw t1, 0x004C(s0) // store y velocity

        // try 1
        // lw v1, 0x09C8(a0) // v1 = attribute pointer
        // lw v1, 0x0058(v1) // v1 = gravity
        // sw v1, 0x004C(s0) // y velocity = gravity

        // try 2
        // freeze x movement
        sw r0, 0x0048(s0) // x velocity = 0
        // freeze y position
        sw r0, 0x004C(s0) // y velocity = 0

        _end:
        lw ra, 0x001C(sp) // ~
        lw s0, 0x0014(sp) // ~
        lw s1, 0x0018(sp) // loar ra, s0, s1
        addiu sp, sp, 0x0038 // deallocate stack space
        jr ra // return
        nop
    }

    // @ Description
    // Subroutine which handles Cloud's horizontal control for up special.
    scope air_control_: {
        addiu sp, sp,-0x0028 // allocate stack space
        sw a1, 0x001C(sp) // ~
        sw ra, 0x0014(sp) // ~
        sw t0, 0x0020(sp) // ~
        sw t1, 0x0024(sp) // store a1, ra, t0, t1
        addiu a1, r0, 0x0008 // a1 = 0x8 (original line)
        lw t6, 0x001C(sp) // t6 = attribute pointer
        // load an immediate value into a2 instead of the air acceleration from the attributes
        lui a2, AIR_ACCELERATION // a2 = AIR_ACCELERATION
        lui a3, AIR_SPEED // a3 = AIR_SPEED
        jal 0x800D8FC8 // air drift subroutine?
        nop
        lw ra, 0x0014(sp) // ~
        lw t0, 0x0020(sp) // ~
        lw t1, 0x0024(sp) // load ra, t0, t1
        addiu sp, sp, 0x0028 // deallocate stack space
        jr ra // return
        nop
    }

    // @ Description
    // Collision wubroutine for Cloud's up special.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Cloud.
    scope collision_: {
        OS.save_registers()
        jal check_ledge_grab_ // cliff catch routine
        nop
        OS.restore_registers()
        
        // Copy the first 30 lines of subroutine 0x80156358
        OS.copy_segment(0xD0D98, 0x78)
        // Replace original line which loads the landing fsm
        //lui a2, 0x3E8F // original line 1
        lui a2, LANDING_FSM // a2 = LANDING_FSM
        // Copy the last 17 lines of subroutine 0x80156358
        OS.copy_segment(0xD0E14, 0x44)
    }

    scope check_ledge_grab_: {
        addiu sp, sp,-0x0030 // allocate stack space
        sw ra, 0x0014(sp) // ~
        sw a0, 0x0018(sp) // store ra, a0
        jal 0x800DE87C // check ledge/floor collision?
        nop
        beq v0, r0, _end // skip if !collision
        nop
        lw a0, 0x0018(sp) // a0 = player object
        lw a1, 0x0084(a0) // a1 = player struct
        lhu a2, 0x00D2(a1) // a2 = collision flags?
        andi a2, a2, 0x3000 // bitmask
        beq a2, r0, _end // skip if !ledge_collision
        nop
        jal 0x80144C24 // ledge grab subroutine
        nop
        
        _end:
        lw ra, 0x0014(sp) // load ra
        jr ra // return
        addiu sp, sp, 0x0030 // deallocate stack space
    }
}