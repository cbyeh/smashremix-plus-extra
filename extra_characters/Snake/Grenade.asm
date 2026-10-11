// Coded by HaloFactory
// Based on code by Fray's Conker Grenade
// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(flashbang_stage_setting_)
constant SHOW_GFX_WHEN_SPAWNED(OS.FALSE)
constant PICKUP_ITEM_MAIN(0)
constant PICKUP_ITEM_INIT(0)
constant DROP_ITEM(flashbang_begin_main_)
constant THROW_ITEM(throw_initial_)
constant PLAYER_COLLISION(0)

// @ Description
// Offset to item in file.
constant FILE_OFFSET(0x40)

constant FLASHBANG_FGM(0x2B7) // 0x2B7 = no hit sound
constant DAMAGE_TYPE(Damage.id.FIRE)
constant INITIAL_DAMAGE(1)
constant EXPLODE_DAMAGE(9)
constant EXPLODE_SIZE(0x43AF) // 350

constant INITIAL_FUSE_TIME(150)
constant DAMAGE_FUSE_TIME(4)

scope flashbang_attributes {
    constant DURATION(0x0000)
    constant GRAVITY(0x0004)
    constant MAX_SPEED(0x0008)
    constant BOUNCE(0x000C)
    constant ANGLE(0x0010)
    constant ROTATION(0x0014)
    struct:
    dw INITIAL_FUSE_TIME // 0x0000 - duration (int)
    float32 2.8 // 0x0004 - gravity
    float32 120 // 0x0008 - max speed
    float32 0.5 // 0x000C - bounce multiplier
    float32 0.00 // 0x0010 - angle
    float32 0.003 // 0x0014 - rotation speed
}

OS.align(16)
item_info_array:
constant ITEM_INFO_ARRAY_ORIGIN(origin())
dw 0x00000000 // 0x00 - item ID placeholder
dw Character.SNAKE_file_7_ptr // 0x04 - address of file pointer
dw FILE_OFFSET // 0x08 - offset to item footer
dw 0x1B000000 // 0x0C - ? either 0x1B000000 or 0x1C000000 - possible argument
dw 0 // 0x10 - ?
flashbang_item_states:
// state 0 - unreleased
dw unreleased_main // 0x14 - state 0 main
dw 0x0 // 0x18 - state 0 collision
dw 0x0 // 0x1C - state 0 hitbox collision w/ hurtbox
dw 0x0 // 0x20 - state 0 hitbox collision w/ shield
dw 0x0 // 0x24 - state 0 hitbox collision w/ shield edge
dw 0x0 // 0x28 - state 0 unknown (maybe absorb)
dw 0x0 // 0x2C - state 0 hitbox collision w/ reflector
dw flashbang_hitbox_collision_ // 0x30 - state 0 hurtbox collision w/ hitbox
// state 1 - resting
dw flashbang_main_ // 0x34 - state 1 main
dw flashbang_resting_collision_ // 0x38 - state 1 collision
dw flashbang_hurtbox_collision_ // 0x3C - state 1 hitbox collision w/ hurtbox
dw flashbang_hurtbox_collision_ // 0x40 - state 1 hitbox collision w/ shield
dw 0x801733E4 // 0x44 - state 1 hitbox collision w/ shield edge
dw 0 // 0x48 - state 1 unknown (maybe absorb)
dw 0x80173434 // 0x4C - state 1 hitbox collision w/ reflector
dw flashbang_hitbox_collision_ // 0x50 - state 1 hurtbox collision w/ hitbox
// state 2 - explosion
dw flashbang_exploding_main_ // 0xD4 - state 2 main
dw 0 // 0xD8 - state 2 collision
dw 0 // 0xDC - state 2 hitbox collision w/ hurtbox
dw 0 // 0xE0 - state 2 hitbox collision w/ shield
dw 0 // 0xE4 - state 2 hitbox collision w/ shield edge
dw 0 // 0xE8 - state 2 unknown (maybe absorb)
dw 0 // 0xEC - state 2 hitbox collision w/ reflector
dw 0 // 0xF0 - state 2 hurtbox collision w/ hitbox
// state 3 - aerial/thrown
dw flashbang_main_ // 0x14 - state 0 main
dw flashbang_collision_ // 0x18 - state 0 collision
dw flashbang_hurtbox_collision_ // 0x1C - state 0 hitbox collision w/ hurtbox
dw flashbang_hurtbox_collision_ // 0x20 - state 0 hitbox collision w/ shield
dw 0x801733E4 // 0x24 - state 0 hitbox collision w/ shield edge
dw 0 // 0x28 - state 0 unknown (maybe absorb)
dw 0x80173434 // 0x2C - state 0 hitbox collision w/ reflector
dw flashbang_hitbox_collision_ // 0x30 - state 0 hurtbox collision w/ hitbox
OS.align(16)

// @ Description
// Subroutine which sets up initial properties of flashbang.
// a0 - player object
// a1 - item info array
// a2 - x/y/z coordinates to create item at
// a3 - unknown x/y/z offset
scope flashbang_stage_setting_: {
    addiu sp, sp,-0x0060 // allocate stack space
    sw s0, 0x0020(sp) // ~
    sw s1, 0x0024(sp) // ~
    sw ra, 0x0028(sp) // store s0, s1, ra
    sw a0, 0x0038(sp) // 0x0038(sp) = player object
    sw a2, 0x003C(sp) // 0x003C(sp) = original x/y/z
    jal 0x8016E174 // create item
    sw r0, 0x0010(sp) // argument 4(unknown) = 0
    beqz v0, _end // end if no item was created
    or s0, v0, r0 // s0 = item object
    li s1, flashbang_attributes.struct // s1 = flashbang_attributes.struct

    // item is created
    sw v0, 0x0040(sp) // 0x0040(sp) = item object
    lw v1, 0x0084(v0) // v1 = item special struct
    sw v1, 0x002C(sp) // 0x002C(sp) = item special struct
    lw a0, 0x0074(v0) // a0 = item first joint (joint 0)
    sw a0, 0x0030(sp) // 0x0030(sp) = item joint 0
    lli a1, 0x002E // a1(render routine?) = 0x2E
    jal 0x80008CC0 // set up render routine?
    or a2, r0, r0 // a2 (unknown) = 0
    lw a0, 0x0030(sp) // ~
    lw a0, 0x0010(a0) // a0 = item second joint (joint 1)
    lli a1, 0x002E // a1(render routine?) = 0x2E
    jal 0x80008CC0 // set up render routine?
    or a2, r0, r0 // a2 (unknown) = 0

    lw v1, 0x002C(sp) // v1 = item special struct
    lbu t9, 0x0158(v1) // ~
    ori t9, t9, 0x0010 // ~
    sb t9, 0x0158(v1) // enable unknown bitflag
    lw t6, flashbang_attributes.DURATION(s1) // t6 = duration
    sw t6, 0x02C0(v1) // store duration\
    lli t7, 0x0004 // ~
    sw t7, 0x0354(v1) // unknown value(bit field?) = 0x00000004
    sw r0, 0x0350(v1) // clear pending explosion flag

    sw r0, 0x002C(v1) // x velocity = 0
    sw r0, 0x0030(v1) // y velocity = 0
    sw r0, 0x0034(v1) // z velocity = 0

    lli at, 0x0001 // ~
    sw at, 0x0248(v1) // enable hurtbox
    sw r0, 0x010C(v1) // disable hitbox
    addiu at, r0, INITIAL_DAMAGE
    sw at, 0x0110(v1) // set damage to INITIAL_DAMAGE
    // lhu at, 0x02CE(v1) // ~
    // ori at, at, 0x0080 // ~
    // sh at, 0x02CE(v1) // enable bitflag which allows owner's hitboxes to collide with the hurtbox

    li t0, flashbang_attributes.struct // t0 = flashbang_attributes.struct
    lw t1, flashbang_attributes.MAX_SPEED(t0) // t1 = MAX_SPEED
    sw t1, 0x01C8(v1) // max speed = MAX_SPEED
    sw r0, 0x01CC(v1) // rotation direction = 0
    sw r0, 0x01D0(v1) // hitbox refresh timer = 0
    sw r0, 0x01D4(v1) // hitbox collision flag = FALSE
    li t1, flashbang_blast_zone_ // load flashbang blast zone routine
    sw t1, 0x0398(v1) // save routine to part of item special struct that carries unique blast wall destruction routines

    sw r0, 0x0100(v1) // remove possible reference to character ID use by Bomb

    lw a0, 0x0038(sp) // a0 = player object
    lw t0, 0x84(a0) // t0 = player struct
    sw a0, 0x8(v1) // set player as projectile owner
    lbu at, 0xD(t0) // at = player port (for combo ownership)
    sb at, 0x15(v1) // store player port for combo ownership
    lli at, 0x28 // nSYAudioFGMPunchS
    sh at, 0x156(v1) // set hit_sfx
    sw t0, 0x01C4(v1) // save player struct (item creator) to custom variable space in the item special struct
    sw r0, 0x1DC(v1) // times landed = 0
    lw at, 0xAE8(t0) // at = number of spawned grenades
    addiu at, at, 1 // number of spawned grenades += 1
    sw at, 0xAE8(t0) // save new value
    sw a0, 0x01D8(v1) // save player object (last owner) to custom variable space to know who the 2nd hitbox should not hit
    lui at, 0x3FC0 // 1.5
    sw at, 0x2C4(v1) // throw speed multiplier

    addiu at, r0, 0x0000
    sw r0, 0x0140(v1) // overwrite knockback values
    sw r0, 0x0144(v1) // overwrite knockback values
    sw r0, 0x0148(v1) // overwrite knockback values

    lw a1, 0x0038(sp)					// ~
    lw a1, 0x0084(a1) // ~
    addiu a2, a1, 0x0078 // a2 = unknown
    lw a1, 0x0078(a1) // a1 = player x/y/z coordinates
    jal 0x800DF058 // check clipping
    lw a0, 0x0040(sp) // a0 = item object

    _end:
    or v0, s0, r0 // v0 = item object
    lw s0, 0x0020(sp) // ~
    lw s1, 0x0024(sp) // ~
    lw ra, 0x0028(sp) // load s0, s1, ra
    jr ra // return
    addiu sp, sp, 0x0060 // deallocate stack space
}

// @ Description
// a0 = item object
scope unreleased_main: {
    addiu sp, sp,-0x0040 // allocate stack space
    sw s0, 0x0014(sp) // ~
    sw s1, 0x0018(sp) // ~
    sw s2, 0x001C(sp) // ~
    sw ra, 0x0030(sp) // store ra, s0-s2

    lw s0, 0x0084(a0) // s0 = item special struct
    or s1, a0, r0 // s1 = item object
    li s2, flashbang_attributes.struct // s2 = flashbang_attributes.struct

    _check_owner_state:
    lw t3, 0x8(s0) // t3 = owner object
    lw t3, 0x84(t3) // t3 = owner player struct

    // snake must be in the operation action
    _action_check: {
        lw t1, 0x0024(t3) // t1 = current action
        lli t2, Snake.Action.GRENADESTART
        beq t1, t2, _action_check_end
        lli t2, Snake.Action.GRENADEWAIT
        beq t1, t2, _action_check_end
        lli t2, Snake.Action.GRENADETHROWN
        beq t1, t2, _action_check_end
        lli t2, Snake.Action.GRENADETHROWF
        beq t1, t2, _action_check_end
        lli t2, Snake.Action.GRENADETHROWB
        beq t1, t2, _action_check_end
        lli t2, Snake.Action.GRENADESTARTAIR
        beq t1, t2, _action_check_end
        lli t2, Snake.Action.GRENADEWAITAIR
        beq t1, t2, _action_check_end
        lli t2, Snake.Action.GRENADETHROWNAIR
        beq t1, t2, _action_check_end
        lli t2, Snake.Action.GRENADETHROWFAIR
        beq t1, t2, _action_check_end
        lli t2, Snake.Action.GRENADETHROWBAIR
        beq t1, t2, _action_check_end
        lli t2, Snake.Action.GRENADEWALKF
        beq t1, t2, _action_check_end
        lli t2, Snake.Action.GRENADEWALKB
        beq t1, t2, _action_check_end
        lli t2, Snake.Action.GRENADEJUMPSQUAT
        beq t1, t2, _action_check_end
        nop
        // if here, we're supposed to be released
        lli at, 0x1
        sw at, 0x1DC(s0) // set times landed to 1 so it doesn't bounce on drop
        jal flashbang_begin_main_ // use the regular drop function (also re-enables pickup)
        or a0, s1, r0 // a0 = item object
        b _end
        nop

        _action_check_end:
    }

    scope _update_pos: {
        addiu sp, sp, -0x20 // allocate space for a vec3

        sw r0, 0x0(sp)
        sw r0, 0x4(sp)
        sw r0, 0x8(sp) // vec3 at 0x0(sp) = {0, 0, 0}
        addiu a1, sp, 0x0 // a1 = vec3 pointer

        jal 0x800EDF24 // gmCollisionGetFighterPartsWorldPosition(DObj *main_dobj, Vec3f *vec) (part, &offset) (updates vec3 in a1)
        lw a0, 0x092C(t3) // a0 = part 0xD (light item bone) struct
        
        lw t4, 0x74(s1) // t4 = item position at 1C(t4), 20(t4), 24(t4)

        lw t3, 0x8(s0) // t3 = owner object
        lw t3, 0x84(t3) // t3 = owner player struct

        // X
        lwc1 f2, 0x0(sp) // f2 = vec3 x
        swc1 f2, 0x1C(t4) // set item x position to vec3 x

        // Y
        lwc1 f2, 0x4(sp) // f2 = vec3 y
        swc1 f2, 0x20(t4) // set item y position to vec3 y

        // Z
        lwc1 f2, 0x8(sp) // at = vec3 z
        swc1 f2, 0x28(t4) // set item z position to vec3 z

        addiu sp, sp, 0x20 // deallocate space

        // // set speed as owner speed
        // lw at, 0x8C(t3) // at = player x speed
        // sw at, 0x2C(s0) // set item x speed to player x speed

        _end:
    }

    _check_duration:
    lw v0, 0x02C0(s0) // v0 = remaining duration
    bnezl v0, _update_duration // branch if duration has not ended
    nop
    jal flashbang_explosion_ // begin explosion
    or a0, s1, r0 // a0 = item special struct
    b _end // end
    nop

    _update_duration:
    addiu t7, v0,-0x0001 // t7 = decremented duration
    sw t7, 0x02C0(s0) // store updated duration

    _reset_rotation:
    lw v0, 0x0074(s1) // v0 = item first joint struct
    sw r0, 0x0038(v0) // store updated x rotation

    _end:
    sw r0, 0x01D4(s0) // hitbox collision flag = FALSE
    lw s0, 0x0014(sp) // ~
    lw s1, 0x0018(sp) // ~
    lw s2, 0x001C(sp) // ~
    lw ra, 0x0030(sp) // store ra, s0-s2
    addiu sp, sp, 0x0040 // deallocate stack space
    jr ra // return
    or v0, r0, r0 // v0 = 0
}

// @ Description
// Main subroutine for the flashbang.
// a0 = item object
scope flashbang_main_: {
    addiu sp, sp,-0x0040 // allocate stack space
    sw s0, 0x0014(sp) // ~
    sw s1, 0x0018(sp) // ~
    sw s2, 0x001C(sp) // ~
    sw ra, 0x0030(sp) // store ra, s0-s2

    lw s0, 0x0084(a0) // s0 = item special struct
    or s1, a0, r0 // s1 = item object

    // if a hit left us with a pending explosion, this is the first frame this
    // function has run since then (hitlag_tics gates proc_update, so we don't
    // get called again until hitlag ends) - explode now
    lw t0, 0x0350(s0) // t0 = pending explosion flag
    beqz t0, _no_pending_explosion
    nop
    sw r0, 0x0350(s0) // clear flag
    jal flashbang_explosion_ // begin explosion
    or a0, s1, r0
    b _end
    nop
    _no_pending_explosion:

    li s2, flashbang_attributes.struct // s2 = flashbang_attributes.struct
    lw at, 0x0108(s0) // at = kinetic state
    beq at, r0, _update_speed_ground // branch if kinetic state = grounded
    nop

    _update_speed_air:
    lui at, 0x3F80 // ~
    mtc1 at, f2 // f2 = 1.0
    lwc1 f4, flashbang_attributes.MAX_SPEED(s2) // f4 = MAX_SPEED
    lwc1 f6, 0x01C8(s0) // f6 = current max speed
    sub.s f6, f6, f2 // f6 = current max speed - 1.0
    c.le.s f6, f4 // ~
    nop // ~
    bc1f _apply_speed_air // branch if MAX_SPEED =< updated max speed
    swc1 f6, 0x01C8(s0) // update current max speed
    // if updated max speed is below MAX_SPEED
    swc1 f4, 0x01C8(s0) // current max speed = MAX_SPEED

    _apply_speed_air:
    lw a1, flashbang_attributes.GRAVITY(s2) // a1 = GRAVITY
    lw a2, 0x01C8(s0) // a2 = current max speed
    jal 0x80172558 // apply gravity/max speed
    or a0, s0, r0 // a0 = item special struct
    b _check_duration // branch
    nop

    _update_speed_ground:
    lwc1 f0, 0x002C(s0) // f0 = x speed
    lui t0, 0x3F70 // ~
    mtc1 t0, f2 // f2 = 0.875
    mul.s f0, f0, f2 // f0 = x speed * 0.875
    swc1 f0, 0x002C(s0) // update x speed
    abs.s f0, f0 // f0 = absolute x speed
    lui t0, 0x4000 // ~
    mtc1 t0, f2 // f2 = minimum x speed
    c.lt.s f0, f2 // ~
    nop // ~
    bc1fl _check_duration // branch if abs x speed > minimum x speed
    nop
    sw r0, 0x002C(s0) // x speed = 0
    sw r0, 0x010C(s0) // disable hitbox

    _check_duration:
    lw v0, 0x02C0(s0) // v0 = remaining duration
    bnezl v0, _update_duration // branch if duration has not ended
    nop
    jal flashbang_explosion_ // begin explosion
    or a0, s1, r0 // a0 = item special struct
    b _end // end
    nop

    _update_duration:
    addiu t7, v0,-0x0001 // t7 = decremented duration
    sw t7, 0x02C0(s0) // store updated duration

    _update_rotation_direction:
    lw t0, 0x002C(s0) // t0 = current x speed
    beqz t0, _update_rotation_speed // branch if x speed is 0
    lwc1 f12, 0x01CC(s0) // f12 = rotation direction

    // if the flashbang's x speed isn't 0, update the rotation direction
    lwc1 f12, 0x002C(s0) // ~
    abs.s f10, f12 // ~
    div.s f12, f12, f10 // f12 = rotation direction
    swc1 f12, 0x01CC(s0) // update rotation direction


    _update_rotation_speed:
    // f12 = rotation direction
    lwc1 f8, 0x002C(s0) // f8 = current x speed
    lwc1 f6, 0x0030(s0) // f6 = current y speed
    mul.s f8, f8, f8 // f8 = x speed squared
    mul.s f6, f6, f6 // f6 = y speed squared
    add.s f8, f8, f6 // f8 = x speed squared + y speed squared
    sqrt.s f10, f8 // f10 = absolute speed
    lwc1 f6, flashbang_attributes.ROTATION(s2) // f6 = default rotation speed
    mul.s f6, f6, f10 // f6 = default rotation speed * absolute speed
    lui t1, 0x3C90 // ~
    mtc1 t1, f8 // ~
    add.s f8, f8, f6 // f8 = calculated rotation speed + base rotation of 0.086
    mul.s f8, f8, f12 // f8(rotation speed) = calculated rotation * direction
    mfc1 at, f10 // at = absolute speed
    bnez at, _apply_rotation // branch if absolute speed = 0
    nop

    // if we're here, absolute speed is 0
    mtc1 r0, f8 // f8(rotation speed) = 0

    _apply_rotation:
    lw v0, 0x0074(s1) // v0 = item first joint struct
    lwc1 f6, 0x0038(v0) // f6 = current x rotation
    sub.s f6, f6, f8 // update x rotation
    swc1 f6, 0x0038(v0) // store updated x rotation

    _hitbox_timer:
    // refresh the hitbox when the hitbox refresh timer is used
    lw t0, 0x01D0(s0) // t0 = hitbox refresh timer
    beqz t0, _speed_refresh // branch if hitbox refresh timer = 0
    nop
    // if the timer is not 0
    addiu t0, t0,-0x0001 // subtract 1 from the timer
    bnez t0, _calculate_damage // branch if the timer is still not 0
    sw t0, 0x01D0(s0) // update the timer
    // if the timer just reached 0
    sw r0, 0x0224(s0) // reset hit object pointer 1
    sw r0, 0x022C(s0) // reset hit object pointer 2
    sw r0, 0x0234(s0) // reset hit object pointer 3
    sw r0, 0x023C(s0) // reset hit object pointer 4

    _speed_refresh:
    // // refresh the hitbox when the refresh timer is unused and the flashbang passes a certain speed threshold
    // lui t0, 0x420C // ~
    // mtc1 t0, f4 // f4 = 35
    // c.le.s f4, f10 // ~
    // nop // ~
    // bc1f _calculate_damage // branch if absolute speed =< 35
    // nop
    // // if absolute speed > 20
    // sw r0, 0x0224(s0) // reset hit object pointer 1
    // sw r0, 0x022C(s0) // reset hit object pointer 2
    // sw r0, 0x0234(s0) // reset hit object pointer 3
    // sw r0, 0x023C(s0) // reset hit object pointer 4

    _calculate_damage:
    // lui t1, 0x3D90 // ~
    // mtc1 t1, f4 // ~
    // mul.s f4, f4, f10 // ~
    // trunc.w.s f4, f4 // ~
    // mfc1 t1, f4 // t1 = absolute speed * 0.07 (rounding down to nearest int)
    // addiu t1, t1, 0x0001 // add 1 base damage
    // sw t1, 0x0110(s0) // update projectile damage
    //sll t1, t1, 0x3 // t1 = damage * 8
    //addiu t1, t1, 000010 // add 10 base knockback
    //sw t1, 0x0148(s0) // set hitbox bkb to (damage * 8) + 10

    _end:
    sw r0, 0x01D4(s0) // hitbox collision flag = FALSE
    lw s0, 0x0014(sp) // ~
    lw s1, 0x0018(sp) // ~
    lw s2, 0x001C(sp) // ~
    lw ra, 0x0030(sp) // store ra, s0-s2
    addiu sp, sp, 0x0040 // deallocate stack space
    jr ra // return
    or v0, r0, r0 // v0 = 0
}

// @ Description
// Collision subroutine for the flashbang.
// a0 = item object
scope flashbang_collision_: {
    addiu sp, sp,-0x0058 // allocate stack space
    sw ra, 0x0014(sp) // ~
    sw s0, 0x0040(sp) // ~
    sw s1, 0x0044(sp) // store ra, s0, s1
    or s0, a0, r0 // s0 = item object
    li s1, flashbang_attributes.struct // s1 = flashbang_attributes.struct

    lw a0, 0x0084(s0) // ~
    addiu a0, a0, 0x0038 // a0 = x/y/z position
    li a1, flashbang_detect_collision_ // a1 = flashbang_detect_collision_
    or a2, s0, r0 // a2 = item object
    jal 0x800DA034 // collision detection
    ori a3, r0, 0x0C21 // bitmask (all collision types)
    sw v0, 0x0028(sp) // store collision result
    or a0, s0, r0 // a0 = item object
    ori a1, r0, 0x0C21 // bitmask (all collision types)
    lw a2, flashbang_attributes.BOUNCE(s1) // a2 = bounce multiplier
    jal 0x801737EC // apply collsion/bounce?
    or a3, r0, r0 // a3 = 0

    lw t0, 0x0028(sp) // t0 = collision result
    beqz t0, _end // branch if collision result = FALSE
    lw t8, 0x0084(s0) // t8 = item special struct
    lhu t0, 0x0092(t8) // t0 = collision flags
    andi t0, t0, 0x0800 // t0 = collision flags | grounded bitmask
    beqz t0, _end // branch if ground collision flag = FALSE
    nop
    lw at, 0x1DC(t8) // at = times landed
    addiu at, at, 0x1 // times landed += 1
    sw at, 0x1DC(t8) // update times landed
    lli t0, 0x2
    blt at, t0, _end // bounce until landed 2x
    nop
    jal flashbang_begin_resting_ // change to grounded/resting state
    or a0, s0, r0 // a0 = item object

    _end:
    lw ra, 0x0014(sp) // ~
    lw s0, 0x0040(sp) // ~
    lw s1, 0x0044(sp) // load ra, s0, s1
    addiu sp, sp, 0x0058 // deallocate stack space
    jr ra // return
    or v0, r0, r0 // return 0
}

// @ Description
// Collision subroutine for the flashbang's resting state.
// a0 = item object
scope flashbang_resting_collision_: {
    addiu sp, sp,-0x0018 // allocate stack space
    sw ra, 0x0014(sp) // store ra
    li a1, flashbang_begin_main_ // a1 = flashbang_begin_main_
    jal 0x801735A0 // generic resting collision?
    nop
    lw ra, 0x0014(sp) // restore ra
    addiu sp, sp, 0x0018 // deallocate stack space
    jr ra // return
    or v0, r0, r0 // return 0
}

// @ Description
// Main subroutine for the flashbang's exploding state.
// a0 = item object
// 80186524
scope flashbang_exploding_main_: {
    addiu sp, sp,-0x0028 // allocate stack space
    sw ra, 0x0014(sp) // ~
    sw s0, 0x001C(sp) // store ra, s0
    lw s0, 0x0084(a0) // s0 = item special struct

    // hitbox for frame 2+, bigger and doesn't hit the owner
    lw at, 0x1D8(s0) // get last owner before explosion
    sw at, 0x8(s0) // set as current owner
    lui t2, 0x43FA // 500
    sw t2, 0x0138(s0) // hitbox size

    jal flashbang_explosion_hitboxes_ // subroutine which handles explosion hitboxes
    sw s0, 0x0010(sp) // save item special struct address
    lli at, 0x0002 // at = explosion ending frame
    lhu t6, 0x033E(s0) // t6 = current explosion timer
    addiu t6, t6, 0x0001 // ~
    sh t6, 0x033E(s0) // increment and update explosion timer
    bne t6, at, _end // branch if explosion timer != ending frame
    lli v0, OS.FALSE // return FALSE (don't destroy item)
    // if explosion timer = ending frame
    lli v0, OS.TRUE // return TRUE (destroy item)
    lw at, 0x010(sp) // load item special struct address
    lw at, 0x1C4(at) // load original owner struct address
    lw t0, 0xAE8(at) // t0 = number of spawned grenades
    addiu t0, t0, -1 // number of spawned grenades -= 1
    sw t0, 0xAE8(at) // save new value
    _end:
    lw ra, 0x0014(sp) // ~
    lw s0, 0x001C(sp) // load ra, s0
    jr ra // return
    addiu sp, sp, 0x0028 // deallocate stack space
}

// @ Description
// Hitbox? subroutine for the flashbang's exploding state.
// For now, just replaces a hard-coded reference to the item info array and then jumps to the original routine, 0x801863AC
scope flashbang_explosion_hitboxes_: {
    lw v0, 0x0084(a0) // a0 = item special struct
    li t6, item_info_array // t6 = item_info_array
    // TODO: extend this custom routine if addressing offset hard-code(s)
    j 0x801863B8 // jump to original routine
    lw t6, 0x0004(t6) // t6 = file pointer
}

// @ Description
// Changes a flashbang to the aerial/main state.
// a0 = item object
scope flashbang_begin_main_: {
    addiu sp, sp,-0x0018 // allocate stack space
    sw ra, 0x0014(sp) // ~
    sw a0, 0x0018(sp) // store ra, a0
    lw a0, 0x0084(a0) // a0 = item special struct
    lbu t0, 0x02CE(a0) // t0 = unknown bitfield
    ori t0, t0, 0x0080 // enable item pickup bit
    sb t0, 0x02CE(a0) // store updated bitfield
    lli at, 0x0001 // ~
    jal 0x80173F78 // bomb subroutine, sets kinetic state value
    sw r0, 0x010C(a0) // disable hitbox
    jal 0x80185CD4 // bomb subroutine, sets an unknown value to 0x1
    lw a0, 0x0018(sp) // a0 = item object
    lw a0, 0x0018(sp) // a0 = item object
    li a1, flashbang_item_states // a1 = object state base address
    jal 0x80172EC8 // change item state
    ori a2, r0, 0x3 // a2 = 3 (aerial/main state)
    lw ra, 0x0014(sp) // load ra
    jr ra // return
    addiu sp, sp, 0x0018 // deallocate stack space
}

// @ Description
// Changes a flashbang to the grounded/resting state.
// a0 = item object
scope flashbang_begin_resting_: {
    addiu sp, sp,-0x0018 // allocate stack space
    sw ra, 0x0014(sp) // ~
    sw a0, 0x0018(sp) // store ra, a0
    lw a0, 0x0084(a0) // a0 = item special struct
    // sw r0, 0x010C(a0) // disable hitbox
    lbu t0, 0x02CE(a0) // t0 = unknown bitfield
    ori t0, t0, 0x0080 // enables item pickup bit
    andi t0, t0, 0x00CF // disable 2 bits
    sb t0, 0x02CE(a0) // store updated bitfield
    sw r0, 0x0030(a0) // y speed = 0
    sw r0, 0x1DC(a0) // times landed = 0
    jal 0x80173F54 // bomb subroutine, sets kinetic state value and applies a multiplier to x speed?
    sw r0, 0x0034(a0) // z speed = 0
    jal 0x80185CD4 // bomb subroutine, sets an unknown value to 0x1
    lw a0, 0x0018(sp) // a0 = item object
    lw a0, 0x0018(sp) // a0 = item object
    li a1, flashbang_item_states // a1 = object state base address
    jal 0x80172EC8 // change item state
    ori a2, r0, 0x0001 // a2 = 1 (grounded/resting state)
    lw ra, 0x0014(sp) // load ra
    jr ra // return
    addiu sp, sp, 0x0018 // deallocate stack space
}

// @ Description
// Handles the flashbang's explosion.
// Based on function 0x80186368 and its subroutine 0x80185A80.
scope flashbang_explosion_: {
    addiu sp, sp,-0x0030 // allocate stack space
    sw ra, 0x001C(sp) // ~
    sw s0, 0x0018(sp) // store ra, s0
    or s0, a0, r0 // s0 = item object
    sw a0, 0x0020(sp) // store item obj

    // if held, make fighter release it
    lw v0, 0x84(a0)
    lw t0, 0x2cc(v0)
    sll t0, t0, 0x11
    bgez t0, _release_item_end
    nop
    addiu sp, sp, -0x20
    // create a vec3 (0,0,0) at 0x0(sp)
    sw r0, 0x0(sp)
    sw r0, 0x4(sp)
    sw r0, 0x8(sp)
    or a1, r0, sp // a1 = velocity vector
    addiu sp, sp, -0x20
    lui a2, 0x3F80 // throw_mul = 1.0
    lli a3, 38 // nFTStatusAttackIDItemThrow
    jal 0x80172984 // itMainSetFighterRelease(GObj *item_gobj, Vec3f *vel, f32 throw_mul, u16 stat_flags, u16 stat_count)
    sw r0, 0x10(sp) // stat_count = 0
    addiu sp, sp, 0x20
    addiu sp, sp, 0x20
    lw a0, 0x0020(sp) // restore item obj
    _release_item_end:

    lw v0, 0x0084(a0) // v0 = item special struct

    lw at, 0x8(v0) // get current owner
    sw at, 0x1D8(v0) // save last owner before explosion

    sw r0, 0x002C(v0) // ~
    sw r0, 0x0030(v0) // ~
    sw r0, 0x0034(v0) // reset x/y/z velocity
    jal 0x8017279C // bomb subroutine, removes owner, updates unknown value, sets unknown bitflag
    sw r0, 0x0248(v0) // disable hurtbox
    lw a0, 0x0074(s0) // a0 = item first joint struct
    jal 0x801005C8 // create explosion gfx
    addiu a0, a0, 0x001C // a0 = item x/y/z
    
    // we will create a screen flash instead of an explosion effect.
    // li at, flash_array_ // at = hard-coded pointer to blend colour command
    // li a0, 0x80131A40 // a0 = hard-coded address to write blend colour commands to screen
    // sw at, 0x0000(a0) // save the pointer to the address.

    // make the explosion larger (probably not needed for flashbang)
    //beqz v0, _next_gfx_call // branch if no explosion gfx was created
    //nop
    //lui at, 0x3FA6 // ~
    //ori at, at, 0x6666 // at = size multiplier
    //lw t8, 0x005C(v0) // t8 = some kind of graphic related struct
    //sw at, 0x001C(t8) // ~
    //sw at, 0x0020(t8) // ~
    //sw at, 0x0024(t8) // store multiplier to graphic x/y/z size

    _screenshake:
    jal 0x801008F4 // screen shake
    lli a0, 0x0001 // shake severity = moderate

    lw t0, 0x0074(s0) // t0 = item first joint struct
    lli t1, 0x0002 // t1 = 2
    sb t1, 0x0054(t0) // set unknown value to 2
    lw t0, 0x0084(s0) // t0 = item special struct
    lli t1, 0x0001 // t1 = 1
    sh t1, 0x0156(t0) // set unknown value to 1
    jal 0x8017275C // bomb subroutine, sets up hitbox stuff? potentially hard-coded?
    or a0, s0, r0 // a0 = item object
    jal flashbang_begin_explosion_ // change to explosion state
    or a0, s0, r0 // a0 = item object
    jal 0x800269C0 // play FGM
    lli a0, 0x0000 // FGM id = 0 (small explosion)

    lw ra, 0x001C(sp) // ~
    lw s0, 0x0018(sp) // load ra, s0
    jr ra // return
    addiu sp, sp, 0x0030 // deallocate stack space
}

// @ Description
// Changes a flashbang to the explosion state.
// Based on function 0x8018656C and its subroutine 0x801864E8
// a0 = item object
scope flashbang_begin_explosion_: {
    addiu sp, sp,-0x0018 // allocate stack space
    sw ra, 0x0014(sp) // store ra
    lw v0, 0x0084(a0) // v0 = item special struct
    lbu t6, 0x0340(v0) // ~
    andi t6, t6, 0xFF0F // ~
    sb t6, 0x0340(v0) // disable unknown bitflags
    sh r0, 0x033E(v0) // set explosion timer to 0
    lui at, 0x3F80 // ~
    sw at, 0x0114(v0) // set unknown value to 1.0
    jal flashbang_explosion_hitboxes_ // subroutine which handles explosion hitboxes
    sw a0, 0x0018(sp) // store a0
    lw a0, 0x0018(sp) // a0 = item object
    li a1, flashbang_item_states // a1 = object state base address
    jal 0x80172EC8 // change item state
    ori a2, r0, 0x0002 // a2 = 2 (explosion state)
    lw a0, 0x0018(sp) // a0 = item object
    lw v0, 0x0084(a0) // v0 = item special struct
    addiu t2, r0, 0x2B7 // ~
    sh t2, 0x156(v0) // save fgm value
    addiu t2, r0, DAMAGE_TYPE // ~
    sw t2, 0x011C(v0) // save damage type as STUN
    // frame 1 hitbox, smaller and hits the owner
    lui t2, 0x4396 // 300
    sw t2, 0x0138(v0) // hitbox size
    addiu at, r0, EXPLODE_DAMAGE
    sw at, 0x0110(v0) // set damage to EXPLODE_DAMAGE
    addiu at, r0, -4
    sw at, 0x014C(v0) // save shield damage
    li at, 80
    sw at, 0x013C(v0) // save hit angle
    li at, 70
    sw at, 0x0148(v0) // base knockback
    li at, 69
    sw at, 0x0140(v0) // knockback growth

    lbu t0, 0x02CE(v0) // t0 = unknown bitfield
    andi t0, t0, 0xFF7F // disable item pickup bit
    sb t0, 0x02CE(v0) // store updated bitfield

    lw ra, 0x0014(sp) // load ra
    jr ra // return
    addiu sp, sp, 0x0018 // deallocate stack space
}

// @ Description
// Collision detection subroutine for aerial flashbangs.
scope flashbang_detect_collision_: {
    // Copy beginning of subroutine 0x801737B8
    OS.copy_segment(0xEE0F4, 0x88)
    beql v0, r0, _end // modify branch
    lhu t5, 0x0056(s0) // ~
    jal 0x800DD59C // ~
    or a0, s0, r0 // ~
    lhu t0, 0x005A(s0) // ~
    lhu t5, 0x0056(s0) // original logic
    // Remove ground collision lines
    // Copy end of subroutine
    _end:
    OS.copy_segment(0xEE1CC, 0x2C)
}

// @ Description
// Runs when a flashbang's hitbox collides with a hurtbox.
// a0 = item object
scope flashbang_hurtbox_collision_: {
    addiu sp, sp,-0x30 // allocate stack space
    sw ra, 0x0024(sp) // ~
    jal flashbang_begin_main_ // transition to aerial/main state
    sw a0, 0x28(sp) // store ra, a0

    lw a0, 0x28(sp) // a0 = item struct
    lw t0, 0x84(a0) // t0 = item special struct

    sw r0, 0x10C(t0) // disable hitbox
    lwc1 f0, 0x2C(t0) // f0 = current x speed
    lwc1 f2, 0x30(t0) // f2 = current y speed
    mul.s f0, f0, f0 // f0 = x speed squared
    mul.s f2, f2, f2 // f2 = y speed squared
    add.s f0, f0, f2 // f0 = x speed squared + y speed squared
    sqrt.s f4, f0 // f4 = absolute speed

    lui at, 0x3E00 // ~
    mtc1 at, f2 // f2 = ~0.25
    mul.s f2, f4, f2 // f2 = absolute speed * 0.25

    lui at, 0x41F0 // constant added for having a bounce even close to speed = 0
    mtc1 at, f6
    add.s f2, f2, f6

    mtc1 r0, f0 // f0 = 0.0

    // bounce at a 80deg angle
    // cos 80 = 0.1736 ~ 3E31
    lui at, 0x3E31
    mtc1 at, f6
    mul.s f6, f2, f6 // f6 = cos(80)*(absolute speed * 0.25)
    lwc1 f4, 0x2C(t0) // load current x speed
    c.eq.s f4, f0
    nop
    bc1tl _apply_x_speed
    mtc1 r0, f6 // if current x speed == 0, keep it at zero
    c.lt.s f4, f0
    nop
    bc1fl _apply_x_speed
    neg.s f6, f6 // if current x speed > 0, invert it
    _apply_x_speed:
    swc1 f6, 0x2C(t0) // save new item x speed
    // sin 80 = 0.9848 ~ 3F7C
    lui at, 0x3F7C
    mtc1 at, f6
    mul.s f6, f2, f6 // f6 = cos(80)*(absolute speed * 0.25)
    swc1 f6, 0x30(t0) // save new item y speed

    _end:
    lw ra, 0x0024(sp) // load ra
    addiu sp, sp, 0x30 // deallocate stack space
    jr ra // return
    or v0, r0, r0 // return 0
}

// @ Description
// this subroutine handles hitbox collision for the flashbang, causing it to be launched when hit by attacks
// a0 = item object
scope flashbang_hitbox_collision_: {
    addiu sp, sp,-0x0050 // allocate stack space
    lw s0, 0x0084(a0) // s0 = item special struct
    sw ra, 0x0020(sp) // 0x0020(sp) = ra
    sw a0, 0x0024(sp) // 0x0024(sp) = item object
    sw s0, 0x0028(sp) // 0x0028(sp) = item special struct

    // update item ownership and combo ownership
    lw t0, 0x0028(sp) // t0 = item special struct
    lw t1, 0x02A8(t0) // t1 = object which has ownership over the colliding hitbox
    sw t1, 0x0008(t0) // update item owner
    lli at, 0x0004 // at = 0x4 (no combo ownership)
    beqz t1, _continue // skip if there isn't an object in t1
    lli t2, 0x03E8 // t2 = player object type
    lw t3, 0x0000(t1) // t3 = object type
    bne t2, t3, _continue // skip if object type != player
    lw t1, 0x0084(t1) // t1 = type specific special struct
    lbu at, 0x000D(t1) // at = player port (for combo ownership)

    _continue:
    // damage_gobj (above) only ever gives the attacker's OWNING PLAYER, not
    // the attacking item - confirmed both in-game and in the engine source
    // for itProcessUpdateDamageStatItem/Weapon, which always write
    // owner_gobj there regardless of whether a fighter or an item hit us.
    // So instead, find out who actually hit us by walking the live item
    // list (head at 0x80046700, same as Smashketball.asm/Hazards.asm) and
    // checking each item's attack_records for our own object - that's the
    // same array flashbang_main_'s _hitbox_timer already resets by hand at
    // 0x224/0x22C/0x234/0x23C.
    sw r0, 0x002C(sp) // 0x002C(sp) = attacker item object found so far (0 = none)
    lw t4, 0x0024(sp) // t4 = our own item object
    OS.read_word(0x80046700, t0) // t0 = live item list head

    _find_attacker_loop:
    beqz t0, _find_attacker_end // stop once we've walked the whole list
    nop
    beq t0, t4, _find_attacker_next // skip ourselves
    nop

    lw t1, 0x0084(t0) // t1 = candidate item's special struct
    lw t2, 0x0224(t1) // t2 = candidate's attack record 0 victim
    beq t2, t4, _find_attacker_found
    nop
    lw t2, 0x022C(t1) // t2 = candidate's attack record 1 victim
    beq t2, t4, _find_attacker_found
    nop
    lw t2, 0x0234(t1) // t2 = candidate's attack record 2 victim
    beq t2, t4, _find_attacker_found
    nop
    lw t2, 0x023C(t1) // t2 = candidate's attack record 3 victim
    bne t2, t4, _find_attacker_next
    nop

    _find_attacker_found:
    sw t0, 0x002C(sp) // remember which item hit us
    b _find_attacker_end
    nop

    _find_attacker_next:
    lw t0, 0x0004(t0) // t0 = next item in the list
    b _find_attacker_loop
    nop

    _find_attacker_end:
    lw t0, 0x002C(sp) // t0 = attacker item object, or 0 if a fighter/weapon hit us instead
    beqz t0, _explode // no item attacker found - explode as normal
    nop
    lw t1, 0x0084(t0) // t1 = attacker's item special struct
    lw t2, 0x000C(t1) // t2 = attacker's item ID
    li t3, SnakeSpecial.GrenadeItem.id // t3 = our own item ID
    bne t2, t3, _explode // hit by some other item, not another grenade - explode as normal
    nop
    lw t2, 0x011C(t1) // t2 = attacker's current hitbox element/type
    li t3, Damage.id.FIRE // t3 = FIRE (only set on the explosion hitbox)
    beq t2, t3, _explode // attacker is currently exploding - let it detonate us too
    nop

    // hit by another grenade's flying contact hitbox - bounce instead of exploding
    lw a0, 0x0024(sp) // a0 = item object
    jal flashbang_hurtbox_collision_ // reuse the shield/hurtbox bounce physics
    nop
    b _end
    nop

    _explode:
    // Force the aerial/thrown state so being hit always runs through
    // flashbang_main_ (which handles the pending-explosion check below)
    // regardless of the state we were hit in - this also sidesteps
    // unreleased_main's _check_owner_state, which assumes the owner is
    // still Snake, but we just overwrote it with the attacker above.
    lw a0, 0x0024(sp) // a0 = item object
    li a1, flashbang_item_states // a1 = object state base address
    jal 0x80172EC8 // change item state
    addiu a2, r0, 0x0003 // state = 3 (thrown/aerial)

    // Don't explode immediately - the engine will automatically put the item
    // into hitlag based on the damage it just took (ip->damage_lag, set right
    // before this callback runs, gets converted to ip->hitlag_tics right after
    // it returns). Just mark the explosion as pending; flashbang_main_ won't
    // run again until hitlag ends, so it'll fire on the frame right after.
    lw a0, 0x0024(sp) // a0 = item object
    lw t0, 0x0084(a0) // t0 = item special struct
    lli t1, 1
    sw t1, 0x0350(t0) // mark explosion as pending

    _end:
    lw ra, 0x0020(sp) // load ra
    addiu sp, sp, 0x0050 // deallocate stack space
    jr ra
    or v0, r0, r0 // return 0 (important, not sure why)
}

// @ Description
// this routine gets run by whenever a projectile crosses the blast zone. The purpose here is to restock Peppy's flashbangs
scope flashbang_blast_zone_: {
    lw t0, 0x0084(a0) // t0 = item special struct
    lw t1, 0x01C4(t0) // original owner struct from item special struct
    lw at, 0xAE8(t1) // t0 = number of spawned grenades
    addiu at, at, -1 // number of spawned grenades -= 1
    jr ra // return
    sw at, 0xAE8(t1) // save new value
}

scope throw_initial_: {
    addiu sp, sp, -0x28
    sw ra, 0x14(sp)
    sw a0, 0x18(sp) // save item object

    lw v1, 0x84(a0)
    addiu at, r0, 1
    sw at, 0x248(v1) // enable hurtbox
    sw at, 0x010C(v1) // enable hitbox - actually being thrown as an item, unlike a plain release/drop
    addiu at, r0, INITIAL_DAMAGE
    sw at, 0x110(v1) // set damage to INITIAL_DAMAGE

    li a1, flashbang_item_states
    jal 0x80172EC8 // change item state
    addiu a2, r0, 0x3 // state = 3(thrown)

    lw ra, 0x14 (sp)
    jr ra
    addiu sp, sp, 0x28
}