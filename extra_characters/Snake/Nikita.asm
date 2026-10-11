// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(stage_setting_)
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
constant INITIAL_DAMAGE(1)

constant EXPLODE_TIME(500)

constant INITIAL_SPEED(0x41F0) // 30.0
constant ACCELERATION(0x4080) // 4.0
constant MAX_SPEED(0x428C) // 70.0
constant ROTATE_SPEED(0x3DA0D97C) // float: 4.5 deg in radians

constant DECELERATION_SPEED(0x3F40) // 0.75
constant GRAVITY(0x3FC0) // 1.5
constant MAX_FALL_SPEED(0x4270) // 60.0

scope attributes {
    constant DURATION(0x0000)
    constant GRAVITY(0x0004)
    constant MAX_FALL_SPEED(0x0008)
    constant ROTATION(0x000C)
    struct:
    dw EXPLODE_TIME                    // 0x0000 - duration (int)
    float32 3.6                             // 0x0004 - gravity
    float32 63                              // 0x0008 - max fall speed
    float32 0                               // 0x000C - rotation speed
}

scope VARIABLES: {
    constant SPEED(0x350)
    constant ANGLE(0x354)
    constant HIT_OPPONENT(0x358)
    constant DISABLED(0x35C)
}

OS.align(16)
item_info_array:
constant ITEM_INFO_ARRAY_ORIGIN(origin())
dw 0x00000000                           // 0x00 - item ID placeholder
dw Character.SNAKE_file_6_ptr           // 0x04 - address of file pointer
dw Snake.FILE_OFFSETS.MERGED_FILERESOURCE_6_1 // 0x08 - offset to item footer
dw 0x1B000000                           // 0x0C - ? either 0x1B000000 or 0x1C000000 - possible argument
dw 0                                    // 0x10 - ?
item_states:
// state 0 - main/control
dw main_                        // 0x14 - state 0 main
dw collision_                   // 0x18 - state 0 collision
dw hurtbox_collision_          // 0x1C - state 0 hitbox collision w/ hurtbox
dw hurtbox_collision_           // 0x20 - state 0 hitbox collision w/ shield
dw hurtbox_collision_           // 0x24 - state 0 hitbox collision w/ shield edge
dw 0                                      // 0x28 - state 0 unknown (maybe absorb)
dw reflect_                   // 0x2C - state 0 hitbox collision w/ reflector
dw hitbox_collision_            // 0x30 - state 0 hurtbox collision w/ hitbox
// state 1 - disabled
dw 0                                    // 0x34 - state 1 main
dw 0                                    // 0x38 - state 1 collision
dw 0                                    // 0x3C - state 1 hitbox collision w/ hurtbox
dw 0                                    // 0x40 - state 1 hitbox collision w/ shield
dw 0                                   // 0x44 - state 1 hitbox collision w/ shield edge
dw 0                                    // 0x48 - state 1 unknown (maybe absorb)
dw 0                                   // 0x4C - state 1 hitbox collision w/ reflector
dw 0                                    // 0x50 - state 1 hurtbox collision w/ hitbox
// state 2 - explosion
dw exploding_main_              // 0xD4 - state 2 main
dw 0                                    // 0xD8 - state 2 collision
dw 0                                    // 0xDC - state 2 hitbox collision w/ hurtbox
dw 0                                    // 0xE0 - state 2 hitbox collision w/ shield
dw 0                                    // 0xE4 - state 2 hitbox collision w/ shield edge
dw 0                                    // 0xE8 - state 2 unknown (maybe absorb)
dw 0                                    // 0xEC - state 2 hitbox collision w/ reflector
dw 0                                    // 0xF0 - state 2 hurtbox collision w/ hitbox
OS.align(16)

// @ Description
// Subroutine which sets up initial properties of the Nikita missile.
// a0 - player object
// a1 - item info array
// a2 - x/y/z coordinates to create item at
// a3 - unknown x/y/z offset
scope stage_setting_: {
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
    li      s1, attributes.struct   // s1 = attributes.struct

    // item is created
    sw      v0, 0x0040(sp)                  // 0x0040(sp) = item object
    lw      v1, 0x0084(v0)                  // v1 = item special struct
    sw      v1, 0x002C(sp)                  // 0x002C(sp) = item special struct
    lw      a0, 0x0074(v0)                  // a0 = item first joint (joint 0)
    sw      a0, 0x0030(sp)                  // 0x0030(sp) = item joint 0
    lli     a1, 0x002E                      // a1(render routine?) = 0x2E
    // jal     0x80008CC0                      // set up render routine?
    or      a2, r0, r0                      // a2 (unknown) = 0
    lw      a0, 0x0030(sp)                  // ~
    lw      a0, 0x0010(a0)                  // a0 = item second joint (joint 1)
    lli     a1, 0x002E                      // a1(render routine?) = 0x2E
    // jal     0x80008CC0                      // set up render routine?
    or      a2, r0, r0                      // a2 (unknown) = 0

    ecb_size: {
        lw      v1, 0x002C(sp)          // v1 = item special struct
        sw      r0, 0x0074(v1)          // ecb center = 0
        lui     at, 0x4248              // at = 50.0
        sw      at, 0x0070(v1)          // ecb top
        lui     at, 0xC248              // at = -50.0
        sw      at, 0x0078(v1)          // ecb bottom
        lui     at, 0x4248              // at = 50.0
        sw      at, 0x007C(v1)          // ecb width
    }

    lw      v1, 0x002C(sp)                  // v1 = item special struct
    lbu     t9, 0x0158(v1)                  // ~
    ori     t9, t9, 0x0010                  // ~
    sb      t9, 0x0158(v1)                  // enable unknown bitflag
    lw      t6, attributes.DURATION(s1)  // t6 = duration
    sw      t6, 0x02C0(v1)                  // store duration\
    lli     t7, 0x0004                      // ~
    sw      t7, 0x0354(v1)                  // unknown value(bit field?) = 0x00000004

    lw      a0, 0x0038(sp)                  // a0 = player object
    lw      v1, 0x002C(sp)                  // v1 = item special struct
    sw      a0, 0x0008(v1)                  // set player as projectile owner
    lw      t6, 0x0084(a0)                  // t6 = player struct
    lbu     at, 0x000C(t6)                  // load player team
    sb      at, 0x0014(v1)                  // save player's team to item to prevent damage when team attack is off
    lbu     at, 0x000D(t6)                  // at = player port
    sb      at, 0x0015(v1)                  // store player port for combo ownership
    sw      v1, 0x0AE0(t6)                  // save object address to free space in player struct
    sw      t6, 0x01C4(v1)                  // save player struct to custom variable space in the item special struct

    li      s1, attributes.struct   // s1 = attributes.struct

    sw      r0, VARIABLES.ANGLE(v1) // initial angle = 0
    sw      r0, VARIABLES.HIT_OPPONENT(v1) // hit opponent = FALSE
    sw      r0, VARIABLES.DISABLED(v1) // disabled = FALSE

    // // set Y scale
    // lw v0, 0x0040(sp) // v0 = item object
    // lw t0, 0x0074(v0) // t0 = item first joint (joint 0)
    // lui at, 0x3EC0 // at = 0.375 = 12/32 (graphic file is stretched in Y)
    // sw at, 0x44(t0) // set Y scale

    lw      t6, 0x0038(sp)                  // ~
    lw      t6, 0x0084(t6)                  // t6 = player struct
    lw      t6, 0x0044(t6)                 // t6 = player direction
    addiu   at, r0, -1
    bne     t6, at, _continue
    nop
    li      at, 0x40490FDB // 180deg in radians
    sw      at, VARIABLES.ANGLE(v1) // initial angle = 180deg

    _continue:
    sw      t6, 0x0024(v1) // set direction to Snake's facing direction at release; never updated again after this

    sw      r0, VARIABLES.SPEED(v1) // initial speed = 0

    lli     at, 0x0001                      // ~
    sw      at, 0x0248(v1)                  // enable hurtbox
    sw      at, 0x010C(v1)                  // enable hitbox
    addiu   at, r0, INITIAL_DAMAGE
    sw      at, 0x0110(v1)                  // set damage to INITIAL_DAMAGE
    sw      r0, 0x0148(v1)                  // base knockback = 0
    sw      r0, 0x0140(v1)                  // knockback growth = 0
    addiu   t2, r0, 0x2B7                   // 2B7 = no hit audio
    sh      t2, 0x156(v1)                   // save fgm value

    // Make projectile not interact with other hitboxes
    lbu at, 0x158(v1)
    andi at, at, 0xFF7F
    sb at, 0x158(v1)

    // lhu     at, 0x02CE(v1)                  // ~
    // ori     at, at, 0x0080                  // ~
    // sh      at, 0x02CE(v1)                  // enable bitflag which allows owner's hitboxes to collide with the hurtbox

    li      t0, attributes.struct   // t0 = attributes.struct
    lw      t1, attributes.MAX_FALL_SPEED(t0)    // t1 = MAX_SPEED
    sw      t1, 0x01C8(v1)                  // max speed = MAX_SPEED
    sw      r0, 0x01CC(v1)                  // rotation direction = 0
    sw      r0, 0x01D0(v1)                  // hitbox refresh timer = 0
    sw      r0, 0x01D4(v1)                  // hitbox collision flag = FALSE
    li      t1, blast_zone_         // load Nikita blast zone routine
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

    _end:
    or      v0, s0, r0                      // v0 = item object
    lw      s0, 0x0020(sp)                  // ~
    lw      s1, 0x0024(sp)                  // ~
    lw      ra, 0x0028(sp)                  // load s0, s1, ra
    jr      ra                              // return
    addiu   sp, sp, 0x0060                  // deallocate stack space
}

// @ Description
// Main subroutine for the Nikita missile.
// a0 = item object
scope main_: {
    addiu   sp, sp,-0x0040                  // allocate stack space
    sw      s0, 0x0014(sp)                  // ~
    sw      s1, 0x0018(sp)                  // ~
    sw      s2, 0x001C(sp)                  // ~
    sw      ra, 0x0030(sp)                  // store ra, s0-s2

    lw      s0, 0x0084(a0)                  // s0 = item special struct
    or      s1, a0, r0                      // s1 = item object
    li      s2, attributes.struct // s2 = attributes.struct

    _check_damage:
    lw at, 0x1c(s0) // load item->percent_damage (total damage received)
    slti at, at, 25 // at = 0 if damage >= 25; at = 1 if damage < 25
    bnez at, _check_duration  // branch if damage < 25 (continue normal operation)
    nop
    // if we're here, we took enough damage to explode
    jal explosion_ // begin explosion
    or a0, s1, r0 // a0 = item object
    b _end // branch to end
    nop

    _check_duration:
    lw      v0, 0x02C0(s0)                  // v0 = remaining duration
    bnezl   v0, _update_duration            // branch if duration has not ended
    nop
    jal     explosion_            // begin explosion
    or      a0, s1, r0                      // a0 = item special struct
    b       _end                            // end
    nop

    _update_duration:
    addiu   t7, v0,-0x0001                  // t7 = decremented duration
    sw      t7, 0x02C0(s0)                  // store updated duration

    _check_out_of_gas_disable:
    lw t6, 0x02C0(s0)  // t6 = remaining duration
    lli t7, 250         // t7 = 250
    bge t6, t7, _hitbox_timer // branch to _hitbox_timer if duration >= 250
    nop

    // if duration < 250, disable the nikita
    lli at, 0x1
    sw at, VARIABLES.DISABLED(s0) // set nikita to disabled

    b _hitbox_timer
    nop

    scope _hitbox_timer: {
        // refresh the hitbox when the hitbox refresh timer is used
        lw      t0, 0x01D0(s0)        // t0 = hitbox refresh timer
        beqz    t0, _end              // branch if hitbox refresh timer = 0
        nop
        // if the timer is not 0
        addiu   t0, t0,-0x0001                  // subtract 1 from the timer
        bnez    t0, _end                        // branch if the timer is still not 0
        sw      t0, 0x01D0(s0)                  // update the timer
        // if the timer just reached 0
        sw      r0, 0x0224(s0)                  // reset hit object pointer 1
        sw      r0, 0x022C(s0)                  // reset hit object pointer 2
        sw      r0, 0x0234(s0)                  // reset hit object pointer 3
        sw      r0, 0x023C(s0)                  // reset hit object pointer 4
        lli     at, 0x1
        sw      at, 0x010C(s0)                  // enable hitbox
        addiu   at, r0, INITIAL_DAMAGE
        sw      at, 0x0110(s0)                  // set damage to INITIAL_DAMAGE

        _end:
    }

    scope _control: {
        lw t0, VARIABLES.DISABLED(s0) // t0 = disabled state
        bnez t0, _skip // skip if disabled
        nop

        lw t3, 0x0008(s0) // t3 = owner
        lw t3, 0x84(t3) // t3 = owner player struct

        or t4, r0, r0 // t4 = 0, if we turn it we'll set it to 1

        // owner must be Snake and 0x0AE0 must point to the item struct
        lw      t1, 0x0008(t3) // t1 = character id
        ori     t2, r0, Character.id.SNAKE
        bne     t1, t2, _skip // branch if character is not Snake
        nop
        // snake must be in the operation action
        _action_check: {
            lw      t1, 0x0024(t3) // t1 = current action
            lli     t2, Snake.Action.NIKITAOPERATION
            beq     t1, t2, _action_check_passed // branch if action is nikita operation
            lli     t2, Snake.Action.NIKITAAIROPERATION
            beq     t1, t2, _action_check_passed // branch if action is nikita air operation
            nop
            b      _skip // if action is not nikita operation, skip
            nop
        }
        _action_check_passed:
        lw      t1, 0x0AE0(t3) // t1 = pointer to nikita struct Snake is controlling
        bne     t1, s0, _skip // branch if t1 != item struct
        nop

        _get_stick_angle:
        lb      t0, 0x01C2(t3)              // t0 = stick_x
        lb      t1, 0x01C3(t3)              // t1 = stick_y
        mtc1    t1, f12                     // ~
        mtc1    t0, f14                     // ~
        cvt.s.w f12, f12                    // f12 = stick y
        cvt.s.w f14, f14                    // f14 = stick x
        mul.s   f8, f12, f12                // ~
        mul.s   f10, f14, f14               // ~
        add.s   f8, f8, f10                 // ~
        sqrt.s  f8, f8                      // f8 = absolute stick x/y
        lui     at, 0x4120                  // ~
        mtc1    at, f6                      // f6 = 10
        c.le.s  f6, f8                      // ~
        nop                                 // ~
        bc1fl   _end                        // skip if absolute stick < 0...
        lwc1    f10, VARIABLES.ANGLE(s0)    // ...and set new angle to previous angle

        // if here we're turning, so set t4 to 1
        lli    t4, 0x0001

        jal     0x8001863C                  // f0 = atan2(f12,f14)
        nop
        mov.s   f12, f0                     // f12 = stick angle

        _get_turn_angle:
        mtc1    r0, f0                      // f0 = 0
        li      at, 0x40C90FDB              // ~
        mtc1    at, f2                      // f2 = 6.28319 rads/360 degrees
        li      at, 0xC0490FDB              // ~
        mtc1    at, f4                      // f4 = -3.14159 rads/-180 degrees
        li      at, ROTATE_SPEED            // ~
        mtc1    at, f6                      // f6 = ROTATE_SPEED
        lwc1    f10, VARIABLES.ANGLE(s0)    // f10 = current movement angle
        sub.s   f8, f12, f10                // f8 = angle difference: stick angle - current angle
        c.lt.s  f4, f8                      // ~
        nop                                 // ~
        bc1t    _skip_add                   // branch if angle difference >= -180...
        nop
        add.s   f8, f8, f2                  // ...otherwise add 360 degrees to angle difference
        _skip_add:

        // if angle difference > 180 deg, we should subtract 360 deg
        neg.s   f14, f4 // f14 = 3.14159
        c.le.s  f8, f14                     // ~
        nop                                 // ~
        bc1t    _skip_sub                   // branch if angle difference <= 180...
        nop
        sub.s   f8, f8, f2                  // ...otherwise subtract 360 degrees from angle difference
        _skip_sub:

        // an exact 180deg reversal is ambiguous; always favor turning through
        // whichever half is upward, based on current facing direction
        sub.s   f16, f8, f14                // f16 = angle difference - 180deg
        abs.s   f16, f16                    // f16 = |angle difference - 180deg|
        li      at, 0x3C800000              // ~0.9deg tolerance
        mtc1    at, f18                     // ~
        c.lt.s  f18, f16                    // ~
        nop                                 // ~
        bc1t    _calculate_turn             // branch if not close to an exact reversal...
        nop
        lw      t9, 0x0024(s0)              // t9 = direction at release (+1 right / -1 left), fixed at spawn
        bgez    t9, _calculate_turn         // branch if facing right (+180 already turns upward)...
        nop
        sub.s   f8, f8, f2                  // ...otherwise flip to -180, which turns upward when facing left

        _calculate_turn:
        abs.s   f14, f8                     // f14 = absolute angle difference
        c.lt.s  f6, f14                     // ~
        nop                                 // ~
        bc1fl   _update_angle               // branch and immediately update if absolute angle difference < ROTATE_SPEED...
        mov.s   f10, f12                    // ...and set movement angle to stick angle
        c.lt.s  f0, f8                      // ~
        nop                                 // ~
        bc1fl   _apply_turn                 // branch if angle difference < 0...
        neg.s   f6, f6                      // ...and set f6 to -ROTATE_SPEED

        _apply_turn:
        add.s   f10, f10, f6                // f10 = previous angle + ROTATE_SPEED

        _update_angle:
        c.lt.s  f4, f10                     // ~
        nop                                 // ~
        bc1fl   _end                        // branch if new movement angle < -180...
        add.s   f10, f10, f2                // ...and add 360 degrees to movement angle
        
        _end:
        lwc1    f12, VARIABLES.ANGLE(s0) // f12 = current movement angle
        c.eq.s  f10, f12 // ~
        nop // ~
        bc1f    _skip // branch if new movement angle != current movement angle...
        swc1    f10, VARIABLES.ANGLE(s0) // ...and set new movement angle

        // if here, we are not turning, so set t4 to 0
        or t4, r0, r0 // t4 = 0

        _skip:
    }

    scope _update_speed: {
        lw t0, VARIABLES.DISABLED(s0) // t0 = disabled state
        bnez t0, _end // skip if disabled
        nop

        lw at, 0x10C(s0) // t0 = hitbox enabled state
        beqz at, _turning // if hitbox is disabled (nikita got hit), slow down as if we're turning
        nop

        beqz t4, _not_turning // t4 is set on control above
        nop

        _turning:
        lui at, INITIAL_SPEED
        sw at, VARIABLES.SPEED(s0) // set speed to INITIAL_SPEED
        b _end
        nop

        _not_turning:
        // accelerate using ACCELERATION speed, up to MAX_SPEED
        lwc1 f2, VARIABLES.SPEED(s0) // f0 = current speed
        lui at, ACCELERATION
        mtc1 at, f4 // f4 = ACCELERATION
        add.s f2, f2, f4 // f0 = current speed + ACCELERATION
        lui at, MAX_SPEED
        mtc1 at, f6 // f6 = MAX_SPEED
        c.le.s f2, f6 // ~
        nop // ~
        bc1tl _update_speed // branch if current speed < MAX_SPEED
        nop
        mov.s f2, f6 // f2 = MAX_SPEED

        _update_speed:
        swc1 f2, VARIABLES.SPEED(s0) // store updated speed

        _end:
    }

    scope _apply_rotation: {
        lw      v0, 0x0074(s1) // v0 = item first joint struct
        lwc1    f12, VARIABLES.ANGLE(s0) // f12 = ANGLE
        li      at, 0x40490FDB // at = PI = 180 deg but in radians
        mtc1    at, f10
        add.s   f12, f12, f10 // f12 = ANGLE + PI (angle + 180 deg)
        swc1    f12, 0x0038(v0) // store updated x rotation
    }

    scope _move: {
        lw t0, VARIABLES.DISABLED(s0) // t0 = disabled state
        bnez t0, _disabled // disabled branch
        nop

        _enabled:
        lwc1    f12, VARIABLES.ANGLE(s0) // f12 = ANGLE
        // ultra64 cosf function
        jal     0x80035CD0                      // f0 = cos(ANGLE)
        swc1    f12, 0x0050(sp)                 // 0x0050(sp) = ANGLE
        lwc1    f6, VARIABLES.SPEED(s0)         // f6 = SPEED
        mul.s   f8, f6, f0                      // f8 = x velocity (SPEED * cos(ANGLE))
        swc1    f8, 0x002C(s0)                 // store x velocity
        // ultra64 sinf function
        jal     0x800303F0                      // f0 = sin(ANGLE)
        lwc1    f12, 0x0050(sp)                 // f12 = ANGLE
        lwc1    f6, VARIABLES.SPEED(s0)         // f6 = SPEED
        mul.s   f8, f6, f0                      // f8 = y velocity (SPEED * sin(ANGLE))
        swc1    f8, 0x0030(s0)                  // store y velocity

        b _end
        nop

        scope _disabled: {
            // here, gradually decrease X speed towards zero
            // and subtract Y towards max fall speed
            mtc1 r0, f0 // f0 = 0

            _x:
            lwc1 f4, 0x002C(s0) // f4 = x speed
            
            lui at, DECELERATION_SPEED
            mtc1 at, f8 // f8 = DECELERATION_SPEED

            // if already close to zero, set x speed to 0
            abs.s  f6, f4 // f6 = abs x speed
            c.le.s  f6, f8 // ~
            nop // ~
            bc1tl _y // branch if abs x speed < DECELERATION_SPEED...
            swc1 f0, 0x002C(s0) // ...and set x speed to 0
            
            c.lt.s f0, f4 // ~
            nop // ~
            bc1fl _apply_x // branch if x speed > 0...
            add.s f4, f4, f8 // ...and add DECELERATION_SPEED to x speed
            sub.s f4, f4, f8 // Otherwise, subtract DECELERATION_SPEED to x speed

            _apply_x:
            swc1 f4, 0x002C(s0)                  // store x speed
            
            _y:
            lwc1 f6, 0x0030(s0)                  // f6 = y speed
            lui at, GRAVITY
            mtc1 at, f8 // f8 = GRAVITY
            // add GRAVITY to y speed
            sub.s f6, f6, f8 // f6 = y speed + GRAVITY
            lui at, MAX_FALL_SPEED
            mtc1 at, f10 // f10 = MAX_FALL_SPEED
            neg.s f10, f10 // f10 = -MAX_FALL_SPEED
            c.le.s f10, f6 // ~
            nop // ~
            bc1fl _end // branch if y speed < MAX_FALL_SPEED...
            mov.s f6, f10 // ...and set y speed to MAX_FALL_SPEED
            swc1 f6, 0x0030(s0)                  // store y speed

            _end:
        }

        _end:
        sw      r0, 0x0034(s0)                  // z velocity = 0
    }

    scope _do_smoke: {
        lw      t0, 0x02C0(s0) // t0 = current duration

        lw      t1, VARIABLES.DISABLED(s0) // t1 = disabled state
        // check to see if a smoke particle should be created on this frame
        beqz    t1, _check_time
        andi    t2, t0, 0x0003 // not disabled: t0 = duration % 4
        // disabled: spawn at lower rate
        andi    t2, t0, 0x000F // not disabled: t0 = duration % 8

        _check_time:
        bnez    t2, _end // branch if not the time to spawn
        nop

        _spawn_smoke:
        // create a smoke particle every 4 frames
        lw      a0, 0x0074(s1)                  // a0 = item first joint struct
        lwc1    f12, 0x0038(a0)                 // f12 = nikita rotation angle
        neg.s   f12, f12                        // f12 = theta
        jal     0x80035CD0                      // f0 = cos(theta)
        swc1    f12, 0x0004(sp)                 // save 0x0050(sp) = theta

        swc1    f0, 0x0008(sp)                  // save cos(theta)
        jal     0x800303F0                      // f0 = sin(ANGLE)
        lwc1    f12, 0x0004(sp)                 // f12 = ANGLE

        lwc1    f2, 0x0008(sp)                  // f2 = cos(theta)

        // x' = x * cos(theta) + y * sin(theta)
        // y' = -x * sin(theta) + y * cos(theta)

        lw      at, 0x0010(a0)                  // at = item 2nd joint
        mtc1    r0, f6 // offset Y = 0
        lui     at, 0x4248
        mtc1    at, f4 // offset X = 50.0

        mul.s   f8, f4, f2                      // f8 = x * cos(theta)
        mul.s   f10, f6, f0                     // f10 = y * sin(theta)
        mul.s   f12, f4, f0                     // f12 = x * sin(theta)
        mul.s   f14, f6, f2                     // f14 = y * cos(theta)

        add.s   f16, f8, f10                    // f16 = x'
        sub.s   f18, f14, f12                   // f18 = y'

        lwc1    f0, 0x001C(a0)                  // f0 = nikita x
        lwc1    f2, 0x0020(a0)                  // f2 = nikita y
        lwc1    f4, 0x0024(a0)                  // f4 = nikita z

        add.s   f0, f0, f16                     // f0 = nikita pin abs x
        add.s   f2, f2, f18                     // f2 = nikita pin abs y

        swc1    f0, 0x0004(sp)                  // save abs x
        swc1    f2, 0x0008(sp)                  // save abs y
        swc1    f4, 0x000C(sp)                  // save abs z

        addiu   a0, sp, 0x0004 // a0 = nikita pin abs x/y/z
        lli     a1, 0x0 // a1 = 0
        addiu   sp, sp, -0x20
        jal     0x800FF648 // efManagerDustExpandSmallMakeEffect(Vec3f *pos, f32 f_index)
        nop
        addiu   sp, sp, 0x20

        _end:
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
}

// @ Description
// Collision subroutine for the Nikita missile.
// a0 = item object
scope collision_: {
    addiu   sp, sp,-0x0058                  // allocate stack space
    sw      ra, 0x0014(sp)                  // ~
    sw      s0, 0x0040(sp)                  // ~
    sw      s1, 0x0044(sp)                  // store ra, s0, s1
    or      s0, a0, r0                      // s0 = item object
    li      s1, attributes.struct   // s1 = attributes.struct

    lw      a0, 0x0084(s0)                  // ~
    addiu   a0, a0, 0x0038                  // a0 = x/y/z position
    li      a1, detect_collision_   // a1 = detect_collision_
    or      a2, s0, r0                      // a2 = item object
    jal     0x800DA034                      // collision detection
    ori     a3, r0, 0x0C21                  // bitmask (all collision types)
    
    beqz    v0, _end                        // branch if collision result = FALSE
    lw      t8, 0x0084(s0)                  // t8 = item special struct

    jal     explosion_            // begin explosion
    or      a0, s0, r0                      // a0 = item object

    _end:
    lw      ra, 0x0014(sp)                  // ~
    lw      s0, 0x0040(sp)                  // ~
    lw      s1, 0x0044(sp)                  // load ra, s0, s1
    addiu   sp, sp, 0x0058                  // deallocate stack space
    jr      ra                              // return
    or      v0, r0, r0                      // return 0
}

// @ Description
// Main subroutine for the Nikita missile's exploding state.
// a0 = item object
// 80186524
scope exploding_main_: {
    addiu   sp, sp,-0x0028                  // allocate stack space
    sw      ra, 0x0014(sp)                  // ~
    sw      s0, 0x001C(sp)                  // store ra, s0
    lw      s0, 0x0084(a0)                  // s0 = item special struct

    jal     explosion_hitboxes_     // subroutine which handles explosion hitboxes
    sw      s0, 0x0010(sp)                  // save item special struct address
    lli     at, 0x0001                      // at = explosion ending frame
    lhu     t6, 0x033E(s0)                  // t6 = current explosion timer
    addiu   t6, t6, 0x0001                  // ~
    sh      t6, 0x033E(s0)                  // increment and update explosion timer
    bne     t6, at, _end                    // branch if explosion timer != ending frame
    lli     v0, OS.FALSE                    // return FALSE (don't destroy item?)
    // if explosion timer = ending frame
    lli     v0, OS.TRUE                     // return TRUE (destroy item?)
    lw      at, 0x0010(sp)                  // load item special struct address
    lw      at, 0x01C4(at)                  // load player struct address
    
    lw      t0, 0x0AE0(at)                  // t0 = item object
    bne     t0, s0, _end                    // branch if item object != item special struct
    nop
    sw      r0, 0x0AE0(at)                  // clear out nikita object pointer
    _end:
    lw      ra, 0x0014(sp)                  // ~
    lw      s0, 0x001C(sp)                  // load ra, s0
    jr      ra                              // return
    addiu   sp, sp, 0x0028                  // deallocate stack space
}

// @ Description
// Hitbox? subroutine for the Nikita missile's exploding state.
// For now, just replaces a hard-coded reference to the item info array and then jumps to the original routine, 0x801863AC
scope explosion_hitboxes_: {
    lw      v0, 0x0084(a0)                  // a0 = item special struct
    li      t6, item_info_array     // t6 = item_info_array
    // TODO: extend this custom routine if addressing offset hard-code(s)
    j       0x801863B8                      // jump to original routine
    lw      t6, 0x0004(t6)                  // t6 = file pointer
}

// @ Description
// Changes the Nikita missile to the aerial/main state.
// a0 = item object
scope begin_main_: {
    addiu   sp, sp,-0x0018                  // allocate stack space
    sw      ra, 0x0014(sp)                  // ~
    sw      a0, 0x0018(sp)                  // store ra, a0
    lw      a0, 0x0084(a0)                  // a0 = item special struct
    // lbu     t0, 0x02CE(a0)               // t0 = unknown bitfield
    // andi    t0, t0, 0xFF7F               // disable item pickup bit
    // sb      t0, 0x02CE(a0)               // store updated bitfield
    lli     at, 0x0001                      // ~
    jal     0x80173F78                      // bomb subroutine, sets kinetic state value
    nop
    // sw      r0, 0x010C(a0)                  // disable hitbox
    lw      a0, 0x0018(sp)                  // a0 = item object
    li      a1, item_states         // a1 = object state base address
    jal     0x80172EC8                      // change item state
    ori     a2, r0, r0                      // a2 = 0 (aerial/main state)
    lw      ra, 0x0014(sp)                  // load ra
    jr      ra                              // return
    addiu   sp, sp, 0x0018                  // deallocate stack space
}

// @ Description
// Handles the Nikita missile's explosion.
// Based on function 0x80186368 and its subroutine 0x80185A80.
scope explosion_: {
    addiu   sp, sp,-0x0030                  // allocate stack space
    sw      ra, 0x001C(sp)                  // ~
    sw      s0, 0x0018(sp)                  // store ra, s0
    or      s0, a0, r0                      // s0 = item object
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    sw      r0, 0x002C(v0)                  // ~
    sw      r0, 0x0030(v0)                  // ~
    sw      r0, 0x0034(v0)                  // reset x/y/z velocity
    // jal     0x8017279C                      // bomb subroutine, removes owner, updates unknown value, sets unknown bitflag
    sw      r0, 0x0248(v0)                  // disable hurtbox
    lw      a0, 0x0074(s0)                  // a0 = item first joint struct
    jal     0x801005C8                      // create exploseion gfx
    addiu   a0, a0, 0x001C                  // a0 = item x/y/z

    // // make the explosion smaller (probably not needed for grenade)
    // beqz    v0, _continue            // branch if no explosion gfx was created
    // nop
    // lui     at, 0x3F80                    // at = size multiplier (0.75)
    // lw      t8, 0x005C(v0)                // t8 = some kind of graphic related struct
    // sw      at, 0x001C(t8)                // ~
    // sw      at, 0x0020(t8)                // ~
    // sw      at, 0x0024(t8)                // store multiplier to graphic x/y/z size
    // _continue:

    jal     0x801008F4                      // efManagerQuakeMakeEffect(s32 magnitude)
    lli     a0, 0x0001                      // a0 = 1

    lw      t0, 0x0074(s0)                  // t0 = item first joint struct
    lli     t1, 0x0002                      // t1 = 2
    sb      t1, 0x0054(t0)                  // set unknown value to 2
    lw      t0, 0x0084(s0)                  // t0 = item special struct
    lli     t1, 0x0001                      // t1 = 1
    sh      t1, 0x0156(t0)                  // set unknown value to 1
    jal     0x8017275C                      // bomb subroutine, sets up hitbox stuff? potentially hard-coded?
    or      a0, s0, r0                      // a0 = item object
    jal     begin_explosion_      // change to explosion state
    or      a0, s0, r0                      // a0 = item object
    jal     0x800269C0                      // play FGM
    lli     a0, 0x0000                      // FGM id = 0 (small explosion)
    lw      ra, 0x001C(sp)                  // ~
    lw      s0, 0x0018(sp)                  // load ra, s0
    jr      ra                              // return
    addiu   sp, sp, 0x0030                  // deallocate stack space
}

// @ Description
// Changes the Nikita missile to the explosion state.
// Based on function 0x8018656C and its subroutine 0x801864E8
// a0 = item object
scope begin_explosion_: {
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
    jal     explosion_hitboxes_     // subroutine which handles explosion hitboxes
    sw      a0, 0x0018(sp)                  // store a0
    lw      a0, 0x0018(sp)                  // a0 = item object
    li      a1, item_states         // a1 = object state base address
    jal     0x80172EC8                      // change item state
    ori     a2, r0, 0x0002                  // a2 = 2 (explosion state)
    lw      a0, 0x0018(sp)                  // a0 = item object
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    addiu   t2, r0, 0x2B7                   // ~
    sh      t2, 0x156(v0)                   // save fgm value
    addiu   t2, r0, DAMAGE_TYPE             // ~
    sw      t2, 0x011C(v0)                  // save damage type

    scope _hitbox_setup: {
        lw t0, VARIABLES.DISABLED(v0) // t0 = disabled state
        bnez t0, _disabled
        nop

        _enabled:
        lui     t2, 0x43A2 // 324
        sw      t2, 0x0138(v0)  // size
        addiu   at, r0, 14
        sw      at, 0x0110(v0)  // damage
        lli     at, 50
        sw      at, 0x013C(v0) // hit angle
        lli     at, 75
        sw      at, 0x0148(v0) // base knockback
        lli     at, 70
        sw      at, 0x0140(v0) // knockback growth

        b _end
        nop

        _disabled:
        lui     t2, 0x4361 // 225
        sw      t2, 0x0138(v0)  // size
        addiu   at, r0, 7
        sw      at, 0x0110(v0)  // damage
        lli     at, 50
        sw      at, 0x013C(v0) // hit angle
        lli     at, 50
        sw      at, 0x0148(v0) // base knockback
        lli     at, 90+20
        sw      at, 0x0140(v0) // knockback growth

        _end:
    }

    _end:
    lw      ra, 0x0014(sp)                  // load ra
    jr      ra                              // return
    addiu   sp, sp, 0x0018                  // deallocate stack space
}

// @ Description
// Collision detection subroutine for the aerial Nikita missile.
scope detect_collision_: {
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
// Runs when the Nikita missile's hitbox collides with a hurtbox.
// a0 = item object
scope hurtbox_collision_: {
    addiu   sp, sp,-0x0030              // allocate stack space
    sw      ra, 0x0024(sp)              // ~
    jal     begin_main_         // transition to aerial/main state
    sw      a0, 0x0028(sp)              // store ra, a0

    lw      a0, 0x0028(sp)              // a0 = item struct
    lw      t0, 0x0084(a0)              // t0 = item special struct
    sw      r0, 0x02C0(t0)              // update remaining duration

    lw      at, 0x264(t0)               // at = ip->hit_normal_damage
    beqz    at, _end                    // branch if hit_normal_damage = 0
    nop
    lli     at, 0x0001                  // at = 1
    sw      at, VARIABLES.HIT_OPPONENT(t0) // set hit opponent flag

    _end:
    lw      ra, 0x0024(sp)              // load ra
    addiu   sp, sp, 0x0030              // deallocate stack space
    jr      ra                          // return
    or      v0, r0, r0                  // return 0
}

// @ Description
// this subroutine handles hitbox collision for the Nikita missile, causing it to be launched when hit by attacks
// a0 = item object
scope hitbox_collision_: {
    addiu   sp, sp,-0x0050              // allocate stack space
    lw      v0, 0x0084(a0)              // v0 = item special struct
    sw      ra, 0x0020(sp)              // 0x0020(sp) = ra
    sw      a0, 0x0024(sp)              // 0x0024(sp) = item object
    jal     begin_main_         // transition to aerial/main state
    sw      v0, 0x0028(sp)              // 0x0028(sp) = item special struct

    // update item ownership and combo ownership
    lw      t0, 0x0028(sp)              // t0 = item special struct
    lw      t1, 0x02A8(t0)              // t1 = object which has ownership over the colliding hitbox

    lli     t1, 0x3C                    // ~
    sw      t1, 0x01D0(t0)              // set hitbox refresh timer to 60 frames
    sw      r0, 0x010C(t0)              // disable hitbox
    lli     t1, OS.TRUE                 // ~
    sw      t1, 0x01D4(t0)              // hitbox collision flag = TRUE
    sw      r0, 0x0110(t0)              // set damage to 0 to disable hit detection
    sw      r0, 0x264(t0)               // ip->hit_normal_damage = 0

    _set_min_speed:
    // set minimum speed (same as if we were turning)
    lui     at, INITIAL_SPEED
    sw      at, VARIABLES.SPEED(t0) // set speed to INITIAL_SPEED

    _rotate_from_damage:
    // add rotation to the projectile based on hit angle
    lw a0, 0x29C(t0) // a0 = hit angle
    
    // if it's the Sakurai angle, change it to 43 degrees
    lli t1, 0x169 // t1 = 0x169 = 361
    bne a0, t1, _continue // branch if a0 != 361
    nop
    lli a0, 0x2B // a0 = 43

    _continue:

    // this subroutine converts the int angle in a0 to radians, also handles sakurai angle
    jal 0x801409BC // f0 = knockback angle in rads
    nop

    lui at, 0x3E80 // at = 0.25 (float)
    mtc1 at, f4 // f4 = 0.25
    mul.s f0, f0, f4 // f0 = hit angle * 0.25

    // add 0-0.25 rotation based on damage (capped at 25%)
    lw t1, 0x298(t0) // t1 = damage
    beqz t1, _continue_rotation // skip if damage = 0
    nop

    // cap damage at 25
    slti at, t1, 25
    bnez at, _convert // branch if damage < 25
    nop
    li t1, 25 // t1 = 25 (cap damage)

    _convert:
    mtc1 t1, f6 // f6 = damage
    cvt.s.w f6, f6 // convert to float
    lui at, 0x41C8 // at = 25.0
    mtc1 at, f8 // f8 = 25.0
    div.s f6, f6, f8 // f6 = damage / 25.0
    lui at, 0x3F00 // at = 0.5
    mtc1 at, f8 // f8 = 0.5
    mul.s f6, f6, f8 // f6 = (damage / 25.0) * 0.5

    _apply_damage_rotation:
    add.s f0, f0, f6 // add damage rotation to hit angle rotation

    _continue_rotation:
    lw t0, 0x0028(sp) // t0 = item special struct
    lwc1 f2, VARIABLES.ANGLE(t0) // f2 = current ANGLE
    add.s f2, f2, f0 // f2 = current angle + (hit angle * 0.25)
    
    _store_new_angle:
    swc1    f2, VARIABLES.ANGLE(t0) // store new angle

    lw      ra, 0x0020(sp) // load ra
    addiu   sp, sp, 0x0050 // deallocate stack space
    jr      ra
    or      v0, r0, r0 // return 0 (do not destroy)
}

scope reflect_: {
    lw t0, 0x84(a0) // t0 = item special struct

    // reflect the projectile by adding 180 degrees to its angle
    lwc1 f0, VARIABLES.ANGLE(t0) // f0 = current angle
    li at, 0x40490FDB // at = PI = 180 deg but in radians
    mtc1 at, f2 // f2 = 180.0
    add.s f0, f0, f2 // f0 = current angle + 180 degrees
    swc1 f0, VARIABLES.ANGLE(t0) // store new angle

    // remove owner reference to make snake stop controlling the projectile
    lw t1, 0x1C4(t0) // load player struct from item special struct

    // check if we're the nikita being controlled
    lw t2, 0xAE0(t1) // t2 = item object
    bne t2, t0, _end // branch if item object != nikita object
    nop
    sw r0, 0xAE0(t1) // clear out reference in player struct
    
    _end:
    jr ra // return
    or v0, r0, r0 // return 0 (do not destroy)
}

// @ Description
// this routine gets run by whenever a projectile crosses the blast zone. The purpose here is to clear Snake's Nikita reference so he can fire another one
scope blast_zone_: {
    lw      t0, 0x0084(a0)          // t0 = item special struct
    lw      t1, 0x01C4(t0)          // load player struct from item special struct

    // check if we're the nikita being controlled
    lw      t2, 0x0AE0(t1)          // t2 = item object
    bne     t2, t0, _end            // branch if item object != nikita object
    nop
    sw      r0, 0x0AE0(t1)          // clear out reference in player struct
    
    _end:
    jr      ra                      // return
    nop
}
