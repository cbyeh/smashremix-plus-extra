// SnakeSpecial.asm

scope SnakeSpecial {
    scope C4Item {
        include "./C4.asm"
    }

    scope NikitaItem {
        include "./Nikita.asm"
    }

    scope CypherItem {
        include "./Cypher.asm"
    }

    scope GrenadeItem {
        include "./Grenade.asm"
    }
    Item.add_item(GrenadeItem)

    scope Crawl: {
        scope interrupt: {
            OS.routine_begin(0x20)

            sw a0, 0x18(sp) // save a0

            jal 0x80143154 // ftCommonSquatWaitProcInterrupt(GObj *fighter_gobj)
            nop

            bnez v0, _end // if the original function returned 1, go with that
            nop

            lw a0, 0x18(sp) // restore a0
            lw a0, 0x84(a0) // a0 = character struct
            lb t6, 0x1c2(a0) // t6 = stick_x
            lw t7, 0x44(a0) // t7 = direction (-1/1)
            multu t6, t7
            mflo t8 // t8 = stick_x * direction

            // if stick_x * direction > 8, we're going _forward
            slti at, t8, 8 // at = 1 if stick_x * direction > 8, else at = 0
            beqz at, _forward // branch if stick_x * direction > 8
            nop
            // if stick_x * direction < -8, we're going _back
            slti at, t8, -8 // at = 1 if stick_x * direction < -8, else at = 0
            bnez at, _back // branch if stick_x * direction < -8
            nop
            // if stick_x * direction is between -8 and 8, we're neutral
            _neutral:
            b _change_action
            lli a1, Action.CrouchIdle

            _forward:
            b _change_action
            lli a1, Snake.Action.CROUCHF

            _back:
            lli a1, Snake.Action.CROUCHB

            _change_action:
            lw a0, 0x18(sp) // restore a0
            lw a2, 0x84(a0) // a2 = character struct
            lw t0, 0x0024(a2) // t0 = current action
            beq t0, a1, _end // if current action == new action, skip
            lli v0, 0x0 // ...and return 0

            OS.save_registers()
            lui a2, 0x3F80 // a2(starting frame) = 1.0
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            sw r0, 0x0010(sp) // argument 4 = 0
            jal 0x800E6F24 // change action
            nop
            OS.restore_registers()
            lli v0, 0x1 // return 1: action was interrupted

            _end:
            OS.routine_end(0x20)
        }

        scope physics: {
            OS.routine_begin(0x20)

            sw a0, 0x18(sp) // save a0

            lw a0, 0x0084(a0) // a0 = character struct

            lw t0, 0x9c8(a0) // t0 = character attributes
            lw a2, 0x24(t0) // a2 = character traction
            li a1, 0x3E4CCCCD // a1 = 0.2F
            
            jal 0x800D8ADC // ftPhysicsSetGroundVelStickRange(FTStruct *fp, f32 vel, f32 friction)
            nop

            jal 0x800D87D0 // ftPhysicsSetGroundVelTransferAir(GObj *fighter_gobj)
            lw a0, 0x18(sp)

            lw a0, 0x18(sp) // a0 = player object
            lw a1, 0x84(a0) // a1 = player struct
            lwc1 f4, 0x60(a1) // f4 = ground x velocity
            abs.s f4, f4 // f4 = abs(ground x velocity)
            lui at, 0x3DCC // ~
            mtc1 at, f2 // f2 = 0.1
            mul.s f2, f2, f4 // f2 = ground x velocity * 0.1
            jal 0x8000BB04 // fsm subroutine
            mfc1 a1, f2 // a1 = FSM

            OS.routine_end(0x20)
        }
    }

    scope DashAttack: {
        scope main: {
            OS.routine_begin(0x20)

            li a1, 0x8014329C // ftCommonSquatWaitSetStatus function
            jal 0x800D9480 // ftAnimEndCheckSetStatus(fighter_gobj, ftCommonSquatWaitSetStatus)
            nop

            OS.routine_end(0x20)
        }
    }

    scope USmash: {
        projectile_struct:
        dw 0x00000000 // this has some sort of bit flag to tell it to use secondary type display list?
        dw 0x0
        dw Character.SNAKE_file_6_ptr // pointer to file
        dw Snake.FILE_OFFSETS.MERGED_FILERESOURCE_6_2 // 00000000
        dw 0x12480000 // rendering routine?
        dw projectile_update // proc update
        dw projectile_procmap // proc map
        dw projectile_collision // proc hit
        dw projectile_collision // proc shield
        dw projectile_collision // proc hop (shield bounce)
        dw 0x80175958 // proc set-off - creates shockwave effect that I don't want
        dw projectile_reflector // proc reflector
        dw 0x80175958 // proc absorb - creates shockwave effect that I don't want
        OS.copy_segment(0x103904, 0x0C) // empty

        scope projectile_update: {
            OS.routine_begin(0x30)
            lw a1, 0x84(a0) // a1 = projectile struct

            sw a0, 0x1C(sp) // save projectile object
            sw a1, 0x20(sp) // save projectile struct

            jal 0x80167FE8 // decrease duration and check if duration is over
            lw a0, 0x20(sp) // a0 = projectile struct

            bnez v0, _explode // branch if duration over
            nop

            scope _physics: {
                lw a1, 0x20(sp) // a1 = projectile struct

                lwc1 f2, 0x24(a1) // load speed y

                lui at, 0xC2F0 // -120.0
                mtc1 at, f4 // f4 = max_fall_speed

                c.lt.s f2, f4 // if f2 < f4 (speed_y < max_fall_speed)
                nop
                bc1tl _end // branch to _end if true...
                swc1 f4, 0x24(a1) // ...and keep speed = max falling speed
                
                lui at, 0x4080 // 4.0
                mtc1 at, f4 // f4 = gravity

                sub.s f2, f2, f4 // subtract gravity
                swc1 f2, 0x24(a1) // save new speed y

                _end:
            }

            scope _do_smoke: {
                lw a0, 0x1C(sp) // a0 = projectile object
                lw a1, 0x20(sp) // a1 = projectile struct

                lw t0, 0x0268(a1) // t0 = current duration
                andi t2, t0, 0x0003 // not disabled: t0 = duration % 4

                bnez t2, _end // branch if not the time to spawn
                nop

                _spawn_smoke:
                // create a smoke particle every N frames
                lw a0, 0x0074(a0) // a0 = item first joint struct
                lwc1 f12, 0x0038(a0) // f12 = rotation angle
                neg.s f12, f12 // f12 = theta
                jal 0x80035CD0 // f0 = cos(theta)
                swc1 f12, 0x0004(sp) // save 0x0050(sp) = theta

                swc1 f0, 0x0008(sp) // save cos(theta)
                jal 0x800303F0 // f0 = sin(ANGLE)
                lwc1 f12, 0x0004(sp) // f12 = ANGLE

                lwc1 f2, 0x0008(sp) // f2 = cos(theta)

                // x' = x * cos(theta) + y * sin(theta)
                // y' = -x * sin(theta) + y * cos(theta)

                mtc1 r0, f4 // offset X = 0
                lui at, 0x4248
                mtc1 at, f6 // offset Y = 50.0

                mul.s f8, f4, f2 // f8 = x * cos(theta)
                mul.s f10, f6, f0 // f10 = y * sin(theta)
                mul.s f12, f4, f0 // f12 = x * sin(theta)
                mul.s f14, f6, f2 // f14 = y * cos(theta)

                add.s f16, f8, f10 // f16 = x'
                sub.s f18, f14, f12 // f18 = y'

                lwc1 f0, 0x001C(a0) // f0 = x
                lwc1 f2, 0x0020(a0) // f2 = y
                lwc1 f4, 0x0024(a0) // f4 = z

                add.s f0, f0, f16 // f0 = tail abs x
                add.s f2, f2, f18 // f2 = tail abs y

                swc1 f0, 0x0004(sp) // save abs x
                swc1 f2, 0x0008(sp) // save abs y
                swc1 f4, 0x000C(sp) // save abs z

                addiu a0, sp, 0x0004 // a0 = tail abs x/y/z
                lli a1, 0x0 // a1 = 0
                addiu sp, sp, -0x20
                jal 0x800FF648 // efManagerDustExpandSmallMakeEffect(Vec3f *pos, f32 f_index)
                nop
                addiu sp, sp, 0x20

                _end:
            }

            _update_model_rotation:
            jal 0x80167FA0 // wpMainVelSetModelPitch(weapon_gobj); - set projectile direction based on speed
            lw a0, 0x1C(sp) // restore a0 = projectile object

            jal 0x80168428 // wpMainReflectorRotateWeaponModel(GObj *weapon_gobj)
            lw a0, 0x1C(sp) // restore a0 = projectile object

            b _end
            or v0, r0, r0

            _explode:
            lli v0, 0x1

            _end:
            OS.routine_end(0x30)
        }

        scope projectile_collision: {
            OS.routine_begin(0x20)

            lw v0, 0x0084(a0) // v0 = projectile special struct

            lw t0, 0x02A0(v0)
            lli t1, 0x1

            beq t0, t1, _end // if already collided, skip
            nop
            
            lli t0, 0x1
            sw t0, 0x02A0(v0)

            lli t0, 0x5
            sw t0, 0x0268(v0) // set duration to 5
			addiu	t0, r0, 1
			sw		t0, 0x0100(v0)	// set hitbox state to 1 to prevent it from smearing

            // refresh hitbox
            sw r0, 0x0214(v0) // reset hit object pointer 1
            sw r0, 0x021C(v0) // reset hit object pointer 2
            sw r0, 0x0224(v0) // reset hit object pointer 3
            sw r0, 0x022C(v0) // reset hit object pointer 4

            // Hitbox size
            lui at, 0x4396 // 300
            sw at, 0x0128(v0) // save new hitbox size

            // Hitbox damage
            lli at, 14
            sw at, 0x0104(v0) // save

            // Hit type
            lli at, 0x1 // at = 1 (fire)
            sw at, 0x010C(v0) // save

            // Hit angle
            lli at, 65
            sw at, 0x012C(v0)

            // Hitbox base knockback
            lli at, 87
            sw at, 0x0138(v0) // save

            // Hitbox knockback growth
            lli at, 60+20
            sw at, 0x0130(v0) // save

            // Make projectile interact with other hitboxes
            lbu at, 0x148(v0)
            ori at, at, 0x80 // can_setoff = 1
            sb at, 0x148(v0)

            lbu at, 0x158(v0)
            ori at, at, 0x2 // can_absorb = 1
            andi at, at, 0xFFFB // can_reflect = 0
            sb at, 0x158(v0)

            // set 0 speed
            sw r0, 0x20(v0) // speed x = 0
            sw r0, 0x24(v0) // speed y = 0

            // explosion effect
            lw t0, 0x0074(a0) // a0 = projectile first joint struct
            sw r0, 0x50(t0) // set no display list for projectile
            jal 0x801005C8 // efManagerSparkleWhiteMultiExplodeMakeEffect(Vec3f *pos) -- explosion gfx
            addiu a0, t0, 0x001C // a0 = projectile x/y/z

            // screen shake
            jal 0x801008F4 // efManagerQuakeMakeEffect(s32 magnitude)
            lli a0, 0x0001 // a0 = 1

            jal 0x800269C0 // play FGM
            lli a0, 0x0000 // FGM id = 0 (small explosion)

            _end:
            or v0, r0, r0
            OS.routine_end(0x20)
        }

        scope projectile_procmap: {
            OS.routine_begin(0x20)

            sw a0, 0x1C(sp) // save projectile object

            jal 0x80167C04 // wpMapTestAllCheckCollEnd(GObj *weapon_gobj)
            nop

            beqz v0, _end
            nop

            jal projectile_collision // if collided, run collision code
            lw a0, 0x1C(sp) // a0 = projectile object

            _end:
            or v0, r0, r0
            OS.routine_end(0x20)
        }

        scope projectile_reflector: {
            OS.routine_begin(0x20)

            // reflect speed XY
            lw a1, 0x84(a0) // a1 = projectile struct
            lwc1 f2, 0x20(a1) // f2 = speed x
            neg.s f2, f2 // negate speed x
            swc1 f2, 0x20(a1) // save new speed x
            lwc1 f2, 0x24(a1) // f2 = speed y
            neg.s f2, f2 // negate speed y
            swc1 f2, 0x24(a1) // save new speed y

            // renew lifetime
            lli t0, 0x100 // lifetime = 256
            sw t0, 0x268(a1) // save lifetime

            _end:
            or v0, r0, r0 // return FALSE (do not destroy)
            OS.routine_end(0x20)
        }

        scope main: {
            OS.routine_begin(0x20)

            sw a0, 0x4(sp)
            lw s0, 0x84(a0) // s0 = player struct

            lw t0, 0x1C(s0) // t0 = current frame (int)

            lli at, 30
            bne t0, at, _check_animation_end
            nop

            _spawn_projectile: {
                addiu sp, sp, -0x20
                {
                    lw t0, 0x78(s0) // t0 = player position vec3

                    lw t1, 0x8E8(s0) // t1 = topjoint transform bone
                    lwc1 f6, 0x0040(t1) // f6 = topjoint X scale

                    lw t1, 0x44(s0) // t1 = facing direction
                    mtc1 t1, f8 // f8 = facing direction
                    cvt.s.w f8, f8 // f8 = facing direction (float)

                    mul.s f10, f6, f8 // f6 = facing direction * scale
                    
                    // create pos vec3 at 0x0
                    lwc1 f2, 0x0(t0) // f2 = player x
                    lui at, 0x4248 // offset x = 50.0
                    mtc1 at, f4 // f4 = offset x
                    mul.s f4, f4, f10 // offset * (direction * scale)
                    add.s f2, f2, f4 // f2 = pos x + final offset
                    swc1 f2, 0x0(sp) // x

                    lwc1 f2, 0x4(t0) // f2 = player y
                    lui at, 0x4348 // offset y = 200.0
                    mtc1 at, f4 // f4 = offset y
                    mul.s f4, f4, f6 // offset * scale
                    add.s f2, f2, f4 // f2 = pos y + final offset
                    swc1 f2, 0x4(sp) // y

                    sw r0, 0x8(sp) // z

                    li a1, projectile_struct
                    addiu a2, sp, 0x0 // a2 = vec3 position
                    lui a3, 0x8000 // a3 = flags

                    addiu sp, sp, -0x20
                    {
                        sw a0, 0x4(sp) // save player object
                        
                        _spawn_weapon:
                        jal 0x801655C8 // GObj* wpManagerMakeWeapon(GObj *parent_gobj, WPDesc *wp_desc, Vec3f *spawn_pos, u32 flags)
                        nop

                        sw v0, 0x8(sp) // save projectile object

                        lw t0, 0x0074(v0) // v1 = item first joint struct
                        lui at, 0x3F40 // at = 0.75
                        mtc1 at, f6
                        swc1 f6, 0x0040(t0) // store x size multiplier to projectile joint
                        swc1 f6, 0x0044(t0) // store y size multiplier to projectile joint

                        lw v1, 0x84(v0) // v1 = ItemGetStruct(item_gobj);

                        lli t0, 0x100 // lifetime = 256
                        sw t0, 0x268(v1) // save lifetime

                        // Hitbox size
                        lui at, 0x430C // at = 140.0 (fp)
                        sw at, 0x0128(v1) // save

                        // Hitbox damage
                        lli at, 0x0001
                        sw at, 0x0104(v1) // save

                        // Hit type
                        sw r0, 0x010C(v1) // save

                        // Hit angle
                        lli at, 0x169 // 361
                        sw at, 0x012C(v1)

                        // Hitbox base knockback
                        lli at, 0x0000 // at = 0
                        sw at, 0x0138(v1) // save

                        // Hitbox knockback growth
                        lli at, 0x0000 // at = 0
                        sw at, 0x0130(v1) // save

                        // Hit FGM
                        lli at, 0x2B7 // no sound
                        sh at, 0x0146(v1) // save

                        // Make projectile not interact with other hitboxes
                        lbu at, 0x148(v1)
                        andi at, at, 0xFF7F // can_setoff = 0
                        sb at, 0x148(v1)

                        // Make projectile not interact with other hitboxes
                        lbu at, 0x158(v1)
                        andi at, at, 0xFFFD // can_absorb = 0
                        sb at, 0x158(v1)

                        // ECB collision prism size
                        lui at, 0x42F0 // 120.0
                        mtc1 at, f2
                        swc1 f2, 0x64(v1) // update ecb top

                        lui at, 0xC2F0 // -120.0
                        mtc1 at, f2
                        swc1 f2, 0x6C(v1) // update ecb bottom

                        lui at, 0x4260 // 56.0
                        mtc1 at, f2
                        swc1 f2, 0x70(v1) // update ecb width

                        lw a0, 0x4(sp) // load player object
                        lw s0, 0x84(a0) // s0 = player struct
                        lwc1 f2, 0x44(s0) // f2 = player facing direction
                        cvt.s.w f2, f2 // f2 = float(player direction)

                        lui at, 0x40C0 // 6.0
                        mtc1 at, f4
                        mul.s f4, f4, f2 // multiply by facing direction
                        swc1 f4, 0x20(v1) // save speed x

                        lui at, 0x42F0 // 120.0
                        mtc1 at, f4
                        swc1 f4, 0x24(v1) // save speed y

                        sw r0, 0x02A0(v1) // start tmp variable 2 as zero (will be 1 if collided with anything)

                        jal 0x80167FA0 // wpMainVelSetModelPitch(weapon_gobj); - set projectile direction based on speed
                        lw a0, 0x8(sp) // restore v0 = projectile object

                        jal 0x80168428 // wpMainReflectorRotateWeaponModel(GObj *weapon_gobj)
                        lw a0, 0x8(sp) // restore v0 = projectile object
                    }
                    addiu sp, sp, 0x20
                }
                addiu sp, sp, 0x20
            }
            lw a0, 0x4(sp) // restore a0
            lw s0, 0x84(a0) // s0 = player struct

            _check_animation_end:
            jal 0x800D94C4 // ftAnimEndSetWait(GObj *fighter_gobj)
            nop

            OS.routine_end(0x20)
        }
    }

    scope TiltF: {
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
            lui t1, 0x4120 // t1 = 11.0F
            mtc1 t1, f8

            c.lt.s f8, f6
            nop
            bc1fl main_normal
            nop

            lw t0, 0x0184(v0) // was A ever pressed during the move?
            beq t0, r0, main_normal // If not, main_normal
            nop

            // all conditions are met
            b cancel_tiltf_2
            nop

            cancel_tiltf_2:
            OS.save_registers()
            lli a1, Snake.Action.TILTF2 // a1 = action to switch to
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

    scope C4: {
        scope initial: {
            addiu sp, sp, -0x0020 // ~
            sw ra, 0x001C(sp) // ~
            sw a0, 0x0020(sp) // original lines 1-3

            lw a0, 0x0084(a0) // a0 = player struct
            lw t6, 0x014C(a0) // t6 = kinetic state (0 = grounded, 1 = aerial)

            lw t7, 0x0ADC(a0) // t7 = 0 if no c4 out

            bnez t6, _aerial
            nop

            _grounded:
            lli a1, Snake.Action.C4START // a1 = action
            beqz t7, change_action
            nop
            b change_action
            lli a1, Snake.Action.C4DETONATE // a1 = action

            _aerial:
            lli a1, Snake.Action.C4AIRSTART // a1 = action
            beqz t7, change_action
            nop
            b change_action
            lli a1, Snake.Action.C4AIRDETONATE // a1 = action

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

        scope Start: {
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

                constant STICKY_RANGE(0x4248) // 50.0

                define TOUCHING_WALL(0x30(sp))
                define STICKY(0x34(sp))

                lw s0, 0x0084(a0) // s0 = player struct

                scope _check_wall: {
                    // create two vector 3: one for our position, one for the wall check
                    // we're calling functions that work as raycasting
                    addiu sp, sp, -0x50 // allocate stack space
                    sw s0, 0x40(sp) // save s0
                    sw a0, 0x44(sp) // save a0
                    sw a1, 0x48(sp) // save a1

                    lw a0, 0x78(s0) // Load TopN translate vector

                    // first, base position at 0x20(sp)
                    lwc1 f2, 0x0(a0) // load x
                    swc1 f2, 0x20(sp) // store x
                    lwc1 f2, 0x4(a0) // load y
                    lwc1 f4, 0xB4(s0) // Load collision diamond center
                    add.s f2, f2, f4 // y += collision diamond center
                    swc1 f2, 0x24(sp) // store y
                    lwc1 f2, 0x8(a0) // load z
                    swc1 f2, 0x28(sp) // store z

                    // second, target position at 0x30(sp)
                    // calculate total X offset using f8
                    lwc1 f8, 0xBC(s0) // Load collision diamond width
                    lui at, 0x4248 // 50.0
                    mtc1 at, f4
                    add.s f8, f8, f4 // f8 += 50.0

                    lw at, 0x44(s0) // at = facing direction (-1/1)
                    mtc1 at, f6 // f6 = facing direction
                    cvt.s.w f6, f6 // f6 = facing direction (float)

                    mul.s f8, f8, f6 // f8 = X offset * facing direction
                    
                    lwc1 f2, 0x20(sp) // load base x
                    add.s f2, f2, f8 // base x + offset
                    swc1 f2, 0x30(sp) // store target x
                    lwc1 f2, 0x24(sp) // load base y
                    swc1 f2, 0x34(sp) // store target y
                    lwc1 f2, 0x28(sp) // load base z
                    swc1 f2, 0x38(sp) // store target z

                    // These functions use pointers to return all sorts of information
                    // about the wall collision. If null, we just don't get them back
                    addiu a0, sp, 0x20 // a0 = base position
                    addiu a1, sp, 0x30 // a1 = target position
                    or a2, r0, r0 // NULL &ga_last
                    or a3, r0, r0 // NULL &stand_line_id
                    sw r0, 0x10(sp) // NULL &stand_coll_flags
                    sw r0, 0x14(sp) // NULL &angle

                    // Use facing direction to determine which wall collision function to call
                    lw at, 0x44(s0) // at = facing direction (-1/1)
                    bltz at, _right_side // if facing left (< 0), check right wall
                    nop

                    // Facing right, check left wall
                    jal 0x800F7F00 // mpCollisionCheckLWallLineCollisionSame
                    nop
                    b _wall_check_end
                    nop

                    _right_side:
                    jal 0x800F6B58 // mpCollisionCheckRWallLineCollisionSame
                    nop

                    _wall_check_end:
                    lw s0, 0x40(sp) // restore s0
                    lw a0, 0x44(sp) // restore a0
                    lw a1, 0x48(sp) // restore a1
                    addiu sp, sp, 0x50 // deallocate stack space
                    _end:
                    sw v0, {TOUCHING_WALL} // save touching wall result
                }

                scope _check_sticky: {
                    // here, we go through all other player structs (it's a linked list)
                    // and check if we're close enough to stick to them
                    // we use our position + ECB center Y as our base position
                    // for the opponent it's also the ECB center Y
                    // then the distance is the sum of the two ECB widths
                    // plus our constant STICKY_RANGE * our root bone scale
                    addiu sp, sp, -0x50 // allocate stack space
                    sw s0, 0x40(sp) // save s0
                    sw a0, 0x44(sp) // save a0
                    sw a1, 0x48(sp) // save a1

                    or v0, r0, r0 // sticky player = NULL

                    lw t0, 0x78(s0) // Load TopN translate vector
                    lwc1 f2, 0x0(t0) // load x
                    lwc1 f4, 0x4(t0) // load y
                    lwc1 f6, 0xB4(s0) // Load collision diamond center
                    add.s f4, f4, f6 // y += collision diamond center

                    lw t0, 0x8E8(s0) // t0 = topjoint transform bone
                    lwc1 f16, 0x40(t0) // f16 = topjoint X scale

                    scope _loop_players: {
                        OS.read_word(Global.p_struct_head, at) // at = p1 player struct
                        _loop:
                        lw t0, 0x4(at) // t0 = player object
                        beqz t0, _next // if no player object, get next player struct
                        nop
                        beq t0, a0, _next // if it's us, get next player struct
                        nop

                        _team_check:
                        li t1, Global.match_info // ~
                        lw t1, 0x0000(t1) // t1 = match info struct
                        lbu t2, 0x0002(t1) // t2 = team battle flag
                        beqz t1, _direction_check // branch if team battle flag = FALSE
                        lbu t2, 0x0009(t1) // t2 = team attack flag
                        bnez t2, _direction_check // branch if team attack flag != FALSE
                        nop

                        // if the match is a team battle with team attack disabled
                        lw t1, 0x0084(t0) // t1 = target player struct
                        lbu t1, 0x000C(t1) // t1 = target team
                        lbu t2, 0x000C(s2) // t2 = player team
                        beq t1, t2, _next // skip if player and target are on the same team
                        nop

                        _direction_check:
                        // we must be facing the target player to stick to them
                        mtc1 r0, f0 // f0 = 0.0

                        lw t1, 0x78(at) // t1 = target player position vec3
                        lwc1 f6, 0x0(t1) // f6 = target player x

                        sub.s f10, f6, f2 // f10 = target_x - our_x
                        lw t2, 0x44(s0) // t2 = our facing direction
                        bgez t2, _facing_right
                        nop

                        // Facing left: target_x must be < our_x
                        c.lt.s f10, f0 // if (target_x - our_x) < 0.0
                        nop
                        bc1t _distance_check
                        nop
                        b _next
                        nop

                        _facing_right:
                        // Facing right: target_x mus be > our_x
                        c.le.s f0, f10 // if (0.0 <= target_x - our_x)
                        nop
                        bc1t _distance_check
                        nop
                        b _next
                        nop

                        _distance_check:
                        lw t1, 0x78(at) // t1 = target player position vec3
                        lwc1 f6, 0x0(t1) // f6 = target player x
                        lwc1 f8, 0x4(t1) // f8 = target player y
                        lwc1 f10, 0xB4(at) // Load target collision diamond center
                        add.s f8, f8, f10 // y += target collision diamond center

                        // calculate distance between players
                        sub.s f12, f6, f2 // f12 = target player x - player x
                        sub.s f14, f8, f4 // f14 = target player y - player y
                        mul.s f12, f12, f12 // f12 = (target player x - player x) ^ 2
                        mul.s f14, f14, f14 // f14 = (target player y - player y) ^ 2
                        add.s f12, f12, f14 // f12 = distance ^ 2
                        sqrt.s f12, f12 // f12 = distance

                        // calculate distance threshold
                        lui t1, STICKY_RANGE
                        mtc1 t1, f14 // f14 = STICKY_RANGE
                        mul.s f14, f14, f16 // f14 = STICKY_RANGE * topjoint X scale
                        lwc1 f10, 0xBC(at) // Load target collision diamond width
                        add.s f14, f14, f10 // f14 += target collision ECB width
                        lwc1 f10, 0xBC(s0) // Load our collision diamond width
                        add.s f14, f14, f10 // f14 += our collision ECB width

                        // if distance <= threshold, we can stick to the player
                        c.le.s f12, f14 // compare distance and threshold
                        nop
                        bc1t _sticky // if distance <= threshold, branch to _sticky
                        nop
                        // if not, continue to next player
                        b _next
                        nop

                        _sticky:
                        // we can stick to the player, save it
                        or v0, r0, at // save player struct pointer to sticky player
                        b _end
                        nop
                        
                        _next:
                        lw at, 0x0000(at) // at = next player struct
                        bnez at, _loop // loop while there are more players to check
                        nop

                        _end:
                    }

                    lw s0, 0x40(sp) // restore s0
                    lw a0, 0x44(sp) // restore a0
                    lw a1, 0x48(sp) // restore a1
                    addiu sp, sp, 0x50 // deallocate stack space

                    // save sticky player result
                    sw v0, {STICKY} // save sticky player result
                }

                lw t0, {TOUCHING_WALL} // t0 = touching wall result
                lw t1, {STICKY} // t1 = sticky player result
                sw t1, 0x17C(s0) // save sticky player result to temp variable 1
                lw t6, 0x014C(s0) // t6 = kinetic state (0 = grounded, 1 = aerial)

                bnez t6, _aerial
                nop

                _grounded:
                bnez t1, _continue // if sticking to player
                lli a1, Snake.Action.C4ENEMY // a1(action id)
                bnez t0, _continue // if touching a wall
                lli a1, Snake.Action.C4WALL // a1(action id)
                b _continue
                lli a1, Snake.Action.C4GROUND // a1(action id)

                _aerial:
                bnez t1, _continue // if sticking to player
                lli a1, Snake.Action.C4AIRENEMY // a1(action id)
                bnez t0, _continue // if touching a wall
                lli a1, Snake.Action.C4AIRWALL // a1(action id)
                b _continue
                lli a1, Snake.Action.C4AIRGROUND // a1(action id)

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

            scope air_collision: {
                addiu sp, sp,-0x0018 // allocate stack space
                sw ra, 0x0014(sp) // store ra
                li a1, air_to_ground // a1(transition subroutine) = air_to_ground
                jal 0x800DE6E4 // common air collision subroutine (transition on landing, no ledge grab)
                nop
                lw ra, 0x0014(sp) // load ra
                addiu sp, sp, 0x0018 // deallocate stack space
                jr ra // return
                nop
            }

            // @ Description
            // Subroutine which handles ground to air transition for down special actions
            scope air_to_ground: {
                addiu sp, sp,-0x0038 // allocate stack space
                sw ra, 0x001C(sp) // store ra
                sw a0, 0x0038(sp) // 0x0038(sp) = player object
                lw a0, 0x0084(a0) // a0 = player struct
                jal 0x800DEE98 // set grounded state
                sw a0, 0x0034(sp) // 0x0034(sp) = player struct
                lw v0, 0x0034(sp) // v0 = player struct
                lw a0, 0x0038(sp) // a0 = player object

                addiu a1, r0, Snake.Action.C4START
                _change_action:
                lw a2, 0x0078(a0) // a2(starting frame) = current animation frame
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1
                jal 0x800E6F24 // change action
                nop
                lw ra, 0x001C(sp) // load ra
                addiu sp, sp, 0x0038 // deallocate stack space
                jr ra // return
                nop
            }
        }

        scope Ground: {
            // Previous state passes 0x17C(struct) as the player struct
            // that we're sticking the grenade to, in case of sticky (C4ENEMY)
            scope main_ground: {
                OS.routine_begin(0x80)

                sw a0, 0x0034(sp) // save 0x0034(sp) = player object
                lw a1, 0x84(a0) // a1 = player struct

                // load current animation frame
                lw t0, 0x78(a0) // t0 = current animation frame
                mtc1 t0, f2

                lw t2, 0x84(a0) // t2 = player struct
                lw t2, 0x24(t2) // t2 = current action

                // decide which frame to spawn item
                lli t3, Snake.Action.C4GROUND
                beq t2, t3, _main_continue
                lui t1, 0x4150 // t1 = 13.0F
                lli t3, Snake.Action.C4WALL
                beq t2, t3, _main_continue
                lui t1, 0x4040 // t1 = 3.0F
                lui t1, 0x4000 // sticky: t1 = 2.0

                _main_continue:
                mtc1 t1, f0
                c.eq.s f0, f2
                nop
                bc1fl _check_animation_end
                nop

                lw v0, 0x0084(a0) // v0 = player struct
                sw r0, 0x0040(sp) // ~
                sw r0, 0x0044(sp) // ~
                sw r0, 0x0048(sp) // unknown x/y/z offset?
                addiu a1, sp, 0x0020
                mtc1 r0, f0
                swc1 f0, 0x0020(sp) // x offset
                swc1 f0, 0x0024(sp) // y offset
                swc1 f0, 0x0028(sp) // z offset
                lw a0, 0x0928(v0) // a0 = part 0xC (right hand) struct
                sw a3, 0x0030(sp)
                jal 0x800EDF24 // returns x/y/z coordinates of the part in a0 to a1
                sw v0, 0x002C(sp)
                sw r0, 0x0008(a1) // z coordinate = 0
                li at, 0x80000002 // ~
                sw at, 0x0010(sp) // unknown argument = 0x80000002
                lw a0, 0x0034(sp) // a0 = player object
                li a1, C4Item.item_info_array // a1 = grenade_item_info_array

                addiu a2, sp, 0x0020 // a2 = x/y/z coordinates
                jal C4Item.SPAWN_ITEM // create flashbang
                addiu a3, sp, 0x0040 // a3 = unknown x/y/z offset

                jal 0x80104458 // efManagerItemGetSwirlProcUpdate(Vec3f *pos)
                addiu a0, sp, 0x0020 // a0 = x/y/z coordinates

                _check_animation_end:
                lw a0, 0x0034(sp) // save 0x0034(sp) = player object
                jal 0x800D94C4 // ftAnimEndSetWait(GObj *fighter_gobj)
                nop

                OS.routine_end(0x80)
            }

            scope main_air: {
                OS.routine_begin(0x80)

                sw a0, 0x0034(sp) // save 0x0034(sp) = player object
                lw a1, 0x84(a0) // a1 = player struct

                // load current animation frame
                lw t0, 0x78(a0) // t0 = current animation frame
                mtc1 t0, f2

                lw t2, 0x84(a0) // t2 = player struct
                lw t2, 0x24(t2) // t2 = current action

                // decide which frame to spawn item
                lli t3, Snake.Action.C4AIRGROUND
                beq t2, t3, _main_continue
                lui t1, 0x4110 // t1 = 9.0F
                lli t3, Snake.Action.C4AIRWALL
                beq t2, t3, _main_continue
                lui t1, 0x4080 // t1 = 4.0F
                lui t1, 0x4000 // sticky: t1 = 2.0

                _main_continue:
                mtc1 t1, f0
                c.eq.s f0, f2
                nop
                bc1fl _check_animation_end
                nop

                lw v0, 0x0084(a0) // v0 = player struct
                sw r0, 0x0040(sp) // ~
                sw r0, 0x0044(sp) // ~
                sw r0, 0x0048(sp) // unknown x/y/z offset?
                addiu a1, sp, 0x0020
                mtc1 r0, f0
                swc1 f0, 0x0020(sp) // x offset
                swc1 f0, 0x0024(sp) // y offset
                swc1 f0, 0x0028(sp) // z offset
                lw a0, 0x0928(v0) // a0 = part 0xC (right hand) struct
                sw a3, 0x0030(sp)
                jal 0x800EDF24 // returns x/y/z coordinates of the part in a0 to a1
                sw v0, 0x002C(sp)
                sw r0, 0x0008(a1) // z coordinate = 0
                li at, 0x80000002 // ~
                sw at, 0x0010(sp) // unknown argument = 0x80000002
                lw a0, 0x0034(sp) // a0 = player object
                li a1, C4Item.item_info_array // a1 = grenade_item_info_array

                addiu a2, sp, 0x0020 // a2 = x/y/z coordinates
                jal C4Item.SPAWN_ITEM // create flashbang
                addiu a3, sp, 0x0040 // a3 = unknown x/y/z offset

                jal 0x80104458 // efManagerItemGetSwirlProcUpdate(Vec3f *pos)
                addiu a0, sp, 0x0020 // a0 = x/y/z coordinates

                _check_animation_end:
                lw a0, 0x0034(sp) // save 0x0034(sp) = player object

                jal 0x800D94E8 // ftAnimEndSetFall(GObj *fighter_gobj)
                nop

                OS.routine_end(0x80)
            }
        }

        scope Detonate: {
            scope main_ground: {
                OS.routine_begin(0x20)

                jal detonate_check
                sw a0, 0x0010(sp)
                jal 0x800D94C4 // original routine
                lw a0, 0x0010(sp) // restore a0

                OS.routine_end(0x20)

            }

            scope main_air: {
                OS.routine_begin(0x20)

                jal detonate_check
                sw a0, 0x0010(sp)
                jal 0x800D94E8 // original routine
                lw a0, 0x0010(sp) // restore a0

                OS.routine_end(0x20)

            }

            // @ Description
            // Check if it is time to detonate the explosive for Peppy
            scope detonate_check: {
                OS.routine_begin(0x20)

                lw v0, 0x0084(a0) // v0 = player struct
                
                // load current animation frame
                lw t0, 0x0078(a0) // t0 = current animation frame
                mtc1 t0, f2
                
                // detonate on frame 25
                lui t1, 0x41C8 // t1 = 25.0
                mtc1 t1, f0
                c.eq.s f0, f2
                nop
                bc1fl _end
                nop
                
                lw t7, 0x0ADC(v0) // get grenade item struct
                beqz t7, _end // branch if no grenade
                nop

                // if here, detonate
                lw at, 0x02C0(t7) // at = current explode timer
                slti at, at, 0 // at = 0 if => detonate timer
                bnez at, _end // branch if already about to detonate
                addiu at, r0, 0
                sw at, 0x02C0(t7) // set explosion timer so it explodes soon

                _end:
                OS.routine_end(0x20)
            }

            scope air_collision: {
                addiu sp, sp,-0x0018 // allocate stack space
                sw ra, 0x0014(sp) // store ra
                li a1, air_to_ground // a1(transition subroutine) = air_to_ground
                jal 0x800DE6E4 // common air collision subroutine (transition on landing, no ledge grab)
                nop
                lw ra, 0x0014(sp) // load ra
                addiu sp, sp, 0x0018 // deallocate stack space
                jr ra // return
                nop
            }

            // @ Description
            // Subroutine which handles ground to air transition for down special actions
            scope air_to_ground: {
                addiu sp, sp,-0x0038 // allocate stack space
                sw ra, 0x001C(sp) // store ra
                sw a0, 0x0038(sp) // 0x0038(sp) = player object
                lw a0, 0x0084(a0) // a0 = player struct
                jal 0x800DEE98 // set grounded state
                sw a0, 0x0034(sp) // 0x0034(sp) = player struct
                lw v0, 0x0034(sp) // v0 = player struct
                lw a0, 0x0038(sp) // a0 = player object

                addiu a1, r0, Snake.Action.C4DETONATE
                _change_action:
                lw a2, 0x0078(a0) // a2(starting frame) = current animation frame
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1
                jal 0x800E6F24 // change action
                nop
                lw ra, 0x001C(sp) // load ra
                addiu sp, sp, 0x0038 // deallocate stack space
                jr ra // return
                nop
            }
        }
    }

    scope Grenade: {
        scope initial: {
            // TODO: drop current item being held
            addiu sp, sp, -0x0020 // ~
            sw ra, 0x001C(sp) // ~
            sw a0, 0x0020(sp) // original lines 1-3

            scope item_drop: {
                lw a1, 0x84(a0) // a1 = fighter struct
                lw at, 0x84C(a1) // held item
                beqz at, _end // if not holding an item, skip
                nop
                addiu sp, sp, -0x20
                // create vec3(0,0,0) at 0x0(sp)
                sw r0, 0x0(sp)
                sw r0, 0x4(sp)
                sw r0, 0x8(sp)
                addiu sp, sp, -0x20
                lw a0, 0x84C(a1) // a0 = held item
                addiu a1, sp, 0x20 // a1 = vel = pointer to our vec3(0,0,0)
                jal 0x80172AEC // itMainSetFighterDrop(GObj *item_gobj, Vec3f *vel, f32 throw_mul)
                lui a2, 0x3F80 // a2 = throw_mul = 1.0
                addiu sp, sp, 0x20
                addiu sp, sp, 0x20
                lw a0, 0x20(sp) // restore a0 = fighter object
                _end:
            }

            lw a0, 0x0084(a0) // a0 = player struct
            lw t6, 0x014C(a0) // t6 = kinetic state (0 = grounded, 1 = aerial)

            lw t7, 0xAE8(a0) // t7 = number of currently spawned grenades
            slti t7, t7, 0x2 // t7 = 1 if we can spawn another grenade

            bnez t6, _aerial
            nop

            _grounded:
            lli a1, Snake.Action.GRENADESTART // a1 = action
            bnez t7, change_action
            nop
            b change_action
            lli a1, Snake.Action.GRENADETHROWEMPTY // we can't spawn another one yet

            _aerial:
            lli a1, Snake.Action.GRENADESTARTAIR // a1 = action
            bnez t7, change_action
            nop
            b change_action
            lli a1, Snake.Action.GRENADETHROWEMPTYAIR // we can't spawn another one yet

            change_action:
            lw a0, 0x0020(sp) // a0 = player object
            sw r0, 0x0010(sp) // argument 4 = 0
            or a2, r0, r0 // a2 = float: 0.0
            jal 0x800E6F24 // change action
            lui a3, 0x3F80 // a3 = float: 1.0
            jal 0x800E0830 // unknown common subroutine
            lw a0, 0x0020(sp) // a0 = player object

            lw a0, 0x20(sp) // a0 = player object
            lw a1, 0x84(a0) // a1 = player struct
            sw r0, 0x17C(a1) // temp variable 1 = 0 (used for grenade reference)

            _end:
            lw a0, 0x0020(sp) // a0 = player object
            lw ra, 0x001C(sp) // ~
            addiu sp, sp, 0x0020 // ~
            jr ra // original return logic
            nop
        }

        scope Start: {
            scope main: {
                OS.routine_begin(0x80)

                sw a0, 0x0034(sp) // save 0x0034(sp) = player object
                lw a1, 0x84(a0) // a1 = player struct

                // load current animation frame
                lw t0, 0x0078(a0) // t0 = current animation frame
                mtc1 t0, f2
                
                // create item on frame 1
                lui t1, 0x4000 // t1 = 2.0F
                mtc1 t1, f0
                c.eq.s f0, f2
                nop
                bc1fl _check_animation_end
                nop

                _spawn_item:
                lw t0, 0x84(a0) // t0 = player struct
                lw t1, 0x78(t0) // t1 = player position vec3

                lw t2, 0x8E8(t0) // t2 = topjoint transform bone
                lwc1 f6, 0x40(t2) // f6 = topjoint X scale

                lw t2, 0x44(t0) // t2 = facing direction
                mtc1 t2, f8 // f8 = facing direction
                cvt.s.w f8, f8 // f8 = facing direction (float)

                mul.s f10, f6, f8 // f6 = facing direction * scale

                // Position vec3 at 0x20(sp)
                mtc1 r0, f0
                
                lwc1 f2, 0x0(t1) // f2 = player x
                lui at, 0x438C // offset x = 280.0
                mtc1 at, f4 // f4 = offset x
                mul.s f4, f4, f10 // offset * (direction * scale)
                add.s f2, f2, f4 // f2 = pos x + final offset
                swc1 f2, 0x20(sp) // x

                lwc1 f2, 0x4(t1) // f2 = player y
                lui at, 0x4361 // offset y = 225.0
                mtc1 at, f4 // f4 = offset y
                mul.s f4, f4, f6 // offset * scale
                add.s f2, f2, f4 // f2 = pos y + final offset
                swc1 f2, 0x24(sp) // y

                sw r0, 0x28(sp) // z

                // Velocity vector at 0x40(sp)
                sw r0, 0x0040(sp) // ~
                sw r0, 0x0044(sp) // ~
                sw r0, 0x0048(sp) // x/y/z velocity = (0,0,0)
            
                lli at, 0x0 // ~
                sw at, 0x0010(sp) // arg4 flags = 0x0 = ITEM_FLAG_PARENT_FIGHTER
                lw a0, 0x0034(sp) // a0 = player object
                li a1, GrenadeItem.item_info_array // a1 = grenade_item_info_array
                addiu a2, sp, 0x0020 // a2 = x/y/z coordinates
                jal GrenadeItem.SPAWN_ITEM // create item
                addiu a3, sp, 0x0040 // a3 = velocity x/y/z

                lw a0, 0x34(sp) // a0 = player object
                lw a1, 0x84(a0) // a1 = player struct
                sw v0, 0x17C(a1) // tmp variable 1 = grenade object

                _check_animation_end:
                lw a0, 0x0034(sp) // a0 = player object
                li a1, goto_next
                jal 0x800D9480 // ftAnimEndCheckSetStatus(GObj *fighter_gobj, void (*proc_status)(GObj*))
                nop
                OS.routine_end(0x80)
            }

            scope goto_next: {
                addiu sp, sp,-0x0040 // allocate stack space
                sw ra, 0x001C(sp) // ~
                sw a0, 0x0020(sp) // ~
                sw s0, 0x0024(sp) // store a0, s0, ra

                lw t6, 0x014C(a1) // t6 = kinetic state (0 = grounded, 1 = aerial)

                bnez t6, _aerial
                nop

                _grounded:
                b _continue
                lli a1, Snake.Action.GRENADEWAIT // a1(action id)

                _aerial:
                b _continue
                lli a1, Snake.Action.GRENADEWAITAIR // a1(action id)

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

            scope air_collision: {
                addiu sp, sp,-0x0018 // allocate stack space
                sw ra, 0x0014(sp) // store ra
                li a1, air_to_ground // a1(transition subroutine) = air_to_ground
                jal 0x800DE6E4 // common air collision subroutine (transition on landing, no ledge grab)
                nop
                lw ra, 0x0014(sp) // load ra
                addiu sp, sp, 0x0018 // deallocate stack space
                jr ra // return
                nop
            }

            // @ Description
            // Subroutine which handles ground to air transition for down special actions
            scope air_to_ground: {
                addiu sp, sp,-0x0038 // allocate stack space
                sw ra, 0x001C(sp) // store ra
                sw a0, 0x0038(sp) // 0x0038(sp) = player object
                lw a0, 0x0084(a0) // a0 = player struct
                jal 0x800DEE98 // set grounded state
                sw a0, 0x0034(sp) // 0x0034(sp) = player struct
                lw v0, 0x0034(sp) // v0 = player struct
                lw a0, 0x0038(sp) // a0 = player object

                addiu a1, r0, Snake.Action.GRENADESTART
                _change_action:
                lw a2, 0x0078(a0) // a2(starting frame) = current animation frame
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1
                jal 0x800E6F24 // change action
                nop
                lw ra, 0x001C(sp) // load ra
                addiu sp, sp, 0x0038 // deallocate stack space
                jr ra // return
                nop
            }
        }

        scope Wait: {
            scope main: {
                OS.routine_begin(0x80)

                sw a0, 0x0034(sp) // save 0x0034(sp) = player object
                lw a1, 0x84(a0) // a1 = player struct

                lw at, 0x14C(a1) // at = kinetic state (0 = grounded, 1 = aerial)
                bnez at, _grounded_end
                nop

                _grounded:
                // if grounded, can cancel into grab, shield
                jal 0x80148D0C // ftCommonGuardOnCheckInterruptCommon(fighter_gobj)
                lw a0, 0x0034(sp)
                bnez v0, _end // input was detected, skip to end
                nop

                jal 0x80149CE0 // ftCommonCatchCheckInterruptCommon(fighter_gobj)
                lw a0, 0x0034(sp)
                bnez v0, _end // input was detected, skip to end
                nop

                _grounded_end:
                // if not holding B, change to throw action
                lw a0, 0x0034(sp)
                lw a1, 0x84(a0) // a1 = player struct
                lh t0, 0x1BC(a1)// t0 = held button mask
                andi t1, t0, Joypad.B // t1 = zero if B is not held
                bnez t1, _end
                nop
                jal goto_next // B was released, go to throw
                nop

                _end:
                OS.routine_end(0x80)
            }

            scope goto_next: {
                addiu sp, sp,-0x0040 // allocate stack space
                sw ra, 0x001C(sp) // ~
                sw a0, 0x0020(sp) // ~
                sw s0, 0x0024(sp) // store a0, s0, ra

                lw t6, 0x014C(a1) // t6 = kinetic state (0 = grounded, 1 = aerial)

                // Note: stick range for tilts in vanilla = 20 (decimal)
                lb t7, 0x1C2(a1) // t7 = stick x
                lw t8, 0x44(a1) // t8 = facing direction
                mul t7, t7, t8 // t7 = stick x * facing direction

                bnez t6, _aerial
                nop

                _grounded:
                addiu at, r0, -20
                ble t7, at, _continue
                lli a1, Snake.Action.GRENADETHROWB // a1(action id)
                addiu at, r0, 20
                bge t7, at, _continue
                lli a1, Snake.Action.GRENADETHROWF // a1(action id)
                b _continue
                lli a1, Snake.Action.GRENADETHROWN // a1(action id)

                _aerial:
                addiu at, r0, -20
                ble t7, at, _continue
                lli a1, Snake.Action.GRENADETHROWBAIR // a1(action id)
                addiu at, r0, 20
                bge t7, at, _continue
                lli a1, Snake.Action.GRENADETHROWFAIR // a1(action id)
                b _continue
                lli a1, Snake.Action.GRENADETHROWNAIR // a1(action id)

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

            scope air_collision: {
                addiu sp, sp,-0x0018 // allocate stack space
                sw ra, 0x0014(sp) // store ra
                li a1, air_to_ground // a1(transition subroutine) = air_to_ground
                jal 0x800DE6E4 // common air collision subroutine (transition on landing, no ledge grab)
                nop
                lw ra, 0x0014(sp) // load ra
                addiu sp, sp, 0x0018 // deallocate stack space
                jr ra // return
                nop
            }

            // @ Description
            // Subroutine which handles ground to air transition
            scope air_to_ground: {
                addiu sp, sp,-0x0038 // allocate stack space
                sw ra, 0x001C(sp) // store ra
                sw a0, 0x0038(sp) // 0x0038(sp) = player object
                lw a0, 0x0084(a0) // a0 = player struct
                jal 0x800DEE98 // set grounded state
                sw a0, 0x0034(sp) // 0x0034(sp) = player struct
                lw v0, 0x0034(sp) // v0 = player struct
                lw a0, 0x0038(sp) // a0 = player object

                addiu a1, r0, Snake.Action.GRENADEWAIT
                _change_action:
                lw a2, 0x0078(a0) // a2(starting frame) = current animation frame
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1
                jal 0x800E6F24 // change action
                nop
                lw ra, 0x001C(sp) // load ra
                addiu sp, sp, 0x0038 // deallocate stack space
                jr ra // return
                nop
            }
        }

        scope Throw: {
            scope main: {
                OS.routine_begin(0x20)
                sw a0, 0x4(sp) // save player object
                lw a1, 0x84(a0) // a1 = player struct

                lw t4, 0x44(a1) // t4 = facing direction
                
                lw t0, 0x24(a1) // t0 = current action
                lui t1, 0x4100 // neutral: 8.0
                lui t2, 0x4210 // throw speed x
                lui t3, 0x4210 // throw speed y
                lli at, Snake.Action.GRENADETHROWN
                beq t0, at, _frame_check
                lli at, Snake.Action.GRENADETHROWNAIR
                beq t0, at, _frame_check
                nop
                lui t1, 0x4120 // forward: 10.0
                lui t2, 0x42C8 // throw speed x
                lui t3, 0x41A0 // throw speed y
                lli at, Snake.Action.GRENADETHROWF
                beq t0, at, _frame_check
                lli at, Snake.Action.GRENADETHROWFAIR
                beq t0, at, _frame_check
                nop
                lui t1, 0x4110 // back: 9.0
                lui t2, 0x40C0 // throw speed x
                lui t3, 0x4280 // throw speed y
                lli at, Snake.Action.GRENADETHROWB
                beq t0, at, _frame_check
                lli at, Snake.Action.GRENADETHROWBAIR
                beq t0, at, _frame_check
                nop
                
                _frame_check:
                mtc1 t1, f2 // f2 = release frame
                lwc1 f4, 0x78(a0) // f4 = current animation frame
                c.eq.s f2, f4
                nop
                bc1fl _check_animation_end
                nop

                scope _release_grenade: {
                    lw at, 0x17C(a1) // at = grenade object
                    beqz at, _check_animation_end // if there's no object, skip
                    nop

                    _set_speed:
                    lw a0, 0x17C(a1) // a0 = grenade object
                    lw a1, 0x84(a0) // a1 = item struct
                    mtc1 t4, f2 // f2 = facing direction (int)
                    cvt.s.w f2, f2 // f2 = facing direction (float)
                    mtc1 t2, f4 // f4 = throw x speed
                    mul.s f2, f2, f4 // f2 = facing direction * throw x speed
                    swc1 f2, 0x2C(a1) // set throw x speed
                    sw t3, 0x30(a1) // set throw y speed

                    _enable_hitbox:
                    lli at, 0x1
                    sw at, 0x10C(a1) // enable hitbox

                    _set_state:
                    addiu sp, sp, -0x20
                    sw a0, 0x18(sp)
                    li a1, GrenadeItem.flashbang_item_states
                    jal 0x80172EC8 // change item state
                    addiu a2, r0, 0x3 // state = 3(thrown)
                    lw a0, 0x18(sp)
                    addiu sp, sp, 0x20

                    _set_is_thrown_true:
                    // set a flag for items being thrown
                    // this makes the damage calculation consider extra damage based on speed
                    lw a1, 0x84(a0) // a1 = item struct
                    lbu at, 0x2CF(a1)
                    ori at, at, 0x20
                    sb at, 0x2CF(a1)

                    _enable_pickup:
                    // only grabbable once actually thrown/released, not
                    // while still being held/pulled by Snake
                    lw a1, 0x84(a0) // a1 = item struct
                    lbu at, 0x2CE(a1)
                    ori at, at, 0x0080
                    sb at, 0x2CE(a1)

                    _cleanup:
                    lw a0, 0x4(sp) // restore player object
                    lw a1, 0x84(a0) // a1 = player struct
                }

                _check_animation_end:
                lw t0, 0x14C(a1) // t0 = kinetic state (0 = grounded, 1 = aerial)
                bnez t0, _air
                nop

                _ground:
                jal 0x800D94C4
                nop
                b _end
                nop

                _air:
                jal 0x800D94E8
                nop

                _end:
                OS.routine_end(0x20)
            }
            
            scope air_collision: {
                addiu sp, sp,-0x0018 // allocate stack space
                sw ra, 0x0014(sp) // store ra
                li a1, air_to_ground // a1(transition subroutine) = air_to_ground
                jal 0x800DE6E4 // common air collision subroutine (transition on landing, no ledge grab)
                nop
                lw ra, 0x0014(sp) // load ra
                addiu sp, sp, 0x0018 // deallocate stack space
                jr ra // return
                nop
            }

            // @ Description
            // Subroutine which handles ground to air transition
            scope air_to_ground: {
                addiu sp, sp,-0x0038 // allocate stack space
                sw ra, 0x001C(sp) // store ra
                sw a0, 0x0038(sp) // 0x0038(sp) = player object
                lw a0, 0x0084(a0) // a0 = player struct
                jal 0x800DEE98 // set grounded state
                sw a0, 0x0034(sp) // 0x0034(sp) = player struct
                lw v0, 0x0034(sp) // v0 = player struct
                lw a0, 0x0038(sp) // a0 = player object

                lw t0, 0x24(v0)
                lli at, Snake.Action.GRENADETHROWNAIR
                beq at, t0, _change_action
                addiu a1, r0, Snake.Action.GRENADETHROWN
                lli at, Snake.Action.GRENADETHROWFAIR
                beq at, t0, _change_action
                addiu a1, r0, Snake.Action.GRENADETHROWF
                lli at, Snake.Action.GRENADETHROWBAIR
                beq at, t0, _change_action
                addiu a1, r0, Snake.Action.GRENADETHROWB
                lli at, Snake.Action.GRENADETHROWEMPTYAIR
                beq at, t0, _change_action
                addiu a1, r0, Snake.Action.GRENADETHROWEMPTY

                _change_action:
                lw a2, 0x0078(a0) // a2(starting frame) = current animation frame
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1
                jal 0x800E6F24 // change action
                nop
                lw ra, 0x001C(sp) // load ra
                addiu sp, sp, 0x0038 // deallocate stack space
                jr ra // return
                nop
            }
        }

        scope Walk: {
            scope interrupt: {
                OS.routine_begin(0x20)

                sw a0, 0x18(sp) // save a0

                _check_jump:
                jal SnakeSpecial.Grenade.JumpSquat.check_interrupt
                nop
                bnez v0, _end // skip if action was interrupted
                lw a0, 0x18(sp) // restore a0 = fighter object

                scope _check_plat_drop: {
                    lw a1, 0x84(a0) // a1 = fighter struct
                    lw at, 0xF4(a1) // at = clipping id
                    andi at, at, 0x4000 // at = 0x4000 if platform has drop-through
                    beqz at, _skip // skip if platform can't be dropped through
                    nop
                    jal 0x80141E60 // ftCommonPassCheckInputSuccess(FTStruct *fp)
                    or a0, a1, r0 // a0 = player struct
                    lw a0, 0x18(sp) // restore a0 = fighter object
                    beqz v0, _skip // skip if no plat drop input
                    lw a1, 0x84(a0) // a1 = player struct

                    // if we're here, drop from platform
                    _begin_plat_drop:
                    jal plat_drop_initial_ // begin DSPPlatDrop
                    nop
                    b _end // end
                    nop

                    _skip:
                    lw a0, 0x18(sp) // restore a0 = fighter object
                }

                lw a0, 0x84(a0) // a0 = character struct
                lb t6, 0x1c2(a0) // t6 = stick_x
                lw t7, 0x44(a0) // t7 = direction (-1/1)
                multu t6, t7
                mflo t8 // t8 = stick_x * direction

                // if stick_x * direction > 8, we're going _forward
                slti at, t8, 8 // at = 1 if stick_x * direction > 8, else at = 0
                beqz at, _forward // branch if stick_x * direction > 8
                nop
                // if stick_x * direction < -8, we're going _back
                slti at, t8, -8 // at = 1 if stick_x * direction < -8, else at = 0
                bnez at, _back // branch if stick_x * direction < -8
                nop
                // if stick_x * direction is between -8 and 8, we're neutral
                _neutral:
                b _change_action
                lli a1, Snake.Action.GRENADEWAIT

                _forward:
                b _change_action
                lli a1, Snake.Action.GRENADEWALKF

                _back:
                lli a1, Snake.Action.GRENADEWALKB

                _change_action:
                lw a0, 0x18(sp) // restore a0
                lw a2, 0x84(a0) // a2 = character struct
                lw t0, 0x0024(a2) // t0 = current action
                beq t0, a1, _end // if current action == new action, skip
                lli v0, 0x0 // ...and return 0

                OS.save_registers()
                lui a2, 0x3F80 // a2(starting frame) = 1.0
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
                sw r0, 0x0010(sp) // argument 4 = 0
                jal 0x800E6F24 // change action
                nop
                OS.restore_registers()
                lli v0, 0x1 // return 1: action was interrupted

                _end:
                OS.routine_end(0x20)
            }

            scope physics: {
                OS.routine_begin(0x20)

                sw a0, 0x18(sp) // save a0

                lw a0, 0x0084(a0) // a0 = character struct

                lw t0, 0x9c8(a0) // t0 = character attributes
                lw a2, 0x24(t0) // a2 = character traction
                li a1, 0x3E99999A // a1 = 0.3F
                
                jal 0x800D8ADC // ftPhysicsSetGroundVelStickRange(FTStruct *fp, f32 vel, f32 friction)
                nop

                jal 0x800D87D0 // ftPhysicsSetGroundVelTransferAir(GObj *fighter_gobj)
                lw a0, 0x18(sp)

                lw a0, 0x18(sp) // a0 = player object
                lw a1, 0x84(a0) // a1 = player struct
                lwc1 f4, 0x60(a1) // f4 = ground x velocity
                abs.s f4, f4 // f4 = abs(ground x velocity)
                lui at, 0x3D4C // ~
                mtc1 at, f2 // f2 = 0.05
                mul.s f2, f2, f4 // f2 = ground x velocity * 0.1
                jal 0x8000BB04 // fsm subroutine
                mfc1 a1, f2 // a1 = FSM

                OS.routine_end(0x20)
            }

            scope plat_drop_initial_: {
                OS.routine_begin(0x30)
                sw a0, 0x0018(sp) // 0x0018(sp) = player object
                lw a0, 0x0084(a0) // a0 = player struct
                jal 0x800DEEC8 // set aerial state
                sw a0,0x001C(sp) // 0x001C(sp) = player struct
                lw a0, 0x0018(sp) // a0 = player object
                lli a1, Snake.Action.GRENADEWAITAIR // a1(action id) = Action.GRENADEWAITAIR
                or a2, r0, r0 // a2(starting frame) = 0
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
                jal 0x800E6F24 // change action
                sw r0, 0x0010(sp) // argument 4 = 0
                jal 0x800E0830 // unknown common subroutine
                lw a0, 0x0018(sp) // a0 = player object
                jal 0x800D8EB8 // momentum capture?
                lw a0, 0x001C(sp) // a0 = player struct
                lw a0, 0x001C(sp) // a0 = player struct
                lw at, 0x00EC(a0) // ~
                sw at, 0x0144(a0) // ignore clipping id
                lli at, 0x00FE // ~
                sb at, 0x0269(a0) // reset stick buffer
                sw r0, 0x004C(a0) // y velocity = 0
                OS.routine_end(0x30)
            }
        }

        // Everything here is based on DK's cargo jumpsquat
        scope JumpSquat: {
            // Checks for a jump input, transitions into grenade jumpsquat
            scope check_interrupt: {
                OS.routine_begin(0x30)
                sw a0, 0x18(sp) // save fighter object

                jal 0x8013F474 // ftCommonKneeBendGetInputTypeCommon(fp)
                lw a0, 0x84(a0) // a0 = fighter struct

                beqz v0, _no_jump
                sw v0, 0x20(sp) // save v0 (input_source // jump type (stick/button))

                change_action:
                lw a0, 0x18(sp) // a0 = fighter object
                lli a1, Snake.Action.GRENADEJUMPSQUAT // a1 = action
                sw r0, 0x0010(sp) // argument 4 = 0
                or a2, r0, r0 // a2 = float: 0.0
                jal 0x800E6F24 // change action
                lui a3, 0x3F80 // a3 = float: 1.0
                // jal 0x800E0830 // unknown common subroutine
                // lw a0, 0x18(sp) // a0 = fighter object

                lw a0, 0x18(sp) // a0 = fighter object
                lw a1, 0x84(a0) // a1 = fighter struct

                // fp->status_vars.common.throwf.jump_force = fp->input.stick_range.y;
                lb t6, 0x1C3(a1)
                mtc1 t6, f2
                cvt.s.w f2, f2
                swc1 f2, 0xB18(a1)
                // fp->status_vars.common.throwf.kneebend_anim_frame = 0.0F;
                sw r0, 0xB1C(a1)
                // fp->status_vars.common.throwf.input_source = input_source;
                lw at, 0x20(sp) // load at = (input_source // jump type (stick/button))
                sw at, 0xB20(a1)
                // fp->status_vars.common.throwf.is_short_hop = FALSE;
                sw r0, 0xB24(a1)

                b _end
                lli v0, 1 // return TRUE

                _no_jump:
                or v0, r0, r0 // return FALSE

                _end:
                OS.routine_end(0x30)
            }
            
            scope main: {
                addiu sp, sp, -0x18 // ~
                sw ra, 0x0014(sp) // ~
                lw v0, 0x0084(a0) // ~
                lui at, 0x3F80 // ~
                mtc1 at, f6 // ~
                lwc1 f4, 0x0B1C(v0) // ~
                lw t6, 0x0B20(v0) // ~
                addiu at, r0, 0x0002 // ~
                add.s f8, f4, f6 // ~
                lw v1, 0x09C8(v0) // ~
                bne t6, at, branch_1 // ~
                swc1 f8, 0x0B1C(v0) // ~
                lui at, 0x4040 // ~
                mtc1 at, f10 // ~
                lwc1 f16, 0x0B1C(v0) // ~
                c.le.s f16, f10 // ~
                nop // ~
                bc1fl branch_2 // ~
                lwc1 f18, 0x0B1C(v0) // ~
                lhu t7, 0x01C0(v0) // ~
                addiu t9, r0, 0x0001 // ~
                andi t8, t7, 0x000F // ~
                beqzl t8, branch_2 // ~
                lwc1 f18, 0x0B1C(v0) // ~
                sw t9, 0x0B24(v0) // ~

                branch_1:
                lwc1 f18, 0x0B1C(v0) // ~
                branch_2:
                lwc1 f4, 0x0034(v1) // ~
                c.le.s f4, f18 // ~
                nop // ~
                bc1fl branch_3 // ~
                lw ra, 0x0014(sp) // original logic
                jal jump_initial_ // begin DSPJump
                nop
                lw ra, 0x0014(sp) // ~
                branch_3:
                addiu sp, sp, 0x18 // ~
                jr ra // original logic
                nop
            }

            scope jump_initial_: {
                addiu sp, sp, -0x40 // ~
                sw ra, 0x0024(sp) // ~
                sw s0, 0x0020(sp) // ~
                sw a0, 0x0040(sp) // ~
                lw s0, 0x0084(a0) // ~
                lw t7, 0x09C8(s0) // ~
                or a0, s0, r0 // ~
                jal 0x800DEEC8 // ~
                sw t7, 0x0038(sp) // ~
                mtc1 r0, f0 // ~
                lw a0, 0x0040(sp) // original logic
                lli a1, Snake.Action.GRENADEWAITAIR // a1(action id) = Action.DSPJump
                mfc1 a2, f0 // a2(starting frame) = 0
                j 0x8014DB30 // return
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0
            }
        }
    }

    scope Nikita: {
        scope initial: {
            addiu sp, sp, -0x0020 // ~
            sw ra, 0x001C(sp) // ~
            sw a0, 0x0020(sp) // original lines 1-3

            lw a0, 0x0084(a0) // a0 = player struct
            lw t6, 0x014C(a0) // t6 = kinetic state (0 = grounded, 1 = aerial)

            bnez t6, _aerial
            nop

            _grounded:
            b change_action
            lli a1, Snake.Action.NIKITASTART // a1 = action

            _aerial:
            b change_action
            lli a1, Snake.Action.NIKITAAIRSTART // a1 = action

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

        scope Start: {
            scope main: {
                OS.routine_begin(0x80)

                sw a0, 0x0034(sp) // save 0x0034(sp) = player object
                lw a1, 0x84(a0) // a1 = player struct

                // load current animation frame
                lw t0, 0x0078(a0) // t0 = current animation frame
                mtc1 t0, f2
                
                // create item on frame 41
                lui t1, 0x4224 // t1 = 41.0F
                mtc1 t1, f0
                c.eq.s f0, f2
                nop
                bc1fl _check_animation_end
                nop

                _spawn_projectile:
                lw t0, 0x84(a0) // t0 = player struct
                lw t1, 0x78(t0) // t1 = player position vec3

                lw t2, 0x8E8(t0) // t2 = topjoint transform bone
                lwc1 f6, 0x40(t2) // f6 = topjoint X scale

                lw t2, 0x44(t0) // t2 = facing direction
                mtc1 t2, f8 // f8 = facing direction
                cvt.s.w f8, f8 // f8 = facing direction (float)

                mul.s f10, f6, f8 // f6 = facing direction * scale

                // Position vec3 at 0x20(sp)
                mtc1 r0, f0
                
                lwc1 f2, 0x0(t1) // f2 = player x
                lui at, 0x438C // offset x = 280.0
                mtc1 at, f4 // f4 = offset x
                mul.s f4, f4, f10 // offset * (direction * scale)
                add.s f2, f2, f4 // f2 = pos x + final offset
                swc1 f2, 0x20(sp) // x

                lwc1 f2, 0x4(t1) // f2 = player y
                lui at, 0x4361 // offset y = 225.0
                mtc1 at, f4 // f4 = offset y
                mul.s f4, f4, f6 // offset * scale
                add.s f2, f2, f4 // f2 = pos y + final offset
                swc1 f2, 0x24(sp) // y

                sw r0, 0x28(sp) // z

                // Velocity vector at 0x40(sp)
                sw r0, 0x0040(sp) // ~
                sw r0, 0x0044(sp) // ~
                sw r0, 0x0048(sp) // x/y/z velocity = (0,0,0)
            
                lli at, 0x0 // ~
                sw at, 0x0010(sp) // arg4 flags = 0x0 = ITEM_FLAG_PARENT_FIGHTER
                lw a0, 0x0034(sp) // a0 = player object
                li a1, NikitaItem.item_info_array // a1 = grenade_item_info_array
                addiu a2, sp, 0x0020 // a2 = x/y/z coordinates
                jal NikitaItem.SPAWN_ITEM // create Nikita
                addiu a3, sp, 0x0040 // a3 = velocity x/y/z

                _check_animation_end:
                lw a0, 0x0034(sp) // a0 = player object
                li a1, goto_next
                jal 0x800D9480 // ftAnimEndCheckSetStatus(GObj *fighter_gobj, void (*proc_status)(GObj*))
                nop

                OS.routine_end(0x80)
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
                b _continue
                lli a1, Snake.Action.NIKITAOPERATION // a1(action id)

                _aerial:
                b _continue
                lli a1, Snake.Action.NIKITAAIROPERATION // a1(action id)

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

            scope air_collision: {
                addiu sp, sp,-0x0018 // allocate stack space
                sw ra, 0x0014(sp) // store ra
                li a1, air_to_ground // a1(transition subroutine) = air_to_ground
                jal 0x800DE6E4 // common air collision subroutine (transition on landing, no ledge grab)
                nop
                lw ra, 0x0014(sp) // load ra
                addiu sp, sp, 0x0018 // deallocate stack space
                jr ra // return
                nop
            }

            // @ Description
            // Subroutine which handles ground to air transition for down special actions
            scope air_to_ground: {
                addiu sp, sp,-0x0038 // allocate stack space
                sw ra, 0x001C(sp) // store ra
                sw a0, 0x0038(sp) // 0x0038(sp) = player object
                lw a0, 0x0084(a0) // a0 = player struct
                jal 0x800DEE98 // set grounded state
                sw a0, 0x0034(sp) // 0x0034(sp) = player struct
                lw v0, 0x0034(sp) // v0 = player struct
                lw a0, 0x0038(sp) // a0 = player object

                addiu a1, r0, Snake.Action.NIKITASTART
                _change_action:
                lw a2, 0x0078(a0) // a2(starting frame) = current animation frame
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1
                jal 0x800E6F24 // change action
                nop
                lw ra, 0x001C(sp) // load ra
                addiu sp, sp, 0x0038 // deallocate stack space
                jr ra // return
                nop
            }
        }

        scope Operation: {
            scope main: {
                OS.routine_begin(0x20)

                sw a0, 0x4(sp) // save 0x4(sp) = player object

                lw s0, 0x0084(a0) // s0 = player struct

                lw t0, 0x0AE0(s0) // t0 = pointer to nikita being controlled
                beqz t0, _goto_next // if no nikita is being controlled, cancel out
                nop

                lhu t0, 0x01BC(s0) // load held button buffer
                andi t1, t0, Joypad.Z // t1 = 0 if Z not pressed, != 0 otherwise
                bne t1, r0, _cancel_nikita // Z was pressed, cancel
                nop

                lw t0, 0x0AE0(s0) // t0 = pointer to nikita being controlled
                lw at, NikitaItem.VARIABLES.HIT_OPPONENT(t0) // at = hit opponent flag
                bnez at, _goto_success // if not 0, we hit a player
                nop

                b _end
                nop

                _cancel_nikita:
                lw t0, 0x0AE0(s0) // t0 = pointer to nikita being controlled
                lli at, 0x1
                sw at, NikitaItem.VARIABLES.DISABLED(t0) // set nikita to disabled
                sw at, 0x10C(t0) // hitbox enabled state = 1 (enable if it was disabled)
                sw at, 0x110(t0) // set damage to 1 so it registers hits
                jal 0x8017275C // itMainRefreshAttackColl(item_gobj) // make Nikita rehit opponents
                lw a0, 0x4(t0) // a0 = item object
                lw a0, 0x4(sp) // restore a0 = player object
                lw s0, 0x0084(a0) // s0 = player struct

                _goto_next:
                sw r0, 0x0AE0(s0) // set nikita pointer to 0 (cancel nikita control)
                jal goto_next // go to next action
                nop
                b _end
                nop

                _goto_success:
                sw r0, 0x0AE0(s0) // set nikita pointer to 0 (cancel nikita control)
                jal goto_success // go to next action
                nop
                b _end
                nop

                _end:
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
                b _continue
                lli a1, Snake.Action.NIKITAEND // a1(action id)

                _aerial:
                b _continue
                lli a1, Snake.Action.NIKITAAIREND // a1(action id)

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

            scope goto_success: {
                addiu sp, sp,-0x0040 // allocate stack space
                sw ra, 0x001C(sp) // ~
                sw a0, 0x0020(sp) // ~
                sw s0, 0x0024(sp) // store a0, s0, ra

                lw s0, 0x0084(a0) // s0 = player struct
                lw t6, 0x014C(s0) // t6 = kinetic state (0 = grounded, 1 = aerial)

                bnez t6, _aerial
                nop

                _grounded:
                b _continue
                lli a1, Snake.Action.NIKITASUCCESS // a1(action id)

                _aerial:
                b _continue
                lli a1, Snake.Action.NIKITAAIRSUCCESS // a1(action id)

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

            scope air_collision: {
                addiu sp, sp,-0x0018 // allocate stack space
                sw ra, 0x0014(sp) // store ra
                li a1, air_to_ground // a1(transition subroutine) = air_to_ground
                jal 0x800DE6E4 // common air collision subroutine (transition on landing, no ledge grab)
                nop
                lw ra, 0x0014(sp) // load ra
                addiu sp, sp, 0x0018 // deallocate stack space
                jr ra // return
                nop
            }

            // @ Description
            // Subroutine which handles ground to air transition for down special actions
            scope air_to_ground: {
                addiu sp, sp,-0x0038 // allocate stack space
                sw ra, 0x001C(sp) // store ra
                sw a0, 0x0038(sp) // 0x0038(sp) = player object
                lw a0, 0x0084(a0) // a0 = player struct
                jal 0x800DEE98 // set grounded state
                sw a0, 0x0034(sp) // 0x0034(sp) = player struct
                lw v0, 0x0034(sp) // v0 = player struct
                lw a0, 0x0038(sp) // a0 = player object

                addiu a1, r0, Snake.Action.NIKITAOPERATION
                _change_action:
                lw a2, 0x0078(a0) // a2(starting frame) = current animation frame
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1
                jal 0x800E6F24 // change action
                nop
                lw ra, 0x001C(sp) // load ra
                addiu sp, sp, 0x0038 // deallocate stack space
                jr ra // return
                nop
            }
        }

        scope End: {
            scope air_collision: {
                addiu sp, sp,-0x0018 // allocate stack space
                sw ra, 0x0014(sp) // store ra
                li a1, air_to_ground // a1(transition subroutine) = air_to_ground
                jal 0x800DE6E4 // common air collision subroutine (transition on landing, no ledge grab)
                nop
                lw ra, 0x0014(sp) // load ra
                addiu sp, sp, 0x0018 // deallocate stack space
                jr ra // return
                nop
            }

            // @ Description
            // Subroutine which handles ground to air transition for down special actions
            scope air_to_ground: {
                addiu sp, sp,-0x0038 // allocate stack space
                sw ra, 0x001C(sp) // store ra
                sw a0, 0x0038(sp) // 0x0038(sp) = player object
                lw a0, 0x0084(a0) // a0 = player struct
                jal 0x800DEE98 // set grounded state
                sw a0, 0x0034(sp) // 0x0034(sp) = player struct
                lw v0, 0x0034(sp) // v0 = player struct
                lw a0, 0x0038(sp) // a0 = player object

                addiu a1, r0, Snake.Action.NIKITAEND
                _change_action:
                lw a2, 0x0078(a0) // a2(starting frame) = current animation frame
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1
                jal 0x800E6F24 // change action
                nop
                lw ra, 0x001C(sp) // load ra
                addiu sp, sp, 0x0038 // deallocate stack space
                jr ra // return
                nop
            }
        }

        scope Success: {
            scope air_collision: {
                addiu sp, sp,-0x0018 // allocate stack space
                sw ra, 0x0014(sp) // store ra
                li a1, air_to_ground // a1(transition subroutine) = air_to_ground
                jal 0x800DE6E4 // common air collision subroutine (transition on landing, no ledge grab)
                nop
                lw ra, 0x0014(sp) // load ra
                addiu sp, sp, 0x0018 // deallocate stack space
                jr ra // return
                nop
            }

            // @ Description
            // Subroutine which handles ground to air transition for down special actions
            scope air_to_ground: {
                addiu sp, sp,-0x0038 // allocate stack space
                sw ra, 0x001C(sp) // store ra
                sw a0, 0x0038(sp) // 0x0038(sp) = player object
                lw a0, 0x0084(a0) // a0 = player struct
                jal 0x800DEE98 // set grounded state
                sw a0, 0x0034(sp) // 0x0034(sp) = player struct
                lw v0, 0x0034(sp) // v0 = player struct
                lw a0, 0x0038(sp) // a0 = player object

                addiu a1, r0, Snake.Action.NIKITASUCCESS
                _change_action:
                lw a2, 0x0078(a0) // a2(starting frame) = current animation frame
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1
                jal 0x800E6F24 // change action
                nop
                lw ra, 0x001C(sp) // load ra
                addiu sp, sp, 0x0038 // deallocate stack space
                jr ra // return
                nop
            }
        }
    }

    scope Cypher: {
        // Cypher's damage-based armor threshold (see Hang scope). Shared with
        // Start.goto_next, which primes fp->damage_resist to this same value
        // before Hang's first frame ever runs.
        constant DAMAGE_RESIST_THRESHOLD(7)

        // Refreshes USP flag when hit
        scope Refresh: {
            jr ra
            sw r0, 0x0AE4(a0) // set usp bool to FALSE
        }

        Character.table_patch_start(on_hit, Character.id.SNAKE, 0x4)
        dw Refresh;
        OS.patch_end()

        scope initial: {
            addiu sp, sp, -0x0020 // ~
            sw ra, 0x001C(sp) // ~
            sw a0, 0x0020(sp) // original lines 1-3

            lw a0, 0x0084(a0) // a0 = player struct
            lw t6, 0x014C(a0) // t6 = kinetic state (0 = grounded, 1 = aerial)
            
            _flag_check:
            lw at, 0x0AE4(a0) // at = usp flag
            bnez at, _end // if flag is not zero, do not usp
            nop

            lli at, 0x1
            sw at, 0x0AE4(a0) // set usp flag to TRUE

            bnez t6, _aerial
            nop

            _grounded:
            b change_action
            lli a1, Snake.Action.CYPHERSTART // a1 = action

            _aerial:
            b change_action
            lli a1, Snake.Action.CYPHERAIRSTART // a1 = action

            change_action:
            lw a0, 0x0020(sp) // a0 = player object
            sw r0, 0x0010(sp) // argument 4 = 0
            or a2, r0, r0 // a2 = float: 0.0
            jal 0x800E6F24 // change action
            lui a3, 0x3F80 // a3 = float: 1.0
            jal 0x800E0830 // unknown common subroutine
            lw a0, 0x0020(sp) // a0 = player object
            
            // reset fall speed
            lw s0, 0x0084(a0) // s0 = player struct
            lbu at, 0x018D(s0) // at = fast fall flag
            ori t6, r0, 0x0007 // t6 = bitmask (01111111)
            and at, at, t6 // ~
            sb at, 0x018D(s0) // disable fast fall flag

            // take mid-air jumps away at this point
            lw t0, 0x09C8(s0) // t0 = attribute pointer
            lw t0, 0x0064(t0) // t0 = max jumps
            sb t0, 0x0148(s0) // jumps used = max jumps

            // set tmp variable 1 to 0 (Cypher object reference)
            sw r0, 0x17C(s0) // temp variable 1 = 0

            _end:
            lw a0, 0x0020(sp) // a0 = player object
            lw ra, 0x001C(sp) // ~
            addiu sp, sp, 0x0020 // ~
            jr ra // original return logic
            nop
        }

        scope Start: {
            scope main: {
                OS.routine_begin(0x80)

                sw a0, 0x0034(sp) // save 0x0034(sp) = player object

                // load current animation frame
                lw t0, 0x0078(a0) // t0 = current animation frame
                mtc1 t0, f2
                
                // create item on frame 4
                lui t1, 0x4080 // t1 = 4.0
                mtc1 t1, f0
                c.eq.s f0, f2
                nop
                bc1fl _check_animation_end
                nop

                lw v0, 0x0084(a0) // v0 = player struct
                sw r0, 0x0040(sp) // ~
                sw r0, 0x0044(sp) // ~
                sw r0, 0x0048(sp) // unknown x/y/z offset?
                addiu a1, sp, 0x0020
                mtc1 r0, f0
                swc1 f0, 0x0020(sp) // x offset
                swc1 f0, 0x0024(sp) // y offset
                swc1 f0, 0x0028(sp) // z offset
                lw a0, 0x0928(v0) // a0 = part 0xC (right hand) struct
                sw a3, 0x0030(sp)
                jal 0x800EDF24 // gmCollisionGetFighterPartsWorldPosition(DObj *main_dobj, Vec3f *vec) (part, &offset) (updates vec3 in a1)
                sw v0, 0x002C(sp)
                sw r0, 0x0008(a1) // z coordinate = 0
                li at, 0x80000002 // ~
                sw at, 0x0010(sp) // unknown argument = 0x80000002
                lw a0, 0x0034(sp) // a0 = player object
                li a1, CypherItem.item_info_array // a1 = grenade_item_info_array

                addiu a2, sp, 0x0020 // a2 = x/y/z coordinates
                jal CypherItem.SPAWN_ITEM // create flashbang
                addiu a3, sp, 0x0040 // a3 = unknown x/y/z offset

                lw a0, 0x0034(sp) // a0 = player object
                lw t0, 0x0084(a0) // t0 = player struct
                sw v0, 0x017C(t0) // temp variable 1 = reference to Cypher object

                _check_animation_end:
                lw a0, 0x0034(sp) // a0 = player object
                li a1, goto_next
                jal 0x800D9480 // ftAnimEndCheckSetStatus(GObj *fighter_gobj, void (*proc_status)(GObj*))
                nop

                OS.routine_end(0x80)
            }

            scope goto_next: {
                addiu sp, sp,-0x0040 // allocate stack space
                sw ra, 0x001C(sp) // ~
                sw a0, 0x0020(sp) // ~
                sw s0, 0x0024(sp) // store a0, s0, ra

                lw s0, 0x0084(a0) // s0 = player struct
                lw t6, 0x014C(s0) // t6 = kinetic state (0 = grounded, 1 = aerial)

                bnez t6, _continue
                nop

                _set_aerial:
                jal 0x800DEEC8 // set aerial state
                or a0, s0, r0 // a0 = player struct

                _continue:
                lw a0, 0x0020(sp) // a0 = player object
                lli a1, Snake.Action.CYPHERAIRHANG // a1(action id)
                or a2, r0, r0 // a2(starting frame) = 0
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0x
                jal 0x800E6F24 // change action
                sw r0, 0x0010(sp) // argument 4 = 0

                // Prime damage_resist before Hang.main's first frame can read it, so it
                // doesn't mistake leftover/garbage data for an already-absorbed hit.
                lw t0, 0x0020(sp) // t0 = player object
                lw t0, 0x0084(t0) // t0 = player struct
                lli t1, DAMAGE_RESIST_THRESHOLD
                sw t1, 0x30(t0) // fp->damage_resist

                jal 0x800E0830 // unknown common subroutine
                lw a0, 0x0020(sp) // a0 = player object

                _end:
                lw ra, 0x001C(sp) // ~
                lw s0, 0x0024(sp) // load s0
                jr ra // return
                addiu sp, sp, 0x0040 // deallocate stack space
            }

            scope air_collision: {
                addiu sp, sp,-0x0018 // allocate stack space
                sw ra, 0x0014(sp) // store ra
                li a1, air_to_ground // a1(transition subroutine) = air_to_ground
                jal 0x800DE6E4 // common air collision subroutine (transition on landing, no ledge grab)
                nop
                lw ra, 0x0014(sp) // load ra
                addiu sp, sp, 0x0018 // deallocate stack space
                jr ra // return
                nop
            }

            // @ Description
            // Subroutine which handles ground to air transition for down special actions
            scope air_to_ground: {
                addiu sp, sp,-0x0038 // allocate stack space
                sw ra, 0x001C(sp) // store ra
                sw a0, 0x0038(sp) // 0x0038(sp) = player object
                lw a0, 0x0084(a0) // a0 = player struct
                jal 0x800DEE98 // set grounded state
                sw a0, 0x0034(sp) // 0x0034(sp) = player struct
                lw v0, 0x0034(sp) // v0 = player struct
                lw a0, 0x0038(sp) // a0 = player object

                addiu a1, r0, Snake.Action.CYPHERSTART
                _change_action:
                lw a2, 0x0078(a0) // a2(starting frame) = current animation frame
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1
                jal 0x800E6F24 // change action
                nop
                lw ra, 0x001C(sp) // load ra
                addiu sp, sp, 0x0038 // deallocate stack space
                jr ra // return
                nop
            }
        }

        scope Hang: {
            constant RISE_ACCEL(0x40C0) // 6.0
            constant MAX_RISE_SPEED(0x4220) // 40.0
            constant CANCEL_FRAME(20) // ssbu: 40

            scope main: {
                OS.routine_begin(0x20)

                lw s0, 0x0084(a0) // s0 = player struct

                _credit_absorbed_damage:
                // fp->damage_resist is reset to DAMAGE_RESIST_THRESHOLD every frame below. If a hit
                // landed since then, the native armor consumes it out of this same field instead of
                // applying percent damage - so whatever it's been brought down to by the time we get
                // back here next frame tells us how much damage was silently absorbed.
                lw t0, 0x30(s0) // t0 = damage_resist as left by any hit since our last reset
                slti at, t0, DAMAGE_RESIST_THRESHOLD // at = 1 if a hit brought it below our last reset value
                beqz at, _set_armor // skip if unchanged (no hit landed)
                nop
                addiu t2, r0, DAMAGE_RESIST_THRESHOLD // t2 = threshold
                subu t2, t2, t0 // t2 = threshold - remaining value = damage absorbed

                sw a0, 0x0018(sp) // save player object across these calls

                or a1, t2, r0 // a1 = damage absorbed
                jal Character.add_percent_ // adds to percent AND refreshes the HUD display, unlike a raw field write
                or a0, s0, r0 // a0 = player struct

                // Armor bypasses the whole native hit pipeline, so hitlag never gets set either - apply it manually
                or a0, t2, r0 // a0 = damage absorbed
                lw a1, 0x24(s0) // a1 = current action
                jal 0x800EA1C0 // gmCommon_DamageCalcHitLag(s32 damage, s32 status_id, f32 hitlag_mul)
                lui a2, 0x3F80 // a2 = hitlag multiplier 1.0
                sw v0, 0x40(s0) // apply hitlag to snake

                lw a0, 0x0018(sp) // restore player object for the rest of this routine

                _set_armor:
                // Cypher armor is non-cumulative. Which means multiple weaker hits won't sum up to break it.
                // fp->is_damage_resist = TRUE; (enable damage based armor)
                lbu at, 0x191(s0)
                ori at, at, 0x20
                sb at, 0x191(s0)

                lli at, DAMAGE_RESIST_THRESHOLD
                sw at, 0x30(s0) // fp->damage_resist (set damage based armor)

                _set_usp_flag:
                // reinforce the usp flag in case we started while grounded
                lli at, 0x1
                sw at, 0x0AE4(s0) // set usp flag to TRUE

                _remove_jumps:
                // take mid-air jumps
                lw t0, 0x09C8(s0) // t0 = attribute pointer
                lw t0, 0x0064(t0) // t0 = max jumps
                sb t0, 0x0148(s0) // jumps used = max jumps

                _accelerate_upwards:
                lwc1 f4, 0x4C(s0)
                lui at, RISE_ACCEL
                mtc1 at, f6
                add.s f4, f4, f6 // yspeed = yspeed + RISE_ACCEL
                swc1 f4, 0x4C(s0) // save new yspeed

                _cap_max_rise_speed:
                lui at, MAX_RISE_SPEED
                mtc1 at, f6

                c.le.s f6, f4 // max rise speed <= current speed
                bc1fl _check_animation_end // if not, skip
                nop

                swc1 f6, 0x4C(s0) // set speed to max rise speed

                _check_animation_end:
                li a1, goto_next
                jal 0x800D9480 // ftAnimEndCheckSetStatus(GObj *fighter_gobj, void (*proc_status)(GObj*))
                nop

                // if the cypher object is destroyed, go to goto_next
                lw t0, 0x17C(s0) // t0 = temp variable 1 (Cypher object reference)
                bnez t0, _end // if Cypher object reference is not 0, skip
                nop
                sw r0, 0x4C(s0) // set yspeed to 0
                jal goto_next // if Cypher object reference is 0, go to next action
                nop

                _end:
                OS.routine_end(0x20)
            }

            scope goto_next: {
                addiu sp, sp,-0x0040 // allocate stack space
                sw ra, 0x001C(sp) // ~
                sw a0, 0x0020(sp) // ~
                sw s0, 0x0024(sp) // store a0, s0, ra

                lw s0, 0x0084(a0) // s0 = player struct

                _continue:
                lw a0, 0x0020(sp) // a0 = player object
                lli a1, Snake.Action.CYPHERAIRCUT // a1(action id)
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

            scope interrupt: {
                OS.routine_begin(0x20)

                sw a0, 0x18(sp) // save a0
                
                lw s0, 0x0084(a0) // s0 = player struct
                lw t0, 0x1C(s0) // t0 = current frame (int)

                slti at, t0, CANCEL_FRAME
                bnez at, _end // cannot interrupt until frame 40
                nop

                _interrupt_action:
                jal 0x8013F660 // jump action interrupt subroutine
                nop
                bnez v0, _end // in case we cancelled to an action, perform that
                nop

                _interrupt_down:
                lw a0, 0x18(sp) // load a0 = player object
                lw s0, 0x84(a0) // s0 = player struct

                lb t1, 0x01C3(s0) // t1 = stick_y
                slti at, t1, -53 // if stick_y < -53 (FTCOMMON_FASTFALL_STICK_RANGE_MIN)
                beqz at, _end // if not holding down enough, skip
                nop

                // lbu t6,0x269(s0) // number of frames the player has held DOWN on the stick
                // slti at, t6, 4 // if been holding down for more than FTCOMMON_FASTFALL_BUFFER_TICS_MAX, skip
                // beqz at, _end
                // nop

                _interrupt_down_change_action:
                lli a1, Snake.Action.CYPHERAIRCUT // a1(action id)
                or a2, r0, r0 // a2(starting frame) = 0
                lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0x
                jal 0x800E6F24 // change action
                sw r0, 0x0010(sp) // argument 4 = 0

                _end:
                OS.routine_end(0x20)
            }
        }
    }

    scope Taunt: {
        scope main: {
            OS.routine_begin(0x20)

            lw t0, 0x0078(a0) // t0 = current animation frame
            lui t1, 0x4000 // t1 = 1.0F

            // if frame != 1, skip
            bne t0, t1, _check_animation_end
            nop

            _goto_random_taunt:
            addiu sp, sp, -0x18 // save variables
            sw a0, 0x4(sp)
            sw v0, 0x8(sp)
            sw ra, 0xC(sp)

            jal Global.get_random_int_ // v0 = (random value)
            lli a0, 0x8 // a0 = random max (non inclusive, so 0-7)

            or t0, r0, v0 // t0 = random result

            lw a0, 0x4(sp)
            lw v0, 0x8(sp)
            lw ra, 0xC(sp)
            addiu sp, sp, 0x18 // restore variables

            // here, t0 = random value
            // Colonel (don't change action)
            lli t1, 0x0
            beq t0, t1, _check_animation_end
            nop
            lli t1, 0x1
            beq t0, t1, _check_animation_end
            nop

            // Mei Ling
            lli a1, Snake.Action.TAUNT_MEILING
            lli t1, 0x2
            beq t0, t1, _change_action
            lli t1, 0x3
            beq t0, t1, _change_action
            nop

            // Otacon
            lli a1, Snake.Action.TAUNT_OTACON
            lli t1, 0x4
            beq t0, t1, _change_action
            lli t1, 0x5
            beq t0, t1, _change_action
            nop

            // Falcon
            lli a1, Snake.Action.TAUNT_FALCON
            lli t1, 0x6
            beq t0, t1, _change_action
            nop

            // Slippy
            lli a1, Snake.Action.TAUNT_SLIPPY
            lli t1, 0x7
            beq t0, t1, _change_action
            nop

            _change_action:
            addiu sp, sp, -0x0020
            sw ra, 0x001C(sp)
            sw a0, 0x0020(sp)

            lw a0, 0x0020(sp) // a0 = player object
            lw a2, 0x0078(a0) // a2(starting frame) = current animation frame
            lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0x
            jal 0x800E6F24 // change action
            sw r0, 0x0010(sp) // argument 4 = 0
            jal 0x800E0830 // unknown common subroutine
            lw a0, 0x0020(sp) // a0 = player object

            lw a0, 0x0020(sp)
            lw ra, 0x001C(sp)
            addiu sp, sp, 0x0020

            _check_animation_end:
            jal 0x800D94C4 // ftAnimEndSetWait(GObj *fighter_gobj)
            nop

            OS.routine_end(0x20)
        }
    }
}