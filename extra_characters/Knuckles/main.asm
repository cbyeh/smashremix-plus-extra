include "./KnucklesSpecial.asm"
include "./AI.asm"

scope Knuckles {
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
    dw 0x380003DE                                   // Spindash SFX
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

    // Modify Action Parameters                // Action                        // Animation                                // Moveset Data                     // Flags
    Character.edit_action_parameters(KNUCKLES, 0xDF,                            File.KNUCKLES_ANIM_ENTRY_LEFT,              0,                                  -1)
    Character.edit_action_parameters(KNUCKLES, 0xE0,                            File.KNUCKLES_ANIM_ENTRY_RIGHT,             0,                                  -1)
    Character.edit_action_parameters(KNUCKLES, Action.Idle,                     File.KNUCKLES_ANIM_IDLE,                    CUSTOM_IDLE,                        -1)
    Character.edit_action_parameters(KNUCKLES, Action.Entry,                    File.KNUCKLES_ANIM_IDLE,                    CUSTOM_IDLE,                        -1)
    Character.edit_action_parameters(KNUCKLES, Action.ReviveWait,               File.KNUCKLES_ANIM_IDLE,                    CUSTOM_IDLE,                        -1)
    Character.edit_action_parameters(KNUCKLES, 0x06,                            File.KNUCKLES_ANIM_IDLE,                    CUSTOM_IDLE,                        -1)
    Character.edit_action_parameters(KNUCKLES, Action.Turn,                     File.KNUCKLES_ANIM_TURN,                    -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.Jab1,                     File.KNUCKLES_ANIM_JAB1,                    JAB1,                               -1)
    Character.edit_action_parameters(KNUCKLES, Action.Jab2,                     File.KNUCKLES_ANIM_JAB2,                    JAB2,                               -1)
    Character.edit_action_parameters(KNUCKLES, 0xDC,                            File.KNUCKLES_ANIM_JAB3,                    JAB3,                               -1)
    Character.edit_action_parameters(KNUCKLES, Action.Taunt,                    File.KNUCKLES_ANIM_TAUNT,                   TAUNT,                              -1)
    Character.edit_action_parameters(KNUCKLES, Action.Grab,                     File.KNUCKLES_ANIM_GRAB,                    CUSTOM_GRAB,                        0x10000000)
    Character.edit_action_parameters(KNUCKLES, Action.GrabPull,                 File.KNUCKLES_ANIM_GRAB_PULL,               -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.ThrowF,                   File.KNUCKLES_ANIM_THROW_F,                 CUSTOM_THROW_F,                     -1)
    Character.edit_action_parameters(KNUCKLES, Action.ThrowB,                   File.KNUCKLES_ANIM_THROW_B,                 CUSTOM_THROW_B,                     -1)
    Character.edit_action_parameters(KNUCKLES, Action.Crouch,                   File.KNUCKLES_ANIM_CROUCH,                  CROUCH,                             -1)
    Character.edit_action_parameters(KNUCKLES, Action.CrouchIdle,               File.KNUCKLES_ANIM_CROUCH_IDLE,             CROUCH_IDLE,                        -1)
    Character.edit_action_parameters(KNUCKLES, Action.CrouchEnd,                File.KNUCKLES_ANIM_CROUCH_END,              CROUCH_END,                         -1)
    Character.edit_action_parameters(KNUCKLES, Action.Walk1,                    File.KNUCKLES_ANIM_WALK1,                   -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.Walk2,                    File.KNUCKLES_ANIM_WALK2,                   -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.Walk3,                    File.KNUCKLES_ANIM_WALK3,                   -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, 0x0E,                            File.KNUCKLES_ANIM_WALK_END,                -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.Dash,                     File.KNUCKLES_ANIM_DASH,                    DASH,                               -1)
    Character.edit_action_parameters(KNUCKLES, Action.Run,                      File.KNUCKLES_ANIM_RUN,                     -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.RunBrake,                 File.KNUCKLES_ANIM_RUN_BRAKE,               RUN_BRAKE,                          -1)
    Character.edit_action_parameters(KNUCKLES, Action.TurnRun,                  File.KNUCKLES_ANIM_RUN_TURN,                TURN_RUN,                           -1)
    Character.edit_action_parameters(KNUCKLES, Action.DashAttack,               File.KNUCKLES_ANIM_DASH_ATTACK,             DASH_ATTACK,                        -1)
    Character.edit_action_parameters(KNUCKLES, Action.FTiltHigh,                File.KNUCKLES_ANIM_TILT_F_HIGH,             FTILT,                              0x40000000)
    Character.edit_action_parameters(KNUCKLES, Action.FTiltMidHigh,             0,                                          0x80000000,                         0)
    Character.edit_action_parameters(KNUCKLES, Action.FTilt,                    File.KNUCKLES_ANIM_TILT_F,                  FTILT,                              0x40000000)
    Character.edit_action_parameters(KNUCKLES, Action.FTiltMidLow,              0,                                          0x80000000,                         0)
    Character.edit_action_parameters(KNUCKLES, Action.FTiltLow,                 File.KNUCKLES_ANIM_TILT_F_LOW,              FTILT,                              0x40000000)
    Character.edit_action_parameters(KNUCKLES, Action.UTilt,                    File.KNUCKLES_ANIM_TILT_U,                  UTILT,                              -1)
    Character.edit_action_parameters(KNUCKLES, Action.DTilt,                    File.KNUCKLES_ANIM_TILT_D,                  DTILT,                              -1)
    Character.edit_action_parameters(KNUCKLES, Action.FSmashHigh,               0,                                          0x80000000,                         0)
    Character.edit_action_parameters(KNUCKLES, Action.FSmashMidHigh,            0,                                          0x80000000,                         0)
    Character.edit_action_parameters(KNUCKLES, Action.FSmash,                   File.KNUCKLES_ANIM_SMASH_F,                 FSMASH,                             0x40000000)
    Character.edit_action_parameters(KNUCKLES, Action.FSmashMidLow,             0,                                          0x80000000,                         0)
    Character.edit_action_parameters(KNUCKLES, Action.FSmashLow,                0,                                          0x80000000,                         0)
    Character.edit_action_parameters(KNUCKLES, Action.USmash,                   File.KNUCKLES_ANIM_SMASH_U,                 USMASH,                             0x40000000)
    Character.edit_action_parameters(KNUCKLES, Action.DSmash,                   File.KNUCKLES_ANIM_SMASH_D,                 CUSTOM_DSMASH,                      0x80000000)
    Character.edit_action_parameters(KNUCKLES, Action.AttackAirN,               File.KNUCKLES_ANIM_ATTACK_AIR_N,            NAIR,                               -1)
    Character.edit_action_parameters(KNUCKLES, Action.AttackAirF,               File.KNUCKLES_ANIM_ATTACK_AIR_F,            FAIR,                               -1)
    Character.edit_action_parameters(KNUCKLES, Action.AttackAirB,               File.KNUCKLES_ANIM_ATTACK_AIR_B,            BAIR,                               -1)
    Character.edit_action_parameters(KNUCKLES, Action.AttackAirU,               File.KNUCKLES_ANIM_ATTACK_AIR_U,            UAIR,                               -1)
    Character.edit_action_parameters(KNUCKLES, Action.AttackAirD,               File.KNUCKLES_ANIM_ATTACK_AIR_D,            DAIR,                               -1)
    Character.edit_action_parameters(KNUCKLES, Action.LandingAirF,              File.KNUCKLES_ANIM_LANDING_AIR_F,           -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.LandingAirB,              File.KNUCKLES_ANIM_LANDING_AIR_B,           -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.LandingAirD,              File.KNUCKLES_ANIM_LANDING_AIR_D,           LANDING_AIR_D,                      -1)
    Character.edit_action_parameters(KNUCKLES, Action.LandingAirX,              File.KNUCKLES_ANIM_JUMPSQUAT,               -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.LandingSpecial,           File.KNUCKLES_ANIM_JUMPSQUAT,               -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.JumpF,                    File.KNUCKLES_ANIM_JUMP_F,                  JUMP,                               -1)
    Character.edit_action_parameters(KNUCKLES, Action.JumpB,                    File.KNUCKLES_ANIM_JUMP_B,                  JUMP,                               -1)
    Character.edit_action_parameters(KNUCKLES, Action.JumpAerialF,              File.KNUCKLES_ANIM_JUMP_AF,                 JUMP_AERIAL,                        -1)
    Character.edit_action_parameters(KNUCKLES, Action.JumpAerialB,              File.KNUCKLES_ANIM_JUMP_AB,                 JUMP_AERIAL,                        -1)
    Character.edit_action_parameters(KNUCKLES, Action.Fall,                     File.KNUCKLES_ANIM_FALL,                    -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.FallAerial,               File.KNUCKLES_ANIM_FALL_AIR,                -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.FallSpecial,              File.KNUCKLES_ANIM_FALL_SPECIAL,            -1,                                 0x00000000)
    Character.edit_action_parameters(KNUCKLES, Action.JumpSquat,                File.KNUCKLES_ANIM_JUMPSQUAT,               -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.ShieldJumpSquat,          File.KNUCKLES_ANIM_JUMPSQUAT,               -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.LandingLight,             File.KNUCKLES_ANIM_JUMPSQUAT,               -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.LandingHeavy,             File.KNUCKLES_ANIM_JUMPSQUAT,               -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.Pass,                     File.KNUCKLES_ANIM_PASS,                    -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.ShieldDrop,               File.KNUCKLES_ANIM_PASS,                    -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.Teeter,                   File.KNUCKLES_ANIM_TEETER,                  TEETER,                             -1)
    Character.edit_action_parameters(KNUCKLES, Action.TeeterStart,              File.KNUCKLES_ANIM_TEETER_START,            TEETER,                             -1)
    Character.edit_action_parameters(KNUCKLES, Action.DamageAir1,               File.KNUCKLES_ANIM_DMG_AIR_1,               -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.ShieldBreak,              -1,                                         SHIELD_BREAK,                       -1)
    Character.edit_action_parameters(KNUCKLES, Action.RollF,                    File.KNUCKLES_ANIM_ROLL_F,                  ROLL_F,                             -1)
    Character.edit_action_parameters(KNUCKLES, Action.RollB,                    File.KNUCKLES_ANIM_ROLL_B,                  ROLL_B,                             -1)
    Character.edit_action_parameters(KNUCKLES, Action.Spring,                   File.KNUCKLES_ANIM_USP,                     USP,                                0x00000000)
    Character.edit_action_parameters(KNUCKLES, Action.DiveGround,               File.KNUCKLES_ANIM_DIVE_G,                  DIVE_GROUND,                        0x00000000)
    Character.edit_action_parameters(KNUCKLES, Action.DiveAirBegin,             File.KNUCKLES_ANIM_DIVE_A_BEGIN,            DIVE_AIR_BEGIN,                     0x00000000)
    Character.edit_action_parameters(KNUCKLES, Action.DiveAirLoop,              File.KNUCKLES_ANIM_DIVE_A_LOOP,             DIVE_AIR_LOOP,                      0x00000000)
    Character.edit_action_parameters(KNUCKLES, Action.DiveLand,                 File.KNUCKLES_ANIM_DIVE_A_LAND,             DIVE_LAND,                          0x00000000)
    Character.edit_action_parameters(KNUCKLES, Action.Stun,                     File.KNUCKLES_ANIM_STUN,                    CUSTOM_STUN,                        -1)
    Character.edit_action_parameters(KNUCKLES, Action.Sleep,                    File.KNUCKLES_ANIM_STUN,                    CUSTOM_SLEEP,                       -1)
    Character.edit_action_parameters(KNUCKLES, Action.Tech,                     File.KNUCKLES_ANIM_TECH,                    TECH,                               0x00000000)
    Character.edit_action_parameters(KNUCKLES, Action.TechF,                    -1,                                         TECH_F,                             -1)
    Character.edit_action_parameters(KNUCKLES, Action.TechB,                    -1,                                         TECH_F,                             -1)
    Character.edit_action_parameters(KNUCKLES, Action.DownAttackU,              File.KNUCKLES_ANIM_DOWNATTACK_U,            DOWNATTACK_U,                       0x00000000)
    Character.edit_action_parameters(KNUCKLES, Action.DownStandU,               File.KNUCKLES_ANIM_DOWNSTAND_U,             -1,                                 0x00000000)
    Character.edit_action_parameters(KNUCKLES, Action.DownBounceU,              File.KNUCKLES_ANIM_DOWNBOUNCE_U,            -1,                                 0x00000000)
    Character.edit_action_parameters(KNUCKLES, Action.DamageElec1,              File.KNUCKLES_ANIM_DMG_ELEC,                -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.DamageElec2,              File.KNUCKLES_ANIM_DMG_ELEC,                -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.EnterPipe,                File.KNUCKLES_ANIM_PIPE_ENTER,              -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.ExitPipe,                 File.KNUCKLES_ANIM_PIPE_EXIT,               -1,                                 -1)

    Character.edit_action_parameters(KNUCKLES, Action.CliffCatch,               File.KNUCKLES_ANIM_CLIFF_CATCH,             -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.CliffWait,                File.KNUCKLES_ANIM_CLIFF_WAIT,              -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.CliffQuick,               File.KNUCKLES_ANIM_CLIFF_QUICK,             -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.CliffClimbQuick1,         File.KNUCKLES_ANIM_CLIFF_CLIMB_QUICK_1,     -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.CliffClimbQuick2,         File.KNUCKLES_ANIM_CLIFF_CLIMB_QUICK_2,     -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.CliffEscapeQuick1,        File.KNUCKLES_ANIM_CLIFF_ESCAPE_QUICK_1,    -1,                                 0x40000000)
    Character.edit_action_parameters(KNUCKLES, Action.CliffEscapeQuick2,        File.KNUCKLES_ANIM_CLIFF_ESCAPE_QUICK_2,    -1,                                 0x40000000)
    Character.edit_action_parameters(KNUCKLES, Action.CliffAttackQuick1,        File.KNUCKLES_ANIM_CLIFF_QUICK_ATTACK_1,    -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.CliffAttackQuick2,        File.KNUCKLES_ANIM_CLIFF_QUICK_ATTACK_2,    CLIFF_ATTACK2,                      -1)
    Character.edit_action_parameters(KNUCKLES, Action.CliffSlow,                File.KNUCKLES_ANIM_CLIFF_SLOW,              -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.CliffClimbSlow1,          File.KNUCKLES_ANIM_CLIFF_CLIMB_SLOW_1,      -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.CliffClimbSlow2,          File.KNUCKLES_ANIM_CLIFF_CLIMB_SLOW_2,      -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.CliffAttackSlow1,         File.KNUCKLES_ANIM_CLIFF_SLOW_ATTACK_1,     -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.CliffAttackSlow2,         File.KNUCKLES_ANIM_CLIFF_SLOW_ATTACK_2,     CLIFF_SLOW_ATTACK2,                 -1)

    Character.edit_action_parameters(KNUCKLES, Action.RayGunShoot,              File.KNUCKLES_ANIM_ITEM_SHOOT,              ITEM_SHOOT,                         0x00000000)
    Character.edit_action_parameters(KNUCKLES, Action.RayGunShootAir,           File.KNUCKLES_ANIM_ITEM_SHOOT_AIR,          ITEM_SHOOT,                         0x00000000)
    Character.edit_action_parameters(KNUCKLES, Action.FireFlowerShoot,          File.KNUCKLES_ANIM_ITEM_SHOOT,              ITEM_SHOOT,                         0x00000000)
    Character.edit_action_parameters(KNUCKLES, Action.FireFlowerShootAir,       File.KNUCKLES_ANIM_ITEM_SHOOT_AIR,          ITEM_SHOOT,                         0x00000000)

    Character.edit_action_parameters(KNUCKLES, Action.ItemDrop,                 File.KNUCKLES_ANIM_ITEM_DROP,               -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.HeavyItemPickup,          File.KNUCKLES_ANIM_ITEM_HEAVY_PICKUP,       -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.HeavyItemThrowF,          File.KNUCKLES_ANIM_ITEM_HEAVY_THROW,        HEAVY_ITEM_THROW,                   -1)
    Character.edit_action_parameters(KNUCKLES, Action.HeavyItemThrowSmashF,     File.KNUCKLES_ANIM_ITEM_HEAVY_THROW,        HEAVY_ITEM_SMASH_THROW,             -1)
    Character.edit_action_parameters(KNUCKLES, Action.HeavyItemThrowSmashB,     File.KNUCKLES_ANIM_ITEM_HEAVY_THROW,        HEAVY_ITEM_SMASH_THROW,             -1)

    Character.edit_action_parameters(KNUCKLES, Action.BatNeutral,               File.KNUCKLES_ANIM_ITEM_NEUTRAL,            -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.BatSmash,                 File.KNUCKLES_ANIM_SWING_SMASH,             -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.BatTilt,                  File.KNUCKLES_ANIM_SWING_TILT,              -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.BatDash,                  File.KNUCKLES_ANIM_ITEM_DASH_ATTACK,        BAT_DASH,                           0x40000000)

    Character.edit_action_parameters(KNUCKLES, Action.FanNeutral,               File.KNUCKLES_ANIM_ITEM_NEUTRAL,            -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.FanSmash,                 File.KNUCKLES_ANIM_SWING_SMASH,             -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.FanTilt,                  File.KNUCKLES_ANIM_SWING_TILT,              -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.FanDash,                  File.KNUCKLES_ANIM_ITEM_DASH_ATTACK,        FAN_DASH,                           0x40000000)

    Character.edit_action_parameters(KNUCKLES, Action.StarRodNeutral,           File.KNUCKLES_ANIM_ITEM_NEUTRAL,            -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.StarRodSmash,             File.KNUCKLES_ANIM_SWING_SMASH,             -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.StarRodTilt,              File.KNUCKLES_ANIM_SWING_TILT,              -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.StarRodDash,              File.KNUCKLES_ANIM_ITEM_DASH_ATTACK,        STARROD_DASH,                       0x40000000)

    Character.edit_action_parameters(KNUCKLES, Action.BeamSwordNeutral,         File.KNUCKLES_ANIM_ITEM_NEUTRAL,            -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.BeamSwordSmash,           File.KNUCKLES_ANIM_SWING_SMASH,             -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.BeamSwordTilt,            File.KNUCKLES_ANIM_SWING_TILT,              -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.BeamSwordDash,            File.KNUCKLES_ANIM_ITEM_DASH_ATTACK,        BEAMSWORD_DASH,                     0x40000000)

    Character.edit_action_parameters(KNUCKLES, Action.HammerIdle,               File.KNUCKLES_ANIM_HAMMER_IDLE,             -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.HammerWalk,               File.KNUCKLES_ANIM_HAMMER_WALK,             -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.HammerTurn,               File.KNUCKLES_ANIM_HAMMER_WALK,             -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.HammerJumpSquat,          File.KNUCKLES_ANIM_HAMMER_WALK,             -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.HammerAir,                File.KNUCKLES_ANIM_HAMMER_WALK,             -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.HammerLanding,            File.KNUCKLES_ANIM_HAMMER_WALK,             -1,                                 -1)

    Character.edit_action_parameters(KNUCKLES, Action.ItemThrowF,               File.KNUCKLES_ANIM_ITEM_THROW_F,            -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.ItemThrowB,               File.KNUCKLES_ANIM_ITEM_THROW_F,            -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.ItemThrowU,               File.KNUCKLES_ANIM_ITEM_THROW_U,            -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.ItemThrowD,               File.KNUCKLES_ANIM_ITEM_THROW_D,            -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.ItemThrowSmashF,          File.KNUCKLES_ANIM_ITEM_THROW_F,            -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.ItemThrowSmashB,          File.KNUCKLES_ANIM_ITEM_THROW_F,            -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.ItemThrowSmashU,          File.KNUCKLES_ANIM_ITEM_THROW_U,            -1,                                 -1)
    Character.edit_action_parameters(KNUCKLES, Action.ItemThrowSmashD,          File.KNUCKLES_ANIM_ITEM_THROW_D,            -1,                                 -1)

    // Modify Menu Action Parameters                // Action       // Animation                        // Moveset Data         // Flags
    Character.edit_menu_action_parameters(KNUCKLES, 0x0,            File.KNUCKLES_ANIM_IDLE,            CUSTOM_IDLE,            -1)
    Character.edit_menu_action_parameters(KNUCKLES, 0x1,            File.KNUCKLES_ANIM_VICTORY1,        VICTORY1,               -1)
    Character.edit_menu_action_parameters(KNUCKLES, 0x2,            File.KNUCKLES_ANIM_VICTORY2,        VICTORY2,               -1)
    Character.edit_menu_action_parameters(KNUCKLES, 0x3,            File.KNUCKLES_ANIM_CSS,             CSS,                    -1)
    Character.edit_menu_action_parameters(KNUCKLES, 0x4,            File.KNUCKLES_ANIM_CSS,             CSS,                    -1)
    Character.edit_menu_action_parameters(KNUCKLES, 0x5,            File.KNUCKLES_ANIM_CLAP,            CLAP,                   -1)
    Character.edit_menu_action_parameters(KNUCKLES, 0x9,            File.KNUCKLES_ANIM_PUPPET_FALL,     -1,                     -1)
    Character.edit_menu_action_parameters(KNUCKLES, 0xA,            File.KNUCKLES_ANIM_PUPPET_REVIVE,   -1,                     -1)
    Character.edit_menu_action_parameters(KNUCKLES, 0xD,            File.KNUCKLES_ANIM_1P_POSE,         0x80000000,             -1)
    Character.edit_menu_action_parameters(KNUCKLES, 0xE,            File.KNUCKLES_ANIM_1P_CPU_POSE,     CPU_POSE,               -1)

    // Modify Actions               // Action               // Staling ID   // Main ASM                   // Interrupt/Other ASM     // Movement/Physics ASM      // Collision ASM
    Character.edit_action(KNUCKLES, 0xDC,                   -1,             0x8014FE40,                   0x00000000,                0x800D8CCC,                    0x800DDF44)                       // Jab3
    Character.edit_action(KNUCKLES, Action.Spring,          -1,             KnucklesUSP.main_air_,        KnucklesUSP.interrupt_,    KnucklesUSP.air_physics_,      0x800DE99C)                       // USP

    Character.edit_action(KNUCKLES, Action.DiveGround,      -1,             KnucklesDive.grounded_main_,  KnucklesDive.ground_move_, KnucklesDive.ground_physics_,  KnucklesDive.ground_collision_)   // Dive Punch Ground
    Character.edit_action(KNUCKLES, Action.DiveAirBegin,    0x1E,           KnucklesDive.aerial_main_,    KnucklesDive.air_move_,    KnucklesDive.air_physics_,     KnucklesDive.air_collision_)      // Dive Punch Air Begin
    Character.edit_action(KNUCKLES, Action.DiveAirLoop,     0x1E,           0x00000000,                   KnucklesDive.air_move_,    KnucklesDive.air_physics_,     KnucklesDive.air_collision_)      // Dive Punch Air Loop
    Character.edit_action(KNUCKLES, Action.DiveLand,        0x1E,           0x800D94C4,                   0,                         0x800D8BB4,                    0x800DDF44)                       // Dive Punch Air Landing

    // Add Action Parameters                   // Action Name       // Base Action  // Animation                        // Moveset Data             // Flags
    Character.add_new_action_params(KNUCKLES, NSP_Climb_Wait,       -1,             File.KNUCKLES_ANIM_CLIMB_UP,        0x80000000,                 0)
    Character.add_new_action_params(KNUCKLES, NSP_Climb_MoveUp,     -1,             File.KNUCKLES_ANIM_CLIMB_UP,        0x80000000,                 0)
    Character.add_new_action_params(KNUCKLES, NSP_Climb_MoveDown,   -1,             File.KNUCKLES_ANIM_CLIMB_DOWN,      0x80000000,                 0)
    Character.add_new_action_params(KNUCKLES, NSP_Turn,             -1,             File.KNUCKLES_ANIM_GLIDE_WAIT,      CUSTOM_IDLE,                0)
    Character.add_new_action_params(KNUCKLES, NSP_Air_Wait,         -1,             File.KNUCKLES_ANIM_GLIDE_WAIT,      CUSTOM_IDLE,                0)
    Character.add_new_action_params(KNUCKLES, NSP_Air_Begin,        -1,             File.KNUCKLES_ANIM_GLIDE_START,     CUSTOM_IDLE,                0)
    Character.add_new_action_params(KNUCKLES, NSP_Air_End,          -1,             File.KNUCKLES_ANIM_GLIDE_END,       CUSTOM_IDLE,                0)
    Character.add_new_action_params(KNUCKLES, DSP_Ground_Charge,    -1,             File.SONIC_CHARGE_LOOP,             CUSTOM_DSP_CHARGE,          0)
    Character.add_new_action_params(KNUCKLES, DSP_Ground_Move,      -1,             File.SONIC_SPIN_LOOP_FAST,          CUSTOM_DSP_MOVE,            0x10000000)
    Character.add_new_action_params(KNUCKLES, DSP_Ground_End,       -1,             File.SONIC_CROUCH_END,              0x80000000,                 0)
    Character.add_new_action_params(KNUCKLES, DSP_Air_Charge,       -1,             File.SONIC_CHARGE_LOOP,             CUSTOM_DSP_AIR_CHARGE,      0)
    Character.add_new_action_params(KNUCKLES, DSP_Air_Move,         -1,             File.SONIC_JUMP_F,                  CUSTOM_DSP_AIR_MOVE,        0)
    Character.add_new_action_params(KNUCKLES, DSP_Air_Jump,         -1,             File.SONIC_JUMP_F,                  CUSTOM_DSP_AIR_JUMP,        0)
    Character.add_new_action_params(KNUCKLES, DSP_Air_End,          -1,             File.SONIC_NSP_FINISH,              0x80000000,                 0)

    // Add Actions                     // Action Name       // Base Action  // Parameters                       // Staling ID   // Main ASM                       // Interrupt/Other ASM                   // Movement/Physics ASM              // Collision ASM
    Character.add_new_action(KNUCKLES, NSP_Climb_Wait,      -1,             ActionParams.NSP_Climb_Wait,        0x12,           KnucklesClimb.climb_common_main_, KnucklesClimb.climb_wait_interrupt_,     KnucklesClimb.climb_jostle_physics_, KnucklesClimb.climb_common_collision_)
    Character.add_new_action(KNUCKLES, NSP_Climb_MoveUp,    -1,             ActionParams.NSP_Climb_MoveUp,      0x12,           KnucklesClimb.climb_common_main_, KnucklesClimb.climb_moveup_interrupt_,   KnucklesClimb.climb_move_physics_,   KnucklesClimb.climb_common_collision_)
    Character.add_new_action(KNUCKLES, NSP_Climb_MoveDown,  -1,             ActionParams.NSP_Climb_MoveDown,    0x12,           KnucklesClimb.climb_common_main_, KnucklesClimb.climb_movedown_interrupt_, KnucklesClimb.climb_move_physics_,   KnucklesClimb.climb_common_collision_)
    Character.add_new_action(KNUCKLES, NSP_Turn,            -1,             ActionParams.NSP_Turn,              0x12,           KnucklesNSP.air_turn_main_,       KnucklesNSP.air_common_interrupt_,       KnucklesNSP.turn_physics_,           KnucklesNSP.air_common_collision_)
    Character.add_new_action(KNUCKLES, NSP_Air_Begin,       -1,             ActionParams.NSP_Air_Begin,         0x12,           KnucklesNSP.air_begin_main_,      0,                                       KnucklesNSP.air_physics_,            KnucklesNSP.air_common_collision_)
    Character.add_new_action(KNUCKLES, NSP_Air_Wait,        -1,             ActionParams.NSP_Air_Wait,          0x12,           KnucklesNSP.air_wait_main_,       KnucklesNSP.air_common_interrupt_,       KnucklesNSP.air_physics_,            KnucklesNSP.air_common_collision_)
    Character.add_new_action(KNUCKLES, NSP_Air_End,         -1,             ActionParams.NSP_Air_End,           0x12,           KnucklesNSP.end_main_,            KnucklesNSP.air_common_interrupt_,       0x800D90E0,                          0x800DE99C)
    Character.add_new_action(KNUCKLES, DSP_Ground_Charge,   -1,             ActionParams.DSP_Ground_Charge,     0x1E,           KnucklesDSP.ground_charge_main_,  0,                                       0x800D8BB4,                          KnucklesDSP.ground_charge_collision_)
    Character.add_new_action(KNUCKLES, DSP_Ground_Move,     -1,             ActionParams.DSP_Ground_Move,       0x1E,           KnucklesDSP.ground_move_main_,    0,                                       KnucklesDSP.ground_move_physics_,    KnucklesDSP.ground_move_collision_)
    Character.add_new_action(KNUCKLES, DSP_Ground_End,      -1,             ActionParams.DSP_Ground_End,        0x1E,           0x800D94C4,                       0,                                       0x800D8BB4,                          KnucklesDSP.ground_end_collision_)
    Character.add_new_action(KNUCKLES, DSP_Air_Charge,      -1,             ActionParams.DSP_Air_Charge,        0x1E,           KnucklesDSP.air_charge_main_,     0,                                       0x800D91EC,                          KnucklesDSP.air_charge_collision_)
    Character.add_new_action(KNUCKLES, DSP_Air_Move,        -1,             ActionParams.DSP_Air_Move,          0x1E,           KnucklesDSP.air_move_main_,       KnucklesDSP.air_move_interrupt_,         KnucklesDSP.air_movement_physics_,   KnucklesDSP.air_move_collision_)
    Character.add_new_action(KNUCKLES, DSP_Air_Jump,        -1,             ActionParams.DSP_Air_Jump,          0x1E,           KnucklesDSP.air_move_main_,       KnucklesDSP.air_move_interrupt_,         KnucklesDSP.air_movement_physics_,   KnucklesDSP.air_move_collision_)
    Character.add_new_action(KNUCKLES, DSP_Air_End,         -1,             ActionParams.DSP_Air_End,           0x1E,           0x800D94E8,                       0,                                       0x800D91EC,                          KnucklesDSP.air_end_collision_)

    if {defined Character.CHARACTER_ADDED_MKNUCKLES} {
        Character.table_patch_start(variant_original, Character.id.KNUCKLES, 0x4)
        dw      Character.id.MKNUCKLES // set MKnuckles as original character (not Fox, who Knuckles is a clone of)
        OS.patch_end()
    }

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.KNUCKLES, 0x2)
    dh FGM.CHANT
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.KNUCKLES, 0x4)
    dw Action.action_string_table
    OS.patch_end()

    // Set entry script
    Character.table_patch_start(entry_script, Character.id.KNUCKLES, 0x4)
    dw 0x8013DD68   // skips entry script
    OS.patch_end()

    // Set initial script
    Character.table_patch_start(initial_script, Character.id.KNUCKLES, 0x4)
    dw initial_script_
    OS.patch_end()

    // Set grounded script
    Character.table_patch_start(grounded_script, Character.id.KNUCKLES, 0x4)
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

    Character.table_patch_start(ground_usp, Character.id.KNUCKLES, 0x4)
    dw      KnucklesUSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.KNUCKLES, 0x4)
    dw      KnucklesUSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(ground_nsp, Character.id.KNUCKLES, 0x4)
    dw      KnucklesDive.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_nsp, Character.id.KNUCKLES, 0x4)
    dw      KnucklesNSP.air_begin_initial_
    OS.patch_end()

    Character.table_patch_start(ground_dsp, Character.id.KNUCKLES, 0x4)
    dw      KnucklesDSP.ground_charge_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.KNUCKLES, 0x4)
    dw      KnucklesDSP.air_charge_initial_
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.KNUCKLES, 0, 2, 1, 3, 0, 1, 2)
    Teams.add_team_costume(YELLOW, KNUCKLES, 0x4)

    // Set default costume shield colors
    Character.set_costume_shield_colors(KNUCKLES, RED, CYAN, GREEN, LIME, ORANGE, PURPLE, GREEN, YELLOW)
}