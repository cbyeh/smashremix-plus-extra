// RyuSpecial.asm

// This file contains subroutines used by Ryu's special moves.
scope RyuSpecial: {
    scope OnActionChanged: {
        OS.routine_begin(0x20)
        lw a0, 0x4(a0) // a0 = player object
        sw a0, 0x18(sp) // save player object
        lw s0, 0x84(a0) // s0 = player struct
        sw s0, 0x1c(sp) // save player struct

        sw r0, 0xAE4(s0) // cancel window frames = 0

        scope _special_cancellable_action_check: {
            // a1 = new action id
            lli t0, Ryu.Action.JAB_L
            beq a1, t0, _continue
            lli t0, Ryu.Action.JAB_L2
            beq a1, t0, _continue
            lli t0, Ryu.Action.JAB_CLOSE
            beq a1, t0, _continue
            lli t0, Ryu.Action.UTILT_H
            beq a1, t0, _continue
            lli t0, Ryu.Action.UTILT_L
            beq a1, t0, _continue
            lli t0, Ryu.Action.DTILT_H
            beq a1, t0, _continue
            lli t0, Ryu.Action.DTILT_L
            beq a1, t0, _continue
            lli t0, Ryu.Action.FTILT_CLOSE
            beq a1, t0, _continue
            lli t0, Action.AttackAirN
            beq a1, t0, _continue
            lli t0, Action.AttackAirF
            beq a1, t0, _continue
            lli t0, Action.AttackAirB
            beq a1, t0, _continue
            lli t0, Action.AttackAirU
            beq a1, t0, _continue
            lli t0, Action.AttackAirD
            beq a1, t0, _continue
            lli t0, Action.DSmash
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
            lli t0, Action.AttackAirF
            beq a1, t0, _set_interrupt
            lli t0, Action.AttackAirB
            beq a1, t0, _set_interrupt
            lli t0, Action.AttackAirU
            beq a1, t0, _set_interrupt
            lli t0, Action.AttackAirD
            beq a1, t0, _set_interrupt
            lli t0, Action.DSmash
            beq a1, t0, _set_interrupt
            nop
            b _end // not an aerial
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
            lli t0, Ryu.Action.JAB_H
            beq a1, t0, _continue
            lli t0, Ryu.Action.JAB_L
            beq a1, t0, _continue
            lli t0, Ryu.Action.JAB_CLOSE
            beq a1, t0, _continue
            lli t0, Ryu.Action.UTILT_H
            beq a1, t0, _continue
            lli t0, Ryu.Action.UTILT_L
            beq a1, t0, _continue
            lli t0, Ryu.Action.DTILT_H
            beq a1, t0, _continue
            lli t0, Ryu.Action.DTILT_L
            beq a1, t0, _continue
            lli t0, Action.DSmash
            beq a1, t0, _continue
            lli t0, Action.USmash
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
    Character.table_patch_start(on_action_changed, Character.id.RYU, 0x4)
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
            lw a0, 0x18(sp)

            scope check_tilt_strength: {
                // check for two things:
                // if frame is < 6
                // if A is pressed
                // if up to frame 5 A is released, we change to the weak version of the move
                lw a1, 0x0084(a0) // loads player struct into a1
                lwc1 f8, 0x0078(a0) // f8 = current frame

                jal proximity_move_check // check if we need to change to the proximity move
                nop
                
                // if frame >= 6, skip
                lwc1 f8, 0x0078(a0) // f8 = current frame
                lui t1, 0x40C0 // t1 = 6.0F
                mtc1 t1, f6 // f6 = 6.0F
                c.le.s f8, f6 // f8 <= f6 (current frame <= 6.0F) ?
                nop
                bc1fl _skip // skip if frame >= 6
                nop

                lhu t0, 0x01BC(a1) // load held button buffer
                andi t1, t0, Joypad.A // t1 != 0 if (A_PRESSED); else t1 = 0
                bne t1, r0, _skip // skip if (!A_PRESSED)
                nop

                // if here, change action to weak version
                // change to a different action depending on the current action
                // DTILT_H -> DTILT_L, same for UTILT, FTILT, (JAB_H, JAB_CLOSE -> JAB_L)
                lw t0, 0x0024(a1) // t0 = current action

                lli t1, Action.DTilt // t1 = action to check against
                beq t0, t1, change_action // if current action matches, change action
                lli a1, Ryu.Action.DTILT_L // a1 = action to change to

                lli t1, Action.UTilt // t1 = action to check against
                beq t0, t1, change_action // if current action matches, change action
                lli a1, Ryu.Action.UTILT_L // a1 = action to change to

                lli t1, Action.FTilt // t1 = action to check against
                beq t0, t1, change_action // if current action matches, change action
                lli a1, Ryu.Action.FTILT_L // a1 = action to change to

                lli t1, Action.Jab1 // t1 = action to check against
                beq t0, t1, change_action // if current action matches, change action
                lli a1, Ryu.Action.JAB_L // a1 = action to change to

                lli t1, Ryu.Action.JAB_CLOSE // t1 = action to check against
                beq t0, t1, change_action // if current action matches, change action
                lli a1, Ryu.Action.JAB_L // a1 = action to change to

                b _skip
                nop

                change_action:
                addiu sp, sp, -0x30
                sw ra, 0x1C(sp)
                sw a0, 0x20(sp)

                or a2, r0, r0 // a2(starting frame) = 0.0
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
                sw r0, 0x0010(sp) // argument 4 = 0
                jal 0x800E6F24 // change action
                nop

                lw ra, 0x1C(sp)
                lw a0, 0x20(sp)
                addiu sp, sp, 0x30

                lli v0, 0x1 // return true (action was changed)

                OS.routine_end(0x20)

                _skip:
            }

            scope check_jab_continue: {
                lw a0, 0x18(sp) // a0 = player object
                lw a1, 0x84(a0) // a1 = player struct

                lw at, 0xAE4(a1) // at = cancel window frames
                beqz at, _skip // if cancel window frames = 0, skip
                nop

                lhu t0, 0x01BE(a1) // load button press buffer
                andi t1, t0, Joypad.A // t1 != 0 if (A_PRESSED); else t1 = 0
                beq t1, r0, _skip // skip if (!A_PRESSED)
                nop

                lw t0, 0x24(a1) // t0 = current action

                lli t1, Ryu.Action.JAB_L // t1 = Action to check against
                beq t0, t1, change_action // if current action matches, change action
                lli a1, Ryu.Action.JAB_L2 // action to change to

                lli t1, Ryu.Action.JAB_L2 // t1 = Action to check against
                beq t0, t1, change_action // if current action matches, change action
                lli a1, Ryu.Action.JAB_L3 // action to change to

                b _skip
                nop

                change_action:
                addiu sp, sp, -0x30
                sw ra, 0x1C(sp)
                sw a0, 0x20(sp)

                or a2, r0, r0 // a2(starting frame) = 0.0
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
                sw r0, 0x0010(sp) // argument 4 = 0
                jal 0x800E6F24 // change action
                nop

                lw ra, 0x1C(sp)
                lw a0, 0x20(sp)
                addiu sp, sp, 0x30

                lli v0, 0x1 // return true (action was changed)

                OS.routine_end(0x20)

                _skip:
            }
            
            skip_change:
            lw a0, 0x18(sp) // a0 = player object
            lw a1, 0x84(a0) // a1 = player struct
            sw r0, 0x150(a1) // Set attack1_followup_frames = 0. Needed to be able to jab 1 again.

            _end:
            OS.routine_end(0x20)
        }

        scope proximity_move_check: {
            OS.routine_begin(0x20)

            sw a0, 0x0004(sp) // ~
            sw a1, 0x0008(sp) // ~
            sw a2, 0x000C(sp) // ~
            sw v0, 0x0010(sp) // ~

            // f8 = current frame

            // If on first animation frame, check if we have to change to the proximity move
            lui at, 0x4000
            mtc1 at, f6
            c.eq.s f8, f6
            nop
            bc1fl _end // if frame doesn't match, skip
            nop

            or t5, r0, a0

            lw t6, 0x0B18(a0) //
            lw t7, 0x0B1C(a0) // save player struct variables

            sw r0, 0x0B18(a1) // target = NULL
            sw r0, 0x0B1C(a1) // X_DIFF = 0

            jal check_for_targets_ // check_for_targets_
            nop

            lw t0, 0x0B18(a0) // t0 = target object

            sw t6, 0x0B18(a0) //
            sw t7, 0x0B1C(a0) // restore player struct variables
            or a0, r0, t5

            beq v0, r0, _end // skip if no target was found
            nop

            check_distance:
            mtc1 v1, f8 // f8 = X_DIFF

            lui at, MAX_X_RANGE_BACK // at = MAX_X_RANGE_BACK
            mtc1 at, f6 // f6 = MAX_X_RANGE_BACK
            neg.s f8, f8 // f6 = -MAX_X_RANGE_BACK
            c.le.s f8, f6 // ~
            nop // ~
            bc1fl _end // skip if X_DIFF =< MAX_X_RANGE_BACK
            nop

            lw a1, 0x0008(sp) // restore a1
            lw t1, 0x0024(a1) // t1 = current action

            lli t2, Action.Jab1
            beq t1, t2, change_action
            addiu a1, r0, Ryu.Action.JAB_CLOSE

            lli t2, Ryu.Action.FTILT_L
            beq t1, t2, change_action
            addiu a1, r0, Ryu.Action.FTILT_CLOSE

            b _end
            nop

            change_action:
            addiu sp, sp, -0x30
            sw ra, 0x1C(sp)
            sw a0, 0x20(sp)

            lui a2, 0x3F80 // a2(starting frame) = 1.0
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            sw r0, 0x0010(sp) // argument 4 = 0
            jal 0x800E6F24 // change action
            nop
            jal 0x800E0830
            lw a0, 0x20(sp)

            lw ra, 0x1C(sp)
            lw a0, 0x20(sp)
            addiu sp, sp, 0x30

            _end:
            lw a0, 0x0004(sp) // ~
            lw a1, 0x0008(sp) // ~
            lw a2, 0x000C(sp) // ~
            lw v0, 0x0010(sp) // ~

            OS.routine_end(0x20)
        }

        // @ Description
        // Finds the closest opponent, and separately the closest overall
        // target (an opponent, or - whichever is actually closer - an item
        // with an active hurtbox), for auto_turnaround and
        // proximity_move_check respectively. Items can never affect the
        // opponent-only result: it's captured before items are even
        // searched, so auto_turnaround (which only ever turns towards an
        // opponent) is completely unaffected by nearby items, while
        // proximity_move_check still gets the true closest target of
        // either kind.
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
            // wherever pass 1 left off, so proximity_move_check can still
            // get the true overall closest target (opponent or item)
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

    scope CancelItselfDtilt: {
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
            lui t1, 0x40C0 // t1 = 6.0F
            mtc1 t1, f8

            c.le.s f6, f8
            nop
            bc1tl main_normal
            nop

            lw t0, 0x0184(v0) // was A ever pressed during the move?
            beq t0, r0, main_normal // If not, main_normal
            nop

            // all conditions are met
            b cancel_itself
            nop

            cancel_itself:
            OS.save_registers()
            lli a1, Action.DTilt // a1 = Action.Dtilt
            or a2, r0, r0 // a2(starting frame) = 0.0
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

    scope CancelItselfUtilt: {
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

            lb t0, 0x01C3(v0) // t0 = stick_y
            slti t1, t0, 20 // at = 1 if stick_y < 20, else at = 0
            beql t1, r0, register_press // branch if stick_y >= 20
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
            lui t1, 0x40C0 // t1 = 6.0F
            mtc1 t1, f8

            c.le.s f6, f8
            nop
            bc1tl main_normal
            nop

            lw t0, 0x0184(v0) // was A ever pressed during the move?
            beq t0, r0, main_normal // If not, main_normal
            nop

            // all conditions are met
            b cancel_itself
            nop

            cancel_itself:
            OS.save_registers()
            lli a1, Action.UTilt // a1 = Action.Dtilt
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

    scope USP: {
        constant AIR_ACCELERATION(0x3a83) // current setting - float32 0.0099
        constant AIR_SPEED(0x4120) // current setting - float32 10
        constant LANDING_FSM(0x3F80) // current setting - float32 1.0
        // temp variable 3 constants for movement states
        constant BEGIN(0x1)
        constant BEGIN_MOVE(0x2)
        constant MOVE(0x3)

        // @ Description
        // Subroutine which runs when Ryu initiates an aerial up special.
        // Changes action, and sets up initial variable values.
        scope air_initial_: {
            addiu sp, sp, 0xFFE0 // ~
            sw ra, 0x001C(sp) // ~
            sw a0, 0x0020(sp) // original lines 1-3
            sw r0, 0x0010(sp) // argument 4 = 0
            lli a1, Ryu.Action.USP_AIR_L // a1 = Action.USPA
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
        // Subroutine which runs when Ryu initiates a grounded up special.
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
            lli a1, Ryu.Action.USP_L // a1 = Action.USPG
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
        // Main subroutine for Ryu's up special.
        // Based on subroutine 0x8015C750, which is the main subroutine of Fox's up special ending.
        // Modified to load Ryu's landing FSM value and disable the interrupt flag.
        scope main_: {
            OS.routine_begin(0x20)

            light_to_hard:
            lwc1 f8, 0x0078(a0) // load current frame

            // if not in light usp, skip
            lw t7, 0x0024(a2) // t7 = current action
            lli t2, Ryu.Action.USP_L
            beq t7, t2, light_to_hard_continue
            lli t2, Ryu.Action.USP_AIR_L
            beq t7, t2, light_to_hard_continue
            nop
            b _main_normal
            nop

            light_to_hard_continue:
            lui		at, 0x4080					// at = 2.0
            mtc1 at, f6 // ~
            c.eq.s f8, f6 // f8 >= f6 (current frame >= 2) ?
            nop
            bc1fl _main_normal // skip if haven't reached frame 2
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

            lw t7, 0x0024(a2) // t7 = current action
            lli t2, Ryu.Action.USP_L
            beq t7, t2, _change_action
            lli a1, Ryu.Action.USP_H // a1 = Action
            lli a1, Ryu.Action.USP_AIR_H // a1 = Action

            _change_action:
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

            _main_normal:
            lw t8, 0x014C(a2) // t8 = kinetic state
            li a1, goto_fall // a1(transition subroutine) = goto_fall
            jal 0x800D9480 // common main subroutine (transition on animation end)
            nop

            _end:
            OS.routine_end(0x20)
        }

        scope goto_fall: {
            addiu sp, sp,-0x0040 // allocate stack space
            sw ra, 0x001C(sp) // ~
            sw a0, 0x0020(sp) // ~
            sw s0, 0x0024(sp) // store a0, s0, ra

            lw s0, 0x0084(a0) // s0 = player struct
            lw t6, 0x014C(s0) // t6 = kinetic state (0 = grounded, 1 = aerial)
            lw t3, 0x017C(s0) // t3 = tmp variable 1 = 0 if weak, 1 if strong

            lw a0, 0x0020(sp) // a0 = player object
            lli a1, Ryu.Action.USP_FALL // a1(action id)
            or a2, r0, r0 // a2(starting frame) = 0
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
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

        scope fall_main: {
            OS.routine_begin(0x20)

            // on animation end
            li a1, goto_specialfall // a1(transition subroutine)
            jal 0x800D9480 // common main subroutine (transition on animation end)
            nop

            _end:
            OS.routine_end(0x20)
        }

        scope goto_specialfall: {
            addiu sp, sp,-0x0028
            sw ra, 0x24(sp)

            lui a1, 0x3F28 // drift
            lli a2, 0x1 // unknown
            lli a3, 0x1 // accelerate fall (apply gravity)
            sw r0, 0x0010(sp) // is_goto_landing
            sw r0, 0x0018(sp) // interrupt flag = FALSE
            lui t6, LANDING_FSM // t6 = LANDING_FSM
            sw t6, 0x0014(sp) // store LANDING_FSM
            
            jal 0x801438F0 // begin special fall
            nop

            lw ra, 0x24(sp)
            addiu sp, sp, 0x0028
            jr ra
            nop
        }

        scope fall_collision: {
            addiu sp, sp,-0x0018 // allocate stack space
            sw ra, 0x0014(sp) // store ra
            li a1, goto_specialfall // a1(transition subroutine) = air_to_ground_
            jal 0x800DE80C // common air collision subroutine (transition on landing, allow ledge grab)
            nop 
            lw ra, 0x0014(sp) // load ra
            addiu sp, sp, 0x0018 // deallocate stack space
            jr ra // return
            nop
        }

        scope fall_physics: {
            addiu sp,sp,-0x20
            sw ra,0x14(sp)

            // apply gravity
            lw a0, 0x84(a0) // a0 = fighter struct
            lw a1, 0x9c8(a0) // a1 = fighter attributes
            jal 0x800D8E50 // ftPhysicsApplyGravityDefault
            sw a0, 0x1c(sp) // save fighter struct 

            // air x control
            lw a0, 0x1c(sp) // restore a0 = fighter struct
            or a1, r0, r0 // stick_range_min = 0
            lui a2, 0x3F00 // vel
            jal 0x800D8FC8 // ftPhysicsClampAirVelXStickRange
            lui a3, 0x4120 // clamp

            // air x friction
            lw a0, 0x1c(sp) // restore a0 = fighter struct
            lw a1, 0x9c8(a0) // a1 = fighter attributes
            jal 0x800D9074 // ftPhysicsApplyAirVelXFriction
            nop

            lw ra,0x14(sp)
            addiu sp,sp,0x20
            jr ra
            nop
        } 

        // @ Description
        // Subroutine which allows a direction change for Ryu's up special.
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

            _root_motion:
            jal 0x800D93E4 // physics subroutine
            nop

            // Here: if frame == 10, check if abs(analog) > range. If it is, set drift version flag
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
            lui		at, 0x4180					// at = 16.0
            mtc1 at, f6 // ~
            c.lt.s f6, f8 // f8 >= f6 (current frame >= 20) ?
            nop
            bc1tl _end // skip if past frame 20
            nop

            lw t0, 0x017C(s0) // t0 = tmp variable 1
            beq t0, r0, _vertical // skip horizontal if tmp variable 1 == 0
            nop

            lwc1 f0, 0x0048(s0) // f0 = current x velocity

            lui t0, 0x4000 // 2.0F
            mtc1 t0, f2 // f2 = 2.0F

            mul.s f0, f0, f2 // f2 = x velocity * direction
            
            swc1 f0, 0x0048(s0)

            _vertical:
            lw t7, 0x0024(s0) // t7 = current action

            lui t0, 0x3F99 // t0 = ~1.2
            lli t2, Ryu.Action.USP_H
            beq t7, t2, _multiply_movement
            nop
            lui t0, 0x3FC0 // t0 = 1.5
            lli t2, Ryu.Action.USP_AIR_H
            beq t7, t2, _multiply_movement
            nop

            lui t0, 0x3F30 // t0 = ~0.7

            _multiply_movement:
            mtc1 t0, f2 // f2 = multiplier

            lwc1 f0, 0x0048(s0) // f0 = current x velocity
            mul.s f0, f0, f2 // f0 = x velocity * multiplier
            swc1 f0, 0x0048(s0) // x velocity = (x velocity * multiplier)

            lwc1 f0, 0x004C(s0) // f0 = current y velocity
            mul.s f0, f0, f2 // f0 = y velocity * multiplier
            swc1 f0, 0x004C(s0) // y velocity = (y velocity * multiplier)

            _end:
            lw ra, 0x001C(sp) // ~
            lw s0, 0x0014(sp) // ~
            lw s1, 0x0018(sp) // load ra, s0, s1
            addiu sp, sp, 0x0038 // deallocate stack space
            jr ra // return
            nop
        }

        // @ Description
        // Subroutine which handles Ryu's horizontal control for up special.
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
        // Collision wubroutine for Ryu's up special.
        // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
        // Loads the appropriate landing fsm value for Ryu.
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

    scope NSP: {
        // floating point constants for physics and fsm
        constant AIR_Y_SPEED(0x4220) // current setting - float32 60
        constant GROUND_Y_SPEED(0x42C4) // current setting - float32 98
        constant X_SPEED(0x0) // current setting - float32 10
        constant AIR_ACCELERATION(0x3C88) // current setting - float32 0.0166
        constant AIR_SPEED(0x41B0) // current setting - float32 22
        constant LANDING_FSM(0x4000) // current setting - float32 0.375
        // temp variable 3 constants for movement states
        constant BEGIN(0x1)
        constant BEGIN_MOVE(0x2)
        constant MOVE(0x3)


        // tmp variable 1 0x017C
        // tmp variable 2 0x0B30 -- use this to check if we're going for shakunetsu
        // tmp variable 3 0x0184

        // @ Description 
        // main subroutine for Ryu's Blaster
        scope main: {
            addiu sp, sp, -0x0040
            sw ra, 0x0014(sp)
            swc1 f6, 0x003C(sp)
            swc1 f8, 0x0038(sp)
            sw a0, 0x0034(sp)
            addu	a2, a0, r0
            lw v0, 0x0084(a0) // loads player struct

            // Check if we're on fist frame so we can set x speed to 0
            lui t1, 0x4000 // t1=1.0
            mtc1 t1, f6 // f6=1.0
            lwc1 f8, 0x0078(a2) // f8=current frame, if a2 is player object
            c.eq.s f8, f6 // compare less equal f8 f6
            bc1fl main_continue // if frame is not 1.0, continue
            nop

            // frame = 1.0
            sw r0, 0x0048(v0) // set zero x speed

            // check if we came from a smash input
            // in this case, do shakunetsu
            sw r0, 0x0B30(v0) // initialize tmp var 2 as zero
            
            // check stick x
            lb t0, 0x01C2(v0) // t0 = stick_x
            mtc1 t0, f6 // f6 = stick_x
            cvt.s.w f6, f6
            abs.s f6, f6 // f6 = abs(stick_x)
            lui t1, 0x4260 // t1 = 56.0
            mtc1 t1, f8 // f8 = 56.0
            c.le.s f8, f6 // ~
            nop // ~
            bc1fl main_continue // skip if absolute stick < 56
            nop

            // check B buffer
            lbu t0, 0x26a(v0) // t0 = b button press buffer
            slti t0, t0, 8
            beqz t0, main_continue
            nop

            lw t0, 0x0008(v0) // t0 = character id
            ori t1, r0, Character.id.RYU // t1 = id.RYU
            beq t0, t1, fsmash_b_ryu // if character id = RYU
            nop

            fsmash_b_ryu:
            lli t0, 0x2
            sw t0, 0x0B30(v0) // set tmp variable 2 to 1 to know we're going for shakunetsu

            main_continue:
            or a3, a0, r0
            lw t6, 0x017C(v0) // tmp variable 1
            beql t6, r0, _idle_transition_check // this checks moveset variables to see if projectile should be spawned
            lw ra, 0x0014(sp)
            lw at, 0x0ADC(v0) // pointer to spawned hadouken object (if any)
            bnez at, _idle_transition_check // if there's a hadouken out, skip
            lw ra, 0x0014(sp)
            mtc1 r0, f0
            sw r0, 0x017C(v0) // clears out variable so he only fires one shot
            addiu a1, sp, 0x0020
            swc1 f0, 0x0020(sp) // x origin point
            swc1 f0, 0x0024(sp) // y origin point
            swc1 f0, 0x0028(sp) // z origin point
            lw a0, 0x0928(v0)
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

            // For Ryu
            lw t0, 0x0B30(v0) // t0 = load tmp variable 2
            lli t1, 0x2
            bne t0, t1, hadouken_branch // If it's not 0x2, we load hadouken
            nop

            b shakunetsu_branch // Else, go for Shakunetsu
            nop

            hadouken_branch:
            // Check if B is pressed to switch between light and strong hadouken
            // v0 = player struct
            la s0, _blaster_fireball_struct // s0 = light hadouken address

            li t2, _blaster_projectile_struct // Load projectile struct address into t2 for later use

            lhu t0, 0x01BC(v0) // load button press buffer
            andi t1, t0, 0x4000 // t1 = 0x40 if (B_PRESSED); else t1 = 0
            beq t1, r0, projectile_stage_setting_continue // skip if (!B_PRESSED)
            nop

            la s0, _blaster_fireball_heavy_struct // s0 = light hadouken address
            b projectile_stage_setting_continue
            nop

            shakunetsu_branch:
            // Check if B is pressed to switch between light and strong hadouken
            // v0 = player struct
            la s0, _blaster_shakunetsu_struct // s0 = light hadouken address

            li t2, _blaster_shakunetsu_projectile_struct // Load projectile struct address into t2 for later use

            lhu t0, 0x01BC(v0) // load button press buffer
            andi t1, t0, 0x4000 // t1 = 0x40 if (B_PRESSED); else t1 = 0
            beq t1, r0, projectile_stage_setting_continue // skip if (!B_PRESSED)
            nop

            la s0, _blaster_shakunetsu_heavy_struct // s0 = light hadouken address
            b projectile_stage_setting_continue
            nop
            
            projectile_stage_setting_continue:
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
            lw t0, 0x0B30(v0) // t0 = load tmp variable 2
            lli t1, 0x2 // If it's 0x2, we load shakunetsu

            bne t0, t1, _projectile_branch_hadouken
            nop

            b _projectile_branch_shakunetsu
            nop

            _projectile_branch_hadouken:
            // ==============
            // EDIT HITBOX
            // ==============

            // Hitbox size
            lui at, 0x42F0 // at = 120.0 (fp)
            sw at, 0x0128(v1) // save

            // Hitbox damage
            lli at, 0x000A // 10
            sw at, 0x0104(v1) // save

            // Hit type
            sw r0, 0x010C(v1) // save

            // Hit angle
            lli at, 0x3C // 60
            sw at, 0x012C(v1)

            // // Hitbox base knockback
            lli at, 0x0026 // at = 38
            sw at, 0x0138(v1) // save

            // Hitbox knockback growth
            lli at, 0x000A // at = 10
            sw at, 0x0130(v1) // save

            // Hit FGM
            lli at, Ryu.FGM.PUNCH_M // at = RYU_HIT_M
            sh at, 0x0146(v1) // save

            // Check if B is held, add more damage and knockback to the strong version
            lhu t0, 0x01BC(v0) // load button press buffer
            andi t1, t0, 0x4000 // t1 = 0x40 if (B_PRESSED); else t1 = 0
            beq t1, r0, _projectile_branch_continue // skip if (!B_PRESSED)
            nop

            // Hitbox base knockback
            lli at, 0x0028 // at = 40
            sw at, 0x0138(v1) // save

            // Hitbox damage
            lli at, 0x000C // 12
            sw at, 0x0104(v1) // save

            // Hit FGM
            lli at, Ryu.FGM.PUNCH_L // at = RYU_HIT_L
            sh at, 0x0146(v1) // save
            
            // ==============
            // END EDIT HITBOX
            // ==============
            
            b _projectile_branch_continue
            nop

            _projectile_branch_shakunetsu:
            // ==============
            // EDIT HITBOX
            // ==============

            // Hitbox size
            lui at, 0x42F0 // at = 120.0 (fp)
            sw at, 0x0128(v1) // save

            // Hitbox damage
            lli at, 0x0001 // 1
            sw at, 0x0104(v1) // save

            // Hit type
            lli at, 0x1 // at = 1 (fire)
            sw at, 0x010C(v1) // save

            // Hit angle
            lli at, 0x0050 // 80
            sw r0, 0x012C(v1)

            // // Hitbox base knockback
            lli at, 0x0014 // 20
            sw at, 0x0138(v1) // save

            // Hitbox knockback growth
            sw r0, 0x0130(v1) // 0

            // Hit FGM
            lli at, FGM.hit.FIRE_S // at = FIRE_S
            sh at, 0x0146(v1) // save

            sw r0, 0x02A0(v1) // start tmp variable 2 as zero (will be 1 if collided with anything)
            
            // ==============
            // END EDIT HITBOX
            // ==============
    
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
            addiu sp, sp, -0x0024
            sw ra, 0x0014(sp)
            sw a0, 0x0020(sp)
            swc1 f10, 0x0024(sp)
            lw a0, 0x0084(a0)

            jal 0x80167FE8 // decrease duration and check if duration is over
            sw a0, 0x001C(sp) // store a0
            bnez v0, _destroy // branch if duration over
            addiu v0, r0, 1 // return 1 (destroy projectile)
            lw a0, 0x001C(sp) // if here, restore a0
            
            _continue:
            addiu t8, r0, r0 // used to use free space area, but for no apparent reason, affects graphics
            //lw t8, 0x029C(a0)
            li t0, _blaster_fireball_struct
            addu v0, r0, t0
            lw a1, 0x000C(v0)
            lw a2, 0x0004(v0)
            lw t1, 0x0020(sp)
            addiu t2, r0, r0 // used to use free space area, but for no apparent reason, effects graphics
            lw v1, 0x0074(t1)
            or v0, r0, r0

            lui at, 0x3FB4 // at = 1.4
            mtc1 at, f6

            swc1 f6, 0x0040(v1) // store x size multiplier to projectile joint
            swc1 f6, 0x0044(v1) // store y size multiplier to projectile joint

            _end_duration:
            lw ra, 0x0014(sp)
            lwc1 f10, 0x0024(sp)
            addiu sp, sp, 0x0024
            jr ra
            nop

            _destroy:
            lw a0, 0x20(sp) // a0 = projectile object
            lw v0, 0x74(a0) // v0 = projectile physics struct
            addiu a0, v0, 0x1C // a0 = pointer to projectile position vector (1C in projectile physics struct)
            jal 0x800FF648 // efManagerDustExpandSmallMakeEffect(Vec3f *pos, f32 f_index)
            or a1, r0, r0
            b _end_duration
            addiu v0, r0, 1 // return 1 (destroy projectile)

            // this subroutine seems to have a variety of functions, but definetly deals with the duration of move and result at the end of duration
            blaster_duration_shakunetsu:
            addiu sp, sp, -0x0024
            sw ra, 0x0014(sp)
            sw a0, 0x0020(sp)
            swc1 f10, 0x0024(sp)
            lw a0, 0x0084(a0)

            jal 0x80167FE8 // decrease duration and check if duration is over
            sw a0, 0x001C(sp) // store a0
            bnez v0, _destroy_shakunetsu // branch if duration over
            addiu v0, r0, 1 // return 1 (destroy projectile)
            lw a0, 0x001C(sp) // if here, restore a0
            
            _continue_shakunetsu:
            addiu t8, r0, r0 // used to use free space area, but for no apparent reason, affects graphics
            //lw t8, 0x029C(a0)
            li t0, _blaster_fireball_struct
            addu v0, r0, t0
            lw a1, 0x000C(v0)
            lw a2, 0x0004(v0)
            lw t1, 0x0020(sp)
            addiu t2, r0, r0 // used to use free space area, but for no apparent reason, effects graphics
            lw v1, 0x0074(t1)
            or v0, r0, r0

            lw t0, 0x02A0(a0) // check if collided with anything
            lli t1, 0x1
            bne t0, t1, _continue_shakunetsu2
            nop
            
            // if collided with anything, continue
            lwc1 f8, 0x0020(a0) // load current speed

            lui		at, 0x4140 // new speed = 12.0
            mtc1 at, f6 // f6 = new speed

            mtc1 r0, f10 // load 0 to f10
            c.lt.s f8, f10 // current velocity compared to 0 (less than or equal to)
            nop
            bc1f _slow_shaku_apply // jump if velocity is greater than 0
            nop

            neg.s f6, f6

            _slow_shaku_apply:
            swc1 f6, 0x0020(a0)

            _check_frame_refresh:
            // Refresh hitbox on duration = 14, 10, 6, 1
            lw t0, 0x0268(a0) // t0 = remaining duration

            lli t1, 0xE
            beq t0, t1, _refresh_hitbox
            nop

            lli t1, 0xA
            beq t0, t1, _refresh_hitbox
            nop

            lli t1, 0x6
            beq t0, t1, _refresh_hitbox
            nop

            lli t1, 0x1
            beq t0, t1, _refresh_hitbox
            nop

            b _continue_shakunetsu2
            nop

            _refresh_hitbox:

            // refresh hitbox
            sw r0, 0x0214(a0) // reset hit object pointer 1
            sw r0, 0x021C(a0) // reset hit object pointer 2
            sw r0, 0x0224(a0) // reset hit object pointer 3
            sw r0, 0x022C(a0) // reset hit object pointer 4

            lli t1, 0x1
            bne t0, t1, _continue_shakunetsu2 // if we're not in the final hit, skip
            nop

            // Set last hit properties
            // Hitbox damage
            lli t0, 0x0009 // 9
            sw t0, 0x0104(a0) // save

            // Hit angle
            lli t1, 0x003C // 60
            sw t1, 0x012C(a0)

            // Hitbox base knockback
            lli t0, 0x003A // 58
            sw t0, 0x0138(a0) // save

            // Hitbox knockback growth
            lli t0, 0x003C // 60
            sw t0, 0x0130(a0) // save

            // Hit FGM
            lli t0, FGM.hit.FIRE_L // at = RYU_HIT_M
            sh t0, 0x0146(a0) // save

            _continue_shakunetsu2:
            lui at, 0x3FB4 // at = 1.4
            mtc1 at, f6

            swc1 f6, 0x0040(v1) // store x size multiplier to projectile joint
            swc1 f6, 0x0044(v1) // store y size multiplier to projectile joint

            _end_duration_shakunetsu:
            lw ra, 0x0014(sp)
            lwc1 f10, 0x0024(sp)
            addiu sp, sp, 0x0024
            jr ra
            nop

            _destroy_shakunetsu:
            lw a0, 0x20(sp) // a0 = projectile object
            lw v0, 0x74(a0) // v0 = projectile physics struct
            addiu a0, v0, 0x1C // a0 = pointer to projectile position vector (1C in projectile physics struct)
            jal 0x800FF648 // efManagerDustExpandSmallMakeEffect(Vec3f *pos, f32 f_index)
            or a1, r0, r0
            b _end_duration_shakunetsu
            addiu v0, r0, 1 // return 1 (destroy projectile)

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
            addiu t7, r0, Character.id.RYU
            bnel t0, t7, _standard
            lui t7, 0x3F80 // load normal reflect multiplier if not ryu and thereby top speed of ryu projectile will not increase
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

            // @ Description
            // This subroutine bounces the ryo off shields and changes the rotation of the graphic on top
            scope shakunetsu_collision: {
                OS.routine_begin(0x20) // allocate stackspace

                lw v0, 0x0084(a0) // v0 = projectile special struct

                lw t0, 0x02A0(v0)
                lli t1, 0x1

                beq t0, t1, shakunetsu_collision_end // if already collided, skip
                nop
                
                lli t0, 0x1
                sw t0, 0x02A0(v0)

                lli t0, 0x12
                sw t0, 0x0268(v0) // set duration to 18

                lui t0, 0x4382 // 260.0 (fp)
                sw t0, 0x0128(v0) // save new hitbox size
                
                shakunetsu_collision_end:
                addiu v0, r0, 0 // return 0 (dont destroy)
                OS.routine_end(0x20) // deallocate stackspace and return
            }

            scope hadouken_vanish: {
                OS.routine_begin(0x20) // allocate stackspace

                lw v0, 0x74(a0) // v0 = projectile physics struct
                addiu a0, v0, 0x1C // a0 = pointer to projectile position vector (1C in projectile physics struct)
                jal 0x800FF648 // efManagerDustExpandSmallMakeEffect(Vec3f *pos, f32 f_index)
                or a1, r0, r0

                lli v0, 0x1 // return 1 to destroy projectile
                OS.routine_end(0x20) // deallocate stackspace and return
            }

            Projectile.add_projectile(RYU_HADOUKEN)
            Projectile.set_projectile_hitlag_multiplier(Projectile.id.RYU_HADOUKEN, 0x3FC0) // 1.5x hitlag
            
            _blaster_projectile_struct:
            dw 0x00000000 // this has some sort of bit flag to tell it to use secondary type display list?
            dw Projectile.id.RYU_HADOUKEN
            dw Character.RYU_file_6_ptr // pointer to file
            dw 0x00000000 // 00000000
            dw 0x12480000 // rendering routine?
            dw blaster_duration // proc update
            dw 0x80175914 // proc map
            dw hadouken_vanish // proc hit
            dw hadouken_vanish // proc shield
            dw 0x8016DD2C // proc hop (shield bounce)
            dw hadouken_vanish // proc set-off
            dw blaster_reflection // proc reflector
            dw hadouken_vanish // proc absorb
            OS.copy_segment(0x103904, 0x0C) // empty 

            _blaster_shakunetsu_projectile_struct:
            dw 0x00000000 // this has some sort of bit flag to tell it to use secondary type display list?
            dw Projectile.id.RYU_HADOUKEN
            dw Character.RYU_file_6_ptr // pointer to file
            dw 0x00000000 // 00000000
            dw 0x12480000 // rendering routine?
            dw blaster_duration_shakunetsu // proc update
            dw 0x80175914 // proc map
            dw shakunetsu_collision // proc hit
            dw shakunetsu_collision // proc shield
            dw 0x8016DD2C // proc hop (shield bounce)
            dw hadouken_vanish // proc set-off
            dw blaster_reflection // proc reflector
            dw hadouken_vanish // proc absorb
            OS.copy_segment(0x103904, 0x0C) // empty 

            _blaster_shakunetsu_struct:
            dw 84 // 0x0000 - duration (int)
            float32 18 // 0x0004 - max speed
            float32 18 // 0x0008 - min speed
            float32 0 // 0x000C - gravity
            float32 0 // 0x0010 - bounce multiplier
            float32 0 // 0x0014 - rotation angle
            float32 0 // 0x0018 - initial angle (ground)
            float32 0 // 0x001C initial angle (air)
            float32 18 // 0x0020 initial speed
            dw Character.RYU_file_6_ptr // 0x0024 projectile data pointer
            dw 0 // 0x0028 unknown (default 0)
            float32 1 // 0x002C palette index (0 = mario, 1 = luigi)
            OS.copy_segment(0x1038A0, 0x30)
            
            _blaster_fireball_struct:
            dw 84 // 0x0000 - duration (int)
            float32 18 // 0x0004 - max speed
            float32 18 // 0x0008 - min speed
            float32 0 // 0x000C - gravity
            float32 0 // 0x0010 - bounce multiplier
            float32 0 // 0x0014 - rotation angle
            float32 0 // 0x0018 - initial angle (ground)
            float32 0 // 0x001C initial angle (air)
            float32 18 // 0x0020 initial speed
            dw Character.RYU_file_6_ptr // 0x0024 projectile data pointer
            dw 0 // 0x0028 unknown (default 0)
            float32 0 // 0x002C palette index (0 = mario, 1 = luigi)
            OS.copy_segment(0x1038A0, 0x30)

            _blaster_shakunetsu_heavy_struct:
            dw 54 // 0x0000 - duration (int)
            float32 52 // 0x0004 - max speed
            float32 52 // 0x0008 - min speed
            float32 0 // 0x000C - gravity
            float32 0 // 0x0010 - bounce multiplier
            float32 0 // 0x0014 - rotation angle
            float32 0 // 0x0018 - initial angle (ground)
            float32 0 // 0x001C initial angle (air)
            float32 52 // 0x0020 initial speed
            dw Character.RYU_file_6_ptr // 0x0024 projectile data pointer
            dw 0 // 0x0028 unknown (default 0)
            float32 1 // 0x002C palette index (0 = mario, 1 = luigi)
            OS.copy_segment(0x1038A0, 0x30)

            _blaster_fireball_heavy_struct:
            dw 54 // 0x0000 - duration (int)
            float32 52 // 0x0004 - max speed
            float32 52 // 0x0008 - min speed
            float32 0 // 0x000C - gravity
            float32 0 // 0x0010 - bounce multiplier
            float32 0 // 0x0014 - rotation angle
            float32 0 // 0x0018 - initial angle (ground)
            float32 0 // 0x001C initial angle (air)
            float32 52 // 0x0020 initial speed
            dw Character.RYU_file_6_ptr // 0x0024 projectile data pointer
            dw 0 // 0x0028 unknown (default 0)
            float32 0 // 0x002C palette index (0 = mario, 1 = luigi)
            OS.copy_segment(0x1038A0, 0x30)
        }
            
    // @ Description
    // Subroutine which handles air collision for neutral special actions
        scope air_collision_: {
            addiu sp, sp,-0x0018 // allocate stack space
            sw ra, 0x0014(sp) // store ra
            li a1, air_to_ground_ // a1(transition subroutine) = air_to_ground_
            jal 0x800DE6E4 // common air collision subroutine (transition on landing, no ledge grab)
            nop 
            lw ra, 0x0014(sp) // load ra
            addiu sp, sp, 0x0018 // deallocate stack space
            jr ra // return
            nop
        }
        
        // @ Description
        // Subroutine which handles ground to air transition for neutral special actions
        scope air_to_ground_: {
            addiu sp, sp,-0x0038 // allocate stack space
            sw ra, 0x001C(sp) // store ra
            sw a0, 0x0038(sp) // 0x0038(sp) = player object
            lw a0, 0x0084(a0) // a0 = player struct
            jal 0x800DEE98 // set grounded state
            sw a0, 0x0034(sp) // 0x0034(sp) = player struct
            lw v0, 0x0034(sp) // v0 = player struct
            lw a0, 0x0038(sp) // a0 = player object
            
            lw a2, 0x0008(v0) // load character ID
            lli a1, Character.id.KIRBY // a1 = id.KIRBY
            beql a1, a2, _change_action // if Kirby, load alternate action ID
            lli a1, Kirby.Action.WOLF_NSP_Ground
            lli a1, Character.id.JKIRBY // a1 = id.JKIRBY
            beql a1, a2, _change_action // if J Kirby, load alternate action ID
            lli a1, Kirby.Action.WOLF_NSP_Ground
            
            addiu a1, r0, 0x00E4 // a1 = equivalent ground action for current air action
            _change_action:
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

        // @ Description
        // Subroutine which handles movement for Marina's up special.
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
            jal 0x800D8BB4 // grounded physics subroutine
            nop
            b _end // end subroutine
            nop

            _aerial:
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

            sw r0, 0x0048(s0) // x velocity = 0
            // sw r0, 0x004C(s0) // y velocity = 0

            _check_hop:
            lwc1 f8, 0x0078(t0) // load current animation frame
            lui		at, 0x4140					// at = 12.0
            mtc1 at, f6 // ~
            c.eq.s f8, f6 // f8 == f6 (current frame == 10) ?
            nop
            bc1fl _end // skip if frame isn't 10
            nop

            lui t1, AIR_Y_SPEED // t1 = AIR_Y_SPEED
            sw t1, 0x004C(s0) // store y velocity

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
    }

    scope DSP: {
        scope Start {
            scope main: {
                OS.routine_begin(0x20)

                li a1, goto_next
                jal 0x800D9480 // ftAnimEndCheckSetStatus(GObj *fighter_gobj, void (*proc_status)(GObj*))
                nop

                OS.routine_end(0x20)
            }

            scope goto_next: {
                addiu sp, sp,-0x0040 // allocate stack space
                sw ra, 0x001C(sp) // ~
                sw a0, 0x0020(sp) // ~
                sw s0, 0x0024(sp) // store a0, s0, ra

                lw s0, 0x0084(a0) // s0 = player struct
                lw t6, 0x014C(s0) // t6 = kinetic state (0 = grounded, 1 = aerial)

                bnez t6, _aerial
                nop

                _grounded:
                lhu t0, 0x01BC(s0) // load button press buffer
                lhu t1, 0x01BE(s0) // load button hold buffer
                or t0, t0, t1 // join both so we cover press or hold
                andi t1, t0, Joypad.B // t1 = 0x40 if (B_PRESSED); else t1 = 0
                beq t1, r0, _ground_weak // skip if (!B_PRESSED)
                nop
                _grounded_strong:
                lli at, 0x3
                sw at, 0x017C(s0) // temp variable 1 (spins) = 3
                b _continue
                lli a1, Ryu.Action.DSP_H // a1(action id)

                _ground_weak:
                lli at, 0x1
                sw at, 0x017C(s0) // temp variable 1 (spins) = 1
                b _continue
                lli a1, Ryu.Action.DSP_L // a1(action id)

                _aerial:
                lli at, 0x2
                sw at, 0x017C(s0) // temp variable 1 (spins) = 2
                b _continue
                lli a1, Ryu.Action.DSP_AIR // a1(action id)

                _continue:
                lw a0, 0x0020(sp) // a0 = player object
                or a2, r0, r0 // a2(starting frame) = 0
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0x
                lli t6, 0x0001 // ~
                jal 0x800E6F24 // change action
                sw t6, 0x0010(sp) // argument 4 = 1 (continue hitbox)
                // jal 0x800E0830 // unknown common subroutine
                // lw a0, 0x0020(sp) // a0 = player object

                _end:
                lw ra, 0x001C(sp) // ~
                lw s0, 0x0024(sp) // load s0
                jr ra // return
                addiu sp, sp, 0x0040 // deallocate stack space
            }

            scope physics: {
                OS.routine_begin(0x20)
                sw s0, 0x0000(sp)

                lw s0, 0x0084(a0) // s0 = player struct
                // sw r0, 0x0048(s0) // x velocity = 0
                // sw r0, 0x004C(s0) // y velocity = 0

                lwc1 f8, 0x0078(a0) // load current animation frame
                lui at, 0x40C0 // at = 6.0
                mtc1 at, f6 // ~
                c.lt.s f8, f6 // f8 < f6 (current frame < 6.0)?
                nop
                bc1fl _move // if >= 6.0, move
                nop

                _pre:
                lw t6, 0x014C(s0) // t6 = kinetic state (0 = grounded, 1 = aerial)
                bnez t6, _aerial
                nop

                _ground:
                jal 0x800D8BB4
                nop
                b _end
                nop

                _aerial:
                lw t0, 0x4C(s0) // t0 = y velocity
                mtc1 t0, f2
                mtc1 r0, f4
                c.le.s f2, f4 // f2 <= f4 (air speed <= 0) ?
                nop
                bc1fl _aerial_continue // skip if not
                nop
                sw r0, 0x4C(s0) // t0 = y velocity = 0
                _aerial_continue:
                // jal 0x800D91EC
                // nop
                // b _end
                // nop

                _move:
                jal Loop.physics
                nop

                _end:
                lw s0, 0x0000(sp)
                OS.routine_end(0x20)
            }
        }

        scope Loop {
            scope main: {
                OS.routine_begin(0x20)

                li a1, goto_end
                jal 0x800D9480 // ftAnimEndCheckSetStatus(GObj *fighter_gobj, void (*proc_status)(GObj*))
                nop

                OS.routine_end(0x20)
            }

            scope goto_end: {
                addiu sp, sp,-0x0040 // allocate stack space
                sw ra, 0x001C(sp) // ~
                sw a0, 0x0020(sp) // ~
                sw s0, 0x0024(sp) // store a0, s0, ra

                lw s0, 0x0084(a0) // s0 = player struct

                lw at, 0x017C(s0) // at = temp variable 1 (spins)
                subiu at, at, 1 // at -= 1
                sw at, 0x017C(s0) // update temp variable 1

                bnez at, _end // if there are spins left, do not change state yet
                nop

                lw t6, 0x014C(s0) // t6 = kinetic state (0 = grounded, 1 = aerial)

                bnez t6, _aerial
                nop

                _grounded:
                b _continue
                lli a1, Ryu.Action.DSP_END // a1(action id)

                _aerial:
                b _continue
                lli a1, Ryu.Action.DSP_AIREND // a1(action id)

                _continue:
                lw a0, 0x0020(sp) // a0 = player object
                or a2, r0, r0 // a2(starting frame) = 0
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0x
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

            scope physics: {
                constant GND_SPEED(0x4220) // 40.0
                constant AIR_SPEED(0x41F0) // 30.0

                OS.routine_begin(0x20)
                sw s0, 0x0000(sp)

                lw s0, 0x0084(a0) // s0 = player struct
                lw t8, 0x014C(s0) // t8 = kinetic state

                bnez t8, _aerial
                nop
                _grounded:
                lui at, GND_SPEED
                b _set_x_speed
                nop
                _aerial:
                lui at, AIR_SPEED

                _set_x_speed:
                mtc1 at, f2 // f2 = X_SPEED
                lwc1 f4, 0x0044(s0) // ~
                cvt.s.w f4, f4 // f4 = DIRECTION
                swc1 f2, 0x0060(s0) // x velocity = X_SPEED
                mul.s f2, f2, f4 // f2 = X_SPEED * DIRECTION
                swc1 f2, 0x0048(s0) // x velocity = X_SPEED * DIRECTION

                bnez t8, _air_routine
                nop

                _ground_routine:
                // jal 0x800D8BB4 // no ground friction
                nop
                b _end
                nop

                _air_routine:
                or a0, r0, s0
                jal 0x800D9074 // ftPhysicsApplyAirVelXFriction(FTStruct *fp, FTAttributes *attr)
                lw a1, 0x09C8(s0) // a1 = attribute pointer

                or a0, r0, s0
                lui a1, 0x4000 // 2.0
                jal 0x800D8D68 // ftPhysicsApplyGravityClampTVel(FTStruct *fp, f32 gravity, f32 tvel)
                lui a2, 0x4100 // 8.0

                _end:
                lw s0, 0x0000(sp)
                OS.routine_end(0x20)
            }
        }

        scope End {
            scope physics: {
                OS.routine_begin(0x20)
                sw s0, 0x0000(sp)

                lw s0, 0x0084(a0) // s0 = player struct

                lwc1 f8, 0x0078(a0) // load current animation frame
                lui at, 0x4120 // at = 10.0
                mtc1 at, f6 // ~
                c.lt.s f8, f6 // f8 < f6 (current frame < 10.0)?
                nop
                bc1tl _move // if < 10.0, move
                nop

                _pre:
                lw t6, 0x014C(s0) // t6 = kinetic state (0 = grounded, 1 = aerial)
                bnez t6, _aerial
                nop

                _ground:
                jal 0x800D8BB4
                nop
                b _end
                nop

                _aerial:
                jal 0x800D90E0
                nop
                b _end
                nop

                _move:
                jal Loop.physics
                nop

                _end:
                lw s0, 0x0000(sp)
                OS.routine_end(0x20)
            }
        }
    }
}