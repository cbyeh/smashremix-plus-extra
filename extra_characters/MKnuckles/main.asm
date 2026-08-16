include "./MKnucklesSpecial.asm"
include "./AI.asm"

scope MKnuckles {
    insert CUSTOM_IDLE,"moveset/IDLE.bin"; Moveset.GO_TO(CUSTOM_IDLE) // loops
    insert CUSTOM_SPARKLE, "moveset/SPARKLE.bin"; Moveset.GO_TO(CUSTOM_SPARKLE)
    insert CUSTOM_SHIELD_BREAK, "moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(CUSTOM_SPARKLE)
    insert CUSTOM_STUN, "moveset/STUN.bin"; Moveset.GO_TO(CUSTOM_STUN) // loops
    insert CUSTOM_SLEEP, "moveset/SLEEP.bin"; Moveset.GO_TO(CUSTOM_SLEEP) // loops

    BALL_HURTBOX_ON:
    dw 0xA8000000   // unknown
    dw 0x7C300000, 0x00000064, 0xFFC4012C, 0x012C012C // set body hurtbox properties
    dw 0x70400003   // left shoulder intangible
    dw 0x70480003   // left wrist intangible
    dw 0x70600003   // head intangible
    dw 0x70700003   // right shoulder intangible
    dw 0x70780003   // right wrist intangible
    dw 0x70980003   // left thigh intangible
    dw 0x70A00003   // left shin intangible
    dw 0x70C00003   // rightt thigh intangible
    dw 0x70C80003   // rightt shin intangible
    Moveset.RETURN()
    // Subroutine for disabling ball hurtboxes
    BALL_HURTBOX_OFF:
    dw 0xA4000000   // unknown
    dw 0x78000000   // reset hurtbox sizes?
    dw 0x6C000001   // set all hurtboxes to vulernable
    Moveset.RETURN()

    CUSTOM_GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); Moveset.GO_TO(GRAB)
    CUSTOM_THROW_F:; Moveset.THROW_DATA(THROW_F_DATA); Moveset.GO_TO(THROW_F)
    CUSTOM_THROW_B:;Moveset.CONCURRENT_STREAM(THROW_B_CONCURRENT); Moveset.THROW_DATA(THROW_B_DATA); Moveset.GO_TO(THROW_B)
    THROW_B_CONCURRENT:
    dw 0x04000010                                   // wait 16 frames
    dw 0x3800002B                                   // Play Attack FGM
    dw 0x04000014                                   // wait 16 frames
    dw 0x3800002B                                   // Play Attack FGM
    dw 0                                            // terminate moveset commands

    CUSTOM_DSMASH:; Moveset.CONCURRENT_STREAM(DSMASH_CONCURRENT); insert "moveset/DSMASH.bin"
    DSMASH_CONCURRENT:
    dw 0xBC000000                                   // slope contour
    dw 0x04000005                                   // wait 5 frames
    dw 0x380003D8                                   // Spindash SFX
    dw 0x04000007                                   // wait 7 frames
    dw 0xA8000000; dw 0xA0300001; dw 0x04000004     // show ball model and wait 4 frames
    Moveset.SUBROUTINE(SHOW_MODEL); dw 0x04000002   // show full model and wait 2 frames
    dw 0xA8000000; dw 0xA0300001; dw 0x04000004     // show ball model and wait 4 frames
    Moveset.SUBROUTINE(SHOW_MODEL); dw 0x04000002   // show full model and wait 2 frames
    dw 0xBC000004                                   // slope contour
    dw 0xA8000000; dw 0xA0300001; dw 0x04000004     // show ball model and wait 4 frames
    Moveset.SUBROUTINE(SHOW_MODEL); dw 0x04000002   // show full model and wait 2 frames
    dw 0xBC000000                                   // slope contour
    dw 0xA8000000; dw 0xA0300001; dw 0x04000004     // show ball model and wait 4 frames
    Moveset.SUBROUTINE(SHOW_MODEL); dw 0x04000002   // show full model and wait 2 frames
    dw 0                                            // terminate moveset commands

    CUSTOM_DSP_CHARGE:; Moveset.CONCURRENT_STREAM(DSP_CHARGE_HITBOX); Moveset.SUBROUTINE(BALL_HURTBOX_ON); insert "moveset/DSP_CHARGE.bin"
    CUSTOM_DSP_AIR_CHARGE:; Moveset.CONCURRENT_STREAM(DSP_CHARGE_HITBOX); Moveset.SUBROUTINE(BALL_HURTBOX_ON); insert "moveset/DSP_AIR_CHARGE.bin"
    CUSTOM_DSP_MOVE:; Moveset.CONCURRENT_STREAM(DSP_FLICKER_LOOP); Moveset.SUBROUTINE(BALL_HURTBOX_ON); insert "moveset/DSP_MOVE.bin"
    CUSTOM_DSP_AIR_MOVE:; Moveset.CONCURRENT_STREAM(DSP_FLICKER_END);  insert "moveset/DSP_AIR_MOVE.bin"
    CUSTOM_DSP_AIR_JUMP:; Moveset.CONCURRENT_STREAM(DSP_FLICKER_END); insert "moveset/DSP_AIR_JUMP.bin"
    DSP_CHARGE_HITBOX:
    dw 0x04000001                                   // wait 1 frames
    dw 0x0C000053, 0x00B40000, 0x00C80000, 0x1186407B, 0x002A0000 // create hitbox
    dw 0x04000004                                   // wait 4 frames
    dw 0x18000000                                   // end hitboxes
    Moveset.GO_TO(DSP_CHARGE_HITBOX)                // loops
    DSP_FLICKER_LOOP:
    dw 0xA8000000; dw 0xA0300001; dw 0x04000003     // show ball model and wait 3 frames
    Moveset.SUBROUTINE(SHOW_MODEL); dw 0x04000003   // show full model and wait 3 frames
    Moveset.GO_TO(DSP_FLICKER_LOOP)                 // loops
    DSP_FLICKER_END:
    Moveset.SUBROUTINE(BALL_HURTBOX_ON)             // enabled ball hurtboxes
    dw 0x80000006                                   // begin a loop with 6 iterations
    dw 0xA8000000; dw 0xA0300001; dw 0x04000003     // show ball model and wait 3 frames
    Moveset.SUBROUTINE(SHOW_MODEL); dw 0x04000003   // show full model and wait 3 frames
    dw 0x84000000                                   // end loop
    Moveset.SUBROUTINE(BALL_HURTBOX_OFF)            // disable ball hurtboxes
    dw 0

    BEAMSWORD_DASH:; dw 0xBC000004; dw 0xCC040000; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_DASH); dw 0x04000005; dw 0xCC03FFFF; dw 0x04000006; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    BAT_DASH:; dw 0xBC000004; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.BAT_DASH); dw 0x04000012; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    FAN_DASH:; dw 0xBC000004; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.FAN_DASH); dw 0x04000012; dw 0x18000000; dw 0x08000006; dw 0xBC000003; dw 0
    STARROD_DASH:; dw 0xBC000004; dw 0xB12C0014; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.STARROD_DASH); dw 0x04000005; dw 0x18000000; dw 0x08000006; dw 0xBC000003; dw 0

    duo_moveset:
    dw 0xAC000003   // Set Texture Form (Knuckles eyes)
    dw 0xAC100004   // Set Texture Form (Knuckles Smile)
    dw 0x00000000   // End

    // @ Description
    // Knuckles' Extra Actions
    scope Action {
        constant Jab3(0xDC)
        constant Appear1(0xDF)
        constant Appear2(0xE0)
        constant Spring(0x0E4)
        constant DiveGround(0xE6)
        constant DiveAirBegin(0xE7)
        constant DiveAirLoop(0xE8)
        constant DiveLand(0xE9)
        constant ClimbWait(0xF6)
        constant ClimbUp(0xF7)
        constant ClimbDown(0xF8)
        constant GlideTurn(0xF9)
        constant GlideBegin(0xFA)
        constant GlideWait(0xFB)
        constant GlideEnd(0xFC)
        constant SpinDashChargeGround(0xFD)
        constant SpinDashGround(0xFE)
        constant SpinDashEndGround(0xFF)
        constant SpinDashChargeAir(0x100)
        constant SpinDashAir(0x101)
        constant SpinDashJumpAir(0x102)
        constant SpinDashendAir(0x103)

        // strings!
        string_0x0E4:; String.insert("Spring")
        string_0xE6:; String.insert("DiveGround")
        string_0xE7:; String.insert("DiveAirBegin")
        string_0xE8:; String.insert("DiveAirLoop")
        string_0xE9:; String.insert("DiveLand")
        string_ClimbWait:; String.insert("ClimbWait")
        string_ClimbUp:; String.insert("ClimbUp")
        string_ClimbDown:; String.insert("ClimbDown")
        string_0xF6:; String.insert("GlideTurn")
        string_0xF7:; String.insert("GlideBegin")
        string_0xF8:; String.insert("GlideWait")
        string_0xF9:; String.insert("GlideEnd")
        string_0xFA:; String.insert("SpinDashChargeGround")
        string_0xFB:; String.insert("SpinDashGround")
        string_0xFC:; String.insert("SpinDashEndGround")
        string_0xFD:; String.insert("SpinDashChargeAir")
        string_0xFE:; String.insert("SpinDashAir")
        string_0xFF:; String.insert("SpinDashJumpAir")
        string_0x100:; String.insert("SpinDashEndAir")

        action_string_table:
        dw Action.COMMON.string_jab3
        dw 0
        dw 0
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw 0
        dw 0
        dw 0
        dw string_0x0E4
        dw 0
        dw string_0xE6
        dw string_0xE7
        dw string_0xE8
        dw string_0xE9
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw string_ClimbWait
        dw string_ClimbUp
        dw string_ClimbDown
        dw string_0xF6
        dw string_0xF7
        dw string_0xF8
        dw string_0xF9
        dw string_0xFA
        dw string_0xFB
        dw string_0xFC
        dw string_0xFD
        dw string_0xFE
        dw string_0xFF
        dw string_0x100
        dw 0
        dw 0
        dw 0
    }

    // Modify Action Parameters                 // Action                       // Animation                                // Moveset Data                     // Flags
    Character.edit_action_parameters(MKNUCKLES, 0xDF,                           File.MKNUCKLES_ANIM_ENTRY_LEFT,             0,                                  -1)
    Character.edit_action_parameters(MKNUCKLES, 0xE0,                           File.MKNUCKLES_ANIM_ENTRY_RIGHT,            0,                                  -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Idle,                    File.MKNUCKLES_ANIM_IDLE,                   CUSTOM_IDLE,                        -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Entry,                   File.MKNUCKLES_ANIM_IDLE,                   CUSTOM_IDLE,                        -1)
    Character.edit_action_parameters(MKNUCKLES, Action.ReviveWait,              File.MKNUCKLES_ANIM_IDLE,                   CUSTOM_IDLE,                        -1)
    Character.edit_action_parameters(MKNUCKLES, 0x06,                           File.MKNUCKLES_ANIM_IDLE,                   CUSTOM_IDLE,                        -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Turn,                    File.MKNUCKLES_ANIM_TURN,                   -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Jab1,                    File.MKNUCKLES_ANIM_JAB1,                   JAB1,                               -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Jab2,                    File.MKNUCKLES_ANIM_JAB2,                   JAB2,                               -1)
    Character.edit_action_parameters(MKNUCKLES, 0xDC,                           File.MKNUCKLES_ANIM_JAB3,                   JAB3,                               -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Taunt,                   File.MKNUCKLES_ANIM_TAUNT,                  TAUNT,                              -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Grab,                    File.MKNUCKLES_ANIM_GRAB,                   CUSTOM_GRAB,                        0x10000000)
    Character.edit_action_parameters(MKNUCKLES, Action.GrabPull,                File.MKNUCKLES_ANIM_GRAB_PULL,              -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.ThrowF,                  File.MKNUCKLES_ANIM_THROW_F,                CUSTOM_THROW_F,                     -1)
    Character.edit_action_parameters(MKNUCKLES, Action.ThrowB,                  File.MKNUCKLES_ANIM_THROW_B,                CUSTOM_THROW_B,                     -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Crouch,                  File.MKNUCKLES_ANIM_CROUCH,                 CROUCH,                             -1)
    Character.edit_action_parameters(MKNUCKLES, Action.CrouchIdle,              File.MKNUCKLES_ANIM_CROUCH_IDLE,            CROUCH_IDLE,                        -1)
    Character.edit_action_parameters(MKNUCKLES, Action.CrouchEnd,               File.MKNUCKLES_ANIM_CROUCH_END,             CROUCH_END,                         -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Walk1,                   File.MKNUCKLES_ANIM_WALK1,                  -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Walk2,                   File.MKNUCKLES_ANIM_WALK2,                  -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Walk3,                   File.MKNUCKLES_ANIM_WALK3,                  -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, 0x0E,                           File.MKNUCKLES_ANIM_WALK_END,               -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Dash,                    File.MKNUCKLES_ANIM_DASH,                   DASH,                               -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Run,                     File.MKNUCKLES_ANIM_RUN,                    -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.RunBrake,                File.MKNUCKLES_ANIM_RUN_BRAKE,              RUN_BRAKE,                          -1)
    Character.edit_action_parameters(MKNUCKLES, Action.TurnRun,                 File.MKNUCKLES_ANIM_RUN_TURN,               TURN_RUN,                           -1)
    Character.edit_action_parameters(MKNUCKLES, Action.DashAttack,              File.MKNUCKLES_ANIM_DASH_ATTACK,            DASH_ATTACK,                        -1)
    Character.edit_action_parameters(MKNUCKLES, Action.FTiltHigh,               File.MKNUCKLES_ANIM_TILT_F_HIGH,            FTILT,                              0x40000000)
    Character.edit_action_parameters(MKNUCKLES, Action.FTiltMidHigh,            0,                                          0x80000000,                         0)
    Character.edit_action_parameters(MKNUCKLES, Action.FTilt,                   File.MKNUCKLES_ANIM_TILT_F,                 FTILT,                              0x40000000)
    Character.edit_action_parameters(MKNUCKLES, Action.FTiltMidLow,             0,                                          0x80000000,                         0)
    Character.edit_action_parameters(MKNUCKLES, Action.FTiltLow,                File.MKNUCKLES_ANIM_TILT_F_LOW,             FTILT,                              0x40000000)
    Character.edit_action_parameters(MKNUCKLES, Action.UTilt,                   File.MKNUCKLES_ANIM_TILT_U,                 UTILT,                              -1)
    Character.edit_action_parameters(MKNUCKLES, Action.DTilt,                   File.MKNUCKLES_ANIM_TILT_D,                 DTILT,                              -1)
    Character.edit_action_parameters(MKNUCKLES, Action.FSmashHigh,              0,                                          0x80000000,                         0)
    Character.edit_action_parameters(MKNUCKLES, Action.FSmashMidHigh,           0,                                          0x80000000,                         0)
    Character.edit_action_parameters(MKNUCKLES, Action.FSmash,                  File.MKNUCKLES_ANIM_SMASH_F,                FSMASH,                             0x40000000)
    Character.edit_action_parameters(MKNUCKLES, Action.FSmashMidLow,            0,                                          0x80000000,                         0)
    Character.edit_action_parameters(MKNUCKLES, Action.FSmashLow,               0,                                          0x80000000,                         0)
    Character.edit_action_parameters(MKNUCKLES, Action.USmash,                  File.MKNUCKLES_ANIM_SMASH_U,                USMASH,                             0x40000000)
    Character.edit_action_parameters(MKNUCKLES, Action.DSmash,                  File.MKNUCKLES_ANIM_SMASH_D,                CUSTOM_DSMASH,                      0x80000000)
    Character.edit_action_parameters(MKNUCKLES, Action.AttackAirN,              File.MKNUCKLES_ANIM_ATTACK_AIR_N,           NAIR,                               -1)
    Character.edit_action_parameters(MKNUCKLES, Action.AttackAirF,              File.MKNUCKLES_ANIM_ATTACK_AIR_F,           FAIR,                               -1)
    Character.edit_action_parameters(MKNUCKLES, Action.AttackAirB,              File.MKNUCKLES_ANIM_ATTACK_AIR_B,           BAIR,                               -1)
    Character.edit_action_parameters(MKNUCKLES, Action.AttackAirU,              File.MKNUCKLES_ANIM_ATTACK_AIR_U,           UAIR,                               -1)
    Character.edit_action_parameters(MKNUCKLES, Action.AttackAirD,              File.MKNUCKLES_ANIM_ATTACK_AIR_D,           DAIR,                               -1)
    Character.edit_action_parameters(MKNUCKLES, Action.LandingAirF,             File.MKNUCKLES_ANIM_LANDING_AIR_F,          -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.LandingAirB,             File.MKNUCKLES_ANIM_LANDING_AIR_B,          -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.LandingAirD,             File.MKNUCKLES_ANIM_LANDING_AIR_D,          LANDING_AIR_D,                      -1)
    Character.edit_action_parameters(MKNUCKLES, Action.LandingAirX,             File.MKNUCKLES_ANIM_JUMPSQUAT,              -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.LandingSpecial,          File.MKNUCKLES_ANIM_JUMPSQUAT,              -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.JumpF,                   File.MKNUCKLES_ANIM_JUMP_F,                 JUMP,                               -1)
    Character.edit_action_parameters(MKNUCKLES, Action.JumpB,                   File.MKNUCKLES_ANIM_JUMP_B,                 JUMP,                               -1)
    Character.edit_action_parameters(MKNUCKLES, Action.JumpAerialF,             File.MKNUCKLES_ANIM_JUMP_AF,                JUMP_AERIAL,                        -1)
    Character.edit_action_parameters(MKNUCKLES, Action.JumpAerialB,             File.MKNUCKLES_ANIM_JUMP_AB,                JUMP_AERIAL,                        -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Fall,                    File.MKNUCKLES_ANIM_FALL,                   -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.FallAerial,              File.MKNUCKLES_ANIM_FALL_AIR,               -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.FallSpecial,             File.MKNUCKLES_ANIM_FALL_SPECIAL,           -1,                                 0x00000000)
    Character.edit_action_parameters(MKNUCKLES, Action.JumpSquat,               File.MKNUCKLES_ANIM_JUMPSQUAT,              -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.ShieldJumpSquat,         File.MKNUCKLES_ANIM_JUMPSQUAT,              -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.LandingLight,            File.MKNUCKLES_ANIM_JUMPSQUAT,              -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.LandingHeavy,            File.MKNUCKLES_ANIM_JUMPSQUAT,              -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Pass,                    File.MKNUCKLES_ANIM_PASS,                   -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.ShieldDrop,              File.MKNUCKLES_ANIM_PASS,                   -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Teeter,                  File.MKNUCKLES_ANIM_TEETER,                 TEETER,                             -1)
    Character.edit_action_parameters(MKNUCKLES, Action.TeeterStart,             File.MKNUCKLES_ANIM_TEETER_START,           TEETER_VOICE,                       -1)
    Character.edit_action_parameters(MKNUCKLES, Action.DamageAir1,              File.MKNUCKLES_ANIM_DMG_AIR_1,              -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.ShieldBreak,             -1,                                         SHIELD_BREAK,                       -1)
    Character.edit_action_parameters(MKNUCKLES, Action.RollF,                   File.MKNUCKLES_ANIM_ROLL_F,                 ROLL_F,                             -1)
    Character.edit_action_parameters(MKNUCKLES, Action.RollB,                   File.MKNUCKLES_ANIM_ROLL_B,                 ROLL_B,                             -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Spring,                  File.MKNUCKLES_ANIM_USP,                    USP,                                0x00000000)
    Character.edit_action_parameters(MKNUCKLES, Action.DiveGround,              File.MKNUCKLES_ANIM_DIVE_G,                 DIVE_GROUND,                        0x00000000)
    Character.edit_action_parameters(MKNUCKLES, Action.DiveAirBegin,            File.MKNUCKLES_ANIM_DIVE_A_BEGIN,           DIVE_AIR_BEGIN,                     0x00000000)
    Character.edit_action_parameters(MKNUCKLES, Action.DiveAirLoop,             File.MKNUCKLES_ANIM_DIVE_A_LOOP,            DIVE_AIR_LOOP,                      0x00000000)
    Character.edit_action_parameters(MKNUCKLES, Action.DiveLand,                File.MKNUCKLES_ANIM_DIVE_A_LAND,            DIVE_LAND,                          0x00000000)
    Character.edit_action_parameters(MKNUCKLES, Action.Stun,                    File.MKNUCKLES_ANIM_STUN,                   CUSTOM_STUN,                        -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Sleep,                   File.MKNUCKLES_ANIM_STUN,                   CUSTOM_SLEEP,                       -1)
    Character.edit_action_parameters(MKNUCKLES, Action.Tech,                    File.MKNUCKLES_ANIM_TECH,                   TECH,                               0x00000000)
    Character.edit_action_parameters(MKNUCKLES, Action.TechF,                   -1,                                         TECH_F,                             -1)
    Character.edit_action_parameters(MKNUCKLES, Action.TechB,                   -1,                                         TECH_F,                             -1)
    Character.edit_action_parameters(MKNUCKLES, Action.DownAttackU,             File.MKNUCKLES_ANIM_DOWNATTACK_U,           DOWNATTACK_U,                       0x00000000)
    Character.edit_action_parameters(MKNUCKLES, Action.DownStandU,              File.MKNUCKLES_ANIM_DOWNSTAND_U,            -1,                                 0x00000000)
    Character.edit_action_parameters(MKNUCKLES, Action.DownBounceU,             File.MKNUCKLES_ANIM_DOWNBOUNCE_U,           -1,                                 0x00000000)
    Character.edit_action_parameters(MKNUCKLES, Action.DamageElec1,             File.MKNUCKLES_ANIM_DMG_ELEC,               -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.DamageElec2,             File.MKNUCKLES_ANIM_DMG_ELEC,               -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.EnterPipe,               File.MKNUCKLES_ANIM_PIPE_ENTER,             -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.ExitPipe,                File.MKNUCKLES_ANIM_PIPE_EXIT,              -1,                                 -1)

    Character.edit_action_parameters(MKNUCKLES, Action.CliffCatch,              File.MKNUCKLES_ANIM_CLIFF_CATCH,            -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.CliffWait,               File.MKNUCKLES_ANIM_CLIFF_WAIT,             -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.CliffQuick,              File.MKNUCKLES_ANIM_CLIFF_QUICK,            -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.CliffClimbQuick1,        File.MKNUCKLES_ANIM_CLIFF_CLIMB_QUICK_1,    -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.CliffClimbQuick2,        File.MKNUCKLES_ANIM_CLIFF_CLIMB_QUICK_2,    -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.CliffEscapeQuick1,       File.MKNUCKLES_ANIM_CLIFF_ESCAPE_QUICK_1,   -1,                                 0x40000000)
    Character.edit_action_parameters(MKNUCKLES, Action.CliffEscapeQuick2,       File.MKNUCKLES_ANIM_CLIFF_ESCAPE_QUICK_2,   -1,                                 0x40000000)
    Character.edit_action_parameters(MKNUCKLES, Action.CliffAttackQuick1,       File.MKNUCKLES_ANIM_CLIFF_QUICK_ATTACK_1,   -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.CliffAttackQuick2,       File.MKNUCKLES_ANIM_CLIFF_QUICK_ATTACK_2,   CLIFF_ATTACK2,                      -1)
    Character.edit_action_parameters(MKNUCKLES, Action.CliffSlow,               File.MKNUCKLES_ANIM_CLIFF_SLOW,             -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.CliffClimbSlow1,         File.MKNUCKLES_ANIM_CLIFF_CLIMB_SLOW_1,     -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.CliffClimbSlow2,         File.MKNUCKLES_ANIM_CLIFF_CLIMB_SLOW_2,     -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.CliffAttackSlow1,        File.MKNUCKLES_ANIM_CLIFF_SLOW_ATTACK_1,    -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.CliffAttackSlow2,        File.MKNUCKLES_ANIM_CLIFF_SLOW_ATTACK_2,    CLIFF_SLOW_ATTACK2,                 -1)

    Character.edit_action_parameters(MKNUCKLES, Action.RayGunShoot,             File.MKNUCKLES_ANIM_ITEM_SHOOT,             ITEM_SHOOT,                         0x00000000)
    Character.edit_action_parameters(MKNUCKLES, Action.RayGunShootAir,          File.MKNUCKLES_ANIM_ITEM_SHOOT_AIR,         ITEM_SHOOT,                         0x00000000)
    Character.edit_action_parameters(MKNUCKLES, Action.FireFlowerShoot,         File.MKNUCKLES_ANIM_ITEM_SHOOT,             ITEM_SHOOT,                         0x00000000)
    Character.edit_action_parameters(MKNUCKLES, Action.FireFlowerShootAir,      File.MKNUCKLES_ANIM_ITEM_SHOOT_AIR,         ITEM_SHOOT,                         0x00000000)

    Character.edit_action_parameters(MKNUCKLES, Action.ItemDrop,                File.MKNUCKLES_ANIM_ITEM_DROP,              -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.HeavyItemPickup,         File.MKNUCKLES_ANIM_ITEM_HEAVY_PICKUP,      -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.HeavyItemThrowF,         File.MKNUCKLES_ANIM_ITEM_HEAVY_THROW,       HEAVY_ITEM_THROW,                   -1)
    Character.edit_action_parameters(MKNUCKLES, Action.HeavyItemThrowSmashF,    File.MKNUCKLES_ANIM_ITEM_HEAVY_THROW,       HEAVY_ITEM_SMASH_THROW,             -1)
    Character.edit_action_parameters(MKNUCKLES, Action.HeavyItemThrowSmashB,    File.MKNUCKLES_ANIM_ITEM_HEAVY_THROW,       HEAVY_ITEM_SMASH_THROW,             -1)

    Character.edit_action_parameters(MKNUCKLES, Action.BatNeutral,              File.MKNUCKLES_ANIM_ITEM_NEUTRAL,           -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.BatSmash,                File.MKNUCKLES_ANIM_SWING_SMASH,            -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.BatTilt,                 File.MKNUCKLES_ANIM_SWING_TILT,             -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.BatDash,                 File.MKNUCKLES_ANIM_ITEM_DASH_ATTACK,       BAT_DASH,                           0x40000000)

    Character.edit_action_parameters(MKNUCKLES, Action.FanNeutral,              File.MKNUCKLES_ANIM_ITEM_NEUTRAL,           -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.FanSmash,                File.MKNUCKLES_ANIM_SWING_SMASH,            -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.FanTilt,                 File.MKNUCKLES_ANIM_SWING_TILT,             -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.FanDash,                 File.MKNUCKLES_ANIM_ITEM_DASH_ATTACK,       FAN_DASH,                           0x40000000)

    Character.edit_action_parameters(MKNUCKLES, Action.StarRodNeutral,          File.MKNUCKLES_ANIM_ITEM_NEUTRAL,           -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.StarRodSmash,            File.MKNUCKLES_ANIM_SWING_SMASH,            -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.StarRodTilt,             File.MKNUCKLES_ANIM_SWING_TILT,             -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.StarRodDash,             File.MKNUCKLES_ANIM_ITEM_DASH_ATTACK,       STARROD_DASH,                       0x40000000)

    Character.edit_action_parameters(MKNUCKLES, Action.BeamSwordNeutral,        File.MKNUCKLES_ANIM_ITEM_NEUTRAL,           -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.BeamSwordSmash,          File.MKNUCKLES_ANIM_SWING_SMASH,            -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.BeamSwordTilt,           File.MKNUCKLES_ANIM_SWING_TILT,             -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.BeamSwordDash,           File.MKNUCKLES_ANIM_ITEM_DASH_ATTACK,       BEAMSWORD_DASH,                     0x40000000)

    Character.edit_action_parameters(MKNUCKLES, Action.HammerIdle,              File.MKNUCKLES_ANIM_HAMMER_IDLE,            -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.HammerWalk,              File.MKNUCKLES_ANIM_HAMMER_WALK,            -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.HammerTurn,              File.MKNUCKLES_ANIM_HAMMER_WALK,            -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.HammerJumpSquat,         File.MKNUCKLES_ANIM_HAMMER_WALK,            -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.HammerAir,               File.MKNUCKLES_ANIM_HAMMER_WALK,            -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.HammerLanding,           File.MKNUCKLES_ANIM_HAMMER_WALK,            -1,                                 -1)

    Character.edit_action_parameters(MKNUCKLES, Action.ItemThrowF,              File.MKNUCKLES_ANIM_ITEM_THROW_F,           -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.ItemThrowB,              File.MKNUCKLES_ANIM_ITEM_THROW_F,           -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.ItemThrowU,              File.MKNUCKLES_ANIM_ITEM_THROW_U,           -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.ItemThrowD,              File.MKNUCKLES_ANIM_ITEM_THROW_D,           -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.ItemThrowSmashF,         File.MKNUCKLES_ANIM_ITEM_THROW_F,           -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.ItemThrowSmashB,         File.MKNUCKLES_ANIM_ITEM_THROW_F,           -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.ItemThrowSmashU,         File.MKNUCKLES_ANIM_ITEM_THROW_U,           -1,                                 -1)
    Character.edit_action_parameters(MKNUCKLES, Action.ItemThrowSmashD,         File.MKNUCKLES_ANIM_ITEM_THROW_D,           -1,                                 -1)

    // Modify Menu Action Parameters                 // Action      // Animation                        // Moveset Data         // Flags
    Character.edit_menu_action_parameters(MKNUCKLES, 0x0,           File.MKNUCKLES_ANIM_IDLE,           CUSTOM_IDLE,            -1)
    Character.edit_menu_action_parameters(MKNUCKLES, 0x1,           File.MKNUCKLES_ANIM_VICTORY1,       VICTORY1,               -1)
    Character.edit_menu_action_parameters(MKNUCKLES, 0x2,           File.MKNUCKLES_ANIM_VICTORY2,       VICTORY2,               -1)
    Character.edit_menu_action_parameters(MKNUCKLES, 0x3,           File.MKNUCKLES_ANIM_CSS,            CSS,                    -1)
    Character.edit_menu_action_parameters(MKNUCKLES, 0x4,           File.MKNUCKLES_ANIM_CSS,            CSS,                    -1)
    Character.edit_menu_action_parameters(MKNUCKLES, 0x5,           File.MKNUCKLES_ANIM_CLAP,           CLAP,                   -1)
    Character.edit_menu_action_parameters(MKNUCKLES, 0x9,           File.MKNUCKLES_ANIM_PUPPET_FALL,    -1,                     -1)
    Character.edit_menu_action_parameters(MKNUCKLES, 0xA,           File.MKNUCKLES_ANIM_PUPPET_REVIVE,  -1,                     -1)
    Character.edit_menu_action_parameters(MKNUCKLES, 0xD,           File.MKNUCKLES_ANIM_1P_POSE,        SPPOSE,                 -1)
    Character.edit_menu_action_parameters(MKNUCKLES, 0xE,           File.MKNUCKLES_ANIM_1P_CPU_POSE,    CPU_POSE,               -1)

    // Modify Actions                // Action              // Staling ID   // Main ASM                    // Interrupt/Other ASM      // Movement/Physics ASM         // Collision ASM
    Character.edit_action(MKNUCKLES, 0xDC,                  -1,             0x8014FE40,                    0x00000000,                 0x800D8CCC,                     0x800DDF44)                        // Jab3
    Character.edit_action(MKNUCKLES, Action.Spring,         -1,             MKnucklesUSP.main_air_,        MKnucklesUSP.interrupt_,    MKnucklesUSP.air_physics_,      0x800DE99C)                        // USP

    Character.edit_action(MKNUCKLES, Action.DiveGround,     -1,             MKnucklesDive.grounded_main_,  MKnucklesDive.ground_move_, MKnucklesDive.ground_physics_,  MKnucklesDive.ground_collision_)   // Dive Punch Ground
    Character.edit_action(MKNUCKLES, Action.DiveAirBegin,   0x1E,           MKnucklesDive.aerial_main_,    MKnucklesDive.air_move_,    MKnucklesDive.air_physics_,     MKnucklesDive.air_collision_)      // Dive Punch Air Begin
    Character.edit_action(MKNUCKLES, Action.DiveAirLoop,    0x1E,           0x00000000,                    MKnucklesDive.air_move_,    MKnucklesDive.air_physics_,     MKnucklesDive.air_collision_)      // Dive Punch Air Loop
    Character.edit_action(MKNUCKLES, Action.DiveLand,       0x1E,           0x800D94C4,                    0,                          0x800D8BB4,                     0x800DDF44)                        // Dive Punch Air Landing

    // Add Action Parameters                   // Action Name       // Base Action  // Animation                        // Moveset Data             // Flags
    Character.add_new_action_params(MKNUCKLES, NSP_Climb_Wait,      -1,             File.MKNUCKLES_ANIM_CLIMB_UP,       0x80000000,                 0)
    Character.add_new_action_params(MKNUCKLES, NSP_Climb_MoveUp,    -1,             File.MKNUCKLES_ANIM_CLIMB_UP,       0x80000000,                 0)
    Character.add_new_action_params(MKNUCKLES, NSP_Climb_MoveDown,  -1,             File.MKNUCKLES_ANIM_CLIMB_DOWN,     0x80000000,                 0)
    Character.add_new_action_params(MKNUCKLES, NSP_Turn,            -1,             File.MKNUCKLES_ANIM_GLIDE_WAIT,     CUSTOM_IDLE,                0)
    Character.add_new_action_params(MKNUCKLES, NSP_Air_Wait,        -1,             File.MKNUCKLES_ANIM_GLIDE_WAIT,     CUSTOM_IDLE,                0)
    Character.add_new_action_params(MKNUCKLES, NSP_Air_Begin,       -1,             File.MKNUCKLES_ANIM_GLIDE_START,    CUSTOM_IDLE,                0)
    Character.add_new_action_params(MKNUCKLES, NSP_Air_End,         -1,             File.MKNUCKLES_ANIM_GLIDE_END,      CUSTOM_IDLE,                0)
    Character.add_new_action_params(MKNUCKLES, DSP_Ground_Charge,   -1,             File.SONIC_CHARGE_LOOP,             CUSTOM_DSP_CHARGE,          0)
    Character.add_new_action_params(MKNUCKLES, DSP_Ground_Move,     -1,             File.SONIC_SPIN_LOOP_FAST,          CUSTOM_DSP_MOVE,            0x10000000)
    Character.add_new_action_params(MKNUCKLES, DSP_Ground_End,      -1,             File.SONIC_CROUCH_END,              0x80000000,                 0)
    Character.add_new_action_params(MKNUCKLES, DSP_Air_Charge,      -1,             File.SONIC_CHARGE_LOOP,             CUSTOM_DSP_AIR_CHARGE,      0)
    Character.add_new_action_params(MKNUCKLES, DSP_Air_Move,        -1,             File.SONIC_JUMP_F,                  CUSTOM_DSP_AIR_MOVE,        0)
    Character.add_new_action_params(MKNUCKLES, DSP_Air_Jump,        -1,             File.SONIC_JUMP_F,                  CUSTOM_DSP_AIR_JUMP,        0)
    Character.add_new_action_params(MKNUCKLES, DSP_Air_End,         -1,             File.SONIC_NSP_FINISH,              0x80000000,                 0)

    // Add Actions                      // Action Name      // Base Action  // Parameters                       // Staling ID   // Main ASM                       // Interrupt/Other ASM                   // Movement/Physics ASM              // Collision ASM
    Character.add_new_action(MKNUCKLES, NSP_Climb_Wait,     -1,             ActionParams.NSP_Climb_Wait,        0x12,           MKnucklesClimb.climb_common_main_, MKnucklesClimb.climb_wait_interrupt_,     MKnucklesClimb.climb_jostle_physics_, MKnucklesClimb.climb_common_collision_)
    Character.add_new_action(MKNUCKLES, NSP_Climb_MoveUp,   -1,             ActionParams.NSP_Climb_MoveUp,      0x12,           MKnucklesClimb.climb_common_main_, MKnucklesClimb.climb_moveup_interrupt_,   MKnucklesClimb.climb_move_physics_,   MKnucklesClimb.climb_common_collision_)
    Character.add_new_action(MKNUCKLES, NSP_Climb_MoveDown, -1,             ActionParams.NSP_Climb_MoveDown,    0x12,           MKnucklesClimb.climb_common_main_, MKnucklesClimb.climb_movedown_interrupt_, MKnucklesClimb.climb_move_physics_,   MKnucklesClimb.climb_common_collision_)
    Character.add_new_action(MKNUCKLES, NSP_Turn,           -1,             ActionParams.NSP_Turn,              0x12,           MKnucklesNSP.air_turn_main_,       MKnucklesNSP.air_common_interrupt_,       MKnucklesNSP.turn_physics_,           MKnucklesNSP.air_common_collision_)
    Character.add_new_action(MKNUCKLES, NSP_Air_Begin,      -1,             ActionParams.NSP_Air_Begin,         0x12,           MKnucklesNSP.air_begin_main_,      0,                                        MKnucklesNSP.air_physics_,            MKnucklesNSP.air_common_collision_)
    Character.add_new_action(MKNUCKLES, NSP_Air_Wait,       -1,             ActionParams.NSP_Air_Wait,          0x12,           MKnucklesNSP.air_wait_main_,       MKnucklesNSP.air_common_interrupt_,       MKnucklesNSP.air_physics_,            MKnucklesNSP.air_common_collision_)
    Character.add_new_action(MKNUCKLES, NSP_Air_End,        -1,             ActionParams.NSP_Air_End,           0x12,           MKnucklesNSP.end_main_,            MKnucklesNSP.air_common_interrupt_,       0x800D90E0,                           0x800DE99C)
    Character.add_new_action(MKNUCKLES, DSP_Ground_Charge,  -1,             ActionParams.DSP_Ground_Charge,     0x1E,           MKnucklesDSP.ground_charge_main_,  0,                                        0x800D8BB4,                           MKnucklesDSP.ground_charge_collision_)
    Character.add_new_action(MKNUCKLES, DSP_Ground_Move,    -1,             ActionParams.DSP_Ground_Move,       0x1E,           MKnucklesDSP.ground_move_main_,    0,                                        MKnucklesDSP.ground_move_physics_,    MKnucklesDSP.ground_move_collision_)
    Character.add_new_action(MKNUCKLES, DSP_Ground_End,     -1,             ActionParams.DSP_Ground_End,        0x1E,           0x800D94C4,                        0,                                        0x800D8BB4,                           MKnucklesDSP.ground_end_collision_)
    Character.add_new_action(MKNUCKLES, DSP_Air_Charge,     -1,             ActionParams.DSP_Air_Charge,        0x1E,           MKnucklesDSP.air_charge_main_,     0,                                        0x800D91EC,                           MKnucklesDSP.air_charge_collision_)
    Character.add_new_action(MKNUCKLES, DSP_Air_Move,       -1,             ActionParams.DSP_Air_Move,          0x1E,           MKnucklesDSP.air_move_main_,       MKnucklesDSP.air_move_interrupt_,         MKnucklesDSP.air_movement_physics_,   MKnucklesDSP.air_move_collision_)
    Character.add_new_action(MKNUCKLES, DSP_Air_Jump,       -1,             ActionParams.DSP_Air_Jump,          0x1E,           MKnucklesDSP.air_move_main_,       MKnucklesDSP.air_move_interrupt_,         MKnucklesDSP.air_movement_physics_,   MKnucklesDSP.air_move_collision_)
    Character.add_new_action(MKNUCKLES, DSP_Air_End,        -1,             ActionParams.DSP_Air_End,           0x1E,           0x800D94E8,                        0,                                        0x800D91EC,                           MKnucklesDSP.air_end_collision_)

    scope DPad {
        if {defined Character.CHARACTER_ADDED_CBKNUCKLES} {
            constant LEFT(Character.id.CBKNUCKLES)
        } else {
            constant LEFT(Character.id.NONE)
        }

        if {defined Character.CHARACTER_ADDED_KNUCKLES} {
            constant UP(Character.id.KNUCKLES)
        } else {
            constant UP(Character.id.NONE)
        }

        if {defined Character.CHARACTER_ADDED_CBMKNUCKLES} {
            constant RIGHT(Character.id.CBMKNUCKLES)
        } else {
            constant RIGHT(Character.id.NONE)
        }

        constant DOWN(Character.id.NONE)
    }

    Character.table_patch_start(variants, Character.id.MKNUCKLES, 0x4)
    db      DPad.UP    // set as SPECIAL variant for KNUCKLES
    db      DPad.DOWN
    db      DPad.LEFT  // set as SPECIAL variant for COWBOY KNUCKLES
    db      DPad.RIGHT // set as SPECIAL variant for COWBOY MODERN KNUCKLES
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.MKNUCKLES, 0x2)
    dh FGM.CHANT
    OS.patch_end()

    // Set rare death FGM
    Character.table_patch_start(rare_death_fgm, Character.id.MKNUCKLES, 0x4)
    dh FGM.OH_NO    // Rare Death FGM ID
    dh 5            // 1/5 chance
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.MKNUCKLES, 0x4)
    dw Action.action_string_table
    OS.patch_end()

    // Set entry script
    Character.table_patch_start(entry_script, Character.id.MKNUCKLES, 0x4)
    dw 0x8013DD68   // skips entry script
    OS.patch_end()

    // Set initial script
    Character.table_patch_start(initial_script, Character.id.MKNUCKLES, 0x4)
    dw initial_script_
    OS.patch_end()

    // Set grounded script
    Character.table_patch_start(grounded_script, Character.id.MKNUCKLES, 0x4)
    dw grounded_script_
    OS.patch_end()

    scope initial_script_: {
        j       0x800D7F0C                      // back to original routine
        sw      r0, 0x0AE0(v1)                  // clear glide flag
    }

    scope grounded_script_: {
        j       0x800DE428                      // back to original routine
        sw      r0, 0x0AE0(v0)                  // clear glide flag
    }

    Character.table_patch_start(ground_usp, Character.id.MKNUCKLES, 0x4)
    dw      MKnucklesUSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.MKNUCKLES, 0x4)
    dw      MKnucklesUSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(ground_nsp, Character.id.MKNUCKLES, 0x4)
    dw      MKnucklesDive.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_nsp, Character.id.MKNUCKLES, 0x4)
    dw      MKnucklesNSP.air_begin_initial_
    OS.patch_end()

    Character.table_patch_start(ground_dsp, Character.id.MKNUCKLES, 0x4)
    dw      MKnucklesDSP.ground_charge_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.MKNUCKLES, 0x4)
    dw      MKnucklesDSP.air_charge_initial_
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.MKNUCKLES, 0, 2, 1, 3, 0, 1, 2)
    Teams.add_team_costume(YELLOW, MKNUCKLES, 0x4)

    // Set default costume shield colors
    Character.set_costume_shield_colors(MKNUCKLES, RED, CYAN, GREEN, LIME, ORANGE, PURPLE, GREEN, YELLOW)
}