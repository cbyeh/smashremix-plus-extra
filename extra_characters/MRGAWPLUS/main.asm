// GameAndWatchPLUS2D.asm

// This file contains file inclusions, action edits, and assembly for Mr. Game and Watch Plus.
scope GameAndWatchPLUS2D {

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
        constant ParachuteFloat(0x0F7)

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
        string_0x0F7:; String.insert("ParachuteFloat")

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
	dw string_0x0F7
    }

    OS.align(16)

    // Modify Action Parameters              // Action                      // Animation                  // Moveset Data           // Flags
    Character.edit_action_parameters(MRGAWPLUS, Action.DeadU,                  File.MRGAWPLUS_ANIM_TUMBLE,                 -1,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ScreenKO,               File.MRGAWPLUS_ANIM_TUMBLE,                 -1,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Revive1,                File.MRGAWPLUS_ANIM_DOWNBOUNCED,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Revive2,                File.MRGAWPLUS_ANIM_DOWNSTANDD,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ReviveWait,             File.MRGAWPLUS_ANIM_IDLE,                   -1,                       -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Idle,                   File.MRGAWPLUS_ANIM_IDLE,                   IDLE,                       -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Walk1,                  File.MRGAWPLUS_ANIM_WALK1,                 WALK1_,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Walk2,                  File.MRGAWPLUS_ANIM_WALK2,                 WALK2_,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Walk3,                  File.MRGAWPLUS_ANIM_WALK3,                 WALK3_,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, 0x00E,                         File.MRGAWPLUS_ANIM_WALKEND,               SLOPES,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Dash,                   File.MRGAWPLUS_ANIM_DASH,                   DASH,                       -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Run,                    File.MRGAWPLUS_ANIM_RUN,                    RUN_,                        -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.RunBrake,               File.MRGAWPLUS_ANIM_RUNBRAKE,              SLOPES,                  -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Turn,                   File.MRGAWPLUS_ANIM_TURN,                   TURN,                       -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.TurnRun,                File.MRGAWPLUS_ANIM_TURNRUN,               -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.JumpSquat,              File.MRGAWPLUS_ANIM_LANDING,                -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ShieldJumpSquat,        File.MRGAWPLUS_ANIM_LANDING,                -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.JumpF,                  File.MRGAWPLUS_ANIM_JUMPF,                 JUMP,                     -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.JumpB,                  File.MRGAWPLUS_ANIM_JUMPB,                 JUMP,                     -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.JumpAerialF,            File.MRGAWPLUS_ANIM_JUMPAERIALF,          DOUBLEJUMP,                     -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.JumpAerialB,            File.MRGAWPLUS_ANIM_JUMPAERIALB,          DOUBLEJUMP,                     -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Fall,                   File.MRGAWPLUS_ANIM_FALL,                   -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.FallAerial,             File.MRGAWPLUS_ANIM_FALLAERIAL,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Crouch,                 File.MRGAWPLUS_ANIM_CROUCH,                 SLOPES,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.CrouchIdle,             File.MRGAWPLUS_ANIM_CROUCHIDLE,            SLOPES,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.CrouchEnd,              File.MRGAWPLUS_ANIM_CROUCHEND,             SLOPES,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.LandingLight,           File.MRGAWPLUS_ANIM_LANDING,                SLOPES,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.LandingHeavy,           File.MRGAWPLUS_ANIM_LANDING,                SLOPES,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Pass,                   File.MRGAWPLUS_ANIM_PLATFORMDROP,              -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ShieldDrop,             File.MRGAWPLUS_ANIM_PLATFORMDROP,              -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Teeter,                 File.MRGAWPLUS_ANIM_TEETER,                 SLOPES,                     -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.TeeterStart,            File.MRGAWPLUS_ANIM_TEETERSTART,            SLOPES,                     -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageHigh1,            File.MRGAWPLUS_ANIM_DAMAGEHI1,             MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageHigh2,            File.MRGAWPLUS_ANIM_DAMAGEHI2,             MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageHigh3,            File.MRGAWPLUS_ANIM_DAMAGEHI3,             MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageMid1,             File.MRGAWPLUS_ANIM_DAMAGEMID1,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageMid2,             File.MRGAWPLUS_ANIM_DAMAGEMID2,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageMid3,             File.MRGAWPLUS_ANIM_DAMAGEMID3,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageLow1,             File.MRGAWPLUS_ANIM_DAMAGELOW1,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageLow2,             File.MRGAWPLUS_ANIM_DAMAGELOW2,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageLow3,             File.MRGAWPLUS_ANIM_DAMAGELOW3,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageAir1,             File.MRGAWPLUS_ANIM_DAMAGEAIR1,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageAir2,             File.MRGAWPLUS_ANIM_DAMAGEAIR2,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageAir3,             File.MRGAWPLUS_ANIM_DAMAGEAIR3,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageElec1,            File.MRGAWPLUS_ANIM_DAMAGEELEC,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageElec2,            File.MRGAWPLUS_ANIM_DAMAGEELEC,            MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageFlyHigh,          File.MRGAWPLUS_ANIM_DAMAGEFLYHI,           MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageFlyMid,           File.MRGAWPLUS_ANIM_DAMAGEFLYMID,          MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageFlyLow,           File.MRGAWPLUS_ANIM_DAMAGEFLYLOW,          MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageFlyTop,           File.MRGAWPLUS_ANIM_DAMAGEFLYTOP,          MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DamageFlyRoll,          File.MRGAWPLUS_ANIM_DAMAGEFLYROLL,         MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.WallBounce,             File.MRGAWPLUS_ANIM_TUMBLE,                MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Tumble,                 File.MRGAWPLUS_ANIM_TUMBLE,                MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.FallSpecial,            File.MRGAWPLUS_ANIM_FALLSPECIAL,           MOUTH,                       -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.LandingSpecial,         File.MRGAWPLUS_ANIM_LANDING,                SLOPES,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.EnterPipe,              File.MRGAWPLUS_ANIM_ENTERPIPE,             -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ExitPipe,               File.MRGAWPLUS_ANIM_EXITPIPE,              -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ExitPipeWalk,           File.MRGAWPLUS_ANIM_EXITPIPEWALK,         -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.CeilingBonk,            File.MRGAWPLUS_ANIM_CEILINGBONK,           -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DownBounceD,            File.MRGAWPLUS_ANIM_DOWNBOUNCED,            -1,                -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DownBounceU,            File.MRGAWPLUS_ANIM_DOWNBOUNCEU,            -1,                -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DownStandD,             File.MRGAWPLUS_ANIM_DOWNSTANDD,            -1,                 -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DownStandU,             File.MRGAWPLUS_ANIM_DOWNSTANDU,            -1,                 -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.TechF,                  File.MRGAWPLUS_ANIM_TECHF,                 TECHFB,                  -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.TechB,                  File.MRGAWPLUS_ANIM_TECHB,                 TECHFB,                  -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DownForwardD,           File.MRGAWPLUS_ANIM_DOWNFORWARDD,            -1,                  -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DownForwardU,           File.MRGAWPLUS_ANIM_DOWNFORWARDU,            -1,                  -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DownBackD,              File.MRGAWPLUS_ANIM_DOWNBACKD,              -1,                  -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DownBackU,              File.MRGAWPLUS_ANIM_DOWNBACKU,              -1,                  -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DownAttackD,            File.MRGAWPLUS_ANIM_DOWNATTACKD,             DOWN_ATTACK,              -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.DownAttackU,            File.MRGAWPLUS_ANIM_DOWNATTACKU,             DOWN_ATTACK,              -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Tech,                   File.MRGAWPLUS_ANIM_TECH,                   TECH,                       -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ClangRecoil,            File.MRGAWPLUS_ANIM_CLANGRECOIL,           SLOPES,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.CliffCatch,             File.MRGAWPLUS_ANIM_CLIFFCATCH,              -1,                -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.CliffWait,              File.MRGAWPLUS_ANIM_CLIFFWAIT,               -1,                 -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.CliffQuick,             File.MRGAWPLUS_ANIM_CLIFFQUICK,              -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.CliffClimbQuick1,       File.MRGAWPLUS_ANIM_CLIFFCLIMBQUICK1,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.CliffClimbQuick2,       File.MRGAWPLUS_ANIM_CLIFFCLIMBQUICK2,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.CliffSlow,              File.MRGAWPLUS_ANIM_CLIFFSLOW,               -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.CliffClimbSlow1,        File.MRGAWPLUS_ANIM_CLIFFCLIMBSLOW1,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.CliffClimbSlow2,        File.MRGAWPLUS_ANIM_CLIFFCLIMBSLOW2,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.CliffAttackQuick1,      File.MRGAWPLUS_ANIM_CLIFFATTACKQUICK1,            -1,                        0x50000000)
    Character.edit_action_parameters(MRGAWPLUS, Action.CliffAttackQuick2,      File.MRGAWPLUS_ANIM_CLIFFATTACKQUICK2,            CLIFF_ATK_QUICK_2,         0x50000000)
    Character.edit_action_parameters(MRGAWPLUS, Action.CliffAttackSlow1,       File.MRGAWPLUS_ANIM_CLIFFATTACKSLOW1,            -1,                         0x50000000)
    Character.edit_action_parameters(MRGAWPLUS, Action.CliffAttackSlow2,       File.MRGAWPLUS_ANIM_CLIFFATTACKSLOW2,            CLIFF_ATK_SLOW_2,           0x50000000)
    Character.edit_action_parameters(MRGAWPLUS, Action.CliffEscapeQuick1,      File.MRGAWPLUS_ANIM_CLIFFESCAPEQUICK1,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.CliffEscapeQuick2,      File.MRGAWPLUS_ANIM_CLIFFESCAPEQUICK2,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.CliffEscapeSlow1,       File.MRGAWPLUS_ANIM_CLIFFESCAPESLOW1,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.CliffEscapeSlow2,       File.MRGAWPLUS_ANIM_CLIFFESCAPESLOW2,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.LightItemPickup,        File.MRGAWPLUS_ANIM_ITEMPICKUPLIGHT,           -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.HeavyItemPickup,        File.MRGAWPLUS_ANIM_ITEMPICKUPHEAVY,           -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemDrop,               File.MRGAWPLUS_ANIM_ITEMDROP,               -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemThrowDash,          File.MRGAWPLUS_ANIM_ITEMTHROWDASH,         -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemThrowF,             File.MRGAWPLUS_ANIM_ITEMTHROWF,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemThrowB,             File.MRGAWPLUS_ANIM_ITEMTHROWF,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemThrowU,             File.MRGAWPLUS_ANIM_ITEMTHROWU,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemThrowD,             File.MRGAWPLUS_ANIM_ITEMTHROWD,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemThrowSmashF,        File.MRGAWPLUS_ANIM_ITEMTHROWF,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemThrowSmashB,        File.MRGAWPLUS_ANIM_ITEMTHROWF,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemThrowSmashU,        File.MRGAWPLUS_ANIM_ITEMTHROWU,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemThrowSmashD,        File.MRGAWPLUS_ANIM_ITEMTHROWD,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemThrowAirF,          File.MRGAWPLUS_ANIM_ITEMTHROWAIRF,        -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemThrowAirB,          File.MRGAWPLUS_ANIM_ITEMTHROWAIRF,        -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemThrowAirU,          File.MRGAWPLUS_ANIM_ITEMTHROWAIRU,        -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemThrowAirD,          File.MRGAWPLUS_ANIM_ITEMTHROWAIRD,        -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemThrowAirSmashF,     File.MRGAWPLUS_ANIM_ITEMTHROWAIRF,        -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemThrowAirSmashB,     File.MRGAWPLUS_ANIM_ITEMTHROWAIRF,        -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemThrowAirSmashU,     File.MRGAWPLUS_ANIM_ITEMTHROWAIRU,        -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ItemThrowAirSmashD,     File.MRGAWPLUS_ANIM_ITEMTHROWAIRD,        -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.HeavyItemThrowF,        File.MRGAWPLUS_ANIM_HEAVYITEMTHROW,        -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.HeavyItemThrowB,        File.MRGAWPLUS_ANIM_HEAVYITEMTHROW,        -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.HeavyItemThrowSmashF,   File.MRGAWPLUS_ANIM_HEAVYITEMTHROW,        -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.HeavyItemThrowSmashB,   File.MRGAWPLUS_ANIM_HEAVYITEMTHROW,        -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.BeamSwordNeutral,       File.MRGAWPLUS_ANIM_ITEMNEUTRAL,            BEAMSWORD_JAB,              -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.BeamSwordTilt,          File.MRGAWPLUS_ANIM_ITEMTILT,               BEAMSWORD_TILT,             -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.BeamSwordSmash,         File.MRGAWPLUS_ANIM_ITEMSMASH,              BEAMSWORD_SMASH,            -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.BeamSwordDash,          File.MRGAWPLUS_ANIM_ITEMDASH,               BEAMSWORD_DASH,             -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.BatNeutral,             File.MRGAWPLUS_ANIM_ITEMNEUTRAL,            BAT_JAB,                    -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.BatTilt,                File.MRGAWPLUS_ANIM_ITEMTILT,               BAT_TILT,                   -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.BatSmash,               File.MRGAWPLUS_ANIM_ITEMSMASH,              BAT_SMASH,                  -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.BatDash,                File.MRGAWPLUS_ANIM_ITEMDASH,               BAT_DASH,                   -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.FanNeutral,             File.MRGAWPLUS_ANIM_ITEMNEUTRAL,            FAN_JAB,                    -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.FanTilt,                File.MRGAWPLUS_ANIM_ITEMTILT,               FAN_TILT,                   -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.FanSmash,               File.MRGAWPLUS_ANIM_ITEMSMASH,              FAN_SMASH,                  -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.FanDash,                File.MRGAWPLUS_ANIM_ITEMDASH,               FAN_DASH,                   -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.StarRodNeutral,         File.MRGAWPLUS_ANIM_ITEMNEUTRAL,            STARROD_JAB,                -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.StarRodTilt,            File.MRGAWPLUS_ANIM_ITEMTILT,               STARROD_TILT,               -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.StarRodSmash,           File.MRGAWPLUS_ANIM_ITEMSMASH,              STARROD_SMASH,              -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.StarRodDash,            File.MRGAWPLUS_ANIM_ITEMDASH,               STARROD_DASH,               -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.RayGunShoot,            File.MRGAWPLUS_ANIM_ITEMSHOOT,              -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.RayGunShootAir,         File.MRGAWPLUS_ANIM_ITEMSHOOTAIR,          -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.FireFlowerShoot,        File.MRGAWPLUS_ANIM_ITEMSHOOT,              -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.FireFlowerShootAir,     File.MRGAWPLUS_ANIM_ITEMSHOOTAIR,          -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.HammerIdle,             File.MRGAWPLUS_ANIM_HAMMERIDLE,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.HammerWalk,             File.MRGAWPLUS_ANIM_HAMMERMOVE,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.HammerTurn,             File.MRGAWPLUS_ANIM_HAMMERMOVE,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.HammerJumpSquat,        File.MRGAWPLUS_ANIM_HAMMERMOVE,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.HammerAir,              File.MRGAWPLUS_ANIM_HAMMERMOVE,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.HammerLanding,          File.MRGAWPLUS_ANIM_HAMMERMOVE,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ShieldOn,               File.MRGAWPLUS_ANIM_SHIELDON,              SHIELDON,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ShieldOff,              File.MRGAWPLUS_ANIM_SHIELDOFF,             SHIELDON,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.RollF,                  File.MRGAWPLUS_ANIM_ROLLF,                 -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.RollB,                  File.MRGAWPLUS_ANIM_ROLLB,                 -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ShieldBreak,            File.MRGAWPLUS_ANIM_DAMAGEFLYTOP,           SHIELDBREAK_,                -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ShieldBreakFall,        File.MRGAWPLUS_ANIM_TUMBLE,                 MOUTH2,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.StunLandD,              File.MRGAWPLUS_ANIM_DOWNBOUNCED,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.StunLandU,              File.MRGAWPLUS_ANIM_DOWNBOUNCEU,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.StunStartD,             File.MRGAWPLUS_ANIM_DOWNSTANDD,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.StunStartU,             File.MRGAWPLUS_ANIM_DOWNSTANDU,            -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Stun,                   File.MRGAWPLUS_ANIM_STUN,                   STUN_,                       -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Sleep,                  File.MRGAWPLUS_ANIM_STUN,                   SLEEP_,                     -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Grab,                   File.MRGAWPLUS_ANIM_GRAB,                   GRAB_,                       -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.GrabPull,               File.MRGAWPLUS_ANIM_GRABPULL,              -1,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ThrowF,                 File.MRGAWPLUS_ANIM_THROWF,                THROW_F_,                    -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ThrowB,                 File.MRGAWPLUS_ANIM_THROWB,                THROW_B_,                    -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Tornado,                File.MRGAWPLUS_ANIM_TUMBLE,                 -1,                         -1)

    Character.edit_action_parameters(MRGAWPLUS, Action.CapturePulled,       File.MRGAWPLUS_ANIM_CAPTUREPULLED,         MOUTH2,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.InhalePulled,        File.MRGAWPLUS_ANIM_TUMBLE,                MOUTH2,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.InhaleSpat,          File.MRGAWPLUS_ANIM_TUMBLE,                MOUTH2,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.InhaleCopied,        File.MRGAWPLUS_ANIM_TUMBLE,                MOUTH2,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.EggLayPulled,        File.MRGAWPLUS_ANIM_CAPTUREPULLED,         MOUTH2,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.EggLay,              File.MRGAWPLUS_ANIM_IDLE,                  MOUTH2,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.FalconDivePulled,    File.MRGAWPLUS_ANIM_DAMAGEHI3,             MOUTH2,                         -1)
    Character.edit_action_parameters(MRGAWPLUS, 0x0B4,                      File.MRGAWPLUS_ANIM_TUMBLE,                MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ThrownDKPulled,      File.MRGAWPLUS_ANIM_THROWNDKPULLED,        MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ThrownMarioBros,     File.MRGAWPLUS_ANIM_THROWNMARIOBROS,       MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.ThrownDK,            File.MRGAWPLUS_ANIM_THROWNDK,              MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Thrown1,             File.MRGAWPLUS_ANIM_THROWN1,               MOUTH2,                      -1)
    Character.edit_action_parameters(MRGAWPLUS, Action.Thrown2,             File.MRGAWPLUS_ANIM_THROWN2,               MOUTH2,                      -1)


    // Modify Action Parameters             // Action                 // Animation                       // Moveset Data              // Flags
    Character.edit_action_parameters(MRGAWPLUS,   Action.Taunt,           File.MRGAWPLUS_ANIM_TAUNT,             TAUNT,                       0x10000000)
    Character.edit_action_parameters(MRGAWPLUS,   Action.Jab1,            File.MRGAWPLUS_ANIM_JAB1,              JAB_1,                       0x10000000)
    Character.edit_action_parameters(MRGAWPLUS,   Action.Jab2,            File.MRGAWPLUS_ANIM_JAB2,              JAB_2,                       -1)
    Character.edit_action_parameters(MRGAWPLUS,   Action.DashAttack,      File.MRGAWPLUS_ANIM_DASHATTACK,        DASH_ATTACK,                 -1)
    Character.edit_action_parameters(MRGAWPLUS,   Action.FTiltHigh,       File.MRGAWPLUS_ANIM_FTILT,             FORWARD_TILT,                0x10000000)
    Character.edit_action_parameters(MRGAWPLUS,   Action.FTilt,           File.MRGAWPLUS_ANIM_FTILT,             FORWARD_TILT,                0x10000000)
    Character.edit_action_parameters(MRGAWPLUS,   Action.FTiltLow,        File.MRGAWPLUS_ANIM_FTILT,             FORWARD_TILT,                0x10000000)
    Character.edit_action_parameters(MRGAWPLUS,   Action.UTilt,           File.MRGAWPLUS_ANIM_UTILT,             UP_TILT,                     0x50000000)
    Character.edit_action_parameters(MRGAWPLUS,   Action.DTilt,           File.MRGAWPLUS_ANIM_DTILT,             DOWN_TILT,                   0x50000000)
    Character.edit_action_parameters(MRGAWPLUS,   Action.FSmashHigh,      File.MRGAWPLUS_ANIM_FSMASH,            FORWARD_SMASH,               -1)
    Character.edit_action_parameters(MRGAWPLUS,   Action.FSmashMidHigh,   File.MRGAWPLUS_ANIM_FSMASH,            FORWARD_SMASH,               -1)
    Character.edit_action_parameters(MRGAWPLUS,   Action.FSmash,          File.MRGAWPLUS_ANIM_FSMASH,            FORWARD_SMASH,               -1)
    Character.edit_action_parameters(MRGAWPLUS,   Action.FSmashMidLow,    File.MRGAWPLUS_ANIM_FSMASH,            FORWARD_SMASH,               -1)
    Character.edit_action_parameters(MRGAWPLUS,   Action.FSmashLow,       File.MRGAWPLUS_ANIM_FSMASH,            FORWARD_SMASH,               -1)
    Character.edit_action_parameters(MRGAWPLUS,   Action.USmash,          File.MRGAWPLUS_ANIM_USMASH,            UP_SMASH,                    -1)
    Character.edit_action_parameters(MRGAWPLUS,   Action.DSmash,          File.MRGAWPLUS_ANIM_DSMASH,            DOWN_SMASH,                  0x10000000)
    Character.edit_action_parameters(MRGAWPLUS,   Action.AttackAirN,      File.MRGAWPLUS_ANIM_AIRN,              NEUTRAL_AERIAL,              0x10000000)
    Character.edit_action_parameters(MRGAWPLUS,   Action.AttackAirF,      File.MRGAWPLUS_ANIM_AIRF,              FORWARD_AERIAL,              0x10000000)
    Character.edit_action_parameters(MRGAWPLUS,   Action.AttackAirB,      File.MRGAWPLUS_ANIM_AIRB,              BACK_AERIAL,                 -1)
    Character.edit_action_parameters(MRGAWPLUS,   Action.AttackAirU,      File.MRGAWPLUS_ANIM_AIRU,              UP_AERIAL,                   0x10000000)
    Character.edit_action_parameters(MRGAWPLUS,   Action.AttackAirD,      File.MRGAWPLUS_ANIM_AIRD,              DOWN_AERIAL,                 0x10000000)
    Character.edit_action_parameters(MRGAWPLUS,   0xDC,                   File.MRGAWPLUS_ANIM_JAB3,              JAB_3,                      -1)
    Character.edit_action_parameters(MRGAWPLUS,   0xDD,                   File.MRGAWPLUS_ANIM_ENTRYR,            APPEAR,                     -1)
    Character.edit_action_parameters(MRGAWPLUS,   0xDE,                   File.MRGAWPLUS_ANIM_ENTRYL,            APPEAR,                     -1)
    Character.edit_action_parameters(MRGAWPLUS,   0xDF,                   File.MRGAWPLUS_ANIM_NSPGND,            NEUTRAL_SPECIAL,            -1)//0x40000000)
    Character.edit_action_parameters(MRGAWPLUS,   0xE0,                   File.MRGAWPLUS_ANIM_NSPAIR,            NEUTRAL_SPECIAL,            -1)
    Character.edit_action_parameters(MRGAWPLUS,   0xE1,                   File.MRGAWPLUS_ANIM_USP,               UP_SPECIAL,                 0x50000000)
    Character.edit_action_parameters(MRGAWPLUS,   0xE2,                   File.MRGAWPLUS_ANIM_USP,               UP_SPECIAL,                 0x50000000)
    Character.edit_action_parameters(MRGAWPLUS,   0xE3,                   File.MRGAWPLUS_ANIM_DSPGND,            DOWN_SPECIAL_1,             0x50000000)
    Character.edit_action_parameters(MRGAWPLUS,   0xE4,                   File.MRGAWPLUS_ANIM_DSPAIR,            DOWN_SPECIAL_1,             0x50000000)
	
    Character.edit_action_parameters(MRGAWPLUS,   0x0D6,                  File.MRGAWPLUS_ANIM_LANDN,             NAIRLAND,                   -1)
    Character.edit_action_parameters(MRGAWPLUS,   0x0D7,                  File.MRGAWPLUS_ANIM_LANDF,             FAIRLAND,                   0x10000000)
    Character.edit_action_parameters(MRGAWPLUS,   0x0D8,                  File.MRGAWPLUS_ANIM_LANDB,             BAIRLAND,                   -1)
    Character.edit_action_parameters(MRGAWPLUS,   0x0D9,                  File.MRGAWPLUS_ANIM_LANDU,             UAIRLAND,                   0x10000000)
    Character.edit_action_parameters(MRGAWPLUS,   0x0DA,                  File.MRGAWPLUS_ANIM_LANDD,             DAIRLAND,                   0x10000000)
	
    // Modify Actions             // Action          			// Staling ID   // Main ASM           			// Interrupt/Other ASM          	// Movement/Physics ASM         // Collision ASM
    Character.edit_action(MRGAWPLUS,  0xDF,              		-1,             GameAndWatchNSP.main,  			GameAndWatchNSP.chef_refresh_,          -1,                             -1)
    Character.edit_action(MRGAWPLUS,  0xE0,              		-1,             GameAndWatchNSP.main,  			GameAndWatchNSP.chef_refresh_,          -1,                             GameAndWatchNSP.air_collision_)
    Character.edit_action(MRGAWPLUS,  Action.Fire,       		-1,             GameAndWatchUSP.main_air_,  		GameAndWatchUSP.change_direction_,      GameAndWatchUSP.physics_,       GameAndWatchUSP.collision_)
    Character.edit_action(MRGAWPLUS,  Action.FireAir,    		-1,             GameAndWatchUSP.main_air_,  		GameAndWatchUSP.change_direction_,      GameAndWatchUSP.physics_,       GameAndWatchUSP.collision_)
    Character.edit_action(MRGAWPLUS,  Action.JudgeBegin, 		-1,          	GameAndWatchDSP.main,       		-1,					0x800D8BB4,			GameAndWatchDSP.ground_collision_)
    Character.edit_action(MRGAWPLUS,  Action.JudgeBeginAir,   	        -1,             GameAndWatchDSP.main,          		-1,					0x800D90E0,			GameAndWatchDSP.air_collision_)
	
    // Add Action Parameters             // Action Name      // Base Action  // Animation               // Moveset Data        // Flags
    Character.add_new_action_params(MRGAWPLUS, DSP_Ground_1,   	 -1,             File.MRGAWPLUS_ANIM_DSPGND,   			DOWN_SPECIAL_1,                 0x50000000)
    Character.add_new_action_params(MRGAWPLUS, DSP_Air_1,      	 -1,             File.MRGAWPLUS_ANIM_DSPAIR,   			DOWN_SPECIAL_1,                 0x50000000)
    Character.add_new_action_params(MRGAWPLUS, DSP_Ground_2,   	 -1,             File.MRGAWPLUS_ANIM_DSPGND,   			DOWN_SPECIAL_2,                 0x50000000)
    Character.add_new_action_params(MRGAWPLUS, DSP_Air_2,      	 -1,             File.MRGAWPLUS_ANIM_DSPAIR,   			DOWN_SPECIAL_2,                 0x50000000)
    Character.add_new_action_params(MRGAWPLUS, DSP_Ground_3,   	 -1,             File.MRGAWPLUS_ANIM_DSPGND,   			DOWN_SPECIAL_3,                 0x50000000)
    Character.add_new_action_params(MRGAWPLUS, DSP_Air_3,      	 -1,             File.MRGAWPLUS_ANIM_DSPAIR,   			DOWN_SPECIAL_3,                 0x50000000)
    Character.add_new_action_params(MRGAWPLUS, DSP_Ground_4,   	 -1,             File.MRGAWPLUS_ANIM_DSPGND,   			DOWN_SPECIAL_4,                 0x50000000)
    Character.add_new_action_params(MRGAWPLUS, DSP_Air_4,      	 -1,             File.MRGAWPLUS_ANIM_DSPAIR,   			DOWN_SPECIAL_4,                 0x50000000)
    Character.add_new_action_params(MRGAWPLUS, DSP_Ground_5,   	 0xE3,           File.MRGAWPLUS_ANIM_DSPGND,   		    	DOWN_SPECIAL_5,                 0x50000000)
    Character.add_new_action_params(MRGAWPLUS, DSP_Air_5,      	 0xE4,           File.MRGAWPLUS_ANIM_DSPAIR,   		    	DOWN_SPECIAL_5,                 0x50000000)
    Character.add_new_action_params(MRGAWPLUS, DSP_Ground_6,   	 -1,             File.MRGAWPLUS_ANIM_DSPGND,   			DOWN_SPECIAL_6,                 0x50000000)
    Character.add_new_action_params(MRGAWPLUS, DSP_Air_6,      	 -1,             File.MRGAWPLUS_ANIM_DSPAIR,   			DOWN_SPECIAL_6,                 0x50000000)
    Character.add_new_action_params(MRGAWPLUS, DSP_Ground_7,   	 -1,             File.MRGAWPLUS_ANIM_DSPGND,   			DOWN_SPECIAL_7,                 0x50000000)
    Character.add_new_action_params(MRGAWPLUS, DSP_Air_7,      	 -1,             File.MRGAWPLUS_ANIM_DSPAIR,   			DOWN_SPECIAL_7,                 0x50000000)
    Character.add_new_action_params(MRGAWPLUS, DSP_Ground_8,   	 -1,             File.MRGAWPLUS_ANIM_DSPGND,   			DOWN_SPECIAL_8,                 0x50000000)
    Character.add_new_action_params(MRGAWPLUS, DSP_Air_8,      	 -1,             File.MRGAWPLUS_ANIM_DSPAIR,   			DOWN_SPECIAL_8,                 0x50000000)
    Character.add_new_action_params(MRGAWPLUS, DSP_Ground_9,   	 -1,             File.MRGAWPLUS_ANIM_DSPGND,   			DOWN_SPECIAL_9,                 0x50000000)
    Character.add_new_action_params(MRGAWPLUS, DSP_Air_9,      	 -1,             File.MRGAWPLUS_ANIM_DSPAIR,   			DOWN_SPECIAL_9,                 0x50000000)
	
    Character.add_new_action_params(MRGAWPLUS, USP_Float,      	 -1,             File.MRGAWPLUS_ANIM_USPFLOAT,   		UP_SPECIAL_FLOAT,               0x50000000)

    // Add Actions                // Action Name    // Base Action     //Parameters  // Staling ID   // Main ASM  // Interrupt/Other ASM      // Movement/Physics ASM    // Collision ASM	
    Character.add_new_action(MRGAWPLUS, DSP_Ground_1,   -1,     ActionParams.DSP_Ground_1,  0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4,    GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWPLUS, DSP_Air_1,      -1,     ActionParams.DSP_Air_1,     0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D90E0,    GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAWPLUS, DSP_Ground_2,   -1,     ActionParams.DSP_Ground_2,  0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4,    GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWPLUS, DSP_Air_2,      -1,     ActionParams.DSP_Air_2,     0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D90E0,    GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAWPLUS, DSP_Ground_3,   -1,     ActionParams.DSP_Ground_3,  0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4,    GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWPLUS, DSP_Air_3,      -1,     ActionParams.DSP_Air_3,     0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D90E0,    GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAWPLUS, DSP_Ground_4,   -1,     ActionParams.DSP_Ground_4,  0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4,    GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWPLUS, DSP_Air_4,      -1,     ActionParams.DSP_Air_4,     0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D90E0,    GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAWPLUS, DSP_Ground_5,   -1,     ActionParams.DSP_Ground_5,  0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4,    GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWPLUS, DSP_Air_5,      -1,     ActionParams.DSP_Air_5,     0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D90E0,    GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAWPLUS, DSP_Ground_6,   -1,     ActionParams.DSP_Ground_6,  0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4,    GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWPLUS, DSP_Air_6,      -1,     ActionParams.DSP_Air_6,     0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D90E0,    GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAWPLUS, DSP_Ground_7,   -1,     ActionParams.DSP_Ground_7,  0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4,    GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWPLUS, DSP_Air_7,      -1,     ActionParams.DSP_Air_7,     0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D90E0,    GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAWPLUS, DSP_Ground_8,   -1,     ActionParams.DSP_Ground_8,  0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4,    GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWPLUS, DSP_Air_8,      -1,     ActionParams.DSP_Air_8,     0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D90E0,    GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAWPLUS, DSP_Ground_9,   -1,     ActionParams.DSP_Ground_9,  0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D8BB4,    GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWPLUS, DSP_Air_9,      -1,     ActionParams.DSP_Air_9,     0x1E,    GameAndWatchDSP.attacks_main_,    -1,    0x800D90E0,    GameAndWatchDSP.air_collision_)

    Character.add_new_action(MRGAWPLUS, USP_Float, -1, ActionParams.USP_Float, -1, 0x00000000, GameAndWatchUSP.float_interrupt_, GameAndWatchUSP.float_physics_, GameAndWatchUSP.float_collision_)

    //GameAndWatchDSP.air_physics_ for all aerial versions (used to be GameAndWatchDSP.air_physics_)
    // Modify Action Parameters               // Action             // Animation                // Moveset Data             // Flags
	Character.edit_action_parameters(MRGAWPLUS,   0xE3,                 File.MRGAWPLUS_ANIM_DSPGND,              DOWN_SPECIAL_1,                    	-1)
	Character.edit_action_parameters(MRGAWPLUS,   0xE4,                 File.MRGAWPLUS_ANIM_DSPAIRBEGIN,              DOWN_SPECIAL_1,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xE5,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_1,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xE6,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_1,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xE7,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_2,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xE8,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_2,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xE9,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_3,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xEA,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_3,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xEB,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_4,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xEC,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_4,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xED,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_5,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xEE,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_5,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xEF,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_6,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xF0,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_6,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xF1,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_7,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xF2,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_7,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xF3,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_8,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xF4,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_8,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xF5,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_9,                    	0x10000000)
	//Character.edit_action_parameters(MRGAWPLUS,   0xF6,                 File.MRGAWPLUS_ANIM_DSPA,              DSP_9,                    	0x10000000)

    Character.edit_menu_action_parameters(MRGAWPLUS, 0x0,             File.MRGAWPLUS_ANIM_IDLE,           MOUTH,                                       -1)     // CSS IDLE
    Character.edit_menu_action_parameters(MRGAWPLUS, 0x1,             File.MRGAWPLUS_ANIM_VICTORY3,        VICTORY_3,                       0x10000000)     // VICTORY 3 and CSS animation
    Character.edit_menu_action_parameters(MRGAWPLUS, 0x2,             File.MRGAWPLUS_ANIM_VICTORY2,        VICTORY_2,                               -1)     // VICTORY 2
    Character.edit_menu_action_parameters(MRGAWPLUS, 0x3,             File.MRGAWPLUS_ANIM_VICTORY1,        VICTORY_1,                       0x10000000)     // VICTORY 1

    Character.edit_menu_action_parameters(MRGAWPLUS, 0x5,             File.MRGAWPLUS_ANIM_CLAP,            CLAP,                                    -1)     // NO CONTEST
    // Character.edit_menu_action_parameters(MRGAWPLUS, 0x9,          File.MRGAWPLUS_ANIM_CONTINUE_FALL,     -1,                                    -1)
    // Character.edit_menu_action_parameters(MRGAWPLUS, 0xA,          File.MRGAWPLUS_ANIM_CONTINUE_UP,       -1,                                    -1)
    Character.edit_menu_action_parameters(MRGAWPLUS, 0xD,             File.MRGAWPLUS_ANIM_1PPOSE,        	 POSE1P,                                -1)     // 1P SCREEN POSE
    Character.edit_menu_action_parameters(MRGAWPLUS, 0xE,             File.MRGAWPLUS_ANIM_1PPOSE,        	 POSE1P,                                -1)     // 1P SCREEN POSE

    // Modify Menu Action Parameters                // Action           // Animation                // Moveset Data             // Flags
    //Character.edit_menu_action_parameters(MRGAWPLUS,      0xE,                File.DRM_1P_CPU_POSE,       0x80000000,                 -1)

    if {defined Character.CHARACTER_ADDED_MRGAW} {
        Character.table_patch_start(variant_original, Character.id.MRGAWPLUS, 0x4)
        dw      Character.id.MRGAW // set Mr. Game & Watch as original character (not Mario, who MRGAWPLUS is a clone of)
        OS.patch_end()
    }

    // Set subroutines for special move initiations.
    Character.table_patch_start(ground_dsp, Character.id.MRGAWPLUS, 0x4)
    dw      GameAndWatchDSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.MRGAWPLUS, 0x4)
    dw      GameAndWatchDSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(ground_usp, Character.id.MRGAWPLUS, 0x4)
    dw      GameAndWatchUSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.MRGAWPLUS, 0x4)
    dw      GameAndWatchUSP.air_initial_
    OS.patch_end()
	
	// Remove entry script (no more warp pipe).
    Character.table_patch_start(entry_script, Character.id.MRGAWPLUS, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.MRGAWPLUS, 0x2)
    dh  FGM.CHANT
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.MRGAWPLUS, 0xC)
    dh 0x08
    OS.patch_end()

	// Set default costumes(id, costume_1, costume_2, costume_3, costume_4, red_team, blue_team, green_team)
    Character.set_default_costumes(Character.id.MRGAWPLUS, 0, 3, 2, 1, 3, 2, 1)
    Teams.add_team_costume(YELLOW, MRGAWPLUS, 0x6)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(MRGAWPLUS, BLACK, GREEN, BLUE, RED, CYAN, WHITE, YELLOW, PURPLE, MAGENTA, ORANGE, RED, YELLOW)

    // Set action strings
    Character.table_patch_start(action_string, Character.id.MRGAWPLUS, 0x4)
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
            //li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_fish_bowl
            li      t1, _check_gnw_flag        // t1 = return address
            lbu     t2, 0x0995(s8)              // t2 = g&w arm part_id
            lli     t9, 0x0003                  // t9 = special part of fish_bowl
            beql    t2, t9, _fix                // if fish_bowl, fix
            nop

            _check_gnw_flag:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_flag
            li      t1, _check_gnw_blaster_one  // t1 = return address
            lbu     t2, 0x0997(s8)              // t2 = g&w arm part_id
            lli     t9, 0x0001                  // t9 = special part of flag
            beql    t2, t9, _fix                // if flag, fix
            nop

            _check_gnw_blaster_one:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_blaster_one
            li      t1, _check_gnw_blaster_two  // t1 = return address
            lbu     t2, 0x0997(s8)              // t2 = g&w arm part_id
            lli     t9, 0x0002                  // t9 = special part of blaster_one
            beql    t2, t9, _fix                // if blaster_one, fix
            nop

            _check_gnw_blaster_two:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_blaster_two
            li      t1, _check_gnw_torch        // t1 = return address
            lbu     t2, 0x0997(s8)              // t2 = g&w arm part_id
            lli     t9, 0x0003                  // t9 = special part of blaster_two
            beql    t2, t9, _fix                // if blaster_two, fix
            nop

            _check_gnw_torch:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_torch
            li      t1, _check_gnw_turtle        // t1 = return address
            lbu     t2, 0x0997(s8)              // t2 = g&w item part_id
            lli     t9, 0x0004                  // t9 = special part of torch
            beql    t2, t9, _fix                // if torch, fix
            nop

            _check_gnw_turtle:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_turtle
            li      t1, _check_gnw_fish_one        // t1 = return address
            lbu     t2, 0x0997(s8)              // t2 = g&w item part_id
            lli     t9, 0x0005                  // t9 = special part of turtle
            beql    t2, t9, _fix                // if turtle, fix
            nop

            _check_gnw_fish_one:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_fish_one
            li      t1, _check_gnw_bell        // t1 = return address
            lbu     t2, 0x0997(s8)              // t2 = g&w item part_id
            lli     t9, 0x0006                  // t9 = special part of fish_one
            beql    t2, t9, _fix                // if fish_one, fix
            nop

            _check_gnw_bell:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_bell
            li      t1, _check_gnw_key        // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0001                  // t9 = special part of bell
            beql    t2, t9, _fix                // if bell, fix
            nop

            _check_gnw_key:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_key
            li      t1, _check_gnw_wind        // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0003                  // t9 = special part of key
            beql    t2, t9, _fix                // if key, fix
            nop

            _check_gnw_wind:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_wind
            li      t1, _check_gnw_chair        // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0005                  // t9 = special part of wind
            beql    t2, t9, _fix                // if wind, fix
            nop

            _check_gnw_chair:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_chair
            li      t1, _check_gnw_parachute    // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0006                  // t9 = special part of chair
            beql    t2, t9, _fix                // if chair, fix
            nop

            _check_gnw_parachute:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_parachute
            li      t1, _check_gnw_card_one        // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0009                  // t9 = special part of parachute
            beql    t2, t9, _fix                // if parachute, fix
            nop

            _check_gnw_card_one:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_card_one
            li      t1, _check_gnw_card_two        // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x000A                  // t9 = special part of card_one
            beql    t2, t9, _fix                // if card_one, fix
            nop

            _check_gnw_card_two:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_card_two
            li      t1, _check_gnw_card_three        // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x000B                  // t9 = special part of card_two
            beql    t2, t9, _fix                // if card_two, fix
            nop

            _check_gnw_card_three:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_card_three
            li      t1, _check_gnw_card_four   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x000C                  // t9 = special part of card_three
            beql    t2, t9, _fix                // if card_three, fix
            nop

            _check_gnw_card_four:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_card_four
            li      t1, _check_gnw_card_five   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x000D                  // t9 = special part of card_four
            beql    t2, t9, _fix                // if card_four, fix
            nop

            _check_gnw_card_five:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_card_five
            li      t1, _check_gnw_card_six   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x000E                  // t9 = special part of card_five
            beql    t2, t9, _fix                // if card_five, fix
            nop

            _check_gnw_card_six:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_card_six
            li      t1, _check_gnw_card_seven   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x000F                  // t9 = special part of card_six
            beql    t2, t9, _fix                // if card_six, fix
            nop

            _check_gnw_card_seven:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_card_seven
            li      t1, _check_gnw_card_eight   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0010                  // t9 = special part of card_seven
            beql    t2, t9, _fix                // if card_seven, fix
            nop

            _check_gnw_card_eight:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_card_eight
            li      t1, _check_gnw_card_nine   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0011                  // t9 = special part of card_eight
            beql    t2, t9, _fix                // if card_eight, fix
            nop

            _check_gnw_card_nine:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_card_nine
            li      t1, _check_gnw_fire_one   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0012                  // t9 = special part of card_nine
            beql    t2, t9, _fix                // if card_nine, fix
            nop

            _check_gnw_fire_one:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_fire_one
            li      t1, _check_gnw_fire_two   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0013                  // t9 = special part of fire_one
            beql    t2, t9, _fix                // if fire_one, fix
            nop

            _check_gnw_fire_two:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_fire_two
            li      t1, _check_gnw_fish_two   // t1 = return address
            lbu     t2, 0x09AD(s8)              // t2 = g&w grab part_id
            lli     t9, 0x0014                  // t9 = special part of fire_two
            beql    t2, t9, _fix                // if fire_two, fix
            nop

            _check_gnw_fish_two:
            li      v0, CharEnvColor.custom_display_lists_struct_mrgawplus_fish_two
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

