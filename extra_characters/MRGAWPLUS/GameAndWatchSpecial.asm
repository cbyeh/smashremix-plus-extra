// GameAndWatchSpecial.asm

// This file contains subroutines used by Game and Watch's special moves.

scope GameAndWatchScale {
    // @ Description
    // Scales G&W's model depending on his facing direction, hides overlapping outlines.
    scope adjust_scale_for_direction_: {
        OS.patch_start(0x5D870, 0x800E2070)
        jal     adjust_scale_for_direction_
        addiu   t8, t7, 0x001C              // original line 1
        OS.patch_end()

        // s1 = player struct
        lw      t3, 0x0008(s1)              // t3 = character id
        lli     t2, Character.id.MRGAWPLUS  // t2 = id.MRGAWPLUS
        beq     t3, t2, _move_check         // skip if character isn't MRGAWPLUS
        nop
        addiu   t2, -1      		    // t2 = id.MRGAW
        bne     t3, t2, _end                // skip if character isn't MRGAW

        _move_check:
        lw      t0, 0x0024(s1)              // t0 = current action
        lli     t1, Action.Appear1         // t1 = Action.Appear1
        beq     t0, t1, _end   // skip if current action = Appear1
        nop
        lli     t1, Action.Appear2         // t1 = Action.Appear2
        beq     t0, t1, _end   // skip if current action = Appear2
        nop

        lw      t3, 0x08E8(s1)              // t3 = topjoint
        lwc1    f2, 0x0044(s1)              // ~
        cvt.s.w f2, f2                      // ~
        neg.s   f2, f2                      // f2 = -direction
        lwc1    f4, 0x0040(t3)              // ~
        abs.s   f4, f4                      // f4 = |topjoint x scale|
        mul.s   f4, f4, f2                  // ~
        swc1    f4, 0x0040(t3)              // topjoint x scale = |scale| * -direction
        lw      t3, 0x08F8 + 0xD*4(s1)      // t3 = weapon joint
        lwc1    f4, 0x0040(t3)              // ~
        abs.s   f4, f4                      // f4 = |weapon x scale|
        mul.s   f4, f4, f2                  // ~
        swc1    f4, 0x0040(t3)              // weapon x scale = |scale| * -direction
        lw      t3, 0x08F8 + 0x18*4(s1)     // t3 = grab joint
        beqz    t3, _end                    // skip if no grab joint
        nop
        lwc1    f4, 0x0040(t3)              // ~
        abs.s   f4, f4                      // f4 = |grab joint x scale|
        mul.s   f4, f4, f2                  // ~
        swc1    f4, 0x0040(t3)              // grab joint x scale = |scale| * -direction

        _end:
        jr      ra
        sw      t8, 0x0068(sp)              // original line 2
    }
}

scope GameAndWatchNSP {
    // @ Description

    constant RELEASE_FRAME(0x4180) // 16
    constant SAUSAGE_SCALE(0x3F40) // 0.75

    // new code below
    //angle_info:
    //float32 1.0472                      // 0x00 - Default Angle (60 degrees)
    //float32 0.436332                    // 0x04 - Angle Spread (25 degrees)
    // end new code

    // main subroutine for MRGAWPLUS's Chef
    scope main: {
        addiu   sp, sp, -0x0040
        sw      ra, 0x0014(sp)
        swc1    f6, 0x003C(sp)
        swc1    f8, 0x0038(sp)
        sw      a0, 0x0034(sp)
        addu    a2, a0, r0
        lw      v0, 0x0084(a0)                      // loads player struct

        or      a3, a0, r0
        lw      t6, 0x017C(v0)
        beql    t6, r0, _idle_transition_check      // this checks moveset variables to see if projectile should be spawned
        lw      ra, 0x0014(sp)
        mtc1    r0, f0
        sw      r0, 0x017C(v0)                      // clears out variable so he only fires one shot
        addiu   a1, sp, 0x0020
        swc1    f0, 0x0024(sp)                      // y origin point
        swc1    f0, 0x0028(sp)                      // z origin point

	lui     t0, 0x4300
	mtc1	t0, f0				    
	swc1    f0, 0x0020(sp)                      // x origin point
	mtc1    r0, f0
        lw      a0, 0x0928(v0)
        sw      a3, 0x0030(sp)
        jal     0x800EDF24                          // generic function used to determine projectile origin point
        sw      v0, 0x002C(sp)
        lw      v0, 0x002C(sp)
        lw      a3, 0x0030(sp)
        sw      r0, 0x001C(sp)
        or      a0, a3, r0
        addiu   a1, sp, 0x0020
        jal     projectile_stage_setting            // this sets the basic features of a projectile
        lw      a2, 0x001C(sp)
        lw      a2, 0x0034(sp)
        lw      ra, 0x0014(sp)

        // checks frame counter to see if reached end of the move
        _idle_transition_check:
        mtc1    r0, f6
        lwc1    f8, 0x0078(a2)
        c.le.s  f8, f6
        nop
        bc1fl   _end
        lw      ra, 0x0014(sp)
	
	lw      a0, 0x0034(sp)
	lw      v0, 0x0084(a0)              // v0 = player struct
	or      t2, r0, r0	    	    // ~
        sw      t2, 0x0184(v0)              // temp variable 3 = 0

        lw      a2, 0x0034(sp)
        jal     0x800DEE54
        or      a0, a2, r0
        _end:
        lw      a0, 0x0034(sp)
        lwc1    f6, 0x003C(sp)
        lwc1    f8, 0x0038(sp)
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0040
        jr      ra
        nop

        projectile_stage_setting:
        addiu   sp, sp, -0x0050
        sw      a2, 0x0038(sp)
        lw      t7, 0x0038(sp)
        sw      s0, 0x0018(sp)
        li      s0, _blaster_fireball_struct       // load blaster format address

        sw      a1, 0x0034(sp)
        sw      ra, 0x001C(sp)
        lw      t6, 0x0084(a0)
        lw      t0, 0x0024(s0)
        lw      t1, 0x0028(s0)
        li      a1, _blaster_projectile_struct      // load projectile addresses
        lw      a2, 0x0034(sp)
        lui     a3, 0x8000
        sw      t6, 0x002C(sp)          // 0x002C(sp) = player struct
        //sw      t0, 0x0008(a1)        // would revise default pointer, which has another pointer, which is to the hitbox data
        jal     0x801655C8                // This is a generic routine that does much of the work for defining all projectiles
        sw      t1, 0x000C(a1)

        bnez    v0, _projectile_branch
        sw      v0, 0x0028(sp)
        beq     r0, r0, _end_stage_setting
        or      v0, r0, r0

        _projectile_branch:
        lw      v1, 0x0084(v0)
        lui     t2, 0x3f80              // load 1(fp) into f2
        addiu   at, r0, 0x0001
        mtc1    r0, f4
        sw      t2, 0x029C(v1)           // save 1(fp) to projectile struct free space
        lw      t3, 0x0000(s0)
        sw      t3, 0x0268(v1)

	lli   t3, 0x0022		// make medium punch the hit sound
	sh    t3, 0x0146(v1)

	lli   at, 0x0025		// set projectile bkb to 37
	sw    at, 0x0138(v1)

	lli   at, 0x0023		// set projectile kbs to 35
	sw    at, 0x0130(v1)

	sw    r0, 0x010C(v1)	        // make damage type normal

	lli   at, 0x0005		// change damage to 5
	sw    at, 0x0104(v1)

	// end new code


	mtc1    r0, f4                      // f4 = 0
        swc1    f4, 0x0028(v1)              // set z speed? to 0

	lw	t5, 0x002C(sp)		    //0x0084(a0)
        lb      t6, 0x01C2(t5)              // t6 = stick_x
	mtc1    t6, f12                     // f12 = stick_x
	cvt.s.w f12, f12                    // f12 = stick_x
	nop
        lwc1      f2, 0x0044(t5)            // f2 = DIRECTION
        cvt.s.w f2, f2                      // f2 = stick_x
	nop
        mul.s   f2, f2, f12                 // f2 = stick_x * direction
	lwc1    f12, 0x0018(s0)             // f12 = initial angle (ground)
        lwc1    f12, 0x001C(s0)             // f12 = initial angle (air)
	swc1    f12, 0x0020(sp)             // 0x0020(sp) = adjusted angle
	c.lt.s  f2, f4                      // if f2 < 0
        nop                                 // ~
        bc1t    _increase_angle             // branch to increase angle (makes projectile go more vertical) stick_x * direction < 0
        nop

		c.lt.s  f4, f2                      // if f2 > 0
        nop                                 // ~
        bc1t    _decrease_angle             // branch to decrease angle (makes projectile go more horizontal) stick_x * direction > 0
        nop

	beq		r0, r0, _after_angle_set	// branch here if joystick is not tilted (do nothing to angle)
	nop

	_increase_angle:
	lui     t6, 0x3ea0                  // ~
        mtc1    t6, f6                      // f6 = 0.3125 (used to be 3ec0 or 0.375)
        add.s   f12, f12, f6                // f12 = adjusted angle (initial angle + adjustment)
        swc1    f12, 0x0020(sp)             // 0x0020(sp) = adjusted angle
	nop
	beq		r0, r0, _after_angle_set	// branch here if joystick is not tilted (do nothing to angle)
	nop

	_decrease_angle:
	lui     t6, 0x3ec0                  // ~
        mtc1    t6, f6                      // f6 = 0.375
        sub.s   f12, f12, f6                // f12 = adjusted angle (initial angle - adjustment)
	swc1    f12, 0x0020(sp)             // 0x0020(sp) = adjusted angle
	nop

	_after_angle_set:
	jal      0x80035CD0      			// cos(ANGLE)
	sw     v1, 0x0024(sp)				// something to do with the call above?

        lw      t6, 0x002C(sp)				// t6 = projectile struct (0x0084(a0))
        lw      v1, 0x0024(sp)				// something to do with the cos call?
        lw      t7, 0x0044(t6)				// t7 = player direction
		lwc1    f6, 0x0020(s0)           	// load speed (integer)
        mul.s   f8, f0, f6					// ~
        lwc1    f12, 0x0020(sp)				// load the now modified angle
        mtc1    t7, f10						// ~
        nop									// ~
        cvt.s.w f16, f10					// ~
        mul.s   f18, f8, f16				// ~
        jal     0x800303F0					// sin(ANGLE)
        swc1    f18, 0x0020(v1)				// somehow this is the original logic?

        lwc1    f4, 0x0020(s0)
        lw      v1, 0x0024(sp)				// something to do with the call above?
        lw      a0, 0x0028(sp)
        mul.s   f6, f0, f4
        swc1    f6, 0x0024(v1)
        lw      t8, 0x0074(a0)
        lwc1    f10, 0x002C(s0)
        lw      t9, 0x0080(t8)
        // This ensures the projectile faces the correct direction
        jal     0x80167FA0
        swc1    f10, 0x0088(t9)
        lw      v0, 0x0028(sp)

        _end_stage_setting:
        lw      ra, 0x001C(sp)
        lw      s0, 0x0018(sp)
        addiu   sp, sp, 0x0050
        jr      ra
        nop

        // this subroutine seems to have a variety of functions, but definetly deals with the duration of move and result at the end of duration
        blaster_duration:
        addiu   sp, sp, -0x0024
        sw      ra, 0x0014(sp)
        sw      a0, 0x0020(sp)
        swc1    f10, 0x0024(sp)
        lw      a0, 0x0084(a0)

	// new code here to check duration
	// credit to halofactory and Shino for the code
	jal     0x80167FE8      // check if duration is over
        sw      a0, 0x001C(sp)  // store a0
        bnez    v0, _end_duration        // branch if duration over
        addiu   v0, r0, 1       // return 1 (destroy projectile)
        lw      a0, 0x001C(sp)  // if here, restore a0
	// end new code

        _continue:
        addiu   t8, r0, r0          // used to use free space area, but for no apparent reason, affects graphics
        //lw      t8, 0x029C(a0)
        li      t0, _blaster_fireball_struct
        addu    v0, r0, t0
        lw      a1, 0x000C(v0)
        lw      a2, 0x0004(v0)
        lw      t1, 0x0020(sp)
        addiu   t2, r0, r0          // used to use free space area, but for no apparent reason, effects graphics
        lw      v1, 0x0074(t1)
        or      v0, r0, r0
        lwc1    f8, 0x0024(a0)      // load current speed (y speed/gravity)

        lui     at, 0xBF84          // y speed decreases by 1.03125 every frame
        mtc1    at, f6              // move speed addition to floating point register
	add.s	f8, f8, f6
        swc1    f8, 0x0024(a0)      // save new speed amount to projectile hitbox information (y speed/gravity)

	_initial_rotation:
	li      t0, _blaster_fireball_struct
        lw      t1, 0x0020(sp)      // t1 = projectile object
        lw      v1, 0x0074(t1)      // v1 = top joint
        lwc1    f4, 0x0030(v1)      // f4 = current rotation value
        lwc1    f6, 0x0014(t0)      // f6 = what to rotate by
        add.s   f8, f4, f6          // f8 = new rotation value
        swc1    f8, 0x0030(v1)      // update rotation value

        _scaling:
	lui	at, SAUSAGE_SCALE
	mtc1	at, f6
        swc1    f6, 0x0040(v1)      // store x size multiplier to projectile joint
        swc1    f6, 0x0044(v1)      // store y size multiplier to projectile joint

        _end_duration:
        lw      ra, 0x0014(sp)
        lwc1    f10, 0x0024(sp)
        addiu   sp, sp, 0x0024
        jr      ra
        nop

        _hitbox_end:
        OS.copy_segment(0xE396C, 0x38)
        // swc1 f4, 0x0148(v0)
        OS.copy_segment(0xE39A8, 0x30)

        // this subroutine determines the behavior of the projectile upon reflection
        blaster_reflection:
        addiu   sp, sp, -0x0018
        sw      ra, 0x0014(sp)
        sw      a0, 0x0018(sp)
        lw      a0, 0x0084(a0)      // loads active projectile struct
        lw      t0, 0x0008(v0)
        addiu   t7, r0, Character.id.MRGAWPLUS
        bnel    t0, t7, _standard
        lui     t7, 0x3F80          // load normal reflect multiplier if not MRGAWPLUS and thereby top speed of MRGAWPLUS projectile will not increase
        li      t7, 0x3FC90FDB      // load reflect multiplier
        _standard:
        mtc1    t7, f4              // move reflect multiplier to floating point
        sw      t7, 0x029C(a0)      // save multiplier to free space to increase max speed
        lw      t7, 0x0008(a0)
        li      t0, _blaster_fireball_struct // load fireball struct to pull parameters
        lw      t0, 0x0000(t0)      // loads max duration from fireball struct
        sw      t0, 0x0268(a0)      // save max duration to active projectile struct current remaining duration
        lw      a1, 0x0084(t7)      // loads reflective character's struct

        // Before determining new direction, multiply speed.
        lw      t6, 0x0044(a1)      // loads player direction 1 or -1 in fp
        lwc1    f0, 0x0020(a0)      // loads projectile velocity
        mul.s   f0, f0, f4          // multiply current speed by reflection speed multiplier
        nop
        swc1    f0, 0x0020(a0)      // save new speed
        nop
        jal     0x801680EC          // go to the default subroutine that determines direction
        nop

        _branch:
        lw      a0, 0x0018(sp)
        lw      v0, 0x0084(a0)      // load active projectile struct
        mtc1    r0, f6              // move 0 to f6
        lwc1    f4, 0x0020(v0)      // load current velocity of projectile
        c.le.s  f6, f4              // compare 0 to current velocity to see if now traveling leftward
        nop
        bc1f    _left               // jump if 0 is greater than velocity, this means the projectile is traveling leftward
        nop
        li        at, 0x3FC90FDB
        mtc1      at, f8
        lw      t6, 0x0074(a0)
        j       _end_reflect
        swc1    f8, 0x0034(t6)
        _left:
        li        at, 0xBFC90FDB
        mtc1      at, f10
        lw      t7, 0x0074(a0)
        swc1    f10, 0x0034(t7)
        _end_reflect:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0018
        or      v0, r0, r0
        jr      ra
        nop


        _blaster_projectile_struct:
        dw 0x00000000                   // this has some sort of bit flag to tell it to use secondary type display list?
        dw 0x00000000
        dw Character.MRGAWPLUS_file_6_ptr     // pointer to file
        dw 0x00000000                   // 00000000
        dw 0x12480000                   // rendering routine?
        dw blaster_duration             // duration (default 0x80168540) (samus 0x80168F98)
        dw 0x80175914                   // collision (0x801685F0 - Mario) (0x80169108 - Samus)
        dw 0x80175958                   // after_effect 0x801691FC, this one is used when grenade connects with player
        dw 0x80175958                   // after_effect 0x801691FC, used when touched by player when object is still, by setting to null, nothing happens
        dw 0x8016DD2C                   // determines behavior when projectile bounces off shield, this uses Master Hand's projectile coding to determine correct angle of graphic (0x8016898C Fox)
        dw 0x80175958                   // after_effect                // rocket_after_effect 0x801691FC
        dw blaster_reflection           // OS.copy_segment(0x1038FC, 0x04)            // this determines reflect behavior (default 0x80168748)
        dw 0x80175958                   // This function is run when the projectile is used on ness while using psi magnet
        OS.copy_segment(0x103904, 0x0C) // empty


        _blaster_fireball_struct:
        dw 110                          // 0x0000 - duration (int)
        float32 100                     // 0x0004 - max speed
        float32 -100                    // 0x0008 - min speed
	float32 3                       // 0x000C - gravity
	float32 1.5                     // 0x0010 - bounce multiplier
	float32 0.125                   // 0x0014 - rotation speed
        float32 1.1072                  // 0x0018 - initial angle (ground, was 1.0472)
        float32 1.1072                  // 0x001C   initial angle (air, was 1.0472)
        float32 40                      // 0x0020   initial speed
        dw Character.MRGAWPLUS_file_6_ptr     // 0x0024   projectile data pointer
        dw 0                            // 0x0028   unknown (default 0)
        float32 0                       // 0x002C   palette index (0 = mario, 1 = luigi)
        OS.copy_segment(0x1038A0, 0x30)
    }

    // @ Description
    // Subroutine which handles air collision for neutral special actions
    scope air_collision_: {
	addiu   sp, sp,-0x0028              // allocate stack space
	swc1    f0, 0x0020(sp)              // ~
	swc1    f2, 0x0024(sp)              // ~
	sw      ra, 0x0014(sp)              // store f0, f2, ra
	li      a1, air_to_ground_          // a1 = air_to_ground_ (transition to ground nsp)

	_check_cancel:
	// check if the current animation frame is higher than RELEASE_FRAME, if so, G&W is cooking
	// or is in endlag and we should check if the B button is held or not for the landing transition.
	// This code is borrowed from Bowser's neutral special.
	lwc1    f0, 0x0078(a0)              // f0 = current animation frame
	lui     t6, RELEASE_FRAME           
	mtc1    t6, f2                      // f2 = float: RELEASE_FRAME
	c.le.s  f2, f0                      // fp compare
	nop
	bc1fl   _continue                   // branch if animation frame =< RELEASE_FRAME
	nop
	// if the b button is held, transition to grounded neutral special, otherwise run normal landing subroutine
	lw      at, 0x0084(a0)              // at = player struct
	lh      at, 0x01BC(at)              // at = buttons_held
	andi    at, at, Joypad.B            // at = 0x0020 if (B_HELD); else a2 = 0
	bnez    at, _continue               // branch if (B_HELD)
	nop
	// if we reach this point, the conditions for a normal landing transition have been met

	lw      v0, 0x0084(a0)              // v0 = player struct
	or      t2, r0, r0	    	    // ~
       	sw      t2, 0x0184(v0)              // temp variable 3 = 0

	li      a1, 0x800DE8E4              // a1 = normal ground collision (transition to landing)

	_continue:
	jal     0x800DE6E4                  // ground collision subroutine
	nop
	lwc1    f0, 0x0020(sp)              // ~
	lwc1    f2, 0x0024(sp)              // ~
	lw      ra, 0x0014(sp)              // load f0, f2, ra
	addiu   sp, sp, 0x0028              // deallocate stack space
	jr      ra                          // return
	nop
    }

    // @ Description
    // Subroutine which handles ground to air transition for neutral special actions
    scope air_to_ground_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object

        lw      a2, 0x0008(v0)              // load character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, _change_action      // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WOLF_NSP_Ground  //MRGAWPLUS_NSP_Ground
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, _change_action      // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WOLF_NSP_Ground //MRGAWPLUS_NSP_Ground


        addiu   a1, r0, 0x00DF              // a1 = equivalent ground action for current air action (used to be 0x00DF)
        _change_action:
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0001                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 1 (continue hitbox)
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    constant REFRESH_FRAME_PUSH(0x41E0) // how many frames until pushing b launches another projectile (28)
    constant REFRESH_FRAME_HOLD(0x4228) // how many frames until holding b launches another projectile (42)
    constant REFRESH_START(0x4140)      // what frame of the animation the loop will go to (12)
    constant MAX_LOOPS(0x4)             // how many times the move can loop until it ends (4)
    scope chef_refresh_: {
	_check_refresh:
	// check if the current animation frame is higher than REFRESH_FRAME and if temp variable 2 < MAX_LOOPS.
	// if both these are true, refresh the move at a specific frame to prepare launching another projectile.
	addiu   sp, sp,-0x0028              // allocate stack space
	swc1    f0, 0x0020(sp)              // ~
	swc1    f2, 0x0024(sp)              // ~
	sw	a0, 0x0018(sp)		    // ~
	sw      ra, 0x0014(sp)              // store f0, f2, a0, ra

        lw      v0, 0x0084(a0)              // v0 = player struct
        addiu   t1, r0, MAX_LOOPS	    // t1 = MAX_LOOPS
	lw      t2, 0x0180(v0)	    	    // t2 = temp variable 2
	sub     t3, t1, t2		    // t3 = MAX_LOOPS - temp variable 2
	blez	t3, _refresh_continue

	// check if button is pushed during refresh time frame
	lwc1    f0, 0x0078(a0)              // f0 = current animation frame
	lui     t6, REFRESH_FRAME_PUSH           
	mtc1    t6, f2                      // f2 = float: REFRESH_FRAME_PUSH
	c.lt.s  f2, f0                      // fp compare
	nop
	bc1fl   _refresh_continue           // branch if animation frame < REFRESH_FRAME_PUSH
	nop
	lui     t6, REFRESH_FRAME_HOLD           
	mtc1    t6, f2                      // f2 = float: REFRESH_FRAME_PUSH
	c.le.s  f0, f2                      // fp compare
	nop
	bc1fl   _refresh_continue           // branch if animation frame > REFRESH_FRAME_HOLD
	nop
	// if the b button is pressed, keep cooking
	lw      at, 0x0084(a0)              // at = player struct
	lh      at, 0x01BE(at)              // at = buttons_pressed
	andi    at, at, Joypad.B            // at = 0x0020 if (B_PRESSED); else at = 0
	bgtz    at, _initiate_refresh       // branch if (B_PRESSED) is 1
	nop

	// check if button is held at the end of refresh time frame
	lwc1    f0, 0x0078(a0)              // f0 = current animation frame
	lui     t6, REFRESH_FRAME_HOLD           
	mtc1    t6, f2                      // f2 = float: REFRESH_FRAME_HOLD
	c.eq.s  f2, f0                      // fp compare
	nop
	bc1fl   _refresh_continue           // branch if animation frame != REFRESH_FRAME_HOLD
	nop
	// if the b button is held, keep cooking
	lw      at, 0x0084(a0)              // at = player struct
	lh      at, 0x01BC(at)              // at = buttons_held
	andi    at, at, Joypad.B            // at = 0x0020 if (B_HELD); else at = 0
	beqz    at, _refresh_continue       // branch if (B_HELD) is 0
	nop

	// if we reach this point, the conditions for a refresh have been met
	_initiate_refresh:
        lw      a1, 0x0024(v0)              // a1(action id) = current action (used to be Action.Chef)
	lui     a2, REFRESH_START           // a2 = frame to start refresh on
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0

	lw	a0, 0x0018(sp)
	lw      v0, 0x0084(a0)              // v0 = player struct
	lw      t2, 0x0180(v0)	    	    // t2 = temp variable 2
	addiu   t2, t2, 0x1                 // temp variable 2 += 1 (there is probably a better place for this)
        sw      t2, 0x0180(v0)              // temp variable 2 = t2

	_refresh_continue:
	lwc1    f0, 0x0020(sp)              // ~
	lwc1    f2, 0x0024(sp)              // ~
	lw      ra, 0x0014(sp)              // load f0, f2, ra
	addiu   sp, sp, 0x0028              // deallocate stack space
	jr      ra                          // return
	nop
    }
}

// @ Description
// Refreshes Specials flag when hit
scope MRGAWPLUSSpecialsRefresh: {
    sw  r0, 0x0ADC(a0)              // set up special bool to FALSE
    jr  ra
    nop
}

Character.table_patch_start(on_hit, Character.id.MRGAWPLUS, 0x4)
dw MRGAWPLUSSpecialsRefresh;
OS.patch_end()

scope GameAndWatchUSP {
    // floating point constants for physics and fsm
    constant AIR_Y_SPEED(0x4368)            // current setting - float32 232.5
    constant GROUND_Y_SPEED(0x4368)         // current setting - float32 232.5
    constant X_SPEED(0x3e40)                // current setting - float32 0.1875 (was 0x3e00 or 0.125)
    constant X_SPEED_INIT(0x3f40)           // current setting - float32 0.75
    constant GRAV_ACCELERATION(0x4100)      // current setting - float32 8
    constant END_AIR_ACCELERATION(0x3f00)   // current setting - float32 0.5 (used to be 0x3C20 or 0.00977)
    constant END_AIR_SPEED(0x41C0)          // current setting - float32 24
    constant LANDING_FSM(0x3EC0)            // current setting - float32 0.375
    // parachute constants
    constant FLOAT_GRAVITY(0x3F00)          // current setting - float32 0.5
    constant FLOAT_FALL_SPEED(0x4190)       // current setting - float32 18
    constant CANCEL_FRAME(0)

    // temp variable 3 constants for movement states (for future reference)
    constant BEGIN(0x1)
    constant BEGIN_MOVE(0x2)
    constant MOVE(0x3)
    constant END_MOVE(0x4)
    constant END(0x5)

    // @ Description
    // Initial subroutine for USP.
    scope ground_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      v1, 0x0ADC(v0)              // v1 = up special bool
        bnez    v1, _end                    // end if up special bool = TRUE
        lli     at, OS.TRUE                 // at = TRUE
        sw      at, 0x0ADC(v0)              // up special bool = TRUE

		lw		t1, 0x0184(v0)
		ori     t2, r0, BEGIN                  // t2 = 2 (there is probably a better place for this)
        sw      t2, 0x0184(v0)              // temp variable 3 = 2
		lw		t1, 0x0184(v0)

        lli     a1, Action.Fire             // a1(action id) = USP
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      a0, 0x0018(sp)              // a0 = player object
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object

        // save initial position for firemen
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a1, 0x84(a0)                // a1 = player struct
        lw      t3, 0x08E8(a1)              // t3 = topjoint
        beqz    t3, _end                    // skip if no topjoint
        nop
        lw      at, 0x1C(t3)                // joint x
        sw      at, 0xAE4(a1)               // save to free space
        lw      at, 0x20(t3)                // joint y
        sw      at, 0xAE8(a1)               // save to free space

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Initial subroutine for USP.
    scope air_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      v1, 0x0ADC(v0)              // v1 = up special bool
        bnez    v1, _end                    // end if up special bool = TRUE
        lli     at, OS.TRUE                 // at = TRUE
        sw      at, 0x0ADC(v0)              // up special bool = TRUE

		lw		t1, 0x0184(v0)
		ori     t2, r0, BEGIN                  // t2 = 2 (there is probably a better place for this)
        sw      t2, 0x0184(v0)              // temp variable 3 = 2
		lw		t1, 0x0184(v0)

        lli     a1, Action.Fire             // a1(action id) = USP
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      a0, 0x0018(sp)              // a0 = player object
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object

        // save initial position for firemen
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a1, 0x84(a0)                // a1 = player struct
        lw      t3, 0x08E8(a1)              // t3 = topjoint
        beqz    t3, _end                    // skip if no topjoint
        nop
        lw      at, 0x1C(t3)                // joint x
        sw      at, 0xAE4(a1)               // save to free space
        lw      at, 0x20(t3)                // joint y
        sw      at, 0xAE8(a1)               // save to free space

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Main subroutine for MRGAWPLUS's aerial up special.
    scope main_air_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x0038(sp)              // 0x0014(sp) = ra
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player object
        or      a3, a0, r0                  // a3 = player object
        addu    a2, a0, r0                  // a2 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        lhu     t6, 0x0180(v0)              // t6 = temp variable 2
	beqz    t6, _begin_movement         // if temp 2 is set, start moving up

        _begin_movement:
        lli     at, OS.TRUE                 // at = TRUE
        sw      at, 0x0B18(v0)              // movement flag = TRUE
        sw      at, 0x0ADC(v0)              // up special bool = TRUE

        // take mid-air jumps away at this point
        lw      at, 0x0B1C(v0)              // at = grounded flag
        bnez    at, _check_end              // don't take away jumps if grounded
        lw      at, 0x09C8(v0)              // at = attribute pointer
        lw      at, 0x0064(at)              // at = max jumps
        b       _check_end
        sb      at, 0x0148(v0)              // jumps used = max jumps

        _check_end:
        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        li a1, goto_next
        jal 0x800D9480 // ftAnimEndCheckSetStatus(GObj *fighter_gobj, void (*proc_status)(GObj*))
        // jal     0x800DEE54                  // transition to idle
        nop

        _end:
        lw      ra, 0x0038(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Subroutine which allows a direction change for MRGAWPLUS's up special.
    // Uses the moveset data command 580000XX (orignally identified as "set flag" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // Variable values used by this subroutine:
    // 0x2 = change direction
    // 0x3 = interrupt (if i can get away with it in the same function)
    scope change_direction_: {
        // 0x180 in player struct = temp variable 2
        lw      a1, 0x0084(a0)              // a1 = player struct
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // ~
        sw      a0, 0x0010(sp)              // store t0, t1, ra, a0
        lw      t0, 0x0180(a1)              // t0 = temp variable 2
        ori     t1, r0, 0x0002              // t1 = 0x2
        bne     t1, t0, _inter                // skip if temp variable 2 != 2
        nop
        jal     0x80160370                  // turn subroutine (copied from captain falcon)
        nop

		_inter:
        //lw      t0, 0x0084(a0)            // t0 = player struct
        lw      at, 0x0184(a1)              // at = temp variable 3
		ori		t1, r0, END_MOVE			// t1 = 4
        //beqz    at, _end                  // skip if temp variable 3 isn't set
		slt     t2, at, t1
		bgtz    t2, _update_firemen_pos
        sw      ra, 0x001C(sp)              // store ra

        // if temp variable 3 was set to 4, do an action check/allow interrupts
        jal     0x80150B00                  // check for aerial attacks
        sw      a0, 0x0028(sp)              // 0x0018(sp) = player object
        bnezl   v0, _update_firemen_pos                    // end if aerial attack initiated
        lw      ra, 0x002C(sp)              // load ra
        //jal     0x8014019C                  // check for midair jumps
        lw      a0, 0x0028(sp)              // a0 = player object
        lw      ra, 0x002C(sp)              // load ra

        _update_firemen_pos:
        // grab joint position/rotation is tied to topjoint
        // so we have to negate it to do relative position => world position
        lw      a0, 0x10(sp)                // restore a0 = player object
        lw      a1, 0x84(a0)                // a1 = player struct
        lw      t3, 0x08F8 + 0x18*4(a1)     // t3 = grab joint
        beqz    t3, _end                    // skip if no grab joint
        nop
        lw      t4, 0x08E8(a1)              // t4 = topjoint
        beqz    t4, _end                    // skip if no topjoint
        nop
        
        lwc1    f6, 0x44(t4)                // f6 = topjoint y scale (used for x and y below)

        lwc1    f2, 0xAE4(a1)               // f2 = initial topjoint x from free space
        lwc1    f4, 0x1C(t4)                // f4 = topjoint x
        sub.s   f2, f4, f2                  // f2 = initial x - current x
        lwc1    f4, 0x44(a1)                // f4 = facing direction (int)
        cvt.s.w f4, f4                      // f4 = facing direction (float)
        mul.s   f2, f2, f4                  // f2 = (initial x - current x) * facing direction
        div.s   f2, f2, f6                  // f2 = ((initial x - current x) * facing direction) * model scale
        lwc1    f4, 0x1C(t3)                // current pos x
        sub.s   f2, f2, f4                  // displace current pos
        swc1    f2, 0x1C(t3)                // save new x
        lwc1    f2, 0xAE8(a1)               // f2 = initial topjoint y from free space
        lwc1    f4, 0x20(t4)                // f4 = topjoint y
        sub.s   f2, f2, f4                  // f2 = initial y - current y
        div.s   f2, f2, f6                  // f2 = (initial y - current y) * model scale
        lwc1    f4, 0x20(t3)                // current pos y
        add.s   f2, f2, f4                  // displace current pos
        swc1    f2, 0x20(t3)                // save new y

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // load t0, t1, ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

	// @ Description
    // Subroutine which handles movement for Marth's up special.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x2 = begin movement
    // 0x3 = movement
    // 0x4 = end movement
    // 0x5 = ending
    scope physics_: {
        // s0 = player struct
        // s1 = attributes pointer
        // 0x184 in player struct = temp variable 3
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        sw      s1, 0x0018(sp)              // original store registers
        sw      t0, 0x0024(sp)              // ~
        sw      t1, 0x0028(sp)              // ~
        swc1    f0, 0x002C(sp)              // ~
        swc1    f2, 0x0030(sp)              // ~
        swc1    f4, 0x0034(sp)              // store t0, t1, f0, f2, f4

        lw      s0, 0x0084(a0)              // s0 = player struct
        lw      t0, 0x014C(s0)              // t0 = kinetic state
        bnez    t0, _aerial                 // branch if kinetic state !grounded
        nop

	// idk why this is commented out. it was for marth and it works
	// so i kept it that way just in case.
        //_grounded:
        jal     0x800D8BB4                  // grounded physics subroutine
        nop
        b       _end                        // end subroutine
        nop

        _aerial:
        OS.copy_segment(0x548F0, 0x40)      // copy from original air physics subroutine
        bnez    v0, _check_begin            // modified original branch
        nop
        li      t8, 0x800D8FA8              // t8 = subroutine which disallows air control
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, END                 // t1 = END
        bne     t0, t1, _apply_air_physics  // branch if temp variable 3 != END
        nop
        li      t8, air_control_             // t8 = air_control_

        _apply_air_physics:
        or      a0, s0, r0                  // a0 = player struct
        jalr    t8                          // air control subroutine
        or      a1, s1, r0                  // a1 = attributes pointer
        or      a0, s0, r0                  // a0 = player struct
        jal     0x800D9074                  // air friction subroutine?
        or      a1, s1, r0                  // a1 = attributes pointer

		// comments: when starting out, sets the x velocity to a
		// fraction of what it used to be, and sets y velocity to 0
        _check_begin:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        bne     t0, t1, _check_begin_move   // skip if temp variable 3 != BEGIN
        lw      t0, 0x0024(s0)              // t0 = current action
        lli     t1, Action.Fire         // t1 = Action.Fire
        beq     t0, t1, _check_begin_move   // skip if current action = Fire
        nop
        // slow x movement
        lwc1    f0, 0x0048(s0)              // f0 = current x velocity
        lui     t0, X_SPEED_INIT            // 3f40 is 0.75
        mtc1    t0, f2                      // ~
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.75
        swc1    f0, 0x0048(s0)              // x velocity = (x velocity * 0.5)
        // freeze y position
        sw      r0, 0x004C(s0)              // y velocity = 0

		// comments: okay, so this thing will call the calc_velocity thing
		// that determines direction when the joystick is held left or right
        _check_begin_move:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, MOVE          		// t1 = BEGIN_MOVE
		beq     t0, t1, _apply_gravity      // skip if temp variable 3 = MOVE
		ori     t1, r0, BEGIN_MOVE          // t1 = BEGIN_MOVE
        bne     t0, t1, _end_movement      // skip if temp variable 3 != BEGIN_MOVE
        nop
        // initialize x/y velocity
        lw      t0, 0x0024(s0)              // t0 = current action
        lli     t1, Action.Fire         // t1 = Action.Fire
        beq     t0, t1, _calculate_velocity // branch if current action = Fire
        lui     t0, GROUND_Y_SPEED          // t0 = GROUND_Y_SPEED
        // if current action != Fire
        lui     t0, AIR_Y_SPEED             // t0 = AIR_Y_SPEED
	xori	t4, r0, r0					// t4 = 0 (until we get to calculate the velocity)

	// comments: okay, so this thing really only runs once
	// so that means any gravity things shouldn't happen here
        _calculate_velocity:
        mtc1    t0, f4                      // f4 = AIR_Y_SPEED
        lwc1    f0, 0x0044(s0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        lb      t0, 0x01C2(s0)              // ~
        mtc1    t0, f2                      // ~
        cvt.s.w f2, f2                      // f2 = stick_x
        mul.s   f0, f2, f0                  // f0 = stick_x * direction
        lui     t0, 0x4100                  // ~
        mtc1    t0, f2                      // f2 = 8
        c.le.s  f2, f0                      // ~
        nop                                 // ~
        bc1f    _apply_movement             // branch if stick_x * direction =< 8
        nop
        // update x velocity based on stick_x
        // f0 = stick_x (relative to direction)
        lui     t0, X_SPEED_INIT            // ~
        mtc1    t0, f2                      // f2 = 0.75, used to be 3f00 or 0.5
        mul.s   f2, f0, f2                  // f2 = x velocity (stick_x * 0.75)
        // update y velocity based on x velocity (higher x = lower y)
        lui     t0, 0x3d80                  // ~
        mtc1    t0, f0                      // f0 = 0.0625
        mul.s   f0, f0, f2                  // ~
        sub.s   f4, f4, f0                  // f4 = AIR_Y_SPEED - (x velocity * 0.0625)

	// comments: this seems to apply the movement only once
	// so for gravity, don't really bother with it
        _apply_movement:
        // f2 = x velocity to add
        // f4 = y velocity
        lui     t0, X_SPEED                 // ~
        mtc1    t0, f0                      // f0 = X_SPEED
        add.s   f2, f2, f0                  // f2 = final velocity
        lwc1    f0, 0x0044(s0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        mul.s   f2, f0, f2                  // f2 = x velocity * direction
        swc1    f2, 0x0048(s0)              // store x velocity
        swc1    f4, 0x004C(s0)              // store y velocity
        ori     t0, r0, MOVE                // t0 = MOVE
        sw      t0, 0x0184(s0)              // temp variable 3 = MOVE
        // take mid-air jumps away at this point
        lw      t0, 0x09C8(s0)              // t0 = attribute pointer
        lw      t0, 0x0064(t0)              // t0 = max jumps
        sb      t0, 0x0148(s0)              // jumps used = max jumps

	// we want this to run every frame after we've added velocity
	_apply_gravity:
	lwc1    f4, 0x004C(s0)              // f0 = current y velocity
        lui     t0, GRAV_ACCELERATION       // ~
        mtc1    t0, f2                      // f2 = how much velocity to subtract from y_speed
        sub.s	f4, f4, f2                  // f4 = f4 - f2
	swc1    f4, 0x004C(s0)              // store y velocity, now reduced due to gravity

	// this runs every frame the move is active
        _check_end_move:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, END_MOVE            // t1 = END_MOVE
        bne     t0, t1, _end                // skip if temp variable 3 != END_MOVE
        nop

        _end_movement:
        // slow x movement
        lwc1    f0, 0x0048(s0)              // f0 = current x velocity
        lui     t0, 0x3E00                  // ~
        mtc1    t0, f2                      // f2 = 0.125
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.125
        lui     t0, X_SPEED                 // ~
        mtc1    t0, f2                      // f2 = X_SPEED
        lwc1    f4, 0x0044(s0)              // ~
        cvt.s.w f4, f4                      // f4 = direction
        mul.s   f2, f2, f4                  // f2 = X_SPEED * direction
        add.s   f0, f0, f2                  // f0 = final velocity
        swc1    f0, 0x0048(s0)              // x velocity = (x velocity * 0.125) + X_SPEED
        // slow y movement
        lwc1    f0, 0x004C(s0)              // f0 = current y velocity
        lui     t0, END_AIR_ACCELERATION    // ~
        mtc1    t0, f2                      // f2 = END_AIR_ACCELERATION (5)
        mul.s   f0, f0, f2                  // f0 = y velocity * 0.5
        swc1    f0, 0x004C(s0)              // y velocity = (y velocity * 0.5)

	lw	t0, 0x0184(s0)				// t0 = temp 3
	ori     t1, r0, END_MOVE            // t1 = END_MOVE
	bne	t0, t1,	_end				// don't set to END unless the movement is ending!
        ori     t0, r0, END                 // t0 = END
        sw      t0, 0x0184(s0)              // temp variable 3 = END

        _end:
        lw      t0, 0x0024(sp)              // ~
        lw      t1, 0x0028(sp)              // ~
        lwc1    f0, 0x002C(sp)              // ~
        lwc1    f2, 0x0030(sp)              // ~
        lwc1    f4, 0x0034(sp)              // load t0, t1, f0, f2, f4
        lw      ra, 0x001C(sp)              // ~
        lw      s0, 0x0014(sp)              // ~
        lw      s1, 0x0018(sp)              // original load registers
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles Marth's horizontal control for up special.
    // This seems to only affect the character when temp 3 is set to end.
    scope air_control_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      a1, 0x001C(sp)              // ~
        sw      ra, 0x0014(sp)              // ~
        sw      t0, 0x0020(sp)              // ~
        sw      t1, 0x0024(sp)              // store a1, ra, t0, t1
        addiu   a1, r0, 0x0008              // a1 = 0x8 (original line)
        lw      t6, 0x001C(sp)              // t6 = attribute pointer
        // load an immediate value into a2 instead of the air acceleration from the attributes
        lui     a2, END_AIR_ACCELERATION    // a2 = END_AIR_ACCELERATION
        lui     a3, END_AIR_SPEED           // a3 = END_AIR_SPEED
        jal     0x800D8FC8                  // air drift subroutine?
        nop
        lw      ra, 0x0014(sp)              // ~
        lw      t0, 0x0020(sp)              // ~
        lw      t1, 0x0024(sp)              // load ra, t0, t1
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles collision for Marth's up special.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Marth.
    scope collision_: {
        // Copy the first 30 lines of subroutine 0x80156358
        OS.copy_segment(0xD0D98, 0x78)
        // Replace original line which loads the landing fsm
        //lui     a2, 0x3E8F                // original line 1
        lui     a2, LANDING_FSM             // a2 = LANDING_FSM
        // Copy the last 17 lines of subroutine 0x80156358
        OS.copy_segment(0xD0E14, 0x44)
    }

    // @ Description
    // Subroutine for Game and Watch's aerial up special interrupt.
    // Code borrowed from Sonic.
    scope interrupt_: {
        addiu   sp, sp, -0x0020
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      at, 0x0184(t0)              // at = temp variable 3
		lui		t1, END_MOVE				// t1 = 4
        //beqz    at, _end                  // skip if temp variable 3 isn't set
		bne     at, t1, _end                // skip if temp variable 3 isn't 4
        sw      ra, 0x001C(sp)              // store ra

        // if temp variable 3 was set, do an action check/allow interrupts
        jal     0x80150B00                  // check for aerial attacks
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        bnezl   v0, _end                    // end if aerial attack initiated
        lw      ra, 0x001C(sp)              // load ra
        jal     0x8014019C                  // check for midair jumps
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra

        _end:
        jr      ra
        addiu   sp, sp, 0x0020
    }

    scope goto_next: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      s0, 0x0024(sp)              // store a0, s0, ra

        lw      s0, 0x0084(a0)              // s0 = player struct
        lw      t6, 0x014C(s0)              // t6 = kinetic state (0 = grounded, 1 = aerial)

        bnez    t6, _continue
        nop

        _set_aerial:
        jal     0x800DEEC8 // set aerial state
        or      a0, s0, r0 // a0 = player struct

        _continue:
        lw      a0, 0x0020(sp)              // a0 = player object
        lli     a1, GameAndWatchPLUS2D.Action.USP_Float    // a1(action id)
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0x
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object

        _end:
        lw      ra, 0x001C(sp)              // ~
        lw      s0, 0x0024(sp)              // load s0
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Aerial movement subroutine for USPFloat.
    // Modified version of subroutine 0x800D90E0.
    // Modified from Peach's code.
    scope float_physics_: {
        // Copy the first 8 lines of subroutine 0x800D90E0
        OS.copy_segment(0x548E0, 0x20)

        // Skip 7 lines (fast fall branch logic)

        // jal 0x800D8E50                   // ~
        // or a1, s1, r0                    // original 2 lines call gravity subroutine
	
        lui     a1, FLOAT_GRAVITY           // a1 = FLOAT_GRAVITY
        jal     0x800D8D68                  // apply gravity/fall speed
        lui     a2, FLOAT_FALL_SPEED        // a2 = FLOAT_FALL_SPEED

        // Copy the next 15 lines of subroutine 0x800D90E0
        OS.copy_segment(0x54924, 0x3C)
    }

    // @ Description
    // Collision wubroutine for Game and Watch's up special.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value.
    // Code borrowed from Dedede.
    scope float_collision_: {
        addiu          sp, sp, -0x28        // allocate stack space
        sw             ra, 0x001c (sp)      // save return address to stack
        lw             a1, 0x0084 (a0)      // load player struct
        sw             a0, 0x0028 (sp)      // save player object to stack

        jal            0x800de87c           // check to see if player has collided with clipping
        sw             a1, 0x0024 (sp)      // save player struct

        beqz           v0, _end             // if no collision, skip to end
        lw             a1, 0x0024 (sp)      // load player struct

        lhu            v0, 0x00d2 (a1)      // load collision clipping flag
        andi           t6, v0, Surface.GROUND // check if colliding with a floor

        beqz           t6, _cliff_check     // branch not colliding with a wall
        andi           t7, v0, 0x3000       // check if colliding with cliff

	_ground:
        jal            0x800dee98
        or             a0, a1, r0           // place player struct in a0

        lw             a0, 0x0028 (sp)      // load player object
        addiu          a1, r0, Action.LandingHeavy // load action ID
        lui            a2, LANDING_FSM             // a2 = LANDING_FSM
        lui            a3, 0x3f80           // 1.0 placed in a3

        jal            0x800e6f24           // change action routine
        sw             r0, 0x0010 (sp)

        b              _end_2
        lw             ra, 0x001c (sp)      // load return address

        _cliff_check:
        beqzl          t7, _end   // branch if not a cliff
        andi           t6, v0, Surface.CEILING // check if colliding with a ceiling
        jal            0x80144c24           // cliff catch routine
        lw             a0, 0x0028 (sp)      // load player object

        _end:
        lw             ra, 0x001c (sp)      // load return address
		_end_2:
        jr             ra                   // return
        addiu          sp, sp, 0x28         // deallocate stack space
    }

    // @ Description
    // Subroutine for Game and Watch's aerial parachute interrupt.
    scope float_interrupt_: {
        OS.routine_begin(0x20)

        sw a0, 0x18(sp) // save a0
                
        lw      s0, 0x0084(a0) // s0 = player struct
        lw      t0, 0x1C(s0) // t0 = current frame (int)

        slti    at, t0, CANCEL_FRAME
        bnez    at, _end // cannot interrupt until the cancel frame
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
        lli a1, Action.FallAerial // a1(action id)
        or a2, r0, r0 // a2(starting frame) = 0
        lui a3, 0x3F80 // a3(frame speed multiplier) = 1.0x
        jal 0x800E6F24 // change action
        sw r0, 0x0010(sp) // argument 4 = 0

        _end:
        OS.routine_end(0x20)
    }

}

scope GameAndWatchDSP {

    // @ Description
    // Subroutine which runs when Game and Watch initiates a grounded down special.
    scope ground_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Action.JudgeBegin // a1(action id) = DSP_Ground
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        sw      r0, 0x0B18(a0)              // hit detection = FALSE
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which runs when Game and Watch initiates an aerial down special.
    scope air_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Action.JudgeBeginAir    // a1(action id) = DSP_Air
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        //sw      r0, 0x0B18(a0)              // hit detection = FALSE
        //sw      r0, 0x004C(a0)              // y velocity = 0
        //lwc1    f4, 0x0048(a0)              // f4 = x velocity
        //lui     at, 0x3F00                  // ~
        //mtc1    at, f6                      // f6 = 0.5
        //mul.s   f4, f4, f6                  // f4 = x velocity * 0.5
        //swc1    f4, 0x0048(a0)              // store updated x velocity
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSP_Begin
    // Picks a random number, then changes to that move
    scope main: {
	addiu   sp, sp,-0x0040              // allocate stack space
	sw      ra, 0x0014(sp)              // store ra
	sw      a0, 0x0018(sp)
	sw      s0, 0x0020(sp)
	jal     Global.get_random_int_safe_	// v0 = random number (from 0 to 8)
	lli   	a0, 000009

	// set these to use later for determining which move to use
	// then jump to the appropriate function
	or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0

	beqz	v0, _judge_1
	nop
	addiu	v0, -1
	beqz	v0, _judge_2
	nop
	addiu	v0, -1
	beqz	v0, _judge_3
	nop
	addiu	v0, -1
	beqz	v0, _judge_4
	nop
	addiu	v0, -1
	beqz	v0, _judge_5
	nop
	addiu	v0, -1
	beqz	v0, _judge_6
	nop
	addiu	v0, -1
	beqz	v0, _judge_7
	nop
	addiu	v0, -1
	beqz	v0, _judge_8
	nop
	addiu	v0, -1
	beqz	v0, _judge_9
	nop

	_judge_1:
	lli     a1, Action.DSP_Ground_1     // a1(action id) = DSP
	lw      a0, 0x0018(sp)
	lw      t1, 0x0084(a0)              // t1 = player struct
	lw      t0, 0x0014C(t1)             // get aerial flag
	beqz	t0, _change_action          // if grounded, change to grounded 1 state
	nop
	lli     a1, Action.DSP_Air_1        // a1(action id) = DSP
	beq	r0, r0, _change_action      // if aerial, change to aerial 1 state
	nop

	_judge_2:
	lli     a1, Action.DSP_Ground_2
	lw      a0, 0x0018(sp)
	lw      t1, 0x0084(a0)
	lw      t0, 0x0014C(t1)
	beqz	t0, _change_action
	nop
	lli     a1, Action.DSP_Air_2
	beq	r0, r0, _change_action
	nop

	_judge_3:
	lli     a1, Action.DSP_Ground_3
	lw      a0, 0x0018(sp)
	lw      t1, 0x0084(a0)
	lw      t0, 0x0014C(t1)
	beqz	t0, _change_action
	nop
	lli     a1, Action.DSP_Air_3
	beq	r0, r0, _change_action
	nop

	_judge_4:
	lli     a1, Action.DSP_Ground_4
	lw      a0, 0x0018(sp)
	lw      t1, 0x0084(a0)
	lw      t0, 0x0014C(t1)
	beqz	t0, _change_action
	nop
	lli     a1, Action.DSP_Air_4
	beq	r0, r0, _change_action
	nop

	_judge_5:
	lli     a1, Action.DSP_Ground_5
	lw      a0, 0x0018(sp)
	lw      t1, 0x0084(a0)
	lw      t0, 0x0014C(t1)
	beqz	t0, _change_action
	nop
	lli     a1, Action.DSP_Air_5
	beq	r0, r0, _change_action
	nop

	_judge_6:
	lli     a1, Action.DSP_Ground_6
	lw      a0, 0x0018(sp)
	lw      t1, 0x0084(a0)
	lw      t0, 0x0014C(t1)
	beqz	t0, _change_action
	nop
	lli     a1, Action.DSP_Air_6
	beq	r0, r0, _change_action
	nop

	_judge_7:
	lli     a1, Action.DSP_Ground_7
	lw      a0, 0x0018(sp)
	lw      t1, 0x0084(a0)
	lw      t0, 0x0014C(t1)
	beqz	t0, _change_action
	nop
	lli     a1, Action.DSP_Air_7
	beq	r0, r0, _change_action
	nop

	_judge_8:
	lli     a1, Action.DSP_Ground_8
	lw      a0, 0x0018(sp)
	lw      t1, 0x0084(a0)
	lw      t0, 0x0014C(t1)
	beqz	t0, _change_action
	nop
	lli     a1, Action.DSP_Air_8
	beq	r0, r0, _change_action
	nop

	_judge_9:
	lli     a1, Action.DSP_Ground_9
	lw      a0, 0x0018(sp)
	lw      t1, 0x0084(a0)
	lw      t0, 0x0014C(t1)
	beqz	t0, _change_action
	nop
	lli     a1, Action.DSP_Air_9
	beq	r0, r0, _change_action
	nop

	_change_action:
	lw      a0, 0x0018(sp)              // a0 = player object
	jal     0x800E6F24                  // change action
	sw      r0, 0x0010(sp)              // argument 4 = 0
	lw      a0, 0x0018(sp)              // a0 = player object
	jal     0x800E0830                  // unknown common subroutine
	lw      a0, 0x0018(sp)              // a0 = player object

	//_release:
	nop
	b       _end
	nop

	_end:
	lw      s0, 0x0020(sp)
	lw      a0, 0x0018(sp)
	lw      ra, 0x0014(sp)              // load ra
	jr      ra                          // return
	addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles ground collision for down special actions
    scope ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_to_air_          // a1(transition subroutine) = ground_to_air_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles air collision for down special actions
    scope air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_to_ground_          // a1(transition subroutine) = air_to_ground_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles ground to air transition for down special actions
    scope ground_to_air_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lw      t7, 0x0024(v0)              // t7 = current action
        addiu   a1, t7, 0x0001              // a1 = equivalent air action for current ground action (id + 2)
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x2803                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x2803 (continue: sword trails, 3C command FGM, gfx routines, hitboxes)
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0034(sp)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles air to ground transition for down special actions
    scope air_to_ground_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lw      t7, 0x0024(v0)              // t7 = current action
        addiu   a1, t7,-0x0001              // a1 = equivalent ground action for current air action (id - 2)
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x2803                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x2803 (continue: sword trails, 3C command FGM, gfx routines, hitboxes)
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // floating point constants for physics and fsm
    constant X_MAXSPEED(0x41A0)             // limits x speed. current setting - float32 20
    constant X_MULT(0x3F70)                 // multiplies x speed to slow down gradually. current setting - float32 0.9375

    // @ Description
    // Subroutine which handles physics for Game and Watch's aerial down special.
    // Just like in the main games, his horizontal movement is slowed during judge.
    // This feels worse, but it's necessary since throw combos were too overpowered before.
    scope air_physics_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        sw      s0, 0x0020(sp)              // ~
        lw      s0, 0x0084(a0)              // s0 = player struct

        jal     0x800D91EC                  // physics subroutine (disallows player control)
        nop

        // slow x movement in the air
        // it's like this in the main games too
        //lwc1    f0, 0x0048(s0)              // f0 = current x velocity
        //abs.s   f2, f0                      // f2 = abs(f0)
        //lui     t0, X_MAXSPEED              // ~
        //mtc1    t0, f4                      // f4 = X_MAXSPEED

        //c.le.s  f2, f4                      // if going slower than the max speed, do nothing
        //nop                                 // otherwise, slow the speed
        //bc1t   _end
        //nop
        //lui     t0, X_MULT                  // ~
        //mtc1    t0, f2                      // f2 = X_MULT
	//mul.s   f0, f0, f2                  // f0 = velocity * X_MULT
        //swc1    f0, 0x0048(s0)              //

        _end:
        lw      ra, 0x0014(sp)
        lw      s0, 0x0020(sp)
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // this constant is the bitmask for B presses
    constant B_PRESSED(0x40)                // bitmask for b press	
    // this constant is how much he will go up by when mashing
    constant Y_VELOCITY_ADD(0x40b0)			// 5.5f
    constant Y_VELOCITY_MAX(0x41f0)			// 30.0f
    scope attacks_main_: {
	addiu   sp, sp, -0x0070
        sw      ra, 0x0014(sp)
        swc1    f6, 0x003C(sp)
        swc1    f8, 0x0038(sp)
        sw      a0, 0x0034(sp)
	sw      a1, 0x0054(sp)
        addu    a2, a0, r0
        lw      v0, 0x0084(a0)                      // loads player struct into v0

	lw     t0, 0x0024(v0)              				// t0 = current action
	lli    t1, Action.DSP_Ground_1     // t1 = Action.DSP_Ground_1
        beq    t0, t1, _one_damage    					// branch to one damage
	nop
        lli    t1, Action.DSP_Air_1    	// t1 = Action.DSP_Air_1
        beq    t0, t1, _one_damage   					// branch to one damage
	nop

	lli    t1, Action.DSP_Ground_5     // t1 = Action.DSP_Ground_5
        beq    t0, t1, _five_hover   					// branch to five hover
	nop
        lli    t1, Action.DSP_Air_5    	// t1 = Action.DSP_Air_5
        beq    t0, t1, _five_hover   					// branch to five hover
	nop

	lli    t1, Action.DSP_Ground_7     // t1 = Action.DSP_Ground_7
        beq    t0, t1, _seven_food  					// branch to seven food
	nop
        lli    t1, Action.DSP_Air_7    	// t1 = Action.DSP_Air_7
        beq    t0, t1, _seven_food  					// branch to seven food
	nop

	beq    r0, r0, _idle_transition_check  			// skip to end (no special action needed)
	nop

	_one_damage:
        lui     t0, 0x4160
	mtc1    t0, f6
        lwc1    f8, 0x0078(a2)					// get how many frames until animation is done
        c.eq.s  f8, f6
        nop
        bc1fl   _idle_transition_check			// if not frame 15, don't do any damage
	nop
	lw	a0, 0x0084(a0)					// load character struct into a0
	ori	a1, 0,  0						// reset a1
	addiu   a1, a1, 15						// set a1 to the damage given to MRGAWPLUS (currently 15)
	jal	Character.add_percent_			// args: a0 = character struct, a1 = damage to add
	nop

	beq    r0, r0, _idle_transition_check
        nop

	_five_hover:
        lw      t0, 0x0084(a0)              			// t0 = player struct
        lbu     t1, 0x01BE(t0)              			// t1 = button_pressed
        lw      t2, 0x0B18(t0)              			// t2 = button_press_buffer
        or      t1, t1, t2                  			// t1 = button_pressed | button_press_buffer
        sw      t1, 0x0B18(t0)              			// update button_press_buffer with current inputs
        sw      t1, 0x0068(sp)              			// save button_pressed to stack

	lw      t3, 0x0068(sp)              			// load button press buffer
        andi    t1, t3, B_PRESSED           			// t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, _idle_transition_check          	// skip if (!B_PRESSED)
        nop
		lwc1    f8, 0x004C(t0)				// load velocity
        lui     t4, Y_VELOCITY_ADD  
	mtc1    t4, f6
	add.s   f8, f8, f6					// f8 = f8 + f6
	lui     t4, Y_VELOCITY_MAX  
	mtc1    t4, f6 						// if you mash, you can fly! (i hope)
	c.le.s	f6, f8
	bc1f	_set_new_velocity
	nop
	mtc1	t4,	f8
	_set_new_velocity:
	mfc1	t4, f8
	sw		t4,	0x004c(t0)

	beq    r0, r0, _idle_transition_check
        nop

        // Here we check if something was hit during the current state
        // We can only spawn food if we hit something
	_seven_food:
        lw      t0, 0x0084(a0)              			// t0 = player struct
        lw      t1, 0x0178(v0)              			// t1 = temp variable 3 (sanity check)
	bne     t1, r0, _idle_transition_check			// skip if food already spawned
	nop
        addiu   t8, v0, 0x0294              // t8 = first hitbox struct
        addiu   t9, t8, 0xC4 * 3            // t9 = last hitbox struct
        or      t6, r0, r0                  // t6 = 0
        _loop:
        lw      t0, 0x0000(t8)              // t0 = hitbox state
        beqz    t0, _loop_end               // skip if hitbox is disabled
        nop
        lbu     t1, 0x0060(t8)              // t1 = hitbox collision flags(1/4)
        or      t6, t6, t1                  // t6 = t6 | collision flags
        lbu     t1, 0x0068(t8)              // t1 = hitbox collision flags(2/4)
        or      t6, t6, t1                  // t6 = t6 | collision flags
        lbu     t1, 0x0070(t8)              // t1 = hitbox collision flags(3/4)
        or      t6, t6, t1                  // t6 = t6 | collision flags
        lbu     t1, 0x0078(t8)              // t1 = hitbox collision flags(4/4)
        or      t6, t6, t1                  // t6 = t6 | collision flags
        _loop_end:
        bne     t8, t9, _loop               // loop if t8 != last hitbox struct
        addiu   t8, t8, 0x00C4              // t8 = next hitbox struct

        lw      ra, 0x0014(sp)              // restore return address

        // t6 = collision flags for all active hitboxes
        andi    t6, t6, 0x00F0              // t6 != 0 if hitbox collision has occured
        beq     t6, r0, _idle_transition_check      // skip if no hitbox collision is detected
        nop

        _create_food:
        OS.save_registers()
		nop
        addiu   sp, sp, -0x0060             // allocate stack space (0x8016EA78 is unsafe)
        addiu   a1, sp, 0x0020              // a1 = address to return x/y/z coordinates to
        sw      v0, 0x001C(sp)              // v0 = player struct
        sw      r0, 0x0000(a1)              // ~
        sw      r0, 0x0004(a1)              // ~
        sw      r0, 0x0008(a1)              // clear space for x/y/z coordinates

	lw      a0, 0x08E8(v0)              // v0 = MRGAWPLUS joint (he doesn't have a 0x95C joint?)
	lw      t0, 0x0084(a2)
	lw      t1, 0x0008(t0)              // t1 = character id
	lw      t2, 0x0078(t0)              // t2 = xyz coords

	nop
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
	nop
        or      a0, r0, r0                  // a0 = owner (none)
        addiu   a2, sp, 0x0020              // a2 = coordinates to create item at
        addiu   a3, sp, 0x002C              // a3 = address of velocity floats
        lli     t3, 0x0001                  // t3 = 1
        sw      t3, 0x0010(sp)              // 0x0010(sp) = 1
        sw      r0, 0x0008(a2)              // initial z position = 0
        sw      r0, 0x0000(a3)              // initial x velocity = 0
        lui     t3, 0x41F0                  // ~
        sw      t3, 0x0004(a3)              // initial y velocity = 30
        jal     Global.get_random_int_safe_
        addiu   a0, r0, 800


        addiu   v0, -10
        bltz    v0, _create_food_continue
        lli     a1, Item.Fan.id                       // 10 in 800 chance of fan

        addiu   v0, -10
        bltz    v0, _create_food_continue
        lli     a1, Item.MrSaturn.id                  // 10 in 800 chance of mr. saturn

        addiu   v0, -10
        bltz    v0, _create_food_continue
        lli     a1, Item.Tomato.id                    // 8 in 800 chance of tomato

        addiu   v0, -8
        bltz    v0, _create_food_continue
        lli     a1, Item.Bumper.id                    // 8 in 800 chance of bumper

        addiu   v0, -8
        bltz    v0, _create_food_continue
        lli     a1, Item.BeamSword.id                 // 8 in 800 chance of beam sword

        addiu   v0, -8
        bltz    v0, _create_food_continue
        lli     a1, Item.FranklinBadge.id             // 8 in 800 chance of franklin badge

        addiu   v0, -6
        bltz    v0, _create_food_continue
        lli     a1, Item.Bobomb.id                    // 6 in 800 chance of bobomb

        addiu   v0, -6
        bltz    v0, _create_food_continue
        lli     a1, Item.FireFlower.id                // 6 in 800 chance of fire flower

        addiu   v0, -4
        bltz    v0, _create_food_continue
        lli     a1, Item.MotionSensorBomb.id          // 4 in 800 chance of motion sensor bomb

        addiu   v0, -4
        bltz    v0, _create_food_continue
        lli     a1, Item.StarRod.id                   // 4 in 800 chance of star rod

        addiu   v0, -4
        bltz    v0, _create_food_continue
        lli     a1, Item.RayGun.id                    // 4 in 800 chance of ray gun

        addiu   v0, -4
        bltz    v0, _create_food_continue
        lli     a1, Item.HomeRunBat.id                // 4 in 800 chance of home run bat

        addiu   v0, -2
        bltz    v0, _create_food_continue
        lli     a1, Item.GreenShell.id                // 2 in 800 chance of green shell

        addiu   v0, -2
        bltz    v0, _create_food_continue
        lli     a1, Item.SuperMushroom.id             // 2 in 800 chance of super mush

        addiu   v0, -2
        bltz    v0, _create_food_continue
        lli     a1, Item.PoisonMushroom.id            // 2 in 800 chance of poison mush

        addiu   v0, -2
        bltz    v0, _create_food_continue
        lli     a1, Item.DekuNut.id                   // 2 in 800 chance of deku nut

        addiu   v0, -2
        bltz    v0, _create_food_continue
        lli     a1, Item.Pitfall.id                   // 2 in 800 chance of pitfall

        addiu   v0, -2
        bltz    v0, _create_food_continue
        lli     a1, Item.Pwing.id                     // 2 in 800 chance of pwing

        addiu   v0, -2
        bltz    v0, _create_food_continue
        lli     a1, Item.Stopwatch.id                 // 2 in 800 chance of stopwatch

        addiu   v0, -1
        bltz    v0, _create_food_continue
        lli     a1, Item.Heart.id                     // 1 in 800 chance of heart

        addiu   v0, -1
        bltz    v0, _create_food_continue
        lli     a1, Item.Pokeball.id                  // 1 in 800 chance of pokeball

        addiu   v0, -1
        bltz    v0, _create_food_continue
        lli     a1, Item.RedShell.id                  // 1 in 800 chance of red shell

        addiu   v0, -1
        bltz    v0, _create_food_continue
        lli     a1, Item.BlueShell.id                 // 1 in 800 chance of blue shell

        addiu   v0, -1
        bltz    v0, _create_food_continue
        lli     a1, Item.Lightning.id                 // 1 in 800 chance of lightning

        addiu   v0, -1
        bltz    v0, _create_food_continue
        lli     a1, Item.GoldenGun.id                 // 1 in 800 chance of golden gun

        addiu   v0, 0
        bltz    v0, _create_food_continue
        lli     a1, Item.Hammer.id                    // 0 in 800 chance of hammer

        addiu   v0, 0
        bltz    v0, _create_food_continue
        lli     a1, Item.Star.id                      // 0 in 800 chance of star

        addiu   v0, 0
        bltz    v0, _create_food_continue
        lli     a1, Item.CloakingDevice.id            // 0 in 800 chance of cloaking device

        lli     a1, Item.Dango.id           // remaining # in 800 chance of Dango item (heals 10%)
        _create_food_continue:
        jal     0x8016EA78                  // create item
        sw      r0, 0x0008(a3)              // initial z velocity = 0
        beqz    v0, _end_food               // branch if no item object was created
        addiu   sp, sp, 0x0060              // deallocate stack space

        // prevent spawned item from clipping into walls
        lw      a1, 0xFFBC(sp)             // a1 = player struct
        addiu   a2, a1, 0x0078              // a2 = unknown
        lw      a1, 0x0078(a1)              // a1 = player x/y/z coordinates
        jal     0x800DF058                  // check clipping
        or      a0, v0, r0                  // a0 = item object
	nop

        _end_food:
        OS.restore_registers()
	nop
        lli    t1, 0x1						// save tmp variable 1 = 1
        sw     t1, 0x0178(v0)             			// to prevent mass food spawning
	nop

        // checks frame counter to see if reached end of the move
        _idle_transition_check:
        mtc1    r0, f6
        lwc1    f8, 0x0078(a2)
        c.le.s  f8, f6
        nop
        bc1fl   _end
		nop
	ori    t1, r0, r0					// reset temp variable 1 to 0
	sw     t1, 0x0178(v0)              			// t1 = temp variable 1 (sanity check)
        lw     ra, 0x0014(sp)
        lw     a2, 0x0034(sp)
        jal    0x800DEE54
        or     a0, a2, r0

        _end:
        lw      a0, 0x0034(sp)
	lw      a1, 0x0054(sp)
        lwc1    f6, 0x003C(sp)
        lwc1    f8, 0x0038(sp)
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0070
        jr      ra
        nop
	}
}