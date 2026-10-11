// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(flashbang_stage_setting_)
constant SHOW_GFX_WHEN_SPAWNED(OS.FALSE)
constant PICKUP_ITEM_MAIN(0)
constant PICKUP_ITEM_INIT(0)
constant DROP_ITEM(0)
constant THROW_ITEM(0)
constant PLAYER_COLLISION(0)

// @ Description
// Offset to item in file.
constant FILE_OFFSET(0x40)

constant DAMAGE_TYPE(Damage.id.FIRE)
constant INITIAL_DAMAGE(0)
constant EXPLODE_DAMAGE(17)
constant EXPLODE_SIZE(0x43D4) // 424

constant INITIAL_FUSE_TIME(1600)
constant DAMAGE_FUSE_TIME(1)

scope flashbang_attributes {
    constant DURATION(0x0000)
    constant GRAVITY(0x0004)
    constant MAX_SPEED(0x0008)
    constant BOUNCE(0x000C)
    constant ANGLE(0x0010)
    constant ROTATION(0x0014)
    struct:
    dw INITIAL_FUSE_TIME                    // 0x0000 - duration (int)
    float32 3.6                             // 0x0004 - gravity
    float32 63                              // 0x0008 - max speed
    float32 0                               // 0x000C - bounce multiplier
    float32 0.0                             // 0x0010 - angle
    float32 0.02                            // 0x0014 - rotation speed
    dw 0                                    // 0x0018 - frames set (int)
}

scope VARIABLES: {
    constant STICKY_PLAYER_STRUCT(0x350)
    constant FRAMES_SET(0x354) // counter for how much time has passed since it was set down (ground, wall, player)
}

OS.align(16)
item_info_array:
constant ITEM_INFO_ARRAY_ORIGIN(origin())
dw 0x00000000                           // 0x00 - item ID placeholder
dw Character.SNAKE_file_6_ptr           // 0x04 - address of file pointer
dw Snake.FILE_OFFSETS.MERGED_FILERESOURCE_6_0 // 0x08 - offset to item footer
dw 0x1B000000                           // 0x0C - ? either 0x1B000000 or 0x1C000000 - possible argument
dw 0                                    // 0x10 - ?
flashbang_item_states:
// state 0 - main/aerial
dw flashbang_main_                        // 0x14 - state 0 main
dw flashbang_collision_                   // 0x18 - state 0 collision
dw 0                                    // 0x1C - state 0 hitbox collision w/ hurtbox
dw 0                                    // 0x20 - state 0 hitbox collision w/ shield
dw 0                                     // 0x24 - state 0 hitbox collision w/ shield edge
dw 0                                      // 0x28 - state 0 unknown (maybe absorb)
dw 0                                     // 0x2C - state 0 hitbox collision w/ reflector
dw 0                                    // 0x30 - state 0 hurtbox collision w/ hitbox
// state 1 - resting
dw flashbang_main_                        // 0x34 - state 1 main
dw flashbang_resting_collision_           // 0x38 - state 1 collision
dw 0                                    // 0x3C - state 1 hitbox collision w/ hurtbox
dw 0                                    // 0x40 - state 1 hitbox collision w/ shield
dw 0                                   // 0x44 - state 1 hitbox collision w/ shield edge
dw 0                                    // 0x48 - state 1 unknown (maybe absorb)
dw 0                                   // 0x4C - state 1 hitbox collision w/ reflector
dw 0                                    // 0x50 - state 1 hurtbox collision w/ hitbox
// state 2 - explosion
dw flashbang_exploding_main_              // 0xD4 - state 2 main
dw 0                                    // 0xD8 - state 2 collision
dw 0                                    // 0xDC - state 2 hitbox collision w/ hurtbox
dw 0                                    // 0xE0 - state 2 hitbox collision w/ shield
dw 0                                    // 0xE4 - state 2 hitbox collision w/ shield edge
dw 0                                    // 0xE8 - state 2 unknown (maybe absorb)
dw 0                                    // 0xEC - state 2 hitbox collision w/ reflector
dw 0                                    // 0xF0 - state 2 hurtbox collision w/ hitbox
OS.align(16)

// @ Description
// based on damage colour command @ 0x8012DB70
flash_array_:
dw 0x24000000     // 0x00 - ?
dw 0xDDDDDD88     // 0x04 - initial colour (white)
dw 0x28000008     // 0x08 - determines length of colour transition (8 frames, second half word)
dw 0xFFFFFF00     // 0x0C - target colour (white, no alpha)
dw 0x04000004     // 0x10 - determines total length of flash (8 frames, second half word)
dw 0x00000000     // 0x14 - end of command

// @ Description
// Subroutine which sets up initial properties of flashbang.
// a0 - player object
// a1 - item info array
// a2 - x/y/z coordinates to create item at
// a3 - unknown x/y/z offset
scope flashbang_stage_setting_: {
    addiu   sp, sp,-0x0060                  // allocate stack space
    sw      s0, 0x0020(sp)                  // ~
    sw      s1, 0x0024(sp)                  // ~
    sw      ra, 0x0028(sp)                  // store s0, s1, ra
    sw      a0, 0x0038(sp)                  // 0x0038(sp) = player object
    sw      a2, 0x003C(sp)                  // 0x003C(sp) = original x/y/z
    jal     0x8016E174                      // create item
    sw      r0, 0x0010(sp)                  // argument 4(unknown) = 0
    beqz    v0, _end                        // end if no item was created
    or      s0, v0, r0                      // s0 = item object
    li      s1, flashbang_attributes.struct   // s1 = flashbang_attributes.struct

    // item is created
    sw      v0, 0x0040(sp)                  // 0x0040(sp) = item object
    lw      v1, 0x0084(v0)                  // v1 = item special struct
    sw      v1, 0x002C(sp)                  // 0x002C(sp) = item special struct
    lw      a0, 0x0074(v0)                  // a0 = item first joint (joint 0)
    sw      a0, 0x0030(sp)                  // 0x0030(sp) = item joint 0
    lli     a1, 0x002E                      // a1(render routine?) = 0x2E
    jal     0x80008CC0                      // set up render routine?
    or      a2, r0, r0                      // a2 (unknown) = 0
    lw      a0, 0x0030(sp)                  // ~
    lw      a0, 0x0010(a0)                  // a0 = item second joint (joint 1)
    lli     a1, 0x002E                      // a1(render routine?) = 0x2E
    jal     0x80008CC0                      // set up render routine?
    or      a2, r0, r0                      // a2 (unknown) = 0

    ecb_size: {
        lw      v1, 0x002C(sp)          // v1 = item special struct
        sw      r0, 0x0074(v1)          // ecb center = 0
        lui     at, 0x41A0              // at = 20.0
        sw      at, 0x0070(v1)          // ecb top
        lui     at, 0xC1A0              // at = -20.0
        sw      at, 0x0078(v1)          // ecb bottom
        lui     at, 0x41A0              // at = 20.0
        sw      at, 0x007C(v1)          // ecb width
    }

    // set scale
    lw v0, 0x0040(sp) // v0 = item object
    lw t0, 0x0074(v0) // t0 = item first joint (joint 0)
    lui at, 0x3ECC // at = ~0.4
    sw at, 0x40(t0) // set X scale
    sw at, 0x44(t0) // set Y scale
    sw at, 0x48(t0) // set Z scale

    _flip_graphic: {
        lw t6, 0x0038(sp) // ~
        lw t6, 0x0084(t6) // t6 = player struct
        lw t6, 0x0044(t6) // t6 = player direction
        addiu at, r0, -1
        bne t6, at, _flip_graphic_end
        nop
        // negate X scale (flip graphic)
        lwc1 f2, 0x40(t0) // f2 = x scale
        neg.s f2, f2 // f2 = -x scale
        swc1 f2, 0x40(t0) // set x scale to -x scale
    }
    _flip_graphic_end:
    sw t6, 0x0024(v1) // set item direction

    lw      v1, 0x002C(sp)                  // v1 = item special struct
    lbu     t9, 0x0158(v1)                  // ~
    ori     t9, t9, 0x0010                  // ~
    sb      t9, 0x0158(v1)                  // enable unknown bitflag
    lw      t6, flashbang_attributes.DURATION(s1)  // t6 = duration
    sw      t6, 0x02C0(v1)                  // store duration\
    lli     t7, 0x0004                      // ~
    sw      t7, 0x0354(v1)                  // unknown value(bit field?) = 0x00000004

    lw      v1, 0x002C(sp)                  // v1 = item special struct
    sw      r0, 0x002C(v1)                  // x velocity = 0
    sw      r0, 0x0030(v1)                  // y velocity = 0
    sw      r0, 0x0034(v1)                  // z velocity = 0

    lw      a0, 0x0038(sp)                  // a0 = player object
    lw      v1, 0x002C(sp)                  // v1 = item special struct
    sw      a0, 0x0008(v1)                  // set player as projectile owner
    lw      t6, 0x0084(a0)                  // t6 = player struct
    lbu     at, 0x000C(t6)                  // load player team
    sb      at, 0x0014(v1)                  // save player's team to item to prevent damage when team attack is off
    lbu     at, 0x000D(t6)                  // at = player port
    sb      at, 0x0015(v1)                  // store player port for combo ownership
    sw      v1, 0x0ADC(t6)                  // save object address to free space in player struct
    sw      t6, 0x01C4(v1)                  // save player struct to custom variable space in the item special struct

    lw      at, 0x17C(t6) // load sticky player value from player struct's temp variable
    sw      at, VARIABLES.STICKY_PLAYER_STRUCT(v1) // save sticky player struct
    sw      r0, VARIABLES.FRAMES_SET(v1)

    _sticky_sfx_test:
    lw at, VARIABLES.STICKY_PLAYER_STRUCT(v1)
    beqz at, _sticky_sfx_test_end
    nop
    addiu sp,sp,-0x20
    sw a0, 0x10(sp)
    sw v0, 0x14(sp)
    sw v1, 0x18(sp)

    jal 0x800269C0 // play FGM
    addiu a0, r0, 0x2C // FGM id = proximity bomb attach

    or v1, r0, s0 // v1 = item object
    lw t0, 0x74(v1) // item first joint
    sw r0, 0x50(t0) // remove displaylist pointer to make invisible

    lw a0, 0x10(sp)
    lw v0, 0x14(sp)
    lw v1, 0x18(sp)
    addiu   sp,sp,0x20
    _sticky_sfx_test_end:

    sw      r0, 0x0248(v1)                  // disable hurtbox
    sw      r0, 0x010C(v1)                  // disable hitbox
    addiu   at, r0, INITIAL_DAMAGE
    sw      at, 0x0110(v1)                  // set damage to INITIAL_DAMAGE
    lhu     at, 0x02CE(v1)                  // ~
    ori     at, at, 0x0080                  // ~
    // sh      at, 0x02CE(v1)                  // enable bitflag which allows owner's hitboxes to collide with the hurtbox

    // Make projectile not interact with other hitboxes
    lbu at, 0x158(v1)
    andi at, at, 0xFF7F
    sb at, 0x158(v1)

    li      t0, flashbang_attributes.struct   // t0 = flashbang_attributes.struct
    lw      t1, flashbang_attributes.MAX_SPEED(t0)    // t1 = MAX_SPEED
    sw      t1, 0x01C8(v1)                  // max speed = MAX_SPEED
    sw      r0, 0x01CC(v1)                  // rotation direction = 0
    sw      r0, 0x01D0(v1)                  // hitbox refresh timer = 0
    sw      r0, 0x01D4(v1)                  // hitbox collision flag = FALSE
    li      t1, flashbang_blast_zone_         // load flashbang blast zone routine
    sw      t1, 0x0398(v1)                  // save routine to part of item special struct that carries unique blast wall destruction routines

    sw      r0, 0x0100(v1)                  // remove possible reference to character ID use by Bomb

    addiu   at, r0, 0x0001
    sw      r0, 0x0140(v1)                  // overwrite knockback values
    sw      r0, 0x0144(v1)                  // overwrite knockback values
    sw      at, 0x0148(v1)                  // overwrite knockback values

    lw      a1, 0x0038(sp)					// ~
    lw      a1, 0x0084(a1)                  // ~
    addiu   a2, a1, 0x0078                  // a2 = unknown
    lw      a1, 0x0078(a1)                  // a1 = player x/y/z coordinates
    jal     0x800DF058                      // check clipping
    lw      a0, 0x0040(sp)                  // a0 = item object

    scope _check_wall_attach: {
        lw v1, 0x84(s0) // v1 = item struct

        // on creation, check if we're attaching to a wall
        lw at, VARIABLES.STICKY_PLAYER_STRUCT(v1)
        bnez at, _end // if sticky, we skip this check
        nop

        lw t6, 0x01C4(v1) // t6 = owner player struct

        // create two vector 3: one for our position, one for the wall check
        // we're calling functions that work as raycasting
        addiu sp, sp, -0x60 // allocate stack space
        sw s0, 0x40(sp) // save s0
        sw a0, 0x44(sp) // save a0
        sw a1, 0x48(sp) // save a1

        // or a0, r0, t0 // item position x/y/z
        lw a0, 0x74(s0) // t4 = item position at 1C(t1), 20(t1), 24(t1) // t1 = c4 x/y/z position

        // first, base position at 0x20(sp)
        lwc1 f2, 0x1C(a0) // load x
        swc1 f2, 0x20(sp) // store x
        lwc1 f2, 0x20(a0) // load y
        lwc1 f4, 0x74(v1) // Load collision diamond center
        add.s f2, f2, f4 // y += collision diamond center
        swc1 f2, 0x24(sp) // store y
        lwc1 f2, 0x24(a0) // load z
        swc1 f2, 0x28(sp) // store z

        // second, target position at 0x30(sp)
        // calculate total X offset using f8
        lwc1 f8, 0x7C(v1) // Load collision diamond width
        lui at, 0x4248 // 50.0
        mtc1 at, f4
        add.s f8, f8, f4 // f8 += 50.0

        lw at, 0x44(t6) // at = owner facing direction (-1/1)
        mtc1 at, f6 // f6 = owner facing direction
        cvt.s.w f6, f6 // f6 = owner facing direction (float)

        mul.s f8, f8, f6 // f8 = X offset * owner facing direction
        
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
        addiu a3, sp, 0x50 // &stand_line_id - will be set in 0x50
        sw r0, 0x10(sp) // NULL &stand_coll_flags
        addiu at, sp, 0x54 // &angle - will be set in 0x54
        sw at, 0x14(sp) // NULL &angle

        // Use facing direction to determine which wall collision function to call
        lw at, 0x44(t6) // at = facing direction (-1/1)
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
        lw v1, 0x50(sp) // v1 = wall id we found
        addiu t8, sp, 0x54 // t8 = pointer to vec3 with the wall rotation
        lw s0, 0x40(sp) // restore s0
        lw a0, 0x44(sp) // restore a0
        lw a1, 0x48(sp) // restore a1
        addiu   sp, sp, 0x60 // deallocate stack space

        beqz v0, _end // if there was no collision, we end here
        nop
        // if there was a collision, attach
        lw at, 0x84(s0) // at = item struct
        sh v1, 0x2D0(at) // ip->attach_line_id = line id
        
        // ip->is_attach_surface = TRUE;
        lbu t1, 0x2CF(at)
        ori t1, t1, 0x40
        sb t1, 0x2CF(at)

        // here, we have to manually set the rotation
        lwc1 f14,0x0(t8) // wall_angle.x
        jal 0x8001863C // atan2f
        lwc1 f12,0x4(t8) // wall_angle.y

        lui at, 0x8019 // ~
        lwc1 f4, 0xCDB8(at) // f4 = pi
        sub.s f6, f0, f4
        mfc1 t0, f6 // t0 = z rotation to match wall angle
        lw at, 0x74(s0) // load item first joint
        swc1 f6, 0x38(at) // rot.z = angle
        nop

        lw t0, 0x84(s0) // t0 = item struct
        lw t6, 0x0024(t0) // item direction
        _flip_angle: {
            addiu at, r0, -1
            bne t6, at, _flip_angle_end
            nop
            // negate angle when facing left
            lw at, 0x74(s0) // load item first joint
            lwc1 f6, 0x38(at) // rot.z = angle
            neg.s f6, f6 // f6 = -angle
            swc1 f6, 0x38(at) // set item first joint z rotation to -angle
        }
        _flip_angle_end:

        jal flashbang_begin_resting_
        or a0, r0, s0 // a0 = item object
        _end:
    }

    _end:
    or      v0, s0, r0                      // v0 = item object
    lw      s0, 0x0020(sp)                  // ~
    lw      s1, 0x0024(sp)                  // ~
    lw      ra, 0x0028(sp)                  // load s0, s1, ra
    jr      ra                              // return
    addiu   sp, sp, 0x0060                  // deallocate stack space
}

// @ Description
// Main subroutine for the flashbang.
// a0 = item object
scope flashbang_main_: {
    addiu   sp, sp,-0x0040                  // allocate stack space
    sw      s0, 0x0014(sp)                  // ~
    sw      s1, 0x0018(sp)                  // ~
    sw      s2, 0x001C(sp)                  // ~
    sw      ra, 0x0030(sp)                  // store ra, s0-s2

    lw      s0, 0x0084(a0)                  // s0 = item special struct
    or      s1, a0, r0                      // s1 = item object
    li      s2, flashbang_attributes.struct // s2 = flashbang_attributes.struct

    _check_duration:
    lw      v0, 0x02C0(s0)                  // v0 = remaining duration
    bnezl   v0, _update_duration            // branch if duration has not ended
    nop
    jal     flashbang_explosion_              // begin explosion
    or      a0, s1, r0                      // a0 = item special struct
    b       _end                            // end
    nop

    _update_duration:
    addiu   t7, v0,-0x0001                  // t7 = decremented duration
    sw      t7, 0x02C0(s0)                  // store updated duration

    // branch if sticked to a player
    lw at, VARIABLES.STICKY_PLAYER_STRUCT(s0)
    bnez at, _sticky
    nop

    // branch between aerial or grounded state
    lw      at, 0x0108(s0)                  // at = kinetic state
    beq     at, r0, _update_speed_ground    // branch if kinetic state = grounded
    nop

    _update_speed_air:
    lui     at, 0x3F80                      // ~
    mtc1    at, f2                          // f2 = 1.0
    lwc1    f4, flashbang_attributes.MAX_SPEED(s2)    // f4 = MAX_SPEED
    lwc1    f6, 0x01C8(s0)                  // f6 = current max speed
    sub.s   f6, f6, f2                      // f6 = current max speed - 1.0
    c.le.s  f6, f4                          // ~
    nop                                     // ~
    bc1f    _apply_speed_air                // branch if MAX_SPEED =< updated max speed
    swc1    f6, 0x01C8(s0)                  // update current max speed
    // if updated max speed is below MAX_SPEED
    swc1    f4, 0x01C8(s0)                  // current max speed = MAX_SPEED

    _apply_speed_air:
    lw      a1, flashbang_attributes.GRAVITY(s2)      // a1 = GRAVITY
    lw      a2, 0x01C8(s0)                  // a2 = current max speed
    jal     0x80172558                      // apply gravity/max speed
    or      a0, s0, r0                      // a0 = item special struct
    b       _update_rotation_direction      // branch
    nop

    _update_speed_ground:
    sw      r0, 0x002C(s0)                  // x speed = 0
    sw      r0, 0x010C(s0)                  // disable hitbox

    // update set down frames (frames_set)
    lw      t0, VARIABLES.FRAMES_SET(s0) // t0 = frames set
    addiu   t0, t0, 0x0001                  // t0 = frames set + 1
    sw      t0, VARIABLES.FRAMES_SET(s0) // update frames set

    b       _do_flash
    nop

    _update_rotation_direction:
    lw      t0, 0x002C(s0)                  // t0 = current x speed
    beqz    t0, _update_rotation_speed      // branch if x speed is 0
    lwc1    f12, 0x01CC(s0)                 // f12 = rotation direction

    // if the flashbang's x speed isn't 0, update the rotation direction
    lwc1    f12, 0x002C(s0)                 // ~
    abs.s   f10, f12                        // ~
    div.s   f12, f12, f10                   // f12 = rotation direction
    swc1    f12, 0x01CC(s0)                 // update rotation direction

    _update_rotation_speed:
    // f12 = rotation direction
    lwc1    f8, 0x002C(s0)                  // f8 = current x speed
    lwc1    f6, 0x0030(s0)                  // f6 = current y speed
    mul.s   f8, f8, f8                      // f8 = x speed squared
    mul.s   f6, f6, f6                      // f6 = y speed squared
    add.s   f8, f8, f6                      // f8 = x speed squared + y speed squared
    sqrt.s  f10, f8                         // f10 = absolute speed
    lwc1    f6, flashbang_attributes.ROTATION(s2) // f6 = default rotation speed
    mul.s   f6, f6, f10                     // f6 = default rotation speed * absolute speed
    lui     t1, 0x3C90                      // ~
    mtc1    t1, f8                          // ~
    add.s   f8, f8, f6                      // f8 = calculated rotation speed + base rotation of 0.086
    mul.s   f8, f8, f12                     // f8(rotation speed) = calculated rotation * direction
    mfc1    at, f10                         // at = absolute speed
    bnez    at, _apply_rotation             // branch if absolute speed = 0
    nop

    // if we're here, absolute speed is 0
    mtc1    r0, f8                          // f8(rotation speed) = 0

    _apply_rotation:
    lw      v0, 0x0074(s1)                  // v0 = item first joint struct
    lwc1    f6, 0x0038(v0)                  // f6 = current x rotation
    sub.s   f6, f6, f8                      // update x rotation
    swc1    f6, 0x0038(v0)                  // store updated x rotation

    b _do_flash
    nop

    _sticky:
    lw t0, VARIABLES.STICKY_PLAYER_STRUCT(s0) // t0 = sticky player struct

    // check for conditions where we should destroy the C4
    lw t1, 0x24(t0) // t1 = sticked player's current action
    blt t1, Action.Idle, _destroy // if action < Idle, it's a KO related action
    nop
    
    sw r0, 0x002C(s0) // x speed = 0
    sw r0, 0x0030(s0) // y speed = 0

    lw t1, 0x74(s1) // t4 = item position at 1C(t1), 20(t1), 24(t1) // t1 = c4 x/y/z position
    lw t2, 0x78(t0) // t2 = sticky player position vec3

    lw at, 0x0(t2) // load player X
    sw at, 0x1C(t1) // save to our X
    lwc1 f2, 0x4(t2) // load player Y
    lwc1 f4, 0xB4(t0) // Load ECB collision diamond center
    add.s f2, f2, f4 // y += collision diamond center
    swc1 f2, 0x20(t1) // save to our Y

    // update set down frames (frames_set)
    lw      t0, VARIABLES.FRAMES_SET(s0) // t0 = frames set
    addiu   t0, t0, 0x0001                  // t0 = frames set + 1
    sw      t0, VARIABLES.FRAMES_SET(s0) // update frames set

    _do_flash: {
        // check to see if the flashbang is set down
        lw t0, VARIABLES.STICKY_PLAYER_STRUCT(s0)
        bnez t0, _flash // if sticked to a player, consider itself as set
        nop
        lw      t0, 0x0108(s0)                  // t0 = kinetic state
        bnez    t0, _end                        // branch if kinetic state = aerial
        nop

        _flash:
        // when the flashbang is set down, it will flash for the first 30 frames
        lw      t0, VARIABLES.FRAMES_SET(s0) // t0 = frames set
        sltiu   t1, t0, 30                      // if frames set is below 30...
        beqz    t1, _end                        // ...then branch to end
        nop

        // check to see if a flash particle should be created on this frame
        andi    t0, t0, 0x0007                  // t0 = duration % 8
        bnez    t0, _end                        // branch if duration % 8 != 0
        nop

        // create a flash particle every 8 frames
        lw      a0, 0x0074(s1)                  // a0 = item first joint struct

        lwc1    f0, 0x001C(a0)                  // f0 = flashbang x
        lwc1    f2, 0x0020(a0)                  // f2 = flashbang y
        lwc1    f4, 0x0024(a0)                  // f4 = flashbang z

        swc1    f0, 0x0004(sp)                  // save abs x
        swc1    f2, 0x0008(sp)                  // save abs y
        swc1    f4, 0x000C(sp)                  // save abs z

        jal     0x801015D4                      // create flash gfx
        addiu   a0, sp, 0x0004                  // a0 = flashbang pin abs x/y/z
    }

    _end:
    sw      r0, 0x01D4(s0)                  // hitbox collision flag = FALSE
    lw      s0, 0x0014(sp)                  // ~
    lw      s1, 0x0018(sp)                  // ~
    lw      s2, 0x001C(sp)                  // ~
    lw      ra, 0x0030(sp)                  // store ra, s0-s2
    addiu   sp, sp, 0x0040                  // deallocate stack space
    jr      ra                              // return
    or      v0, r0, r0                      // v0 = 0

    _destroy:
    lw t1, 0x01C4(s0) // load owner struct
    sw r0, 0x0ADC(t1) // clear out player struct free space so another c4 can be spawned
    lw s0, 0x0014(sp) // ~
    lw s1, 0x0018(sp) // ~
    lw s2, 0x001C(sp) // ~
    lw ra, 0x0030(sp) // store ra, s0-s2
    addiu sp, sp, 0x0040 // deallocate stack space
    jr ra
    lli v0, 0x1
}

// @ Description
// Collision subroutine for the flashbang.
// a0 = item object
scope flashbang_collision_: {
    addiu   sp, sp,-0x0058                  // allocate stack space
    sw      ra, 0x0014(sp)                  // ~
    sw      s0, 0x0040(sp)                  // ~
    sw      s1, 0x0044(sp)                  // store ra, s0, s1
    or      s0, a0, r0                      // s0 = item object
    li      s1, flashbang_attributes.struct   // s1 = flashbang_attributes.struct
    
    // skip collision check if in sticky mode
    lw t0, 0x84(a0) // t0 = item struct
    lw at, VARIABLES.STICKY_PLAYER_STRUCT(t0)
    bnez at, _end
    nop

    // if any collision occurs, change to the grounded/attached state
    li a1, attach_floor
    jal 0x80173E58 // itMapCheckMapProcAll(item_gobj, itMSBombAttachedSetStatus);
    or a0, r0, s0 // a0 = item object

    _end:
    lw      ra, 0x0014(sp)                  // ~
    lw      s0, 0x0040(sp)                  // ~
    lw      s1, 0x0044(sp)                  // load ra, s0, s1
    addiu   sp, sp, 0x0058                  // deallocate stack space
    jr      ra                              // return
    or      v0, r0, r0                      // return 0
}

// @ Description
// Collision subroutine for the flashbang's resting state.
// a0 = item object
scope flashbang_resting_collision_: {
    addiu   sp, sp,-0x0018                  // allocate stack space
    sw      ra, 0x0014(sp)                  // store ra
    li      a1, flashbang_begin_main_         // a1 = flashbang_begin_main_
    // jal     0x801735A0                      // generic resting collision?
    nop
    lw      ra, 0x0014(sp)                  // restore ra
    addiu   sp, sp, 0x0018                  // deallocate stack space
    jr      ra                              // return
    or      v0, r0, r0                      // return 0
}

// @ Description
// Main subroutine for the flashbang's exploding state.
// a0 = item object
// 80186524
scope flashbang_exploding_main_: {
    addiu   sp, sp,-0x0028                  // allocate stack space
    sw      ra, 0x0014(sp)                  // ~
    sw      s0, 0x001C(sp)                  // store ra, s0
    lw      s0, 0x0084(a0)                  // s0 = item special struct

    jal     flashbang_explosion_hitboxes_     // subroutine which handles explosion hitboxes
    sw      s0, 0x0010(sp)                  // save item special struct address
    lli     at, 0x0003                      // at = explosion ending frame
    lhu     t6, 0x033E(s0)                  // t6 = current explosion timer
    addiu   t6, t6, 0x0001                  // ~
    sh      t6, 0x033E(s0)                  // increment and update explosion timer
    bne     t6, at, _end                    // branch if explosion timer != ending frame
    lli     v0, OS.FALSE                    // return FALSE (don't destroy item?)
    // if explosion timer = ending frame
    lli     v0, OS.TRUE                     // return TRUE (destroy item?)
    lw      at, 0x0010(sp)                  // load item special struct address
    lw      at, 0x01C4(at)                  // load player struct address
    sw      r0, 0x0ADC(at)                  // clear out free space in player struct so that another flashbang can be thrown
    _end:
    lw      ra, 0x0014(sp)                  // ~
    lw      s0, 0x001C(sp)                  // load ra, s0
    jr      ra                              // return
    addiu   sp, sp, 0x0028                  // deallocate stack space
}

// @ Description
// Hitbox? subroutine for the flashbang's exploding state.
// For now, just replaces a hard-coded reference to the item info array and then jumps to the original routine, 0x801863AC
scope flashbang_explosion_hitboxes_: {
    lw      v0, 0x0084(a0)                  // a0 = item special struct
    li      t6, item_info_array     // t6 = item_info_array
    // TODO: extend this custom routine if addressing offset hard-code(s)
    j       0x801863B8                      // jump to original routine
    lw      t6, 0x0004(t6)                  // t6 = file pointer
}

// @ Description
// Changes a flashbang to the aerial/main state.
// a0 = item object
scope flashbang_begin_main_: {
    addiu   sp, sp,-0x0018                  // allocate stack space
    sw      ra, 0x0014(sp)                  // ~
    sw      a0, 0x0018(sp)                  // store ra, a0
    lw      a0, 0x0084(a0)                  // a0 = item special struct
    // lbu     t0, 0x02CE(a0)               // t0 = unknown bitfield
    // andi    t0, t0, 0xFF7F               // disable item pickup bit
    // sb      t0, 0x02CE(a0)               // store updated bitfield
    lli     at, 0x0001                      // ~
    jal     0x80173F78                      // bomb subroutine, sets kinetic state value
    sw      r0, 0x0248(a0)                  // disable hurtbox
    sw      r0, 0x010C(a0)                  // disable hitbox
    lw      a0, 0x0018(sp)                  // a0 = item object
    li      a1, flashbang_item_states         // a1 = object state base address
    jal     0x80172EC8                      // change item state
    ori     a2, r0, r0                      // a2 = 0 (aerial/main state)
    lw      ra, 0x0014(sp)                  // load ra
    jr      ra                              // return
    addiu   sp, sp, 0x0018                  // deallocate stack space
}

// wrapper to set resting state that gets collision angle to use as model rotation
// a0 = item object
scope attach_floor: {
    OS.routine_begin(0x20)
    sw a0, 0x4(sp)

    jal flashbang_begin_resting_
    nop
    jal 0x80176708 // itMSBombAttachedUpdateSurface(GObj *item_gobj) - rotation = ground/wall angle, stolen from proximity bomb
    lw a0, 0x4(sp) // a0 = item object

    lw v1, 0x84(a0) // v1 = item struct
    lw t6, 0x0024(v1) // item direction

    _flip_angle: {
        addiu at, r0, -1
        bne t6, at, _flip_angle_end
        nop
        // negate angle when facing left
        lw at, 0x74(a0) // load item first joint
        lwc1 f6, 0x38(at) // rot.z = angle
        neg.s f6, f6 // f6 = -angle
        swc1 f6, 0x38(at) // set item first joint z rotation to -angle
    }
    _flip_angle_end:

    lw a0, 0x4(sp) // a0 = item object
    OS.routine_end(0x20)
}

// @ Description
// Changes a flashbang to the grounded/resting state.
// a0 = item object
scope flashbang_begin_resting_: {
    addiu   sp, sp,-0x0018                  // allocate stack space
    sw      ra, 0x0014(sp)                  // ~
    sw      a0, 0x0018(sp)                  // store ra, a0
    lw      a0, 0x0084(a0)                  // a0 = item special struct
    sw      r0, 0x010C(a0)                  // disable hitbox
    sw      r0, 0x0248(a0)                  // disable hurtbox
    sw      r0, VARIABLES.FRAMES_SET(a0)    // reset frames set counter
    lbu     t0, 0x02CE(a0)                  // t0 = unknown bitfield
    // ori     t0, t0, 0x0080               // enables item pickup bit
    andi    t0, t0, 0x00CF                  // disable 2 bits
    sb      t0, 0x02CE(a0)                  // store updated bitfield
    sw      r0, 0x0030(a0)                  // y speed = 0
    jal     0x80173F54                      // bomb subroutine, sets kinetic state value and applies a multiplier to x speed?
    sw      r0, 0x0034(a0)                  // z speed = 0
    lw      a0, 0x0018(sp)                  // a0 = item object
    li      a1, flashbang_item_states       // a1 = object state base address
    jal     0x80172EC8                      // change item state
    ori     a2, r0, 0x0001                  // a2 = 1 (grounded/resting state)

    jal     0x800269C0 // play FGM
    addiu   a0, r0, 0x2C // FGM id = proximity bomb attach

    lw      ra, 0x0014(sp)                  // load ra
    jr      ra                              // return
    addiu   sp, sp, 0x0018                  // deallocate stack space
}

// @ Description
// Handles the flashbang's explosion.
// Based on function 0x80186368 and its subroutine 0x80185A80.
scope flashbang_explosion_: {
        addiu   sp, sp,-0x0030 // allocate stack space
        sw      ra, 0x001C(sp) // ~
        sw      s0, 0x0018(sp) // store ra, s0
        or      s0, a0, r0 // s0 = item object
        lw      v0, 0x0084(a0) // v0 = item special struct
        sw      r0, 0x002C(v0) // ~
        sw      r0, 0x0030(v0) // ~
        sw      r0, 0x0034(v0) // reset x/y/z velocity
        jal     0x8017279C // bomb subroutine, removes owner, updates unknown value, sets unknown bitflag
        sw      r0, 0x0248(v0) // disable hurtbox
        lw      a0, 0x0074(s0) // a0 = item first joint struct
        jal     0x801005C8 // create exploseion gfx
        addiu   a0, a0, 0x001C // a0 = item x/y/z

        // make the explosion larger
        beqz    v0, _continue // branch if no explosion gfx was created
        nop
        lui     at, 0x3FA0 // at = size multiplier (1.25)
        lw      t8, 0x005C(v0) // t8 = some kind of graphic related struct
        sw      at, 0x001C(t8) // ~
        sw      at, 0x0020(t8) // ~
        sw      at, 0x0024(t8) // store multiplier to graphic x/y/z size
        _continue:

        jal     0x801008F4 // unknown gfx related? function
        lli     a0, 0x0001 // a0 = 1 (why?)

        lw      t0, 0x0074(s0) // t0 = item first joint struct
        lli     t1, 0x0002 // t1 = 2
        sb      t1, 0x0054(t0) // set unknown value to 2
        lw      t0, 0x0084(s0) // t0 = item special struct
        lli     t1, 0x0001 // t1 = 1
        sh      t1, 0x0156(t0) // set unknown value to 1
        jal     0x8017275C // bomb subroutine, sets up hitbox stuff? potentially hard-coded?
        or      a0, s0, r0 // a0 = item object
        jal     flashbang_begin_explosion_ // change to explosion state
        or      a0, s0, r0 // a0 = item object
        jal     0x800269C0 // play FGM
        lli     a0, 0x0001 // FGM id = 1
        lw      ra, 0x001C(sp) // ~
        lw      s0, 0x0018(sp) // load ra, s0
        jr      ra // return
        addiu   sp, sp, 0x0030 // deallocate stack space
    }

// @ Description
// Changes a flashbang to the explosion state.
// Based on function 0x8018656C and its subroutine 0x801864E8
// a0 = item object
scope flashbang_begin_explosion_: {
    addiu   sp, sp,-0x0018                  // allocate stack space
    sw      ra, 0x0014(sp)                  // store ra
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    lbu     t6, 0x0340(v0)                  // ~
    andi    t6, t6, 0xFF0F                  // ~
    sb      t6, 0x0340(v0)                  // disable unknown bitflags
    sh      r0, 0x033E(v0)                  // set explosion timer to 0
    lui     at, 0x3F80                      // ~
    sw      at, 0x0114(v0)                  // set unknown value to 1.0
    lli     t2, 000070                      // ~
    sw      t2, 0x0140(v0)                  // set hitbox kbg to 70
    lli     t2, 000050                      // ~
    sw      t2, 0x0148(v0)                  // set hitbox bkb to 50
    jal     flashbang_explosion_hitboxes_     // subroutine which handles explosion hitboxes
    sw      a0, 0x0018(sp)                  // store a0
    lw      a0, 0x0018(sp)                  // a0 = item object
    li      a1, flashbang_item_states         // a1 = object state base address
    jal     0x80172EC8                      // change item state
    ori     a2, r0, 0x0002                  // a2 = 2 (explosion state)
    lw      a0, 0x0018(sp)                  // a0 = item object
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    addiu   t2, r0, 0x2B7                   // ~
    sh      t2, 0x156(v0)                   // save fgm value
    addiu   t2, r0, DAMAGE_TYPE             // ~
    sw      t2, 0x011C(v0)                  // save damage type as STUN
    lui     t2, EXPLODE_SIZE                // ~
    sw      t2, 0x0138(v0)                  // save damage type as STUN
    addiu   at, r0, EXPLODE_DAMAGE 
    sw      at, 0x0110(v0)                  // set damage to EXPLODE_DAMAGE
    li      at, 80
    sw      at, 0x013C(v0) // save hit angle
    li      at, 20
    sw      at, 0x0148(v0) // base knockback
    li      at, 100
    sw      at, 0x0140(v0) // knockback growth

    lw      ra, 0x0014(sp)                  // load ra
    jr      ra                              // return
    addiu   sp, sp, 0x0018                  // deallocate stack space
}

// @ Description
// Collision detection subroutine for aerial flashbangs.
scope flashbang_detect_collision_: {
    // Copy beginning of subroutine 0x801737B8
    OS.copy_segment(0xEE0F4, 0x88)
    beql    v0, r0, _end                    // modify branch
    lhu     t5, 0x0056(s0)                  // ~
    jal     0x800DD59C                      // ~
    or      a0, s0, r0                      // ~
    lhu     t0, 0x005A(s0)                  // ~
    lhu     t5, 0x0056(s0)                  // original logic
    // Remove ground collision lines
    // Copy end of subroutine
    _end:
    OS.copy_segment(0xEE1CC, 0x2C)
}

// @ Description
// Runs when a flashbang's hitbox collides with a hurtbox.
// a0 = item object
scope flashbang_hurtbox_collision_: {
    addiu   sp, sp,-0x0030              // allocate stack space
    sw      ra, 0x0024(sp)              // ~
    jal     flashbang_begin_main_         // transition to aerial/main state
    sw      a0, 0x0028(sp)              // store ra, a0

    lw      a0, 0x0028(sp)              // a0 = item struct
    lw      t0, 0x0084(a0)              // t0 = item special struct
    
    sw      r0, 0x010C(t0)              // disable hitbox
    lwc1    f0, 0x002C(t0)              // f0 = current x speed
    lwc1    f2, 0x0030(t0)              // f2 = current y speed
    mul.s   f0, f0, f0                  // f0 = x speed squared
    mul.s   f2, f2, f2                  // f2 = y speed squared
    add.s   f0, f0, f2                  // f0 = x speed squared + y speed squared
    sqrt.s  f4, f0                      // f4 = absolute speed
    lui     t1, 0x3F00                  // ~
    mtc1    t1, f2                      // f2 = 0.5
    mul.s   f0, f4, f2                  // f0 = absolute speed * 0.5
    lui     t1, 0x40A0                  // ~
    mtc1    t1, f2                      // f2 = 5
    add.s   f0, f0, f2                  // add base speed of 5 to f0

    // prevent the x/y speed from being updated if the hitbox collision flag is enabled
    // this is to prevent the flashbang from recoiling if it trades hits
    lw      t1, 0x01D4(t0)              // t1 = hitbox collision flag
    bnez    t1, _continue               // skip if hitbox collision flag = TRUE
    sw      r0, 0x01D4(t0)              // hitbox collision flag = FALSE

    // if the hitbox collision flag wasn't enabled
    sw      r0, 0x002C(t0)              // item x speed = 0
    swc1    f0, 0x0030(t0)              // item y speed = (absolute speed * 0.5) + 5

    _continue:
    sw      r0, 0x01D0(t0)              // disable hitbox refresh timer
    cvt.w.s f0, f4                      // convert absolute speed to int
    mfc1    t1, f0                      // t1 = absolute speed (int)
    srl     t2, t1, 0x1                 // ~
    addu    t1, t1, t2                  // t1 = absolute speed * 1.5
    lw      t2, 0x02C0(t0)              // t2 = current duration
    subu    t2, t2, t1                  // t2 = updated duration (duration - (absolute speed * 1.5))
    slti    at, t2, 000012              // at = TRUE if updated duration < 12; else at = FALSE
    beqz    at, _end                    // branch if updated duration >= 12
    nop
    // if we're here then the calculated remaining duration was set to less than 12 frames
    // we'll set it to 12 instead
    lli     t2, 000012                  // t2 = 12

    _end:
    sw      t2, 0x02C0(t0)              // update remaining duration
    lw      ra, 0x0024(sp)              // load ra
    addiu   sp, sp, 0x0030              // deallocate stack space
    jr      ra                          // return
    or      v0, r0, r0                  // return 0
}

// @ Description
// this subroutine handles hitbox collision for the flashbang, causing it to be launched when hit by attacks
// a0 = item object
scope flashbang_hitbox_collision_: {
    addiu   sp, sp,-0x0050              // allocate stack space
    lw      v0, 0x0084(a0)              // v0 = item special struct
    sw      ra, 0x0020(sp)              // 0x0020(sp) = ra
    sw      a0, 0x0024(sp)              // 0x0024(sp) = item object
    jal     flashbang_begin_main_         // transition to aerial/main state
    sw      v0, 0x0028(sp)              // 0x0028(sp) = item special struct

    // update item ownership and combo ownership
    lw      t0, 0x0028(sp)              // t0 = item special struct
    lw      t1, 0x02A8(t0)              // t1 = object which has ownership over the colliding hitbox
    sw      t1, 0x0008(t0)              // update item owner
    lli     at, 0x0004                  // at = 0x4 (no combo ownership)
    beqz    t1, _calculate_movement     // skip if there isn't an object in t1
    lli     t2, 0x03E8                  // t2 = player object type
    lw      t3, 0x0000(t1)              // t3 = object type
    bne     t2, t3, _calculate_movement // skip if object type != player
    lw      t1, 0x0084(t1)              // t1 = type specific special struct
    lbu     at, 0x000D(t1)              // at = player port (for combo ownership)

    _calculate_movement:
    sb      at, 0x0015(t0)              // update combo ownership
    lwc1    f0, 0x0298(t0)              // ~
    cvt.s.w f0, f0                      // f0 = damage
    lui     t1, 0x4080                  // ~
    mtc1    t1, f2                      // f2 = 4
    mul.s   f0, f0, f2                  // f0 = damage * 4
    lui     t1, 0x4120                  // ~
    mtc1    t1, f2                      // f2 = 10
    add.s   f0, f0, f2                  // f0 = knockback ((damage * 4) + 10)
    swc1    f0, 0x002C(sp)              // 0x002C(sp) = knockback
    swc1    f0, 0x01C8(t0)              // current max speed = knockback
    lw      a0, 0x029C(t0)              // a0 = knockback angle
    // this subroutine converts the int angle in a0 to radians, also handles sakurai angle
    jal     0x801409BC                  // f0 = knockback angle in rads
    lw      a2, 0x002C(sp)              // a2 = knockback
    swc1    f0, 0x0030(sp)              // 0x0030(sp) = knockback angle
    // ultra64 cosf function
    jal     0x80035CD0                  // f0 = cos(angle)
    mov.s   f12, f0                     // f12 = knockback angle
    lwc1    f4, 0x002C(sp)              // f4 = knockback
    mul.s   f4, f4, f0                  // f4 = x velocity (knockback * cos(angle))
    swc1    f4, 0x0034(sp)              // 0x0034(sp) = x velocity
    // ultra64 sinf function
    jal     0x800303F0                  // f0 = sin(angle)
    lwc1    f12, 0x0030(sp)             // f12 = knockback angle
    lwc1    f4, 0x002C(sp)              // f4 = knockback
    mul.s   f4, f4, f0                  // f4 = y velocity (knockback * sin(angle))
    lwc1    f2, 0x0034(sp)              // f2 = x velocity

    lw      t0, 0x0028(sp)              // t0 = item special struct
    lw      t1, 0x02A4(t0)              // ~
    subu    t1, r0, t1                  // t1 = DIRECTION
    sw      t1, 0x0024(t0)              // update item direction
    mtc1    t1, f0                      // ~
    cvt.s.w f0, f0                      // f0 = DIRECTION
    mul.s   f2, f0, f2                  // f2 = x velocity * DIRECTION
    swc1    f2, 0x002C(t0)              // update projectile x velocity
    swc1    f4, 0x0030(t0)              // update projectile y velocity
    // lw      t1, 0x0004(t0)              // ~
    // lw      t1, 0x0074(t1)              // t1 = projectile position struct
    // lwc1    f2, 0x0034(t1)              // f2 = projectile z rotation
    // abs.s   f2, f2                      // f2 = absolute projectile z rotation
    // mul.s   f2, f0, f2                  // f2 = rotation * DIRECTION
    // swc1    f2, 0x0034(t1)              // store updated rotation
    lli     t1, 000016                  // ~
    sw      t1, 0x01D0(t0)              // set hitbox refresh timer to 16 frames
    lli     t1, OS.TRUE                 // ~
    sw      t1, 0x01D4(t0)              // hitbox collision flag = TRUE
    lw      t2, 0x02C0(t0)              // t2 = current duration
    slti    at, t2, DAMAGE_FUSE_TIME    // at = TRUE if updated duration < DAMAGE_FUSE_TIME; else at = FALSE
    bnez    at, _end                    // branch if updated duration <= DAMAGE_FUSE_TIME
    nop
    // if we're here then the calculated remaining duration was set to less than 20 frames
    lli     t2, DAMAGE_FUSE_TIME        // t2 = damage_fuse_time

    _end:
    sw      t2, 0x02C0(t0)              // update remaining duration

    lw      ra, 0x0020(sp)              // load ra
    addiu   sp, sp, 0x0050              // deallocate stack space
    jr      ra
    or      v0, r0, r0                  // return 0 (important, not sure why)
}

// @ Description
// this routine gets run by whenever a projectile crosses the blast zone. The purpose here is to restock Peppy's flashbangs
scope flashbang_blast_zone_: {
    lw      t0, 0x0084(a0)          // t0 = item special struct
    lw      t1, 0x01C4(t0)          // load player struct from item special struct
    jr      ra                      // return
    sw      r0, 0x0ADC(t1)          // clear out player struct free space so another flashbang can be thrown
}
