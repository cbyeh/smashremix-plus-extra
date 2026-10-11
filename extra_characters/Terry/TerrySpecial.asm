scope TerrySpecial: {
    scope OnActionChanged: {
        OS.routine_begin(0x20)
        lw a0, 0x4(a0) // a0 = player object
        sw a0, 0x18(sp) // save player object
        lw s0, 0x84(a0) // s0 = player struct
        sw s0, 0x1c(sp) // save player struct

        sw r0, 0xAE4(s0) // cancel window frames = 0

        scope _special_cancellable_action_check: {
            // a1 = new action id
            lli t0, Terry.Action.JAB1
            beq a1, t0, _continue
            lli t0, Terry.Action.JAB2
            beq a1, t0, _continue
            lli t0, Terry.Action.DTILT
            beq a1, t0, _continue
            lli t0, Action.UTilt
            beq a1, t0, _continue
            lli t0, Terry.Action.TILTF
            beq a1, t0, _continue
            lli t0, Action.AttackAirN
            beq a1, t0, _continue
            lli t0, Action.AttackAirU
            beq a1, t0, _continue
            lli t0, Action.AttackAirD
            beq a1, t0, _continue
            nop
            b _end
            nop

            _continue:
            li at, SetCancelWindow
            sw at, 0x09F4(s0) // on hit shield function
            sw at, 0x09F8(s0) // on hit function

            lli t0, Action.AttackAirN
            beq a1, t0, _set_interrupt
            lli t0, Action.AttackAirU
            beq a1, t0, _set_interrupt
            lli t0, Action.AttackAirD
            beq a1, t0, _set_interrupt
            lli t0, Action.UTilt
            beq a1, t0, _set_interrupt
            nop
            b _end
            nop

            _set_interrupt:
            // for aerials, we set the interrupt function here
            // to avoid creating 500 new actions
            li at, SpecialCancel.interrupt
            sw at, 0x9DC(s0) // set interrupt function

            // Fix for dair: right after the action change, the game overwrites proc_hit
            // for Link's dair hop functionality
            lli t0, Action.AttackAirD
            bne a1, t0, _end
            nop
            // Editing a saved value in 80150B00
            sw r0, 0xFC(sp)

            _end:
        }

        scope _auto_turnaround_check: {
            lli t0, Terry.Action.JAB1
            beq a1, t0, _continue
            lli t0, Action.UTilt
            beq a1, t0, _continue
            lli t0, Action.USmash
            beq a1, t0, _continue
            lli t0, Terry.Action.SMASHD
            beq a1, t0, _continue
            lli t0, Terry.Action.DTILT
            beq a1, t0, _continue
            nop
            b _end // no actions matched
            nop

            _continue:
            jal SpecialCancel.auto_turnaround
            lw a0, 0x18(sp) // a0 = player object

            _end:
        }

        _end:
        OS.routine_end(0x20)
    }
    // Set on_action_changed function
    Character.table_patch_start(on_action_changed, Character.id.TERRY, 0x4)
    dw OnActionChanged
    OS.patch_end()

    scope SetCancelWindow: {
        OS.routine_begin(0x20)
        sw a0, 0x18(sp) // save player object

        // v0 = collision flags for all active hitboxes
        jal Character.get_hitbox_collision_flags_
        lw a0, 0x84(a0) // a0 = fighter struct

        // GMHitFlags bits: hurtbox, shield, reflect, absorb
        andi v0, v0, 0b11000000 // v0 != 0 if hurtbox or shield collision occured
        beq v0, r0, _end // skip if no collision is detected
        nop

        _set:
        lli at, 20
        sw at, 0xAE4(s0) // cancel window frames

        _end:
        lw a0, 0x18(sp)
        OS.routine_end(0x20)
    }

    scope Jab1: {
        scope interrupt: {
            OS.routine_begin(0x20)
            sw a0, 0x18(sp)

            jal SpecialCancel.SpecialCancelInterrupt // check for special cancel interrupt
            lw a1, 0x84(a0) // a1 = player struct
            bnez v0, _end // if special cancel interrupt returns true, skip
            nop

            jal 0x8014E91C // void ftCommonAttack11ProcInterrupt(GObj *fighter_gobj)
            lw a0, 0x18(sp)

            _end:
            OS.routine_end(0x20)
        }
    }

    scope Jab2: {
        scope interrupt: {
            OS.routine_begin(0x20)
            sw a0, 0x18(sp)

            jal SpecialCancel.SpecialCancelInterrupt // check for special cancel interrupt
            lw a1, 0x84(a0) // a1 = player struct
            bnez v0, _end // if special cancel interrupt returns true, skip
            nop

            jal 0x8014E9B4 // void ftCommonAttack12ProcInterrupt(GObj *fighter_gobj)
            lw a0, 0x18(sp)

            _end:
            OS.routine_end(0x20)
        }
    }

    scope DTilt: {
        scope interrupt: {
            OS.routine_begin(0x20)
            sw a0, 0x18(sp)

            jal SpecialCancel.SpecialCancelInterrupt // check for special cancel interrupt
            lw a1, 0x84(a0) // a1 = player struct
            bnez v0, _end // if special cancel interrupt returns true, skip
            nop

            jal 0x8014FC40 // void ftCommonAttackLw3ProcInterrupt(GObj *fighter_gobj)
            lw a0, 0x18(sp)

            _end:
            OS.routine_end(0x20)
        }
    }

    scope SpecialCancel: {
        constant TURNAROUND_X_RANGE_BACK(0x44C8) // current setting - float: 1600.0

        constant MAX_X_RANGE_FORWARD(0x43C8) // current setting - float: 400.0
        constant MAX_X_RANGE_BACK(0x4370) // current setting - float: 240.0
        constant MAX_Y_RANGE_UP(0x447A) // current setting - float: 1000.0
        constant MAX_Y_RANGE_DOWN(0x4348) // current setting - float: 200.0

        scope interrupt: {
            OS.routine_begin(0x20)
            sw a0, 0x18(sp)

            jal SpecialCancelInterrupt // check for special cancel interrupt
            lw a1, 0x84(a0) // a1 = player struct
            bnez v0, _end // if special cancel interrupt returns true, skip
            nop

            _end:
            OS.routine_end(0x20)
        }

        // @ Description
        // Finds the closest opponent, and separately the closest overall
        // target (an opponent, or - whichever is actually closer - an item
        // with an active hurtbox), for auto_turnaround and any other
        // feature that wants the plain closest target regardless of
        // category. Items can never affect the opponent-only result: it's
        // captured before items are even searched, so auto_turnaround
        // (which only ever turns towards an opponent) is completely
        // unaffected by nearby items.
        // a0 - player object
        // returns
        // v0 - closest overall target - opponent or item (NULL if none found)
        // v1 - closest overall target's X_DIFF (signed distance, positive =
        //      in front of the player's current facing direction)
        // a1 - closest opponent (NULL if no opponent was found)
        // a2 - closest opponent's X_DIFF
        // a3 - number of opponents in the match (excludes self and teammates)
        scope check_for_targets_: {
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

            or s0, a0, r0 // s0 = this player's own player object
            li s1, 0x800466FC // s1 = player object head
            lw s1, 0x0000(s1) // s1 = first player object
            lw s2, 0x0084(s0) // s2 = this player's player struct
            or s3, r0, r0 // s3 = opponent count, tallied by the loop below

            // pass 1: look for the closest valid opponent among all players
            _player_loop:
            beqz s1, _player_loop_exit // exit loop when s1 no longer holds an object pointer
            nop
            beql s1, s0, _player_loop // skip this player's own player object...
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
            lbu t1, 0x000C(s2) // t1 = this player's team
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
            or a0, s2, r0 // a0 = this player's player struct
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
            or a0, s2, r0 // a0 = this player's player struct
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
            // still hold it - the last check_target_ call made above may
            // have rejected its candidate (returning NULL), which would
            // otherwise clobber an earlier, still-valid winner
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
        }

        // @ Description
        // Helper for check_for_targets_ above. Checks whether a single
        // candidate (a player or an item) is within range and, if so,
        // whether it's closer than the current best match.
        // a0 - player struct
        // a1 - target top joint struct
        // a2 - target object struct
        // returns
        // v0 - target object (NULL when no valid target)
        // v1 - target X_DIFF
        scope check_target_: {
            lw t8, 0x0078(a0) // t8 = player x/y/z coordinates
            addiu t9, a1, 0x001C // t9 = target x/y/z coordinates

            // check if the target is within x range
            mtc1 r0, f0 // f0 = 0
            lwc1 f2, 0x0000(t8) // f2 = player x coordinate
            lwc1 f4, 0x0000(t9) // f4 = target x coordinate
            sub.s f10, f4, f2 // f10 = X_DIFF (target x - player x)
            lwc1 f8, 0x0044(a0) // ~
            cvt.s.w f8, f8 // f8 = DIRECTION
            mul.s f10, f10, f8 // f10 = X_DIFF * DIRECTION
            lui at, MAX_X_RANGE_FORWARD // at = MAX_X_RANGE_FORWARD
            mtc1 at, f8 // f8 = MAX_X_RANGE_FORWARD
            c.le.s f10, f8 // ~
            nop // ~
            bc1fl _end // end if MAX_X_RANGE =< X_DIFF
            or v0, r0, r0 // and return 0
            lui at, TURNAROUND_X_RANGE_BACK // at = MAX_X_RANGE_BACK
            mtc1 at, f8 // f8 = MAX_X_RANGE_BACK
            neg.s f8, f8 // f8 = -MAX_X_RANGE_BACK
            c.le.s f8, f10 // ~
            nop // ~
            bc1fl _end // end if X_DIFF =< MAX_X_RANGE_BACK
            or v0, r0, r0 // and return 0

            // check if there is a previous target
            lw t0, 0x0B18(a0) // t0 = current target
            beq t0, r0, _check_y // branch if there is no current target
            lwc1 f8, 0x0B1C(a0) // f8 = current target X_DIFF

            // compare by absolute distance, not signed X_DIFF - otherwise a
            // target behind us (however far) would always beat a target in
            // front of us (however close), since the search cone extends
            // much further behind than in front
            abs.s f14, f10 // f14 = abs(candidate X_DIFF)
            abs.s f8, f8 // f8 = abs(current target X_DIFF)
            c.le.s f14, f8 // ~
            nop // ~
            bc1fl _end // end if the current target is closer or equal
            or v0, r0, r0 // return 0

            _check_y:
            // calculate Y_RANGE based on X_DIFF, creating a cone shaped range
            lwc1 f2, 0x0004(t8) // f2 = player y coordinate
            lwc1 f4, 0x0004(t9) // f4 = target y coordinate
            sub.s f12, f4, f2 // f12 = Y_DIFF (target y - player y)

            lui at, MAX_Y_RANGE_UP // at = MAX_Y_RANGE_UP
            mtc1 at, f8 // f8 = MAX_Y_RANGE_UP
            c.le.s f12, f8 // ~
            nop // ~
            bc1fl _end // end if Y_RANGE =< Y_DIFF
            or v0, r0, r0 // and return 0

            lui at, MAX_Y_RANGE_DOWN // at = MAX_Y_RANGE_DOWN
            mtc1 at, f8 // f8 = MAX_Y_RANGE_DOWN
            neg.s f8, f8 // f8 = -MAX_Y_RANGE_DOWN
            c.le.s f8, f12 // ~
            nop // ~
            bc1fl _end // end if Y_RANGE >= Y_DIFF
            or v0, r0, r0 // return 0

            // if we're here then the target is the closest within range
            or v0, a2, r0 // v0 = target object
            mfc1 v1, f10 // v1 = X_DIFF

            _end:
            jr ra // return
            nop
        }

        scope SpecialCancelInterrupt: {
            // a0 = player object
            // a1 = player struct
            OS.routine_begin(0x30)
            sw a0, 0x18(sp)
            sw a1, 0x1C(sp)
            sw s0, 0x20(sp)
            
            lw at, 0xAE4(a1) // at = cancel window frames
            beqz at, _end // if cancel window frames = 0, skip
            or v0, r0, r0 // v0 = 0 (don't cancel)

            addiu at, at, -1 // at = cancel window frames - 1
            sw at, 0xAE4(a1) // store updated cancel window frames

            lw t0, 0x14C(a1) // t0 = kinetic state
            bnez t0, aerial // aerial state -> aerial cancel
            nop

            grounded:
            jal 0x80151160 // ftCommonSpecialHiCheckInterruptCommon(GObj *fighter_gobj)
            lw a0, 0x18(sp) // a0 = player object
            bnez v0, _end // return early if cancelled
            nop
            jal 0x80151098 // ftCommonSpecialNCheckInterruptCommon(GObj *fighter_gobj)
            lw a0, 0x18(sp) // a0 = player object
            bnez v0, _end // return early if cancelled
            nop
            jal 0x801511E0 // ftCommonSpecialLwCheckInterruptCommon(GObj *fighter_gobj)
            lw a0, 0x18(sp) // a0 = player object
            b _end
            nop

            aerial:
            jal 0x80150F08 // ftCommonSpecialAirCheckInterruptCommon(GObj *fighter_gobj)
            nop

            _end:
            lw a0, 0x18(sp)
            lw a1, 0x1C(sp)
            lw s0, 0x20(sp)
            OS.routine_end(0x30)
        }

        // @ Description
        // Turns the player to face the nearest opponent found by
        // check_for_targets_, if any. Items never factor into this at all -
        // check_for_targets_ hands back the closest opponent separately
        // from its overall (opponent-or-item) result, and this function
        // only ever looks at the opponent-only one. Only actually turns
        // around when there's exactly one opponent in the match.
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
            lw t7, 0x0B1C(t0) // save player struct variables

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
            sw t7, 0x0B1C(t0) // restore player struct variables

            beq t9, r0, _end // branch if no opponent was found
            nop

            // only actually turn around when there's exactly one opponent
            // in the match - the target above is still found/reported (for
            // other features) even when this doesn't apply
            lli t7, 0x0001
            bne a3, t7, _end
            nop

            // apply turnaround
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
    }

    scope USP: {
        // floating point constants for physics and fsm
        constant AIR_Y_SPEED(0x0) // current setting - float32 92
        constant GROUND_Y_SPEED(0x0) // current setting - float32 98
        constant X_SPEED(0x4140) // current setting - float32 12
        constant AIR_ACCELERATION(0x3a83) // current setting - float32 0.0099
        constant AIR_SPEED(0x4120) // current setting - float32 10
        constant LANDING_FSM(0x3F80) // current setting - float32 1.0
        // temp variable 3 constants for movement states
        constant BEGIN(0x1)
        constant BEGIN_MOVE(0x2)
        constant MOVE(0x3)

        // @ Description
        // Subroutine which runs when Terry initiates an aerial up special.
        // Changes action, and sets up initial variable values.
        scope air_initial_: {
            addiu sp, sp, 0xFFE0 // ~
            sw ra, 0x001C(sp) // ~
            sw a0, 0x0020(sp) // original lines 1-3
            sw r0, 0x0010(sp) // argument 4 = 0
            lli a1, Terry.Action.USP_L // a1 = Action.USPA
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
        // Subroutine which runs when Terry initiates a grounded up special.
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
            lli a1, Terry.Action.USP_L // a1 = Action.USPG
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
        // Main subroutine for Terry's up special.
        // Based on subroutine 0x8015C750, which is the main subroutine of Fox's up special ending.
        // Modified to load Terry's landing FSM value and disable the interrupt flag.
        scope main_: {
            lwc1 f8, 0x0078(a0) // load current frame

            j light_to_hard
            nop

            light_to_hard:
            // if not in light usp, skip
            lw t7, 0x0024(a2) // t7 = current action
            lli t2, Terry.Action.USP_L
            bne t7, t2, _main_normal
            nop

            lui		at, 0x40C0					// at = 2.0
            mtc1 at, f6 // ~
            c.eq.s f8, f6 // f8 == f6 (current frame == 6) ?
            nop
            bc1fl _main_normal // skip if haven't reached frame 6
            nop

            lhu t0, 0x01BC(a2) // load button press buffer
            andi t1, t0, 0x4000 // t1 = 0x40 if (B_PRESSED); else t1 = 0
            beq t1, r0, _main_normal // skip if (!B_PRESSED)
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

            lli a1, Terry.Action.USP_H // a1 = Action.USPG
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
            or a1, a0, r0 // restore a0 = player object

            light_to_hard_end:
            jr ra // return
            nop
            
            j _main_normal
            nop

            _main_normal:
            // Set tmp variable 1 to 1
            // This is needed for the collision function
            // so we transition to special landing on grounded transition
            lli t0, 0x1
            sw t0, 0x0180(a2)
            // OS.save_registers()

            // addiu sp, sp, -0x0038 // allocate stack space

            // // unchanged
            // lw a3,0x20(a1)
            // lw a2,0x1c(a1)
            // swc1 f0,0x10(sp)
            // lwc1 f4,0x20(s0)

            // swc1 f4,0x14(sp)
            // lwc1 f6,0x24(s0)
            // sw a1,0x34(sp)
            // swc1 f0,0x1c(sp)

            // // certain
            // li a0,8
            // li a1,2

            // jal 0x800CE8C0
            // swc1 f6,0x18(sp)

            // addiu sp, sp, 0x0038 // deallocate stack space

            // OS.restore_registers()

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
        // Subroutine which allows a direction change for Terry's up special.
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

            lui		at, 0x4080					// at = 4.0
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
        // Subroutine which handles movement for Terry's up special.
        // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
        // This command's purpose appears to be setting a temporary variable in the player struct.
        // The most common use of this variable is to determine when a throw should be applied.
        // Variable values used by this subroutine:
        // 0x2 = begin movement
        // 0x3 = movement
        // 0x4 = ending
        constant MOVEMENT_DEADZONE(10)

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

            lui		at, 0x4218					// at = 2.0
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

            // Here: if frame == 10, check if abs(analog) > range. If it is, set some flag
            // if flag is on, apply this speed here
            lw at, 0x4(s0) // at = player object
            lwc1 f8, 0x0078(at) // f8 = current animation frame

            lui		at, 0x4120					// at = 10.0
            mtc1 at, f6 // ~
            c.lt.s f6, f8 // f8 >= f6 (current frame >= 10) ?
            nop
            bc1tl check_movement // skip if frame != 10
            nop

            lb t0, 0x01C2(s0) // t0 = stick_x
            slti t3, t0, MOVEMENT_DEADZONE // t3 = 0 if stick_x > MOVEMENT_DEADZONE
            beqz t3, _not_neutral // branch if stick_x > MOVEMENT_DEADZONE
            nop

            addiu at, r0, -MOVEMENT_DEADZONE // at = -MOVEMENT_DEADZONE
            blt t0, at, _not_neutral
            nop

            _neutral:
            sw r0, 0x017C(s0) // temp variable 1 = 0
            b check_movement
            nop

            _not_neutral:
            lli t0, 0x1
            sw t0, 0x017C(s0) // temp variable 1 = 1

            check_movement:
            lw at, 0x4(s0) // at = player object
            lwc1 f8, 0x0078(at) // f8 = current animation frame

            lui		at, 0x4120					// at = 10.0
            mtc1 at, f6 // ~
            c.lt.s f6, f8 // f8 >= f6 (current frame >= 10) ?
            nop
            bc1fl _end // skip if haven't reached frame 10
            nop

            lw t0, 0x017C(s0) // t0 = tmp variable 1
            beq t0, r0, _end // skip if tmp variable 1 == 0
            nop

            lui t0, 0x41A0 // 20.0F
            mtc1 t0, f2 // f2 = 20.0F

            lwc1 f0, 0x0044(s0) // ~
            cvt.s.w f0, f0 // f0 = direction

            mul.s f0, f0, f2 // f2 = x velocity * direction
            
            swc1 f0, 0x0048(s0)

            b _end
            nop

            _apply_air_physics:
            // slow x movement
            lwc1 f0, 0x0048(s0) // f0 = current x velocity
            lui t0, 0x3f4c // ~
            mtc1 t0, f2 // f2 = 0.8
            mul.s f0, f0, f2 // f0 = x velocity * 0.8
            swc1 f0, 0x0048(s0) // x velocity = (x velocity * 0.8)

            lw s0, 0x0014(sp) // restore s0 for this one
            lw t0, 0x0084(a0) // t0 = player struct
            lw t1, 0x0180(t0) // t1 = temp variable 2
            li t8, 0x800D90E0 // t8 = physics subroutine which allows player control

            jalr t8
            nop

            // or a1, s1, r0 // a1 = attributes pointer
            // or a0, s0, r0 // a0 = player struct

            // jal 0x800D9074 // air friction subroutine?
            // or a1, s1, r0 // a1 = attributes pointer

            b _end // end subroutine
            nop

            _check_begin:
            lw t0, 0x0184(s0) // t0 = temp variable 3
            ori t1, r0, BEGIN // t1 = BEGIN
            bne t0, t1, _check_begin_move // skip if temp variable 3 != BEGIN
            lw t0, 0x0024(s0) // t0 = current action
            lli t1, Terry.Action.USP_L // t1 = Action.USPG
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
            lli t1, Terry.Action.USP_L // t1 = Action.USPG
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
        // Subroutine which handles Terry's horizontal control for up special.
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
        // Collision wubroutine for Terry's up special.
        // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
        // Loads the appropriate landing fsm value for Terry.
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

    // @ Description
    // Refreshes Specials flag when hit
    scope TerrySpecialsRefresh: {
        sw r0, 0x0ADC(a0) // set nsp special bool to FALSE
        jr ra
        nop
    }

    Character.table_patch_start(on_hit, Character.id.TERRY, 0x4)
    dw TerrySpecialsRefresh;
    OS.patch_end()

    scope BK: {
        scope air_initial_: {
            addiu sp, sp, -0x0020 // ~
            sw ra, 0x001C(sp) // ~
            sw a0, 0x0020(sp) // original lines 1-3

            lw t0, 0x84(a0) // t0 = player struct
            lbu t1, 0x0ADC(t0) // t1 = temp flag, used as NSP ammo
            bnez t1, _abort // skip if temp flag != 0
            lli t1, OS.TRUE // ~
            sb t1, 0x0ADC(t0) // temp flag = TRUE

            direction_check:
            // Before triggering NSP, the game checks analog stick_x
            // and updates the character's direction (in the struct).
            // However, the model isn't updated at the same time.
            // Here, we check if the model rotation matches the struct direction.
            // If they don't, we invert the direction in the struct.
            lw t7, 0x0044(a1) // t7 = DIRECTION

            mtc1 t7, f6 // ~
            cvt.s.w f6, f6 // f6 = direction
            lui at, 0x8013 // ~
            lwc1 f8, 0xFE90(at) // at = rotation constant
            mul.s f8, f8, f6 // f8 = rotation constant * direction
            lw t7, 0x08E8(a1) // t6 = character control joint struct

            lwc1 f6, 0x0034(t7) // update character rotation to match direction

            c.eq.s f8, f6 // f8 == f6 (rotation matches direction?)
            nop
            bc1tl after_back_b_test // skip if they match
            nop

            back_b:
            // If pressing back for more than X frames, do crackshoot backwards
            // If not, do it facing forwards (we have to un-invert the direction)
            lbu t1, 0x26A(t0) // t1 = stick X hold buffer
            slti t1, t1, 7
            beqz t1, back_b_action_change
            nop

            un_invert_direction:
            lw t7, 0x0044(a1) // t7 = DIRECTION
            subu t7, r0, t7 // ~
            sw t7, 0x0044(a1) // reverse and update DIRECTION
            
            back_b_action_change:
            sw r0, 0x0010(sp) // argument 4 = 0
            lli a1, Terry.Action.CSHOOT_AIRSTART // a1 = Action.NSPAir
            or a2, r0, r0 // a2 = float: 0.0
            jal 0x800E6F24 // change action
            lui a3, 0x3F80 // a3 = float: 1.0
            jal 0x800E0830 // unknown common subroutine
            lw a0, 0x0020(sp) // a0 = player object
            b _end
            nop

            after_back_b_test:
            sw r0, 0x0010(sp) // argument 4 = 0
            lli a1, 0xE5 // a1 = Action.NSPAir
            or a2, r0, r0 // a2 = float: 0.0
            jal 0x800E6F24 // change action
            lui a3, 0x3F80 // a3 = float: 1.0
            jal 0x800E0830 // unknown common subroutine
            lw a0, 0x0020(sp) // a0 = player object
            b _end
            nop

            _abort:
            // Before triggering NSP, the game checks analog stick_x
            // and updates the character's direction (in the struct).
            // However, the model isn't updated at the same time.
            // Here, we check if the model rotation matches the struct direction.
            // If they don't, we invert the direction in the struct.
            lw t7, 0x0044(a1) // t7 = DIRECTION

            mtc1 t7, f6 // ~
            cvt.s.w f6, f6 // f6 = direction
            lui at, 0x8013 // ~
            lwc1 f8, 0xFE90(at) // at = rotation constant
            mul.s f8, f8, f6 // f8 = rotation constant * direction
            lw t7, 0x08E8(a1) // t6 = character control joint struct

            lwc1 f6, 0x0034(t7) // update character rotation to match direction

            c.eq.s f8, f6 // f8 == f6 (rotation matches direction?)
            nop
            bc1tl _end // skip if they match
            nop
            
            // Reverse direction in struct
            lw t7, 0x0044(a1) // t7 = DIRECTION
            subu t7, r0, t7 // ~
            sw t7, 0x0044(a1) // reverse and update DIRECTION

            _end:
            lw a0, 0x0020(sp) // a0 = player object
            lw ra, 0x001C(sp) // ~
            addiu sp, sp, 0x0020 // ~
            jr ra // original return logic
            nop
        }

        scope ground_initial_: {
            addiu sp, sp, -0x0020 // ~
            sw ra, 0x001C(sp) // ~
            sw a0, 0x0020(sp) // original lines 1-3

            direction_check:
            // Before triggering NSP, the game checks analog stick_x
            // and updates the character's direction (in the struct).
            // However, the model isn't updated at the same time.
            // Here, we check if the model rotation matches the struct direction.
            // If they don't, we invert the direction in the struct.
            lw t7, 0x0044(a1) // t7 = DIRECTION
            
            mtc1 t7, f6 // ~
            cvt.s.w f6, f6 // f6 = direction
            lui at, 0x8013 // ~
            lwc1 f8, 0xFE90(at) // at = rotation constant
            mul.s f8, f8, f6 // f8 = rotation constant * direction
            lw t7, 0x08E8(a1) // t6 = character control joint struct

            lwc1 f6, 0x0034(t7) // update character rotation to match direction

            c.eq.s f8, f6 // f8 == f6 (rotation matches direction?)
            nop
            bc1tl after_back_b_test // skip if they match
            nop

            back_b:
            lw t7, 0x0044(a1) // t7 = DIRECTION
            subu t7, r0, t7 // ~
            sw t7, 0x0044(a1) // reverse and update DIRECTION

            sw r0, 0x0010(sp) // argument 4 = 0
            lli a1, Terry.Action.CSHOOT_START // a1 = Action.NSPAir
            or a2, r0, r0 // a2 = float: 0.0
            jal 0x800E6F24 // change action
            lui a3, 0x3F80 // a3 = float: 1.0
            jal 0x800E0830 // unknown common subroutine
            lw a0, 0x0020(sp) // a0 = player object
            b _end
            nop

            after_back_b_test:
            sw r0, 0x0010(sp) // argument 4 = 0
            lli a1, 0xE4 // a1 = Action.NSPGround
            or a2, r0, r0 // a2 = float: 0.0
            jal 0x800E6F24 // change action
            lui a3, 0x3F80 // a3 = float: 1.0
            jal 0x800E0830 // unknown common subroutine
            lw a0, 0x0020(sp) // a0 = player object
            b _end
            nop

            _end:
            lw a0, 0x0020(sp) // a0 = player object
            lw ra, 0x001C(sp) // ~
            addiu sp, sp, 0x0020 // ~
            jr ra // original return logic
            nop
        }

        scope begin_main_: {
            constant B_PRESSED(0x4000) // bitmask for b press

            OS.routine_begin(0x20)
            sw s0, 0x0000(sp)
            lw s0, 0x0084(a0) // s0 = player struct
            lw t8, 0x014C(a2) // t8 = kinetic state

            lwc1 f0, 0x0078(a0) // f0 = current animation frame
            lui t0, 0x40C0 // t0 = 6.0F
            mtc1 t0, f2 // f2 = ~

            c.eq.s f0, f2
            nop
            bc1fl _continue // frame is not 6.0
            nop

            // frame = 6.0
            _set_weak_strong_flag:
            sw r0, 0x017C(a2) // temp variable 1 = 0
            lhu t0, 0x01BC(a2) // load button press buffer
            lhu t1, 0x01BE(a2) // load button hold buffer
            or t0, t0, t1 // join both so we cover press or hold
            andi t1, t0, B_PRESSED // t1 = 0x40 if (B_PRESSED); else t1 = 0
            beq t1, r0, _fsm_modify_logic // skip if (!B_PRESSED)
            nop

            lli t0, 0x1
            sw t0, 0x017C(a2) // temp variable 1 = 1 (strong)
            
            _fsm_modify_logic:
            lw t3, 0x017C(a2) // t3 = tmp variable 1 = 0 if weak, 1 if strong

            bnez t8, _aerial
            nop
            _grounded:
            lui t0, 0x3F99 // t0 = 1.19F grounded, weak
            beqz t3, _set_fsm
            nop
            lui t0, 0x3F34 // t0 = 0.70F grounded, strong
            b _set_fsm
            nop
            _aerial:
            lui t0, 0x3FC0 // t0 = 1.5F aerial, weak
            beqz t3, _set_fsm
            nop
            lui t0, 0x3F6B // t0 = 0.91F aerial, strong
            _set_fsm:
            lw t5, 0x0074(a0) // bone 1
            sw t0, 0x0078(t5) // set fsm
            jal 0x8000BB04 // fsm subroutine
            or a1, r0, t0

            _continue:
            lw t8, 0x014C(a2) // t8 = kinetic state
            li a1, goto_attack // a1(transition subroutine) = goto_attack
            jal 0x800D9480 // common main subroutine (transition on animation end)
            nop

            _end:
            lw s0, 0x0000(sp)
            OS.routine_end(0x20)
        }

        scope begin_physics_: {
            OS.routine_begin(0x20)
            sw s0, 0x0000(sp)

            lw s0, 0x0084(a0) // s0 = player struct
            sw r0, 0x0048(s0) // x velocity = 0
            sw r0, 0x004C(s0) // y velocity = 0

            lw t6, 0x014C(s0) // t6 = kinetic state (0 = grounded, 1 = aerial)
            bnez t6, _aerial
            nop

            _ground:
            jal 0x800D8BB4
            nop
            b _end
            nop

            _aerial:
            jal 0x800D91EC
            nop

            _end:
            lw s0, 0x0000(sp)
            OS.routine_end(0x20)
        }

        // How to get these:
        // - Edit Falcon Punch effect in vanilla
        // - Open game in emulator, add breakpoint in 0x80101F84 = dEFFalconPunchEffectDesc
        // - Right at the start of the function, it loads the address to A0. It has the whole struct
        punch_anim_struct_TERRY:
        dw 0x020F0000
        dw Character.TERRY_file_8_ptr
        dw 0x501C0000
        OS.copy_segment(0xA9AF8, 0x0008)
        dw update_routine_
        dw 0x00000040 // customized because this animation was added to an existing file, these are offsets
        dw 0x000001A0 // customized because this animation was added to an existing file, these are offsets
        dw 0x00000000 // beginning of graphic within file, normally 0, but unique since added to another file
        dw 0x000001EC // customized because this animation was added to an existing file, these are offsets

        scope update_routine_: {
            addiu sp, sp,-0x0010 // allocate stack space
            sw ra, 0x0004(sp) // save registers

            lw t3, 0x0074(a0) // t3 = gfx position struct top joint

            li t8, Size.multiplier_table
            lw t7, 0x0084(a0) // t7 = projectile special struct
            lw t7, 0x0004(t7) // t7 = player object
            lw t7, 0x0084(t7) // t7 = player special struct
            lbu t7, 0x000D(t7) // t7 = port
            sll t7, t7, 0x0002 // t7 = port * 4 = offset to multiplier
            addu t8, t8, t7 // t8 = size multiplier address
            lwc1 f6, 0x0000(t8) // f6 = size multiplier

            // wa
            lui at,0x3F40 // 0.5
            mtc1 at,f6

            swc1 f6, 0x0040(t3) // update x scale
            swc1 f6, 0x0044(t3) // update y scale
            swc1 f6, 0x0048(t3) // update z scale

            jal 0x800CB4B0 // call original render routine
            nop

            lw ra, 0x0004(sp) // restore registers
            jr ra
            addiu sp, sp, 0x0010 // deallocate stack space
        }

        scope goto_attack: {
            addiu sp, sp,-0x0040 // allocate stack space
            sw ra, 0x001C(sp) // ~
            sw a0, 0x0020(sp) // ~
            sw s0, 0x0024(sp) // store a0, s0, ra
            lw s0, 0x0084(a0) // s0 = player struct

            lw t3, 0x017C(s0) // t3 = tmp variable 1 = 0 if weak, 1 if strong
            bnez t3, _strong
            nop
            lli a1, Terry.Action.BK_ATTACK_W // a1(action id) = BK_ATTACK_W
            b _continue
            nop
            _strong:
            lli a1, Terry.Action.BK_ATTACK_S // a1(action id) = BK_ATTACK_S

            _continue:
            lw a0, 0x0020(sp) // a0 = player object
            or a2, r0, r0 // a2(starting frame) = 0
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            addiu at, r0, 0x0001
            jal 0x800E6F24 // change action
            sw at, 0x0010(sp) // argument 4 = 1
            jal 0x800E0830 // unknown common subroutine
            lw a0, 0x0020(sp) // a0 = player object

            add_fgx: {
                lw t0, 0x0008(s0) // t0 = character id
                
                OS.save_registers()

                // 80101F90
                OS.copy_segment(0x7D784, 0x0C)
                li a0, punch_anim_struct_TERRY
                // li a0, 0x8012E2C4 // original line 1/3 (load falcon kick animation struct)
                jal 0x800FDB1C
                nop
                OS.copy_segment(0x7D784+0x18, 0x28)
                lw v1,0x90C(a0) // put graphic in hand instead
                OS.copy_segment(0x7D7E4, 0x2C)

                // set fp->is_attach_effect = TRUE; (used for eventually deleting the effect on state change)
                // a0 here is the player struct
                lbu t7,0x18f(a0)
                ori t8,t7,0x10
                sb t8,0x18f(a0)

                // Set effect to pause during hitlag
                // fp->proc_lagstart = ftCommon_ProcPauseGFX;
                li t8, 0x800E9C8C
                sw t8,0xa04(a0)
                //fp->proc_lagend = ftCommon_ProcResumeGFX;
                li t8, 0x800E9CC4
                sw t8,0xa08(a0)

                or a0, v0, r0 // a0 = gfx object

                OS.restore_registers()
            }

            _end:
            lw ra, 0x001C(sp) // ~
            lw s0, 0x0024(sp) // load s0
            jr ra // return
            addiu sp, sp, 0x0040 // deallocate stack space
        }

        scope attack_main_: {
            OS.routine_begin(0x20)

            lwc1 f0, 0x0078(a0) // f0 = current animation frame
            lui t0, 0x40C0 // t0 = 6.0F
            mtc1 t0, f2 // f2 = ~

            c.eq.s f0, f2
            nop
            bc1fl _continue // frame is not 6.0
            nop

            lw t8, 0x014C(a2) // t8 = kinetic state

            _fsm_modify_logic:
            lw t3, 0x017C(a2) // t3 = tmp variable 1 = 0 if weak, 1 if strong

            bnez t8, _aerial
            nop
            _grounded:
            lui t0, 0x3FB3 // t0 = 1.4F grounded, weak
            beqz t3, _set_fsm
            nop
            lui t0, 0x3F80 // t0 = 1.0F grounded, strong
            b _set_fsm
            nop
            _aerial:
            lui t0, 0x3FD9 // t0 = 1.7F aerial, weak
            beqz t3, _set_fsm
            nop
            lui t0, 0x3FD9 // t0 = 1.7F aerial, strong
            _set_fsm:
            lw t5, 0x0074(a0) // bone 1
            sw t0, 0x0078(t5) // set fsm
            jal 0x8000BB04 // fsm subroutine
            or a1, r0, t0

            _continue:
            lw t8, 0x014C(a2) // t8 = kinetic state
            li a1, goto_end // a1(transition subroutine) = goto_end
            jal 0x800D9480 // common main subroutine (transition on animation end)
            nop

            OS.routine_end(0x20)
        }

        scope goto_end: {
            addiu sp, sp,-0x0040 // allocate stack space
            sw ra, 0x001C(sp) // ~
            sw a0, 0x0020(sp) // ~
            sw s0, 0x0024(sp) // store a0, s0, ra

            lw s0, 0x0084(a0) // s0 = player struct
            lw t6, 0x014C(s0) // t6 = kinetic state (0 = grounded, 1 = aerial)
            lw t3, 0x017C(s0) // t3 = tmp variable 1 = 0 if weak, 1 if strong

            bnez t6, _aerial

            _grounded:
            lli a1, Terry.Action.BK_GND_END // a1(action id)
            lui a3, 0x3F9A // a3(frame speed multiplier) (grounded, weak) = 1.2x
            beqz t3, _continue
            nop
            lui a3, 0x3F80 // a3(frame speed multiplier) (grounded, strong) = 1.0x
            b _continue
            nop

            _aerial:
            nop
            lli a1, Terry.Action.BK_AIR_END // a1(action id)
            lui a3, 0x3F80 // a3(frame speed multiplier) (aerial, weak) = 1.0x
            beqz t3, _continue
            nop
            lui a3, 0x3F4F // a3(frame speed multiplier) (aerial, strong) = 0.8x
            b _continue
            nop

            _continue:
            lw a0, 0x0020(sp) // a0 = player object
            or a2, r0, r0 // a2(starting frame) = 0
            jal 0x800E6F24 // change action
            sw r0, 0x0010(sp) // argument 4 = 0
            jal 0x800E0830 // unknown common subroutine
            lw a0, 0x0020(sp) // a0 = player object

            _end:
            lw ra, 0x001C(sp) // ~
            lw s0, 0x0024(sp) // load s0
            jr ra // return
            addiu sp, sp, 0x0040 // deallocate stack space
        }

        scope attack_physics_: {
            constant W_GND_SPEED(0x4270) // current setting - float32 60
            constant S_GND_SPEED(0x42BE) // current setting - float32 95
            constant W_AIR_SPEED(0x4248) // current setting - float32 50
            constant S_AIR_SPEED(0x4270) // current setting - float32 60

            OS.routine_begin(0x20)
            sw s0, 0x0000(sp)

            lw s0, 0x0084(a0) // s0 = player struct
            lw t8, 0x014C(s0) // t8 = kinetic state
            lw t3, 0x017C(s0) // t3 = tmp variable 1 = 0 if weak, 1 if strong

            lwc1 f0, 0x0078(a0) // f0 = current animation frame
            lui t0, 0x3F80 // t0 = 1.0F
            mtc1 t0, f2 // f2 = ~

            c.eq.s f0, f2
            nop
            bc1fl _set_y_speed // frame is not 1.0
            nop

            bnez t8, _aerial
            nop
            _grounded:
            lui at, W_GND_SPEED // at = 1.19F grounded, weak
            beqz t3, _set_x_speed
            nop
            lui at, S_GND_SPEED // at = 0.70F grounded, strong
            b _set_x_speed
            nop
            _aerial:
            lui at, W_AIR_SPEED // at = 1.5F aerial, weak
            beqz t3, _set_x_speed
            nop
            lui at, S_AIR_SPEED // at = 0.91F aerial, strong
            _set_x_speed:
            mtc1 at, f2 // f2 = X_SPEED
            lwc1 f4, 0x0044(s0) // ~
            cvt.s.w f4, f4 // f4 = DIRECTION
            swc1 f2, 0x0060(s0) // x velocity = X_SPEED
            mul.s f2, f2, f4 // f2 = X_SPEED * DIRECTION
            swc1 f2, 0x0048(s0) // x velocity = X_SPEED * DIRECTION
            
            _set_y_speed:
            // for Y speed, set it as fall speed to negate gravity
            lw t1, 0x09C8(s0) // t1 = attribute pointer
            lw t1, 0x0058(t1) // t1 = fall speed acceleration
            sw t1, 0x004C(s0) // overwrite y velocity with fall speed acceleration value

            lw t6, 0x014C(s0) // t6 = kinetic state (0 = grounded, 1 = aerial)
            bnez t6, _air_routine
            nop

            _ground_routine:
            // jal 0x800D8BB4 // no ground friction
            nop
            b _end
            nop

            _air_routine:
            jal 0x800D91EC
            nop

            _end:
            lw s0, 0x0000(sp)
            OS.routine_end(0x20)
        }

        scope attack_collision_: {
            OS.routine_begin(0x20)
            sw s0, 0x0000(sp)

            lw s0, 0x0084(a0) // s0 = player struct
            lw t6, 0x014C(s0) // t6 = kinetic state (0 = grounded, 1 = aerial)
            bnez t6, _aerial
            nop

            _grounded:
            jal 0x800DDF44 // grounded subroutine
            nop
            b _end
            nop

            _aerial:
            li a1, attack_air_to_ground_ // a1(transition subroutine) = air_to_ground_
            jal 0x800DE6E4 // common air collision subroutine (transition on landing, no ledge grab)
            nop 

            _end:
            lw s0, 0x0000(sp)
            OS.routine_end(0x20)
        }

        scope attack_air_to_ground_: {
            jr ra // return
            nop
        }

        scope end_air_collision_: {
            addiu sp, sp,-0x0018 // allocate stack space
            sw ra, 0x0014(sp) // store ra
            li a1, end_air_to_ground_ // a1(transition subroutine) = air_to_ground_
            jal 0x800DE6E4 // common air collision subroutine (transition on landing, no ledge grab)
            nop
            lw ra, 0x0014(sp) // load ra
            addiu sp, sp, 0x0018 // deallocate stack space
            jr ra // return
            nop
        }

        // @ Description
        // Subroutine which handles ground to air transition for down special actions
        scope end_air_to_ground_: {
            addiu sp, sp,-0x0038 // allocate stack space
            sw ra, 0x001C(sp) // store ra
            sw a0, 0x0038(sp) // 0x0038(sp) = player object
            lw a0, 0x0084(a0) // a0 = player struct
            jal 0x800DEE98 // set grounded state
            sw a0, 0x0034(sp) // 0x0034(sp) = player struct
            lw v0, 0x0034(sp) // v0 = player struct
            lw a0, 0x0038(sp) // a0 = player object

            addiu a1, r0, Terry.Action.BK_GND_END // a1 = DSP landing routine
            _change_action:
            lw a2, 0x0078(a0) // a2(starting frame) = current animation frame
            lui a3, 0x3F9A // a3(frame speed multiplier) = 1.2
            jal 0x800E6F24 // change action
            nop
            lw ra, 0x001C(sp) // load ra
            addiu sp, sp, 0x0038 // deallocate stack space
            jr ra // return
            nop
        }
    }

    scope PD: {
        scope ground_initial_: {
            addiu sp, sp, -0x0020 // ~
            sw ra, 0x001C(sp) // ~
            sw a0, 0x0020(sp) // original lines 1-3

            lw a0, 0x0084(a0) // a0 = player struct
            
            // check if we came from a smash input
            // in this case, we might wanna do a Power Dunk
            // else, do Power Wave

            lli a1, 0xE6 // a1 = action = grounded dsp

            // check stick buffer
            lbu t0, 0x26B(a0) // t0 = vertical stick hold buffer
            slti t0, t0, 8
            bnez t0, change_action
            nop

            not_dsmash_b:
            sw r0, 0x0048(a0) // set zero x speed
            lli a1, Terry.Action.PWAVE_W // a1 = action
            sw r0, 0x017C(a0) // reset variable used for generating the projectile

            change_action:
            lw a0, 0x0020(sp) // a0 = player object
            sw r0, 0x0010(sp) // argument 4 = 0
            or a2, r0, r0 // a2 = float: 0.0
            jal 0x800E6F24 // change action
            lui a3, 0x3F80 // a3 = float: 1.0
            jal 0x800E0830 // unknown common subroutine
            lw a0, 0x0020(sp) // a0 = player object
            b _end
            nop

            _end:
            lw a0, 0x0020(sp) // a0 = player object
            lw ra, 0x001C(sp) // ~
            addiu sp, sp, 0x0020 // ~
            jr ra // original return logic
            nop
        }

        scope begin_main_: {
            constant B_PRESSED(0x4000) // bitmask for b press

            OS.routine_begin(0x20)
            sw s0, 0x0000(sp)
            lw s0, 0x0084(a0) // s0 = player struct
            lw t8, 0x014C(a2) // t8 = kinetic state

            sw a0, 0x0004(sp)
            // jal 0x800DEEC8 // set aerial state
            or a0, s0, r0
            lw a0, 0x0004(sp)

            lwc1 f0, 0x0078(a0) // f0 = current animation frame
            lui t0, 0x40A0 // t0 = 5.0F
            mtc1 t0, f2 // f2 = ~

            c.eq.s f0, f2
            nop
            bc1fl _continue // frame is not 5.0
            nop

            // frame = 5.0
            _set_weak_strong_flag:
            sw r0, 0x017C(a2) // temp variable 1 = 0
            lhu t0, 0x01BC(a2) // load button press buffer
            lhu t1, 0x01BE(a2) // load button hold buffer
            or t0, t0, t1 // join both so we cover press or hold
            andi t1, t0, B_PRESSED // t1 = 0x40 if (B_PRESSED); else t1 = 0
            beq t1, r0, _continue // skip if (!B_PRESSED)
            nop

            lli t0, 0x1
            sw t0, 0x017C(a2) // temp variable 1 = 1 (strong)

            _continue:
            lw t8, 0x014C(a2) // t8 = kinetic state
            li a1, goto_rise // a1(transition subroutine) = goto_rise
            jal 0x800D9480 // common main subroutine (transition on animation end)
            nop

            _end:
            lw s0, 0x0000(sp)
            OS.routine_end(0x20)
        }

        scope goto_rise: {
            addiu sp, sp,-0x0040 // allocate stack space
            sw ra, 0x001C(sp) // ~
            sw a0, 0x0020(sp) // ~
            sw s0, 0x0024(sp) // store a0, s0, ra
            lw s0, 0x0084(a0) // s0 = player struct

            lw t8, 0x014C(s0) // t8 = kinetic state (0 = grounded, 1 = aerial)
            bnez t8, after_set_aerial
            nop

            set_aerial:
            jal 0x800DEEC8 // set aerial state
            or a0, s0, r0 // a0 = player struct

            after_set_aerial:
            lw t3, 0x017C(s0) // t3 = tmp variable 1 = 0 if weak, 1 if strong
            bnez t3, _strong
            nop
            lli a1, Terry.Action.PD_RISE_W // a1(action id) = BK_ATTACK_W
            b _continue
            nop
            _strong:
            lli a1, Terry.Action.PD_RISE_S // a1(action id) = BK_ATTACK_S

            _continue:
            lw a0, 0x0020(sp) // a0 = player object
            or a2, r0, r0 // a2(starting frame) = 0
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            addiu at, r0, 0x0001
            jal 0x800E6F24 // change action
            sw at, 0x0010(sp) // argument 4 = 1
            jal 0x800E0830 // unknown common subroutine
            lw a0, 0x0020(sp) // a0 = player object

            _end:
            lw ra, 0x001C(sp) // ~
            lw s0, 0x0024(sp) // load s0
            jr ra // return
            addiu sp, sp, 0x0040 // deallocate stack space
        }

        scope rise_collision_: {
            OS.routine_begin(0x20)
            sw s0, 0x0000(sp)

            lw s0, 0x0084(a0) // s0 = player struct
            lw t6, 0x014C(s0) // t6 = kinetic state (0 = grounded, 1 = aerial)
            bnez t6, _aerial
            nop

            _grounded:
            jal 0x800DDF44 // grounded subroutine
            nop
            b _end
            nop

            _aerial:
            li a1, rise_air_to_ground_ // a1(transition subroutine) = air_to_ground_
            jal 0x800DE6E4 // common air collision subroutine (transition on landing, no ledge grab)
            nop 

            _end:
            lw s0, 0x0000(sp)
            OS.routine_end(0x20)
        }

        scope rise_air_to_ground_: {
            jr ra // return
            nop
        }

        scope rise_main_: {
            OS.routine_begin(0x20)

            lw t8, 0x014C(a2) // t8 = kinetic state
            li a1, goto_fall // a1(transition subroutine)
            jal 0x800D9480 // common main subroutine (transition on animation end)
            nop

            OS.routine_end(0x20)
        }

        // How to get these:
        // - Edit Falcon Punch effect in vanilla
        // - Open game in emulator, add breakpoint in 0x80101F84 = dEFFalconPunchEffectDesc
        // - Right at the start of the function, it loads the address to A0. It has the whole struct
        dunk_anim_struct_TERRY:
        dw 0x020F0000
        dw Character.TERRY_file_9_ptr
        dw 0x501C0000
        OS.copy_segment(0xA9AF8, 0x0008)
        dw update_routine_
        dw 0x00000040 // customized because this animation was added to an existing file, these are offsets
        dw 0x000001E8 // customized because this animation was added to an existing file, these are offsets
        dw 0x00000000 // beginning of graphic within file, normally 0, but unique since added to another file
        dw 0x0000022C // customized because this animation was added to an existing file, these are offsets

        scope update_routine_: {
            addiu sp, sp,-0x0010 // allocate stack space
            sw ra, 0x0004(sp) // save registers

            lw t3, 0x0074(a0) // t3 = gfx position struct top joint

            li t8, Size.multiplier_table
            lw t7, 0x0084(a0) // t7 = projectile special struct
            lw t7, 0x0004(t7) // t7 = player object
            lw t7, 0x0084(t7) // t7 = player special struct
            lbu t7, 0x000D(t7) // t7 = port
            sll t7, t7, 0x0002 // t7 = port * 4 = offset to multiplier
            addu t8, t8, t7 // t8 = size multiplier address
            lwc1 f6, 0x0000(t8) // f6 = size multiplier

            // wa
            lui at,0x3F80 // 0.5
            mtc1 at,f6

            swc1 f6, 0x0040(t3) // update x scale
            swc1 f6, 0x0044(t3) // update y scale
            swc1 f6, 0x0048(t3) // update z scale

            jal 0x800CB4B0 // call original render routine
            nop

            lw ra, 0x0004(sp) // restore registers
            jr ra
            addiu sp, sp, 0x0010 // deallocate stack space
        }

        scope goto_fall: {
            addiu sp, sp,-0x0040 // allocate stack space
            sw ra, 0x001C(sp) // ~
            sw a0, 0x0020(sp) // ~
            sw s0, 0x0024(sp) // store a0, s0, ra

            lw s0, 0x0084(a0) // s0 = player struct
            lw t3, 0x017C(s0) // t3 = tmp variable 1 = 0 if weak, 1 if strong
            bnez t3, _strong
            nop

            lli a1, Terry.Action.PD_FALL_W // a1(action id) = BK_ATTACK_W
            lui a3, 0x3FE0 // a3(frame speed multiplier) = 1.75
            b _continue
            nop

            _strong:
            lli a1, Terry.Action.PD_FALL_S // a1(action id) = BK_ATTACK_S
            lui a3, 0x3FA0 // a3(frame speed multiplier) = 1.25

            _continue:
            lw a0, 0x0020(sp) // a0 = player object
            or a2, r0, r0 // a2(starting frame) = 0
            jal 0x800E6F24 // change action
            sw r0, 0x0010(sp) // argument 4 = 0
            jal 0x800E0830 // unknown common subroutine
            lw a0, 0x0020(sp) // a0 = player object

            add_fgx: {
                lw t0, 0x0008(s0) // t0 = character id
                
                OS.save_registers()

                // 80101F90
                OS.copy_segment(0x7D784, 0x0C)
                li a0, dunk_anim_struct_TERRY
                // li a0, 0x8012E2C4 // original line 1/3 (load falcon kick animation struct)
                jal 0x800FDB1C
                nop
                OS.copy_segment(0x7D784+0x18, 0x28)
                lw v1,0x92C(a0) // put graphic in hand instead
                OS.copy_segment(0x7D7E4, 0x2C)

                // set fp->is_attach_effect = TRUE; (used for eventually deleting the effect on state change)
                // a0 here is the player struct
                lbu t7,0x18f(a0)
                ori t8,t7,0x10
                sb t8,0x18f(a0)

                // Set effect to pause during hitlag
                // fp->proc_lagstart = ftCommon_ProcPauseGFX;
                li t8, 0x800E9C8C
                sw t8,0xa04(a0)
                //fp->proc_lagend = ftCommon_ProcResumeGFX;
                li t8, 0x800E9CC4
                sw t8,0xa08(a0)

                or a0, v0, r0 // a0 = gfx object

                OS.restore_registers()
            }

            _end:
            lw ra, 0x001C(sp) // ~
            lw s0, 0x0024(sp) // load s0
            jr ra // return
            addiu sp, sp, 0x0040 // deallocate stack space
        }

        scope fall_collision_: {
            OS.routine_begin(0x20)
            sw s0, 0x0000(sp)

            lw s0, 0x0084(a0) // s0 = player struct
            lw t6, 0x014C(s0) // t6 = kinetic state (0 = grounded, 1 = aerial)
            bnez t6, _aerial
            nop

            _grounded:
            jal 0x800DDF44 // grounded subroutine
            nop
            b _end
            nop

            _aerial:
            li a1, fall_air_to_ground_ // a1(transition subroutine) = air_to_ground_
            jal 0x800DE6E4 // common air collision subroutine (transition on landing, no ledge grab)
            nop 

            _end:
            lw s0, 0x0000(sp)
            OS.routine_end(0x20)
        }

        scope fall_air_to_ground_: {
            addiu sp, sp,-0x0038 // allocate stack space
            sw ra, 0x001C(sp) // store ra
            sw a0, 0x0038(sp) // 0x0038(sp) = player object
            sw s0, 0x0024(sp) // store s0

            lw a0, 0x0084(a0) // a0 = player struct
            jal 0x800DEE98 // set grounded state
            sw a0, 0x0034(sp) // 0x0034(sp) = player struct
            lw a0, 0x0038(sp) // a0 = player object
            lw s0, 0x0084(a0) // s0 = player struct

            lwc1 f8, 0x0078(a0) // f8 = current animation frame
            lui		at, 0x41C0 // at = 24.0
            mtc1 at, f6 // ~
            c.lt.s f6, f8 // f8 >= f6 (current frame >= MAX_FRAME_APPLY_SPEED) ?
            nop
            bc1fl _laggy // skip if frame > MAX_FRAME_APPLY_SPEED
            nop

            _lagless:
            addiu a1, r0, Action.LandingHeavy // a1 = target action
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            b _continue
            nop

            _laggy:
            addiu a1, r0, Terry.Action.PD_LAND // a1 = target action

            lw t3, 0x017C(s0) // t3 = tmp variable 1 = 0 if weak, 1 if strong
            bnez t3, _strong
            nop

            lui a3, 0x3FC0 // a3(frame speed multiplier) = 1.5
            b _continue
            nop
            _strong:
            lui a3, 0x3FA0 // a3(frame speed multiplier) = 1.25

            _continue:
            or a2, r0, r0 // a2(starting frame) = 0
            jal 0x800E6F24 // change action
            sw r0, 0x0010(sp) // argument 4 = 0

            lw s0, 0x0024(sp) // load s0
            lw ra, 0x001C(sp) // load ra
            addiu sp, sp, 0x0038 // deallocate stack space
            jr ra // return
            nop
        }

        scope fall_physics_: {
            constant W_SPEED_X(0x4270) // current setting - float32 60
            constant W_SPEED_Y(0xC2B4) // current setting - float32 -90

            OS.routine_begin(0x20)
            sw s0, 0x0000(sp)

            lw s0, 0x0084(a0) // s0 = player struct

            lw at, 0x4(s0) // at = player object
            lw t3, 0x017C(s0) // t3 = tmp variable 1 = 0 if weak, 1 if strong
            lwc1 f8, 0x0078(at) // f8 = current animation frame

            lui		at, 0x41C0 // at = 24.0
            mtc1 at, f6 // ~
            c.lt.s f6, f8 // f8 >= f6 (current frame >= MAX_FRAME_APPLY_SPEED) ?
            nop
            bc1tl _late_air_routine // skip if frame > MAX_FRAME_APPLY_SPEED
            nop

            lui		at, 0x4000 // at = 2.0
            mtc1 at, f6 // ~
            mtc1 r0, f6 // ~ 
            c.lt.s f6, f8 // f8 >= f6 (current frame >= MAX_FRAME_APPLY_SPEED) ?
            nop
            bc1tl _air_routine // skip if frame > MAX_FRAME_APPLY_SPEED
            nop

            lui at, W_SPEED_X // at = ~
            mtc1 at, f2 // f2 = X_AIR_SPEED
            lwc1 f4, 0x0044(s0) // ~
            cvt.s.w f4, f4 // f4 = DIRECTION
            mul.s f2, f2, f4 // f2 = X_AIR_SPEED * DIRECTION
            swc1 f2, 0x0048(s0) // x velocity = X_AIR_SPEED * DIRECTION

            _air_routine:
            jal 0x800D90E0 // this function allows for air control on X, but limits Y speed
            nop
            lui at, W_SPEED_Y // at = ~
            sw at, 0x004C(s0) // y velocity = Y_AIR_SPEED (always forced)
            b _end
            nop

            _late_air_routine:
            sw a0, 0x0004(sp)
            jal 0x800E9C3C // routine that ends graphics
            nop
            lw a0, 0x0004(sp)

            jal 0x800D90E0
            nop
            b _end
            nop

            _end:
            lw s0, 0x0000(sp)
            OS.routine_end(0x20)
        }
    }

    scope CS: {
        scope begin_main_: {
            constant B_PRESSED(0x4000) // bitmask for b press

            OS.routine_begin(0x20)
            sw s0, 0x0000(sp)
            lw s0, 0x0084(a0) // s0 = player struct
            lw t8, 0x014C(a2) // t8 = kinetic state

            sw a0, 0x0004(sp)
            // jal 0x800DEEC8 // set aerial state
            or a0, s0, r0
            lw a0, 0x0004(sp)

            lwc1 f0, 0x0078(a0) // f0 = current animation frame
            lui t0, 0x40A0 // t0 = 5.0F
            mtc1 t0, f2 // f2 = ~

            c.eq.s f0, f2
            nop
            bc1fl _continue // frame is not 5.0
            nop

            // frame = 5.0
            _set_weak_strong_flag:
            sw r0, 0x017C(a2) // temp variable 1 = 0
            lhu t0, 0x01BC(a2) // load button press buffer
            lhu t1, 0x01BE(a2) // load button hold buffer
            or t0, t0, t1 // join both so we cover press or hold
            andi t1, t0, B_PRESSED // t1 = 0x40 if (B_PRESSED); else t1 = 0
            beq t1, r0, _continue // skip if (!B_PRESSED)
            nop

            lli t0, 0x1
            sw t0, 0x017C(a2) // temp variable 1 = 1 (strong)

            _continue:
            lw t8, 0x014C(a2) // t8 = kinetic state
            li a1, goto_shoot // a1(transition subroutine) = goto_shoot
            jal 0x800D9480 // common main subroutine (transition on animation end)
            nop

            _end:
            lw s0, 0x0000(sp)
            OS.routine_end(0x20)
        }

        scope goto_shoot: {
            addiu sp, sp,-0x0040 // allocate stack space
            sw ra, 0x001C(sp) // ~
            sw a0, 0x0020(sp) // ~
            sw s0, 0x0024(sp) // store a0, s0, ra
            lw s0, 0x0084(a0) // s0 = player struct

            lw t8, 0x014C(s0) // t8 = kinetic state (0 = grounded, 1 = aerial)
            bnez t8, after_set_aerial
            nop

            set_aerial:
            jal 0x800DEEC8 // set aerial state
            or a0, s0, r0 // a0 = player struct

            after_set_aerial:
            lw t3, 0x017C(s0) // t3 = tmp variable 1 = 0 if weak, 1 if strong
            bnez t3, _strong
            nop
            lli a1, Terry.Action.CSHOOT_W // a1(action id) = CSHOOT_W
            b _continue
            nop
            _strong:
            lli a1, Terry.Action.CSHOOT_S // a1(action id) = CSHOOT_S

            _continue:
            lw a0, 0x0020(sp) // a0 = player object
            or a2, r0, r0 // a2(starting frame) = 0
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            addiu at, r0, 0x0001
            jal 0x800E6F24 // change action
            sw at, 0x0010(sp) // argument 4 = 1
            jal 0x800E0830 // unknown common subroutine
            lw a0, 0x0020(sp) // a0 = player object

            _end:
            lw ra, 0x001C(sp) // ~
            lw s0, 0x0024(sp) // load s0
            jr ra // return
            addiu sp, sp, 0x0040 // deallocate stack space
        }

        scope collision_: {
            OS.routine_begin(0x20)
            sw s0, 0x0000(sp)

            lw s0, 0x0084(a0) // s0 = player struct
            lw t6, 0x014C(s0) // t6 = kinetic state (0 = grounded, 1 = aerial)
            bnez t6, _aerial
            nop

            _grounded:
            jal 0x800DDF44 // grounded subroutine
            nop
            b _end
            nop

            _aerial:
            li a1, air_to_ground_ // a1(transition subroutine) = air_to_ground_
            jal 0x800DE6E4 // common air collision subroutine (transition on landing, no ledge grab)
            nop 

            _end:
            lw s0, 0x0000(sp)
            OS.routine_end(0x20)
        }

        scope air_to_ground_: {
            addiu sp, sp,-0x0038 // allocate stack space
            sw ra, 0x001C(sp) // store ra
            sw a0, 0x0038(sp) // 0x0038(sp) = player object
            sw s0, 0x0024(sp) // store s0

            lw a0, 0x0084(a0) // a0 = player struct
            jal 0x800DEE98 // set grounded state
            sw a0, 0x0034(sp) // 0x0034(sp) = player struct
            lw a0, 0x0038(sp) // a0 = player object
            lw s0, 0x0084(a0) // s0 = player struct

            addiu a1, r0, Terry.Action.CSHOOT_LAND // a1 = target action
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0

            _continue:
            or a2, r0, r0 // a2(starting frame) = 0
            jal 0x800E6F24 // change action
            sw r0, 0x0010(sp) // argument 4 = 0

            lw s0, 0x0024(sp) // load s0
            lw ra, 0x001C(sp) // load ra
            addiu sp, sp, 0x0038 // deallocate stack space
            jr ra // return
            nop
        }
    }

    scope PW: {
        scope main: {
            constant B_PRESSED(0x4000) // bitmask for b press

            addiu sp, sp, -0x0040
            sw ra, 0x0014(sp)
            swc1 f6, 0x003C(sp)
            swc1 f8, 0x0038(sp)
            sw a0, 0x0034(sp)
            addu	a2, a0, r0
            lw v0, 0x0084(a0) // v0 = player struct

            sw r0, 0x0048(v0) // set zero x speed

            // if not in light version, skip transition checks
            lw t7, 0x0024(v0) // t7 = current action
            lli t2, Terry.Action.PWAVE_W
            bne t7, t2, main_continue
            nop

            lwc1 f0, 0x0078(a0) // f0 = current animation frame
            lui t0, 0x40A0 // t0 = 5.0F
            mtc1 t0, f2 // f2 = ~

            c.eq.s f0, f2
            nop
            bc1fl main_continue // frame is not 5.0, skip
            nop

            // frame = 5.0
            _weak_to_strong:
            lhu t0, 0x01BC(v0) // load button press buffer
            lhu t1, 0x01BE(v0) // load button hold buffer
            or t0, t0, t1 // join both so we cover press or hold
            andi t1, t0, B_PRESSED // t1 = 0x40 if (B_PRESSED); else t1 = 0
            beq t1, r0, main_continue // skip if (!B_PRESSED)
            nop

            // if here, all checks passed
            _weak_to_strong_transition:
            addiu sp, sp,-0x0038 // allocate stack space
            sw ra, 0x0004(sp)
            sw a0, 0x0008(sp)
            sw a1, 0x000C(sp) // store variables
            sw a2, 0x0010(sp) // store variables
            sw a3, 0x0014(sp) // store variables
            sw v0, 0x0018(sp) // store variables
            addiu sp, sp,-0x0030 // allocate stack space

            lli a1, Terry.Action.PWAVE_S // a1 = Action.USPG
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

            b _end
            nop
            
            main_continue:
            or a3, a0, r0
            lw t6, 0x017C(v0) // tmp variable 1
            beql t6, r0, _idle_transition_check // this checks moveset variables to see if projectile should be spawned
            lw ra, 0x0014(sp)
            mtc1 r0, f0
            sw r0, 0x017C(v0) // clears out variable so he only fires one shot
            addiu a1, sp, 0x0020
            swc1 f0, 0x0020(sp) // x origin point
            swc1 f0, 0x0024(sp) // y origin point
            swc1 f0, 0x0028(sp) // z origin point

            // lui t0, 0x42C8
            // mtc1 f0, f0

            lw a0, 0x92C(v0)
            sw a3, 0x0030(sp)
            jal 0x800EDF24 // generic function used to determine projectile origin point
            sw v0, 0x002C(sp)
            lw v0, 0x002C(sp)
            lw a3, 0x0030(sp)
            sw r0, 0x001C(sp)
            or a0, a3, r0
            addiu a1, sp, 0x0020
            jal projectile_stage_setting // this sets the basic features of a projectile
            lw a2, 0x001C(sp)
            lw a2, 0x0034(sp)
            lw ra, 0x0014(sp)
            
            // checks frame counter to see if reached end of the move
            _idle_transition_check:
            mtc1 r0, f6
            lwc1 f8, 0x0078(a2)
            c.le.s f8, f6
            nop
            bc1fl _end
            lw ra, 0x0014(sp)
            lw a2, 0x0034(sp)
            jal 0x800DEE54
            or a0, a2, r0
            _end:
            lw a0, 0x0034(sp)
            lwc1 f6, 0x003C(sp)
            lwc1 f8, 0x0038(sp)
            lw ra, 0x0014(sp)
            addiu sp, sp, 0x0040
            jr ra
            nop

            projectile_stage_setting:
            addiu sp, sp, -0x0050
            sw a2, 0x0038(sp)
            lw t7, 0x0038(sp)
            sw s0, 0x0018(sp)

            // Check if B is pressed to switch between light and strong hadouken
            // v0 = player struct
            la s0, _blaster_fireball_struct // s0 = light hadouken address

            lw t0, 0x0024(v0) // t0 = current action
            lli t1, Terry.Action.PWAVE_S
            bne t0, t1, projectile_stage_setting_continue
            nop
            la s0, _blaster_fireball_strong_struct // load strong version

            projectile_stage_setting_continue:
            li t2, _blaster_projectile_struct // Load projectile struct address into t2 for later use
            sw a1, 0x0034(sp)
            sw ra, 0x001C(sp)
            or a1, t2, r0		// use projectile address saved in t2
            lw t6, 0x0084(a0)
            lw t0, 0x0024(s0)
            lw t1, 0x0028(s0)
            lw a2, 0x0034(sp)
            lui a3, 0x8000
            sw t6, 0x002C(sp)
            //sw t0, 0x0008(a1) // would revise default pointer, which has another pointer, which is to the hitbox data
            jal 0x801655C8 // This is a generic routine that does much of the work for defining all projectiles
            sw t1, 0x000C(a1)

            bnez v0, _projectile_branch
            sw v0, 0x0028(sp)
            beq r0, r0, _end_stage_setting
            or v0, r0, r0
            
            _projectile_branch:
            lw v1, 0x0084(v0)
            lui t2, 0x3f80 // load 1(fp) into f2
            addiu at, r0, 0x0001
            mtc1 r0, f4
            sw t2, 0x029C(v1) // save 1(fp) to projectile struct free space
            lw t3, 0x0000(s0)
            sw t3, 0x0268(v1)

            lw v0, 0x002C(sp) // load player struct to v0
            lw t0, 0x0024(v0) // t0 = current action
            lli t1, Terry.Action.PWAVE_S
            beq t0, t1, _projectile_branch_strong
            nop

            _projectile_branch_weak:
            // ==============
            // EDIT HITBOX
            // ==============

            // Hitbox size
            lui at, 0x4334 // at = 180.0 (fp)
            sw at, 0x0128(v1) // save

            // Hitbox damage
            lli at, 0x0008 // 8
            sw at, 0x0104(v1) // save

            // Hit type
            sw r0, 0x010C(v1) // save

            // Hit angle
            lli at, 0x37 // 55 deg
            sw at, 0x012C(v1)

            // // Hitbox base knockback
            lli at, 0x0032 // at = 50
            sw at, 0x0138(v1) // save

            // Hitbox knockback growth
            lli at, 0x0014 // at = 20
            sw at, 0x0130(v1) // save

            // Hit FGM
            lli at, FGM.hit.PUNCH_M // at = CLOUD_SWORD_PIERCE
            sh at, 0x0146(v1) // save
            
            // ==============
            // END EDIT HITBOX
            // ==============
            
            b _projectile_branch_continue
            nop

            _projectile_branch_strong:
            // ==============
            // EDIT HITBOX
            // ==============

            // Hitbox size
            lui at, 0x4334 // at = 180.0 (fp)
            sw at, 0x0128(v1) // save

            // Hitbox damage
            lli at, 0x0009 // 9
            sw at, 0x0104(v1) // save

            // Hit type
            sw r0, 0x010C(v1) // save

            // Hit angle
            lli at, 0x37 // 55 deg
            sw at, 0x012C(v1)

            // // Hitbox base knockback
            lli at, 0x0032 // at = 50
            sw at, 0x0138(v1) // save

            // Hitbox knockback growth
            lli at, 0x0014 // at = 20
            sw at, 0x0130(v1) // save

            // Hit FGM
            lli at, FGM.hit.PUNCH_M // at = CLOUD_SWORD_PIERCE
            sh at, 0x0146(v1) // save
            
            // ==============
            // END EDIT HITBOX
            // ==============
            
            b _projectile_branch_continue
            nop
    
            _projectile_branch_continue:
            OS.copy_segment(0xE3268, 0x2C) 
            lw t6, 0x002C(sp)
            lwc1 f6, 0x0020(s0) // load speed (integer)
            lw v1, 0x0024(sp)
            lw t7, 0x0044(t6)
            mul.s f8, f0, f6
            lwc1 f12, 0x0020(sp)
            mtc1 t7, f10
            nop
            cvt.s.w f16, f10
            mul.s f18, f8, f16
            jal 0x800303F0
            swc1 f18, 0x0020(v1)
            lwc1 f4, 0x0020(s0)
            lw v1, 0x0024(sp)
            lw a0, 0x0028(sp)
            mul.s f6, f0, f4
            swc1 f6, 0x0024(v1)
            lw t8, 0x0074(a0)
            lwc1 f10, 0x002C(s0)
            lw t9, 0x0080(t8)

            lui at, 0x3FC0 // at = 1.5
            mtc1 at, f6
            swc1 f6, 0x0040(t8) // store scale x size multiplier to projectile joint
            swc1 f6, 0x0044(t8) // store scale y size multiplier to projectile joint
            swc1 f6, 0x0048(t8) // store scale z size multiplier to projectile joint

            lui t0, 0xc348 // -200.0f
            mtc1 t0, f0
            swc1 f0, 0x6c(v1) // Adjust coll_data.object_coll.bottom

            lw at, 0x014C(t4) // Load player grounded state
            sw at, 0xfc(v1) // Save grounded matching grounded state for projectile

            lw t1, 0xEC(t4) // t1 = player (t4) ground_line_id
            sw t1, 0xA0(v1) // save to projectile

            bne at, r0, projectile_not_grounded
            nop
            // ip->phys_info.ground_vel = ip->phys_info.vel.x * ip->lr

            lw t6, 0x18(v1) // t2 = ip.phys_info
            lwc1 f4, 0x20(v1)
            mtc1 t6, f6
            nop
            cvt.s.w f18, f6
            mul.s f6, f4, f18
            nop
            swc1 f6, 0x1C(v1) // save to projectile

            projectile_not_grounded:

            // or a0, at, r0
            lw v0, 0x0028(sp)
            
            // This ensures the projectile faces the correct direction
            jal 0x80167FA0
            swc1 f10, 0x0088(t9)

            lw v0, 0x0028(sp)

            _end_stage_setting:
            lw ra, 0x001C(sp)
            lw s0, 0x0018(sp)
            addiu sp, sp, 0x0050
            jr 	ra
            nop

            // this subroutine seems to have a variety of functions, but definetly deals with the duration of move and result at the end of duration
            blaster_duration:
            addiu sp, sp, -0x0038
            sw ra, 0x0014(sp)
            sw a0, 0x0020(sp)
            swc1 f10, 0x0024(sp)

            jal 0x8016BC50
            nop

            sw v0, 0x28(sp)
            sw v1, 0x2C(sp)

            // if not grounded, skip and destroy
            bnez t8, blaster_duration_end // branch if duration over
            addiu v0, r0, 1 // return 1 (destroy projectile)
            or v0, r0, r0 // restore return 0

            // spawn a dash gfx every 8 frames
            andi t7, t7, 0x0007 // ~
            bnez t7, blaster_duration_end // branch if timer value does not end in 0b000 (branch won't be taken once every 8 frames)

            lw a0, 0x0020(sp) // ~

            lw t0, 0x0084(a0) // t0 = item special struct
            lw a1, 0x0018(t0) // ~ a1 = direction

            addiu sp, sp, -0x0020

            lw a0, 0x0074(a0) // ~
            addiu a0, a0, 0x001C // a0 = object x/y/z coordinates

            // build a vector 3 structure on 0x4(sp)
            lw t0, 0x0(a0) // projectile X
            sw t0, 0x4(sp) // save X

            lwc1 f0, 0x4(a0) // f0 = projectile Y
            lui t0, 0xC348 // -200.0f
            mtc1 t0, f2 // f2 = -200
            add.s f0, f0, f2 // f0 = projectile Y - 200
            swc1 f0, 0x8(sp) // save Y

            lw t0, 0x8(a0) // projectile Z
            sw t0, 0xC(sp) // save Z

            addiu a0, sp, 0x4 // a0 (position) = pointer to vector we created
            addiu sp, sp, -0x0020
            lui a2, 0x3F80 // a2 = scale? float32 1
            jal 0x800FF7D8 // create footstep gfx
            nop
            addiu sp, sp, 0x0020

            addiu sp, sp, 0x0020

            lw a0, 0x0020(sp)

            lw v0, 0x28(sp)
            lw v1, 0x2C(sp)

            blaster_duration_end:
            lw ra, 0x0014(sp)
            //lw a0, 0x0020(sp)
            lwc1 f10, 0x0024(sp)
            addiu sp, sp, 0x0038
            jr ra
            nop

            _hitbox_end:
            OS.copy_segment(0xE396C, 0x38)
            // swc1 f4, 0x0148(v0)
            OS.copy_segment(0xE39A8, 0x30)
            
            // this subroutine determines the behavior of the projectile upon reflection
            blaster_reflection:
            addiu sp, sp, -0x0018
            sw ra, 0x0014(sp)
            sw a0, 0x0018(sp)
            lw a0, 0x0084(a0) // loads active projectile struct
            lw t0, 0x0008(v0)
            addiu t7, r0, Character.id.TERRY
            bnel t0, t7, _standard
            lui t7, 0x3F80 // load normal reflect multiplier if not cloud and thereby top speed of cloud projectile will not increase
            li t7, 0x3FC90FDB // load reflect multiplier
            _standard:
            mtc1 t7, f4 // move reflect multiplier to floating point
            sw t7, 0x029C(a0) // save multiplier to free space to increase max speed
            lw t7, 0x0008(a0)
            li t0, _blaster_fireball_struct // load fireball struct to pull parameters
            lw t0, 0x0000(t0) // loads max duration from fireball struct
            sw t0, 0x0268(a0) // save max duration to active projectile struct current remaining duration
            lw a1, 0x0084(t7) // loads reflective character's struct

            // Before determining new direction, multiply speed.
            lw t6, 0x0044(a1) // loads player direction 1 or -1 in fp
            lwc1 f0, 0x0020(a0) // loads projectile velocity
            mul.s f0, f0, f4 // multiply current speed by reflection speed multiplier
            nop
            swc1 f0, 0x0020(a0) // save new speed
            nop
            jal 0x801680EC // go to the default subroutine that determines direction
            nop

            // old routine for reference, was based on 0x801680EC
            // lw t6, 0x0044(a1) // loads direction 1 or -1 in fp
            // lwc1 f0, 0x0020(a0) // loads velocity
            // mul.s f0, f0, f4 // multiply current speed by reflection speed multiplier (not original logic)
            // mtc1 r0, f10 // move 0 to f10
            // mtc1 t6, f4 // place direction in f4
            // nop
            // cvt.s.w f6, f4 // cvt to sw floating point
            // mul.s f8, f0, f6 // change direction of projectile to the opposite direction via multiplication
            // // lw t6, 0x0004(t0) // load max speed
            // // mtc1 t6, f6 // move max speed to f6
            // c.lt.s f8, f10 // current velocity compared to 0 (less than or equal to)
            // nop
            // bc1f _branch // jump if velocity is greater than 0
            // nop
            // neg.s f16, f0
            // swc1 f16, 0x0020(a0) // save velocity
            
            _branch:
            lw a0, 0x0018(sp)
            lw v0, 0x0084(a0) // load active projectile struct
            mtc1 r0, f6 // move 0 to f6
            lwc1 f4, 0x0020(v0) // load current velocity of projectile
            c.le.s f6, f4 // compare 0 to current velocity to see if now traveling leftward
            nop
            bc1f _left // jump if 0 is greater than velocity, this means the projectile is traveling leftward
            nop
            li at, 0x3FC90FDB
            mtc1 at, f8 
            lw t6, 0x0074(a0)
            j _end_reflect
            swc1 f8, 0x0034(t6)
            _left:
            li at, 0xBFC90FDB
            mtc1 at, f10
            lw t7, 0x0074(a0)
            swc1 f10, 0x0034(t7)
            _end_reflect:
            lw ra, 0x0014(sp)
            addiu sp, sp, 0x0018
            or v0, r0, r0
            jr ra
            nop

            scope projectile_vanish: {
                OS.routine_begin(0x20) // allocate stackspace

                lw v0, 0x74(a0) // v0 = projectile physics struct
                addiu a0, v0, 0x1C // a0 = pointer to projectile position vector (1C in projectile physics struct)
                jal 0x800FF648 // efManagerDustExpandSmallMakeEffect(Vec3f *pos, f32 f_index)
                or a1, r0, r0

                lli v0, 0x1 // return 1 to destroy projectile
                OS.routine_end(0x20) // deallocate stackspace and return
            }

            Projectile.add_projectile(TERRY_WAVE)
            Projectile.set_projectile_hitlag_multiplier(Projectile.id.TERRY_WAVE, 0x3FC0) // 1.5x hitlag
            
            _blaster_projectile_struct:
            dw 0x00000000 // this has some sort of bit flag to tell it to use secondary type display list?
            dw Projectile.id.TERRY_WAVE
            dw Character.TERRY_file_6_ptr // pointer to file
            dw 0x00000000 // 00000000
            dw 0x1C000000 // rendering routine?
            dw blaster_duration // proc update
            dw 0x8016BCC8 // proc map: wpKirbyCutterProcMap(GObj *weapon_gobj)
            dw projectile_vanish // proc hit
            dw projectile_vanish // proc shield
            dw 0x8016DD2C // proc hop (shield bounce)
            dw projectile_vanish // proc set-off
            dw blaster_reflection // proc reflector
            dw projectile_vanish // proc absorb
            OS.copy_segment(0x103904, 0x0C) // empty 
            
            _blaster_fireball_struct:
            dw 67 // 0x0000 - duration (int)
            float32 44 // 0x0004 - max speed
            float32 44 // 0x0008 - min speed
            float32 0 // 0x000C - gravity
            float32 0 // 0x0010 - bounce multiplier
            float32 0 // 0x0014 - rotation angle
            float32 0 // 0x0018 - initial angle (ground)
            float32 0 // 0x001C initial angle (air)
            float32 44 // 0x0020 initial speed
            dw Character.TERRY_file_6_ptr // 0x0024 projectile data pointer
            dw 0 // 0x0028 unknown (default 0)
            float32 0 // 0x002C palette index (0 = mario, 1 = luigi)
            OS.copy_segment(0x1038A0, 0x30)

            _blaster_fireball_strong_struct:
            dw 44 // 0x0000 - duration (int)
            float32 70 // 0x0004 - max speed
            float32 70 // 0x0008 - min speed
            float32 0 // 0x000C - gravity
            float32 0 // 0x0010 - bounce multiplier
            float32 0 // 0x0014 - rotation angle
            float32 0 // 0x0018 - initial angle (ground)
            float32 0 // 0x001C initial angle (air)
            float32 70 // 0x0020 initial speed
            dw Character.TERRY_file_6_ptr // 0x0024 projectile data pointer
            dw 0 // 0x0028 unknown (default 0)
            float32 0 // 0x002C palette index (0 = mario, 1 = luigi)
            OS.copy_segment(0x1038A0, 0x30)
        }
    }
}