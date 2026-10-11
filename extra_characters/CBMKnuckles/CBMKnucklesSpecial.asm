if !{defined __CBMKNUCKLES_SPECIAL__} {
define __CBMKNUCKLES_SPECIAL__()

// CBMKnucklesSpecial.asm

// This file contains subroutines used by CBMKnuckles' special moves.

// @ Description
// Refreshes USP flag when hit
scope CBMKnucklesUSPRefresh: {
    jr  ra
    sw  r0, 0x0ADC(a0)                      // set up special bool to FALSE
}

Character.table_patch_start(on_hit, Character.id.CBMKNUCKLES, 0x4)
dw CBMKnucklesUSPRefresh;
OS.patch_end()

scope CBMKnucklesUSP {
    constant Y_SPEED(0x42f0)                // current setting - float: 120

    // @ Description
    // Initial Subroutine for Knuckles' grounded up special.
    scope ground_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // a0 = player struct

        // move Knuckles up to be on spring
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      t0, 0x0074(a0)              // t0 = top joint
        lui     at, 0x4310                  // at = 144 (fp)
        mtc1    at, f0                      // f0 = 144
        lwc1    f2, 0x0020(t0)              // f2 = Y position
        add.s   f2, f2, f0                  // f2 = adjusted Y position
        jal     air_initial_                // air_initial_
        swc1    f2, 0x0020(t0)              // update Y position

        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        lli     at, OS.TRUE                 // ~
        sw      at, 0x0B1C(a0)              // grounded flag = TRUE
        lli     t0, 0x0000                  // t0 = 0 (initialize spring on ground)
        lw      at, 0x00EC(a0)              // at = clipping ID of player
        bltzl   at, pc() + 8                // if not over a normal plat (like on the respawn plat), then initialize in air
        lli     t0, 0x0001                  // t0 = 1 (initialize spring in air)
        sb      at, 0x0186(a0)              // temp variable 3, 3rd byte = character's clipping ID
        sb      t0, 0x0187(a0)              // temp variable 3, 4th byte = initialize spring on ground/in air
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Initial Subroutine for Knuckles' aerial up special.
    scope air_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      at, 0x0084(a0)              // at = player struct
        lw      at, 0x0ADC(at)              // at = up special bool
        bnezl   at, _end                    // if up special bool = TRUE, skip
        nop

        lli     a1, CBMKnuckles.Action.Spring // a1(action id) = Spring
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        lli     v1, 0x0001                  // v1 = 1
        sw      v1, 0x0184(a0)              // temp variable 3 = 1 (initialize spring in air)
        sw      r0, 0x0B18(a0)              // movement flag = FALSE
        sw      r0, 0x0B1C(a0)              // grounded flag = FALSE
        sw      r0, 0x0048(a0)              // set x velocity to 0
        sw      r0, 0x004C(a0)              // set y velocity to 0
        lbu     v1, 0x018D(a0)              // v1 = fast fall flag
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag

        _end:
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main subroutine for Knuckles' aerial up special.
    scope main_air_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x0038(sp)              // 0x0014(sp) = ra
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player object
        or      a3, a0, r0                  // a3 = player object
        addu    a2, a0, r0                  // a2 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        lhu     t6, 0x0184(v0)              // t6 = temp variable 3
        beqz    t6, _create_spring          // if temp variable 3 = 0, create spring projectile
        lw      t6, 0x017C(v0)              // t6 = temp variable 1
        beqz    t6, _check_end              // skip if temp variable 1 = 0
        lw      t6, 0x0184(v0)              // t6 = spring object

        // if we're here, then temp variable 1 was set, so uncoil the spring and begin upwards movement
        lw      at, 0x0074(t6)              // at = position struct
        beqz    at, _begin_movement         // if the projectile has been destroyed, skip
        nop
        lw      at, 0x0080(at)              // at = special image struct
        lh      t6, 0x0080(at)              // t6 = coiled spring index
        andi    t0, t6, 0x0001              // t0 = 1 if coiled
        beqz    t0, _begin_movement         // if already uncoiled, skip
        addiu   t6, t6, -0x0001             // t6 = uncoiled spring index
        mtc1    t6, f8                      // f8 = uncoiled spring index
        cvt.s.w f8, f8                      // t6 = uncoiled spring index, fp
        sh      t6, 0x0080(at)              // set image to uncoiled spring
        swc1    f8, 0x0088(at)              // set palette to uncoiled spring's

        _begin_movement:
        lui     at, Y_SPEED                 // at = Y_SPEED
        sw      at, 0x004C(v0)              // y velocity = Y_SPEED
        sw      r0, 0x017C(v0)              // reset temp variable 1
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

        _create_spring:
        addiu   a1, sp, 0x0020              // a1 = address to return x/y/z coordinates to
        sw      r0, 0x0020(sp)              // ~
        sw      r0, 0x0028(sp)              // x/z offset = 0
        sw      r0, 0x0024(sp)              // y offset = 0

        lw      a0, 0x08F8(v0)              // a0 = part 0x0 (body) struct
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
        sw      v0, 0x002C(sp)              // 0x002C(sp) = player struct
        sw      r0, 0x0028(sp)              // set z coordinate to 0
        lui     t6, 0xC364                  // t6 = -228 (fp)
        mtc1    t6, f8                      // f8 = -228
        lwc1    f6, 0x0024(sp)              // f6 = y coordinate
        add.s   f6, f6, f8                  // f6 = adjusted y coordinate
        swc1    f6, 0x0024(sp)              // update y coordinate
        lw      a0, 0x0034(sp)              // a0 = player object
        addiu   a2, r0, r0
        jal     spring_stage_setting_       // INITIATE SPRING
        addiu   a1, sp, 0x0020              // a1 = coordinates to create projectile at
        lw      a0, 0x0034(sp)              // a0 = player object

        _check_end:
        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        jal     0x800DEE54                  // transition to idle
        nop

        _end:
        lw      ra, 0x0038(sp)              // load ra
        jr      ra
        addiu   sp, sp, 0x0050              // deallocate stack space
    }

    // @ Description
    // Subroutine for Knuckles' aerial up special physics.
    scope air_physics_: {
        addiu   sp, sp, -0x0020
        sw      a0, 0x0018(sp)      // ~
        sw      ra, 0x001C(sp)      // store ra, a0
        lw      t0, 0x0084(a0)      // t0 = player struct
        lw      t0, 0x0B18(t0)      // t0 = movement flag
        beqz    t0, _end            // skip if movement flag = FALSE
        nop

        // if movement has started
        jal     0x800D90E0          // physics subroutine which allows player control
        nop

        _end:
        lw      ra, 0x001C(sp)      // load ra
        jr      ra
        addiu   sp, sp, 0x0020
    }

    // @ Description
    // Subroutine which sets up the initial properties for the projectile.
    // @ Arguments
    // a0 - player object
    // a1 - spring coordinates
    // a2 - ?
    scope spring_stage_setting_: {
        addiu   sp, sp, -0x0050             // allocate stack space
        sw      s0, 0x0018(sp)              // save registers
        sw      ra, 0x001C(sp)              // ~

        lw      t6, 0x0084(a0)              // t6 = player struct
        li      s0, spring_properties_struct // s0 = projectile properties struct address
        //lw      t0, 0x0024(s0)              // t0 = projectile data pointer
        lw      t1, 0x0028(s0)              // t1 = ?
        or      a2, a1, r0                  // a2 = spring coordinates

        lw      t8, 0x0008(t6)              // t8 = char_id
        if {defined Character.CHARACTER_ADDED_KNUCKLES} {
            lli     at, Character.id.KNUCKLES
            li      a1, knuckles_spring_projectile_struct // a1 = main projectile struct address
            beql    t8, at, _continue
            nop
        }
        if {defined Character.CHARACTER_ADDED_MKNUCKLES} {
            lli     at, Character.id.MKNUCKLES
            li      a1, mknuckles_spring_projectile_struct // a1 = main projectile struct address
            beql    t8, at, _continue
            nop
        }
        if {defined Character.CHARACTER_ADDED_CBKNUCKLES} {
            lli     at, Character.id.CBKNUCKLES
            li      a1, cbknuckles_spring_projectile_struct // a1 = main projectile struct address
            beql    t8, at, _continue
            nop
        }
        if {defined Character.CHARACTER_ADDED_CBMKNUCKLES} {
            lli     at, Character.id.CBMKNUCKLES
            li      a1, cbmknuckles_spring_projectile_struct // a1 = main projectile struct address
            beql    t8, at, _continue
            nop
        }

        _continue:
        lui     a3, 0x8000                  // a3 = ?
        sw      t6, 0x002C(sp)              // 0x002C(sp) = player struct
        jal     0x801655C8                  // This is a generic routine that does much of the work for defining all projectiles
        sw      t1, 0x000C(a1)              // ?

        beqz    v0, _end_stage_setting      // if 801655C8 returns 0, there's no space to create a new projectile object, so skip to end
        nop

        _projectile_branch:
        sw      v0, 0x0028(sp)              // 0x0028(sp) = projectile object
        lw      v1, 0x0084(v0)              // v1 = projectile struct
        sw      v1, 0x0024(sp)              // save projectile struct to stack
        lw      t3, 0x0000(s0)              // t3 = duration
        sw      t3, 0x0268(v1)              // store duration

        // update spring room, avoids adding stuff to sonic patch
        or      a0, r0, v0                  // a0 = projectile object
        lli     a1, 0x000B                  // a1 = room (originally 0x000E)
        jal     0x8000A0D0                  // gcMoveGObjDL
        lui     a2, 0x8000                  // a2 = GOBJ_PRIORITY_DEFAULT

        lw      v0, 0x0028(sp)              // v0 = projectile object
        lw      a0, 0x002C(sp)              // a0 = player struct
        lw      t7, 0x0008(a0)              // t7 = character id
        lw      t3, 0x0074(v0)              // t3 = position struct
        lw      t3, 0x0080(t3)              // t3 = special image struct

        lli     t6, 0x0001                  // t6 = 1 = spring coiled index
        if {defined Character.CHARACTER_ADDED_KNUCKLES} {
            lli     at, Character.id.KNUCKLES   // at = id.KNUCKLES
            beql    t7, at, pc() + 8        // if Classic Knuckles, use classic spring
            lli     t6, 0x0003              // t6 = 3 = classic spring coiled index
        }

        if {defined Character.CHARACTER_ADDED_CBKNUCKLES} {
            lli     at, Character.id.CBKNUCKLES // at = id.CBKNUCKLES
            beql    t7, at, pc() + 8        // if Classic Cowboy Knuckles, use classic spring
            lli     t6, 0x0003              // t6 = 3 = classic spring coiled index
        }
        sh      t6, 0x0080(t3)              // set image to coiled spring

        lui     t6, 0x3F80                  // t6 = 1 (fp) = spring coiled index for palette
        if {defined Character.CHARACTER_ADDED_KNUCKLES} {
            lli     at, Character.id.KNUCKLES   // at = id.KNUCKLES
            beql    t7, at, pc() + 8        // if Classic Knuckles, use classic spring
            lui     t6, 0x4040              // t6 = 3 (fp) = classic spring coiled index for palette
        }

        if {defined Character.CHARACTER_ADDED_CBKNUCKLES} {
            lli     at, Character.id.CBKNUCKLES // at = id.CBKNUCKLES
            beql    t7, at, pc() + 8        // if Classic Cowboy Knuckles, use classic spring
            lui     t6, 0x4040              // t6 = 3 (fp) = classic spring coiled index for palette
        }
        sw      t6, 0x0088(t3)              // set palette to coiled spring's

        lb      at, 0x0186(a0)              // at = clipping ID of character at start of USP
        lbu     t3, 0x0187(a0)              // t3 = kinetic state to initialize as (1 = aerial, 0 = grounded)
        sw      v0, 0x0184(a0)              // temp variable 3 = projectile object
        sw      r0, 0x0040(v0)              // set spring check flag to false
        sw      r0, 0x0150(v1)              // turn off hitbox initially
        bnez    t3, _fgm                    // if not grounded, skip
        lw      t6, 0x00EC(a0)              // t6 = clipping ID of player
        bnel    at, t6, _fgm                // if character is no longer over original clipping ID, set to aerial
        lli     t3, 0x0001                  // t3 = kinetic state = aerial
        bgezl   t6, _fgm                    // if player is still over a valid clipping ID, set for spring
        sw      t6, 0x00A0(v1)              // set clipping ID of spring

        // if here, set initial state to aerial
        lli     t3, 0x0001                  // t3 = kinetic state = aerial

        _fgm:
        sw      t3, 0x00FC(v1)              // initialize kinetic state
        lli     a0, 0x03D7                  // a0 = spring fgm_id

        if {defined Character.CHARACTER_ADDED_KNUCKLES} {
            lli     at, Character.id.KNUCKLES   // at = id.KNUCKLES
            beql    t7, at, pc() + 8        // if Classic Knuckles, use classic spring
            lli     a0, 0x03DF              // a0 = classic spring fgm_id
        }
        if {defined Character.CHARACTER_ADDED_CBKNUCKLES} {
            lli     at, Character.id.CBKNUCKLES // at = id.CBKNUCKLES
            beql    t7, at, pc() + 8        // if Classic Cowboy Knuckles, use classic spring
            lli     a0, 0x03DF              // a0 = classic spring fgm_id
        }

        _play_fgm:
        jal     FGM.play_                   // play FGM
        sw      a0, 0x0044(v0)              // save fgm_id

        lw      t6, 0x002C(sp)              // ~
        lw      v1, 0x0024(sp)              // ~
        lw      t7, 0x0044(t6)              // ~
        mul.s   f8, f0, f6                  // ~
        mtc1    r0, f12                     // ~
        mtc1    t7, f10                     // ~
        nop                                 // ~
        cvt.s.w f16, f10                    // ~
        mul.s   f18, f8, f16                // ~
        //jal     0x800303F0                  // ~
        //swc1    f18, 0x0020(v1)             // original logic

        lw      v1, 0x0024(sp)              // ~
        lw      a0, 0x0028(sp)              // ~
        jal     0x80167FA0                  // ~
        nop

        lw      v0, 0x0028(sp)              // original logic

        _end_stage_setting:
        lw      ra, 0x001C(sp)
        lw      s0, 0x0018(sp)
        jr      ra
        addiu   sp, sp, 0x0050
    }

    // @ Description
    // Subroutine which accounts for the main function of spring projectile
    scope spring_main_: {
        addiu   sp, sp, -0x0030     // allocate stack space
        sw      ra, 0x0014(sp)      // save registers
        sw      a0, 0x0020(sp)      // ~

        lw      a0, 0x0084(a0)      // a0 = projectile special struct
        jal     0x80167FE8          // counts down from duration
        sw      a0, 0x001C(sp)      // save projectile special struct
        beqz    v0, _continue       // if duration not met, continue
        lw      a0, 0x001C(sp)      // a0 = projectile special struct

        // end projectile
        lw      t7, 0x0020(sp)      // t7 = projectile object
        lui     a1, 0x3F80          // a1 = 1 (fp)
        lw      a0, 0x0074(t7)      // a0 = projectile position struct
        jal     0x800FF648          // create smoke gfx
        addiu   a0, a0, 0x001C      // a0 = coordinates
        b       _end
        addiu   v0, r0, 0x0001      // v0 = 1 means destroy spring object

        _continue:
        li      v0, spring_properties_struct
        lw      t8, 0x0000(v0)      // t8 = initial duration
        addiu   t8, t8, -0x0004     // t8 = initial duration - 4 frames
        // t7 has current count from prior jal
        sltu    t8, t7, t8          // t8 = 1 if after first 4 frames
        mtc1    r0, f6              // f6 = 0 = no rotation
        beqz    t8, _initial_rotation // if in the first 4 frames, skip normal rotation/gravity
        addiu   a1, r0, r0          // set gravity to 0

        // rest of the duration functionality
        lw      a1, 0x000C(v0)      // load normal gravity

        lw      t1, 0x0020(sp)      // t1 = projectile object
        lw      t2, 0x0084(t1)      // t2 = projectile special struct

        // ensure hitbox is always on in the air
        lli     at, 0x0001          // at = 1 = enable hitbox
        sw      at, 0x0150(t2)      // turn on hitbox

        lw      t3, 0x00FC(t2)      // t3 = 0 if grounded
        bnezl   t3, _initial_rotation // if not grounded, rotate
        lwc1    f6, 0x0014(v0)      // load normal rotation

        // if here, set the rotation to 0
        lw      v1, 0x0074(t1)      // v1 = top joint
        sw      r0, 0x0030(v1)      // set current rotation value to 0

        // remove hitbox and remove stored player objects
        sw      r0, 0x0150(t2)      // turn off hitbox
        lli     at, 0x00E0          // at = flag
        sw      r0, 0x0214(t2)      // clear hit player object reference
        sb      at, 0x0218(t2)      // clear hit flag
        sw      r0, 0x021C(t2)      // clear hit player object reference
        sb      at, 0x0220(t2)      // clear hit flag
        sw      r0, 0x0224(t2)      // clear hit player object reference
        sb      at, 0x0228(t2)      // clear hit flag
        sw      r0, 0x022C(t2)      // clear hit player object reference
        sb      at, 0x0230(t2)      // clear hit flag

        lli     at, 0x0001          // at = 1 = enable spring
        sw      at, 0x0040(t1)      // set enable spring flag to true

        // and set to uncoiled
        lw      t3, 0x0080(v1)      // t3 = special image struct
        lh      t6, 0x0080(t3)      // t6 = spring index
        andi    at, t6, 0x0001      // at = 1 if coiled
        beqz    at, _after_rotation_set // if already uncoiled, skip
        addiu   t6, t6, -0x0001     // t6 = uncoiled spring index
        mtc1    t6, f8              // f8 = uncoiled spring index
        cvt.s.w f8, f8              // t6 = uncoiled spring index, fp
        sh      t6, 0x0080(t3)      // set image to coiled spring
        swc1    f8, 0x0088(t3)      // set palette to coiled spring's

        b       _after_rotation_set
        sw      r0, 0x0040(t1)      // set enable spring flag to false this frame

        _initial_rotation:
        lw      t1, 0x0020(sp)      // t1 = projectile object
        lw      v1, 0x0074(t1)      // v1 = top joint
        lwc1    f4, 0x0030(v1)      // f4 = current rotation value
        add.s   f8, f4, f6          // f8 = new rotation value
        swc1    f8, 0x0030(v1)      // update rotation value

        _after_rotation_set:
        // todo: check if the following 2 lines are necessary
        addiu   t2, r0, r0          // used to use free space area, but for no apparent reason, effects graphics
        addiu   t8, r0, r0          // used to use free space area, but for no apparent reason, affects graphics

        jal     0x80168088          // main projectile routine
        lw      a2, 0x0004(v0)      // a2 = max speed

        lw      a0, 0x0020(sp)      // a0 = projectile object
        lw      at, 0x0040(a0)      // at = spring enabled flag
        beqz    at, _end            // if not enabled, skip
        or      v0, r0, r0          // v0 = 0 (don't destroy spring)

        jal     check_spring_bounce_
        nop

        or      v0, r0, r0          // v0 = 0 (don't destroy spring)

        _end:
        lw      ra, 0x0014(sp)      // restore registers
        jr      ra
        addiu   sp, sp, 0x0030      // deallocate stack space
    }

    // @ Description
    // For the given spring, checks if any players should trigger the spring.
    // @ Arguments
    // a0 - spring projectile object
    scope check_spring_bounce_: {
        addiu   sp, sp, -0x0030     // allocate stack space
        sw      ra, 0x0024(sp)      // save registers
        sw      a0, 0x0028(sp)      // ~

        lui     t0, 0x8004
        lw      t0, 0x66FC(t0)      // t0 = first player object

        _loop:
        beqz    t0, _end            // stop looping if no more players to check
        nop
        lw      t1, 0x0074(t0)      // t1 = player position struct (top joint)
        lw      t2, 0x0084(t0)      // t2 = player struct

        lw      t3, 0x0008(t2)      // t3 = char_id
        lli     at, Character.id.BOSS
        beq     t3, at, _next       // if Masterhand, skip
        lw      at, 0x014C(t2)      // at = kinetic state

        beqz    at, _next           // if player is grounded, skip
        lw      t3, 0x0024(t1)      // t3 = player Z position

        bnez    t3, _next           // if player Z position is not 0, skip
        lwc1    f4, 0x0090(t2)      // f4 = Y velocity

        mtc1    r0, f0              // f0 = 0
        c.lt.s  f4, f0              // check if Y velocity is negative
        bc1f    _next               // if Y velocity is not negative, skip
        lwc1    f4, 0x001C(t1)      // f4 = player X position

        lw      t4, 0x0074(a0)      // t4 = spring position struct
        lwc1    f6, 0x001C(t4)      // f6 = spring X position

        lw      t3, 0x0084(a0)      // t3 = spring projectile special struct

        sub.s   f4, f4, f6          // f4 = player X position - spring X position
        abs.s   f4, f4              // f4 = |player X position - spring X position|
        lwc1    f2, 0x0070(t3)      // f2 = spring ECB width/2
        c.le.s  f4, f2              // check if player is within X bounds of spring
        bc1f    _next               // if player is not within X bounds of spring, skip
        lwc1    f4, 0x0020(t1)      // f4 = player Y position

        lwc1    f6, 0x0020(t4)      // f6 = spring center Y position
        lwc1    f2, 0x0064(t3)      // f2 = spring ECB top point Y offset
        add.s   f2, f6, f2          // f2 = spring top Y position
        c.lt.s  f4, f6              // check if player is below the spring center
        bc1t    _next               // if player is below the spring center, skip
        nop
        c.le.s  f4, f2              // check if player is at or below top of spring
        bc1f    _next               // if player is above top of spring,  skip
        lw      t3, 0x0024(t2)      // t3 = Action

        // if we're here, then initiate spring

        // move player to be on spring
        swc1    f6, 0x0020(t1)      // update Y position of player

        // update spring to coiled
        lw      t4, 0x0074(a0)      // t4 = spring position struct
        lw      t4, 0x0080(t4)      // t4 = special image struct
        lh      t6, 0x0080(t4)      // t6 = spring index
        andi    at, t6, 0x0001      // at = 1 if coiled
        bnez    at, _check_action   // if already coiled, skip
        addiu   t6, t6, 0x0001      // t6 = coiled spring index
        mtc1    t6, f8              // f8 = coiled spring index
        cvt.s.w f8, f8              // t6 = coiled spring index, fp
        sh      t6, 0x0080(t4)      // set image to coiled spring
        swc1    f8, 0x0088(t4)      // set palette to coiled spring's

        _check_action:
        // For some actions, we'll do an action change to JumpF
        // Valid action ranges: JumpF - Pass, Tumble - FallSpecial

        or      a0, t0, r0          // a0 = player object
        sw      a0, 0x002C(sp)      // save player object

        lli     t4, Action.JumpF
        sltu    t4, t3, t4          // t4 = 1 if < JumpF
        bnez    t4, _keep_action    // if not in range, don't change action
        lli     t4, Action.Pass + 1
        sltu    t4, t3, t4          // t4 = 1 if in range for JumpF - Pass
        bnez    t4, _change_action  // if in range, do action change
        lli     t4, Action.Tumble
        sltu    t4, t3, t4          // t4 = 1 if < Tumble
        bnez    t4, _keep_action    // if not in range, don't change action
        lli     t4, Action.FallSpecial
        sltu    t4, t3, t4          // t4 = 1 if in range for Tumble = FallSpecial
        bnez    t4, _change_action  // if not in range, change action
        lli     t4, Action.ShieldBreakFall
        beq     t4, t3, _change_action  // if in Shield Break Fall, change action
        lli     t4, Action.ShieldBreak
        beq     t4, t3, _change_action  // if in Shield Break Fall, change action
        lli     t4, Action.InhalePulled
        beq     t4, t3, _next       // if in Inhale Pulled, ignore spring
        nop

        _keep_action:
        // Some character actions need to be interrupted, so check!

        lw      t4, 0x0008(t2)      // t4 = char_id
        lli     at, Character.id.FOX
        beq     t4, at, _fox_falco  // if Fox, need to do action checks
        lli     at, Character.id.JFOX
        beq     t4, at, _fox_falco  // if JFox, need to do action checks
        lli     at, Character.id.FALCO
        beq     t4, at, _fox_falco  // if Falco, need to do action checks
        lli     at, Character.id.PEPPY
        beq     t4, at, _peppy      // if Peppy, need to do action checks
        lli     at, Character.id.KIRBY
        beq     t4, at, _kirby      // if Kirby, need to do action checks
        lli     at, Character.id.JKIRBY
        beq     t4, at, _kirby      // if JKirby, need to do action checks
        lli     at, Character.id.YOSHI
        beq     t4, at, _yoshi      // if Yoshi, need to do action checks
        lli     at, Character.id.JYOSHI
        beq     t4, at, _yoshi      // if JYoshi, need to do action checks
        lli     at, Character.id.BOWSER
        beq     t4, at, _bowser     // if Bowser, need to do action checks
        lli     at, Character.id.GBOWSER
        beq     t4, at, _bowser     // if Giga Bowser, need to do action checks
        lli     at, Character.id.NESS
        beq     t4, at, _ness_lucas     // if Ness, need to do action checks
        lli     at, Character.id.JNESS
        beq     t4, at, _ness_lucas     // if J Ness, need to do action checks
        lli     at, Character.id.LUCAS
        beq     t4, at, _ness_lucas     // if Lucas, need to do action checks
        lli     at, Character.id.CONKER
        beq     t4, at, _conker         // if Conker, need to do action checks
        lli     at, Character.id.MARTH
        beq     t4, at, _marth          // if Marth, need to do action checks
        if {defined Character.CHARACTER_ADDED_KNUCKLES} {
            lli     at, Character.id.KNUCKLES
            beq     t4, at, _knuckles   // if Knuckles, need to do action checks
        }
        if {defined Character.CHARACTER_ADDED_MKNUCKLES} {
            lli     at, Character.id.MKNUCKLES
            beq     t4, at, _knuckles   // if Knuckles, need to do action checks
        }
        if {defined Character.CHARACTER_ADDED_CBMKNUCKLES} {
            lli     at, Character.id.CBMKNUCKLES
            beq     t4, at, _knuckles   // if Knuckles, need to do action checks
        }
        if {defined Character.CHARACTER_ADDED_CBKNUCKLES} {
            lli     at, Character.id.CBKNUCKLES
            beq     t4, at, _knuckles   // if Knuckles, need to do action checks
        }
        nop

        b       _draw_smoke_gfx
        nop

        _peppy:
        lli     t4, Action.FOX.FireFoxAir  // same as PEPPY.Action.FireHareAir
        beq     t3, t4, _change_action
        nop
        b        _draw_smoke_gfx
        nop

        _fox_falco:
        // Change action for these actions
        lli     t4, Action.FOX.FireFoxAir  // same as FALCO.Action.FireBirdAir
        beq     t3, t4, _change_action
        addiu   at, r0, Action.FOX.ReflectorTurnAir // final reflector action
        lli     t4, Action.FOX.ReflectorStartAir  // same as FALCO

        _reflector_loop:
        beq     t3, t4, _change_action
        nop
        bne     at, t4, _reflector_loop
        addiu   t4, t4, 0x0001
        // Otherwise, don't change action
        b        _draw_smoke_gfx
        nop

        _kirby:
        // Change action for these actions
        lli     t4, Action.KIRBY.FinalCutter
        beq     t3, t4, _change_action
        lli     t4, Action.KIRBY.FinalCutterAir
        beq     t3, t4, _change_action
        lli     t4, Action.KIRBY.FinalCutterFall
        beq     t3, t4, _change_action
        lli     t4, Action.KIRBY.StoneFall
        beq     t3, t4, _change_action
        nop
        // Otherwise, don't change action
        b        _draw_smoke_gfx
        nop

        _yoshi:
        // Change action for these actions
        lli     t4, Action.YOSHI.GroundPoundDrop
        beq     t3, t4, _change_action
        nop
        // Otherwise, don't change action
        b        _draw_smoke_gfx
        nop

        _bowser:
        // Change action for these actions
        lli     t4, Bowser.Action.BowserBombDrop
        beq     t3, t4, _change_action
        // Skip for these actions
        lli     t4, Bowser.Action.BowserForwardThrow1   // same as Giga Bowser
        beq     t3, t4, _next
        lli     t4, Bowser.Action.BowserForwardThrow2   // same as Giga Bowser
        beq     t3, t4, _next
        lli     t4, Bowser.Action.BowserForwardThrow3   // same as Giga Bowser
        beq     t3, t4, _next
        nop
        // Otherwise, don't change action
        b        _draw_smoke_gfx
        nop

        _ness_lucas:
        addiu   at, r0, Action.NESS.PsiMagnetEndAir // final magnet action
        lli     t4, Action.NESS.PsiMagnetStartAir   // same as LUCAS

        _magnet_loop:
        beq     t3, t4, _psi_magnet
        nop
        bne     at, t4, _magnet_loop
        addiu   t4, t4, 0x0001

        addiu   at, r0, Action.NESS.PKTAAir          // final pk thunder action
        lli     t4, Action.NESS.PKThunderStartAir    // same as LUCAS


        _pk_thunder_loop:
        beq     t3, t4, _change_action
        nop
        bne     at, t4, _pk_thunder_loop
        addiu   t4, t4, 0x0001

        // Otherwise, don't change action
        b        _draw_smoke_gfx
        nop

        _psi_magnet:
        sw      r0, 0x0A20(t2)                      // clear Overlay Routine
        sw      r0, 0x0A24(t2)                      // clear Overlay Routine
        sw      r0, 0x0A28(t2)                      // clear Overlay Routine
        sw      r0, 0x0A30(t2)                      // clear Overlay Flag
        sh      r0, 0x018C(t2)                      // clear space used for overlay stuff
        j       _change_action
        sw      r0, 0x0A88(t2)                      // clear current Overlay


        _marth:
        // Change action for these actions
        lli     t4, Marth.Action.DSPGA
        beq     t3, t4, _change_action
        lli     t4, Marth.Action.DSPGA_Attack
        beq     t3, t4, _change_action
        nop
        // Otherwise, don't change action
        b        _draw_smoke_gfx
        nop

        _conker:
        // Change action for these actions
        lli     t4, Conker.Action.HelicopteryTailThingAir
        beq     t3, t4, _change_action
        lli     t4, Conker.Action.HelicopteryTailThingDescent
        beq     t3, t4, _change_action
        nop
        // Otherwise, don't change action
        b        _draw_smoke_gfx
        nop

        _knuckles:
        // Change action for these actions
        lli     t4, CBMKnuckles.Action.DiveAirBegin
        beq     t3, t4, _change_action
        lli     t4, CBMKnuckles.Action.DiveAirLoop
        beq     t3, t4, _change_action
        lli     t4, CBMKnuckles.Action.DiveLand
        beq     t3, t4, _change_action
        nop

        // Otherwise, don't change action
        b        _draw_smoke_gfx
        nop

        _change_action:
        // set player action to JumpF
        lli     a1, Action.JumpF    // a1(action id) = JumpF
        or      a2, r0, r0          // a2(starting frame) = 0
        lui     a3, 0x3F80          // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24          // change action
        sw      r0, 0x0010(sp)      // argument 4 = 0
        jal     0x800E0830          // unknown common subroutine
        lw      a0, 0x002C(sp)      // a0 = player object
        b       _set_y_velocity     // skip drawing jump smoke gfx when we change actions
        nop

        _draw_smoke_gfx:
        // draw jump smoke gfx
        lw      a0, 0x002C(sp)      // a0 = player object
        lw      a0, 0x0074(a0)      // a0 = top joint
        addiu   a0, a0, 0x001C      // a0 = player x/y/z pointer
        ori     a1, r0, 0x0001      // a1 = 0x1
        lui     a2, 0x3F80          // a2 = float: 1.0
        jal     0x800FF3F4          // jump smoke graphic
        addiu   sp, sp, -0x0010     // allocate stack space
        addiu   sp, sp, 0x0010      // restore stack space

        _set_y_velocity:
        // set initial Y velocity
        lw      t0, 0x002C(sp)      // t0 = player object
        lw      t1, 0x0084(t0)      // t1 = player struct
        lui     at, 0x42f0          // at = initial Y velocity = 120
        sw      at, 0x004C(t1)      // set initial Y velocity
        sw      r0, 0x0058(t1)      // clear knockback Y velocity
        lbu     at, 0x018D(t1)      // at = bit field
        andi    at, at, 0x0007      // at = bit field & mask(0b01111111), this disables the fast fall flag
        sb      at, 0x018D(t1)      // store updated bit field

        // play spring sound
        lw      a0, 0x0028(sp)      // a0 = spring projectile object
        jal     FGM.play_           // play fgm
        lw      a0, 0x0044(a0)      // a0 = spring or classic spring fgm_id

        // do rumble
        lw      t0, 0x002C(sp)      // t0 = player object
        lw      t1, 0x0084(t0)      // t1 = player struct
        lbu     a1, 0x0023(t1)      // a1 = player type (0 = HMN, 1 = CPU)
        bnez    a1, _end_rumble     // if port is CPU, skip rumble
        lbu     a0, 0x000D(t1)      // a0 = port
        lli     a1, 0x0000          // a1 = rumble_id
        lli     a2, 0x0005          // a2 = duration
        jal     Global.rumble_      // add rumble
        addiu   sp, sp, -0x0030     // allocate stack space (not a safe function)
        addiu   sp, sp, 0x0030      // deallocate stack space

        _end_rumble:
        lw      t0, 0x002C(sp)      // t0 = player object

        // if Sonic, restore specials
        lw      t3, 0x0084(t0)      // t3 = player struct
        lw      t4, 0x0008(t3)      // t4 = char_id
        lli     at, Character.id.SONIC
        beql    t4, at, _next       // if Sonic, restore specials
        sw      r0, 0x0ADC(t3)      // set up special bool to FALSE
        lli     at, Character.id.SSONIC
        beql    t4, at, _next       // if Super Sonic, restore specials
        sw      r0, 0x0ADC(t3)      // set up special bool to FALSE
        lli     at, Character.id.EBI
        beql    t4, at, _next       // if Ebisumaru, restore specials
        sw      r0, 0x0ADC(t3)      // set up special bool to FALSE
        if {defined Character.CHARACTER_ADDED_KNUCKLES} {
            lli     at, Character.id.KNUCKLES
            beql    t4, at, _next       // if Knuckles, restore specials
            sw      r0, 0x0ADC(t3)      // set up special bool to FALSE
        }
        if {defined Character.CHARACTER_ADDED_MKNUCKLES} {
            lli     at, Character.id.MKNUCKLES
            beql    t4, at, _next       // if MKnuckles, restore specials
            sw      r0, 0x0ADC(t3)      // set up special bool to FALSE
        }
        if {defined Character.CHARACTER_ADDED_CBKNUCKLES} {
            lli     at, Character.id.CBKNUCKLES
            beql    t4, at, _next       // if CB Knuckles, restore specials
            sw      r0, 0x0ADC(t3)      // set up special bool to FALSE
        }
        if {defined Character.CHARACTER_ADDED_CBMKNUCKLES} {
            lli     at, Character.id.CBMKNUCKLES
            beql    t4, at, _next       // if CB MKnuckles, restore specials
            sw      r0, 0x0ADC(t3)      // set up special bool to FALSE
        }

        _next:
        lw      a0, 0x0028(sp)      // a0 = spring projectile object
        b       _loop
        lw      t0, 0x0004(t0)      // t0 = next player object

        _end:
        lw      ra, 0x0024(sp)      // restore registers
        jr      ra
        addiu   sp, sp, 0x0030      // deallocate stack space
    }

    // @ Description
    // Subroutine for Knuckles's aerial up special interrupt.
    scope interrupt_with_turnaround_: {
        addiu   sp, sp, -0x0020
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      at, 0x0180(t0)              // at = temp variable 2
        ori     t1, r0, 0x2                 // t1 = 0x2
        bne     at, t1, _direction          // skip if temp variable 2 != 0x2
        sw      ra, 0x001C(sp)              // store ra

        // if temp variable 2 was set, do an action check/allow interrupts
        jal     0x80150B00                  // check for aerial attacks
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        bnezl   v0, _end                    // end if aerial attack initiated
        lw      ra, 0x001C(sp)              // load ra
        jal     0x8014019C                  // check for midair jumps
        lw      a0, 0x0018(sp)              // a0 = player object

        b       _end
        lw      ra, 0x001C(sp)              // load ra

        _direction:
        lw      a1, 0x0084(a0)              // a1 = player struct
        lw      at, 0x0180(a1)              // at = temp variable 2
        ori     t1, r0, 0x1                 // t1 = 0x1
        bne     at, t1, _turnend            // skip if temp variable 2 != 0x1
        nop
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      ra, 0x001C(sp)              // store t0, t1, r
        jal     0x80160370                  // turn subroutine (copied from captain falcon)
        nop
        b       _turnend

        _turnend:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x001C(sp)              // load t0, t1, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space

        _end:
        jr      ra
        addiu   sp, sp, 0x0020
    }

    // @ Description
    // Original subroutine for Knuckles' aerial up special interrupt.
    scope interrupt_: {
        addiu   sp, sp, -0x18
        sw      ra, 0x0014(sp)              // store ra
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      at, 0x0180(t0)              // at = temp variable 2
        beqzl   at, _end                    // skip if temp variable 2 isn't set
        lw      ra, 0x14(sp)                // load ra

        // if temp variable 2 was set, do an action check/allow interrupts
        jal     0x80150B00                  // check for aerial attacks
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object

        bnezl   v0, _end                    // end if aerial attack initiated
        lw      ra, 0x0014(sp)              // load ra

        jal     0x8014019C                  // check for midair jumps
        lw      a0, 0x0018(sp)              // a0 = player object

        lw      ra, 0x0014(sp)              // load ra
        _end:
        jr      ra
        addiu   sp, sp, 0x18
    }

    // @ Description
    // Clang routine for Knuckles' spring.
    // Copy of 0x80168A14 (wpFoxBlasterProcReflector), adjusted to skip jumping to a remix patch.
    scope spring_clang_: {
        // Copy the first 5 lines of 0x80168A14
        OS.copy_segment(0xE3454, 0x14)

        // original lines 1 and 2 taken from 0x801680EC (wpMainReflectorSetLR)
        lw      t6, 0x0044(a1)              // t6 = player facing direction, original line 1
        lwc1    f0, 0x0020(a0)              // f0 = projectile horizontal direction, original line 2
        jal     0x801680F4                  // jump to rest of wpMainReflectorSetLR (skip remix patch)
        // delay slot from below copy

        // copy the last 16 lines of 0x80168A14
        OS.copy_segment(0xE3470, 0x40)
    }

    if {defined Character.CHARACTER_ADDED_KNUCKLES} {
        if !{defined Projectile.id.KNUCKLES_SPRING} {
            Projectile.add_projectile(KNUCKLES_SPRING)
        }

        OS.align(16)
        knuckles_spring_projectile_struct:
        dw 0x00000000                           // unknown
        dw Projectile.id.KNUCKLES_SPRING        // projectile id
        dw Character.KNUCKLES_file_6_ptr        // address of knuckles' file 6 pointer
        dw 0x00000000                           // 00000000
        dw 0x12470000                           // This determines z axis rotation? (samus is 1246)
        dw spring_main_                         // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
        dw 0x80169108                           // This function runs when the projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
        dw 0x80169108                           // This function runs when the projectile collides with a hurtbox.
        dw 0                                    // This function runs when the projectile collides with a shield.
        dw 0                                    // This function runs when the projectile collides with edges of a shield and bounces off
        dw spring_clang_                        // This function runs when the projectile collides/clangs with a hitbox.
        dw 0                                    // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
        dw 0                                    // This function runs when the projectile collides with Ness's psi magnet
        OS.copy_segment(0x103904, 0x0C)         // empty
    }

    if {defined Character.CHARACTER_ADDED_MKNUCKLES} {
        if !{defined Projectile.id.MKNUCKLES_SPRING} {
            Projectile.add_projectile(MKNUCKLES_SPRING)
        }

        OS.align(16)
        mknuckles_spring_projectile_struct:
        dw 0x00000000                           // unknown
        dw Projectile.id.MKNUCKLES_SPRING       // projectile id
        dw Character.MKNUCKLES_file_6_ptr       // address of knuckles' file 6 pointer
        dw 0x00000000                           // 00000000
        dw 0x12470000                           // This determines z axis rotation? (samus is 1246)
        dw spring_main_                         // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
        dw 0x80169108                           // This function runs when the projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
        dw 0x80169108                           // This function runs when the projectile collides with a hurtbox.
        dw 0                                    // This function runs when the projectile collides with a shield.
        dw 0                                    // This function runs when the projectile collides with edges of a shield and bounces off
        dw spring_clang_                        // This function runs when the projectile collides/clangs with a hitbox.
        dw 0                                    // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
        dw 0                                    // This function runs when the projectile collides with Ness's psi magnet
        OS.copy_segment(0x103904, 0x0C)         // empty
    }

    if {defined Character.CHARACTER_ADDED_CBKNUCKLES} {
        if !{defined Projectile.id.CBKNUCKLES_SPRING} {
            Projectile.add_projectile(CBKNUCKLES_SPRING)
        }

        OS.align(16)
        cbknuckles_spring_projectile_struct:
        dw 0x00000000                           // unknown
        dw Projectile.id.CBKNUCKLES_SPRING      // projectile id
        dw Character.CBKNUCKLES_file_6_ptr      // address of knuckles' file 6 pointer
        dw 0x00000000                           // 00000000
        dw 0x12470000                           // This determines z axis rotation? (samus is 1246)
        dw spring_main_                         // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
        dw 0x80169108                           // This function runs when the projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
        dw 0x80169108                           // This function runs when the projectile collides with a hurtbox.
        dw 0                                    // This function runs when the projectile collides with a shield.
        dw 0                                    // This function runs when the projectile collides with edges of a shield and bounces off
        dw spring_clang_                        // This function runs when the projectile collides/clangs with a hitbox.
        dw 0                                    // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
        dw 0                                    // This function runs when the projectile collides with Ness's psi magnet
        OS.copy_segment(0x103904, 0x0C)         // empty
    }

    if {defined Character.CHARACTER_ADDED_CBMKNUCKLES} {
        if !{defined Projectile.id.CBMKNUCKLES_SPRING} {
            Projectile.add_projectile(CBMKNUCKLES_SPRING)
        }

        OS.align(16)
        cbmknuckles_spring_projectile_struct:
        dw 0x00000000                           // unknown
        dw Projectile.id.CBMKNUCKLES_SPRING     // projectile id
        dw Character.CBMKNUCKLES_file_6_ptr     // address of knuckles' file 6 pointer
        dw 0x00000000                           // 00000000
        dw 0x12470000                           // This determines z axis rotation? (samus is 1246)
        dw spring_main_                         // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
        dw 0x80169108                           // This function runs when the projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
        dw 0x80169108                           // This function runs when the projectile collides with a hurtbox.
        dw 0                                    // This function runs when the projectile collides with a shield.
        dw 0                                    // This function runs when the projectile collides with edges of a shield and bounces off
        dw spring_clang_                        // This function runs when the projectile collides/clangs with a hitbox.
        dw 0                                    // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
        dw 0                                    // This function runs when the projectile collides with Ness's psi magnet
        OS.copy_segment(0x103904, 0x0C)         // empty
    }

    OS.align(16)
    spring_properties_struct:
    dw 120                                  // 0x0000 - duration (int)
    float32 100                             // 0x0004 - max speed
    float32 100                             // 0x0008 - min speed
    float32 3                               // 0x000C - gravity
    float32 1.5                             // 0x0010 - bounce multiplier
    float32 0.1875                          // 0x0014 - rotation speed
    float32 0                               // 0x0018 - initial angle (ground)
    float32 0                               // 0x001C   initial angle (air)
    float32 0                               // 0x0020   initial speed
    dw 0x0                                  // 0x0024   projectile data pointer
    dw 0x00000000                           // 0x0028   unknown (default 0)
    dw 0x00000000                           // 0x002C   palette index (0 = mario, 1 = luigi)
}

scope CBMKnucklesNSP {
    constant TURNFRAMES(32)             // 32
    constant STARTSPEED(0x42660000)     // 57.5
    constant DESCENT(0xC1040000)        // -8.25
    constant CLAMPX(0x42F00000)         // 120.0
    constant ACCELX(0x3DCCCCCD)         // 0.1
    constant ACCELY(0x3F800000)         // 1.0
    constant GRAVITY(0x40400000)        // 3.0
    constant MAX_TIME(100)              // 100 frames

    // @ Description
    // Subroutine which runs when Knuckles initiates an aerial neutral special.
    scope air_begin_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      v0, 0x0084(a0)              // v0 = player struct

        lw      at, 0x0AE0(v0)
        beqzl   at, _glide
        addiu   a1, r0, CBMKnuckles.Action.NSP_Air_Begin // a1(action id) = NSP_Air_Begin

        jal     CBMKnucklesDive.air_initial_  // a1(transition subroutine) = dive punch air initial
        nop
        b       _end
        lw      ra, 0x1C(sp)

        _glide:
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // Store flags: none
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      t0, 0x0020(sp)              // Load fighter_gobj
        lw      v0, 0x0084(t0)              // Load fighter struct
        lli     at, 0x0001                  // ~
        sw      at, 0x014C(v0)              // set kinetic state to aerial
        sw      r0, 0x017C(v0)              // temp variable 1 = 0
        sw      r0, 0x0180(v0)              // temp variable 2 = 0
        sw      r0, 0x0184(v0)              // temp variable 3 = 0
        lli     at, MAX_TIME                // Load MAX_TIME
        sw      at, 0x0B18(v0)              // set frame timer to MAX_TIME
        addiu   at, r0, OS.TRUE             // at = OS.TRUE
        sw      at, 0x0AE0(v0)              // glide flag = at
        li      at, STARTSPEED              // Load STARTSPEED
        mtc1    at, f0                      // Move STARTSPEED to f0
        nop                                 // ~
        // lwc1    f2, 0x0048(v0)              // Load x velocity
        // abs.s   f2, f2                      // Make x velocity absolute
        // c.lt.s  f2, f0                      // Check if current x velocity < STARTSPEED
        // nop                                 // ~
        // bc1fl   _descent_check              // If current x velocity >= STARTSPEED, skip ahead
        // nop                                 // ~
        lwc1    f2, 0x0044(v0)              // Load direction
        cvt.s.w f2, f2                      // Convert direction to float
        nop                                 // ~
        mul.s   f0, f0, f2                  // Multiply STARTSPEED by direction
        nop                                 // ~
        swc1    f0, 0x0048(v0)              // Set x velocity

        _descent_check:
        li      at, DESCENT                 // Load DESCENT
        mtc1    at, f0                      // Move DESCENT to f0
        nop                                 // ~
        lwc1    f2, 0x004C(v0)              // Load current y velocity
        c.le.s  f2, f0                      // If current y velocity is less than or equal to DESCENT...
        nop                                 // ~
        bc1tl   _tvel_check                 // ...then go to terminal velocity check
        lw      t0, 0x09C8(v0)              // Load attributes

        swc1    f0, 0x004C(v0)              // Store DESCENT as y velocity
        b       _end                        // Go to end
        lw      ra, 0x001C(sp)              // Load ra in delay slot

        _tvel_check:
        lwc1    f0, 0x005C(t0)              // Load normal terminal velocity
        neg.s   f0, f0                      // Negate terminal velocity because it is positive by default

        c.lt.s  f2, f0                      // Check if y velocity is faster than terminal velocity
        nop                                 // ~

        bc1fl   _end
        lw      ra, 0x001C(sp)              // If not faster than, go to end

        swc1    f0, 0x004C(v0)              // ...otherwise store terminal velocity as y velocity
        lw      ra, 0x001C(sp)              // load ra

        _end:
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Main subroutine for NSP_Air_Begin
    scope air_begin_main_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct

        //lh      t7, 0x01BC(v0)              // t7 = buttons_held
        //andi    t7, t7, Joypad.B            // t7 = 0x0020 if (B_HELD); else t7 = 0
        //beqz    t7, _check_end              // branch if !(B_HELD)
        //nop

        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop

        _check_end:
        jal     air_wait_initial_           // common main subroutine (transition on animation end)
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Knuckles's aerial neutral special wait action.
    scope air_wait_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lli     a1, CBMKnuckles.Action.NSP_Air_Wait // a1(action id) = NSP_Air_Wait
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0800                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0800 (this flag continues FGM called with the 3C command)
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object

        _end:
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Main subroutine for NSP_Air_Wait
    scope air_wait_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object

        lw      t6, 0x0B18(v0)              // t6 = frame timer
        addiu   t6, t6, -1                  // decrement frame timer
        blez    t6, _air_end                // branch if frame timer > 0
        sw      t6, 0x0B18(v0)              // store updated frame timer

        _check_buttons:
        lhu     t7, 0x01BC(v0)              // t7 = buttons_held
        andi    t7, t7, Joypad.B            // t7 = 0x0020 if (B_HELD); else t7 = 0
        beqz    t7, _air_end                // branch if !(B_HELD)
        nop

        // begin by checking for turn inputs
        lb      t6, 0x01C2(v0)              // t6 = stick_x
        lw      t7, 0x0044(v0)              // t7 = DIRECTION
        multu   t6, t7                      // ~
        mflo    t6                          // t6 = stick_x * DIRECTION
        slti    at, t6, -39                 // at = 1 if stick_x < -39, else at = 0
        beqz    at, _end                    // branch if stick_x >= -39
        nop

        jal		air_turn_initial_
        nop
        b		_end
        nop

        _air_end:
        // if we reach this point, the b button is not being held or the timer has run out, so transition to ending action
        or      a1, r0, r0                  // Starting frame = 0.0
        jal     air_end_initial_            // transition to NSP_Air_End
        lui     a2, 0x3F80                  // Anim speed = 1.0x

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Common interrupt subroutine for NSP_Air
    scope air_common_interrupt_: {
        addiu   sp, sp, -0x18               // allocate stack space
        sw      ra, 0x14(sp)                // ~
        sw      a0, 0x18(sp)                // store ra, a0
        lw      v0, 0x84(a0)                // load fighter struct
        lhu     t0, 0x1BE(v0)               // load buttons tapped
        andi    at, t0, Joypad.B            // if B is tapped, at = 1, otherwise 0
        beqz    at, _check_aerials          // Check aerial interrupt
        lb      t0, 0x1C3(v0)               // load stick y range
        slti    at, t0, 40                  // if stick y < 40...
        bnezl   at, _check_dsp              // ...go to DSP check
        slti    at, t0, -39                 // ~
        jal     CBMKnucklesUSP.air_initial_ // do USP
        nop                                 // ~
        b       _end                        // go to function end
        lw      ra, 0x14(sp)                // load ra in delay slot

        _check_dsp:
        beqz    at, _check_aerials          // if stick_y > -40, go to aerials check
        nop                                 // ~
        jal     CBMKnucklesDSP.air_charge_initial_ // do DSP
        nop                                 // ~
        b       _end                        // go to function end
        lw      ra, 0x14(sp)                // load ra in delay slot

        _check_aerials:
        jal     0x80150B00                  // go to aerial interrupt check
        nop                                 // ~

        bnezl   v0, _end                    // if an aerial interrupt occurred, go to function end
        lw      ra, 0x14(sp)                // load ra only if we are going to function end

        jal     0x8014019C                  // check for jump interrupt
        lw      a0, 0x18(sp)                // load fighter_gobj

        lw      ra, 0x14(sp)                // load ra
        _end:
        jr      ra                          // return
        addiu   sp, sp, 0x18                // deallocate stack space
    }

    // @ Description
    // Subroutine which begins Knuckles's aerial neural special ending action.
    scope air_turn_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      t0, 0x0084(a0)              // Load fighter struct
        lli     at, TURNFRAMES              // Load TURNFRAMES
        sw      at, 0x0B1C(t0)              // Save turn frames
        lw      t1, 0x0044(t0)              // Load direction
        subu    t1, r0, t1                  // Invert direction

        // While this approach works just fine, I am slightly paranoid that the stick might be re-polled
        // after the call to air_turn_initial_, so I'd rather stick to the ol' reliable... (inverse of current direction)
        // lb      t2, 0x01C2(t0)              // Load stick range x
        // bltzl   t2, _store_direction        // If less than 0, load left...
        // addiu   t1, r0, -1                  // ~

        // addiu   t1, r0, 1                   // ...otherwise load right

        // _store_direction:
        sw      t1, 0x0B20(t0)              // Store target direction

        lwc1    f0, 0x0048(t0)              // Load current x velocity
        abs.s   f0, f0                      // Make x velocity absolute
        nop                                 // ~
        swc1    f0, 0x0B24(t0)              // Save absolute x velocity to catch up to after turning around

        _set_status:
        lli     a1, CBMKnuckles.Action.NSP_Turn // a1(action id) = NSP_Turn
        lw      a2, 0x0078(a0)              // a2(starting frame) = current frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    scope air_turn_main_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      t0, 0x0B18(v0)              // t0 = frame timer
        addiu   t0, t0, -1                  // decrement frame timer
        blez    t0, _air_end                // Go to air end if frame timer <= 0
        sw      t0, 0x0B18(v0)              // store updated frame timer

        lhu     t0, 0x1BC(v0)               // Load held buttons
        andi    at, t0, Joypad.B            // at = 1 if B is held, otherwise 0
        bnez    at, _check_turn             // if B is held, ignore this
        nop                                 // ~

        _air_end:
        or      a1, r0, r0                  // Starting frame = 0.0
        jal     air_end_initial_            // transition to NSP_Air_End
        lui     a2, 0x3F80                  // Anim speed = 1.0x

        b       _end
        nop

        _check_turn:
        lb      t3, 0x01C2(v0)              // Load stick x range

        bgezl   t3, _skip_abs               // x range is absolute, don't need to change
        or      t2, r0, t3                  // create copy of stick x in t2

        subu    t2, r0, t3                  // x range is negative, make it positive

        _skip_abs:
        slti    at, t2, 40                  // if range < 40...
        bnez    at, _normal_turn            // ...don't invert direction
        lw      t0, 0x0B1C(v0)              // Load turn frames

        bgezl   t3, _check_prev_direction   // Holding stick right, load right
        addiu   at, r0, 1                   // ~

        addiu   at, r0, -1                  // Load left

        _check_prev_direction:
        lw      t2, 0x0B20(v0)              // Load target direction

        beq     t2, at, _normal_turn        // Still facing the same direction, update turn frames as such...
        lli     t1, TURNFRAMES              // Load TURNFRAMES (maximum turn frames)

        subu    t0, t1, t0                  // Subtract current turn frames from max turn frames
        sw      t0, 0x0B1C(v0)              // Store updated turn frames

        lli     at, (TURNFRAMES / 2)        // Load TURNFRAMES / 2


        lw      t1, 0x0B20(v0)              // Load target direction
        subu    t1, r0, t1                  // Invert target direction
        sw      t1, 0x0B20(v0)              // Store updated target direction

        bne     t0, at, _normal_turn        // if turn frames left == TURNFRAMES / 2...
        nop                                 // ~

        sw      t1, 0x0044(v0)              // ...store target direction as current direction

        _normal_turn:
        addiu   t0, t0, -1                  // Decrement turn frames
        blez    t0, _end_turn               // If no turn frames remaining, go to anim end setup

        sw      t0, 0x0B1C(v0)              // Store updated turn frames

        _update_model:
        lw      a0, 0x08E8(v0)              // Load TopN joint
        lwc1    f0, 0x0034(a0)              // Load rotation Y-Axis
        li      at, 0x40490FDB              // Load rad180
        mtc1    at, f2                      // Move rad180 into f2
        nop                                 // ~
        lli     at, TURNFRAMES              // Load TURNFRAMES
        mtc1    at, f4                      // Move TURNFRAMES to f4
        nop                                 // ~
        cvt.s.w f4, f4                      // Convert TURNFRAMES to float
        nop                                 // ~
        mtc1    r0, f6                      // ~
        nop                                 // ~
        c.eq.s  f4, f6                      // If TURNFRAMES is somehow 0, don't divide...
        nop                                 // ~
        bc1t    _rotate_y                   // If zero, skip division
        nop                                 // ~

        div.s   f2, f2, f4                  // Divide rad180 by TURNFRAMES
        nop                                 // ~

        _rotate_y:
        lwc1    f4, 0x0B20(v0)              // Load target direction
        cvt.s.w f4, f4                      // Convert target direction to float
        nop                                 // ~
        mul.s   f2, f2, f4                  // Multiply turn step by direction
        nop                                 // ~
        add.s   f0, f0, f2                  // Add step to rotation Y-Axis
        swc1    f0, 0x0034(a0)              // Store rotation Y-Axis

        jal     0x800EB528                  // Unknown function
        nop                                 // ~

        lw      a0, 0x20(sp)                // Load fighter_gobj
        lw      v0, 0x84(a0)                // Load fighter struct
        lw      t0, 0x0B1C(v0)              // Load turn frames

        lli     at, (TURNFRAMES / 2)        // Check if Knuckles is halfway through the turn animation
        bne     t0, at, _end                // If Knuckles is not halfway through, skip this
        nop                                 // ~

        lw      t0, 0x0044(v0)              // Load direction
        subu    t0, r0, t0                  // Invert direction
        b       _end                        // Go to end of function
        sw      t0, 0x0044(v0)              // Store updated direction

        // We're at the end of the animation!
        _end_turn:
        lli     a1, CBMKnuckles.Action.NSP_Air_Wait // a1(action id) = NSP_Air_Wait
        lw      a2, 0x0078(a0)              // a2(starting frame) = current frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0800                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0800 (this flag continues FGM called with the 3C command)
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object

        _end:
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Subroutine which begins Knuckles's aerial neural special ending action.
    scope air_end_initial_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store a0, ra
        or      a3, a2, r0                  // Pass anim speed in a3 (should be passed to this function in a2)
        or      a2, a1, r0                  // Pass starting frame in a2 (should be passed to this function in a1)
        lli     a1, CBMKnuckles.Action.NSP_Air_End // a1(action id) = NSP_Air_End
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = fighter_gobj
        jal		end_main_
        lw      a0, 0x0018(sp)              // a0 = fighter_gobj
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Main subroutine for neutral special air ending
    scope end_main_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // 0x0014(sp) = ra

        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f0                      // ~
        lwc1    f2, 0x0078(a0)              // ~
        c.le.s  f2, f0                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop

        jal     0x800DEE54                  // transition to idle
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    scope turn_physics_: {
        addiu   sp, sp, -0x18               // Allocate stack frame
        sw      ra, 0x14(sp)                // Store ra
        sw      a0, 0x18(sp)                // Store a0

        lw      v0, 0x0074(a0)              // Load TopN joint
        li      at, 0x3FC90FDB              // Load rad90
        mtc1    at, f0                      // Move rad90 into f0
        nop                                 // ~

        lwc1    f2, 0x0034(v0)              // Load rotation Y-Axis

        jal     0x80035CD0                  // cosf
        sub.s   f12, f2, f0                 // Subtract rad90 from rotation Y-Axis

        lw      a0, 0x18(sp)                // Load fighter_gobj
        lw      v0, 0x84(a0)                // Load fighter struct
        lwc1    f6, 0x0044(v0)              // Load current direction
        cvt.s.w f6, f6                      // Convert current direction to float
        nop                                 // ~
        lwc1    f4, 0x0B24(v0)              // Load maximum x velocity

        mul.s   f2, f4, f0                  // Multiply maximum x velocity by cosf(target angle)
        nop                                 // ~

        _save_vel_x:
        swc1    f2, 0x0048(v0)              // store updated x velocity

        abs.s   f2, f2                      // Absolute x velocity
        nop                                 // ~

        c.le.s  f2, f4                      // If x velocity is less than or equal to maximum speed, ignore this
        nop                                 // ~

        bc1tl   _store_vel_y                // Likely (hopefully) less than or equal to max speed, so branch
        nop                                 // ~

        mul.s   f0, f4, f6                  // Multiply absolute max speed by current direction
        nop                                 // Safe delay slot
        swc1    f0, 0x0048(v0)              // Store updated x velocity

        _store_vel_y:
        li      at, DESCENT                 // Load DESCENT
        mtc1    at, f4                      // Move DESCENT into f0
        nop                                 // ~

        lwc1    f2, 0x004C(v0)              // Load y velocity
        c.lt.s  f2, f4                      // Check if y velocity is < DESCENT
        nop                                 // ~
        bc1fl   _gravity                    // If greater than, subtract gravity
        nop

        li      at, ACCELY                  // Load ACCELY
        mtc1    at, f0                      // Move ACCELY to f0
        nop                                 // ~
        add.s   f2, f2, f0                  // ...

        c.le.s  f2, f4                      // Check if new velocity is greater than DESCENT...
        nop                                 // ~

        bc1tl    _end                       // If <= DESCENT, store new velocity
        swc1    f2, 0x004C(v0)              // ~

        b       _end                        // Branch to end
        swc1    f4, 0x004C(v0)              // Store descent in delay slot

        _gravity:
        li      at, GRAVITY                 // Load GRAVITY
        mtc1    at, f0                      // Move GRAVITY into f0
        nop                                 // ~
        sub.s   f2, f2, f0                  // Subtract GRAVITY from y velocity

        c.le.s  f2, f0                      // Check if new velocity is greater than DESCENT...
        nop                                 // ~

        bc1fl    _end                       // If > DESCENT, store new velocity
        swc1    f2, 0x004C(v0)              // ~

        swc1    f4, 0x004C(v0)              // ...otherwise store DESCENT

        _end:
        lw      ra, 0x14(sp)                // Load ra
        jr      ra                          // return
        addiu   sp, sp, 0x18                // Deallocate stack frame
    }

    scope air_physics_: {
        lw      v0, 0x0084(a0)              // Load fighter struct

        li      at, ACCELX                  // Load ACCELX
        mtc1    at, f0                      // f0 = ACCELX
        nop                                 // ~

        lwc1    f2, 0x0048(v0)              // Load x velocity
        lw      t0, 0x0044(v0)              // Load direction

        addiu   at, r0, 1                   // Load right
        beql    at, t0, _store_vel_x        // If direction is right...
        add.s   f0, f2, f0                  // Then add to existing velocity...

        sub.s   f0, f2, f0                  // ...otherwise subtract from it

        _store_vel_x:
        li      at, CLAMPX                  // Load CLAMPX
        mtc1    at, f2                      // Move CLAMPX to f2
        nop                                 // ~
        abs.s   f6, f0                      // Absolute x velocity in f6
        nop                                 // ~

        c.le.s  f6, f2                      // If x velocity is less than or equal to CLAMPX, store new x velocity
        nop                                 // ~

        bc1tl   _store_vel_y                // ~
        swc1    f0, 0x0048(v0)              // store updated x velocity

        mtc1    t0, f0                      // Move direction to f0
        nop                                 // ~
        cvt.s.w f0, f0                      // Convert direction to float
        nop                                 // ~
        mul.s   f0, f2, f0                  // Multiply CLAMPX by direction
        nop                                 // ~
        swc1    f0, 0x0048(v0)              // Store updated x velocity

        _store_vel_y:
        li      at, DESCENT                 // Load DESCENT
        mtc1    at, f4                      // Move DESCENT into f0
        nop                                 // ~

        lwc1    f2, 0x004C(v0)              // Load y velocity
        c.lt.s  f2, f4                      // Check if y velocity is < DESCENT
        nop                                 // ~
        bc1fl   _gravity                    // If greater than, subtract gravity
        nop

        li      at, ACCELY                  // Load ACCELY
        mtc1    at, f0                      // Move ACCELY to f0
        nop                                 // ~
        add.s   f2, f2, f0                  // ...

        c.le.s  f2, f4                      // Check if new velocity is greater than DESCENT...
        nop                                 // ~

        bc1tl    _end                       // If <= DESCENT, store new velocity
        swc1    f2, 0x004C(v0)              // ~

        b       _end                        // Branch to end
        swc1    f4, 0x004C(v0)              // Store descent in delay slot

        _gravity:
        li      at, GRAVITY                 // Load GRAVITY
        mtc1    at, f0                      // Move GRAVITY into f0
        nop                                 // ~
        sub.s   f2, f2, f0                  // Subtract GRAVITY from y velocity

        c.le.s  f2, f0                      // Check if new velocity is greater than DESCENT...
        nop                                 // ~

        bc1fl    _end                       // If > DESCENT, store new velocity
        swc1    f2, 0x004C(v0)              // ~

        swc1    f4, 0x004C(v0)              // ...otherwise store DESCENT

        _end:
        jr      ra                          // return
        nop
    }

    scope air_common_collision_: {
        addiu   sp, sp, -0x18               // Allocate stack frame
        sw      ra, 0x14(sp)                // Save return address
        jal     0x800DE934                  // Collision WITHOUT ledge grab (we want to go straight to ClimbQuick/Slow)
        sw      a0, 0x18(sp)                // Store a0

        lw      a0, 0x18(sp)                // Load fighter_gobj
        lw      v0, 0x84(a0)                // Load fighter struct
        lw      t1, 0x44(v0)                // Load direction
        lhu     t0, 0xCE(v0)                // Load some collision flag
        andi    at, t0, 0x800               // Check if colliding with GROUND
        bnezl   at, _end                    // Knuckles has collided with a GROUND, go to function end
        lw      ra, 0x14(sp)                // Load return address
        andi    at, t0, 0x1                 // Check if colliding with an LWALL
        beqzl   at, _rwall                  // If no LWALL collision, check RWALL instead
        andi    at, t0, 0x20                // Check if colliding with an RWALL

        addiu   at, r0, 1                   // Load 1
        beql    at, t1, _climb_test         // Knuckles is colliding with a left wall facing right, test collision
        sw      at, 0xB20(v0)               // Store LWALL
        andi    at, t0, 0x20                // Check if colliding with an RWALL

        _rwall:
        beqzl   at, _end                    // If not colliding with an RWALL either, go to function end
        lw      ra, 0x14(sp)                // Load return address
        addiu   at, r0, -1                  // Load 1
        bnel    at, t1, _end                // Knuckles is facing the wrong way, go to function end
        lw      ra, 0x14(sp)                // ~

        sw      r0, 0xB20(v0)               // Store RWALL

        _climb_test:
        jal     CBMKnucklesClimb.climb_initial_collision_ // Initial collision test
        nop                                 // ~

        beqzl   v0, _end                    // Knuckles cannot enter climb_wait_initial_, go to function end
        lw      ra, 0x14(sp)                // Load return address

        lw      a0, 0x18(sp)                // Load fighter_gobj
        lw      t0, 0x84(a0)                // Load fighter struct

        addiu   at, r0, CBMKnucklesClimb.CLIMB_DURATION // Load CLIMB_DURATION
        sw      at, 0xB18(t0)               // Store CLIMB_DURATION
        jal     CBMKnucklesClimb.climb_wait_initial_ // Go to climb wait
        or      a1, r0, r0                  // Current frame = 0

        jal     0x800269C0                  // Play SFX
        lli     a0, CBMKnuckles.FGM.CLIMB_CLING

        lw      ra, 0x14(sp)                // Load return address
        _end:
        jr      ra                          // Return from subroutine
        addiu   sp, sp, 0x18                // Restore stack frame
    }
}

scope CBMKnucklesClimb {
    constant JUMP_MUL(0x42480000)           // 50.0
    constant JUMP_ANGLE(0x3F490FDB)         // Angle offset of climb jump (45 degrees)
    constant CLIMB_JOSTLE_WIDTH(0x43A8C000) // Jostling detection width (337.5)
    constant CLIMB_JOSTLE_HEIGHT(0x43E10000)// Jostling detection height (450.0)
    constant CLIMB_JOSTLE_Y(0x00000000)     // Jostle Y push?
    constant CLIMB_JOSTLE_Z(0x00000000)     // Jostle Z push?
    constant CLIMB_SPEED(0x41F00000)        // 30.0 - Maximum climb speed
    constant CLIMB_LWALL_MAX(0x400BA05A)    // rad125
    constant CLIMB_LWALL_MIN(0x3F75BE0B)    // rad55
    constant CLIMB_RWALL_MAX(0xC00BA05A)    // -rad125
    constant CLIMB_RWALL_MIN(0xBF75BE0B)    // -rad55
    constant CLIMB_DIST_MAX(0x43FA0000)     // Maximum distance from ledge within which Knuckles is allowed to climb up (500.0)
    constant CLIMB_DURATION(180)            // Duration of climb
    constant CLIMB_ANIM_SPEED(0x3CB851EC)   // x2.25 speed
    constant DUSTINTERVAL(6)                // Wait 6 frames between dust effects
    constant SLIDEINTERVAL(8)               // Wait 8 frames between slide SFX

    scope climb_wait_initial_: {
        addiu   sp, sp, -0x18               // Allocate stack frame
        sw      ra, 0x14(sp)                // Save return address
        sw      a0, 0x18(sp)                // Store a0
        or      a2, a1, r0                  // a2 = animation frame
        lli     a1, CBMKnuckles.Action.NSP_Climb_Wait // a1(action id) = NSP_Air_Begin
        or      a3, r0, r0                  // a3(frame speed multiplier) = 0.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // Store flags: none
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      t0, 0x0018(sp)              // Load fighter_gobj
        lw      v0, 0x0084(t0)              // Load fighter struct
        // lli     at, 1                       // Load 1
        // sb      at, 0x148(v0)               // Jumps used = 1
        sw      r0, 0x48(v0)                // Kill X-velocity
        sw      r0, 0x4C(v0)                // Kill Y-velocity

        sh      r0, 0xB24(v0)               // Store dust effect interval
        sh      r0, 0xB26(v0)               // Store slide SFX interval

        // jal     KnucklesClimb.climb_common_collision_ // Run initial collision check
        // nop                                 // ~

        lw      ra, 0x14(sp)                // Load return address
        _end:
        jr      ra                          // Return from subroutine
        addiu   sp, sp, 0x18                // Restore stack frame
    }

    scope climb_common_main_: {
        addiu   sp, sp, -0x48               // Allocate stack frame
        sw      ra, 0x44(sp)                // Save return address
        sw      s1, 0x40(sp)                // Store s0
        sw      s0, 0x3C(sp)                // Store s1
        or      s0, a0, r0                  // Move fighter_gobj into s0
        lw      s1, 0x84(a0)                // Load fighter struct
        lw      t0, 0xB18(s1)               // Load duration
        addiu   t0, t0, -1                  // Decrement duration
        blez    t0, _climb_end              // If duration <= 0, set action to GlideEnd
        sw      t0, 0xB18(s1)               // Store updated duration

        lw      t0, 0x24(s1)                // Load action ID

        lli     at, CBMKnuckles.Action.NSP_Climb_MoveUp // Run only if Knuckles is moving
        beq     at, t0, _check_stick        // Knuckles is moving up, check stick range

        lli     at, CBMKnuckles.Action.NSP_Climb_MoveDown // ~
        beql    at, t0, _dustint            // Go to function end if Knuckles is moving down
        lh      t0, 0xB24(s1)               // Load dust effect interval

        b       _end                        // Knuckles is in ClimbWait, go to function end
        lw      ra, 0x44(sp)                // Load return address

        _check_stick:
        lb      t0, 0x1C3(s1)               // Load stick Y range
        bltzl   t0, _move_t0                // If < 0, negate
        subu    t0, r0, t0                  // ~

        _move_t0:
        mtc1    t0, f0                      // Move absolute stick range into f0
        nop                                 // ~
        cvt.s.w f0, f0                      // Convert absolute stick range to float

        li      at, 0x3FA00000              // Load 1.25
        mtc1    at, f2                      // Move 1.25 into f2
        nop                                 // ~

        mul.s   f0, f0, f2                  // Multiply absolute stick range by 1.25
        nop                                 // ~

        // Don't forget to clamp this between 0 and 100!!!

        li      at, CLIMB_ANIM_SPEED        // Load CLIMB_ANIM_SPEED
        mtc1    at, f2                      // Move CLIMB_ANIM_SPEED into f2
        nop                                 // ~

        mul.s   f0, f0, f2                  // Animation speed = percentage converted to decimal (idk if I explained that right)
        lw      t0, 0x74(a0)                // Load root DObj
        lwc1    f2, 0x78(t0)                // Load current animation speed
        c.eq.s  f0, f2                      // Check if current animation speed == calculated animation speed
        nop                                 // ~
        bc1tl   _end                        // If equal, go to function end
        lw      ra, 0x44(sp)                // Load return address

        jal     0x8000BB04                  // Set new animation speed
        mfc1    a1, f0                      // Move new animation speed into a1

        b       _end                        // Go to function end
        lw      ra, 0x44(sp)                // Load return address

        _dustint:
        addiu   t0, t0, -1                  // Decrement dust effect interval
        bgtz    t0, _slide_sfx              // If > 0, check if slide SFX should be played
        sh      t0, 0xB24(s1)               // Store update dust effect interval

        addiu   at, r0, DUSTINTERVAL        // Load DUSTINTERVAL
        sh      at, 0xB24(s1)               // Reset dust effect interval

        sw      r0, 0x20(sp)                // Store offset X
        sw      r0, 0x24(sp)                // Store offset Y
        sw      r0, 0x28(sp)                // Store offset Z

        lui     at, 0x4280                  // Load 64.0
        sw      at, 0x2C(sp)                // Store scatter range X
        sw      at, 0x30(sp)                // Store scatter range Y
        sw      at, 0x34(sp)                // Store scatter range Z

        lli     a1, 18                      // 18 = small expanding dust cloud
        lli     a2, 10                      // Left hand joint ID = 6, I believe GEE excludes the 4 special joints so add 4
        addiu   a3, sp, 0x20                // Get address of offset from joint
        addiu   t1, sp, 0x2C                // Get address of scatter range
        sw      t1, 0x10(sp)                // sp10 = address of scatter range
        lw      t0, 0x44(s1)                // Load direction
        sw      t0, 0x14(sp)                // Store direction
        sw      r0, 0x18(sp)                // Scale position (?) = FALSE
        jal     0x800EABDC                  // Make fighter effect
        sw      r0, 0x1C(sp)                // ???

        or      a0, s0, r0                  // Move fighter_gobj into a0
        lli     a1, 18                      // 18 = small expanding dust cloud
        lli     a2, 22                      // Left foot joint ID = 18, I believe GEE excludes the 4 special joints so add 4
        addiu   a3, sp, 0x20                // Get address of offset from joint
        addiu   t1, sp, 0x2C                // Get address of scatter range
        sw      t1, 0x10(sp)                // sp10 = address of scatter range
        lw      t0, 0x44(s1)                // Load direction
        sw      t0, 0x14(sp)                // Store direction
        sw      r0, 0x18(sp)                // Scale position (?) = FALSE
        jal     0x800EABDC                  // ftParamMakeEffect
        sw      r0, 0x1C(sp)                // ???

        _slide_sfx:
        lh      t0, 0xB26(s1)               // Load slide SFX interval
        addiu   t0, t0, -1                  // Decrement slide SFX wait
        bgtz    t0, _load_ra                // Nothing left to do, go to function end
        sh      t0, 0xB26(s1)               // Store updated slide SFX interval

        jal     0x800269C0                  // Play SFX
        addiu   a0, r0, 0x1C                // BurnS SFX

        addiu   at, r0, SLIDEINTERVAL       // Load SLIDEINTERVAL
        sh      at, 0xB26(s1)               // Store SLIDEINTERVAL

        b       _end                        // Go to function end
        lw      ra, 0x44(sp)                // Load return address

        _climb_end:
        addiu   at, r0, 2                   // Load 2
        sb      at, 0x148(s1)               // Store 2 (all jumps used)
        lui     a1, 0x4080                  // Starting frame = 4.0
        jal     CBMKnucklesNSP.air_end_initial_ // transition to NSP_Air_End
        lui     a2, 0x3F00                  // Anim speed = 0.5x

        _load_ra:
        lw      ra, 0x44(sp)                // Load return address
        _end:
        lw      s1, 0x40(sp)                // Load s1
        lw      s0, 0x3C(sp)                // Load s0
        jr      ra                          // Return from subroutine
        addiu   sp, sp, 0x48                // Restore stack frame
    }

    scope climb_jump_setup_: {
        addiu   sp, sp, -0x30               // Allocate stack frame
        sdc1    f22, 0x28(sp)               // Store f22
        sdc1    f20, 0x20(sp)               // Store f20
        sw      ra, 0x1C(sp)                // Save return address
        sw      s0, 0x18(sp)                // Store s1
        lw      s0, 0x84(a0)                // Load fighter struct

        lwc1    f12, 0xB28(s0)              // Load wall angle X
        lwc1    f14, 0xB2C(s0)              // Load wall angle Y
        jal     0x8001863C                  // atan2f
        neg.s   f12, f12                    // Negate wall angle X

        lw      t0, 0xB20(s0)               // Load line type
        bnezl   t0, _calc_angle             // If not RWALL, ignore this
        nop                                 // ~

        neg.s   f0, f0                      // -atan2f(-x, y)

        _calc_angle:
        li      at, JUMP_ANGLE              // Load JUMP_ANGLE
        mtc1    at, f2                      // Move JUMP_ANGLE to f0
        nop                                 // ~

        add.s   f20, f0, f2                 // Subtract JUMP_ANGLE offset from wall angle
        jal     0x80035CD0                  // cosf
        mov.s   f12, f20                    // Move angle into f12

        lw      t0, 0x9C8(s0)               // Load attributes
        lwc1    f2, 0x3C(t0)                // Load jump force
        li      at, JUMP_MUL                // Load JUMP_MUL
        mtc1    at, f4                      // Move JUMP_MUL to f4
        nop                                 // ~
        mul.s   f2, f2, f4                  // Multiply jump force by JUMP_MUL
        nop                                 // ~
        lwc1    f4, 0x40(t0)                // Load base jump height
        add.s   f2, f2, f4                  // Add base jump height to jump force * JUMP_MUL
        nop                                 // ~
        lwc1    f4, 0x48(t0)                // Load aerial jump height
        nop                                 // ~
        mul.s   f22, f2, f4                 // Multiply JUMP_MUL * jump force + base jump height by aerial jump height
        nop                                 // ~
        mul.s   f0, f0, f22                 // Multiply cosf(wall angle) by aerial jump height

        lwc1    f2, 0x44(s0)                // Load direction
        cvt.s.w f2, f2                      // Convert direction to float
        nop                                 // ~
        // neg.s   f2, f2                   // Knuckles jumps in the opposite direction he is facing, so negate it
        mul.s   f0, f0, f2                  // Multiply X velocity by inverted direction

        swc1    f0, 0x48(s0)                // Store X velocity

        jal     0x800303F0                  // sinf
        mov.s   f12, f20                    // Move JUMP_ANGLE + wall angle to f12

        mul.s   f0, f0, f22                 // Multiply sinf(wall angle) by aerial jump height
        swc1    f0, 0x4C(s0)                // Store Y velocity

        sw      r0, 0xB18(s0)               // JumpAerial status vars
        sw      r0, 0xB1C(s0)               // JumpAerial status vars
        sw      r0, 0xB20(s0)               // JumpAerial status vars

        lbu     t0, 0x148(s0)               // Load jumps used
        addiu   t0, t0, 1                   // Increment jumps used
        sb      t0, 0x148(s0)               // Store updated jumps used

        ldc1    f22, 0x28(sp)               // Load f22
        ldc1    f20, 0x20(sp)               // Load f20
        lw      ra, 0x1C(sp)                // Load return address
        lw      s0, 0x18(sp)                // Load s0
        jr      ra                          // Return
        addiu   sp, sp, 0x30                // Restore stack frame
    }

    scope climb_wait_interrupt_: {
        addiu   sp, sp, -0x20               // Allocate stack frame
        sw      ra, 0x1C(sp)                // Save return address
        sw      s1, 0x18(sp)                // Store s1
        sw      s0, 0x14(sp)                // Store s0
        or      s0, a0, r0                  // Move a0 into s0
        lw      s1, 0x84(a0)                // Load fighter struct

        lb      t0, 0x1C3(s1)               // Load stick Y range
        slti    at, t0, 8                   // If Y range < 20...
        bnezl   at, _check_movedown         // ...then check if <= -20
        slti    at, t0, -7                  // Else if Y range > -20...

        b       _climb_move                 // Go to set absolute stick range label
        lli     a1, CBMKnuckles.Action.NSP_Climb_MoveUp // ~

        _check_movedown:
        beqzl   at, _check_jump             // ...then check for jump inputs
        lhu     t0, 0x1BE(s1)               // Load tapped buttons

        lli     a1, CBMKnuckles.Action.NSP_Climb_MoveDown

        _climb_move:
        jal     CBMKnucklesClimb.climb_move_initial_
        or      a2, t0, r0                  // Move stick range Y into a2

        b       _end                        // Go to function end
        lw      ra, 0x1C(sp)                // Load return address

        _check_jump:
        andi    at, t0, (Joypad.CR | Joypad.CL | Joypad.CD | Joypad.CU) // Check if jump buttons were pressed
        beqzl   at, _end                    // No buttons pressed, go to function end (for now)
        lw      ra, 0x1C(sp)                // Load return address

        // lbu     t0, 0x148(s1)               // Load jumps used
        // slti    at, t0, 2                   // If >= 2 jumps used, go to end
        // beqzl   at, _fall                   // All jumps used, fall instead
        // nop                                 // ~

        lli     a1, Action.JumpAerialF      // a1(action id) = NSP_Air_Begin
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // Store flags: none

        jal     CBMKnucklesClimb.climb_jump_setup_
        or      a0, s0, r0                  // Pass fighter gobj

        // b       _end                        // Go to function end
        // lw      ra, 0x1C(sp)                // Load return address

        _fall:
        // or      a0, s0, r0                  // Pass fighter_gobj
        // lui     a1, 0x4080                  // Starting anim frame = 4.0
        // jal     KnucklesNSP.air_end_initial_ // ~
        // lui     a2, 0x3F00                  // Anim speed = 0.5x

        lw      ra, 0x1C(sp)                // Load return address
        _end:
        lw      s1, 0x18(sp)                // Load s1
        lw      s0, 0x14(sp)                // Load s0
        jr      ra                          // Return from subroutine
        addiu   sp, sp, 0x20                // Restore stack frame
    }

    scope climb_cliff_initial_: {
        addiu   sp, sp, -0x30               // Allocate stack frame
        sw      ra, 0x1C(sp)                // Store return address
        sw      s0, 0x18(sp)                // Store s0
        lw      s0, 0x84(a0)                // Load fighter struct
        lw      t0, 0x2C(s0)                // Load damage
        slti    at, t0, 100                 // at = 1 if damage < 100, 0 if >= 100
        beqzl   at, _check_coll_diamond     // Check for >= 100 damage collision diamond position
        addiu   t0, r0, 3                   // Climb type = 3 (normal slow climb)

        // Damage < 100, check if collision diamond center is above ledge
        beqzl   a1, _climbtype_quick        // Collision diamond is at or above ledge, go to Quick1
        addiu   a1, r0, Action.CliffClimbQuick1  // ~

        addiu   a1, r0, Action.CliffQuick   // Else if <= ledge Y position, just normal CliffQuick

        _climbtype_quick:
        b       _set_action                 // Set action
        or      t0, r0, r0                  // Climb type = 0 (normal quick climb)

        _check_coll_diamond:
        beqzl   a1, _set_action             // Collision diamond is at or above ledge, go to Slow1
        addiu   a1, r0, Action.CliffClimbSlow1   // ~

        addiu   a1, r0, Action.CliffSlow    // ~

        _set_action:
        sw      t0, 0x14(sp)                // Store climb type
        or      a2, r0, r0                  // Starting anim frame = 0.0
        lui     a3, 0x3F80                  // Anim speed = 1.0
        jal     0x800E6F24                  // ftMainSetStatus
        sw      r0, 0x10(sp)                // Flags = none

        jal     0x800E0830                  // ftMainPlayAnimNoEffect
        lw      a0, 0x4(s0)                 // Load fighter_gobj

        jal     0x800DEEC8                  // mpCommonSetFighterAir
        or      a0, s0, r0                  // Pass fighter struct

        jal     0x800D9444                  // ftPhysicsStopVelAll
        lw      a0, 0x4(s0)                 // Load fighter_gobj

        addiu   at, r0, -1                  // Load -1
        sw      at, 0xEC(s0)                // Store ground line ID

        jal     0x80144B54                  // ftCommonCliffCommonProcPhysics
        lw      a0, 0x4(s0)                 // Load fighter_gobj

        lw      t1, 0x14(sp)                // Load climb type
        lw      t0, 0x140(s0)               // Load cliff line ID
        sw      t1, 0xB18(s0)               // Store climb type
        sw      t0, 0xB1C(s0)               // Store cliff line ID

        lbu     t0, 0x190(s0)               // Load flags
        ori     t0, t0, 0x1                 // byte 0x190 bit 7 = hanging on ledge bool
        sb      t0, 0x190(s0)               // Store updated flags

        lw      t0, 0x44(s0)                // Load direction
        lui     v0, 0x800F                  // mpCollisionGetLREdgeUpperL/R upper half
        addiu   at, r0, 1                   // Load RIGHT
        beql    at, t0, _goto_func          // Get left ledge position if facing right
        addiu   v0, v0, 0x4428              // UpperL

        addiu   v0, v0, 0x4408              // UpperR

        _goto_func:
        lw      a0, 0x140(s0)               // Load cliff line ID
        jalr    v0                          // Go to function
        addiu   a1, sp, 0x20                // Get address of position

        jal     0x80101688                  // efManagerFlashSmallMakeEffect
        addiu   a0, sp, 0x20                // Get address of position

        jal     0x800269C0                  // Play SFX
        addiu   a0, r0, 0x13                // Normal grab SFX

        li      at, 0x80144CF8              // ftCommonCliffCommonProcDamage
        sw      at, 0x9EC(s0)               // Store as ProcDamage

        or      a0, s0, r0                  // Pass fighter struct
        jal     0x800E8098                  // ftParamSetCaptureImmuneMask
        addiu   a1, r0, 0x4                 // 0x4 = immune to Barrel Cannon

        jal     0x800DE368                  // mpCommonSetFighterLandingParams
        lw      a0, 0x4(s0)                 // Load fighter_gobj

        lw      ra, 0x1C(sp)                // Load return address
        lw      s0, 0x18(sp)                // Load s0
        jr      ra                          // Return
        addiu   sp, sp, 0x30                // Restore stack frame
    }

    // This is essentially checking if Knuckles is allowed to go to ClimbWait after a collision test; 0 = FALSE, 1 = TRUE
    scope climb_initial_collision_: {
        addiu   sp, sp, -0x50               // Allocate stack frame
        sdc1    f20, 0x48(sp)               // Store f20
        sw      ra, 0x44(sp)                // Save return address
        sw      s0, 0x40(sp)                // Store s1
        // jal     0x800DE934                  // mpCommonProcFighterWaitOrLanding
        lw      s0, 0x84(a0)                // Load fighter struct

        // Vanilla line types:
        // 0 = ground, 1 = ceiling, 2 = right wall, 3 = left wall
        // We do not need to check for ground and ceiling, and we cannot check for immediate values,
        // So we are optimizing these checks by making 0 = right wall and 1 = left wall
        lw      t0, 0xB20(s0)               // Load line type
        beqz    t0, _rwall_block            // Go to RWALL block
        addiu   at, r0, 1                   // Load LWALL
        bnel    at, t0, _climb_end          // Knuckles is somehow not on a wall, drop him off
        nop                                 // Load return address

        // ~~~ LWALL block ~~~
        // First, check if the wall still exists...
        lw      a0, 0x118(s0)               // Load current Line ID
        bltzl   a0, _climb_end              // Line doesn't exist, don't bother
        nop                                 // ~
        jal     0x800FC67C                  // mpCollisionCheckExistLineID
        nop                                 // ~
        beqzl   v0, _climb_end              // Line ID is turned off, don't bother
        nop                                 // ~

        // Check if we're touching a left wall...
        lw      a0, 0x118(s0)               // Load current Line ID
        lw      v0, 0x78(s0)                // Load TopN translate vector
        lw      t0, 0x0(v0)                 // Load TopN translate X
        lw      t1, 0x4(v0)                 // Load TopN translate Y
        sw      t0, 0x20(sp)                // Store TopN translate X
        sw      t1, 0x24(sp)                // Store TopN translate Y
        lw      t0, 0x8(v0)                 // Load TopN translate Z
        sw      t0, 0x28(sp)                // Store TopN translate Z
        lwc1    f2, 0xBC(s0)                // Load collision diamond width
        lwc1    f0, 0x20(sp)                // Load TopN translate X
        add.s   f0, f0, f2                  // Add collision diamond width to TopN translate X
        swc1    f0, 0x20(sp)                // Store TopN translate X + collision diamond width
        lwc1    f2, 0xB4(s0)                // Load collision diamond center
        lwc1    f0, 0x24(sp)                // Load TopN translate Y
        add.s   f20, f0, f2                 // Add collision diamond center to TopN translate Y
        swc1    f20, 0x24(sp)               // Store TopN Translate Y + collision diamond center
        addiu   a1, sp, 0x20                // Get address of collision detection position
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL collision flags pointer
        addiu   t0, s0, 0xB28               // Get address of wall angle status var
        jal     0x800F4194                  // mpCollisionGetLRCommonLeft
        sw      t0, 0x10(sp)                // ~

        sw      v0, 0x30(sp)                // Store collision check bool

        // Get the line ID above connecting to this LWALL
        jal     0x800FAC64                  // mpCollisionGetEdgeRightULineID
        lw      a0, 0x118(s0)               // Load new LWALL line ID

        bltzl   v0, _params_l               // No line ID connected!?
        nop                                 // Go to params stuff

        sw      v0, 0x2C(sp)                // Store found line ID
        jal     0x800FC67C                  // mpCollisionCheckExistLineID
        or      a0, v0, r0                  // Pass found line ID

        beqzl   v0, _params_l               // Line isn't turned on, just stay on the wall...
        nop                                 // ~

        jal     0x800FA8A4                  // Get line type of line ID
        lw      a0, 0x2C(sp)                // Pass found line ID

        bnezl   v0, _params_l               // Not a ground line ID?
        nop                                 // Also update params

        // Check if the line ID has the spike material type
        jal     0x800FCAC8                  // mpCollisionGetVertexFlagsLineID
        lw      a0, 0x2C(sp)                // Load found line ID
        andi    t0, v0, 0x00FF              // Mask surface material bits
        addiu   at, r0, 10                  // Load spike material ID
        beql    at, t0, _climb_end          // If hazard, end climb
        nop                                 // ~

        // Now let's get the left edge of the ground line ID we found
        lw      a0, 0x2C(sp)                // Load found line ID
        jal     0x800F4428                  // mpCollisionGetLREdgeUpperL
        addiu   a1, sp, 0x20                // Get address of position vector

        // We have the position of the ledge, let's see if Knuckles' ledge grab box is in range...
        lwc1    f2, 0xC4(s0)                // Load ledge grab box X position
        lw      a1, 0x78(s0)                // Load TopN translate vector
        lwc1    f0, 0x0(a1)                 // Load translate X
        add.s   f0, f0, f2                  // Add ledge grab box X to translate X
        nop                                 // ~
        lwc1    f2, 0x20(sp)                // Load edge X position
        c.lt.s  f0, f2                      // If (translate X + ledge grab X) < edge X
        nop                                 // ~
        bc1tl   _params_l                   // Continue to parameters stuff
        nop                                 // ~

        // lwc1    f4, 0xB4(s0)             // Load collision diamond center
        lwc1    f2, 0xC8(s0)                // Load ledge grab box Y position
        lwc1    f0, 0x4(a1)                 // Load translate Y
        // add.s   f20, f0, f4              // Add collision diamond center to translate Y
        // nop                              // ~
        add.s   f0, f0, f2                  // Add ledge grab box Y to translate Y
        nop                                 // ~
        lwc1    f2, 0x24(sp)                // Load edge Y position
        c.lt.s  f0, f2                      // If (translate Y + ledge grab Y) < edge Y...
        nop                                 // ~
        bc1tl   _check_ceil_l               // ...then go to ceiling check
        nop                                 // ~
        jal     0x80019AB0                  // syVectorDist3D
        addiu   a0, sp, 0x20                // Get address of edge position

        li      at, CLIMB_DIST_MAX          // Load CLIMB_DIST_MAX
        mtc1    at, f2                      // Move CLIMB_DIST_MAX into f2
        nop                                 // ~
        c.le.s  f0, f2                      // If distance to ledge > CLIMB_DIST_MAX...
        nop                                 // ~
        bc1fl   _check_ceil_l               // ...then allow Knuckles to climb up
        nop                                 // ~

        lw      a0, 0x2C(sp)                // Load found line ID
        jal     0x800F4428                  // mpCollisionGetLREdgeUpperL
        addiu   a1, sp, 0x34                // Get address of position vector

        // Any left walls in chat?
        lwc1    f2, 0xBC(s0)                // Load collision diamond width
        lwc1    f0, 0x34(sp)                // Load edge X
        add.s   f0, f0, f2                  // Add collision diamond width to edge X
        swc1    f0, 0x34(sp)                // Store edge X + collision diamond width
        lui     at, 0x41F0                  // Load 30.0
        mtc1    at, f4                      // Move 30.0 into f4
        lwc1    f2, 0xB0(s0)                // Load collision diamond top
        add.s   f2, f2, f4                  // Add 30.0 to collision diamond top
        lwc1    f0, 0x38(sp)                // Load edge Y
        add.s   f0, f0, f2                  // Add collision diamond top + 30.0 to edge Y
        swc1    f0, 0x38(sp)                // Store edge Y
        lw      a0, 0x78(s0)                // Load TopN translate vector
        addiu   a1, sp, 0x34                // Get address of collision detection position
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL line ID to find
        sw      r0, 0x10(sp)                // ~
        jal     0x800F7F00                  // mpCollisionCheckLWallLineCollisionSame
        sw      r0, 0x14(sp)                // ~

        bnezl   v0, _params_l               // There is a new wall line ID above, allow Knuckles to keep climbing
        nop                                 // ~

        lw      a0, 0x118(s0)               // Load LWALL line ID
        jal     0x800F4650                  // mpCollisionGetUDEdgeUpperL
        addiu   a1, sp, 0x34                // Get address of collision detection position

        // This checks at upper edge Y base
        lwc1    f2, 0xBC(s0)                // Load collision diamond width
        lwc1    f0, 0x34(sp)                // Load edge X
        add.s   f0, f0, f2                  // Add collision diamond width to edge X
        swc1    f0, 0x34(sp)                // Store edge X + collision diamond width
        lw      a0, 0x78(s0)                // Load TopN translate vector
        addiu   a1, sp, 0x34                // Get address of collision detection position
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL collision flags pointer
        sw      r0, 0x10(sp)                // ~
        jal     0x800F5E90                  // mpCollisionCheckCeilLineCollisionSame
        sw      r0, 0x14(sp)                // ~

        bnezl   v0, _climb_end              // Ceiling collision is in the way, end climb
        nop                                 // ~

        // This checks at upper edge Y base + ECB center
        lwc1    f2, 0xB4(s0)                // Load collision diamond center
        lwc1    f0, 0x38(sp)                // Load edge Y
        add.s   f0, f0, f2                  // Add collision diamond center to edge Y
        swc1    f0, 0x38(sp)                // Store edge Y + collision diamond center
        lw      a0, 0x78(s0)                // Load TopN translate vector
        addiu   a1, sp, 0x34                // Get address of collision detection position
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL collision flags pointer
        sw      r0, 0x10(sp)                // ~
        jal     0x800F5E90                  // mpCollisionCheckCeilLineCollisionSame
        sw      r0, 0x14(sp)                // ~

        bnezl   v0, _climb_end              // Ceiling collision is in the way, end climb
        nop                                 // ~

        lwc1    f4, 0xB0(s0)                // Load collision diamond top
        lwc1    f2, 0xB4(s0)                // Load collision diamond center
        lwc1    f0, 0x38(sp)                // Load edge Y + collision diamond center
        sub.s   f0, f0, f2                  // Subtract collision diamond center from edge Y + collision diamond center
        lw      a0, 0x78(s0)                // Load TopN translate vector
        add.s   f0, f0, f4                  // Add collision diamond top to edge Y
        addiu   a1, sp, 0x34                // Get address of collision detection position
        swc1    f0, 0x38(sp)                // Store edge Y + collision diamond center
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL collision flags pointer
        sw      r0, 0x10(sp)                // ~
        jal     0x800F5E90                  // mpCollisionCheckCeilLineCollisionSame
        sw      r0, 0x14(sp)                // ~

        beqzl   v0, _climb_up               // No ceiling collision in the way, allow Knuckles to climb up
        nop                                 // ~

        b       _climb_end                  // Otherwise end climb
        nop                                 // ~

        _check_ceil_l:
        lw      a0, 0x118(s0)               // Load LWALL line ID
        jal     0x800F4670                  // mpCollisionGetUDEdgeUnderL
        addiu   a1, sp, 0x34                // Get address of position vector

        lwc1    f0, 0x38(sp)                // Load position of wall bottom edge
        c.lt.s  f20, f0                     // Check if TopN translate Y + collision diamond center < wall bottom edge Y
        nop                                 // ~
        bc1tl   _climb_end                  // Knuckles is below the wall bottom edge, drop off
        nop                                 // ~

        _params_l:
        lw      v0, 0x30(sp)                // Load collision check bool
        beqzl   v0, _climb_end              // If collision check also failed in the first place, drop off
        nop

        // Now that we have arrived here, we can update Knuckles' rotation
        lwc1    f12, 0xB28(s0)              // Load wall angle X
        lwc1    f14, 0xB2C(s0)              // Load wall angle Y
        jal     0x8001863C                  // atan2f
        neg.s   f12, f12                    // Negate wall angle X

        li      at, CLIMB_LWALL_MAX         // Load CLIMB_LWALL_MAX
        mtc1    at, f2                      // Move CLIMB_LWALL_MAX to f2
        nop                                 // ~
        c.le.s  f0, f2                      // Check if angle > CLIMB_LWALL_MAX
        nop                                 // ~
        bc1fl   _climb_end                  // Angle is invalid, drop off
        nop                                 // ~
        li      at, CLIMB_LWALL_MIN         // Load CLIMB_LWALL_MIN
        mtc1    at, f2                      // Move CLIMB_LWALL_MIN to f2
        nop                                 // ~
        c.lt.s  f0, f2                      // Check if angle < CLIMB_LWALL_MIN
        nop                                 // ~
        bc1tl   _climb_end                  // Angle is invalid, drop off
        nop                                 // ~

        swc1    f0, 0xB1C(s0)               // Store wall angle
        li      at, 0x3FC90FDB              // Load rad90
        mtc1    at, f2                      // Move rad90 to f2
        neg.s   f0, f0                      // -atan2f(-x, y)
        add.s   f0, f0, f2                  // Add rad90 to angle
        lw      a0, 0x8F8(s0)               // Load hip joint
        jal     0x800EB528                  // Unknown DObj function
        swc1    f0, 0x30(a0)                // Store angle as X rotation

        b       _end                        // ~
        addiu   v0, r0, 1                   // ClimbWait collision test was successful, return TRUE

        // ~~~ RWALL block ~~~
        _rwall_block:
        // First, check if the wall still exists...
        lw      a0, 0x12C(s0)               // Load current Line ID
        bltzl   a0, _climb_end              // Line doesn't exist, don't bother
        nop                                 // ~
        jal     0x800FC67C                  // mpCollisionCheckExistLineID
        nop                                 // ~
        beqzl   v0, _climb_end              // Line ID is turned off, don't bother
        nop                                 // ~

        // Check if we're touching a right wall...
        lw      a0, 0x12C(s0)               // Load current Line ID
        lw      v0, 0x78(s0)                // Load TopN translate vector
        lw      t0, 0x0(v0)                 // Load TopN translate X
        lw      t1, 0x4(v0)                 // Load TopN translate Y
        sw      t0, 0x20(sp)                // Store TopN translate X
        sw      t1, 0x24(sp)                // Store TopN translate Y
        lw      t0, 0x8(v0)                 // Load TopN translate Z
        sw      t0, 0x28(sp)                // Store TopN translate Z
        lwc1    f2, 0xBC(s0)                // Load collision diamond width
        lwc1    f0, 0x20(sp)                // Load TopN translate X
        sub.s   f0, f0, f2                  // Subtract collision diamond width from TopN translate X
        swc1    f0, 0x20(sp)                // Store TopN translate X - collision diamond width
        lwc1    f2, 0xB4(s0)                // Load collision diamond center
        lwc1    f0, 0x24(sp)                // Load TopN translate Y
        add.s   f20, f0, f2                 // Add collision diamond center to TopN translate Y
        swc1    f20, 0x24(sp)               // Store TopN Translate Y + collision diamond center
        addiu   a1, sp, 0x20                // Get address of collision detection position
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL collision flags pointer
        addiu   t0, s0, 0xB28               // Get address of wall angle status var
        jal     0x800F41C0                  // mpCollisionGetLRCommonRight
        sw      t0, 0x10(sp)                // ~

        sw      v0, 0x30(sp)                // Store collision check bool

        // Get the line ID above connecting to this RWALL
        jal     0x800FADE4                  // mpCollisionGetEdgeLeftULineID
        lw      a0, 0x12C(s0)               // Load new RWALL line ID

        bltzl   v0, _params_r               // No line ID connected!?
        nop                                 // Go to params stuff

        sw      v0, 0x2C(sp)                // Store found line ID
        jal     0x800FC67C                  // mpCollisionCheckExistLineID
        or      a0, v0, r0                  // Pass found line ID

        beqzl   v0, _params_r               // Line isn't turned on, just stay on the wall...
        nop                                 // ~

        jal     0x800FA8A4                  // Get line type of line ID
        lw      a0, 0x2C(sp)                // Pass found line ID

        bnezl   v0, _params_r               // Not a ground line ID?
        nop                                 // Also update params

        // Check if the line ID has the spike material type
        jal     0x800FCAC8                  // mpCollisionGetVertexFlagsLineID
        lw      a0, 0x2C(sp)                // Load found line ID
        andi    t0, v0, 0x00FF              // Mask surface material bits
        addiu   at, r0, 10                  // Load spike material ID
        beql    at, t0, _climb_end          // If hazard, end climb
        nop                                 // ~

        // Now let's get the right edge of the ground line ID we found
        lw      a0, 0x2C(sp)                // Load found line ID
        jal     0x800F4448                  // mpCollisionGetLREdgeUpperR
        addiu   a1, sp, 0x20                // Get address of position vector

        // We have the position of the ledge, let's see if Knuckles' ledge grab box is in range...
        lwc1    f2, 0xC4(s0)                // Load ledge grab box X position
        lw      a1, 0x78(s0)                // Load TopN translate vector
        lwc1    f0, 0x0(a1)                 // Load translate X
        sub.s   f0, f0, f2                  // Subtract ledge grab box X from translate X
        nop                                 // ~
        lwc1    f2, 0x20(sp)                // Load edge X position
        c.le.s  f0, f2                      // If (translate X + ledge grab X) > edge X
        nop                                 // ~
        bc1fl   _params_r                   // Continue to parameters stuff
        nop                                 // ~

        // lwc1    f4, 0xB4(s0)                // Load collision diamond center
        lwc1    f2, 0xC8(s0)                // Load ledge grab box Y position
        lwc1    f0, 0x4(a1)                 // Load translate Y
        // add.s   f20, f0, f4                 // Add collision diamond center to translate Y
        // nop                                 // ~
        add.s   f0, f0, f2                  // Add ledge grab box Y to translate Y
        nop                                 // ~
        lwc1    f2, 0x24(sp)                // Load edge Y position
        c.lt.s  f0, f2                      // If (translate Y + ledge grab Y) < edge Y...
        nop                                 // ~
        bc1tl   _check_ceil_r               // ...then go to ceiling check
        nop                                 // ~
        jal     0x80019AB0                  // syVectorDist3D
        addiu   a0, sp, 0x20                // Get address of edge position

        li      at, CLIMB_DIST_MAX          // Load CLIMB_DIST_MAX
        mtc1    at, f2                      // Move CLIMB_DIST_MAX into f2
        nop                                 // ~
        c.le.s  f0, f2                      // If distance to ledge <= CLIMB_DIST_MAX...
        nop                                 // ~
        bc1fl   _check_ceil_r               // ...then allow Knuckles to climb up
        nop                                 // ~

        lw      a0, 0x2C(sp)                // Load found line ID
        jal     0x800F4448                  // mpCollisionGetLREdgeUpperR
        addiu   a1, sp, 0x34                // Get address of position vector

        // Any right walls in chat?
        lwc1    f2, 0xBC(s0)                // Load collision diamond width
        lwc1    f0, 0x34(sp)                // Load edge X
        sub.s   f0, f0, f2                  // Subtract collision diamond width from edge X
        swc1    f0, 0x34(sp)                // Store edge X + collision diamond width
        lui     at, 0x41F0                  // Load 30.0
        mtc1    at, f4                      // Move 30.0 into f4
        lwc1    f2, 0xB0(s0)                // Load collision diamond top
        add.s   f2, f2, f4                  // Add 30.0 to collision diamond top
        lwc1    f0, 0x38(sp)                // Load edge Y
        add.s   f0, f0, f2                  // Add collision diamond top + 30.0 to edge Y
        swc1    f0, 0x38(sp)                // Store edge Y
        lw      a0, 0x78(s0)                // Load TopN translate vector
        addiu   a1, sp, 0x34                // Get address of collision detection position
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL line ID to find
        sw      r0, 0x10(sp)                // ~
        jal     0x800F6B58                  // mpCollisionCheckRWallLineCollisionSame
        sw      r0, 0x14(sp)                // ~

        bnezl   v0, _params_r               // There is a new wall line ID above, allow Knuckles to keep climbing
        nop                                 // ~

        lw      a0, 0x12C(s0)               // Load RWALL line ID
        jal     0x800F4690                  // mpCollisionGetUDEdgeUpperR
        addiu   a1, sp, 0x34                // Get address of collision detection position

        // This checks at upper edge Y base
        lwc1    f2, 0xBC(s0)                // Load collision diamond width
        lwc1    f0, 0x34(sp)                // Load edge X
        sub.s   f0, f0, f2                  // Subtract collision diamond width from edge X
        swc1    f0, 0x34(sp)                // Store edge X + collision diamond width
        lw      a0, 0x78(s0)                // Load TopN translate vector
        addiu   a1, sp, 0x34                // Get address of collision detection position
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL collision flags pointer
        sw      r0, 0x10(sp)                // ~
        jal     0x800F5E90                  // mpCollisionCheckCeilLineCollisionSame
        sw      r0, 0x14(sp)                // ~

        bnezl   v0, _climb_end              // Ceiling collision is in the way, end climb
        nop                                 // ~

        // This checks at upper edge Y base + ECB center
        lwc1    f2, 0xB4(s0)                // Load collision diamond center
        lwc1    f0, 0x38(sp)                // Load edge Y
        add.s   f0, f0, f2                  // Add collision diamond center to edge Y
        swc1    f0, 0x38(sp)                // Store edge Y + collision diamond center
        lw      a0, 0x78(s0)                // Load TopN translate vector
        addiu   a1, sp, 0x34                // Get address of collision detection position
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL collision flags pointer
        sw      r0, 0x10(sp)                // ~
        jal     0x800F5E90                  // mpCollisionCheckCeilLineCollisionSame
        sw      r0, 0x14(sp)                // ~

        bnezl   v0, _climb_end              // Ceiling collision is in the way, end climb
        nop                                 // ~

        lwc1    f4, 0xB0(s0)                // Load collision diamond top
        lwc1    f2, 0xB4(s0)                // Load collision diamond center
        lwc1    f0, 0x38(sp)                // Load edge Y + collision diamond center
        sub.s   f0, f0, f2                  // Subtract collision diamond center from edge Y + collision diamond center
        lw      a0, 0x78(s0)                // Load TopN translate vector
        add.s   f0, f0, f4                  // Add collision diamond top to edge Y
        addiu   a1, sp, 0x34                // Get address of collision detection position
        swc1    f0, 0x38(sp)                // Store edge Y + collision diamond center
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL collision flags pointer
        sw      r0, 0x10(sp)                // ~
        jal     0x800F5E90                  // mpCollisionCheckCeilLineCollisionSame
        sw      r0, 0x14(sp)                // ~

        beqzl   v0, _climb_up               // No ceiling collision in the way, allow Knuckles to climb up
        nop                                 // ~

        b       _climb_end                  // Otherwise end climb
        nop                                 // ~

        _check_ceil_r:
        lw      a0, 0x12C(s0)               // Load RWALL line ID
        jal     0x800F46B0                  // mpCollisionGetUDEdgeUnderR
        addiu   a1, sp, 0x34                // Get address of position vector

        lwc1    f0, 0x38(sp)                // Load position of ceiling edge
        c.lt.s  f20, f0                     // Check if TopN translate Y + collision diamond center < ceiling edge Y
        nop                                 // ~
        bc1tl   _climb_end                  // Knuckles is below the ceiling, drop off
        nop                                 // ~

        _params_r:
        lw      v0, 0x30(sp)                // Load collision check bool
        beqzl   v0, _climb_end              // If collision check also failed in the first place, drop off
        nop

        // Now that we have arrived here, we can update Knuckles' rotation
        lwc1    f12, 0xB28(s0)              // Load wall angle X
        lwc1    f14, 0xB2C(s0)              // Load wall angle Y
        jal     0x8001863C                  // atan2f
        neg.s   f12, f12                    // Negate wall angle X

        li      at, CLIMB_RWALL_MAX         // Load CLIMB_RWALL_MAX
        mtc1    at, f2                      // Move CLIMB_RWALL_MAX to f2
        nop                                 // ~
        c.le.s  f0, f2                      // Check if angle > CLIMB_RWALL_MAX
        nop                                 // ~
        bc1tl   _climb_end                  // Angle is invalid, drop off
        nop                                 // ~
        li      at, CLIMB_RWALL_MIN         // Load CLIMB_RWALL_MIN
        mtc1    at, f2                      // Move CLIMB_RWALL_MIN to f2
        nop                                 // ~
        c.lt.s  f0, f2                      // Check if angle < CLIMB_RWALL_MIN
        nop                                 // ~
        bc1fl   _climb_end                  // Angle is invalid, drop off
        nop                                 // ~

        swc1    f0, 0xB1C(s0)               // Store wall angle
        li      at, 0x3FC90FDB              // Load rad90
        mtc1    at, f2                      // Move rad90 to f2
        nop                                 // ~
        add.s   f0, f0, f2                  // Subtract rad90 from angle
        lw      a0, 0x8F8(s0)               // Load hip joint
        jal     0x800EB528                  // Unknown DObj function
        swc1    f0, 0x30(a0)                // Store angle as X rotation

        b       _end                        // ~
        addiu   v0, r0, 1                   // ClimbWait collision test was successful, return TRUE

        _climb_up:
        lw      t0, 0x2C(sp)                // Get found ground line ID
        sw      t0, 0x140(s0)               // Store ground line ID as cliff ID

        lui     at, 0x8004                  // gGCCommonLinks
        lw      v1, 0x66FC(at)              // Load fighter_gobj links (0x800466FC, link ID 3)
        lw      a0, 0x4(s0)                 // Load this fighter_gobj

        beqzl   v1, _climb_pos_check        // Link GObj doesn't exist, skip loop
        lwc1    f0, 0x24(sp)                // Get Y position of edge

        _loop_start:
        beql    v1, a0, _loop_check         // If this fighter_gobj == other fighter_gobj, check next GObj in list
        lw      v1, 0x4(v1)                 // Load link_next

        lw      v0, 0x84(v1)                // Load other fighter struct
        lbu     t1, 0x190(v0)               // Load flags
        andi    at, t1, 0x1                 // AND with ledge hold flag
        beqzl   at, _loop_check             // This guy is not holding the ledge, move along...
        lw      v1, 0x4(v1)                 // Load link_next

        lw      t1, 0x140(v0)               // Load other fighter's cliff line ID
        bnel    t1, t0, _loop_check         // Cliff line ID is not the same, move along...
        lw      v1, 0x4(v1)                 // Load link_next

        lw      t1, 0x44(v0)                // Load other fighter's direction
        lw      t0, 0x44(s0)                // Load this fighter's direction

        bnel    t0, t1, _loop_check         // Not facing the same direction, move allong...
        lw      v1, 0x4(v1)                 // Load link_next

        b       _climb_end                  // The ledge is occupied, end climb...
        nop                                 // ~

        _loop_check:
        bnezl    v1, _loop_start            // GObj exists, loop again
        nop                                 // ~

        lwc1    f0, 0x24(sp)                // Get Y position of edge

        _climb_pos_check:
        c.lt.s  f20, f0                     // If translate Y + collision diamond Y < edge Y...
        nop                                 // ~
        bc1fl   _climb_action               // Then < ledge bool = FALSE
        or      a1, r0, r0                  // ~

        addiu   a1, r0, 1                   // Otherwise < ledge bool = TRUE

        _climb_action:
        jal     CBMKnucklesClimb.climb_cliff_initial_ // ftCommonCliffQuickOrSlowSetStatus
        nop                                 // fighter_gobj should be ready here

        b       _end                        // ~
        or      v0, r0, r0                  // Climb collision was successful, but ended with ledge climb; return FALSE

        _climb_end:
        addiu   at, r0, 2                   // Load 2
        sb      at, 0x148(s0)               // Store 2 (all jumps used)

        // ...otherwise GlideEnd
        lw      a0, 0x4(s0)                 // Load fighter_gobj
        or      a1, r0, r0                  // Starting anim frame = 4.0
        jal     CBMKnucklesNSP.air_end_initial_ // ~
        lui     a2, 0x3F80                  // Anim speed = 1.0x

        sw      r0, 0x48(s0)                // Kill X velocity

        or      v0, r0, r0                  // Climb was unsuccessful, return FALSE
        _end:
        lw      ra, 0x44(sp)                // Load return address
        lw      s0, 0x40(sp)                // Load s0
        ldc1    f20, 0x48(sp)               // Load f20
        jr      ra                          // Return from subroutine
        addiu   sp, sp, 0x50                // Restore stack frame
    }

    scope climb_common_collision_: {
        addiu   sp, sp, -0x50               // Allocate stack frame
        sdc1    f20, 0x48(sp)               // Store f20
        sw      ra, 0x44(sp)                // Save return address
        sw      s0, 0x40(sp)                // Store s1
        lw      s0, 0x84(a0)                // Load fighter struct

        // Vanilla line types:
        // 0 = ground, 1 = ceiling, 2 = right wall, 3 = left wall
        // We do not need to check for ground and ceiling, and we cannot check for immediate values,
        // So we are optimizing these checks by making 0 = right wall and 1 = left wall
        lw      t0, 0xB20(s0)               // Load line type
        beqz    t0, _rwall_block            // Go to RWALL block
        addiu   at, r0, 1                   // Load LWALL
        bnel    at, t0, _climb_end          // Knuckles is somehow not on a wall, drop him off
        nop                                 // Load return address

        // ~~~ LWALL block ~~~
        // Run main collision routine
        // Check if the wall even exists in the first place
        lw      a0, 0x118(s0)               // Load current Line ID
        // lw      t0, 0x118(s0)               // Load LWALL line ID
        // bnel    a0, t0, _climb_end          // Somehow on a different line ID!?
        // nop                                 // ~
        bltzl   a0, _climb_end              // Line doesn't exist, don't bother
        nop                                 // ~
        jal     0x800FC67C                  // mpCollisionCheckExistLineID
        nop                                 // ~
        beqzl   v0, _climb_end              // Line ID is turned off, don't bother
        nop                                 // ~

        // Try to get position of moving collisions with wall line ID
        lw      a0, 0x118(s0)               // Load current Line ID
        jal     0x800FA7B8                  // mpCollisionGetSpeedLineID
        addiu   a1, s0, 0x98                // Get address of moving collision velocity

        lw      a0, 0x78(s0)                // Load TopN translate vector
        jal     0x80018FBC                  // syVectorAdd3D
        addiu   a1, s0, 0x98                // Get address of moving collision velocity

        // Now run the main collision routine to correct our position
        jal     0x800DE934                  // mpCommonProcFighterWaitOrLanding
        lw      a0, 0x4(s0)                 // Load fighter_gobj

        lhu     t0, 0xCE(s0)                // Load some collision flag
        andi    at, t0, 0x800               // Check if colliding with GROUND
        bnezl   at, _end                    // Go to function end if Knuckles has collided with GROUND
        lw      ra, 0x44(sp)                // Load return address

        // Check if we're touching a left wall...
        lw      a0, 0x118(s0)               // Load current Line ID
        lw      v0, 0x78(s0)                // Load TopN translate vector
        lw      t0, 0x0(v0)                 // Load TopN translate X
        lw      t1, 0x4(v0)                 // Load TopN translate Y
        sw      t0, 0x20(sp)                // Store TopN translate X
        sw      t1, 0x24(sp)                // Store TopN translate Y
        lw      t0, 0x8(v0)                 // Load TopN translate Z
        sw      t0, 0x28(sp)                // Store TopN translate Z
        lwc1    f2, 0xBC(s0)                // Load collision diamond width
        lwc1    f0, 0x20(sp)                // Load TopN translate X
        add.s   f0, f0, f2                  // Add collision diamond width to TopN translate X
        swc1    f0, 0x20(sp)                // Store TopN translate X + collision diamond width
        lwc1    f2, 0xB4(s0)                // Load collision diamond center
        lwc1    f0, 0x24(sp)                // Load TopN translate Y
        add.s   f20, f0, f2                 // Add collision diamond center to TopN translate Y
        swc1    f20, 0x24(sp)               // Store TopN Translate Y + collision diamond center
        addiu   a1, sp, 0x20                // Get address of collision detection position
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL collision flags pointer
        addiu   t0, s0, 0xB28               // Get address of wall angle status var
        jal     0x800F4194                  // mpCollisionGetLRCommonLeft
        sw      t0, 0x10(sp)                // ~

        // ...if we're not touching a wall, put Knuckles in GlideEnd (for now)
        beqzl   v0, _climb_end              // Line doesn't exist, don't bother
        nop                                 // ~

        // Get the line ID above connecting to this LWALL
        jal     0x800FAAE4                  // mpCollisionGetEdgeUpperRLineID
        lw      a0, 0x118(s0)               // Load new LWALL line ID

        bltzl   v0, _params_l               // No line ID connected!?
        nop                                 // Go to params stuff

        sw      v0, 0x2C(sp)                // Store found line ID
        jal     0x800FC67C                  // mpCollisionCheckExistLineID
        or      a0, v0, r0                  // Pass found line ID

        beqzl   v0, _params_l               // Line isn't turned on, just stay on the wall...
        nop                                 // ~

        jal     0x800FA8A4                  // Get line type of line ID
        lw      a0, 0x2C(sp)                // Pass found line ID

        bnezl   v0, _params_l               // Not a ground line ID?
        nop                                 // Also update params

        // Check if the line ID has the spike material type
        jal     0x800FCAC8                  // mpCollisionGetVertexFlagsLineID
        lw      a0, 0x2C(sp)                // Load found line ID
        andi    t0, v0, 0x00FF              // Mask surface material bits
        addiu   at, r0, 10                  // Load spike material ID
        beql    at, t0, _climb_end          // If hazard, end climb
        nop                                 // ~

        // Now let's get the left edge of the ground line ID we found
        lw      a0, 0x2C(sp)                // Load found line ID
        jal     0x800F4428                  // mpCollisionGetLREdgeUpperL
        addiu   a1, sp, 0x20                // Get address of position vector

        // We have the position of the ledge, let's see if Knuckles' ledge grab box is in range...
        lwc1    f2, 0xC4(s0)                // Load ledge grab box X position
        lw      a1, 0x78(s0)                // Load TopN translate vector
        lwc1    f0, 0x0(a1)                 // Load translate X
        add.s   f0, f0, f2                  // Add ledge grab box X to translate X
        nop                                 // ~
        lwc1    f2, 0x20(sp)                // Load edge X position
        c.lt.s  f0, f2                      // If (translate X + ledge grab X) < edge X
        nop                                 // ~
        bc1tl   _params_l                   // Continue to parameters stuff
        nop                                 // ~

        // lwc1    f4, 0xB4(s0)                // Load collision diamond center
        lwc1    f2, 0xC8(s0)                // Load ledge grab box Y position
        lwc1    f0, 0x4(a1)                 // Load translate Y
        // add.s   f20, f0, f4                 // Add collision diamond center to translate Y
        // nop                                 // ~
        add.s   f0, f0, f2                  // Add ledge grab box Y to translate Y
        nop                                 // ~
        lwc1    f2, 0x24(sp)                // Load edge Y position
        c.lt.s  f0, f2                      // If (translate Y + ledge grab Y) < edge Y...
        nop                                 // ~
        bc1tl   _params_l                   // ...then continue to parameters stuff
        nop                                 // ~
        jal     0x80019AB0                  // syVectorDist3D
        addiu   a0, sp, 0x20                // Get address of edge position

        li      at, CLIMB_DIST_MAX          // Load CLIMB_DIST_MAX
        mtc1    at, f2                      // Move CLIMB_DIST_MAX into f2
        nop                                 // ~
        c.le.s  f0, f2                      // If distance to ledge <= CLIMB_DIST_MAX...
        nop                                 // ~
        bc1fl   _params_l                   // ...then allow Knuckles to climb up
        nop                                 // ~

        lw      a0, 0x2C(sp)                // Load found line ID
        jal     0x800F4428                  // mpCollisionGetLREdgeUpperL
        addiu   a1, sp, 0x34                // Get address of position vector

        // Any left walls in chat?
        lwc1    f2, 0xBC(s0)                // Load collision diamond width
        lwc1    f0, 0x34(sp)                // Load edge X
        add.s   f0, f0, f2                  // Add collision diamond width to edge X
        swc1    f0, 0x34(sp)                // Store edge X + collision diamond width
        lui     at, 0x41F0                  // Load 30.0
        mtc1    at, f4                      // Move 30.0 into f4
        lwc1    f2, 0xB0(s0)                // Load collision diamond top
        add.s   f2, f2, f4                  // Add 30.0 to collision diamond top
        lwc1    f0, 0x38(sp)                // Load edge Y
        add.s   f0, f0, f2                  // Add collision diamond top + 30.0 to edge Y
        swc1    f0, 0x38(sp)                // Store edge Y
        lw      a0, 0x78(s0)                // Load TopN translate vector
        addiu   a1, sp, 0x34                // Get address of collision detection position
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL line ID to find
        sw      r0, 0x10(sp)                // ~
        jal     0x800F7F00                  // mpCollisionCheckLWallLineCollisionSame
        sw      r0, 0x14(sp)                // ~

        bnezl   v0, _params_l               // There is a new wall line ID above, allow Knuckles to keep climbing
        nop                                 // ~

        lw      a0, 0x118(s0)               // Load LWALL line ID
        jal     0x800F4650                  // mpCollisionGetUDEdgeUpperL
        addiu   a1, sp, 0x34                // Get address of collision detection position

        // This checks at upper edge Y base
        lwc1    f2, 0xBC(s0)                // Load collision diamond width
        lwc1    f0, 0x34(sp)                // Load edge X
        add.s   f0, f0, f2                  // Add collision diamond width to edge X
        swc1    f0, 0x34(sp)                // Store edge X + collision diamond width
        lw      a0, 0x78(s0)                // Load TopN translate vector
        addiu   a1, sp, 0x34                // Get address of collision detection position
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL collision flags pointer
        sw      r0, 0x10(sp)                // ~
        jal     0x800F5E90                  // mpCollisionCheckCeilLineCollisionSame
        sw      r0, 0x14(sp)                // ~

        bnezl   v0, _climb_end              // Ceiling collision is in the way, end climb
        nop                                 // ~

        // This checks at upper edge Y base + ECB center
        lwc1    f2, 0xB4(s0)                // Load collision diamond center
        lwc1    f0, 0x38(sp)                // Load edge Y
        add.s   f0, f0, f2                  // Add collision diamond center to edge Y
        swc1    f0, 0x38(sp)                // Store edge Y + collision diamond center
        lw      a0, 0x78(s0)                // Load TopN translate vector
        addiu   a1, sp, 0x34                // Get address of collision detection position
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL collision flags pointer
        sw      r0, 0x10(sp)                // ~
        jal     0x800F5E90                  // mpCollisionCheckCeilLineCollisionSame
        sw      r0, 0x14(sp)                // ~

        bnezl   v0, _climb_end              // Ceiling collision is in the way, end climb
        nop                                 // ~

        lwc1    f4, 0xB0(s0)                // Load collision diamond top
        lwc1    f2, 0xB4(s0)                // Load collision diamond center
        lwc1    f0, 0x38(sp)                // Load edge Y + collision diamond center
        sub.s   f0, f0, f2                  // Subtract collision diamond center from edge Y + collision diamond center
        lw      a0, 0x78(s0)                // Load TopN translate vector
        add.s   f0, f0, f4                  // Add collision diamond top to edge Y
        addiu   a1, sp, 0x34                // Get address of collision detection position
        swc1    f0, 0x38(sp)                // Store edge Y + collision diamond center
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL collision flags pointer
        sw      r0, 0x10(sp)                // ~
        jal     0x800F5E90                  // mpCollisionCheckCeilLineCollisionSame
        sw      r0, 0x14(sp)                // ~

        beqzl   v0, _climb_up               // No ceiling collision in the way, allow Knuckles to climb up
        nop                                 // ~

        b       _climb_end                  // Otherwise end climb
        nop                                 // ~

        _params_l:
        // Now that we have arrived here, we can update Knuckles' rotation
        lwc1    f12, 0xB28(s0)              // Load wall angle X
        lwc1    f14, 0xB2C(s0)              // Load wall angle Y
        jal     0x8001863C                  // atan2f
        neg.s   f12, f12                    // Negate wall angle X

        li      at, CLIMB_LWALL_MAX         // Load CLIMB_LWALL_MAX
        mtc1    at, f2                      // Move CLIMB_LWALL_MAX to f2
        nop                                 // ~
        c.le.s  f0, f2                      // Check if angle > CLIMB_LWALL_MAX
        nop                                 // ~
        bc1fl   _climb_end                  // Angle is invalid, drop off
        nop                                 // ~
        li      at, CLIMB_LWALL_MIN         // Load CLIMB_LWALL_MIN
        mtc1    at, f2                      // Move CLIMB_LWALL_MIN to f2
        nop                                 // ~
        c.lt.s  f0, f2                      // Check if angle < CLIMB_LWALL_MIN
        nop                                 // ~
        bc1tl   _climb_end                  // Angle is invalid, drop off
        nop                                 // ~

        swc1    f0, 0xB1C(s0)               // Store wall angle
        li      at, 0x3FC90FDB              // Load rad90
        mtc1    at, f2                      // Move rad90 to f2
        neg.s   f0, f0                      // -atan2f(-x, y)
        add.s   f0, f0, f2                  // Add rad90 to angle
        lw      a0, 0x8F8(s0)               // Load hip joint
        jal     0x800EB528                  // Unknown DObj function
        swc1    f0, 0x30(a0)                // Store angle as X rotation

        b       _end                        // ~
        lw      ra, 0x44(sp)                // Load return address

        // ~~~ RWALL block ~~~
        _rwall_block:
        // Check if the wall even exists in the first place
        lw      a0, 0x12C(s0)               // Load current Line ID
        // lw      t0, 0x12C(s0)               // Load RWALL line ID
        // bnel    a0, t0, _climb_end          // Somehow on a different line ID!?
        // nop                                 // ~
        bltzl   a0, _climb_end              // Line doesn't exist, don't bother
        nop                                 // ~
        jal     0x800FC67C                  // mpCollisionCheckExistLineID
        nop                                 // ~
        beqzl   v0, _climb_end              // Line ID is turned off, don't bother
        nop                                 // ~

        // Try to get position of moving collisions with wall line ID
        lw      a0, 0x12C(s0)               // Load current Line ID
        jal     0x800FA7B8                  // mpCollisionGetSpeedLineID
        addiu   a1, s0, 0x98                // Get address of moving collision velocity

        lw      a0, 0x78(s0)                // Load TopN translate vector
        jal     0x80018FBC                  // syVectorAdd3D
        addiu   a1, s0, 0x98                // Get address of moving collision velocity

        // Now run the main collision routine to correct our position
        jal     0x800DE934                  // mpCommonProcFighterWaitOrLanding
        lw      a0, 0x4(s0)                 // Load fighter_gobj

        lhu     t0, 0xCE(s0)                // Load some collision flag
        andi    at, t0, 0x800               // Check if colliding with GROUND
        bnezl   at, _end                    // Go to function end if Knuckles has collided with GROUND
        lw      ra, 0x44(sp)                // Load return address

        // Check if we're touching a right wall...
        lw      a0, 0x12C(s0)               // Load current Line ID
        lw      v0, 0x78(s0)                // Load TopN translate vector
        lw      t0, 0x0(v0)                 // Load TopN translate X
        lw      t1, 0x4(v0)                 // Load TopN translate Y
        sw      t0, 0x20(sp)                // Store TopN translate X
        sw      t1, 0x24(sp)                // Store TopN translate Y
        lw      t0, 0x8(v0)                 // Load TopN translate Z
        sw      t0, 0x28(sp)                // Store TopN translate Z
        lwc1    f2, 0xBC(s0)                // Load collision diamond width
        lwc1    f0, 0x20(sp)                // Load TopN translate X
        sub.s   f0, f0, f2                  // Subtract collision diamond width from TopN translate X
        swc1    f0, 0x20(sp)                // Store TopN translate X - collision diamond width
        lwc1    f2, 0xB4(s0)                // Load collision diamond center
        lwc1    f0, 0x24(sp)                // Load TopN translate Y
        add.s   f20, f0, f2                 // Add collision diamond center to TopN translate Y
        swc1    f20, 0x24(sp)               // Store TopN Translate Y + collision diamond center
        addiu   a1, sp, 0x20                // Get address of collision detection position
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL collision flags pointer
        addiu   t0, s0, 0xB28               // Get address of wall angle status var
        jal     0x800F41C0                  // mpCollisionGetLRCommonRight
        sw      t0, 0x10(sp)                // ~

        // ...if we're not touching a wall, put Knuckles in GlideEnd (for now)
        beqzl   v0, _climb_end              // Line doesn't exist, don't bother
        nop                                 // ~

        // Get the line ID above connecting to this RWALL
        jal     0x800FAAE4                  // mpCollisionGetEdgeUpperRLineID
        lw      a0, 0x12C(s0)               // Load new RWALL line ID

        bltzl   v0, _params_r               // No line ID connected!?
        nop                                 // Go to params stuff

        sw      v0, 0x2C(sp)                // Store found line ID
        jal     0x800FC67C                  // mpCollisionCheckExistLineID
        or      a0, v0, r0                  // Pass found line ID

        beqzl   v0, _params_r               // Line isn't turned on, just stay on the wall...
        nop                                 // ~

        jal     0x800FA8A4                  // Get line type of line ID
        lw      a0, 0x2C(sp)                // Pass found line ID

        bnezl   v0, _params_r               // Not a ground line ID?
        nop                                 // Also update params

        // Check if the line ID has the spike material type
        jal     0x800FCAC8                  // mpCollisionGetVertexFlagsLineID
        lw      a0, 0x2C(sp)                // Load found line ID
        andi    t0, v0, 0x00FF              // Mask surface material bits
        addiu   at, r0, 10                  // Load spike material ID
        beql    at, t0, _climb_end          // If hazard, end climb
        nop                                 // ~

        // Now let's get the right edge of the ground line ID we found
        lw      a0, 0x2C(sp)                // Load found line ID
        jal     0x800F4448                  // mpCollisionGetLREdgeUpperR
        addiu   a1, sp, 0x20                // Get address of position vector

        // We have the position of the ledge, let's see if Knuckles' ledge grab box is in range...
        lwc1    f2, 0xC4(s0)                // Load ledge grab box X position
        lw      a1, 0x78(s0)                // Load TopN translate vector
        lwc1    f0, 0x0(a1)                 // Load translate X
        sub.s   f0, f0, f2                  // Subtract ledge grab box X from translate X
        nop                                 // ~
        lwc1    f2, 0x20(sp)                // Load edge X position
        c.le.s  f0, f2                      // If (translate X + ledge grab X) > edge X
        nop                                 // ~
        bc1fl   _params_r                   // Continue to parameters stuff
        nop                                 // ~

        // lwc1    f4, 0xB4(s0)                // Load collision diamond center
        lwc1    f2, 0xC8(s0)                // Load ledge grab box Y position
        lwc1    f0, 0x4(a1)                 // Load translate Y
        // add.s   f20, f0, f4                 // Add collision diamond center to translate Y
        // nop                                 // ~
        add.s   f0, f0, f2                  // Add ledge grab box Y to translate Y
        nop                                 // ~
        lwc1    f2, 0x24(sp)                // Load edge Y position
        c.lt.s  f0, f2                      // If (translate Y + ledge grab Y) >= edge Y
        nop                                 // ~
        bc1tl   _params_r                   // Set action to CliffCatch
        nop                                 // ~

        jal     0x80019AB0                  // syVectorDist3D
        addiu   a0, sp, 0x20                // Get address of edge position

        li      at, CLIMB_DIST_MAX          // Load CLIMB_DIST_MAX
        mtc1    at, f2                      // Move CLIMB_DIST_MAX into f2
        nop                                 // ~
        c.le.s  f0, f2                      // If distance to ledge <= CLIMB_DIST_MAX...
        nop                                 // ~
        bc1fl   _params_r                   // ...then allow Knuckles to climb up
        nop                                 // ~

        lw      a0, 0x2C(sp)                // Load found line ID
        jal     0x800F4448                  // mpCollisionGetLREdgeUpperR
        addiu   a1, sp, 0x34                // Get address of position vector

        // Any right walls in chat?
        lwc1    f2, 0xBC(s0)                // Load collision diamond width
        lwc1    f0, 0x34(sp)                // Load edge X
        sub.s   f0, f0, f2                  // Subtract collision diamond width from edge X
        swc1    f0, 0x34(sp)                // Store edge X + collision diamond width
        lui     at, 0x41F0                  // Load 30.0
        mtc1    at, f4                      // Move 30.0 into f4
        lwc1    f2, 0xB0(s0)                // Load collision diamond top
        add.s   f2, f2, f4                  // Add 30.0 to collision diamond top
        lwc1    f0, 0x38(sp)                // Load edge Y
        add.s   f0, f0, f2                  // Add collision diamond top + 30.0 to edge Y
        swc1    f0, 0x38(sp)                // Store edge Y
        lw      a0, 0x78(s0)                // Load TopN translate vector
        addiu   a1, sp, 0x34                // Get address of collision detection position
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL line ID to find
        sw      r0, 0x10(sp)                // ~
        jal     0x800F6B58                  // mpCollisionCheckRWallLineCollisionSame
        sw      r0, 0x14(sp)                // ~

        bnezl   v0, _params_r               // There is a new wall line ID above, allow Knuckles to keep climbing
        nop                                 // ~

        lw      a0, 0x12C(s0)               // Load RWALL line ID
        jal     0x800F4690                  // mpCollisionGetUDEdgeUpperR
        addiu   a1, sp, 0x34                // Get address of collision detection position

        // This checks at upper edge Y base
        lwc1    f2, 0xBC(s0)                // Load collision diamond width
        lwc1    f0, 0x34(sp)                // Load edge X
        sub.s   f0, f0, f2                  // Subtract collision diamond width from edge X
        swc1    f0, 0x34(sp)                // Store edge X + collision diamond width
        lw      a0, 0x78(s0)                // Load TopN translate vector
        addiu   a1, sp, 0x34                // Get address of collision detection position
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL collision flags pointer
        sw      r0, 0x10(sp)                // ~
        jal     0x800F5E90                  // mpCollisionCheckCeilLineCollisionSame
        sw      r0, 0x14(sp)                // ~

        // This checks at upper edge Y base + ECB center
        lwc1    f2, 0xB4(s0)                // Load collision diamond center
        lwc1    f0, 0x38(sp)                // Load edge Y
        add.s   f0, f0, f2                  // Add collision diamond center to edge Y
        swc1    f0, 0x38(sp)                // Store edge Y + collision diamond center
        lw      a0, 0x78(s0)                // Load TopN translate vector
        addiu   a1, sp, 0x34                // Get address of collision detection position
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL collision flags pointer
        sw      r0, 0x10(sp)                // ~
        jal     0x800F5E90                  // mpCollisionCheckCeilLineCollisionSame
        sw      r0, 0x14(sp)                // ~

        bnezl   v0, _climb_end              // Ceiling collision is in the way, end climb
        nop                                 // ~

        lwc1    f4, 0xB0(s0)                // Load collision diamond top
        lwc1    f2, 0xB4(s0)                // Load collision diamond center
        lwc1    f0, 0x38(sp)                // Load edge Y + collision diamond center
        sub.s   f0, f0, f2                  // Subtract collision diamond center from edge Y + collision diamond center
        lw      a0, 0x78(s0)                // Load TopN translate vector
        add.s   f0, f0, f4                  // Add collision diamond top to edge Y
        addiu   a1, sp, 0x34                // Get address of collision detection position
        swc1    f0, 0x38(sp)                // Store edge Y + collision diamond center
        or      a2, r0, r0                  // NULL distance to collision vector
        or      a3, r0, r0                  // NULL collision flags pointer
        sw      r0, 0x10(sp)                // ~
        jal     0x800F5E90                  // mpCollisionCheckCeilLineCollisionSame
        sw      r0, 0x14(sp)                // ~

        beqzl   v0, _climb_up               // No ceiling collision in the way, allow Knuckles to climb up
        nop                                 // ~

        b       _climb_end                  // Otherwise end climb
        nop                                 // ~

        _params_r:
        // Now that we have arrived here, we can update Knuckles' rotation
        lwc1    f12, 0xB28(s0)              // Load wall angle X
        lwc1    f14, 0xB2C(s0)              // Load wall angle Y
        jal     0x8001863C                  // atan2f
        neg.s   f12, f12                    // Negate wall angle X

        li      at, CLIMB_RWALL_MAX         // Load CLIMB_RWALL_MAX
        mtc1    at, f2                      // Move CLIMB_RWALL_MAX to f2
        nop                                 // ~
        c.le.s  f0, f2                      // Check if angle > CLIMB_RWALL_MAX
        nop                                 // ~
        bc1tl   _climb_end                  // Angle is invalid, drop off
        nop                                 // ~
        li      at, CLIMB_RWALL_MIN         // Load CLIMB_RWALL_MIN
        mtc1    at, f2                      // Move CLIMB_RWALL_MIN to f2
        nop                                 // ~
        c.lt.s  f0, f2                      // Check if angle < CLIMB_RWALL_MIN
        nop                                 // ~
        bc1fl   _climb_end                  // Angle is invalid, drop off
        nop                                 // ~

        swc1    f0, 0xB1C(s0)               // Store wall angle
        li      at, 0x3FC90FDB              // Load rad90
        mtc1    at, f2                      // Move rad90 to f2
        nop                                 // ~
        add.s   f0, f0, f2                  // Subtract rad90 from angle
        lw      a0, 0x8F8(s0)               // Load hip joint
        jal     0x800EB528                  // Unknown DObj function
        swc1    f0, 0x30(a0)                // Store angle as X rotation

        b       _end                        // ~
        lw      ra, 0x44(sp)                // Load return address

        _climb_up:
        lw      t0, 0x2C(sp)                // Get found ground line ID
        sw      t0, 0x140(s0)               // Store ground line ID as cliff ID

        lui     at, 0x8004                  // gGCCommonLinks
        lw      v1, 0x66FC(at)              // Load fighter_gobj links (0x800466FC, link ID 3)
        lw      a0, 0x4(s0)                 // Load this fighter_gobj

        beqzl   v1, _climb_pos_check        // Link GObj doesn't exist, skip loop
        lwc1    f0, 0x24(sp)                // Get Y position of edge

        _loop_start:
        beql    v1, a0, _loop_check         // If this fighter_gobj == other fighter_gobj, check next GObj in list
        lw      v1, 0x4(v1)                 // Load link_next

        lw      v0, 0x84(v1)                // Load other fighter struct
        lbu     t1, 0x190(v0)               // Load flags
        andi    at, t1, 0x1                 // AND with ledge hold flag
        beqzl   at, _loop_check             // This guy is not holding the ledge, move along...
        lw      v1, 0x4(v1)                 // Load link_next

        lw      t1, 0x140(v0)               // Load other fighter's cliff line ID
        bnel    t1, t0, _loop_check         // Cliff line ID is not the same, move along...
        lw      v1, 0x4(v1)                 // Load link_next

        lw      t1, 0x44(v0)                // Load other fighter's direction
        lw      t0, 0x44(s0)                // Load this fighter's direction

        bnel    t0, t1, _loop_check         // Not facing the same direction, move allong...
        lw      v1, 0x4(v1)                 // Load link_next

        b       _climb_end                  // The ledge is occupied, end climb...
        nop                                 // ~

        _loop_check:
        bnezl    v1, _loop_start            // GObj exists, loop again
        nop                                 // ~

        lwc1    f0, 0x24(sp)                // Get Y position of edge

        _climb_pos_check:
        c.lt.s  f20, f0                     // If translate Y + collision diamond Y < edge Y...
        nop                                 // ~
        bc1fl   _climb_action               // Then < ledge bool = FALSE
        or      a1, r0, r0                  // ~

        addiu   a1, r0, 1                   // Otherwise < ledge bool = TRUE

        _climb_action:
        jal     CBMKnucklesClimb.climb_cliff_initial_ // ftCommonCliffQuickOrSlowSetStatus
        nop                                 // fighter_gobj should be ready here

        b       _end                        // ~
        lw      ra, 0x44(sp)                // Load return address

        _climb_end:
        addiu   at, r0, 2                   // Load 2
        sb      at, 0x148(s0)               // Store 2 (all jumps used)

        _fall:
        lw      a0, 0x4(s0)                 // Load fighter_gobj
        lui     a1, 0x4080                  // Starting anim frame = 4.0
        jal     CBMKnucklesNSP.air_end_initial_ // ~
        lui     a2, 0x3F00                  // Anim speed = 0.5x

        jal     0x80035CD0                  // cosf
        lwc1    f12, 0xB1C(s0)              // Load wall angle

        lw      t0, 0x4C(s0)                // Load Y velocity
        mtc1    t0, f2                      // Move Y velocity into f2
        blezl   t0, _vel_cosf               // If Y velocity <= 0, continue
        abs.s   f2, f2                      // Make Y velocity absolute

        jal     0x800D9444                  // ftPhysicsStopVelAll
        lw      a0, 0x4(s0)                 // Load fighter_gobj

        b       _end                        // Go to function end
        lw      ra, 0x44(sp)                // Load return address

        _vel_cosf:
        mul.s   f0, f0, f2                  // Multiply Y velocity by cosf(angle)

        lwc1    f2, 0x44(s0)                // Load direction
        cvt.s.w f2, f2                      // Convert direction to float
        nop                                 // ~

        neg.s   f2, f2                      // Negate direction
        mul.s   f0, f0, f2                  // Multiply by direction
        nop                                 // ~
        swc1    f0, 0x48(s0)                // Store new X velocity

        lw      ra, 0x44(sp)                // Load return address
        _end:
        lw      s0, 0x40(sp)                // Load s0
        ldc1    f20, 0x48(sp)               // Load f20
        jr      ra                          // Return from subroutine
        addiu   sp, sp, 0x50                // Restore stack frame
    }

    scope climb_move_initial_: {
        addiu   sp, sp, -0x18               // Allocate stack frame
        sw      ra, 0x14(sp)                // Save return address
        sw      a0, 0x18(sp)                // Store a0

        bltzl   a2, pc() + 8                // If < 0, invert into t0
        subu    a2, r0, a2                  // ~

        mtc1    a2, f0                      // Move absolute stick range into f0
        nop                                 // ~
        cvt.s.w f0, f0                      // Convert absolute stick range to float

        li      at, 0x3FA00000              // Load 1.25
        mtc1    at, f2                      // Move 1.25 into f2
        nop                                 // ~

        mul.s   f0, f0, f2                  // Multiply absolute stick range by 1.25
        nop                                 // ~

        // Don't forget to clamp this between 0 and 100!!!

        li      at, CLIMB_ANIM_SPEED        // Load CLIMB_ANIM_SPEED
        mtc1    at, f2                      // Move CLIMB_ANIM_SPEED into f2
        nop                                 // ~

        mul.s   f0, f0, f2                  // Animation speed = percentage converted to decimal (idk if I explained that right)
        lli     at, CBMKnuckles.Action.NSP_Climb_MoveDown
        beql    at, a1, _movedown           // If action is MoveDown...
        or      a2, r0, r0                  // 0 as starting animation frame

        lw      a2, 0x78(a0)                // a2(starting frame) = current frame
        b       _change_action              // ~
        mfc1    a3, f0                      // a3(frame speed multiplier) = absolute stick range * 1.25

        _movedown:

        lui     a3, 0x3F80                  // Load 1.0
        _change_action:
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // Store flags: none
        // jal     0x800E0830                  // unknown common subroutine
        // lw      a0, 0x0018(sp)              // a0 = player object

        lw      ra, 0x14(sp)                // Load return address
        jr      ra                          // Return from subroutine
        addiu   sp, sp, 0x18                // Restore stack frame
    }

    scope climb_moveup_interrupt_: {
        addiu   sp, sp, -0x20               // Allocate stack frame
        sw      ra, 0x1C(sp)                // Save return address
        sw      s1, 0x18(sp)                // Store s1
        sw      s0, 0x14(sp)                // Store s0
        or      s0, a0, r0                  // Move a0 into s0
        lw      s1, 0x84(a0)                // Load fighter struct

        lb      t0, 0x1C3(s1)               // Load stick Y range

        slti    at, t0, -7                  // If Y range > -20...
        beqzl   at, _check_wait             // ...then check for jump inputs
        slti    at, t0, 8                   // Else check if range >= 20...

        lli     a1, CBMKnuckles.Action.NSP_Climb_MoveDown
        jal     CBMKnucklesClimb.climb_move_initial_
        or      a2, t0, r0                  // Move current stick range into a2

        b       _end                        // Go to function end
        lw      ra, 0x1C(sp)                // Load return address

        _check_wait:
        beqzl   at, _check_jump             // If range > -20 and < 20, go to wait
        lhu     t0, 0x1BE(s1)               // Load tapped buttons

        jal     CBMKnucklesClimb.climb_wait_initial_ // Go to climb wait
        lw      a1, 0x78(a0)                // Load animation frame

        b       _end                        // Go to function end
        lw      ra, 0x1C(sp)                // Load return address

        _check_jump:
        andi    at, t0, (Joypad.CR | Joypad.CL | Joypad.CD | Joypad.CU) // Check if jump buttons were pressed
        beqzl   at, _end                    // No buttons pressed, go to function end (for now)
        lw      ra, 0x1C(sp)                // Load return address

        // lbu     t0, 0x148(s1)               // Load jumps used
        // slti    at, t0, 2                   // If >= 2 jumps used, go to end
        // beqzl   at, _fall                   // All jumps used, fall instead
        // nop                                 // ~

        lli     a1, Action.JumpAerialF      // a1(action id) = NSP_Air_Begin
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // Store flags: none

        jal     CBMKnucklesClimb.climb_jump_setup_
        or      a0, s0, r0                  // Pass fighter gobj

        // b       _end                        // Go to function end
        // lw      ra, 0x1C(sp)                // Load return address

        _fall:
        // or      a0, s0, r0                  // Pass fighter_gobj
        // lui     a1, 0x4080                  // Starting anim frame = 4.0
        // jal     KnucklesNSP.air_end_initial_ // ~
        // lui     a2, 0x3F00                  // Anim speed = 0.5x

        lw      ra, 0x1C(sp)                // Load return address
        _end:
        lw      s1, 0x18(sp)                // Load s1
        lw      s0, 0x14(sp)                // Load s0
        jr      ra                          // Return from subroutine
        addiu   sp, sp, 0x20                // Restore stack frame
    }

    scope climb_movedown_interrupt_: {
        addiu   sp, sp, -0x20               // Allocate stack frame
        sw      ra, 0x1C(sp)                // Save return address
        sw      s1, 0x18(sp)                // Store s1
        sw      s0, 0x14(sp)                // Store s0
        or      s0, a0, r0                  // Move a0 into s0
        lw      s1, 0x84(a0)                // Load fighter struct

        lb      t0, 0x1C3(s1)               // Load stick Y range

        slti    at, t0, 8                  // If Y range >= 20...
        bnezl   at, _check_wait             // ...then check for jump inputs
        slti    at, t0, -7                 // Else check if range >= -20...

        lli     a1, CBMKnuckles.Action.NSP_Climb_MoveUp
        jal     CBMKnucklesClimb.climb_move_initial_
        or      a2, t0, r0                  // Move current stick range into a2

        b       _end                        // Go to function end
        lw      ra, 0x1C(sp)                // Load return address

        _check_wait:
        bnezl   at, _check_jump             // If range > -20 and < 20, go to wait
        lhu     t0, 0x1BE(s1)               // Load tapped buttons

        jal     CBMKnucklesClimb.climb_wait_initial_ // Go to climb wait
        or      a1, r0, r0                  // Animation frame = 0

        b       _end                        // Go to function end
        lw      ra, 0x1C(sp)                // Load return address

        _check_jump:
        andi    at, t0, (Joypad.CR | Joypad.CL | Joypad.CD | Joypad.CU) // Check if jump buttons were pressed
        beqzl   at, _end                    // No buttons pressed, go to function end (for now)
        lw      ra, 0x1C(sp)                // Load return address

        // lbu     t0, 0x148(s1)               // Load jumps used
        // slti    at, t0, 2                   // If >= 2 jumps used, go to end
        // beqzl   at, _fall                   // All jumps used, fall instead
        // nop                                 // ~

        lli     a1, Action.JumpAerialF      // a1(action id) = NSP_Air_Begin
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // Store flags: none

        jal     CBMKnucklesClimb.climb_jump_setup_
        or      a0, s0, r0                  // Pass fighter gobj

        // b       _end                        // Go to function end
        // lw      ra, 0x1C(sp)                // Load return address

        _fall:
        // or      a0, s0, r0                  // Pass fighter_gobj
        // lui     a1, 0x4080                  // Starting anim frame = 4.0
        // jal     KnucklesNSP.air_end_initial_ // ~
        // lui     a2, 0x3F00                  // Anim speed = 0.5x

        lw      ra, 0x1C(sp)                // Load return address
        _end:
        lw      s1, 0x18(sp)                // Load s1
        lw      s0, 0x14(sp)                // Load s0
        jr      ra                          // Return from subroutine
        addiu   sp, sp, 0x20                // Restore stack frame
    }

    // Almost works but... nah
    scope climb_move_physics_madmathman_: {
        addiu   sp, sp, -0x18               // Allocate stack frame
        sw      ra, 0x14(sp)                // Save return address
        sw      s0, 0x10(sp)                // Store s0
        lw      s0, 0x84(a0)                // Load fighter struct

        lb      t0, 0x1C3(s0)               // Load stick Y range
        mtc1    t0, f2                      // Move stick range into f0
        nop                                 // ~
        cvt.s.w f2, f2                      // Convert stick range to float

        li      at, CLIMB_SPEED             // Load CLIMB_SPEED
        mtc1    at, f4                      // Move CLIMB_SPEED into f2
        nop                                 // ~

        lui     at, 0x42A0                  // Load 80.0 (max stick range)
        mtc1    at, f6                      // Move 80.0 into f6
        nop                                 // ~

        div.s   f4, f4, f6                  // Get stick range multiplier by dividing CLIMB_SPEED by max stick range
        nop                                 // ~

        mul.s   f2, f2, f4                  // Multiply stick range by CLIMB_SPEED / max stick range
        nop                                 // ~
        swc1    f2, 0x4C(s0)                // Store new Y velocity

        jal     0x80035CD0                  // cosf
        lwc1    f12, 0xB1C(s0)              // Load wall angle

        lw      t0, 0xB20(s0)               // Load line type
        li      at, 0x3FC90FDB              // Load rad90
        mtc1    at, f2                      // Move rad90 into f2
        lwc1    f4, 0xB1C(s0)               // Load wall angle
        beqzl   t0, _cmp_rwall              // If RWALL, negate and compare > rad90 (?)
        neg.s   f2, f2

        c.lt.s  f4, f2                      // If LWALL && angle < 90, negate
        nop                                 // ~
        bc1fl   _get_velocity               // ~
        nop                                 // ~

        b       _get_velocity               // ~
        neg.s   f0, f0                      // ~

        _cmp_rwall:
        c.le.s  f4, f2                      // If RWALL && angle > -90, negate
        nop                                 // ~
        bc1fl   _get_velocity               // ~
        neg.s   f0, f0                      // ~

        _get_velocity:
        lwc1    f4, 0x4C(s0)                // Load Y velocity
        lwc1    f2, 0x44(s0)                // Load direction
        cvt.s.w f2, f2                      // Convert direction to float
        abs.s   f4, f4                      // Make Y velocity absolute
        neg.s   f2, f2                      // Negate direction
        mul.s   f2, f2, f4                  // Multiply direction by absolute Y velocity
        nop                                 // ~
        mul.s   f0, f0, f2                  // Multiply cosf(angle) by direction * absolute Y velocity
        nop                                 // ~
        swc1    f0, 0x48(s0)                // Store new X velocity

        lw      ra, 0x14(sp)                // Load return address
        lw      s0, 0x10(sp)                // Load s0
        jr      ra                          // Return from subroutine
        addiu   sp, sp, 0x18                // Restore stack frame
    }

    scope climb_jostle_physics_: {
        lui     at, 0x8004                  // Load gGCCommonLinks upper
        lw      a1, 0x66FC(at)              // Load link ID 3 (fighter GObjs)
        lw      v0, 0x84(a0)                // Load fighter struct
        or      t1, r0, r0                  // is_jostle bool = FALSE
        beqz    a1, _end                    // If other fighter_gobj is NULL, end
        or      t0, r0, r0                  // is_check_self bool = FALSE
        lui     at, 0x4040                  // Load 3.0
        mtc1    at, f10                     // Move 3.0 into f10
        lui     at, 0x40D8                  // Load 6.75
        mtc1    at, f8                      // Move 6.75 into f8
        mtc1    r0, f6                      // Move 0.0 into f16

        _loop_start:
        beq     a0, a1, _set_self           // If fighter_gobj == other_gobj, set self check bool
        lw      v1, 0x84(a1)                // Load other fighter struct

        lw      t2, 0x8(v1)                 // Load other fighter kind
        if {defined Character.CHARACTER_ADDED_KNUCKLES} {
            addiu   at, r0, Character.id.KNUCKLES // Check if Classic Knuckles
            beq     at, t2, _check_status   // Valid Knuckles variation, go to status check
            nop
        }
        if {defined Character.CHARACTER_ADDED_MKNUCKLES} {
            addiu   at, r0, Character.id.MKNUCKLES // Check if Modern Knuckles
            beq     at, t2, _check_status   // Valid Knuckles variation, go to status check
            nop
        }
        if {defined Character.CHARACTER_ADDED_CBKNUCKLES} {
            addiu   at, r0, Character.id.CBKNUCKLES // Check if Classic Cowboy Knuckles
            beq     at, t2, _check_status   // Valid Knuckles variation, go to status check
            nop
        }
        if {defined Character.CHARACTER_ADDED_CBMKNUCKLES} {
            addiu   at, r0, Character.id.CBMKNUCKLES // Check if Modern Cowboy Knuckles
            beq     at, t2, _check_status   // Valid Knuckles variation, go to status check
            nop
        }
        if {defined Character.CHARACTER_ADDED_NKNUX} {
            addiu   at, r0, Character.id.NKNUX  // Load Poly Knuckles character ID
            beq     at, t2, _check_status   // Valid Knuckles variation, go to status check
            nop
        }
        bnel    at, t2, _loop_continue      // If also not Poly Knuckles, continue with the loop
        lw      a1, 0x4(a1)                 // Load next GObj in list

        _check_status:
        lw      t2, 0x24(v1)                // Load other fighter's status ID
        addiu   t2, t2, -(CBMKnuckles.Action.ClimbWait) // Subtract climb wait status ID from status ID
        sltiu   at, t2, (CBMKnuckles.Action.ClimbDown - CBMKnuckles.Action.ClimbWait + 1) // at = 1 if any Climb action, 0 otherwise
        beqzl   at, _loop_continue          // If not climbing, ignore
        lw      a1, 0x4(a1)                 // Load next GObj in list

        lw      t3, 0x74(a1)                // Load other TopN joint
        lwc1    f4, 0x1C(t3)                // Load other TopN translate X
        lw      t2, 0x74(a0)                // Load this TopN joint
        lwc1    f2, 0x1C(t2)                // Load this TopN translate X
        li      at, CLIMB_JOSTLE_WIDTH      // Load CLIMB_JOSTLE_WIDTH
        mtc1    at, f0                      // Move CLIMB_JOSTLE_WIDTH to f4
        sub.s   f12, f4, f0                 // Subtract CLIMB_JOSTLE_WIDTH from other TopN translate X
        c.lt.s  f2, f12                     // Check if outside horizontal jostle range to the left
        nop                                 // ~
        bc1tl   _loop_continue              // Outside horizontal range, ignore
        lw      a1, 0x4(a1)                 // Load next GObj in list
        add.s   f12, f4, f0                 // Add CLIMB_JOSTLE_WIDTH to other TopN translate X
        c.le.s  f2, f12                     // Check if outside horizontal jostle range to the right
        nop                                 // ~
        bc1fl   _loop_continue              // Outside horizontal range, ignore
        lw      a1, 0x4(a1)                 // Load next GObj in list

        lwc1    f4, 0x20(t3)                // Load other TopN translate Y
        lwc1    f2, 0x20(t2)                // Load this TopN translate Y

        li      at, CLIMB_JOSTLE_Y          // Load CLIMB_JOSTLE_Y
        mtc1    at, f0                      // Move CLIMB_JOSTLE_Y to f0

        add.s   f2, f2, f0                  // This TopN translate Y + CLIMB_JOSTLE_Y
        add.s   f4, f4, f0                  // Other TopN translate Y + CLIMB_JOSTLE_Y
        nop                                 // ~
        sub.s   f0, f2, f4                  // Distance between jostles

        li      at, CLIMB_JOSTLE_HEIGHT     // Load CLIMB_JOSTLE_HEIGHT
        mtc1    at, f2                      // Move CLIMB_JOSTLE_HEIGHT to f2
        abs.s   f4, f0                      // Absolute jostle distance
        c.lt.s  f4, f2                      // Absolute jostle distance < CLIMB_JOSTLE_HEIGHT
        nop                                 // ~
        bc1fl   _loop_continue              // Not within distance, ignore
        lw      a1, 0x4(a1)                 // Load next GObj in list

        addiu   t1, r0, 1                   // is_jostle bool = TRUE
        c.eq.s  f0, f6                      // Jostle distance == 0.0
        mfc1    t4, f0                      // ~
        bc1fl   _check_cond_y               // ~
        slti    at, t4, 0                   // Check = jostle distance < 0.0

        or      at, t0, r0                  // Check = (is_check_self != FALSE)

        _check_cond_y:
        mov.s   f4, f8                      // ~
        bnezl   at, pc() + 8                // Check passed, make 6.75 negative
        neg.s   f4, f4                      // ~

        lwc1    f2, 0x20(t2)                // Load this TopN translate Y
        add.s   f2, f2, f4                  // TopN translate Y += jostle Y
        swc1    f2, 0x20(t2)                // Store new TopN translate Y

        lwc1    f4, 0x44(v0)                // Load direction
        cvt.s.w f4, f4                      // Convert direction to float
        abs.s   f2, f2                      // Make Y velocity absolute
        mul.s   f4, f2, f4                  // Multiply direction by absolute Y velocity
        nop                                 // ~
        lwc1    f2, 0x1C(t2)                // Load this TopN translate X
        add.s   f2, f2, f4                  // Add X velocity to TopN translate X
        swc1    f2, 0x1C(t2)                // Store new X velocity

        // lwc1    f4, 0x24(t3)                // Load other TopN translate Z
        // lwc1    f2, 0x24(t2)                // Load this TopN translate Z
        // sub.s   f2, f2, f4                  // Get Z distance

        // c.eq.s  f2, f6                      // Z distance == 0.0
        // mfc1    t5, f2                      // ~
        // bc1tl   _check_cond_z               // Check Z condition
        // slti    at, t5, 0                   // Check = dist_z < 0.0

        // c.eq.s  f0, f6                      // Jostle distance == 0.0
        // mfc1    t4, f0                      // ~
        // slti    at, t4, 0                   // Check = jostle distance < 0.0
        // bc1fl   _check_cond_z               // ~
        // xori    at, at, 1                   // ~

        // move    at, t0                      // Check = (is_check_self != FALSE)

        // _check_cond_z:
        // mov.s   f4, f10                     // ~
        // bnezl   at, pc() + 8                // Check passed, make 3.0 negative
        // neg.s   f4, f4                      // ~

        // lwc1    f2, 0x50(v0)                // Load this fighter's Z velocity
        // add.s   f2, f2, f4                  // Z velocity += Z distance
        // swc1    f2, 0x50(v0)                // Store new Z velocity

        b       _loop_continue              // ~
        lw      a1, 0x4(a1)                 // Load next GObj in list

        _set_self:
        addiu   t0, r0, 1                   // is_check_self = TRUE
        lw      a1, 0x4(a1)                 // Load next GObj in list

        _loop_continue:
        bnezl   a1, _loop_start             // If other GObj != NULL, continue
        nop                                 // ~

        // bnezl   t1, _end                    // If jostling has been handled, go to end
        // nop                                 // ~
        // lw      t0, 0x74(a0)                // Load this TopN joint
        // lwc1    f0, 0x24(t0)                // Load TopN translate Z
        // c.eq.s  f0, f16                     // TopN translate Z == 0.0
        // nop                                 // ~
        // bc1tl   _end                        // If translate Z == 0.0, go to end
        // nop                                 // ~

        // c.lt.s  f0, f16                     // If translate Z >= 0.0F, negate 3.0
        // nop                                 // ~
        // bc1fl   pc() + 8                    // ~
        // neg.s   f10, f10                    // ~

        // swc1    f10, 0x50(v0)               // Store new Z velocity
        _end:
        jr      ra                          // Return
        nop
    }

    scope climb_move_physics_: {
        addiu   sp, sp, -0x18               // Allocate stack frame
        sw      ra, 0x14(sp)                // Save return address
        lw      v0, 0x84(a0)                // Load fighter struct

        lb      t0, 0x1C3(v0)               // Load stick Y range
        mtc1    t0, f2                      // Move stick range into f0
        nop                                 // ~
        cvt.s.w f2, f2                      // Convert stick range to float

        li      at, CLIMB_SPEED             // Load CLIMB_SPEED
        mtc1    at, f4                      // Move CLIMB_SPEED into f2
        nop                                 // ~

        lui     at, 0x42A0                  // Load 80.0 (max stick range)
        mtc1    at, f6                      // Move 80.0 into f6
        nop                                 // ~

        div.s   f4, f4, f6                  // Get stick range multiplier by dividing CLIMB_SPEED by max stick range
        nop                                 // ~

        mul.s   f2, f2, f4                  // Multiply stick range by CLIMB_SPEED / max stick range
        nop                                 // ~
        swc1    f2, 0x4C(v0)                // Store new Y velocity

        lwc1    f0, 0x44(v0)                // Load direction
        cvt.s.w f0, f0                      // Convert direction to float
        abs.s   f2, f2                      // Make Y velocity absolute
        mul.s   f0, f0, f2                  // Multiply direction by absolute Y velocity
        nop                                 // ~
        swc1    f0, 0x48(v0)                // Store new X velocity

        jal     CBMKnucklesClimb.climb_jostle_physics_
        nop                                 // ~

        lw      ra, 0x14(sp)                // Load return address
        jr      ra                          // Return from subroutine
        addiu   sp, sp, 0x18                // Restore stack frame
    }
}

scope CBMKnucklesDive {
    constant AERIAL_INITIAL_Y_SPEED(0x4120) // current setting - float: 10
    constant X_SPEED(0x428C)                // current setting - float: 70
    constant Y_SPEED(0xC2C8)                // current setting - float: -110

    constant INITIAL_Y_SPEED(0x4334)        // current setting - float: 180.0
    constant INITIAL_X_SPEED(0x429C)        // current setting - float: 78
    constant SLOWING_SPEED_X(0x3F60)        // current setting - float: 0.875
    constant SLOWING_SPEED_Y(0x3F60)        // current setting - float: 0.875

    constant BEGIN(0x1)
    constant MOVE(0x2)

    constant WAIT_TIME(8)
    constant SLIDE_DIST(0x3F19)             // current setting - float: 0.6

    scope ground_initial_: {
        OS.routine_begin(0x18)
        sw      a0, 0x0018(sp)              // ~

        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      a2, 0x0008(t0)              // get character id

        // lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        // beql    a1, a2, _check_plat         // if Kirby, transition to aerial dive punch
        // addiu   t2, r0, OS.TRUE             // t2 = kirby indicator
        // lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        // beql    a1, a2, _check_plat         // if J Kirby, transition to aerial dive punch
        // addiu   t2, r0, OS.TRUE             // t2 = kirby indicator

        addiu   t2, r0, OS.FALSE            // kirby indicator = FALSE
        _check_plat:
        lw      at, 0x00EC(t0)              // at = clipping ID of player
        bgezl   at, _normal                 // if not over a normal plat (like on the respawn plat), then initialize in air
        nop

        beqzl   t2, _glide                  // transition to glide if not kirby
        addiu   at, r0, 1                   // Jumps used = 1

        _kirby_air:
        jal     air_initial_                // transition to aerial dive punch
        nop
        b       _end                        // go to function end
        nop

        _glide:
        jal     CBMKnucklesNSP.air_begin_initial_ // a1(transition subroutine) = glide air initial
        sb      at, 0x148(t0)               // Store jumps used
        b       _end                        // go to function end
        nop

        _normal:
        // bnezl   t2, _change_action          // if Kirby or J Kirby, use Kirby action
        // lli     a1, Kirby.Action.KNUX_Dive_Ground

        lli     a1, CBMKnuckles.Action.DiveGround // a1 = action id
        _change_action:
        lli     a2, 0x0000                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0

        jal     0x800E0830                  // ftMainPlayAnimEventsAll
        lw      a0, 0x0018(sp)              // ~

        lw      a0, 0x0018(sp)              // Load fighter GObj
        lw      t0, 0x0084(a0)              // t0 = player struct
        sw      r0, 0x017C(t0)              // temp variable 1 = 0
        sw      r0, 0x0180(t0)              // temp variable 2 = 0
        lli     at, BEGIN                   // at = BEGIN
        sw      at, 0x0184(t0)              // temp variable 3 = 0x1(BEGIN)
        sw      r0, 0x0B18(t0)              // frame timer     = 0

        _end:
        OS.routine_end(0x18)
    }

    scope ground_move_: {
        // a2 = player struct
        // 0x184 in player struct = temp variable 3

        OS.routine_begin(0x18)
        sw      t0, 0x0004(sp)              // ~
        sw      t2, 0x0008(sp)              // ~
        swc1    f0, 0x000C(sp)              // ~
        swc1    f2, 0x0010(sp)              // store t0, t2, f0, f2

        lw      t0, 0x0B18(a2)              // t0 = frame timer
        slti    at, t0, WAIT_TIME           // at = 1 if frame timer < WAIT_TIME, else at = 0
        addiu   t0, t0, 0x0001              // ~
        bnezl   at, _slide                  // branch if frame timer < WAIT_TIME
        sw      t0, 0x0B18(a2)              // increment frame timer

        // slow down x movement
        lwc1    f0, 0x0048(a2)              // f0 = current x velocity
        lui     t0, SLOWING_SPEED_X         // ~
        mtc1    t0, f2                      // f2 = SLOWING_SPEED_X
        mul.s   f0, f0, f2                  // f0 = x velocity * SLOWING_SPEED_X
        swc1    f0, 0x0048(a2)              // x velocity = (x velocity * SLOWING_SPEED_X)

        _check_begin:
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        lli     t2, BEGIN                   // t2 = BEGIN
        bnel    t0, t2, _check_initial      // skip if t0 != BEGIN
        nop

        // slow down y movement
        lwc1    f0, 0x004C(a2)              // f0 = current y velocity
        lui     t0, SLOWING_SPEED_Y         // ~
        mtc1    t0, f2                      // f2 = SLOWING_SPEED_Y
        mul.s   f0, f0, f2                  // f0 = y velocity * SLOWING_SPEED_Y
        swc1    f0, 0x004C(a2)              // y velocity = (y velocity * SLOWING_SPEED_Y)

        _check_initial:
        lw      t0, 0x017C(a2)              // t0 = temp variable 1
        beqzl   t0, _end                    // skip if temp variable 1 = 0
        nop

        sw      r0, 0x017C(a2)              // temp variable 1 = 0

        // apply initial x velocity
        lui     t2, INITIAL_X_SPEED         // ~
        mtc1    t2, f0                      // f0 = INITIAL_X_SPEED
        lwc1    f2, 0x0044(a2)              // ~
        cvt.s.w f2, f2                      // f2 = facing direction
        mul.s   f0, f0, f2                  // f0 = INITIAL_X_SPEED * direction
        swc1    f0, 0x0048(a2)              // x velocity = INITIAL_X_SPEED * direction

        // apply initial y velocity
        lui     t0, INITIAL_Y_SPEED         // ~
        sw      t0, 0x004C(a2)              // y velocity = INITIAL_Y_SPEED
        jal     0x800DEEC8                  // set aerial state
        or      a0, a2, r0                  // a0 = player struct
        b   _end
        nop

        _slide:
        lwc1    f0, 0x0048(a2)              // f0 = current x velocity
        lui     t0, SLIDE_DIST              // ~
        mtc1    t0, f2                      // f2 = SLIDE_DIST
        mul.s   f0, f0, f2                  // f0 = x velocity * SLIDE_DIST
        swc1    f0, 0x0048(a2)              // x velocity = (x velocity * SLIDE_DIST)

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // ~
        lwc1    f0, 0x000C(sp)              // ~
        lwc1    f2, 0x0010(sp)              // load t0, t2, f0, f2
        OS.routine_end(0x18)
    }

    // @ Description
    // Subroutine which handles physics for Knuckles' grounded Dive special.
    // Prevents negative Y velocity when temp variable 3 = 1 (BEGIN)
    // Temp variable 3 (5C00XXXX):
    // 0x1 = begin
    // 0x2 = apply movement speed
    scope ground_physics_: {
        // 0x184 in player struct = temp variable 3

        OS.routine_begin(0x18)
        sw      t0, 0x0004(sp)              // ~
        sw      t2, 0x0008(sp)              // ~
        sw      a0, 0x0010(sp)              // store t0, t2, a0

        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t0, 0x0B18(t0)              // t0 = frame timer
        slti    at, t0, WAIT_TIME           // at = 1 if frame timer < WAIT_TIME, else at = 0
        addiu   t0, t0, 0x0001              // ~
        bnezl   at, _end                    // branch if frame timer < WAIT_TIME
        nop

        jal     0x800D91EC                  // t8 = physics subroutine which prevents player control
        nop

        _check_fall:
        lw      a0, 0x0010(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t0, 0x0184(a0)              // t0 = temp variable 3
        lli     t2, BEGIN                   // t2 = BEGIN
        bnel    t0, t2, _check_move         // skip if temp variable 3 != BEGIN
        nop

        // Checks if the highest bit is set to 1, which is used to represent a negative floating
        // point value. If the highest bit is set to 1, sets y velocity to 0.
        lw      t0, 0x004C(a0)              // t0 = y velocity
        lui     t2, 0x8000                  // t2 = bitmask
        and     t2, t0, t2                  // t2 = 0 if y velocity is positive
        bnel    t2, r0, _end                // execute next instruction if y velocity is negative
        sw      r0, 0x004C(a0)              // y velocity = 0

        _check_move:
        lw      t0, 0x0184(a0)              // t0 = temp variable 3
        lli     t2, MOVE                    // t2 = MOVE
        bnel    t0, t2, _end                // skip if t0 != MOVE
        nop

        // apply y velocity
        lui     t2, Y_SPEED                 // ~
        sw      t2, 0x004C(a0)              // y velocity = Y_SPEED

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // ~
        lw      a0, 0x0010(sp)              // load t0, t2, a0
        OS.routine_end(0x18)
    }

    // @ Description
    // Subroutine which handles collision for Knuckles' grounded Dive special.
    // Transitions into the neutral special landing action when temp variable 3 = MOVE,
    // otherwise lands normally.
    scope ground_collision_: {
        OS.routine_begin(0x18)
        sw      t0, 0x000C(sp)              // ~
        sw      a0, 0x0010(sp)              // store a0, t0

        lw      a1, 0x0084(a0)              // a1 = player struct
        lw      t0, 0x0B18(a1)              // t0 = frame timer
        slti    at, t0, WAIT_TIME           // at = 1 if frame timer < WAIT_TIME, else at = 0
        addiu   t0, t0, 0x0001              // ~
        bnezl   at, _end                    // branch if frame timer < WAIT_TIME
        nop

        lw      t0, 0x014C(a1)              // t0 = kinetic state
        bnezl   t0, _aerial                 // branch if kinetic state != grounded
        nop

        _grounded:
        jal     0x800DDF44                  // grounded collision subroutine
        nop
        b       _end                        // branch to end
        nop

        _aerial:
        lw      t0, 0x184(a1)               // t0 = temp variable 3
        lli     a1, MOVE                    // a1 = MOVE
        beql    a1, t0, _main_collision     // branch if temp variable 3 = MOVE
        nop

        // If Knuckles is not in the ground pound motion, run a normal aerial collision subroutine
        // instead.
        jal     0x800DE99C                  // aerial collision subroutine
        nop
        b       _end                        // branch to end
        nop

        _main_collision:
        li      a1, begin_landing_          // a1 = begin_landing_
        jal     0x800DE6E4                  // general air collision?
        lw      a0, 0x0010(sp)              // a0 = player object
        jal     0x800DE87C                  // check ledge/floor collision?
        lw      a0, 0x0010(sp)              // a0 = player object
        beql    v0, r0, _end                // skip if !collision
        nop
        lw      a0, 0x0010(sp)              // a0 = player object
        lw      a1, 0x0084(a0)              // a1 = player struct
        lhu     a2, 0x00D2(a1)              // a2 = collision flags?
        andi    a2, a2, 0x3000              // bitmask
        beql    a2, r0, _end                // skip if !ledge_collision
        nop
        jal     0x80144C24                  // ledge grab subroutine
        nop

        _end:
        lw      t0, 0x000C(sp)              // ~
        lw      a0, 0x0010(sp)              // load a0, t0
        OS.routine_end(0x18)
    }

    // @ Description
    // Subroutine which transitions into the landing action for Knuckles' neutral special.
    // Copy of subroutine 0x801600EC, which begins the landing action for Falcon Kick.
    // Loads the appropriate landing action for Knuckles.
    scope begin_landing_: {
        // Copy the first 6 lines of subroutine 0x801600EC
        OS.copy_segment(0xDAB2C, 0x18)
        // Replace original line which loads the landing action id
        // addiu   a1, r0, 0x00E8           // replaced line

        // a0 = player object
        // a2, a3 are safe

        // lw      a1, 0x0084(a0)              // get player struct
        // lw      a2, 0x0008(a1)              // get character id
        // lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        // beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        // lli     a1, Kirby.Action.KNUX_Dive_Land
        // lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        // beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        // lli     a1, Kirby.Action.KNUX_Dive_Land

        lli     a1, CBMKnuckles.Action.DiveLand // a1 = action id

        // Copy the last 8 lines of subroutine 0x801600EC
        OS.copy_segment(0xDAB48, 0x20)
    }

    scope grounded_main_: {
        OS.routine_begin(0x18)
        li      a1, air_initial_            // a1(transition subroutine) = air_initial_
        jal     0x800D9480                  // common main subroutine (transition on animation end)
        lw      t8, 0x014C(a2)              // t8 = kinetic state
        OS.routine_end(0x18)
    }

    // @ Description
    // Subroutine which runs when Knuckles initiates the aerial neutral special for Dive.
    // Changes action, and sets up initial variable values.
    scope air_initial_: {
        OS.routine_begin(0x20)
        lli     t6, 0x0008                  // ~
        sw      a0, 0x0020(sp)              // ~
        sw      t6, 0x0010(sp)              // original begin logic

        // lw      a1, 0x0084(a0)              // get player struct
        // lw      a2, 0x0008(a1)              // get character id
        // lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        // beql    a1, a2, _change_action      // if Kirby, load alternate action ID
        // lli     a1, Kirby.Action.KNUX_Dive_Air_Begin
        // lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        // beql    a1, a2, _change_action      // if J Kirby, load alternate action ID
        // lli     a1, Kirby.Action.KNUX_Dive_Air_Begin

        lli     a1, CBMKnuckles.Action.DiveAirBegin // a1 = action id
        _change_action:
        lli     a2, 0x0000                  // a2 = 0 (begin action frame)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        jal     0x800E0830                  // ftMainPlayAnimEventsAll
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        lli     v1, BEGIN                   // ~
        sw      v1, 0x0184(a0)              // temp variable 3 = 0x1(BEGIN)
        // reset fall speed
        lbu     v1, 0x018D(a0)              // v1 = fast fall flag
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        OS.routine_end(0x20)
    }

    // Main subroutine for DiveAirBegin
    scope aerial_main_: {
        OS.routine_begin(0x18)
        li      a1, loop_initial_           // a1(transition subroutine) = loop_initial_
        jal     0x800D9480                  // common main subroutine (transition on animation end)
        lw      t8, 0x014C(a2)              // t8 = kinetic state
        OS.routine_end(0x18)
    }

    // @ Description
    // Subroutine which sets up the movement for the aerial version of Knuckles' neutral special for Dive
    // Temp variable 3 (5C00XXXX):
    // 0x1 = begin
    // 0x2 = apply movement speed
    scope air_move_: {
        // TODO: check what this actually does?
        // a2 = player struct
        // 0x184 in player struct = temp variable 3

        OS.routine_begin(0x18)
        sw      t0, 0x0004(sp)              // ~
        sw      t2, 0x0008(sp)              // ~
        swc1    f0, 0x000C(sp)              // ~
        swc1    f2, 0x0010(sp)              // store t0, t2, f0, f2

        // slow x movement
        lwc1    f0, 0x0048(a2)              // f0 = current x velocity
        lui     t0, SLOWING_SPEED_X         // ~
        mtc1    t0, f2                      // f2 = SLOWING_SPEED_X
        mul.s   f0, f0, f2                  // f0 = x velocity * SLOWING_SPEED_X
        swc1    f0, 0x0048(a2)              // x velocity = (x velocity * SLOWING_SPEED_X)

        _check_begin:
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        lli     t2, BEGIN                   // t2 = BEGIN
        bne     t0, t2, _end                // skip if t0 != BEGIN
        nop

        // slow y movement
        lwc1    f0, 0x004C(a2)              // f0 = current y velocity
        lui     t0, SLOWING_SPEED_Y         // ~
        mtc1    t0, f2                      // f2 = SLOWING_SPEED_Y
        mul.s   f0, f0, f2                  // f0 = x velocity * SLOWING_SPEED_Y
        swc1    f0, 0x004C(a2)              // y velocity = (y velocity * SLOWING_SPEED_Y)

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // ~
        lwc1    f0, 0x000C(sp)              // ~
        lwc1    f2, 0x0010(sp)              // load t0, t2, f0, f2
        OS.routine_end(0x18)
    }

    // @ Description
    // Subroutine which handles physics for Knuckles' aerial Dive special
    // Temp variable 3 (5C00XXXX):
    // 0x1 = begin
    // 0x2 = apply movement speed
    scope air_physics_: {
        // 0x184 in player struct = temp variable 3

        OS.routine_begin(0x18)
        sw      t0, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      a0, 0x0010(sp)              // store t0, t2, a0

        jal     0x800D91EC                  // physics subroutine which prevents player control
        nop

        lw      a0, 0x0010(sp)              // a0 = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t0, 0x0024(a0)              // t0 = current action id
        lli     t2, CBMKnuckles.Action.DiveAirLoop
        beql    t2, t0, _diving             // branch if in Dive Loop
        nop
        // lli     t2, Kirby.Action.KNUX_Dive_Air_Loop // at = action id: Dive Loop (Kirby)
        // beql    t2, t0, _diving             // branch if in Dive Loop
        // nop

        sw      r0, 0x0048(a0)              // x velocity = 0.0
        lw      t0, 0x0184(a0)              // t0 = temp variable 3
        lli     t2, MOVE                    // t2 = MOVE
        bnel    t0, t2, _apply_velocity + 4 // skip if temp variable 3 != MOVE
        lui     t2, AERIAL_INITIAL_Y_SPEED  // rising up y speed

        _diving:
        lui     t0, X_SPEED                 // ~
        mtc1    t0, f2                      // f2 = X_SPEED
        lwc1    f0, 0x0044(a0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        mul.s   f2, f0, f2                  // f2 = X_SPEED * direction
        lui     t2, Y_SPEED                 // diving down y speed

        _apply_velocity:
        swc1    f2, 0x0048(a0)              // x velocity = X_SPEED
        sw      t2, 0x004C(a0)              // y velocity = Y_SPEED or AERIAL_INITIAL_Y_SPEED

        _end:
        lw      t0, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      a0, 0x0010(sp)              // load t0, t2, ra, a0
        OS.routine_end(0x18)
    }

    // @ Description
    // Subroutine which handles collision for Knuckles' Dive neutral special
    // Transitions into the down special landing action when temp variable 3 = MOVE,
    // otherwise lands normally.
    scope air_collision_: {
        OS.routine_begin(0x18)
        sw      a0, 0x0010(sp)              // store a0

        lw      a1, 0x0084(a0)              // a1 = player struct
        lw      v0, 0x014C(a1)              // v0 = kinetic state
        bnezl   v0, _aerial                 // branch if kinetic state != grounded
        nop

        _grounded:
        jal     0x800DDF44                  // grounded collision subroutine
        nop
        b       _end                        // branch to end
        nop

        _aerial:
        lw      v1, 0x0024(a1)              // current action
        lli     at, CBMKnuckles.Action.DiveAirLoop
        beql    at, v1, _main_collision     // branch if doing aerial loop action
        nop
        // lli     at, Kirby.Action.KNUX_Dive_Air_Loop // Dive loop action (Kirby)
        // beql    at, v1, _main_collision     // branch if doing aerial loop action
        // nop

        lw      v0, 0x184(a1)               // v0 = temp variable 3
        lli     t0, MOVE                    // t0 = MOVE
        beql    t0, v0, _main_collision     // branch if temp variable 3 = MOVE
        nop

        // If Knuckles is not in the ground pound motion, run a normal aerial collision subroutine
        // instead.
        jal     0x800DE99C                  // aerial collision subroutine
        nop
        b       _end                        // branch to end
        nop

        _main_collision:
        li      a1, begin_landing_          // a1 = begin_landing_
        jal     0x800DE6E4                  // general air collision?
        lw      a0, 0x0010(sp)              // load a0
        jal     0x800DE87C                  // check ledge/floor collision?
        lw      a0, 0x0010(sp)              // load a0
        beql    v0, r0, _end                // skip if !collision
        nop
        lw      a0, 0x0010(sp)              // load a0
        lw      a1, 0x0084(a0)              // a1 = player struct
        lhu     a2, 0x00D2(a1)              // a2 = collision flags?
        andi    a2, a2, 0x3000              // bitmask
        beql    a2, r0, _end                // skip if !ledge_collision
        nop
        jal     0x80144C24                  // ledge grab subroutine
        nop

        _end:
        OS.routine_end(0x18)
    }

    // @ Description
    // Initial Subroutine for Knuckles' DiveAirLoop
    // Changes action, and sets up initial variable values.
    scope loop_initial_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        addiu   t6, r0, 0x0001              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      t6, 0x0010(sp)              // original begin logic

        // lw      a1, 0x0084(a0)              // get player struct
        // lw      a2, 0x0008(a1)              // get character id
        // lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        // beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        // lli     a1, Kirby.Action.KNUX_Dive_Air_Loop
        // lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        // beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        // lli     a1, Kirby.Action.KNUX_Dive_Air_Loop

        lli     a1, CBMKnuckles.Action.DiveAirLoop // a1 = action id
        _change_action:
        lli     a2, 0x0000                  // a2 = 0 (begin action frame)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a2 = float: 1.0

        jal     0x800E0830                  // ftMainPlayAnimEventsAll
        lw      a0, 0x0020(sp)              // a0 = player object

        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 2 = 0

        lw      ra, 0x001C(sp)              // ~
        jr      ra                          // original return logic
        addiu   sp, sp, 0x0020              // ~
    }
}

scope CBMKnucklesDSP {
    constant MAX_CHARGE(21)
    constant MAX_CHARGE_AIR(15)
    constant BASE_SPEED(0x4204)             // current setting - float: 33.0
    constant MIN_SPEED(0x4120)              // current setting - float: 10.0
    constant JUMP_SPEED(0x4282)             // current setting - float: 65.0
    constant BASE_SPEED_SS(0x428C)          // current setting (Super Knuckles) - float: 70.0
    constant MIN_SPEED_SS(0x41C8)           // current setting (Super Knuckles) - float: 25.0
    constant JUMP_SPEED_SS(0x4296)          // current setting (Super Knuckles) - float: 75.0
    constant GRAVITY(0x4000)                // current setting - float: 2.0
    constant SLOPE_ACCELERATION(0x4060)     // current setting - float: 3.5
    constant MAX_FALL_SPEED(0x4270)         // current setting - float: 60.0
    constant AIR_FRICTION(0x4040)           // current setting - float: 3.0
    constant GROUND_TRACTION(0x3E80)        // current setting - float: 0.25

    constant WALL_COLLISION_L(0x0001)       // bitmask for wall collision
    constant WALL_COLLISION_R(0x0020)       // bitmask for wall collision

    // @ Description
    // Initial subroutine for DSP_Ground_Charge.
    scope ground_charge_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lli     a1, CBMKnuckles.Action.DSP_Ground_Charge // a1(action id) = DSP_Ground_Charge
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        lui     t0, 0x3F00                  // ~
        mtc1    t0, f0                      // f0 = 0.5
        lwc1    f2, 0x0060(a0)              // f2 = x velocity
        mul.s   f2, f2, f0                  // ~
        swc1    f2, 0x0060(a0)              // multiply x velocity by 0.5 and update
        sw      r0, 0x0B18(a0)              // charge level = 0
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Initial subroutine for DSP_Air_Charge.
    scope air_charge_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lli     a1, CBMKnuckles.Action.DSP_Air_Charge // a1(action id) = DSP_Air_Charge
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        lui     t0, 0x3EA0                  // ~
        mtc1    t0, f0                      // f0 = 0.31
        lwc1    f2, 0x004C(a0)              // f2 = y velocity
        mul.s   f2, f2, f0                  // ~
        swc1    f2, 0x004C(a0)              // multiply y velocity by 0.31 and update
        lbu     v1, 0x018D(a0)              // v1 = fast fall flag
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        sw      r0, 0x0B18(a0)              // charge level = 0
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Main subroutine for DSP_Ground_Charge
    scope ground_charge_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // ~
        sw      s0, 0x001C(sp)              // store ra, a0, s0
        lw      s0, 0x0084(a0)              // s0 = player struct

        // check if the a or b button are pressed to add charge level
        _check_button_press:
        lhu     t6, 0x01BE(s0)              // t6 = buttons_pressed
        andi    t6, t6, Joypad.B | Joypad.A // t6 != 0 if B or A is pressed, else t6 = 0
        beqz    t6, _check_charge_variable  // skip if B or A are not pressed
        nop

        // if either the a or b button was pressed, add three charge levels and play a sound
        lw      t6, 0x0B18(s0)              // t6 = charge level
        addiu   t6, t6, 0x0003              // increase charge level by 2
        sw      t6, 0x0B18(s0)              // store updated charge level
        lli     a1, 0x3D8                   // a1 = SPINDASH_CHARGE FGM

        lw      t6, 0x0008(s0)              // t6 = Character ID
        if {defined Character.CHARACTER_ADDED_KNUCKLES} {
            lli     at, Character.id.KNUCKLES // at = Classic Knuckles Char ID
            beql    t6, at, pc() + 8        // Branch if not Classic Knuckles
            lli     a1, 0x3DE               // ...a1 = CLASSIC_SPINDASH_CHARGE FGM
        }
        if {defined Character.CHARACTER_ADDED_CBKNUCKLES} {
            lli     at, Character.id.CBKNUCKLES // at = Classic Cowboy Knuckles Char ID
            beql    t6, at, pc() + 8        // Branch if not Classic Cowboy Knuckles
            lli     a1, 0x3DE               // ...a1 = CLASSIC_SPINDASH_CHARGE FGM
        }

        jal     0x800E8190                  // play fgm once
        or      a0, s0, r0                  // a0 = player struct

        // increase charge level by the value of temp variable 2 when it is set
        _check_charge_variable:
        lw      t6, 0x0B18(s0)              // t6 = charge level
        lw      t7, 0x0180(s0)              // t7 = temp variable 2
        addu    t6, t6, t7                  // t7 = charge level + variable value
        sw      t6, 0x0B18(s0)              // store updated charge level
        sw      r0, 0x0180(s0)              // reset temp variable 2

        // prevent the charge level from exceeeding a maximum value
        _limit_charge_level:
        lw      t6, 0x0B18(s0)              // t6 = charge level
        lli     t7, MAX_CHARGE              // t7 = MAX_CHARGE
        slt     at, t7, t6                  // at = 1 if MAX_CHARGE < charge level, else at = 0
        bnel    at, r0, _check_movement     // branch if charge level exceeds MAX_CHARGE...
        sw      t7, 0x0B18(s0)              // ...and set charge level to MAX_CHARGE

        // check if movement should begin
        // values for temp variable 1:
        // 0 - can't begin movement
        // 1 - can begin movement
        // 2 - force movement
        _check_movement:
        lw      t6, 0x017C(s0)              // t6 = temp variable 1
        beqz    t6, _end                    // skip if temp variable 1 = 0
        lli     at, 0x0001                  // at = 1
        bne     t6, at, _begin_movement     // force movement if temp variable 1 != 1
        nop

        // check if the stick is being held down
        _check_stick:
        lb      t6, 0x01C3(s0)              // t6 = stick_y
        slti    at, t6, -39                 // at = 1 if stick_y < -39, else at = 0
        bnez    at, _end                    // skip if stick_y =< -40
        nop

        // check if knuckles is holding b
        _check_b_held:
        lh      t6, 0x01BC(s0)              // t7 = buttons_held
        andi    t6, t6, Joypad.B            // t7 = 0x0020 if (B_HELD); else t7 = 0
        bnez    t6, _end                    // skip if (B_HELD)
        nop

        // if we're here, then transition into DSP_Ground_Move
        _begin_movement:
        jal     ground_move_initial_
        lw      a0, 0x0018(sp)              // a0 = player object

        _end:
        lw      ra, 0x0014(sp)              // ~
        lw      s0, 0x001C(sp)              // load ra, s0
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Main subroutine for DSP_Air_Charge
    scope air_charge_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // ~
        sw      s0, 0x001C(sp)              // store ra, a0, s0
        lw      s0, 0x0084(a0)              // s0 = player struct

        // check if the a or b button are pressed to add charge level
        _check_button_press:
        lhu     t6, 0x01BE(s0)              // t6 = buttons_pressed
        andi    t6, t6, Joypad.B | Joypad.A // t6 != 0 if B or A is pressed, else t6 = 0
        beqz    t6, _check_charge_variable  // skip if B or A are not pressed
        nop

        // if either the a or b button was pressed, add three charge levels and play a sound
        lw      t6, 0x0B18(s0)              // t6 = charge level
        addiu   t6, t6, 0x0003              // increase charge level by 3
        sw      t6, 0x0B18(s0)              // store updated charge level
        lli     a1, 0x3D8                   // a1 = SPINDASH_CHARGE FGM

        lw      t6, 0x0008(s0)              // t6 = Character ID
        if {defined Character.CHARACTER_ADDED_KNUCKLES} {
            lli     at, Character.id.KNUCKLES   // at = Classic Knuckles Char ID
            beql    t6, at, pc() + 8        // Branch if not Classic Knuckles
            lli     a1, 0x3DE               // ...a1 = CLASSIC_SPINDASH_CHARGE FGM
        }
        if {defined Character.CHARACTER_ADDED_CBKNUCKLES} {
            lli     at, Character.id.CBKNUCKLES// at = Classic Cowboy Knuckles Char ID
            beql    t6, at, pc() + 8        // Branch if not Classic Cowboy Knuckles
            lli     a1, 0x3DE               // ...a1 = CLASSIC_SPINDASH_CHARGE FGM
        }

        jal     0x800E8190                  // play fgm once
        or      a0, s0, r0                  // a0 = player struct

        // increase charge level by the value of temp variable 2 when it is set
        _check_charge_variable:
        lw      t6, 0x0B18(s0)              // t6 = charge level
        lw      t7, 0x0180(s0)              // t7 = temp variable 2
        addu    t6, t6, t7                  // t7 = charge level + variable value
        sw      t6, 0x0B18(s0)              // store updated charge level
        sw      r0, 0x0180(s0)              // reset temp variable 2

        // prevent the charge level from exceeeding a maximum value
        _limit_charge_level:
        lw      t6, 0x0B18(s0)              // t6 = charge level
        lli     t7, MAX_CHARGE_AIR          // t7 = MAX_CHARGE_AIR
        slt     at, t7, t6                  // at = 1 if MAX_CHARGE_AIR < charge level, else at = 0
        bnel    at, r0, _check_cancel       // branch if charge level exceeds MAX_CHARGE_AIR...
        sw      t7, 0x0B18(s0)              // ...and set charge level to MAX_CHARGE_AIR

        // check if cancel should begin
        // values for temp variable 1:
        // 0 - can't begin cancel
        // 1 - can begin cancel
        // 2 - force cancel
        _check_cancel:
        lw      t6, 0x017C(s0)              // t6 = temp variable 1
        beqz    t6, _end                    // skip if temp variable 1 = 0
        lli     at, 0x0001                  // at = 1
        bne     t6, at, _begin_cancel       // force cancel if temp variable 1 != 1
        nop

        // check if the stick is being held down
        _check_stick:
        lb      t6, 0x01C3(s0)              // t6 = stick_y
        slti    at, t6, -39                 // at = 1 if stick_y < -39, else at = 0
        bnez    at, _end                    // skip if stick_y =< -40
        nop

        // check if knuckles is holding b
        _check_b_held:
        lh      t6, 0x01BC(s0)              // t7 = buttons_held
        andi    t6, t6, Joypad.B            // t7 = 0x0020 if (B_HELD); else t7 = 0
        bnez    t6, _end                    // skip if (B_HELD)
        nop

        // if we're here, then transition into DSP_Air_End
        _begin_cancel:
        jal     air_end_initial_
        lw      a0, 0x0018(sp)              // a0 = player object

        _end:
        lw      ra, 0x0014(sp)              // ~
        lw      s0, 0x001C(sp)              // load ra, s0
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Collision subroutine for DSP_Ground_Charge.
    scope ground_charge_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_charge_transition_  // a1(transition subroutine) = air_charge_transition_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Collision subroutine for DSP_Air_Charge.
    scope air_charge_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_charge_transition_ // a1(transition subroutine) = ground_charge_transition_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which transitions to DSP_Ground_Charge or DSP_Ground_Move.
    scope ground_charge_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct


        // if Knuckles has built enough charge, then allow movement to begin instantly upon hitting the ground
        _check_charge:
        lw      a0, 0x0034(sp)              // a0 = player struct
        lw      t6, 0x0B18(a0)              // t6 = charge level
        sltiu   at, t6, 6                   // at = 1 if charge level < 6, else at = 0
        bnez    at, _transition_to_charge   // if charge level is less than 6, then don't begin movement
        nop

        // if we're here, then transition into DSP_Ground_Move
        _begin_movement:
        jal     ground_move_initial_
        lw      a0, 0x0038(sp)              // a0 = player object
        b       _end                        // branch to end
        nop

        _transition_to_charge:
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, CBMKnuckles.Action.DSP_Ground_Charge // a1(action id) = DSP_Ground_Charge
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0


        _end:
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0050              // deallocate stack space
    }

    // @ Description
    // Subroutine which transitions to DSP_Air_Charge.
    scope air_charge_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, CBMKnuckles.Action.DSP_Air_Charge // a1(action id) = DSP_Air_Charge
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0034(sp)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0050              // deallocate stack space
    }

    // @ Description
    // Initial subroutine for DSP_Ground_Move
    scope ground_move_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lli     a1, CBMKnuckles.Action.DSP_Ground_Move // a1(action id) = DSP_Ground_Move
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     at, BASE_SPEED              // ~
        _move_base:
        mtc1    at, f2                      // f2 = BASE_SPEED
        lw      at, 0x0B18(a0)              // ~
        sll     at, at, 0x2                 // ~
        mtc1    at, f4                      // ~
        cvt.s.w f4, f4                      // f4 = charge level * 4
        add.s   f2, f2, f4                  // f2 = BASE_SPEED + (charge level * 4)
        swc1    f2, 0x0060(a0)	            // ground x velocity = BASE_SPEED + (charge level * 4)
        lwc1    f4, 0x0044(a0)              // ~
        cvt.s.w f4, f4                      // f4 = DIRECTION
        mul.s   f2, f2, f4                  // f2 = ground x velocity * DIRECTION
        swc1    f2, 0x0048(a0)              // x velocity = ground x velocity * DIRECTION
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Initial subroutine for DSP_Air_Move
    scope air_move_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0018(sp)              // a0 = player object
        lli     a1, CBMKnuckles.Action.DSP_Air_Move // a1(action id) = DSP_Air_Move
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main subroutine for DSP_Ground_Move
    scope ground_move_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // ~
        sw      s0, 0x001C(sp)              // store ra, a0, s0
        lw      s0, 0x0084(a0)              // s0 = player struct

        // adjust knuckles's speed based on the angle of the slope he's spinning on
        jal     0x80161478                  // f0 = slope angle
        or      a0, s0, r0                  // a0 = player struct
        jal     0x800303F0                  // f0 = sin(f12)
        mov.s   f12, f0                     // f12 = slope angle
        lui     at, SLOPE_ACCELERATION      // ~
        mtc1    at, f2                      // f2 = SLOPE_ACCELERATION
        lwc1    f4, 0x0044(s0)              // ~
        cvt.s.w f4, f4                      // f4 = DIRECTION
        neg.s   f4, f4                      // f4 = -DIRECTION
        mul.s   f2, f2, f0                  // f2 = SLOPE_ACCELERATION * sin(slope angle)
        mul.s   f2, f2, f4                  // f2 = speed difference = (SLOPE_ACCELERATION * sin(slope angle)) * -DIRECTION
        lwc1    f4, 0x0060(s0)              // f4 = ground x velocity
        add.s   f4, f4, f2                  // f4 = current x velocity + calculated speed difference
        swc1    f4, 0x0060(s0)              // update ground x velocity

        // adjust the animation speed based on knuckles's movement speed
        lui     at, 0x41A0                  // ~
        mtc1    at, f2                      // f2 = 20
        add.s   f4, f4, f2                  // f2 = ground x velocity + 20
        lui     at, 0x3C22                  // ~
        mtc1    at, f2                      // f2 = 0.01
        mul.s   f2, f2, f4                  // f2 = FSM = (ground x velocity + 20) * 0.01
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      t0, 0x0074(a0)              // t0 = top joint struct
        lw      t1, 0x0078(t0)              // t1 = top joint frame speed multiplier
        lui     t2, 0x3F80                  // t2 = 1.0
        beql    t1, t2, pc() + 8            // if top joint fsm = 1.0...
        addiu   t1, t2, 0x0001              // ...set top joint fsm to 3F800001 so it resets on action change
        sw      t1, 0x0078(t0)              // update top joint FSM
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x08F8(t0)              // t1 = joint 0 struct
        swc1    f2, 0x0078(t1)              // set joint 0 FSM
        lw      t1, 0x08FC(t0)              // t1 = joint 1 struct
        swc1    f2, 0x0078(t1)              // set joint 1 FSM

        // check if knuckles's speed is below minimum
        lw      t8, 0x0008(s0)              // t8 = character id
        lui     t0, MIN_SPEED               // t0 = MIN_SPEED
        mtc1    t0, f2                      // f2 = MIN_SPEED
        lwc1    f4, 0x0060(s0)              // f4 = ground x velocity
        c.le.s  f4, f2                      // ~
        nop                                 // ~
        bc1fl   _jump_check                 // branch if MIN_SPEED =< ground x velocity
        nop

        // if we're here, knuckles is below minimum speed so transition to DSP_Ground_End
        _end_movement:
        jal     ground_end_initial_
        lw      a0, 0x0018(sp)              // a0 = player object
        b       _end                        // branc to end
        nop

        _jump_check:
        jal     0x8013F474                  // check jump (returns 0 for no jump)
        or      a0, s0, r0                  // a0 = player struct
        beq     v0, r0, _end                // skip if !jump
        nop

        // if we're here then knuckles has input a jump, so transition to DSP_Air_Jump
        jal     air_jump_initial_
        lw      a0, 0x0018(sp)              // a0 = player object

        _end:
        lw      ra, 0x0014(sp)              // ~
        lw      s0, 0x001C(sp)              // load ra, s0
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Main subroutine for DSP_Air_Move and DSP_Air_Jump.
    scope air_move_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0

        jal     0x800D94E8                  // main subroutine which transitions to fall on animation end
        nop

        // adjust the animation speed based on knuckles's movement speed
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      t8, 0x0084(a0)              // t8 = player struct
        lwc1    f4, 0x0048(t8)              // ~
        mul.s   f4, f4, f4                  // ~
        lwc1    f6, 0x004C(t8)              // ~
        mul.s   f6, f6, f6                  // ~
        add.s   f4, f4, f6                  // ~
        sqrt.s  f4, f4                      // f4 = absolute speed
        lui     at, 0x41A0                  // ~
        mtc1    at, f2                      // f2 = 20
        add.s   f4, f4, f2                  // f2 = absolute speed + 20
        lui     at, 0x3C22                  // ~
        mtc1    at, f2                      // f2 = 0.01
        mul.s   f2, f2, f4                  // f2 = FSM = (absolute speed + 20) * 0.01
        lw      t0, 0x0074(a0)              // t0 = top joint struct
        lw      t1, 0x0078(t0)              // t1 = top joint frame speed multiplier
        lui     t2, 0x3F80                  // t2 = 1.0
        beql    t1, t2, pc() + 8            // if top joint fsm = 1.0...
        addiu   t1, t2, 0x0001              // ...set top joint fsm to 3F800001 so it resets on action change
        sw      t1, 0x0078(t0)              // update top joint FSM
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x08F8(t0)              // t1 = joint 0 struct
        swc1    f2, 0x0078(t1)              // set joint 0 FSM
        lw      t1, 0x08FC(t0)              // t1 = joint 1 struct
        swc1    f2, 0x0078(t1)              // set joint 1 FSM

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Interrupt subroutine for DSP_Air_Move and DSP_Air_Jump.
    scope air_move_interrupt_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      t6, 0x0084(a0)              // t6 = player struct
        lw      t6, 0x0184(t6)              // t6 = temp variable 3
        beqz    t6, _end                    // skip if temp variable 3 is not set
        nop

        // if we're here then Knuckles is now considered actionable, so allow interrupts
        _interrupt:
        jal      0x8013F660                 // jump interrupt subroutine
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Physics subroutine for DSP_Ground_Move
    // Copy of subroutine 0x800D8BB4, loads a hard-coded traction value instead of the character's
    // traction value.
    scope ground_move_physics_: {
        // Copy the first 10 lines of subroutine 0x800D8BB4
        OS.copy_segment(0x543B4, 0x28)
        // Replace original lines which load the base friction from the friction table
        constant UPPER(Surface.friction_table >> 16)
        constant LOWER(Surface.friction_table & 0xFFFF)
        if LOWER > 0x7FFF {
            lui     at, (UPPER + 0x1)
        } else {
            lui     at, UPPER
        }
        addu    at, at, t9
        lwc1    f4, LOWER(at)
        // Replace original line which loads the character's grounded tracion value
        // lwc1 f6, 0x0024(v0)              // replaced line
        lui     a1, GROUND_TRACTION         // ~
        mtc1    a1, f6                      // f6 = GROUND_TRACTION
        // Copy the last 10 lines of subroutine 0x800D8BB4
        OS.copy_segment(0x543EC, 0x28)
    }

    // @ Description
    // Physics subroutine for DSP_Air_Move and DSP_Air_Jump.
    // Restores player control when temp variable 3 = 1
    scope air_movement_physics_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      t6, 0x0084(a0)              // t6 = player struct
        lw      t6, 0x0184(t6)              // t6 = temp variable 3
        li      t8, 0x800D90E0              // t8 = physics subroutine which allows player control
        bnez    t6, _subroutine             // branch if temp variable 3 is set
        nop

        // if we're here then Knuckles is still locked into movement, so use a special physics subroutine
        li      t8, air_move_physics_

        // if we're here then Knuckles is now considered actionable, so do a normal transition on landing
        _subroutine:
        jalr    t8                          // run physics subroutine
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Physics subroutine for non-actionable aerial movement
    // Modified version of subroutine 0x800D91EC.
    scope air_move_physics_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      s1, 0x0018(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        lw      s0, 0x0084(a0)              // ~
        lw      s1, 0x09C8(s0)              // ~
        or      a0, s0, r0                  // original lines
        or      a3, s1, r0                  // a3
        lui     a1, GRAVITY                 // a1 = GRAVITY
        jal     0x800D8D68                  // apply gravity/fall speed
        lui     a2, MAX_FALL_SPEED          // a2 = MAX_FALL_SPEED

        // Subroutine 0x800D9074 applies air friction. Usually, air friction is loaded from
        // 0x0054(a1), with a1 being the attribute pointer for the character. In this case, a
        // different air friction value is stored at 0x0054(sp) and then the stack pointer is
        // passed to a1 for subroutine 0x800D9074.
        or      a0, s0, r0                  // a0 = player struct
        addiu   sp, sp,-0x0058              // allocate stack space
        lui     a1, AIR_FRICTION            // a1 = AIR_FRICTION
        sw      a1, 0x0054(sp)              // store AIR_FRICTION
        jal     0x800D9074                  // apply air friction
        or      a1, sp, r0                  // a1 = stack pointer
        addiu   sp, sp, 0x0058              // deallocate stack space
        lw      ra, 0x001C(sp)              // ~
        lw      s1, 0x0018(sp)              // ~
        lw      s0, 0x0014(sp)              // ~
        jr      ra                          // ~
        addiu   sp, sp, 0x0020              // original return logic
    }

    // @ Description
    // Collision subroutine for DSP_Ground_Move.
    scope ground_move_collision_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_move_initial_       // a1(transition subroutine) = air_move_initial_
        jal     0x800DDDDC                  // common ground collision subroutine (transition on no floor, slide-off)
        sw      a0, 0x0018(sp)              // store a0

        beqz    v0, _end                    // skip if air transition occured
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lhu     a1, 0x00CC(a0)              // a1 = collision flags
        lw      t1, 0x0044(a0)              // t0 = direction
        bgezl   t1, _wall_collision         // branch if direction = right
        andi    a1, a1, WALL_COLLISION_L    // a1 = collision flags & WALL_COLLISION_L
        andi    a1, a1, WALL_COLLISION_R    // a1 = collision flags & WALL_COLLISION_R

        _wall_collision:
        beql    a1, r0, _end                // skip if !WALL_COLLISION
        nop

        // if Knuckles is colliding with a wall, end movement
        jal     ground_end_initial_
        lw      a0, 0x0018(sp)              // a0 = player object

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Collision subroutine for for DSP_Air_Move and DSP_Air_Jump.
    scope air_move_collision_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      t6, 0x0084(a0)              // t6 = player struct
        lw      t6, 0x0184(t6)              // t6 = temp variable 3
        bnez    t6, _interrupt              // branch if temp variable 3 is set
        nop

        // if we're here then Knuckles is still locked into movement, so transition to DSP_Ground_Move
        _transition:
        li      a1, ground_move_transition_ // a1(transition subroutine) = ground_move_transition_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        b       _end                        // end subroutine
        nop

        // if we're here then Knuckles is now considered actionable, so do a normal transition on landing
        _interrupt:
        jal      0x800DE978                 // air collision subroutine (cancel on landing)
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Subroutine which transitions to DSP_Ground_Move.
    scope ground_move_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, CBMKnuckles.Action.DSP_Ground_Move // a1(action id) = DSP_Ground_End
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0050              // deallocate stack space
    }


    // @ Description
    // Initial subroutine for DSP_Air_Jump
    scope air_jump_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0018(sp)              // a0 = player object
        lli     a1, CBMKnuckles.Action.DSP_Air_Jump // a1(action id) = DSP_Air_Move
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0

        // apply jump velocity
        lw      a0, 0x0018(sp)              // load a0
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     at, JUMP_SPEED              // at = JUMP_SPEED

        _move_jump:
        sw      at, 0x004C(a0)              // y velocity = JUMP_SPEED
        // create gfx
        lw      a0, 0x0078(a0)              // a0 = player x/y/z pointer
        ori     a1, r0, 0x0001              // a1 = 0x1
        jal     0x800FF3F4                  // jump smoke graphic
        lui     a2, 0x3F80                  // a2 = float: 1.0

        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Initial subroutine for DSP_Ground_End.
    scope ground_end_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lli     a1, CBMKnuckles.Action.DSP_Ground_End // a1(action id) = DSP_Ground_End
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Initial subroutine for DSP_Air_End.
    scope air_end_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lli     a1, CBMKnuckles.Action.DSP_Air_End // a1(action id) = DSP_Air_End
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Collision subroutine for DSP_Ground_End.
    scope ground_end_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_end_transition_     // a1(transition subroutine) = air_end_transition_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Collision subroutine for DSP_Air_End.
    scope air_end_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_end_transition_  // a1(transition subroutine) = ground_end_transition_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which transitions to DSP_Ground_End.
    scope ground_end_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, CBMKnuckles.Action.DSP_Ground_End // a1(action id) = DSP_Ground_End
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0050              // deallocate stack space
    }

    // @ Description
    // Subroutine which transitions to DSP_Air_End.
    scope air_end_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, CBMKnuckles.Action.DSP_Air_End // a1(action id) = DSP_Air_End
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0034(sp)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0050              // deallocate stack space
    }
}
}