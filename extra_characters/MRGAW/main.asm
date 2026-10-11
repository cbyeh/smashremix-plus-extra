// GameAndWatch2D.asm

// This file contains file inclusions, action edits, and assembly for 2D Mr. Game and Watch.
scope GameAndWatch2D {

    // Insert Special Attacks
    include "GameAndWatchSpecial.asm"

    // THROWS
    THROW_F_:; Moveset.THROW_DATA(THROW_F_DATA); Moveset.GO_TO(THROW_F)
    THROW_B_:; Moveset.THROW_DATA(THROW_B_DATA); Moveset.GO_TO(THROW_B)
    GRAB_:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); Moveset.GO_TO(GRAB)

	insert SLEEP_,"moveset/SLEEP.bin"; Moveset.GO_TO(SLEEP_) // loops
	insert SPARKLE_,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE_) // loops
	insert SHIELDBREAK_,"moveset/SHIELDBREAK.bin"; Moveset.GO_TO(SPARKLE_) // goes to sparkle
	insert STUN_,"moveset/STUN.bin"; Moveset.GO_TO(STUN_) // loops

	insert WALK1_,"moveset/WALK1.bin"; Moveset.GO_TO(WALK1_) // loops
	insert WALK2_,"moveset/WALK2.bin"; Moveset.GO_TO(WALK2_) // loops
	insert WALK3_,"moveset/WALK3.bin"; Moveset.GO_TO(WALK3_) // loops
	insert RUN_,"moveset/RUN.bin"; Moveset.GO_TO(RUN_) // loops

	POSE1P:; dw 0xA0600001;dw 0xA0800001; dw 0
	
    BEAMSWORD_JAB:; dw 0xBC000004; dw 0xA0600001; dw 0x08000004; dw 0xCC040000; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_JAB); dw 0x04000005; dw 0xCC03FFFF; dw 0x04000004; dw 0x18000000; dw 0
    BEAMSWORD_TILT:; dw 0xBC000004; dw 0xA0600001; dw 0x08000004; dw 0xBC000004; dw 0xCC040000; dw 0x08000009; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_TILT); dw 0x04000003; dw 0xCC03FFFF; dw 0x04000007; dw 0x18000000; dw 0
    BEAMSWORD_SMASH:; dw 0xBC000004; dw 0xA0600001; dw 0x50000000; dw 0x08000014; dw 0xCC040000; dw 0x08000016; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_SMASH); dw 0x04000007; dw 0x18000000; dw 0x04000002; dw 0xCC03FFFF; dw 0x0800002D; dw 0xBC000004; dw 0
    BEAMSWORD_DASH:; dw 0xBC000004; dw 0xA0600001; dw 0x08000004; dw 0xCC040000; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_DASH); dw 0x04000004; dw 0xCC03FFFF; dw 0x04000016; dw 0x18000000; dw 0x08000020; dw 0xBC000004; dw 0
    BAT_JAB:; dw 0xBC000004; dw 0xA0600001; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.BAT_JAB); dw 0x04000009; dw 0x18000000; dw 0
    BAT_TILT:; dw 0xBC000004; dw 0xA0600001; dw 0x08000004; dw 0xBC000004; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.BAT_TILT); dw 0x0400000A; dw 0x18000000; dw 0x08000026; dw 0xBC000004; dw 0
    BAT_SMASH:; dw 0x50000000; dw 0xA0600001; dw 0xBC000004; dw 0xC4000007; dw 0xB1300028; dw 0x08000014; dw 0xBC000004; dw 0x08000016; Moveset.SUBROUTINE(Moveset.shared.BAT_SMASH); dw 0x04000007; dw 0x18000000; dw 0x0800002D; dw 0xBC000004; dw 0
    BAT_DASH:; dw 0xBC000004; dw 0xA0600001; dw 0x08000004; Moveset.SUBROUTINE(Moveset.shared.BAT_DASH); dw 0x0400001A; dw 0x18000000; dw 0x08000020; dw 0xBC000004; dw 0
    FAN_JAB:; dw 0xBC000004; dw 0xA0600001; dw 0x08000005; Moveset.SUBROUTINE(Moveset.shared.FAN_JAB); dw 0x04000005; dw 0x18000000; dw 0
    FAN_TILT:; dw 0xBC000004; dw 0xA0600001; dw 0x08000004; dw 0xBC000004; dw 0x08000005; Moveset.SUBROUTINE(Moveset.shared.FAN_TILT); dw 0x0400000A; dw 0x18000000; dw 0x08000026; dw 0xBC000004; dw 0
    FAN_SMASH:; dw 0xBC000004; dw 0xA0600001; dw 0x08000014; dw 0xBC000004; dw 0x08000016; Moveset.SUBROUTINE(Moveset.shared.FAN_SMASH); dw 0x04000007; dw 0x18000000; dw 0x0800002D; dw 0xBC000004; dw 0
    FAN_DASH:; dw 0xBC000004; dw 0xA0600001; dw 0x08000004; Moveset.SUBROUTINE(Moveset.shared.FAN_DASH); dw 0x0400001A; dw 0x18000000; dw 0x08000020; dw 0xBC000004; dw 0
    STARROD_JAB:; dw 0xBC000004; dw 0xA0600001; dw 0xB12C0010; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.STARROD_JAB); dw 0x04000009; dw 0x18000000; dw 0
    STARROD_TILT:; dw 0xBC000004; dw 0xA0600001; dw 0x08000004; dw 0xBC000004; dw 0xB12C000D; dw 0x08000009; Moveset.SUBROUTINE(Moveset.shared.STARROD_TILT); dw 0x04000001; dw 0x54000001; dw 0x04000009; dw 0x18000000;  dw 0x08000026; dw 0xBC000004; dw 0
    STARROD_SMASH:; dw 0x50000000; dw 0xA0600001; dw 0xBC000004; dw 0x08000014; dw 0xBC000004; dw 0xB12C0024; dw 0x08000016; Moveset.SUBROUTINE(Moveset.shared.STARROD_SMASH); dw 0x04000001; dw 0x54000002; dw 0x04000006; dw 0x18000000; dw 0x0800002D; dw 0xBC000004; dw 0
    STARROD_DASH:; dw 0xBC000004; dw 0xA0600001; dw 0xB12C0014; dw 0x08000004; Moveset.SUBROUTINE(Moveset.shared.STARROD_DASH); dw 0x0400001A; dw 0x18000000; dw 0x08000020; dw 0xBC000004; dw 0
	
	// @ Description
    // Game And Watch's extra actions
    scope Action {
        constant Jab3(0x0DC)
        constant Appear1(0x0DD)
        constant Appear2(0x0DE)
        constant Chef(0x0DF)
        constant ChefAir(0x0E0)
        constant Fire(0x0E1)
        constant FireAir(0x0E2)
        constant JudgeBegin(0x0E3)
	constant JudgeBeginAir(0x0E4)
        constant Judge1(0x0E5)
        constant Judge1Air(0x0E6)
        constant Judge2(0x0E7)
        constant Judge2Air(0x0E8)
        constant Judge3(0x0E9)
        constant Judge3Air(0x0EA)
        constant Judge4(0x0EB)
        constant Judge4Air(0x0EC)
        constant Judge5(0x0ED)
        constant Judge5Air(0x0EE)
	constant Judge6(0x0EF)
        constant Judge6Air(0x0F0)
        constant Judge7(0x0F1)
        constant Judge7Air(0x0F2)
        constant Judge8(0x0F3)
        constant Judge8Air(0x0F4)
        constant Judge9(0x0F5)
        constant Judge9Air(0x0F6)

        // strings!
        //string_0x0DC:; String.insert("Jab3")
        //string_0x0DD:; String.insert("Appear1")
        //string_0x0DE:; String.insert("Appear2")
        string_0x0DF:; String.insert("Chef")
        string_0x0E0:; String.insert("ChefAir")
        string_0x0E1:; String.insert("Fire")
        string_0x0E2:; String.insert("FireAir")
        string_0x0E3:; String.insert("JudgeBegin")
	string_0x0E4:; String.insert("JudgeBegin")
        string_0x0E5:; String.insert("Judge1")
	string_0x0E6:; String.insert("Judge1Air")
        string_0x0E7:; String.insert("Judge2")
	string_0x0E8:; String.insert("Judge2Air")
        string_0x0E9:; String.insert("Judge3")
	string_0x0EA:; String.insert("Judge3Air")
        string_0x0EB:; String.insert("Judge4")
	string_0x0EC:; String.insert("Judge4Air")
        string_0x0ED:; String.insert("Judge5")
	string_0x0EE:; String.insert("Judge5Air")
	string_0x0EF:; String.insert("Judge6")
	string_0x0F0:; String.insert("Judge6Air")
        string_0x0F1:; String.insert("Judge7")
	string_0x0F2:; String.insert("Judge7Air")
        string_0x0F3:; String.insert("Judge8")
	string_0x0F4:; String.insert("Judge8Air")
        string_0x0F5:; String.insert("Judge9")
	string_0x0F6:; String.insert("Judge9Air")

        action_string_table:
        dw Action.COMMON.string_jab3
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw string_0x0DF
        dw string_0x0E0
        dw string_0x0E1 //Action.MARIO.string_0x0E1
        dw string_0x0E2 //Action.MARIO.string_0x0E2
        dw string_0x0E3 //Action.MARIO.string_0x0E3
        dw string_0x0E4 //Action.MARIO.string_0x0E4
	dw string_0x0E5
	dw string_0x0E6
	dw string_0x0E7
	dw string_0x0E8
	dw string_0x0E9
	dw string_0x0EA
	dw string_0x0EB
	dw string_0x0EC
	dw string_0x0ED
	dw string_0x0EE
	dw string_0x0EF
	dw string_0x0F0
	dw string_0x0F1
	dw string_0x0F2
	dw string_0x0F3
	dw string_0x0F4
	dw string_0x0F5
	dw string_0x0F6
    }

    OS.align(16)

    // Modify Action Parameters              // Action                      // Animation                  // Moveset Data           // Flags
    Character.edit_action_parameters(MRGAW, Action.DeadU,                  File.MRGAW_ANIM_TUMBLE,                 -1,                      -1)
    Character.edit_action_parameters(MRGAW, Action.ScreenKO,               File.MRGAW_ANIM_TUMBLE,                 -1,                      -1)
    Character.edit_action_parameters(MRGAW, Action.Revive1,                File.MRGAW_ANIM_DOWNBOUNCED,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.Revive2,                File.MRGAW_ANIM_DOWNSTANDD,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ReviveWait,             File.MRGAW_ANIM_IDLE,                   -1,                       -1)
    Character.edit_action_parameters(MRGAW, Action.Idle,                   File.MRGAW_ANIM_IDLE,                   IDLE,                       -1)
    Character.edit_action_parameters(MRGAW, Action.Walk1,                  File.MRGAW_ANIM_WALK1,                 WALK1_,                         -1)
    Character.edit_action_parameters(MRGAW, Action.Walk2,                  File.MRGAW_ANIM_WALK2,                 WALK2_,                         -1)
    Character.edit_action_parameters(MRGAW, Action.Walk3,                  File.MRGAW_ANIM_WALK3,                 WALK3_,                         -1)
    Character.edit_action_parameters(MRGAW, 0x00E,                         File.MRGAW_ANIM_WALKEND,               SLOPES,                         -1)
    Character.edit_action_parameters(MRGAW, Action.Dash,                   File.MRGAW_ANIM_DASH,                   DASH,                       -1)
    Character.edit_action_parameters(MRGAW, Action.Run,                    File.MRGAW_ANIM_RUN,                    RUN_,                        -1)
    Character.edit_action_parameters(MRGAW, Action.RunBrake,               File.MRGAW_ANIM_RUNBRAKE,              SLOPES,                  -1)
    Character.edit_action_parameters(MRGAW, Action.Turn,                   File.MRGAW_ANIM_TURN,                   TURN,                       -1)
    Character.edit_action_parameters(MRGAW, Action.TurnRun,                File.MRGAW_ANIM_TURNRUN,               -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.JumpSquat,              File.MRGAW_ANIM_LANDING,                -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ShieldJumpSquat,        File.MRGAW_ANIM_LANDING,                -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.JumpF,                  File.MRGAW_ANIM_JUMPF,                 JUMP,                     -1)
    Character.edit_action_parameters(MRGAW, Action.JumpB,                  File.MRGAW_ANIM_JUMPB,                 JUMP,                     -1)
    Character.edit_action_parameters(MRGAW, Action.JumpAerialF,            File.MRGAW_ANIM_JUMPAERIALF,          DOUBLEJUMP,                     -1)
    Character.edit_action_parameters(MRGAW, Action.JumpAerialB,            File.MRGAW_ANIM_JUMPAERIALB,          DOUBLEJUMP,                     -1)
    Character.edit_action_parameters(MRGAW, Action.Fall,                   File.MRGAW_ANIM_FALL,                   -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.FallAerial,             File.MRGAW_ANIM_FALLAERIAL,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.Crouch,                 File.MRGAW_ANIM_CROUCH,                 SLOPES,                         -1)
    Character.edit_action_parameters(MRGAW, Action.CrouchIdle,             File.MRGAW_ANIM_CROUCHIDLE,            SLOPES,                         -1)
    Character.edit_action_parameters(MRGAW, Action.CrouchEnd,              File.MRGAW_ANIM_CROUCHEND,             SLOPES,                         -1)
    Character.edit_action_parameters(MRGAW, Action.LandingLight,           File.MRGAW_ANIM_LANDING,                SLOPES,                         -1)
    Character.edit_action_parameters(MRGAW, Action.LandingHeavy,           File.MRGAW_ANIM_LANDING,                SLOPES,                         -1)
    Character.edit_action_parameters(MRGAW, Action.Pass,                   File.MRGAW_ANIM_PLATFORMDROP,              -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ShieldDrop,             File.MRGAW_ANIM_PLATFORMDROP,              -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.Teeter,                 File.MRGAW_ANIM_TEETER,                 SLOPES,                     -1)
    Character.edit_action_parameters(MRGAW, Action.TeeterStart,            File.MRGAW_ANIM_TEETERSTART,            SLOPES,                     -1)
    Character.edit_action_parameters(MRGAW, Action.DamageHigh1,            File.MRGAW_ANIM_DAMAGEHI1,             MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageHigh2,            File.MRGAW_ANIM_DAMAGEHI2,             MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageHigh3,            File.MRGAW_ANIM_DAMAGEHI3,             MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageMid1,             File.MRGAW_ANIM_DAMAGEMID1,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageMid2,             File.MRGAW_ANIM_DAMAGEMID2,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageMid3,             File.MRGAW_ANIM_DAMAGEMID3,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageLow1,             File.MRGAW_ANIM_DAMAGELOW1,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageLow2,             File.MRGAW_ANIM_DAMAGELOW2,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageLow3,             File.MRGAW_ANIM_DAMAGELOW3,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageAir1,             File.MRGAW_ANIM_DAMAGEAIR1,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageAir2,             File.MRGAW_ANIM_DAMAGEAIR2,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageAir3,             File.MRGAW_ANIM_DAMAGEAIR3,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageElec1,            File.MRGAW_ANIM_DAMAGEELEC,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageElec2,            File.MRGAW_ANIM_DAMAGEELEC,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageFlyHigh,          File.MRGAW_ANIM_DAMAGEFLYHI,           MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageFlyMid,           File.MRGAW_ANIM_DAMAGEFLYMID,          MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageFlyLow,           File.MRGAW_ANIM_DAMAGEFLYLOW,          MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageFlyTop,           File.MRGAW_ANIM_DAMAGEFLYTOP,          MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.DamageFlyRoll,          File.MRGAW_ANIM_DAMAGEFLYROLL,         MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.WallBounce,             File.MRGAW_ANIM_TUMBLE,                MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.Tumble,                 File.MRGAW_ANIM_TUMBLE,                MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.FallSpecial,            File.MRGAW_ANIM_FALLSPECIAL,           MOUTH,                       -1)
    Character.edit_action_parameters(MRGAW, Action.LandingSpecial,         File.MRGAW_ANIM_LANDING,                SLOPES,                         -1)
    Character.edit_action_parameters(MRGAW, Action.EnterPipe,              File.MRGAW_ANIM_ENTERPIPE,             -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ExitPipe,               File.MRGAW_ANIM_EXITPIPE,              -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ExitPipeWalk,           File.MRGAW_ANIM_EXITPIPEWALK,         -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.CeilingBonk,            File.MRGAW_ANIM_CEILINGBONK,           -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.DownBounceD,            File.MRGAW_ANIM_DOWNBOUNCED,            -1,                -1)
    Character.edit_action_parameters(MRGAW, Action.DownBounceU,            File.MRGAW_ANIM_DOWNBOUNCEU,            -1,                -1)
    Character.edit_action_parameters(MRGAW, Action.DownStandD,             File.MRGAW_ANIM_DOWNSTANDD,            -1,                 -1)
    Character.edit_action_parameters(MRGAW, Action.DownStandU,             File.MRGAW_ANIM_DOWNSTANDU,            -1,                 -1)
    Character.edit_action_parameters(MRGAW, Action.TechF,                  File.MRGAW_ANIM_TECHF,                 TECHFB,                  -1)
    Character.edit_action_parameters(MRGAW, Action.TechB,                  File.MRGAW_ANIM_TECHB,                 TECHFB,                  -1)
    Character.edit_action_parameters(MRGAW, Action.DownForwardD,           File.MRGAW_ANIM_DOWNFORWARDD,            -1,                  -1)
    Character.edit_action_parameters(MRGAW, Action.DownForwardU,           File.MRGAW_ANIM_DOWNFORWARDU,            -1,                  -1)
    Character.edit_action_parameters(MRGAW, Action.DownBackD,              File.MRGAW_ANIM_DOWNBACKD,              -1,                  -1)
    Character.edit_action_parameters(MRGAW, Action.DownBackU,              File.MRGAW_ANIM_DOWNBACKU,              -1,                  -1)
    Character.edit_action_parameters(MRGAW, Action.DownAttackD,            File.MRGAW_ANIM_DOWNATTACKD,             DOWN_ATTACK,              -1)
    Character.edit_action_parameters(MRGAW, Action.DownAttackU,            File.MRGAW_ANIM_DOWNATTACKU,             DOWN_ATTACK,              -1)
    Character.edit_action_parameters(MRGAW, Action.Tech,                   File.MRGAW_ANIM_TECH,                   TECH,                       -1)
    Character.edit_action_parameters(MRGAW, Action.ClangRecoil,            File.MRGAW_ANIM_CLANGRECOIL,           SLOPES,                         -1)
    Character.edit_action_parameters(MRGAW, Action.CliffCatch,             File.MRGAW_ANIM_CLIFFCATCH,              -1,                -1)
    Character.edit_action_parameters(MRGAW, Action.CliffWait,              File.MRGAW_ANIM_CLIFFWAIT,               -1,                 -1)
    Character.edit_action_parameters(MRGAW, Action.CliffQuick,             File.MRGAW_ANIM_CLIFFQUICK,              -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.CliffClimbQuick1,       File.MRGAW_ANIM_CLIFFCLIMBQUICK1,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.CliffClimbQuick2,       File.MRGAW_ANIM_CLIFFCLIMBQUICK2,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.CliffSlow,              File.MRGAW_ANIM_CLIFFSLOW,               -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.CliffClimbSlow1,        File.MRGAW_ANIM_CLIFFCLIMBSLOW1,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.CliffClimbSlow2,        File.MRGAW_ANIM_CLIFFCLIMBSLOW2,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.CliffAttackQuick1,      File.MRGAW_ANIM_CLIFFATTACKQUICK1,            -1,                        0x50000000)
    Character.edit_action_parameters(MRGAW, Action.CliffAttackQuick2,      File.MRGAW_ANIM_CLIFFATTACKQUICK2,            CLIFF_ATK_QUICK_2,         0x50000000)
    Character.edit_action_parameters(MRGAW, Action.CliffAttackSlow1,       File.MRGAW_ANIM_CLIFFATTACKSLOW1,            -1,                         0x50000000)
    Character.edit_action_parameters(MRGAW, Action.CliffAttackSlow2,       File.MRGAW_ANIM_CLIFFATTACKSLOW2,            CLIFF_ATK_SLOW_2,           0x50000000)
    Character.edit_action_parameters(MRGAW, Action.CliffEscapeQuick1,      File.MRGAW_ANIM_CLIFFESCAPEQUICK1,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.CliffEscapeQuick2,      File.MRGAW_ANIM_CLIFFESCAPEQUICK2,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.CliffEscapeSlow1,       File.MRGAW_ANIM_CLIFFESCAPESLOW1,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.CliffEscapeSlow2,       File.MRGAW_ANIM_CLIFFESCAPESLOW2,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.LightItemPickup,        File.MRGAW_ANIM_ITEMPICKUPLIGHT,           -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.HeavyItemPickup,        File.MRGAW_ANIM_ITEMPICKUPHEAVY,           -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemDrop,               File.MRGAW_ANIM_ITEMDROP,               -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemThrowDash,          File.MRGAW_ANIM_ITEMTHROWDASH,         -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemThrowF,             File.MRGAW_ANIM_ITEMTHROWF,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemThrowB,             File.MRGAW_ANIM_ITEMTHROWF,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemThrowU,             File.MRGAW_ANIM_ITEMTHROWU,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemThrowD,             File.MRGAW_ANIM_ITEMTHROWD,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemThrowSmashF,        File.MRGAW_ANIM_ITEMTHROWF,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemThrowSmashB,        File.MRGAW_ANIM_ITEMTHROWF,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemThrowSmashU,        File.MRGAW_ANIM_ITEMTHROWU,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemThrowSmashD,        File.MRGAW_ANIM_ITEMTHROWD,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemThrowAirF,          File.MRGAW_ANIM_ITEMTHROWAIRF,        -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemThrowAirB,          File.MRGAW_ANIM_ITEMTHROWAIRF,        -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemThrowAirU,          File.MRGAW_ANIM_ITEMTHROWAIRU,        -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemThrowAirD,          File.MRGAW_ANIM_ITEMTHROWAIRD,        -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemThrowAirSmashF,     File.MRGAW_ANIM_ITEMTHROWAIRF,        -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemThrowAirSmashB,     File.MRGAW_ANIM_ITEMTHROWAIRF,        -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemThrowAirSmashU,     File.MRGAW_ANIM_ITEMTHROWAIRU,        -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ItemThrowAirSmashD,     File.MRGAW_ANIM_ITEMTHROWAIRD,        -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.HeavyItemThrowF,        File.MRGAW_ANIM_HEAVYITEMTHROW,        -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.HeavyItemThrowB,        File.MRGAW_ANIM_HEAVYITEMTHROW,        -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.HeavyItemThrowSmashF,   File.MRGAW_ANIM_HEAVYITEMTHROW,        -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.HeavyItemThrowSmashB,   File.MRGAW_ANIM_HEAVYITEMTHROW,        -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.BeamSwordNeutral,       File.MRGAW_ANIM_ITEMNEUTRAL,            BEAMSWORD_JAB,              -1)
    Character.edit_action_parameters(MRGAW, Action.BeamSwordTilt,          File.MRGAW_ANIM_ITEMTILT,               BEAMSWORD_TILT,             -1)
    Character.edit_action_parameters(MRGAW, Action.BeamSwordSmash,         File.MRGAW_ANIM_ITEMSMASH,              BEAMSWORD_SMASH,            -1)
    Character.edit_action_parameters(MRGAW, Action.BeamSwordDash,          File.MRGAW_ANIM_ITEMDASH,               BEAMSWORD_DASH,             -1)
    Character.edit_action_parameters(MRGAW, Action.BatNeutral,             File.MRGAW_ANIM_ITEMNEUTRAL,            BAT_JAB,                    -1)
    Character.edit_action_parameters(MRGAW, Action.BatTilt,                File.MRGAW_ANIM_ITEMTILT,               BAT_TILT,                   -1)
    Character.edit_action_parameters(MRGAW, Action.BatSmash,               File.MRGAW_ANIM_ITEMSMASH,              BAT_SMASH,                  -1)
    Character.edit_action_parameters(MRGAW, Action.BatDash,                File.MRGAW_ANIM_ITEMDASH,               BAT_DASH,                   -1)
    Character.edit_action_parameters(MRGAW, Action.FanNeutral,             File.MRGAW_ANIM_ITEMNEUTRAL,            FAN_JAB,                    -1)
    Character.edit_action_parameters(MRGAW, Action.FanTilt,                File.MRGAW_ANIM_ITEMTILT,               FAN_TILT,                   -1)
    Character.edit_action_parameters(MRGAW, Action.FanSmash,               File.MRGAW_ANIM_ITEMSMASH,              FAN_SMASH,                  -1)
    Character.edit_action_parameters(MRGAW, Action.FanDash,                File.MRGAW_ANIM_ITEMDASH,               FAN_DASH,                   -1)
    Character.edit_action_parameters(MRGAW, Action.StarRodNeutral,         File.MRGAW_ANIM_ITEMNEUTRAL,            STARROD_JAB,                -1)
    Character.edit_action_parameters(MRGAW, Action.StarRodTilt,            File.MRGAW_ANIM_ITEMTILT,               STARROD_TILT,               -1)
    Character.edit_action_parameters(MRGAW, Action.StarRodSmash,           File.MRGAW_ANIM_ITEMSMASH,              STARROD_SMASH,              -1)
    Character.edit_action_parameters(MRGAW, Action.StarRodDash,            File.MRGAW_ANIM_ITEMDASH,               STARROD_DASH,               -1)
    Character.edit_action_parameters(MRGAW, Action.RayGunShoot,            File.MRGAW_ANIM_ITEMSHOOT,              -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.RayGunShootAir,         File.MRGAW_ANIM_ITEMSHOOTAIR,          -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.FireFlowerShoot,        File.MRGAW_ANIM_ITEMSHOOT,              -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.FireFlowerShootAir,     File.MRGAW_ANIM_ITEMSHOOTAIR,          -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.HammerIdle,             File.MRGAW_ANIM_HAMMERIDLE,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.HammerWalk,             File.MRGAW_ANIM_HAMMERMOVE,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.HammerTurn,             File.MRGAW_ANIM_HAMMERMOVE,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.HammerJumpSquat,        File.MRGAW_ANIM_HAMMERMOVE,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.HammerAir,              File.MRGAW_ANIM_HAMMERMOVE,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.HammerLanding,          File.MRGAW_ANIM_HAMMERMOVE,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ShieldOn,               File.MRGAW_ANIM_SHIELDON,              SHIELDON,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ShieldOff,              File.MRGAW_ANIM_SHIELDOFF,             SHIELDON,                         -1)
    Character.edit_action_parameters(MRGAW, Action.RollF,                  File.MRGAW_ANIM_ROLLF,                 -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.RollB,                  File.MRGAW_ANIM_ROLLB,                 -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ShieldBreak,            File.MRGAW_ANIM_DAMAGEFLYTOP,           SHIELDBREAK_,                -1)
    Character.edit_action_parameters(MRGAW, Action.ShieldBreakFall,        File.MRGAW_ANIM_TUMBLE,                 MOUTH2,                         -1)
    Character.edit_action_parameters(MRGAW, Action.StunLandD,              File.MRGAW_ANIM_DOWNBOUNCED,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.StunLandU,              File.MRGAW_ANIM_DOWNBOUNCEU,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.StunStartD,             File.MRGAW_ANIM_DOWNSTANDD,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.StunStartU,             File.MRGAW_ANIM_DOWNSTANDU,            -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.Stun,                   File.MRGAW_ANIM_STUN,                   STUN_,                       -1)
    Character.edit_action_parameters(MRGAW, Action.Sleep,                  File.MRGAW_ANIM_STUN,                   SLEEP_,                     -1)
    Character.edit_action_parameters(MRGAW, Action.Grab,                   File.MRGAW_ANIM_GRAB,                   GRAB_,                       -1)
    Character.edit_action_parameters(MRGAW, Action.GrabPull,               File.MRGAW_ANIM_GRABPULL,              -1,                         -1)
    Character.edit_action_parameters(MRGAW, Action.ThrowF,                 File.MRGAW_ANIM_THROWF,                THROW_F_,                    -1)
    Character.edit_action_parameters(MRGAW, Action.ThrowB,                 File.MRGAW_ANIM_THROWB,                THROW_B_,                    -1)
    Character.edit_action_parameters(MRGAW, Action.Tornado,                File.MRGAW_ANIM_TUMBLE,                 -1,                         -1)

    Character.edit_action_parameters(MRGAW, Action.CapturePulled,       File.MRGAW_ANIM_CAPTUREPULLED,         MOUTH2,                         -1)
    Character.edit_action_parameters(MRGAW, Action.InhalePulled,        File.MRGAW_ANIM_TUMBLE,                MOUTH2,                         -1)
    Character.edit_action_parameters(MRGAW, Action.InhaleSpat,          File.MRGAW_ANIM_TUMBLE,                MOUTH2,                         -1)
    Character.edit_action_parameters(MRGAW, Action.InhaleCopied,        File.MRGAW_ANIM_TUMBLE,                MOUTH2,                         -1)
    Character.edit_action_parameters(MRGAW, Action.EggLayPulled,        File.MRGAW_ANIM_CAPTUREPULLED,         MOUTH2,                         -1)
    Character.edit_action_parameters(MRGAW, Action.EggLay,              File.MRGAW_ANIM_IDLE,                  MOUTH2,                         -1)
    Character.edit_action_parameters(MRGAW, Action.FalconDivePulled,    File.MRGAW_ANIM_DAMAGEHI3,             MOUTH2,                         -1)
    Character.edit_action_parameters(MRGAW, 0x0B4,                      File.MRGAW_ANIM_TUMBLE,                MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.ThrownDKPulled,      File.MRGAW_ANIM_THROWNDKPULLED,        MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.ThrownMarioBros,     File.MRGAW_ANIM_THROWNMARIOBROS,       MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.ThrownDK,            File.MRGAW_ANIM_THROWNDK,              MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.Thrown1,             File.MRGAW_ANIM_THROWN1,               MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAW, Action.Thrown2,             File.MRGAW_ANIM_THROWN2,               MOUTH2,                      -1)


    // Modify Action Parameters             // Action                 // Animation                       // Moveset Data              // Flags
    Character.edit_action_parameters(MRGAW,   Action.Taunt,           File.MRGAW_ANIM_TAUNT,             TAUNT,                      0x10000000)
    Character.edit_action_parameters(MRGAW,   Action.Jab1,            File.MRGAW_ANIM_JAB1,              JAB_1,                      0x10000000)
    Character.edit_action_parameters(MRGAW,   Action.Jab2,            File.MRGAW_ANIM_JAB2,              JAB_2,                      -1)
    Character.edit_action_parameters(MRGAW,   Action.DashAttack,      File.MRGAW_ANIM_DASHATTACK,        DASH_ATTACK,                -1)
    Character.edit_action_parameters(MRGAW,   Action.FTiltHigh,       File.MRGAW_ANIM_FTILT,             FORWARD_TILT,               0x10000000)
    Character.edit_action_parameters(MRGAW,   Action.FTilt,           File.MRGAW_ANIM_FTILT,             FORWARD_TILT,               0x10000000)
    Character.edit_action_parameters(MRGAW,   Action.FTiltLow,        File.MRGAW_ANIM_FTILT,             FORWARD_TILT,               0x10000000)
    Character.edit_action_parameters(MRGAW,   Action.UTilt,           File.MRGAW_ANIM_UTILT,             UP_TILT,                    0x50000000)
    Character.edit_action_parameters(MRGAW,   Action.DTilt,           File.MRGAW_ANIM_DTILT,             DOWN_TILT,                  0x50000000)
    Character.edit_action_parameters(MRGAW,   Action.FSmashHigh,      File.MRGAW_ANIM_FSMASH,            FORWARD_SMASH,              -1)
    Character.edit_action_parameters(MRGAW,   Action.FSmashMidHigh,   File.MRGAW_ANIM_FSMASH,            FORWARD_SMASH,              -1)
    Character.edit_action_parameters(MRGAW,   Action.FSmash,          File.MRGAW_ANIM_FSMASH,            FORWARD_SMASH,              -1)
    Character.edit_action_parameters(MRGAW,   Action.FSmashMidLow,    File.MRGAW_ANIM_FSMASH,            FORWARD_SMASH,              -1)
    Character.edit_action_parameters(MRGAW,   Action.FSmashLow,       File.MRGAW_ANIM_FSMASH,            FORWARD_SMASH,              -1)
    Character.edit_action_parameters(MRGAW,   Action.USmash,          File.MRGAW_ANIM_USMASH,            UP_SMASH,                   -1)
    Character.edit_action_parameters(MRGAW,   Action.DSmash,          File.MRGAW_ANIM_DSMASH,            DOWN_SMASH,                 0x10000000)
    Character.edit_action_parameters(MRGAW,   Action.AttackAirN,      File.MRGAW_ANIM_AIRN,              NEUTRAL_AERIAL,             0x10000000)
    Character.edit_action_parameters(MRGAW,   Action.AttackAirF,      File.MRGAW_ANIM_AIRF,              FORWARD_AERIAL,             0x10000000)
    Character.edit_action_parameters(MRGAW,   Action.AttackAirB,      File.MRGAW_ANIM_AIRB,              BACK_AERIAL,                -1)
    Character.edit_action_parameters(MRGAW,   Action.AttackAirU,      File.MRGAW_ANIM_AIRU,              UP_AERIAL,                  0x10000000)
    Character.edit_action_parameters(MRGAW,   Action.AttackAirD,      File.MRGAW_ANIM_AIRD,              DOWN_AERIAL,                0x10000000)
    Character.edit_action_parameters(MRGAW,   0xDC,                   File.MRGAW_ANIM_JAB3,              JAB_3,                      -1)
    Character.edit_action_parameters(MRGAW,   0xDD,                   File.MRGAW_ANIM_ENTRYR,            APPEAR,                     -1)
    Character.edit_action_parameters(MRGAW,   0xDE,                   File.MRGAW_ANIM_ENTRYL,            APPEAR,                     -1)
    Character.edit_action_parameters(MRGAW,   0xDF,                   File.MRGAW_ANIM_NSPGND,            NEUTRAL_SPECIAL,     	     -1)//0x40000000)
    Character.edit_action_parameters(MRGAW,   0xE0,                   File.MRGAW_ANIM_NSPAIR,            NEUTRAL_SPECIAL,     	     -1)
    Character.edit_action_parameters(MRGAW,   0xE1,                   File.MRGAW_ANIM_USP,               UP_SPECIAL,                 0x50000000)
    Character.edit_action_parameters(MRGAW,   0xE2,                   File.MRGAW_ANIM_USP,               UP_SPECIAL,                 0x50000000)
    Character.edit_action_parameters(MRGAW,   0xE3,                   File.MRGAW_ANIM_DSPGND,            DOWN_SPECIAL_1,             0x50000000)
    Character.edit_action_parameters(MRGAW,   0xE4,                   File.MRGAW_ANIM_DSPAIR,            DOWN_SPECIAL_1,             0x50000000)
	
    Character.edit_action_parameters(MRGAW,   0x0D6,                  File.MRGAW_ANIM_LANDN,             NAIRLAND,                     -1)
    Character.edit_action_parameters(MRGAW,   0x0D7,                  File.MRGAW_ANIM_LANDF,             FAIRLAND,                   0x10000000)
    Character.edit_action_parameters(MRGAW,   0x0D8,                  File.MRGAW_ANIM_LANDB,             BAIRLAND,                   -1)
    Character.edit_action_parameters(MRGAW,   0x0D9,                  File.MRGAW_ANIM_LANDU,             UAIRLAND,                   0x10000000)
    Character.edit_action_parameters(MRGAW,   0x0DA,                  File.MRGAW_ANIM_LANDD,             DAIRLAND,                   0x10000000)
	
    // Modify Actions             // Action          			// Staling ID   // Main ASM           			// Interrupt/Other ASM          	// Movement/Physics ASM         // Collision ASM
    Character.edit_action(MRGAW,  0xDF,              			-1,             GameAndWatchNSP.main,  			GameAndWatchNSP.chef_refresh_,          -1,                            -1)
    Character.edit_action(MRGAW,  0xE0,              			-1,             GameAndWatchNSP.main,  			GameAndWatchNSP.chef_refresh_,          -1,                            GameAndWatchNSP.air_collision_)
    Character.edit_action(MRGAW,  Action.Fire,       			-1,             GameAndWatchUSP.main_air_,  		GameAndWatchUSP.change_direction_,      GameAndWatchUSP.physics_,       GameAndWatchUSP.collision_)
    Character.edit_action(MRGAW,  Action.FireAir,    			-1,             GameAndWatchUSP.main_air_,  		GameAndWatchUSP.change_direction_,      GameAndWatchUSP.physics_,       GameAndWatchUSP.collision_)
    Character.edit_action(MRGAW,  Action.JudgeBegin, 			-1,          	GameAndWatchDSP.main,       		-1,					0x800D8BB4,			GameAndWatchDSP.ground_collision_)
    Character.edit_action(MRGAW,  Action.JudgeBeginAir,   	        -1,             GameAndWatchDSP.main,          		-1,					0x800D90E0,			GameAndWatchDSP.air_collision_) 
	
    // Add Action Parameters             // Action Name      // Base Action  // Animation               // Moveset Data        // Flags
    Character.add_new_action_params(MRGAW, DSP_Ground_1,   	 -1,             File.MRGAW_ANIM_DSPGND,   			DOWN_SPECIAL_1,                 0x50000000)
    Character.add_new_action_params(MRGAW, DSP_Air_1,      	 -1,             File.MRGAW_ANIM_DSPAIR,   			DOWN_SPECIAL_1,                 0x50000000)
    Character.add_new_action_params(MRGAW, DSP_Ground_2,   	 -1,             File.MRGAW_ANIM_DSPGND,   			DOWN_SPECIAL_2,                 0x50000000)
    Character.add_new_action_params(MRGAW, DSP_Air_2,      	 -1,             File.MRGAW_ANIM_DSPAIR,   			DOWN_SPECIAL_2,                 0x50000000)
    Character.add_new_action_params(MRGAW, DSP_Ground_3,   	 -1,             File.MRGAW_ANIM_DSPGND,   			DOWN_SPECIAL_3,                 0x50000000)
    Character.add_new_action_params(MRGAW, DSP_Air_3,      	 -1,             File.MRGAW_ANIM_DSPAIR,   			DOWN_SPECIAL_3,                 0x50000000)
    Character.add_new_action_params(MRGAW, DSP_Ground_4,   	 -1,             File.MRGAW_ANIM_DSPGND,   			DOWN_SPECIAL_4,                 0x50000000)
    Character.add_new_action_params(MRGAW, DSP_Air_4,      	 -1,             File.MRGAW_ANIM_DSPAIR,   			DOWN_SPECIAL_4,                 0x50000000)
    Character.add_new_action_params(MRGAW, DSP_Ground_5,   	 0xE3,           File.MRGAW_ANIM_DSPGND,   		    	DOWN_SPECIAL_5,                 0x50000000)
    Character.add_new_action_params(MRGAW, DSP_Air_5,      	 0xE4,           File.MRGAW_ANIM_DSPAIR,   		    	DOWN_SPECIAL_5,                 0x50000000)
    Character.add_new_action_params(MRGAW, DSP_Ground_6,   	 -1,             File.MRGAW_ANIM_DSPGND,   			DOWN_SPECIAL_6,                 0x50000000)
    Character.add_new_action_params(MRGAW, DSP_Air_6,      	 -1,             File.MRGAW_ANIM_DSPAIR,   			DOWN_SPECIAL_6,                 0x50000000)
    Character.add_new_action_params(MRGAW, DSP_Ground_7,   	 -1,             File.MRGAW_ANIM_DSPGND,   			DOWN_SPECIAL_7,                 0x50000000)
    Character.add_new_action_params(MRGAW, DSP_Air_7,      	 -1,             File.MRGAW_ANIM_DSPAIR,   			DOWN_SPECIAL_7,                 0x50000000)
    Character.add_new_action_params(MRGAW, DSP_Ground_8,   	 -1,             File.MRGAW_ANIM_DSPGND,   			DOWN_SPECIAL_8,                 0x50000000)
    Character.add_new_action_params(MRGAW, DSP_Air_8,      	 -1,             File.MRGAW_ANIM_DSPAIR,   			DOWN_SPECIAL_8,                 0x50000000)
    Character.add_new_action_params(MRGAW, DSP_Ground_9,   	 -1,             File.MRGAW_ANIM_DSPGND,   			DOWN_SPECIAL_9,                 0x50000000)
    Character.add_new_action_params(MRGAW, DSP_Air_9,      	 -1,             File.MRGAW_ANIM_DSPAIR,   			DOWN_SPECIAL_9,                 0x50000000)
	
    // Add Actions                // Action Name    // Base Action     //Parameters  // Staling ID   // Main ASM  // Interrupt/Other ASM      // Movement/Physics ASM    // Collision ASM	
    Character.add_new_action(MRGAW, DSP_Ground_1,   -1,     ActionParams.DSP_Ground_1,  0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4,                      GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAW, DSP_Air_1,      -1,     ActionParams.DSP_Air_1,  	0x1E,    GameAndWatchDSP.attacks_main_,    -1,    GameAndWatchDSP.air_physics_,    GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAW, DSP_Ground_2,   -1,     ActionParams.DSP_Ground_2,  0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4,                      GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAW, DSP_Air_2, 	    -1,     ActionParams.DSP_Air_2, 	0x1E,    GameAndWatchDSP.attacks_main_,    -1,    GameAndWatchDSP.air_physics_,    GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAW, DSP_Ground_3,   -1,     ActionParams.DSP_Ground_3, 	0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4, 	                   GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAW, DSP_Air_3, 	    -1,     ActionParams.DSP_Air_3, 	0x1E,    GameAndWatchDSP.attacks_main_,    -1,    GameAndWatchDSP.air_physics_,    GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAW, DSP_Ground_4,   -1,     ActionParams.DSP_Ground_4,  0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4,                      GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAW, DSP_Air_4,      -1,     ActionParams.DSP_Air_4,     0x1E,    GameAndWatchDSP.attacks_main_,    -1,    GameAndWatchDSP.air_physics_,    GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAW, DSP_Ground_5,   -1,     ActionParams.DSP_Ground_5,  0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4,                      GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAW, DSP_Air_5,      -1,     ActionParams.DSP_Air_5,   	0x1E,    GameAndWatchDSP.attacks_main_,    -1,    GameAndWatchDSP.air_physics_,    GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAW, DSP_Ground_6,   -1,     ActionParams.DSP_Ground_6,  0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4,                      GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAW, DSP_Air_6,      -1,     ActionParams.DSP_Air_6,  	0x1E,    GameAndWatchDSP.attacks_main_,    -1,    GameAndWatchDSP.air_physics_,    GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAW, DSP_Ground_7,   -1,     ActionParams.DSP_Ground_7, 	0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4, 	                   GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAW, DSP_Air_7, 	    -1,     ActionParams.DSP_Air_7, 	0x1E,    GameAndWatchDSP.attacks_main_,    -1,    GameAndWatchDSP.air_physics_,    GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAW, DSP_Ground_8,   -1,     ActionParams.DSP_Ground_8, 	0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4, 	                   GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAW, DSP_Air_8,      -1,     ActionParams.DSP_Air_8,    	0x1E,    GameAndWatchDSP.attacks_main_,    -1,    GameAndWatchDSP.air_physics_,    GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAW, DSP_Ground_9,   -1,     ActionParams.DSP_Ground_9,  0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4,                      GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAW, DSP_Air_9,      -1,     ActionParams.DSP_Air_9,     0x1E,    GameAndWatchDSP.attacks_main_,    -1,    GameAndWatchDSP.air_physics_,    GameAndWatchDSP.air_collision_)
																																			
    //GameAndWatchDSP.air_physics_ for all aerial versions (used to be 0x800D90E0)
    // Modify Action Parameters               // Action             // Animation                // Moveset Data             // Flags
	Character.edit_action_parameters(MRGAW,   0xE3,                 File.MRGAW_ANIM_DSPGND,              DOWN_SPECIAL_1,                    	-1)
	Character.edit_action_parameters(MRGAW,   0xE4,                 File.MRGAW_ANIM_DSPAIRBEGIN,              DOWN_SPECIAL_1,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xE5,                 File.MRGAW_ANIM_DSPA,              DSP_1,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xE6,                 File.MRGAW_ANIM_DSPA,              DSP_1,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xE7,                 File.MRGAW_ANIM_DSPA,              DSP_2,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xE8,                 File.MRGAW_ANIM_DSPA,              DSP_2,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xE9,                 File.MRGAW_ANIM_DSPA,              DSP_3,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xEA,                 File.MRGAW_ANIM_DSPA,              DSP_3,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xEB,                 File.MRGAW_ANIM_DSPA,              DSP_4,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xEC,                 File.MRGAW_ANIM_DSPA,              DSP_4,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xED,                 File.MRGAW_ANIM_DSPA,              DSP_5,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xEE,                 File.MRGAW_ANIM_DSPA,              DSP_5,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xEF,                 File.MRGAW_ANIM_DSPA,              DSP_6,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xF0,                 File.MRGAW_ANIM_DSPA,              DSP_6,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xF1,                 File.MRGAW_ANIM_DSPA,              DSP_7,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xF2,                 File.MRGAW_ANIM_DSPA,              DSP_7,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xF3,                 File.MRGAW_ANIM_DSPA,              DSP_8,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xF4,                 File.MRGAW_ANIM_DSPA,              DSP_8,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xF5,                 File.MRGAW_ANIM_DSPA,              DSP_9,                    	0x10000000)
	//Character.edit_action_parameters(MRGAW,   0xF6,                 File.MRGAW_ANIM_DSPA,              DSP_9,                    	0x10000000)

    Character.edit_menu_action_parameters(MRGAW, 0x0,             File.MRGAW_ANIM_IDLE,           -1,                                       -1)     // CSS IDLE
    Character.edit_menu_action_parameters(MRGAW, 0x1,             File.MRGAW_ANIM_VICTORY3,        VICTORY_3,                       0x10000000)     // VICTORY 3 and CSS animation
    Character.edit_menu_action_parameters(MRGAW, 0x2,             File.MRGAW_ANIM_VICTORY2,        VICTORY_2,                               -1)     // VICTORY 2
    Character.edit_menu_action_parameters(MRGAW, 0x3,             File.MRGAW_ANIM_VICTORY1,        VICTORY_1,                       0x10000000)     // VICTORY 1

    Character.edit_menu_action_parameters(MRGAW, 0x5,             File.MRGAW_ANIM_CLAP,            CLAP,                                    -1)     // NO CONTEST
    // Character.edit_menu_action_parameters(MRGAW, 0x9,          File.MRGAW_ANIM_CONTINUE_FALL,     -1,                                    -1)
    // Character.edit_menu_action_parameters(MRGAW, 0xA,          File.MRGAW_ANIM_CONTINUE_UP,       -1,                                    -1)
    Character.edit_menu_action_parameters(MRGAW, 0xD,             File.MRGAW_ANIM_1PPOSE,        	 POSE1P,                                -1)     // 1P SCREEN POSE
    Character.edit_menu_action_parameters(MRGAW, 0xE,             File.MRGAW_ANIM_1PPOSE,        	 POSE1P,                                -1)     // 1P SCREEN POSE

    // Modify Menu Action Parameters                // Action           // Animation                // Moveset Data             // Flags
    //Character.edit_menu_action_parameters(MRGAW,      0xE,                File.DRM_1P_CPU_POSE,       0x80000000,                 -1)

    scope DPad {
        if {defined Character.CHARACTER_ADDED_MRGAWPLUS} {
            constant LEFT(Character.id.MRGAWPLUS)
        } else {
            constant LEFT(Character.id.NONE)
        }

        if {defined Character.CHARACTER_ADDED_MRGAWTHREED} {
            constant UP(Character.id.MRGAWTHREED)
        } else {
            constant UP(Character.id.NONE)
        }

        constant RIGHT(Character.id.NONE)

        constant DOWN(Character.id.NONE)
    }

    Character.table_patch_start(variants, Character.id.MRGAW, 0x4)
    db      DPad.UP    // set as SPECIAL variant for GAW PLUS
    db      DPad.DOWN  // set as POLYGON variant for MRGAW
    db      DPad.LEFT
    db      DPad.RIGHT // set as SPECIAL variant for GAW 3D
    OS.patch_end()

    // Set subroutines for special move initiations.
    Character.table_patch_start(ground_dsp, Character.id.MRGAW, 0x4)
    dw      GameAndWatchDSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.MRGAW, 0x4)
    dw      GameAndWatchDSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(ground_usp, Character.id.MRGAW, 0x4)
    dw      GameAndWatchUSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.MRGAW, 0x4)
    dw      GameAndWatchUSP.air_initial_
    OS.patch_end()
	
	// Remove entry script (no more warp pipe).
    Character.table_patch_start(entry_script, Character.id.MRGAW, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.MRGAW, 0x2)
    dh  FGM.CHANT
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.MRGAW, 0xC)
    dh 0x08
    OS.patch_end()

	// Set default costumes(id, costume_1, costume_2, costume_3, costume_4, red_team, blue_team, green_team)
    Character.set_default_costumes(Character.id.MRGAW, 0, 3, 2, 1, 3, 2, 1)
    Teams.add_team_costume(YELLOW, MRGAW, 0x6)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(MRGAW, BLACK, GREEN, BLUE, RED, CYAN, WHITE, YELLOW, PURPLE, MAGENTA, ORANGE, RED, YELLOW)

    // Set action strings
    Character.table_patch_start(action_string, Character.id.MRGAW, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // Insert AI attack options
    include "AI.asm"

    scope CloakingFix: {
        scope fix_: {
            // s8 = player struct
            // v0 = first custom part struct (fish_bowl)
            addiu   sp, sp, -0x0010             // allocate stack space
            sw      t1, 0x0004(sp)              // save return address

            _check_gnw_fish_bowl:
            //li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_fish_bowl
            li      t1, _check_gnw_flag        // t1 = return address
            lbu     t2, 0x0995(s8)              // t2 = g&w arm part_id
            lli     t9, 0x0003                  // t9 = special part of fish_bowl
            beql    t2, t9, _fix                // if fish_bowl, fix
            nop

            _check_gnw_flag:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_flag
            li      t1, _check_gnw_blaster_one  // t1 = return address
            lbu     t2, 0x0997(s8)              // t2 = g&w arm part_id
            lli     t9, 0x0001                  // t9 = special part of flag
            beql    t2, t9, _fix                // if flag, fix
            nop

            _check_gnw_blaster_one:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_blaster_one
            li      t1, _check_gnw_blaster_two  // t1 = return address
            lbu     t2, 0x0997(s8)              // t2 = g&w arm part_id
            lli     t9, 0x0002                  // t9 = special part of blaster_one
            beql    t2, t9, _fix                // if blaster_one, fix
            nop

            _check_gnw_blaster_two:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_blaster_two
            li      t1, _check_gnw_torch        // t1 = return address
            lbu     t2, 0x0997(s8)              // t2 = g&w arm part_id
            lli     t9, 0x0003                  // t9 = special part of blaster_two
            beql    t2, t9, _fix                // if blaster_two, fix
            nop

            _check_gnw_torch:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_torch
            li      t1, _check_gnw_turtle        // t1 = return address
            lbu     t2, 0x0997(s8)              // t2 = g&w item part_id
            lli     t9, 0x0004                  // t9 = special part of torch
            beql    t2, t9, _fix                // if torch, fix
            nop

            _check_gnw_turtle:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_turtle
            li      t1, _check_gnw_fish_one        // t1 = return address
            lbu     t2, 0x0997(s8)              // t2 = g&w item part_id
            lli     t9, 0x0005                  // t9 = special part of turtle
            beql    t2, t9, _fix                // if turtle, fix
            nop

            _check_gnw_fish_one:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_fish_one
            li      t1, _check_gnw_bell        // t1 = return address
            lbu     t2, 0x0997(s8)              // t2 = g&w item part_id
            lli     t9, 0x0006                  // t9 = special part of fish_one
            beql    t2, t9, _fix                // if fish_one, fix
            nop

            _check_gnw_bell:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_bell
            li      t1, _check_gnw_key        // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0001                  // t9 = special part of bell
            beql    t2, t9, _fix                // if bell, fix
            nop

            _check_gnw_key:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_key
            li      t1, _check_gnw_wind        // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0003                  // t9 = special part of key
            beql    t2, t9, _fix                // if key, fix
            nop

            _check_gnw_wind:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_wind
            li      t1, _check_gnw_chair        // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0005                  // t9 = special part of wind
            beql    t2, t9, _fix                // if wind, fix
            nop

            _check_gnw_chair:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_chair
            li      t1, _check_gnw_parachute    // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0006                  // t9 = special part of chair
            beql    t2, t9, _fix                // if chair, fix
            nop

            _check_gnw_parachute:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_parachute
            li      t1, _check_gnw_card_one        // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0009                  // t9 = special part of parachute
            beql    t2, t9, _fix                // if parachute, fix
            nop

            _check_gnw_card_one:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_card_one
            li      t1, _check_gnw_card_two        // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x000A                  // t9 = special part of card_one
            beql    t2, t9, _fix                // if card_one, fix
            nop

            _check_gnw_card_two:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_card_two
            li      t1, _check_gnw_card_three        // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x000B                  // t9 = special part of card_two
            beql    t2, t9, _fix                // if card_two, fix
            nop

            _check_gnw_card_three:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_card_three
            li      t1, _check_gnw_card_four   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x000C                  // t9 = special part of card_three
            beql    t2, t9, _fix                // if card_three, fix
            nop

            _check_gnw_card_four:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_card_four
            li      t1, _check_gnw_card_five   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x000D                  // t9 = special part of card_four
            beql    t2, t9, _fix                // if card_four, fix
            nop

            _check_gnw_card_five:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_card_five
            li      t1, _check_gnw_card_six   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x000E                  // t9 = special part of card_five
            beql    t2, t9, _fix                // if card_five, fix
            nop

            _check_gnw_card_six:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_card_six
            li      t1, _check_gnw_card_seven   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x000F                  // t9 = special part of card_six
            beql    t2, t9, _fix                // if card_six, fix
            nop

            _check_gnw_card_seven:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_card_seven
            li      t1, _check_gnw_card_eight   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0010                  // t9 = special part of card_seven
            beql    t2, t9, _fix                // if card_seven, fix
            nop

            _check_gnw_card_eight:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_card_eight
            li      t1, _check_gnw_card_nine   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0011                  // t9 = special part of card_eight
            beql    t2, t9, _fix                // if card_eight, fix
            nop

            _check_gnw_card_nine:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_card_nine
            li      t1, _check_gnw_fire_one   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0012                  // t9 = special part of card_nine
            beql    t2, t9, _fix                // if card_nine, fix
            nop

            _check_gnw_fire_one:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_fire_one
            li      t1, _check_gnw_fire_two   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0013                  // t9 = special part of fire_one
            beql    t2, t9, _fix                // if fire_one, fix
            nop

            _check_gnw_fire_two:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_fire_two
            li      t1, _check_gnw_fish_two   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0014                  // t9 = special part of fire_two
            beql    t2, t9, _fix                // if fire_two, fix
            nop

            _check_gnw_fish_two:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgaw_fish_two
            lw      t1, 0x0004(sp)              // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0015                  // t9 = special part of fish_two
            beql    t2, t9, _fix                // if fish_two, fix
            addiu   sp, sp, 0x0010              // allocate stack space

            j       CharEnvColor.override_env_color_._return
            addiu   sp, sp, 0x0010              // allocate stack space

            _fix:
            j       CharEnvColor.override_env_color_._fix
            nop                                 // after fix, jr's to t1
        }
    }

}

