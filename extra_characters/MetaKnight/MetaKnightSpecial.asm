
scope MetaKnightSpecial: {
    scope OnActionChanged: {
        OS.routine_begin(0x20)

        lw a0, 0x4(a0) // a0 = player object
        lw s0, 0x84(a0) // s0 = player struct

        sw a0, 0x18(sp) // save player object

        _check_wing_carryover_action:
        // a1 = new action id
        // Aerial attacks
        lli t0, Action.AttackAirN
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.AttackAirF
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.AttackAirB
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.AttackAirU
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.AttackAirD
        beq a1, t0, _load_previous_wing_state
        // Fall states
        lli t0, Action.Fall
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.FallSpecial
        beq a1, t0, _load_previous_wing_state
        // Landing states
        lli t0, Action.LandingLight
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.LandingHeavy
        beq a1, t0, _load_previous_wing_state
        // Aerial damage states
        lli t0, Action.DamageAir1
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.DamageAir2
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.DamageAir3
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.DamageFlyHigh
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.DamageFlyLow
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.DamageFlyMid
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.WallBounce
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.Tumble
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.DamageFlyRoll
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.DamageFlyTop
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.DamageElec1
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.DamageElec2
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.FalconDivePulled
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.RayGunShootAir
        beq a1, t0, _load_previous_wing_state
        lli t0, Action.FireFlowerShootAir
        beq a1, t0, _load_previous_wing_state
        nop
        
        b _save_wing_state // no action matched
        nop

        _save_wing_state:
        // check if first wing part is active
        addiu at, r0, -1
        sw at, 0xAE4(s0) // first set wing state to hidden

        lli t0, 0x1E // t0 = first wing bone
        sll t0, t0, 0x2
        addu t0, s0, t0 // t0 = bone pointer in the player struct
        lw t0, 0x8e8(t0) // t0 = bone struct

        beqz t0, _end // if bone doesn't exist, skip
        nop

        lw at, 0x50(t0) // load render state
        b _end
        sw at, 0xAE4(s0) // save current wing state and exit

        _load_previous_wing_state:
        lw a2, 0xAE4(s0) // load wing state from player struct

        jal 0x800E8C70 // void ftParamSetModelPartID(GObj *fighter_gobj, s32 joint_id, s32 modelpart_id)
        lli a1, 0x1E

        lw a0, 0x18(sp) // restore player object
        jal 0x800E8C70 // void ftParamSetModelPartID(GObj *fighter_gobj, s32 joint_id, s32 modelpart_id)
        lli a1, 0x1F

        lw a0, 0x18(sp) // restore player object
        jal 0x800E8C70 // void ftParamSetModelPartID(GObj *fighter_gobj, s32 joint_id, s32 modelpart_id)
        lli a1, 0x20

        lw a0, 0x18(sp) // restore player object
        jal 0x800E8C70 // void ftParamSetModelPartID(GObj *fighter_gobj, s32 joint_id, s32 modelpart_id)
        lli a1, 0x21

        _end:
        OS.routine_end(0x20)
    }

    // Set on_action_changed function
    Character.table_patch_start(on_action_changed, Character.id.METAKNIGHT, 0x4)
    dw OnActionChanged
    OS.patch_end()

    scope Jab: {
        scope Start: {
            scope update: {
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

                _continue:
                lw a0, 0x0020(sp) // a0 = player object
                lli a1, MetaKnight.Action.JAB_LOOP // a1(action id)
                or a2, r0, r0 // a2(starting frame) = 0.0
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
                jal 0x800E6F24 // change action
                sw r0, 0x0010(sp) // argument 4 = 0

                // set tmp variable 1 (is_first_run) to 1
                lw a0, 0x0020(sp) // load player object
                lw t0, 0x84(a0) // t0 = player struct
                lli at, 0x1
                sw at, 0x17C(t0) // temp variable 1 = 1

                // On first loop, do not apply recoil
                // li at, MetaKnightSpecial.Jab.Loop.recoil
                // sw at, 0x09F4(t0) // on hit shield function = recoil
                // sw at, 0x09F8(t0) // on hit function = recoil

                _end:
                lw ra, 0x001C(sp) // ~
                jr ra // return
                addiu sp, sp, 0x0040 // deallocate stack space
            }
        }

        scope Loop: {
            scope update: {
                OS.routine_begin(0x20)

                sw a0, 0x18(sp)
                lw s0, 0x84(a0) // s0 = player struct

                scope cancel_logic: {
                    lw at, 0x17C(s0) // at = tmp variable 1 = is_first_run
                    bnez at, end // if is first run, skip cancel logic
                    nop

                    lh t0, 0x01BC(s0) // get button held
                    andi t0, t0, Joypad.A // check if A held
                    bnez t0, end // if A is held, skip
                    nop
                    jal goto_end // go to final part
                    nop
                    b _end // skip the rest
                    nop

                    end:
                }

                _check_animation_end:
                li a1, loop
                jal 0x800D9480 // ftAnimEndCheckSetStatus(GObj *fighter_gobj, void (*proc_status)(GObj*))
                lw a0, 0x18(sp)

                _end:
                OS.routine_end(0x20)
            }

            scope recoil: {
                OS.routine_begin(0x20)

                sw a0, 0x18(sp)
                lw s0, 0x84(a0) // s0 = player struct

                lw t0, 0x44(s0) // t0 = facing direction
                
                lui at, 0x4170 // 15.0
                mtc1 at, f2 // f2 = speed to add

                bltz at, _apply_speed // if facing left, apply the positive value as it
                nop
                neg.s f2, f2 // if facing right, we're applying a negative value instead
                _apply_speed:
                lwc1 f4, 0x60(s0) // f4 = current ground x speed
                add.s f4, f4, f2 // apply speed
                swc1 f4, 0x60(s0) // save ground speed x back

                OS.routine_end(0x20)
            }
        
            scope loop: {
                addiu sp, sp,-0x0040 // allocate stack space
                sw ra, 0x001C(sp) // ~
                sw a0, 0x0020(sp) // ~

                _continue:
                lw a0, 0x0020(sp) // a0 = player object
                lli a1, MetaKnight.Action.JAB_LOOP // a1(action id)
                or a2, r0, r0 // a2(starting frame) = 0.0
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
                jal 0x800E6F24 // change action
                sw r0, 0x0010(sp) // argument 4 = 0

                // set tmp variable 1 (is_first_run) to 0
                lw a0, 0x0020(sp) // load player object
                lw t0, 0x84(a0) // t0 = player struct
                sw r0, 0x17C(t0) // temp variable 1 = 0

                li at, MetaKnightSpecial.Jab.Loop.recoil
                sw at, 0x09F4(t0) // on hit shield function = recoil
                sw at, 0x09F8(t0) // on hit function = recoil

                _end:
                lw ra, 0x001C(sp) // ~
                jr ra // return
                addiu sp, sp, 0x0040 // deallocate stack space
            }

            scope goto_end: {
                addiu sp, sp,-0x0040 // allocate stack space
                sw ra, 0x001C(sp) // ~
                sw a0, 0x0020(sp) // ~

                _continue:
                lw a0, 0x0020(sp) // a0 = player object
                lli a1, MetaKnight.Action.JAB_END // a1(action id)
                or a2, r0, r0 // a2(starting frame) = 0.0
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
                jal 0x800E6F24 // change action
                sw r0, 0x0010(sp) // argument 4 = 0

                _end:
                lw ra, 0x001C(sp) // ~
                jr ra // return
                addiu sp, sp, 0x0040 // deallocate stack space
            }
        }
    }

    scope TiltF: {
        // tmp variable 3 0x0184 -- used to check if A was ever pressed down during the move
        scope update: {
            OS.routine_begin(0x20)
            sw a0, 0x18(sp)

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
            andi t2, t1, Joypad.A // t2 = 0x80 if A is pressed; else t2 = 0
            bne t2, r0, register_press // if A is pressed
            nop

            b check_transition
            nop

            register_press:
            lli t0, 0x1
            sw t0, 0x0184(v0)

            b check_transition
            nop

            check_transition:
            lw t0, 0x0184(v0) // was A ever pressed during the move?
            beq t0, r0, check_animation_end // If not, skip everything
            nop

            set_cancel_window:
            lw t2, 0x24(v0) // t2 = current action

            lli at, Action.FTilt
            beq t2, at, check_frame
            lui t1, 0x4120 // t1 = 11.0F
            lui t1, 0x40E0 // t1 = 7.0F

            check_frame:
            lw t0, 0x0078(a0) // t0 = current animation frame
            mtc1 t0, f6
            mtc1 t1, f8
            c.lt.s  f8, f6
            nop
            bc1fl check_animation_end // can't cancel yet
            nop

            // all conditions are met
            lli at, Action.FTilt
            beq t2, at, apply_cancel
            lli a1, MetaKnight.Action.TILTF2 // a1 = action to switch to
            lli a1, MetaKnight.Action.TILTF3 // a1 = action to switch to

            apply_cancel:
            addiu sp, sp, -0x40 // allocate stack space
            sw ra, 0x001C(sp)
            sw a0, 0x0020(sp)
            
            or a2, r0, r0 // a2(starting frame) = 0.0
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            jal 0x800E6F24 // change action
            sw r0, 0x0010(sp) // argument 4 = 0
            jal 0x800E0830 // unknown common subroutine
            lw a0, 0x20(sp) // a0 = player object
            
            lw ra, 0x001C(sp)
            lw a0, 0x0020(sp)
            addiu sp, sp, 0x40 // deallocate stack space

            OS.routine_end(0x20)

            check_animation_end:
            jal 0x800D94C4 // check animation end
            lw a0, 0x18(sp)

            OS.routine_end(0x20)
        }
    }

    scope USP: {
        scope air_initial: {
            OS.routine_begin(0x20)

            sw a0, 0x0020(sp) // save player object

            // change action
            sw r0, 0x0010(sp) // argument 4 = 0
            lli a1, MetaKnight.Action.USP_AIR_START // a1 = Action.USPA
            or a2, r0, r0 // a2 = float: 0.0
            jal 0x800E6F24 // change action
            lui a3, 0x3F80 // a3 = float: 1.0

            lw a0, 0x0020(sp) // a0 = player object
            lw a0, 0x0084(a0) // a0 = player struct

            // tmp variable 1 (root bone rotation) = 0
            sw r0, 0x17C(a0) // temp variable 1 = 0

            // take mid-air jumps away at this point
            lw t0, 0x9C8(a0) // t0 = attribute pointer
            lw t0, 0x64(t0) // t0 = max jumps
            sb t0, 0x148(a0) // jumps used = max jumps

            OS.routine_end(0x20)
        }

        // @ Description
        // Subroutine which runs when Marina initiates a grounded up special.
        // Changes action, and sets up initial variable values.
        scope ground_initial: {
            OS.routine_begin(0x20)

            sw a0, 0x0020(sp) // save player object

            // change action
            sw r0, 0x0010(sp) // argument 4 = 0
            lli a1, MetaKnight.Action.USP // a1 = Action.USPA
            or a2, r0, r0 // a2 = float: 0.0
            jal 0x800E6F24 // change action
            lui a3, 0x3F80 // a3 = float: 1.0

            // tmp variable 1 (root bone rotation) = 0
            lw a0, 0x0020(sp) // a0 = player object
            lw a0, 0x0084(a0) // a0 = player struct
            sw r0, 0x17C(a0) // temp variable 1 = 0

            // take mid-air jumps away at this point
            lw t0, 0x9C8(a0) // t0 = attribute pointer
            lw t0, 0x64(t0) // t0 = max jumps
            sb t0, 0x148(a0) // jumps used = max jumps

            OS.routine_end(0x20)
        }

        scope air_start_update: {
            OS.routine_begin(0x20)
            li a1, air_goto_next
            jal 0x800D9480 // ftAnimEndCheckSetStatus(GObj *fighter_gobj, void (*proc_status)(GObj*))
            nop
            OS.routine_end(0x20)
        }

        scope air_goto_next: {
            addiu sp, sp,-0x0040 // allocate stack space
            sw ra, 0x001C(sp) // ~
            sw a0, 0x0020(sp) // ~

            _continue:
            lw a0, 0x0020(sp) // a0 = player object
            lli a1, MetaKnight.Action.USP_AIR // a1(action id)
            lui a2, 0x40C0 // a2(starting frame) = 6.0
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0x
            jal 0x800E6F24 // change action
            sw r0, 0x0010(sp) // argument 4 = 0
            jal 0x800E0830 // runs 1 frame to get the hitbox out
            lw a0, 0x0020(sp) // a0 = player object

            _end:
            lw ra, 0x001C(sp) // ~
            jr ra // return
            addiu sp, sp, 0x0040 // deallocate stack space
        }

        scope main: {
            OS.routine_begin(0x20)

            scope check_animation_end: {
                // check if animation has ended (frame<=0.0)
                lwc1 f6, 0x78(a0) // f6 = current animation frame (float)
                mtc1 r0, f4 // f4 = 0
                c.le.s f6, f4 // current animation frame <= 0?
                nop
                bc1f _skip // if not, skip
                nop

                addiu sp, sp, -0x30
                lui a1, 0x3F00 // air drift = 0.5F
                lli a2, 0x1 // unknown and unused variable = true
                lli a3, 0x1 // is_fall_accelerate (can fastfall) = true
                lli at, 0x1
                sw at, 0x10(sp) // is_goto_landing (land into specialfall) = true
                lui at, 0x3F80
                sw at, 0x14(sp) // landing_lag (speed multiplier on animation) = 1.0F
                jal 0x801438F0 // ftCommonFallSpecialSetStatus(GObj *fighter_gobj, f32 drift, sb32 unknown, sb32 is_fall_accelerate, sb32 is_goto_landing, f32 landing_lag, sb32 is_allow_interrupt)
                sw r0, 0x18(sp) // is_allow_interrupt = false
                b _end
                addiu sp, sp, 0x30

                _skip:
            }

            _end:
            OS.routine_end(0x20)
        }

        scope collision: {
            OS.routine_begin(0x20)

            lw a1, 0x84(a0) // a1 = fighter struct

            lw t0, 0x14c(a1) // t0 = grounded status
            beqz t0, _grounded
            nop

            scope _aerial: {
                lw at, 0x78(a0) //  ~
                mtc1 at, f2 // f2 = current animation frame
                // Before frame 13, ignore landing completely
                lui at, 0x4150 // ~
                mtc1 at, f4 // f4 = 13.0
                c.lt.s f2, f4
                nop
                bc1t _no_landing
                nop
                // From frames 13 to 28, ignore soft platform collisions (drop-through)
                lui at, 0x41E0 // ~
                mtc1 at, f4 // f4 = 28.0
                c.le.s f2, f4
                nop
                bc1f _collide_with_platforms
                nop
                // frame 29+, check for landing
                _ignore_platforms:
                // Ignore soft platform/pass-through/droppable collisions
                lw at, 0xEC(a1) // Clipping below player (projected down, not necessarily standing on it)
                b _apply_air_collisions
                sw at, 0x144(a1) // Set clipping to ignore

                _collide_with_platforms:
                addiu at, r0, -1 // set 'ignore clipping id' to -1 (null)
                b _apply_air_collisions
                sw at, 0x144(a1) // Set clipping to ignore

                _apply_air_collisions:
                li a1, air_to_ground  // a1 (transition subroutine) = air_to_ground
                jal 0x800DE80C // mpCommonProcFighterCliff(GObj *fighter_gobj, void (*proc_map)(GObj*)) air collision subroutine (transition on landing, allows ledge grab)
                nop
                b _end
                nop

                _no_landing:
                jal 0x800DE87C
                nop
                b _end
                nop
            }

            scope _grounded: {
                jal 0x800DDF44 // grounded subroutine - do not fall from ledges
                nop
                b _end
                nop
            }

            _end:
            OS.routine_end(0x20)
        }

        scope air_to_ground: {
            OS.routine_begin(0x20)
            lli a1, OS.FALSE // is_allow_interrupt = false
            jal 0x80142E3C // ftCommonLandingFallSpecialSetStatus(GObj *fighter_gobj, sb32 is_allow_interrupt, f32 anim_speed)
            lui a2, 0x3F80 // a2 = anim_speed = 1.0F
            OS.routine_end(0x20)
        }

        scope physics: {
            OS.routine_begin(0x20)
            sw a0, 0x4(sp) // save player object

            lw a1, 0x84(a0) // a1 = fighter struct

            // // From frames 7 to 48, apply root motion
            lw at, 0x78(a0) //  ~
            mtc1 at, f2 // f2 = current animation frame
            lui at, 0x40E0 // ~
            mtc1 at, f4 // f4 = 7.0
            c.le.s f2, f4
            nop
            bc1t _grounded // before frame 7 we're still grounded
            nop
            lui at, 0x4240 // ~
            mtc1 at, f4 // f4 = 48.0
            c.le.s f2, f4
            nop
            bc1f _normal_aerial
            nop

            _root_motion:
            // apply root motion
            jal 0x800D93E4 // ftPhysicsApplyAirVelTransNAll(GObj *fighter_gobj)
            nop
            b _end
            nop

            _normal_aerial:
            // normal air drift
            jal 0x800D90E0 // ftPhysicsApplyAirVelDrift(GObj *fighter_gobj)
            nop
            b _end
            nop

            scope _grounded: {
                // normal ground friction
                jal 0x800D8BB4 // ftPhysicsApplyGroundVelFriction(GObj *fighter_gobj)
                nop

                _ground_to_air:
                // on frame 7, set aerial state
                lw a0, 0x4(sp) // restore a0 = player object
                lw at, 0x78(a0)
                mtc1 at, f2 // f2 = current animation frame
                lui at, 0x40E0 // ~
                mtc1 at, f4 // f4 = 7.0
                c.eq.s f2, f4
                nop
                bc1f _end // only run on frame 7
                nop
                jal 0x800DEEC8 // mpCommonSetFighterAir(FTStruct *fp)
                lw a0, 0x84(a0) // a0 = player struct
            }

            _end:
            OS.routine_end(0x20)
        }

        scope interrupt: {
            OS.routine_begin(0x20)
            lw a1, 0x84(a0) // a1 = fighter struct

            // based on Mario's usp control, here we rotate the model based on stick X
            scope _rotate_model: {
                lw at, 0x78(a0) //  ~
                mtc1 at, f2 // f2 = current animation frame
                lui at, 0x40E0 // ~
                mtc1 at, f4 // f4 = 7.0
                c.eq.s f2, f4
                nop
                bc1f _end // only run on frame 7
                nop

                // stick_x = ABS(fp->input.stick_angle.x, 0);
                lb v1, 0x1C2(a1) // v1 = stick_x
                or v0, r0, v1 // v0 = stick_x
                bltzl v0, pc()+0x8
                negu v0, v0
                // if (stick_x > FTMARIO_SUPERJUMP_TURN_STICK_THRESHOLD)
                slti at, v0, 50
                bnezl at, _end
                nop
                // stick_x = (fp->input.stick_angle.x > 0) ? FTMARIO_SUPERJUMP_TURN_STICK_THRESHOLD : -FTMARIO_SUPERJUMP_TURN_STICK_THRESHOLD;
                addiu v0, r0, 50
                blezl v1, pc()+0x8 
                addiu v0, r0, -50
                // rot_z (f0) = ((fp->input.stick_angle.x - stick_x) * FTMARIO_SUPERJUMP_AIR_DRIFT(0.6F));
                subu t7, v1, v0
                mtc1 t7, f4
                li at, 0x3F19999A // at = 0.6
                mtc1 at, f8
                cvt.s.w f6, f4
                mul.s f0, f6, f8
                // rot_z(f0) = -((rot_z(f0) * PI32) / 180.0F);
                lui at, 0x8019
                lwc1 f10, 0xC688(at) // f10 = PI32
                lui at, 0x4334 // 180.0
                mtc1 at, f18 // f18 = 180.0
                mul.s f16, f0, f10
                div.s f0, f16, f18
                neg.s f0, f0
                // stick_rot = ABSF(rot_z);
                abs.s f14, f0
                // joint_rot = ABSF(fp->joints[nFTPartsJointTransN]->rotate.vec.f.z);
                lw v0, 0x8EC(a1) // v0 = fp->joints[nFTPartsJointTransN] = first joint
                lwc1 f2, 0x38(v0) // f2 = joint rotation z
                abs.s f12, f2
                // if (joint_rot < stick_rot)
                c.lt.s f12, f14
                nop
                bc1fl _end
                nop
                // fp->joint[1]->rotate.z = rot_z;
                swc1 f0, 0x38(v0)
                swc1 f0, 0x17C(a1) // save rotation to tmp variable 1
                _end:
            }

            _apply_rotation:
            // we use tmp variable 1 to save and re-apply rotation every frame
            // this is a fix for the animation itself rotating it back
            // re-apply saved rotation from tmp variable 1
            lw v0, 0x8EC(a1) // v0 = fp->joints[nFTPartsJointTransN] = first joint
            lw at, 0x17C(a1) // at = temp variable 1 (saved rotation)
            sw at, 0x38(v0) // apply rotation

            _end:
            OS.routine_end(0x20)
        }
    }

    scope NSP: {
        scope air_initial: {
            OS.routine_begin(0x20)

            sw a0, 0x0020(sp) // save player object

            // change action
            sw r0, 0x0010(sp) // argument 4 = 0
            lli a1, MetaKnight.Action.TORNADO_START // a1 = Action
            or a2, r0, r0 // a2 = float: 0.0
            jal 0x800E6F24 // change action
            lui a3, 0x3F80 // a3 = float: 1.0

            // set tmp variable 1 (rotation speed) to 130.0
            lw a0, 0x0020(sp) // load player object
            lw t0, 0x84(a0) // t0 = player struct
            lui at, 0x4302 // 130.0
            sw at, 0x17C(t0) // temp variable 1 = 130.0
            sw r0, 0x0B30(t0) // temp variable 2 = 0 (mash cooldown)

            // set X speed to 0
            lw a0, 0x0020(sp) // a0 = player object
            lw a0, 0x0084(a0) // a0 = player struct
            sw r0, 0x0048(a0) // x velocity = 0

            // take mid-air jumps away at this point
            lw t0, 0x9C8(a0) // t0 = attribute pointer
            lw t0, 0x64(t0) // t0 = max jumps
            sb t0, 0x148(a0) // jumps used = max jumps

            // set Y speed to 1/2 current speed
            lwc1 f2, 0x4C(a0) // f2 = y speed
            lui at, 0x3ECC // at = ~0.4
            mtc1 at, f4 // f4 = ~0.4
            mul.s f2, f2, f4 // y speed *= ~0.4
            swc1 f2, 0x4C(a0) // save y speed

            mtc1 r0, f0
            c.lt.s f2, f0 // if yspeed < 0
            nop
            bc1t _end // skip initial hop
            sw r0, 0x4C(a0) // yspeed = 0

            // apply initial hop if not going down
            lui at, 0x41F0 // ~
            mtc1 at, f4 // f4 = 30.0
            add.s f2, f2, f4 // y speed += hop
            swc1 f2, 0x4C(a0) // save y speed

            _end:
            OS.routine_end(0x20)
        }

        scope ground_initial: {
            OS.routine_begin(0x20)

            sw a0, 0x0020(sp) // save player object

            jal 0x800DEEC8 // set aerial state
            lw a0, 0x84(a0) // a0 = player struct

            // change action
            lw a0, 0x0020(sp) // a0 = player object
            sw r0, 0x0010(sp) // argument 4 = 0
            lli a1, MetaKnight.Action.TORNADO_START // a1 = Action
            or a2, r0, r0 // a2 = float: 0.0
            jal 0x800E6F24 // change action
            lui a3, 0x3F80 // a3 = float: 1.0

            // set tmp variable 1 (rotation speed) to 130.0
            lw a0, 0x0020(sp) // load player object
            lw t0, 0x84(a0) // t0 = player struct
            lui at, 0x4302 // 130.0
            sw at, 0x17C(t0) // temp variable 1 = 130.0
            sw r0, 0x0B30(t0) // temp variable 2 = 0 (mash cooldown)

            // reset x speed
            sw r0, 0x48(t0) // x velocity = 0

            // add a Y speed hop
            lui at, 0x41F0 // at = 30.0
            sw at, 0x4C(t0) // save y speed

            // take mid-air jumps away at this point
            lw t1, 0x9C8(t0) // t1 = attribute pointer
            lw t1, 0x64(t1) // t1 = max jumps
            sb t1, 0x148(t0) // jumps used = max jumps

            OS.routine_end(0x20)
        }

        scope Start: {
            scope update: {
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

                _continue:
                lw a0, 0x0020(sp) // a0 = player object
                lli a1, MetaKnight.Action.TORNADO_LOOP // a1(action id)
                or a2, r0, r0 // a2(starting frame) = 0.0
                lui a3, 0x4302 // a3(frame speed multiplier) = 130
                jal 0x800E6F24 // change action
                sw r0, 0x0010(sp) // argument 4 = 0

                _end:
                lw ra, 0x001C(sp) // ~
                jr ra // return
                addiu sp, sp, 0x0040 // deallocate stack space
            }
        }

        scope Loop: {
            scope update: {
                OS.routine_begin(0x20)

                sw a0, 0x18(sp) // save a0

                lw s0, 0x84(a0) // s0 = player struct
                lwc1 f2, 0x17C(s0) // f2 = temp variable 1 (rotation speed)

                lw t1, 0x1C(s0) // t1 = current frame (int)

                // if frame < 60, can mash
                lli t0, 60
                blt t1, t0, _can_mash
                nop
                b _cannot_mash
                nop

                scope _can_mash: {
                    // decrease rotation speed by 2.0 every frame
                    lui at, 0x4000 // at = 2.0
                    mtc1 at, f4 // f4 = 2.0
                    sub.s f2, f2, f4 // f2 = f2 - 2.0
                    swc1 f2, 0x17C(s0) // update temp variable

                    _mash_cooldown_check:
                    lw at, 0x0B30(s0) // at = temp variable 2 (mash cooldown)
                    addiu at, at, -1 // at = at - 1
                    sw at, 0x0B30(s0) // update mash cooldown

                    bgtz at, _can_mash_end // if mash cooldown > 0, skip
                    nop

                    lh t0, 0x01BE(s0) // get button pressed
                    andi t0, t0, Joypad.B // check if B pressed
                    beqz t0, _can_mash_end // if not pressed, skip
                    nop

                    _b_pressed:
                    // set mash cooldown to 4 frames
                    lli at, 4
                    sw at, 0x0B30(s0) // save mash cooldown

                    // increase rotation speed by 7.0
                    lui at, 0x40E0 // at = 7.0
                    mtc1 at, f4 // f4 = 7.0
                    add.s f2, f2, f4 // f2 = f2 + 7.0
                    swc1 f2, 0x17C(s0) // update temp variable

                    li a1, 0x41D00000 // arg1 = velocity = 26
                    li a2, 0x42080000 // arg2 = clamp = 36
                    
                    jal 0x800D8D34 // ftPhysicsAddClampAirVelY(FTStruct *fp, f32 vel, f32 clamp)
                    lw a0, 0x84(a0) // arg0 = player struct
                    lw a0, 0x18(sp) // restore a0

                    _can_mash_end:
                    b _sfx
                    nop
                }

                scope _cannot_mash: {
                    // decrease rotation speed by 3.0 every frame
                    lui at, 0x4040 // at = 3.0
                    mtc1 at, f4 // f4 = 3.0
                    sub.s f2, f2, f4 // f2 = f2 - 3.0
                    swc1 f2, 0x17C(s0) // update temp variable
                }

                _sfx:
                lwc1 f4, 0x78(a0) // f4 = current animation frame
                lwc1 f6, 0x17C(s0) // f2 = temp variable 1 (rotation speed)
                
                // if current frame <= rotation speed, we just completed a full circle
                c.le.s f4, f6
                nop
                bc1f _ground_gfx // still not ended
                nop

                jal 0x800269C0 // play FGM
                lli a0, 0x104 // FGM id 104 (weak), 103 (mid), 102 (strong)

                scope _ground_gfx: {
                    lw at, 0x1C(s0) // at = current frame (int)
                    andi at, at, 0x0007 // at = frame % 8
                    bnez at, _end
                    nop

                    lhu t0, 0xCC(s0) // a1 = collision flags
                    andi t0, t0, Surface.GROUND // t0 = collision flags & GROUND
                    beqz t0, _end // if not touching ground, skip
                    nop

                    addiu sp, sp, -0x50
                    sw a0, 0x14(sp)
                    sw a1, 0x18(sp)
                    sw s0, 0x1C(sp)

                    // build a vector 3 structure on 0x4(sp)
                    lw at, 0x78(s0) // at = position vec3

                    lwc1 f2, 0x0(at) // f2 = player X
                    lwc1 f4, 0x44(s0) // f4 = facing direction
                    cvt.s.w f4, f4 // f4 = facing direction (float)
                    lui t0, 0xC2A0 // -80.0f
                    mtc1 t0, f6 // f6 = -80
                    mul.s f4, f4, f6 // f4 = offset * facing direction
                    add.s f2, f2, f4
                    swc1 f2, 0x4(sp) // save X

                    lwc1 f4, 0x4(at) // f4 = player Y
                    lui t0, 0xC2A0 // -80.0f
                    mtc1 t0, f2 // f2 = -80
                    add.s f4, f4, f2 // f4 = player Y - 80
                    swc1 f4, 0x8(sp) // save Y

                    sw r0, 0xC(sp) // save Z = 0

                    addiu a0, sp, 0x4 // a0 (position) = pointer to vector we created

                    addiu sp, sp, -0x20
                    lw a1, 0x44(s0) // a1 = facing direction
                    subu a1, r0, a1 // a1 = -facing direction
                    jal 0x800FF3F4 // efManagerDustHeavyDoubleMakeEffect(Vec3f *pos, s32 lr, f32 f_index)
                    lui a2, 0x3F80 // a2 = 1.0F
                    addiu sp, sp, 0x20

                    lw a0, 0x14(sp)
                    lw a1, 0x18(sp)
                    lw s0, 0x1C(sp)
                    addiu sp, sp, 0x50

                    _end:
                }

                _set_fsm:
                lw a0, 0x18(sp) // a0 = player object
                jal 0x8000BB04 // gcSetAnimSpeed(fighter_gobj, speed)
                lw a1, 0x17C(s0) // f2 = temp variable 1 (rotation speed)

                _check_end:
                // if rotation speed <= 60, end move
                lw a0, 0x18(sp) // a0 = player object
                lw s0, 0x84(a0) // s0 = player struct
                lwc1 f2, 0x17C(s0) // f2 = temp variable 1 (rotation speed)

                lui at, 0x4270 // at = 60.0
                mtc1 at, f4 // f4 = 60.0
                c.le.s f2, f4
                nop
                bc1f _end // still not ended
                nop

                _goto_end:
                jal goto_next
                lw a0, 0x18(sp) // a0 = player object

                _end:
                lw a0, 0x18(sp) // restore a0
                OS.routine_end(0x20)
            }

            scope goto_next: {
                addiu sp, sp,-0x0040 // allocate stack space
                sw ra, 0x001C(sp) // ~
                sw a0, 0x0020(sp) // ~

                lw t0, 0x84(a0) // t0 = player struct
                lwc1 f2, 0x48(t0) // f2 = x velocity
                lui at, 0x4000 // at = 2.0
                mtc1 at, f4 // f4 = 2.0
                div.s f2, f2, f4 // f2 = x velocity / 2.0
                swc1 f2, 0x48(t0) // x velocity = x velocity / 2.0

                _continue:
                lw a0, 0x0020(sp) // a0 = player object
                lli a1, MetaKnight.Action.TORNADO_END_AIR // a1(action id)
                or a2, r0, r0 // a2(starting frame) = 0.0
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
                jal 0x800E6F24 // change action
                sw r0, 0x0010(sp) // argument 4 = 0

                _end:
                lw ra, 0x001C(sp) // ~
                jr ra // return
                addiu sp, sp, 0x0040 // deallocate stack space
            }

            scope physics: {
                OS.routine_begin(0x20)
                sw a0, 0x18(sp)
                lw s0, 0x84(a0)  // s0 = player struct

                _gravity:
                lui a1, 0x3F80 // arg1 = gravity = 1.0
                lui a2, 0x4140 // arg2 = (terminal) max fall speed = 12.0
                jal 0x800D8D68 // ftPhysicsApplyGravityClampTVel(FTStruct *fp, f32 gravity, f32 tvel)
                lw a0, 0x84(a0) // arg0 = player struct
                lw a0, 0x18(sp) // restore a0
                
                _control_x:
                lw at, 0x8AC(s0) // current moveset script
                beqz at, _slow // if not, we're in the slow portion
                nop

                _fast:
                or a1, r0, r0 // arg2 = min stick X
                li a2, 0x3E99999A // arg3 (accel) = 0.3
                li a3, 0x42A00000 // arg4 (max speed) = 80
                b _control_x_apply
                nop

                _slow:
                or a1, r0, r0 // arg2 = min stick X
                li a2, 0x3D75C28F // arg3 (accel) = 0.06
                li a3, 0x42700000 // arg4 (max speed) = 60

                _control_x_apply:
                jal 0x800D8FC8 // ftPhysicsClampAirVelXStickRange(FTStruct *fp, s32 stick_x_min, f32 vel, f32 clamp)
                lw a0, 0x84(a0) // arg0 = player struct
                lw a0, 0x18(sp) // restore a0

                _friction:
                lw a0, 0x84(a0) // arg0 = player struct
                jal 0x800D9074 // ftPhysicsApplyAirVelXFriction(FTStruct *fp, FTAttributes *attr)
                lw a1, 0x9C8(a0) // arg1 = player attributes
                lw a0, 0x18(sp) // restore a0

                _end:
                OS.routine_end(0x20)
            }

            scope collision: {
                OS.routine_begin(0x20)
                sw a0, 0x18(sp) // save a0

                jal 0x800DE87C // mpCommonCheckFighterCeilHeavyCliff(GObj *fighter_gobj)
                nop

                _reflect_on_walls:
                lw a0, 0x18(sp) // restore a0
                lw s0, 0x84(a0)  // s0 = player struct
                lh t0, 0xCE(s0) // t0 = collision flags
                andi t0, t0, Surface.WALL // t0 = collision flags & WALL
                beqz t0, _end // if not touching wall, skip
                nop
                lui at, 0xC000 // at = -2.0
                mtc1 at, f4 // f4 = -2.0
                lwc1 f2, 0x60(s0) // f2 = current ground x speed
                mul.s f2, f2, f4 // f2 = ground speed * -2.0
                swc1 f2, 0x60(s0) // save ground speed x back
                lwc1 f2, 0x48(s0) // f2 = current air speed x
                mul.s f2, f2, f4 // f2 = ground speed * -2.0
                swc1 f2, 0x48(s0) // save air speed x back

                _end:
                OS.routine_end(0x20)
            }
        }

        scope End: {
            scope air_collision: {
                addiu   sp, sp,-0x0018              // allocate stack space
                sw      ra, 0x0014(sp)              // store ra
                li      a1, air_to_ground           // a1(transition subroutine) = air_to_ground
                jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
                nop
                lw      ra, 0x0014(sp)              // load ra
                addiu   sp, sp, 0x0018              // deallocate stack space
                jr      ra                          // return
                nop
            }

            scope air_to_ground: {
                addiu   sp, sp,-0x0038              // allocate stack space
                sw      ra, 0x001C(sp)              // store ra
                sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
                lw      a0, 0x0084(a0)              // a0 = player struct
                jal     0x800DEE98                  // set grounded state
                sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
                lw      v0, 0x0034(sp)              // v0 = player struct
                lw      a0, 0x0038(sp)              // a0 = player object

                addiu   a1, r0, MetaKnight.Action.TORNADO_END
                _change_action:
                lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
                lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1
                jal     0x800E6F24                  // change action
                nop
                lw      ra, 0x001C(sp)              // load ra
                addiu   sp, sp, 0x0038              // deallocate stack space
                jr      ra                          // return
                nop
            }
        }
    }

    scope DSP: {
        // @ Description
        // Subroutine which runs when Marina initiates a grounded up special.
        // Changes action, and sets up initial variable values.
        scope ground_initial: {
            OS.routine_begin(0x20)

            sw a0, 0x0020(sp) // save player object

            // change action
            lw a0, 0x0020(sp) // a0 = player object
            sw r0, 0x0010(sp) // argument 4 = 0
            lli a1, MetaKnight.Action.CAPE_START // a1 = Action
            or a2, r0, r0 // a2 = float: 0.0
            jal 0x800E6F24 // change action
            lui a3, 0x3F80 // a3 = float: 1.0
            jal 0x800E0830 // unknown common subroutine
            lw a0, 0x20(sp) // a0 = player object

            lw a0, 0x0020(sp) // a0 = player object
            lw a0, 0x0084(a0) // a0 = player struct

            sw r0, 0x17C(a0) // temp variable 1 (angle) = 0
            addiu at, r0, -1 // at = -1
            sw at, 0xB30(a0) // temp variable 2 (don't move/move) = -1 (uninitialized)

            OS.routine_end(0x20)
        }

        scope air_initial: {
            OS.routine_begin(0x20)

            sw a0, 0x0020(sp) // save player object

            // change action
            sw r0, 0x0010(sp) // argument 4 = 0
            lli a1, MetaKnight.Action.CAPE_AIR_START // a1 = Action
            or a2, r0, r0 // a2 = float: 0.0
            jal 0x800E6F24 // change action
            lui a3, 0x3F80 // a3 = float: 1.0
            jal 0x800E0830 // unknown common subroutine
            lw a0, 0x20(sp) // a0 = player object

            // divide speed by 2
            lw a0, 0x0020(sp) // a0 = player object
            lw a0, 0x0084(a0) // a0 = player struct
            lui t0, 0x3F00 // ~
            mtc1 t0, f4 // f4 = 0.5
            lwc1 f2, 0x48(a0) // load x speed
            mul.s f2, f2, f4 // divide by 2
            swc1 f2, 0x48(a0) // save x speed
            lwc1 f2, 0x4C(a0) // load y speed
            mul.s f2, f2, f4 // divide by 2
            swc1 f2, 0x4C(a0) // save y speed

            sw r0, 0x17C(a0) // temp variable 1 (angle) = 0
            addiu at, r0, -1 // at = -1
            sw at, 0xB30(a0) // temp variable 2 (don't move/move) = -1 (uninitialized)

            OS.routine_end(0x20)
        }

        scope Start: {
            constant SPEED(0x4270) // float 60
            constant DEFAULT_ANGLE(0x3FC90FDB) // float 1.570796 rads

            scope update: {
                OS.routine_begin(0x20)
                sw a0, 0x18(sp) // save player object

                lw s0, 0x84(a0) // s0 = player struct

                _check_disappear_frame:
                lw t0, 0x78(a0) // t0 = current frame (float)
                lui at, 0x4150 // 13.0
                bne t0, at, _check_animation_end
                nop

                scope _teleport_start: {
                    _fsm:
                    lw a0, 0x18(sp) // a0 = player object
                    jal 0x8000BB04 // gcSetAnimSpeed(fighter_gobj, speed)
                    lui a1, 0x3F00 // 0.5

                    _check_deadzone:
                    lw t8, 0x014C(s0) // t8 = kinetic state
                    sw t8, 0x0028(sp) // 0x0028(sp) = kinetic state
                    lb t0, 0x01C2(s0) // t0 = stick_x
                    lb t1, 0x01C3(s0) // t1 = stick_y
                    multu t0, t0 // ~
                    mflo t2 // t2 = stick_x ^ 2
                    multu t1, t1 // ~
                    mflo t3 // t3 = stick_y ^ 2
                    addu t2, t2, t3 // ~
                    mtc1 t2, f12 // ~
                    cvt.s.w f12, f12 // ~
                    sqrt.s f12, f12 // f12 = absolute stick input
                    cvt.w.s f12, f12 // ~
                    mfc1 t2, f12 // t2 = absolute stick input (int)
                    slti t1, t2, 0xB // at (don't move/move) = 1 if absolute stick < 11, else at = 0
                    sw t1, 0x0B30(s0) // set tmp variable 2

                    bnez t8, _remove_jumps // skip if kinetic state !grounded
                    nop

                    _grounded:
                    lb t0, 0x01C3(s0) // t0 = stick_y
                    blez t0, _remove_jumps // skip if stick y <= 0 (not up)
                    lli a1, MetaKnight.Action.CAPE_AIR_START // a1(action id) = aerial version

                    jal 0x800DEEC8 // set aerial state
                    or a0, s0, r0 // a0 = player struct

                    _change_action:
                    lw a0, 0x18(sp) // a0 = player object
                    lw a2, 0x78(a0) // a2(starting frame) = current animation frame
                    lui a3, 0x3F00 // a3(frame speed multiplier) = 0.5
                    jal 0x800E6F24 // change action
                    sw r0, 0x0010(sp) // argument 4 = 0
                    lw a0, 0x18(sp) // a0 = player object
                    lw s0, 0x84(a0) // s0 = player struct

                    _remove_jumps:
                    // take mid-air jumps away at this point
                    lw t0, 0x09C8(s0) // t0 = attribute pointer
                    lw t0, 0x0064(t0) // t0 = max jumps
                    sb t0, 0x0148(s0) // jumps used = max jumps
                    lw t1, 0x0B30(s0) // set tmp variable 2
                    bnez t1, _visibility // skip setting angle if tmp variable 2 = don't move
                    sw t0, 0x017C(s0) // store DEFAULT_ANGLE

                    _set_angle:
                    lb t0, 0x01C2(s0) // t0 = stick_x
                    lb t1, 0x01C3(s0) // t1 = stick_y
                    lw t2, 0x0044(s0) // t2 = direction
                    multu t0, t2 // ~
                    mflo t0 // t0 = stick_x * direction
                    mtc1 t1, f12 // ~
                    mtc1 t0, f14 // ~
                    cvt.s.w f12, f12 // f12 = stick y
                    jal 0x8001863C // f0 = atan2(f12,f14)
                    cvt.s.w f14, f14 // f14 = stick x * direction
                    swc1 f0, 0x017C(s0) // store movement angle

                    _visibility:
                    lbu at, 0x018D(s0) // at = bit field
                    ori at, at, 0x0001 // enable bitflag for invisibility
                    sb at, 0x018D(s0) // update bit field
                    lbu at, 0x18F(s0) // at = bit field
                    ori at, at, 0x8 // fp->is_jostle_ignore = TRUE;
                    sb at,0x18F(s0) // update bit field
                    li t0, CharEnvColor.moveset_table
                    lbu t1, 0x000D(s0) // t1 = port
                    sll t1, t1, 0x0002 // t1 = offset to env color override value
                    addu t0, t0, t1 // t0 = address of env color override value
                    li t1, 0xFFFFFF00 // env color for full transparency
                    sw t1, 0x0000(t0) // store updated env color

                    _intangibility:
                    lli t0, 0x0003 // ~
                    sb t0, 0x05BB(s0) // set hurtbox state to 0x0003(intangible)
                }

                _check_animation_end:
                li a1, goto_next
                jal 0x800D9480 // ftAnimEndCheckSetStatus(GObj *fighter_gobj, void (*proc_status)(GObj*))
                lw a0, 0x18(sp)

                _end:
                OS.routine_end(0x20)
            }
        
            scope goto_next: {
                addiu sp, sp,-0x0040 // allocate stack space
                sw ra, 0x001C(sp) // ~
                sw a0, 0x0020(sp) // ~

                lw s0, 0x0084(a0) // s0 = player struct
                lw t6, 0x014C(s0) // t6 = kinetic state (0 = grounded, 1 = aerial)

                lw t1, 0xB30(s0) // t1 = temp variable 2 (don't move/move)
                lh t2, 0x01BC(s0) // get held buttons
                andi t2, t2, Joypad.B | Joypad.A // t2 != 0 if B or A is held, else t2 = 0

                bnez t6, _aerial
                nop

                _grounded:
                bnez t2, _grounded_held // attack
                nop
                b _turn_around
                lli a1, MetaKnight.Action.CAPE_END // no attack

                _grounded_held:
                lb t0, 0x1C2(s0) // t0 = stick_x
                slti at, t0, -11 // at = 1 if stick_x < -11, else at = 0
                bnez at, _grounded_held_directional // branch if stick_x < 11
                nop
                slti at, t0, 12 // at = 1 if stick_x < 12, else at = 0
                beqz at, _grounded_held_directional // branch if stick_x < 11
                nop
                b change_action
                lli a1, MetaKnight.Action.CAPE_N // a1 = action

                _grounded_held_directional:
                lw at, 0x44(s0) // at = looking direction
                lb t0, 0x1C2(s0) // t0 = stick_x

                xor at, at, t0 // at is negative if directions don't match
                bltz at, change_action // if pointing towards looking direction, we're still holding forwards
                lli a1, MetaKnight.Action.CAPE_F // a1 = action
                // otherwise, we switched direction during the move
                lw at, 0x44(s0) // at = looking direction
                subu at, r0, at // invert looking direction
                sw at, 0x44(s0) // save inverted value
                b change_action
                lli a1, MetaKnight.Action.CAPE_B // a1 = action

                _aerial:
                bnez t2, _aerial_held // attack
                nop
                b _turn_around
                lli a1, MetaKnight.Action.CAPE_AIR_END // no attack

                _aerial_held:
                // freeze air speed
                sw r0, 0x48(s0) // update air speed x
                sw r0, 0x4C(s0) // update air speed y
                lb t0, 0x1C2(s0) // t0 = stick_x
                slti at, t0, -11 // at = 1 if stick_x < -11, else at = 0
                bnez at, _aerial_held_directional // branch if stick_x < 11
                nop
                slti at, t0, 12 // at = 1 if stick_x < 12, else at = 0
                beqz at, _aerial_held_directional // branch if stick_x < 11
                nop
                b change_action
                lli a1, MetaKnight.Action.CAPE_AIR_N // a1 = action

                _aerial_held_directional:
                lw at, 0x44(s0) // at = looking direction
                lb t0, 0x1C2(s0) // t0 = stick_x

                xor at, at, t0 // at is negative if directions don't match
                bltz at, change_action // if pointing towards looking direction, we're still holding forwards
                lli a1, MetaKnight.Action.CAPE_AIR_F // a1 = action
                // otherwise, we switched direction during the move
                lw at, 0x44(s0) // at = looking direction
                subu at, r0, at // invert looking direction
                sw at, 0x44(s0) // save inverted value
                b change_action
                lli a1, MetaKnight.Action.CAPE_AIR_B // a1 = action

                _turn_around:
                lb v0, 0x1C2(s0) // v0 = stick_x
                bltzl v0, _check_turnaround // branch if stick_x is negative...
                subu v0, r0, v0 // ...and make stick_x positive

                _check_turnaround:
                // v0 = absolute stick_x
                slti at, v0, 0xB // at = 1 if absolute stick_x < 11, else at = 0
                bnez at, change_action // skip if absolute stick_x < 11
                nop
                lw t0, 0x44(s0) // t0 = looking direction
                jal 0x800E8044 // apply turnaround (look at stick pointing direction)
                or a0, s0, r0 // a0 = player struct
                lw at, 0x44(s0) // at = looking direction
                beq at, t0, change_action // if looking direction didn't change, continue
                nop
                // if looking direction changed, invert grounded x velocity
                lwc1 f2, 0x60(s0) // ground x velocity
                neg.s f2, f2 // invert ground x velocity
                swc1 f2, 0x60(s0) // save inverted ground x velocity

                change_action:
                lw a0, 0x20(sp) // a0 = player object
                or a2, r0, r0 // a2(starting frame) = 0.0
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
                jal 0x800E6F24 // change action
                sw r0, 0x10(sp) // argument 4 = 0

                jal 0x800E0830 // unknown common subroutine
                lw a0, 0x20(sp) // a0 = player object

                _end:
                lw ra, 0x001C(sp) // ~
                jr ra // return
                addiu sp, sp, 0x0040 // deallocate stack space
            }

            scope physics: {
                addiu   sp, sp,-0x0030              // allocate stack space
                sw      ra, 0x0014(sp)              // store ra

                lw s0, 0x84(a0) // s0 = player struct

                _check_movement_flag:
                lw t0, 0xB30(s0) // t0 = tmp variable 2 (don't move/move)

                addiu at, r0, -1 // at = -1
                beq at, t0, _end // if not initialized, skip
                nop

                bnez t0, _end // if not moving, skip
                nop

                jal     apply_movement_             // apply movement
                lw      a0, 0x0084(a0)              // a0 = player struct
                lw      ra, 0x0014(sp)              // load ra

                _end:
                addiu   sp, sp, 0x0030              // deallocate stack space
                jr      ra                          // return
                nop
            }

            // @ Description
            // Subroutine which applies movement to MK's down special based on the angle stored at 0x017C in the player struct.
            // a0 - player struct
            scope apply_movement_: {
                addiu   sp, sp,-0x0040              // allocate stack space
                sw      ra, 0x0014(sp)              // store ra
                lui     at, SPEED                   // ~
                sw      at, 0x0018(sp)              // 0x0018(sp) = SPEED
                lw      at, 0x017C(a0)              // ~
                sw      at, 0x001C(sp)              // 0x001C(sp) = movement angle
                sw      a0, 0x0020(sp)              // 0x0020(sp) = player struct

                // ultra64 cosf function
                jal     0x80035CD0                  // f0 = cos(f12)
                lwc1    f12, 0x001C(sp)             // f12 = movement angle
                lwc1    f4, 0x0018(sp)              // f4 = SPEED
                mul.s   f4, f4, f0                  // f4 = x velocity (SPEED * cos(angle))
                swc1    f4, 0x0024(sp)              // 0x0024(sp) = x velocity
                // ultra64 sinf function
                jal     0x800303F0                  // f0 = sin(f12)
                lwc1    f12, 0x001C(sp)             // f12 = movement angle
                lwc1    f4, 0x0018(sp)              // f4 = SPEED
                mul.s   f4, f4, f0                  // f4 = y velocity (SPEED * sin(angle))

                lw      at, 0x0020(sp)              // at = player struct
                lw      t0, 0x014C(at)              // t0 = kinetic state
                bnez    t0, _aerial                 // branch if kinetic state !grounded
                lwc1    f2, 0x0024(sp)              // f2 = x velocity

                _grounded:
                swc1    f2, 0x0060(at)              // store updated ground x velocity
                lwc1    f0, 0x0044(at)              // ~
                cvt.s.w f0, f0                      // f0 = direction
                mul.s   f2, f2, f0                  // f2 = x velocity * direction
                b       _end                        // end
                swc1    f2, 0x0048(at)              // store updated air x velocity

                _aerial:
                lwc1    f0, 0x0044(at)              // ~
                cvt.s.w f0, f0                      // f0 = direction
                mul.s   f2, f2, f0                  // f2 = x velocity * direction
                swc1    f2, 0x0048(at)              // store updated x velocity
                swc1    f4, 0x004C(at)              // store updated y velocity

                _end:
                lw      ra, 0x0014(sp)              // load ra
                addiu   sp, sp, 0x0040              // deallocate stack space
                jr      ra                          // return
                nop
            }

            scope air_collision: {
                addiu   sp, sp,-0x0018              // allocate stack space
                sw      ra, 0x0014(sp)              // store ra
                li      a1, air_to_ground           // a1(transition subroutine) = air_to_ground
                jal     0x800DE80C                  // common air collision subroutine (transition on landing, allow ledge grab)
                nop
                lw      ra, 0x0014(sp)              // load ra
                addiu   sp, sp, 0x0018              // deallocate stack space
                jr      ra                          // return
                nop
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

                addiu a1, r0, MetaKnight.Action.CAPE_START
                _change_action:
                lw a2, 0x0078(a0) // a2(starting frame) = current animation frame
                lw t0, 0x74(a0) // Load root DObj
                lw a3, 0x78(t0) // a3(frame speed multiplier) = current animation speed
                jal 0x800E6F24 // change action
                sw r0, 0x0010(sp) // argument 4 = 0

                lw a0, 0x38(sp) // a0 = player object
                lw s0, 0x84(a0) // s0 = player struct

                lw at, 0xB30(s0) // temp variable 2 (don't move/move) = -1 (uninitialized)
                bltz at, _end // if not already teleporting, skip
                nop

                _visibility:
                lbu at, 0x018D(s0) // at = bit field
                ori at, at, 0x0001 // enable bitflag for invisibility
                sb at, 0x018D(s0) // update bit field
                lbu at, 0x18F(s0) // at = bit field
                ori at, at, 0x8 // fp->is_jostle_ignore = TRUE;
                sb at,0x18F(s0) // update bit field
                li t0, CharEnvColor.moveset_table
                lbu t1, 0x000D(s0) // t1 = port
                sll t1, t1, 0x0002 // t1 = offset to env color override value
                addu t0, t0, t1 // t0 = address of env color override value
                li t1, 0xFFFFFF00 // env color for full transparency
                sw t1, 0x0000(t0) // store updated env color

                _intangibility:
                lli t0, 0x0003 // ~
                sb t0, 0x05BB(s0) // set hurtbox state to 0x0003(intangible)

                _end:
                lw ra, 0x001C(sp) // load ra
                addiu sp, sp, 0x0038 // deallocate stack space
                jr ra // return
                nop
            }

            scope ground_collision: {
                OS.routine_begin(0x20)
                sw a0, 0x18(sp)

                lw at, 0x78(a0) //  ~
                mtc1 at, f2 // f2 = current animation frame
                lui at, 0x4180 // ~
                mtc1 at, f4 // f4 = 16.0

                c.le.s f2, f4
                nop
                bc1f _no_slide_off_ledges // after this frame, we can't go off ledges
                nop

                _slide_off_ledges:
                li a1, ground_to_air // transition in case we slide off a ledge
                jal 0x800DDDDC // mpCommonProcFighterOnFloor(GObj *fighter_gobj, void (*proc_map)(GObj*)) fall from ledges, run function
                nop
                b _end
                nop

                _no_slide_off_ledges:
                jal 0x800DDF44 // mpCommonSetFighterFallOnEdgeBreak(GObj *fighter_gobj) don't fall from ledges
                nop

                _end:
                OS.routine_end(0x20)
            }

            scope ground_to_air: {
                addiu sp, sp,-0x0038 // allocate stack space
                sw ra, 0x001C(sp) // store ra
                sw a0, 0x0038(sp) // 0x0038(sp) = player object
                lw a0, 0x0084(a0) // a0 = player struct
                jal 0x800DEEC8 // set aerial state
                sw a0, 0x0034(sp) // 0x0034(sp) = player struct
                lw v0, 0x0034(sp) // v0 = player struct
                lw a0, 0x0038(sp) // a0 = player object

                addiu a1, r0, MetaKnight.Action.CAPE_AIR_START
                _change_action:
                lw a2, 0x0078(a0) // a2(starting frame) = current animation frame
                lw t0, 0x74(a0) // Load root DObj
                lw a3, 0x78(t0) // a3(frame speed multiplier) = current animation speed
                jal 0x800E6F24 // change action
                sw r0, 0x0010(sp) // argument 4 = 0

                lw a0, 0x38(sp) // a0 = player object
                lw s0, 0x84(a0) // s0 = player struct

                lw at, 0xB30(s0) // temp variable 2 (don't move/move) = -1 (uninitialized)
                bltz at, _end // if not already teleporting, skip
                nop

                _visibility:
                lbu at, 0x018D(s0) // at = bit field
                ori at, at, 0x0001 // enable bitflag for invisibility
                sb at, 0x018D(s0) // update bit field
                lbu at, 0x18F(s0) // at = bit field
                ori at, at, 0x8 // fp->is_jostle_ignore = TRUE;
                sb at,0x18F(s0) // update bit field
                li t0, CharEnvColor.moveset_table
                lbu t1, 0x000D(s0) // t1 = port
                sll t1, t1, 0x0002 // t1 = offset to env color override value
                addu t0, t0, t1 // t0 = address of env color override value
                li t1, 0xFFFFFF00 // env color for full transparency
                sw t1, 0x0000(t0) // store updated env color

                _intangibility:
                lli t0, 0x0003 // ~
                sb t0, 0x05BB(s0) // set hurtbox state to 0x0003(intangible)

                _end:
                lw ra, 0x001C(sp) // load ra
                addiu sp, sp, 0x0038 // deallocate stack space
                jr ra // return
                nop
            }
        }

        scope Attack: {
            scope air_main: {
                OS.routine_begin(0x20)

                scope check_animation_end: {
                    // check if animation has ended (frame<=0.0)
                    lwc1 f6, 0x78(a0) // f6 = current animation frame (float)
                    mtc1 r0, f4 // f4 = 0
                    c.le.s f6, f4 // current animation frame <= 0?
                    nop
                    bc1f _skip // if not, skip
                    nop

                    addiu sp, sp, -0x30
                    li a1, 0x3F19999A // air drift = 0.6F
                    lli a2, 0x1 // unknown and unused variable = true
                    lli a3, 0x1 // is_fall_accelerate (can fastfall) = true
                    lli at, 0x1
                    sw at, 0x10(sp) // is_goto_landing (land into specialfall) = true
                    lui at, 0x3F80
                    sw at, 0x14(sp) // landing_lag (speed multiplier on animation) = 1.0F
                    jal 0x801438F0 // ftCommonFallSpecialSetStatus(GObj *fighter_gobj, f32 drift, sb32 unknown, sb32 is_fall_accelerate, sb32 is_goto_landing, f32 landing_lag, sb32 is_allow_interrupt)
                    sw r0, 0x18(sp) // is_allow_interrupt = false
                    b _end
                    addiu sp, sp, 0x30

                    _skip:
                }

                _end:
                OS.routine_end(0x20)
            }

            scope air_physics: {
                OS.routine_begin(0x20)
                sw a0, 0x18(sp)
                lw s0, 0x84(a0) // s0 = player struct

                lui at, 0x41A8
                mtc1 at, f2 // f2 = 21.0
                lwc1 f4, 0x78(a0) // f4 = current animation frame

                c.le.s f2, f4
                nop
                bc1f _root_motion // before frame 21 we don't apply gravity
                nop

                _gravity:
                jal 0x800D91EC // ftPhysicsApplyAirVelFriction(GObj *fighter_gobj)
                nop
                b _end
                nop

                _root_motion:
                jal 0x800D93E4 // ftPhysicsApplyAirVelTransNAll(GObj *fighter_gobj)
                nop

                _end:
                OS.routine_end(0x20)
            }
        }
    }
}