// YZelda.asm

// This file contains file inclusions, action edits, and assembly for YZelda.

include "./YZeldaSpecial.asm"

scope YZelda {
    GRAB_:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
	insert SPARKLE_,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE_)                    // loops
    insert SHIELD_BREAK_,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE_)          // loops
    insert STUN_, "moveset/STUN.bin"; Moveset.GO_TO(STUN_)                            // loops
    insert ASLEEP_, "moveset/ASLEEP.bin"; Moveset.GO_TO(ASLEEP_)                      // loops


    scope MODEL {
        scope EYE_L {
            constant NORMAL(0xAC000000)
            constant HURT(0xAC000001)
            constant MID(0xAC000002)
            constant CLOSED(0xAC000003)
            constant UP(0xAC000004)
        }
        scope EYE_R {
            constant NORMAL(0xAC100000)
            constant HURT(0xAC100001)
            constant MID(0xAC100002)
            constant CLOSED(0xAC100003)
            constant UP(0xAC100004)
        }
        scope WEAPON {
            constant PAN(0xA0900000)
            constant RACKET(0xA0900001)
            constant CLUB(0xA0900002)
            constant PRSL_CLS(0xA0900003)
            constant PRSL_OPEN(0xA0900004)
            constant HIDE(0xA0900005) // not proper but I don't really care.
        }
        scope HEAD {
            constant NORMAL(0xA0500000)
            constant NOCROWN(0xA0500001)
        }
        scope RIGHT_HAND {
            constant NORMAL(0xA0600000)
            constant CROWN(0xA0600001)
        }
    }

    // Insert Moveset files

    RUN_:; insert "moveset/RUN.bin"; Moveset.GO_TO(RUN_) // loops
    USP_FGM_ARRAY:; dh YZelda.FGM.YZELDAUSP1; dh YZelda.FGM.YZELDAUSP1; dh YZelda.FGM.YZELDAUSP2; OS.align(4)
    USPNEW:;
    insert "moveset/USP.bin"                           // USP
    dw 0x0400000A;                                     // wait 10 frames
    Moveset.RANDOM_SFX(100, 0x1, 0x3, USP_FGM_ARRAY)   // play a random ocarina fx
    insert "moveset/USP2.bin"                          //  USP2

    CUSTOM_THROW_B:; Moveset.THROW_DATA(THROW_B_DATA); Moveset.GO_TO(THROW_B)
    CUSTOM_THROW_F:; Moveset.THROW_DATA(THROW_F_DATA); Moveset.GO_TO(THROW_F)

    LIGHT_ITEM_PICKUP:; dw 0xBC000003;  dw 0x08000004; dw 0x3800009D; dw 0x58000001; dw 0
    ITEM_DROP:; dw 0xBC000003;  dw 0x08000008; dw 0x54000001; dw 0
    ITEM_THROW_DASH:; dw 0x08000004; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_DASH); dw 0
    ITEM_THROW_F:; dw 0xBC000003; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_B:; dw 0xBC000003; dw 0x60000008; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_U:; dw 0xBC000003; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_D:; dw 0xBC000003; dw 0x08000008; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_SMASH_F:; dw 0xBC000003; dw 0x0800000A; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_SMASH_B:; dw 0xBC000003; dw 0x60000008; dw 0x0800000A; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_SMASH_U:; dw 0xBC000003; dw 0x0800000A; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_SMASH_D:; dw 0xBC000003; dw 0x08000008; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_F:; dw 0xBC000003; dw 0x08000009; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_B:; dw 0xBC000003; dw 0x60000004; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_U:; dw 0xBC000003; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_D:; dw 0xBC000003; dw 0x08000008; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_SMASH_F:; dw 0xBC000003; dw 0x08000009; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_AIR_SMASH_FB); dw 0
    ITEM_THROW_AIR_SMASH_B:; dw 0xBC000003; dw 0x60000006; dw 0x08000009; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_AIR_SMASH_FB); dw 0
    ITEM_THROW_AIR_SMASH_U:; dw 0xBC000003; dw 0x08000009; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_SMASH_UD); dw 0
    ITEM_THROW_AIR_SMASH_D:; dw 0xBC000003; dw 0x08000009; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_SMASH_UD); dw 0
    HEAVY_ITEM_PICKUP:; dw 0xBC000003;  dw 0x08000004; dw 0x58000001; dw 0
    HEAVY_ITEM_THROW_F:; dw 0xBC000003;  dw 0x08000014; dw 0x54000001; dw 0
    HEAVY_ITEM_THROW_B:; dw 0xBC000003;  dw 0x08000014; dw 0x54000001; dw 0
    HEAVY_ITEM_THROW_SMASH_F:; dw 0xBC000003;  dw 0x08000014; dw 0x50000000; dw 0x54000001; dw 0
    HEAVY_ITEM_THROW_SMASH_B:; dw 0xBC000003;  dw 0x08000014; dw 0x50000000; dw 0x54000001; dw 0
    BEAMSWORD_JAB:; dw 0xBC000003; dw 0x08000005; dw 0xCC040000; dw 0x08000009; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_JAB); dw 0x04000005; dw 0x18000000; dw 0x04000004; dw 0xCC03FFFF; dw 0
    BEAMSWORD_TILT:; dw 0xBC000003; dw 0x6000000A; dw 0x08000004; dw 0xBC000004; dw 0xCC040000; dw 0x0800000F; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_TILT); dw 0x04000006; dw 0x18000000; dw 0x04000006; dw 0xCC03FFFF; dw 0x08000026; dw 0xBC000003; dw 0
    BEAMSWORD_SMASH:; dw 0xBC000003; dw 0x08000002; dw 0xCC040000; dw 0x08000003; dw 0xBC000004; dw 0x50000000; dw 0x08000011; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_SMASH); dw 0x04000007; dw 0x18000000; dw 0x04000002; dw 0xCC03FFFF; dw 0x0800002D; dw 0xBC000003; dw 0
    BEAMSWORD_DASH:; dw 0xBC000004; dw 0xCC040000; dw 0x0800000D; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_DASH); dw 0x04000003; dw 0xCC03FFFF; dw 0x0400000F; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    BAT_JAB:; dw 0xBC000003; dw 0x08000009; Moveset.SUBROUTINE(Moveset.shared.BAT_JAB); dw 0x04000004; dw 0x18000000; dw 0
    BAT_TILT:; dw 0xBC000003; dw 0x08000004; dw 0xBC000004; dw 0x0800000F; Moveset.SUBROUTINE(Moveset.shared.BAT_TILT); dw 0x04000004; dw 0x18000000; dw 0x08000026; dw 0xBC000003; dw 0
    BAT_SMASH:; dw 0xC4000007; dw 0xBC000003; dw 0xB1300028; dw 0x08000003; dw 0xBC000004; dw 0x50000000; dw 0x08000011; Moveset.SUBROUTINE(Moveset.shared.BAT_SMASH); dw 0x04000007; dw 0x18000000; dw 0x0800002D; dw 0xBC000003; dw 0
    BAT_DASH:; dw 0xBC000004; dw 0x0800000D; Moveset.SUBROUTINE(Moveset.shared.BAT_DASH); dw 0x04000012; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    FAN_JAB:; dw 0xBC000003; dw 0x08000009; Moveset.SUBROUTINE(Moveset.shared.FAN_JAB); dw 0x04000004; dw 0x18000000; dw 0
    FAN_TILT:; dw 0xBC000003; dw 0x08000004; dw 0xBC000004; dw 0x0800000F; Moveset.SUBROUTINE(Moveset.shared.FAN_TILT); dw 0x04000004; dw 0x18000000; dw 0x08000026; dw 0xBC000003; dw 0
    FAN_SMASH:; dw 0xBC000003; dw 0x08000003; dw 0xBC000004; dw 0x50000000; dw 0x08000011; Moveset.SUBROUTINE(Moveset.shared.FAN_SMASH); dw 0x04000007; dw 0x18000000; dw 0x0800002D; dw 0xBC000003; dw 0
    FAN_DASH:; dw 0xBC000004; dw 0x0800000D; Moveset.SUBROUTINE(Moveset.shared.FAN_DASH); dw 0x04000012; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    STARROD_JAB:; dw 0xBC000003; dw 0xB12C0010; dw 0x08000009; Moveset.SUBROUTINE(Moveset.shared.STARROD_JAB); dw 0x04000004; dw 0x18000000; dw 0
    STARROD_TILT:; dw 0xBC000003; dw 0x08000004; dw 0xBC000004; dw 0xB12C000D; dw 0x0800000F; Moveset.SUBROUTINE(Moveset.shared.STARROD_TILT); dw 0x04000002; dw 0x54000001; dw 0x04000002; dw 0x18000000;  dw 0x08000026; dw 0xBC000003; dw 0
    STARROD_SMASH:; dw 0xBC000003; dw 0x08000003; dw 0xBC000004; dw 0xB12C0024; dw 0x50000000; dw 0x08000011; Moveset.SUBROUTINE(Moveset.shared.STARROD_SMASH); dw 0x04000002; dw 0x54000002; dw 0x04000005; dw 0x18000000; dw 0x0800002D; dw 0xBC000003; dw 0
    STARROD_DASH:; dw 0xBC000004; dw 0xB12C0014; dw 0x0800000D; Moveset.SUBROUTINE(Moveset.shared.STARROD_DASH); dw 0x04000012; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    HAMMER:; dw 0xC4000007; dw 0xBC000004; dw 0xAC000001; dw 0xAC100001; Moveset.SUBROUTINE(Moveset.shared.HAMMER); dw 0x04000010; dw 0x18000000; Moveset.GO_TO(HAMMER)

    scope Action: {
        constant EntryL(0xDC)
        constant EntryR(0xDD)
        constant USPG_BEGIN(0xE3)
        constant USPA_BEGIN(0xE4)
        constant USPG_CHARGE(0xE5)
        constant USPA_CHARGE(0xE6)
        constant USPG_MOVE(0xE7)
        constant USPA_MOVE(0xE8)
        constant USPG_END(0xE9)
        constant USPA_END(0xEA)
        constant NSP_Begin(0xF6)
        constant NSP_Wait(0xF7)
        constant NSP_End(0xF8)
        constant NSPAir_Begin(0xF9)
        constant NSPAir_Wait(0xFA)
        constant NSPAir_End(0xFB)
        constant DSP(0xFC)
        constant DSP_Attack(0xFD)
        constant DSPAir(0xFE)
        constant DSPAir_Attack(0xFF)

        // strings!
        string_0x0DC:; String.insert("")
        string_0x0DD:; String.insert("")
        string_0x0E3:; String.insert("WarpSongStartGround")
        string_0x0E4:; String.insert("WarpSongStartAir")
        string_0x0E5:; String.insert("WarpSongChargeGround")
        string_0x0E6:; String.insert("WarpSongChargeAir")
        string_0x0E7:; String.insert("WarpSongGround")
        string_0x0E8:; String.insert("WarpSongAir")
        string_0x0E9:; String.insert("WarpSongEndGround")
        string_0x0EA:; String.insert("WarpSongEndAir")
        string_0x0F6:; String.insert("LightArrowGround")
        string_0x0F7:; String.insert("LightArrowGroundLoop")
        string_0x0F8:; String.insert("LightArrowGroundFire")
        string_0x0F9:; String.insert("LightArrowAir")
        string_0x0FA:; String.insert("LightArrowAirLoop")
        string_0x0FB:; String.insert("LightArrowAirFire")
        string_0x0FC:; String.insert("ImpaCounterGround")
        string_0x0FD:; String.insert("ImpaCounterGroundAttack")
        string_0x0FE:; String.insert("ImpaCounterAir")
        string_0x0FF:; String.insert("ImpaCounterAirAttack")

        action_string_table:
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw string_0x0E3
        dw string_0x0E4
        dw string_0x0E5
        dw string_0x0E6
        dw string_0x0E7
        dw string_0x0E8
        dw string_0x0E9
        dw string_0x0EA
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
        dw string_0x0F6
        dw string_0x0F7
        dw string_0x0F8
        dw string_0x0F9
        dw string_0x0FA
        dw string_0x0FB
        dw string_0x0FC
        dw string_0x0FD
        dw string_0x0FE
        dw string_0x0FF
    }

    // AI stuff, doing this with a new method.

    // Modify Action Parameters             // Action                       // Animation                    // Moveset Data             // Flags
    Character.edit_action_parameters(YZELDA, Action.DeadU,                   File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DeadU,                   File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.ScreenKO,                File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.Entry,                   File.PEACH_IDLE,                IDLE,                       -1)
    Character.edit_action_parameters(YZELDA, 0x006,                          File.PEACH_IDLE,                IDLE,                       -1)
    Character.edit_action_parameters(YZELDA, Action.Revive1,                 File.PEACH_DOWN_BOUNCE_D,       -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.Revive2,                 File.PEACH_DOWN_STAND_D,        -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.ReviveWait,              File.PEACH_IDLE,                IDLE,                       -1)
    Character.edit_action_parameters(YZELDA, Action.Idle,                    File.PEACH_IDLE,                IDLE,                       -1)
    Character.edit_action_parameters(YZELDA, Action.Walk1,                   File.PEACH_WALK1,               -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.Walk2,                   File.PEACH_WALK2,               -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.Walk3,                   File.PEACH_WALK3,               -1,                         -1)
    Character.edit_action_parameters(YZELDA, 0x00E,                          File.PEACH_TEETER_START,        -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.Dash,                    File.PEACH_DASH,                -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.Run,                     File.PEACH_RUN,                 RUN_,                        -1)
    Character.edit_action_parameters(YZELDA, Action.RunBrake,                File.PEACH_RUN_BRAKE,           -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.Turn,                    File.PEACH_TURN,                -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.TurnRun,                 File.PEACH_TURN_RUN,            -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.JumpSquat,               File.PEACH_LANDING,             -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.ShieldJumpSquat,         File.PEACH_LANDING,             -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.JumpF,                   File.PEACH_JUMP_F,              JUMP_1,                     -1)
    Character.edit_action_parameters(YZELDA, Action.JumpB,                   File.PEACH_JUMP_B,              JUMP_1,                     -1)
    Character.edit_action_parameters(YZELDA, Action.JumpAerialF,             File.PEACH_JUMP_AERIAL_F,       JUMP_2,                      0x40000000)
    Character.edit_action_parameters(YZELDA, Action.JumpAerialB,             File.PEACH_JUMP_AERIAL_B,       JUMP_2,                      0x40000000)
    Character.edit_action_parameters(YZELDA, Action.Fall,                    File.PEACH_FALL,                -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.FallAerial,              File.YZELDA_ANIM_FALLAERIAL,    -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.Crouch,                  File.PEACH_CROUCH,              -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.CrouchIdle,              File.PEACH_CROUCH_IDLE,         -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.CrouchEnd,               File.PEACH_CROUCH_END,          -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.LandingLight,            File.PEACH_LANDING,             -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.LandingHeavy,            File.PEACH_LANDING,             -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.Pass,                    File.PEACH_PLAT_DROP,           -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.ShieldDrop,              File.PEACH_PLAT_DROP,           -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.Teeter,                  File.PEACH_TEETER,              TEETER,                     -1)
    Character.edit_action_parameters(YZELDA, Action.TeeterStart,             File.PEACH_TEETER_START,        -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageHigh1,             File.PEACH_DAMAGE_HIGH1,        -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageHigh2,             File.PEACH_DAMAGE_HIGH2,        -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageHigh3,             File.PEACH_DAMAGE_HIGH3,        -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageMid1,              File.PEACH_DAMAGE_MID1,         -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageMid2,              File.PEACH_DAMAGE_MID2,         -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageMid3,              File.PEACH_DAMAGE_MID3,         -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageLow1,              File.PEACH_DAMAGE_LOW1,         -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageLow2,              File.PEACH_DAMAGE_LOW2,         -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageLow3,              File.PEACH_DAMAGE_LOW3,         -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageAir1,              File.PEACH_DAMAGE_AIR1,         -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageAir2,              File.PEACH_DAMAGE_AIR2,         -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageAir3,              File.PEACH_DAMAGE_AIR3,         -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageElec1,             File.PEACH_DAMAGE_ELEC,         -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageElec2,             File.PEACH_DAMAGE_ELEC,         -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageFlyHigh,           File.PEACH_DAMAGE_FLY_HIGH,     -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageFlyMid,            File.PEACH_DAMAGE_FLY_MID,      -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageFlyLow,            File.PEACH_DAMAGE_FLY_LOW,      -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageFlyTop,            File.PEACH_DAMAGE_FLY_TOP,      -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DamageFlyRoll,           File.PEACH_DAMAGE_FLY_ROLL,     -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.WallBounce,              File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.Tumble,                  File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.FallSpecial,             File.YZELDA_ANIM_FALLSPECIAL,   -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.LandingSpecial,          File.YZELDA_ANIM_LANDSPECIAL,   -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.Tornado,                 File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.EnterPipe,               File.PEACH_ENTER_PIPE,          -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.ExitPipe,                File.PEACH_EXIT_PIPE,           -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.ExitPipeWalk,            File.PEACH_EXIT_PIPE_WALK,      -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.CeilingBonk,             File.PEACH_CEILING_BONK,        -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DownBounceD,             File.PEACH_DOWN_BOUNCE_D,       -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DownBounceU,             File.PEACH_DOWN_BOUNCE_U,       -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DownStandD,              File.PEACH_DOWN_STAND_D,        -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DownStandU,              File.PEACH_DOWN_STAND_U,        -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.TechF,                   File.PEACH_TECH_F,              TECH_ROLL,                  -1)
    Character.edit_action_parameters(YZELDA, Action.TechB,                   File.PEACH_TECH_B,              TECH_ROLL,                  -1)
    Character.edit_action_parameters(YZELDA, Action.DownForwardD,            File.PEACH_DOWN_FORWARD_D,      -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DownForwardU,            File.PEACH_DOWN_FORWARD_U,      -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DownBackD,               File.PEACH_DOWN_BACK_D,         -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DownBackU,               File.PEACH_DOWN_BACK_U,         -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.DownAttackD,             File.PEACH_DOWN_ATK_D,          DOWN_ATTACK_D,              -1)
    Character.edit_action_parameters(YZELDA, Action.DownAttackU,             File.PEACH_DOWN_ATK_U,          DOWN_ATTACK_U,              -1)
    Character.edit_action_parameters(YZELDA, Action.Tech,                    File.PEACH_TECH,                TECH_STAND,                 -1)
    Character.edit_action_parameters(YZELDA, Action.ClangRecoil,             File.PEACH_CLANG_RECOIL,        -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.CliffCatch,              File.PEACH_CLF_CATCH,           CLIFF_CATCH,                -1)
    Character.edit_action_parameters(YZELDA, Action.CliffWait,               File.PEACH_CLF_WAIT,            CLIFF_WAIT,                 -1)
    Character.edit_action_parameters(YZELDA, Action.CliffQuick,              File.PEACH_CLF_Q,               -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.CliffClimbQuick1,        File.PEACH_CLF_CLM_Q1,          -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.CliffClimbQuick2,        File.PEACH_CLF_CLM_Q2,          -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.CliffSlow,               File.PEACH_CLF_S,               -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.CliffClimbSlow1,         File.PEACH_CLF_CLM_S1,          -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.CliffClimbSlow2,         File.PEACH_CLF_CLM_S2,          -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.CliffAttackQuick1,       File.PEACH_CLF_ATK_S1,          EDGE_ATTACK_QUICK_1,        -1)
    Character.edit_action_parameters(YZELDA, Action.CliffAttackQuick2,       File.PEACH_CLF_ATK_S2,          EDGE_ATTACK_QUICK_2,        -1)
    Character.edit_action_parameters(YZELDA, Action.CliffAttackSlow1,        File.YZELDA_ANIM_GETUP_ATTACK_SLOW_1,  -1,                        -1)
    Character.edit_action_parameters(YZELDA, Action.CliffAttackSlow2,        File.YZELDA_ANIM_GETUP_ATTACK_SLOW_2,  EDGE_ATTACK_SLOW_2,        -1)
    Character.edit_action_parameters(YZELDA, Action.CliffEscapeQuick1,       File.PEACH_CLF_ESC_Q1,          -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.CliffEscapeQuick2,       File.PEACH_CLF_ESC_Q2,          -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.CliffEscapeSlow1,        File.PEACH_CLF_ESC_S1,          -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.CliffEscapeSlow2,        File.PEACH_CLF_ESC_S2,          -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.LightItemPickup,         File.PEACH_L_ITM_PICKUP,        LIGHT_ITEM_PICKUP,          -1)
    Character.edit_action_parameters(YZELDA, Action.HeavyItemPickup,         File.PEACH_H_ITM_PICKUP,        HEAVY_ITEM_PICKUP,          -1)
    Character.edit_action_parameters(YZELDA, Action.ItemDrop,                File.PEACH_ITM_DROP,            ITEM_DROP,                  -1)
    Character.edit_action_parameters(YZELDA, Action.ItemThrowDash,           File.PEACH_ITM_THROW_DASH,      ITEM_THROW_DASH,            -1)
    Character.edit_action_parameters(YZELDA, Action.ItemThrowF,              File.PEACH_ITM_THROW_F,         ITEM_THROW_F,               -1)
    Character.edit_action_parameters(YZELDA, Action.ItemThrowB,              File.PEACH_ITM_THROW_F,         ITEM_THROW_B,               -1)
    Character.edit_action_parameters(YZELDA, Action.ItemThrowU,              File.PEACH_ITM_THROW_U,         ITEM_THROW_U,               -1)
    Character.edit_action_parameters(YZELDA, Action.ItemThrowD,              File.PEACH_ITM_THROW_D,         ITEM_THROW_D,               -1)
    Character.edit_action_parameters(YZELDA, Action.ItemThrowSmashF,         File.PEACH_ITM_THROW_F,         ITEM_THROW_SMASH_F,         -1)
    Character.edit_action_parameters(YZELDA, Action.ItemThrowSmashB,         File.PEACH_ITM_THROW_F,         ITEM_THROW_SMASH_B,         -1)
    Character.edit_action_parameters(YZELDA, Action.ItemThrowSmashU,         File.PEACH_ITM_THROW_U,         ITEM_THROW_SMASH_U,         -1)
    Character.edit_action_parameters(YZELDA, Action.ItemThrowSmashD,         File.PEACH_ITM_THROW_D,         ITEM_THROW_SMASH_D,         -1)
    Character.edit_action_parameters(YZELDA, Action.ItemThrowAirF,           File.PEACH_ITM_THROW_AIR_F,     ITEM_THROW_AIR_F,           -1)
    Character.edit_action_parameters(YZELDA, Action.ItemThrowAirB,           File.PEACH_ITM_THROW_AIR_F,     ITEM_THROW_AIR_B,           -1)
    Character.edit_action_parameters(YZELDA, Action.ItemThrowAirU,           File.PEACH_ITM_THROW_AIR_U,     ITEM_THROW_AIR_U,           -1)
    Character.edit_action_parameters(YZELDA, Action.ItemThrowAirD,           File.PEACH_ITM_THROW_AIR_D,     ITEM_THROW_AIR_D,           -1)
    Character.edit_action_parameters(YZELDA, Action.ItemThrowAirSmashF,      File.PEACH_ITM_THROW_AIR_F,     ITEM_THROW_AIR_SMASH_F,     -1)
    Character.edit_action_parameters(YZELDA, Action.ItemThrowAirSmashB,      File.PEACH_ITM_THROW_AIR_F,     ITEM_THROW_AIR_SMASH_B,     -1)
    Character.edit_action_parameters(YZELDA, Action.ItemThrowAirSmashU,      File.PEACH_ITM_THROW_AIR_U,     ITEM_THROW_AIR_SMASH_U,     -1)
    Character.edit_action_parameters(YZELDA, Action.ItemThrowAirSmashD,      File.PEACH_ITM_THROW_AIR_D,     ITEM_THROW_AIR_SMASH_D,     -1)
    Character.edit_action_parameters(YZELDA, Action.HeavyItemThrowF,         File.PEACH_H_ITM_THROW,         HEAVY_ITEM_THROW_F,         -1)
    Character.edit_action_parameters(YZELDA, Action.HeavyItemThrowB,         File.PEACH_H_ITM_THROW,         HEAVY_ITEM_THROW_B,         -1)
    Character.edit_action_parameters(YZELDA, Action.HeavyItemThrowSmashF,    File.PEACH_H_ITM_THROW,         HEAVY_ITEM_THROW_SMASH_F,   -1)
    Character.edit_action_parameters(YZELDA, Action.HeavyItemThrowSmashB,    File.PEACH_H_ITM_THROW,         HEAVY_ITEM_THROW_SMASH_B,   -1)
    Character.edit_action_parameters(YZELDA, Action.BeamSwordNeutral,        File.PEACH_ITM_JAB,             BEAMSWORD_JAB,              -1)
    Character.edit_action_parameters(YZELDA, Action.BeamSwordTilt,           File.PEACH_ITM_TILT,            BEAMSWORD_TILT,             -1)
    Character.edit_action_parameters(YZELDA, Action.BeamSwordSmash,          File.PEACH_ITM_SMASH,           BEAMSWORD_SMASH,            -1)
    Character.edit_action_parameters(YZELDA, Action.BeamSwordDash,           File.PEACH_ITM_DASH,            BEAMSWORD_DASH,             -1)
    Character.edit_action_parameters(YZELDA, Action.BatNeutral,              File.PEACH_ITM_JAB,             BAT_JAB,                    -1)
    Character.edit_action_parameters(YZELDA, Action.BatTilt,                 File.PEACH_ITM_TILT,            BAT_TILT,                   -1)
    Character.edit_action_parameters(YZELDA, Action.BatSmash,                File.PEACH_ITM_SMASH,           BAT_SMASH,                  -1)
    Character.edit_action_parameters(YZELDA, Action.BatDash,                 File.PEACH_ITM_DASH,            BAT_DASH,                   -1)
    Character.edit_action_parameters(YZELDA, Action.FanNeutral,              File.PEACH_ITM_JAB,             FAN_JAB,                    -1)
    Character.edit_action_parameters(YZELDA, Action.FanTilt,                 File.PEACH_ITM_TILT,            FAN_TILT,                   -1)
    Character.edit_action_parameters(YZELDA, Action.FanSmash,                File.PEACH_ITM_SMASH,           FAN_SMASH,                  -1)
    Character.edit_action_parameters(YZELDA, Action.FanDash,                 File.PEACH_ITM_DASH,            FAN_DASH,                   -1)
    Character.edit_action_parameters(YZELDA, Action.StarRodNeutral,          File.PEACH_ITM_JAB,             STARROD_JAB,                -1)
    Character.edit_action_parameters(YZELDA, Action.StarRodTilt,             File.PEACH_ITM_TILT,            STARROD_TILT,               -1)
    Character.edit_action_parameters(YZELDA, Action.StarRodSmash,            File.PEACH_ITM_SMASH,           STARROD_SMASH,              -1)
    Character.edit_action_parameters(YZELDA, Action.StarRodDash,             File.PEACH_ITM_DASH,            STARROD_DASH,               -1)
    Character.edit_action_parameters(YZELDA, Action.RayGunShoot,             File.PEACH_ITM_SHOOT,           -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.RayGunShootAir,          File.PEACH_ITM_SHOOT_AIR,       -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.FireFlowerShoot,         File.PEACH_ITM_SHOOT,           -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.FireFlowerShootAir,      File.PEACH_ITM_SHOOT_AIR,       -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.HammerIdle,              File.PEACH_HAMMER_IDLE,         HAMMER,                     -1)
    Character.edit_action_parameters(YZELDA, Action.HammerWalk,              File.PEACH_HAMMER_WALK,         HAMMER,                     -1)
    Character.edit_action_parameters(YZELDA, Action.HammerTurn,              File.PEACH_HAMMER_WALK,         HAMMER,                     -1)
    Character.edit_action_parameters(YZELDA, Action.HammerJumpSquat,         File.PEACH_HAMMER_WALK,         HAMMER,                     -1)
    Character.edit_action_parameters(YZELDA, Action.HammerAir,               File.PEACH_HAMMER_WALK,         HAMMER,                     -1)
    Character.edit_action_parameters(YZELDA, Action.HammerLanding,           File.PEACH_HAMMER_WALK,         HAMMER,                     -1)
    Character.edit_action_parameters(YZELDA, Action.ShieldOn,                File.PEACH_SHIELD_ON,           -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.ShieldOff,               File.PEACH_SHIELD_OFF,          -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.RollF,                   File.PEACH_ROLL_F,              FROLL,                      -1)
    Character.edit_action_parameters(YZELDA, Action.RollB,                   File.PEACH_ROLL_B,              BROLL,                      -1)
    Character.edit_action_parameters(YZELDA, Action.ShieldBreak,             File.PEACH_DAMAGE_FLY_TOP,      SHIELD_BREAK_,               -1)
    Character.edit_action_parameters(YZELDA, Action.ShieldBreakFall,         File.PEACH_TUMBLE,              SPARKLE_,                    -1)
    Character.edit_action_parameters(YZELDA, Action.StunLandD,               File.PEACH_DOWN_BOUNCE_D,       STUN_LAND,                  -1)
    Character.edit_action_parameters(YZELDA, Action.StunLandU,               File.PEACH_DOWN_BOUNCE_U,       STUN_LAND,                  -1)
    Character.edit_action_parameters(YZELDA, Action.StunStartD,              File.PEACH_DOWN_STAND_D,        STUN_START,                 -1)
    Character.edit_action_parameters(YZELDA, Action.StunStartU,              File.PEACH_DOWN_STAND_U,        STUN_START,                 -1)
    Character.edit_action_parameters(YZELDA, Action.Stun,                    File.PEACH_STUN,                STUN_,                       -1)
    Character.edit_action_parameters(YZELDA, Action.Sleep,                   File.PEACH_STUN,                ASLEEP_,                     -1)
    Character.edit_action_parameters(YZELDA, Action.Grab,                    File.YZELDA_ANIM_GRAB,          GRAB_,                       -1)
    Character.edit_action_parameters(YZELDA, Action.GrabPull,                File.YZELDA_ANIM_GRAB_WAIT,     -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.ThrowF,                  File.YZELDA_ANIM_THROWF,        CUSTOM_THROW_F,             -1)
    Character.edit_action_parameters(YZELDA, Action.ThrowB,                  File.YZELDA_ANIM_THROWB,        CUSTOM_THROW_B,              0x10000000)
    Character.edit_action_parameters(YZELDA, Action.CapturePulled,           File.PEACH_CAPTURE_PULLED,      -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.InhalePulled,            File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.InhaleSpat,              File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.InhaleCopied,            File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.EggLayPulled,            File.PEACH_CAPTURE_PULLED,      -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.EggLay,                  File.PEACH_IDLE,                -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.FalconDivePulled,        File.PEACH_DAMAGE_HIGH3,        -1,                         -1)
    Character.edit_action_parameters(YZELDA, 0x0B4,                          File.PEACH_TUMBLE,              -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.ThrownDKPulled,          File.PEACH_THROWN_DK_PULLED,    -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.ThrownMarioBros,         File.PEACH_THROWN_MARIO_BROS,   -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.ThrownDK,                File.PEACH_THROWN_DK,           -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.Thrown1,                 File.PEACH_THROWN1,             -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.Thrown2,                 File.PEACH_THROWN2,             -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.Thrown3,                 File.PEACH_THROWN3,             -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.ThrownFoxB,              File.PEACH_THROWN_FOX_B,        -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.Taunt,                   File.YZELDA_ANIM_TAUNT,         TAUNT,                      -1)
    Character.edit_action_parameters(YZELDA, Action.Jab1,                    File.YZELDA_ANIM_JAB,           JAB1,                        0x10000000)
    Character.edit_action_parameters(YZELDA, Action.Jab2,                    0,                              0x80000000,                  0)
    Character.edit_action_parameters(YZELDA, Action.DashAttack,              File.PEACH_DASH_ATTACK,         DASHATTACK,                 -1)
    Character.edit_action_parameters(YZELDA, Action.FTiltHigh,               File.YZELDA_ANIM_FTILT_UP,      FTILT,                      -1)
    Character.edit_action_parameters(YZELDA, Action.FTiltMidHigh,            File.YZELDA_ANIM_FTILT_UP,      FTILT,                      -1)
    Character.edit_action_parameters(YZELDA, Action.FTilt,                   File.YZELDA_ANIM_FTILT_MID,     FTILT,                      -1)
    Character.edit_action_parameters(YZELDA, Action.FTiltMidLow,             File.YZELDA_ANIM_FTILT_DOWN,    FTILT,                      -1)
    Character.edit_action_parameters(YZELDA, Action.FTiltLow,                File.YZELDA_ANIM_FTILT_DOWN,    FTILT,                      -1)
    Character.edit_action_parameters(YZELDA, Action.UTilt,                   File.YZELDA_ANIM_UTILT,         UTILT,                      -1)
    Character.edit_action_parameters(YZELDA, Action.DTilt,                   File.PEACH_D_TILT,              DTILT,                      -1)
    Character.edit_action_parameters(YZELDA, Action.FSmashHigh,              File.YZELDA_ANIM_FSMASH_UP,     FSMASH,                      0x10000000)
    Character.edit_action_parameters(YZELDA, Action.FSmashMidHigh,           File.YZELDA_ANIM_FSMASH_UP,     FSMASH,                      0x10000000)
    Character.edit_action_parameters(YZELDA, Action.FSmash,                  File.YZELDA_ANIM_FSMASH,        FSMASH,                      0x10000000)
    Character.edit_action_parameters(YZELDA, Action.FSmashMidLow,            File.YZELDA_ANIM_FSMASH_DOWN,   FSMASH,                      0x10000000)
    Character.edit_action_parameters(YZELDA, Action.FSmashLow,               File.YZELDA_ANIM_FSMASH_DOWN,   FSMASH,                      0x10000000)
    Character.edit_action_parameters(YZELDA, Action.USmash,                  File.YZELDA_ANIM_USMASH,        USMASH,                     -1)
    Character.edit_action_parameters(YZELDA, Action.DSmash,                  File.YZELDA_ANIM_DSMASH,        DSMASH,                      0x10000000)
    Character.edit_action_parameters(YZELDA, Action.AttackAirN,              File.PEACH_ATTACK_AIR_N,        AIR_ATTACK_N,               -1)
    Character.edit_action_parameters(YZELDA, Action.AttackAirF,              File.YZELDA_ANIM_AIRF,          AIR_ATTACK_F,               -1)
    Character.edit_action_parameters(YZELDA, Action.AttackAirB,              File.YZELDA_ANIM_AIRB,          AIR_ATTACK_B,               -1)
    Character.edit_action_parameters(YZELDA, Action.AttackAirU,              File.YZELDA_ANIM_AIRU,          AIR_ATTACK_U,                0x10000000)
    Character.edit_action_parameters(YZELDA, Action.AttackAirD,              File.PEACH_ATTACK_AIR_D,        AIR_ATTACK_D,               -1)
    Character.edit_action_parameters(YZELDA, Action.LandingAirF,             File.PEACH_LANDING_AIR_F,       -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.LandingAirB,             File.PEACH_LANDING_AIR_B,       -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.LandingAirX,             File.PEACH_LANDING,             -1,                         -1)
    Character.edit_action_parameters(YZELDA, Action.EntryL,                  File.YZELDA_ANIM_ENTRYL,        ENTRY,                       0)
    Character.edit_action_parameters(YZELDA, Action.EntryR,                  File.YZELDA_ANIM_ENTRYR,        ENTRY,                       0)

    Character.edit_action_parameters(YZELDA, Action.USPG_BEGIN,              File.YZELDA_ANIM_USP,           USPNEW,                      0)
    Character.edit_action_parameters(YZELDA, Action.USPG_MOVE,               File.YZELDA_ANIM_USPMOVE,       USP_MOVE,                    0)
    Character.edit_action_parameters(YZELDA, Action.USPG_END,                File.YZELDA_ANIM_USPEND,        USP_END,                     0)
    Character.edit_action_parameters(YZELDA, Action.USPA_BEGIN,              File.YZELDA_ANIM_USPAIR,        USPNEW,                      0)
    Character.edit_action_parameters(YZELDA, Action.USPA_MOVE,               File.YZELDA_ANIM_USPMOVE,       USP_MOVE,                    0)
    Character.edit_action_parameters(YZELDA, Action.USPA_END,                File.YZELDA_ANIM_USPAIREND,     USP_ENDAIR,                  0)
    Character.edit_action_parameters(YZELDA, Action.USPG_CHARGE,             File.YZELDA_ANIM_USPMOVE,       USP_MOVE,                    0)
    Character.edit_action_parameters(YZELDA, Action.USPA_CHARGE,             File.YZELDA_ANIM_USPMOVE,       USP_MOVE,                    0)
    
    
    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(YZELDA, Action.EntryL,     -1,             0x8013D994,                  0,            0,                              0)
    Character.edit_action(YZELDA, Action.EntryR,     -1,             0x8013D994,                  0,            0,                              0)
    //Character.edit_action(YZELDA, Action.USPG_BEGIN,  0x11,          YZeldaUSP.begin_main_,       0,            0x800D8BB4,                     YZeldaUSP.ground_begin_collision_)
    Character.edit_action(YZELDA, Action.USPG_MOVE,  -1,            YZeldaUSP.move_initial_,                          0x80160370,    YZeldaUSP.movement_physics_,    YZeldaUSP.ground_move_collision_)
    Character.edit_action(YZELDA, Action.USPG_END,    0x11,          YZeldaUSP.ground_end_main_,  0,            0x800D8BB4,                     0x800DDF44)
    //Character.edit_action(YZELDA, Action.USPA_BEGIN,  0x11,          YZeldaUSP.begin_main_,       0,            YZeldaUSP.air_begin_physics_,   YZeldaUSP.air_begin_collision_)
    //Character.edit_action(YZELDA, Action.USPA_MOVE,   0x11,          YZeldaUSP.move_main_,        0x80160370,   YZeldaUSP.move_physics_,        YZeldaUSP.air_move_collision_)
    Character.edit_action(YZELDA, Action.USPA_END,    0x11,          YZeldaUSP.air_end_main_,     0,            YZeldaUSP.end_physics_,         YZeldaUSP.end_air_collision_)
    Character.edit_action(YZELDA, Action.USPA_MOVE,  -1,            -1,                          0x80160370,    YZeldaUSP.movement_physics_,    YZeldaUSP.air_move_collision_)
    
   


    // Modify Menu Action Parameters              // Action // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(YZELDA,  0x0,      File.PEACH_IDLE,            -1,                         -1)
    Character.edit_menu_action_parameters(YZELDA,  0x1,      File.YZELDA_ANIM_WIN1,      WIN1,                       -1)
    Character.edit_menu_action_parameters(YZELDA,  0x2,      File.YZELDA_ANIM_WIN2,      WIN2,                       -1)
    Character.edit_menu_action_parameters(YZELDA,  0x3,      File.YZELDA_ANIM_WIN3,      WIN3,                       -1)
    Character.edit_menu_action_parameters(YZELDA,  0x4,      File.YZELDA_ANIM_WIN1,      WIN1,                       -1)
    Character.edit_menu_action_parameters(YZELDA,  0x5,      File.PEACH_CLAP,            IDLE,                       -1)
    Character.edit_menu_action_parameters(YZELDA,  0x9,      File.PEACH_CONTINUE_FALL,   -1,                         -1)
    Character.edit_menu_action_parameters(YZELDA,  0xA,      File.PEACH_CONTINUE_UP,     -1,                         -1)
    Character.edit_menu_action_parameters(YZELDA,  0xD,      File.YZELDA_ANIM_ONEPOSE,   ONEPOSE,                    -1)
    Character.edit_menu_action_parameters(YZELDA,  0xE,      File.PEACH_CPU_POSE,        -1,                         -1)

    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(YZELDA, NSP_Ground_Begin,   -1,             File.YZELDA_ANIM_NSPSTART,     NSP_BEGIN,                  0)
    Character.add_new_action_params(YZELDA, NSP_Ground_Wait,    -1,             File.YZELDA_ANIM_NSPLOOP,      NSP_WAIT,                   0)
    Character.add_new_action_params(YZELDA, NSP_Ground_End,     -1,             File.YZELDA_ANIM_NSPEND,       NSP_END,                    0)
    Character.add_new_action_params(YZELDA, NSP_Air_Begin,      -1,             File.YZELDA_ANIM_NSPSTARTAIR,  NSP_BEGIN,                  0)
    Character.add_new_action_params(YZELDA, NSP_Air_Wait,       -1,             File.YZELDA_ANIM_NSPLOOPAIR,   NSP_WAIT,                   0)
    Character.add_new_action_params(YZELDA, NSP_Air_End,        -1,             File.YZELDA_ANIM_NSPENDAIR,    NSP_END,                    0)
    Character.add_new_action_params(YZELDA, DSP_Ground,         -1,             File.YZELDA_ANIM_DSPBEGIN,     DSP,                        0x10000000)
    Character.add_new_action_params(YZELDA, DSP_Ground_Attack,  -1,             File.YZELDA_ANIM_DSPEND,       DSP_ATTACK,                 0x10000000)
    Character.add_new_action_params(YZELDA, DSP_Air,            -1,             File.YZELDA_ANIM_DSPBEGINAIR,  DSP,                        0x10000000)
    Character.add_new_action_params(YZELDA, DSP_Air_Attack,     -1,             File.YZELDA_ANIM_DSPENDAIR,    DSP_ATTACK,                 0x10000000)
    
    

    // Add Actions      // Action Name     // Base Action  //Parameters  // Staling ID   // Main ASM    // Interrupt/Other ASM     // Movement/Physics ASM    // Collision ASM
    Character.add_new_action(YZELDA, NSP_Ground_Begin,  -1,  ActionParams.NSP_Ground_Begin,  0x12, YZeldaNSP.ground_begin_main_, 0,  0x800D8BB4,             YZeldaNSP.ground_collision_)
    Character.add_new_action(YZELDA, NSP_Ground_Wait,   -1,  ActionParams.NSP_Ground_Wait,   0x12, YZeldaNSP.ground_wait_main_,  0,  0x800D8BB4,             YZeldaNSP.ground_collision_)
    Character.add_new_action(YZELDA, NSP_Ground_End,    -1,  ActionParams.NSP_Ground_End,    0x12, YZeldaNSP.end_main_,          0,  0x800D8BB4,             YZeldaNSP.ground_collision_)
    Character.add_new_action(YZELDA, NSP_Air_Begin,     -1,  ActionParams.NSP_Air_Begin,     0x12, YZeldaNSP.air_begin_main_,    0,  0x800D90E0,             YZeldaNSP.air_collision_)
    Character.add_new_action(YZELDA, NSP_Air_Wait,      -1,  ActionParams.NSP_Air_Wait,      0x12, YZeldaNSP.air_wait_main_,     0,  0x800D90E0,             YZeldaNSP.air_collision_)
    Character.add_new_action(YZELDA, NSP_Air_End,       -1,  ActionParams.NSP_Air_End,       0x12, YZeldaNSP.end_main_,          0,  0x800D90E0,             YZeldaNSP.air_collision_end_)
    Character.add_new_action(YZELDA, DSP_Ground,        -1,  ActionParams.DSP_Ground,        0x1E, YZeldaDSP.main_,              0,  0x800D8BB4,             YZeldaDSP.ground_collision_)
    Character.add_new_action(YZELDA, DSP_Ground_Attack, -1,  ActionParams.DSP_Ground_Attack, 0x1E, 0x800D94C4,                   0,  0x800D8BB4,             YZeldaDSP.ground_collision_)
    Character.add_new_action(YZELDA, DSP_Air,           -1,  ActionParams.DSP_Air,           0x1E, YZeldaDSP.main_,              0,  YZeldaDSP.air_physics_, YZeldaDSP.air_collision_)
    Character.add_new_action(YZELDA, DSP_Air_Attack,    -1,  ActionParams.DSP_Air_Attack,    0x1E, 0x800D94E8,                   0,  YZeldaDSP.air_physics_, YZeldaDSP.air_collision_)

    

    // Use Mario's initial/grounded script.
    Character.table_patch_start(initial_script, Character.id.YZELDA, 0x4)
    dw 0x800D7DCC
    OS.patch_end()
    Character.table_patch_start(grounded_script, Character.id.YZELDA, 0x4)
    dw 0x800DE428
    OS.patch_end()

    Character.table_patch_start(air_dsp, Character.id.YZELDA, 0x4)
    dw      YZeldaDSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_dsp, Character.id.YZELDA, 0x4)
    dw      YZeldaDSP.ground_initial_
    OS.patch_end()

    Character.table_patch_start(air_nsp, Character.id.YZELDA, 0x4)
    dw      YZeldaNSP.air_begin_initial_
    OS.patch_end()

    Character.table_patch_start(ground_nsp, Character.id.YZELDA, 0x4)
    dw      YZeldaNSP.ground_begin_initial_
    OS.patch_end()

    Character.table_patch_start(air_usp, Character.id.YZELDA, 0x4)
    dw      YZeldaUSP.air_begin_initial_
    OS.patch_end()

    Character.table_patch_start(ground_usp, Character.id.YZELDA, 0x4)
    dw      YZeldaUSP.ground_begin_initial_
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.YZELDA, 0x4)
    float32 1.225
    OS.patch_end()

    Character.table_patch_start(jab_3, Character.id.YZELDA, 0x4)
    dw      Character.jab_3.DISABLED        // disable jab 3
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.YZELDA, 0x2)
    dh  0x05D8
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.YZELDA, 0xC)
    dh 0x2B
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.YZELDA, 0, 5, 6, 7, 1, 2, 3)
    Teams.add_team_costume(YELLOW, YZELDA, 4)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(YZELDA, MAGENTA, RED, BLUE, GREEN, YELLOW, WHITE, PINK, AZURE, BLACK, NA, NA, NA)

    // Set action strings
    Character.table_patch_start(action_string, Character.id.YZELDA, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // Set Remix 1P ending music
    Character.table_patch_start(remix_1p_end_bgm, Character.id.YZELDA, 0x2)
    dh {MIDI.id.BRAWL_OOT}
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.YZELDA, 0x4)
    float32 1.125
    OS.patch_end()

    // Set 1P Victory Image
    SinglePlayer.set_ending_image(Character.id.YZELDA, File.PEACH_VICTORY_IMAGE_BOTTOM)

    // Allows Marth to use his entry which is similar to Link
    // Set entry action
    Character.table_patch_start(entry_action, Character.id.YZELDA, 0x8)
    dw Action.EntryR, Action.EntryL
    OS.patch_end()
    Character.table_patch_start(entry_script, Character.id.YZELDA, 0x4)
    dw yzelda_entry_routine_
    OS.patch_end()

    // @ Description
    // Replaces a small subroutine which usually sets the up special delay for Fox, extends to
    // include Falco.
    scope up_special_delay_: {
        OS.patch_start(0xD6A38, 0x8015BFF8)
        jal     up_special_delay_
        OS.patch_end()
        OS.patch_start(0xD6A7C, 0x8015C03C)
        jal     up_special_delay_
        OS.patch_end()

        addiu   sp, sp,-0x0008              // allocate stack space
        sw      t0, 0x0004(sp)              // store t0
        lw      v0, 0x0084(a0)              // v0 = player struct, (original line 1 )
        lw      t6, 0x0008(v0)              // t6 = character id
        ori     t0, r0, Character.id.FALCO  // t0 = FALCO
        beql    t0, t6, _end                // branch if character = FALCO
        addiu   t6, r0, 0x0016              // up special delay = 0x16
        ori     t0, r0, Character.id.SLIPPY // t0 = SLIPPY
        beql    t0, t6, _end                // branch if character = SLIPPY
        addiu   t6, r0, 12                  // up special delay = 12
        ori     t0, r0, Character.id.YZELDA // t0 = YZELDA
        beql    t0, t6, _end                // branch if character = YZELDA
        addiu   t6, r0, 6                   // up special delay = 6
        ori     t0, r0, Character.id.PEPPY  // t0 = PEPPY
        beql    t0, t6, _end                // branch if character = PEPPY
        addiu   t6, r0, 16                  // up special delay = 16

        addiu   t6, r0, 0x0023              // up special delay = 0x23 (original line 2)
        _end:
        lw      t0, 0x0004(sp)              // load t0
        addiu   sp, sp, 0x0008              // deallocate stack space
        jr      ra                          // return (original line 3)
        sw      t6, 0x0B18(v0)              // store up special delay (original line 4)
    }

    // @ Description
    // Patches  a small subroutine which usually sets the up special duration for Fox.
    // Sets a different value for Slippy Toad.
    scope up_special_duration_: {
        OS.patch_start(0xD6F08, 0x8015C4C8)
        j       up_special_duration_
        nop
        _return:
        OS.patch_end()

        lw      t6, 0x0008(a0)              // t6 = character id
        lli     at, Character.id.SLIPPY     // at = id.Slippy
        beql     at, t6, _end                // branch if character = SLIPPY
        lli     t6, SlippyUSP.DURATION      // up special duration = SlippyUSP.DURATION
        lli     at, Character.id.YZELDA     // at = id.YZelda
        beql     at, t6, _end                // branch if character = YZELDA
        lli     t6, YZeldaUSP.DURATION      // up special duration = YZeldaUSP.DURATION

        // if the character isn't Slippy
        addiu   t6, r0, 0x001E              // up special duration = 0x1E (30) (original line 1)

        _end:
        j       _return                     // continue original subroutine
        sw      t6, 0x0B24(a0)              // store duration (original line 2)
    }


    // @ Description
    // Entry routine for Marth. Sets the correct facing direction and then jumps to Link's entry routine.
    scope yzelda_entry_routine_: {
        lw      a1, 0x0B1C(s0)              // a1 = direction
        addiu   at, r0,-0x0001              // at = -1 (left)
        beql    a1, at, _end                // branch if direction = left...
        sw      v1, 0x0B24(s0)              // ...and enable reversed direction flag

        _end:
        j       0x8013DCCC                  // jump to Link's entry routine to load entry object
        nop
    }

    scope CloakingFix: {
        scope fix_: {
            // s8 = player struct
            // v0 = first custom part struct (arrow)
            addiu   sp, sp, -0x0010             // allocate stack space
            sw      t1, 0x0004(sp)              // save return address

            _check_yzelda:
            // Check which part is being displayed
            li      t1, _check_yzelda_2         // t1 = return address
            lbu     t2, 0x0997(s8)              // t2 = yzelda right hand part_id
            lli     t9, 0x0001                  // t9 = special part of hand holding arrow
            beql    t2, t9, _fix_yzelda         // if holding arrow hand, then already have correct v0
            nop

            _check_yzelda_2:
            li      v0, CharEnvColor.custom_display_lists_struct_yzelda_arrow_light
            lw      t1, 0x0004(sp)              // t1 = return address
            lbu     t2, 0x0997(s8)              // t2 = yzelda right hand part_id
            lli     t9, 0x0002                  // t9 = special part of hand holding light arrow
            beql    t2, t9, _fix_yzelda         // if holding light arrow hand, fix
            addiu   sp, sp, 0x0010              // allocate stack space

            j       CharEnvColor.override_env_color_._return
            addiu   sp, sp, 0x0010              // allocate stack space

            _fix_yzelda:
            j       CharEnvColor.override_env_color_._fix
            nop                                 // after fix, jr's to t1
        }
    }

}
