// GameAndWatch.asm

// This file contains file inclusions, action edits, and assembly for Mr. Game and Watch.

include "./GameAndWatchSpecial.asm"

scope GameAndWatch {
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
	
    BEAMSWORD_JAB:; dw 0xBC000004; dw 0xA0600002; dw 0x08000004; dw 0xCC040000; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_JAB); dw 0x04000005; dw 0xCC03FFFF; dw 0x04000004; dw 0x18000000; dw 0
    BEAMSWORD_TILT:; dw 0xBC000004; dw 0xA0600002; dw 0x08000004; dw 0xBC000004; dw 0xCC040000; dw 0x08000009; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_TILT); dw 0x04000003; dw 0xCC03FFFF; dw 0x04000007; dw 0x18000000; dw 0
    BEAMSWORD_SMASH:; dw 0xBC000004; dw 0xA0600002; dw 0x50000000; dw 0x08000014; dw 0xCC040000; dw 0x08000016; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_SMASH); dw 0x04000007; dw 0x18000000; dw 0x04000002; dw 0xCC03FFFF; dw 0x0800002D; dw 0xBC000004; dw 0
    BEAMSWORD_DASH:; dw 0xBC000004; dw 0xA0600002; dw 0x08000004; dw 0xCC040000; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_DASH); dw 0x04000004; dw 0xCC03FFFF; dw 0x04000016; dw 0x18000000; dw 0x08000020; dw 0xBC000004; dw 0
    BAT_JAB:; dw 0xBC000004; dw 0xA0600002; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.BAT_JAB); dw 0x04000009; dw 0x18000000; dw 0
    BAT_TILT:; dw 0xBC000004; dw 0xA0600002; dw 0x08000004; dw 0xBC000004; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.BAT_TILT); dw 0x0400000A; dw 0x18000000; dw 0x08000026; dw 0xBC000004; dw 0
    BAT_SMASH:; dw 0x50000000; dw 0xA0600002; dw 0xBC000004; dw 0xC4000007; dw 0xB1300028; dw 0x08000014; dw 0xBC000004; dw 0x08000016; Moveset.SUBROUTINE(Moveset.shared.BAT_SMASH); dw 0x04000007; dw 0x18000000; dw 0x0800002D; dw 0xBC000004; dw 0
    BAT_DASH:; dw 0xBC000004; dw 0xA0600002; dw 0x08000004; Moveset.SUBROUTINE(Moveset.shared.BAT_DASH); dw 0x0400001A; dw 0x18000000; dw 0x08000020; dw 0xBC000004; dw 0
    FAN_JAB:; dw 0xBC000004; dw 0xA0600002; dw 0x08000005; Moveset.SUBROUTINE(Moveset.shared.FAN_JAB); dw 0x04000005; dw 0x18000000; dw 0
    FAN_TILT:; dw 0xBC000004; dw 0xA0600002; dw 0x08000004; dw 0xBC000004; dw 0x08000005; Moveset.SUBROUTINE(Moveset.shared.FAN_TILT); dw 0x0400000A; dw 0x18000000; dw 0x08000026; dw 0xBC000004; dw 0
    FAN_SMASH:; dw 0xBC000004; dw 0xA0600002; dw 0x08000014; dw 0xBC000004; dw 0x08000016; Moveset.SUBROUTINE(Moveset.shared.FAN_SMASH); dw 0x04000007; dw 0x18000000; dw 0x0800002D; dw 0xBC000004; dw 0
    FAN_DASH:; dw 0xBC000004; dw 0xA0600002; dw 0x08000004; Moveset.SUBROUTINE(Moveset.shared.FAN_DASH); dw 0x0400001A; dw 0x18000000; dw 0x08000020; dw 0xBC000004; dw 0
    STARROD_JAB:; dw 0xBC000004; dw 0xA0600002; dw 0xB12C0010; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.STARROD_JAB); dw 0x04000009; dw 0x18000000; dw 0
    STARROD_TILT:; dw 0xBC000004; dw 0xA0600002; dw 0x08000004; dw 0xBC000004; dw 0xB12C000D; dw 0x08000009; Moveset.SUBROUTINE(Moveset.shared.STARROD_TILT); dw 0x04000001; dw 0x54000001; dw 0x04000009; dw 0x18000000;  dw 0x08000026; dw 0xBC000004; dw 0
    STARROD_SMASH:; dw 0x50000000; dw 0xA0600002; dw 0xBC000004; dw 0x08000014; dw 0xBC000004; dw 0xB12C0024; dw 0x08000016; Moveset.SUBROUTINE(Moveset.shared.STARROD_SMASH); dw 0x04000001; dw 0x54000002; dw 0x04000006; dw 0x18000000; dw 0x0800002D; dw 0xBC000004; dw 0
    STARROD_DASH:; dw 0xBC000004; dw 0xA0600002; dw 0xB12C0014; dw 0x08000004; Moveset.SUBROUTINE(Moveset.shared.STARROD_DASH); dw 0x0400001A; dw 0x18000000; dw 0x08000020; dw 0xBC000004; dw 0
	
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
    Character.edit_action_parameters(MRGAWTHREED, Action.DeadU,                  File.MRGAWTHREED_ANIM_TUMBLE,                 -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ScreenKO,               File.MRGAWTHREED_ANIM_TUMBLE,                 -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Revive1,                File.MRGAWTHREED_ANIM_DOWNBOUNCED,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Revive2,                File.MRGAWTHREED_ANIM_DOWNSTANDD,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ReviveWait,             File.MRGAWTHREED_ANIM_IDLE,                   -1,                       -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Idle,                   File.MRGAWTHREED_ANIM_IDLE,                   IDLE,                       -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Walk1,                  File.MRGAWTHREED_ANIM_WALK1,                 WALK1_,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Walk2,                  File.MRGAWTHREED_ANIM_WALK2,                 WALK2_,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Walk3,                  File.MRGAWTHREED_ANIM_WALK3,                 WALK3_,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, 0x00E,                         File.MRGAWTHREED_ANIM_WALKEND,               SLOPES,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Dash,                   File.MRGAWTHREED_ANIM_DASH,                   DASH,                       -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Run,                    File.MRGAWTHREED_ANIM_RUN,                    RUN_,                        -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.RunBrake,               File.MRGAWTHREED_ANIM_RUNBRAKE,              -1,                  -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Turn,                   File.MRGAWTHREED_ANIM_TURN,                   TURN,                       -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.TurnRun,                File.MRGAWTHREED_ANIM_TURNRUN,               -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.JumpSquat,              File.MRGAWTHREED_ANIM_LANDING,                -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ShieldJumpSquat,        File.MRGAWTHREED_ANIM_LANDING,                -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.JumpF,                  File.MRGAWTHREED_ANIM_JUMPF,                 JUMP,                     -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.JumpB,                  File.MRGAWTHREED_ANIM_JUMPB,                 JUMP,                     -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.JumpAerialF,            File.MRGAWTHREED_ANIM_JUMPAERIALF,          DOUBLEJUMP,                     -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.JumpAerialB,            File.MRGAWTHREED_ANIM_JUMPAERIALB,          DOUBLEJUMP,                     -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Fall,                   File.MRGAWTHREED_ANIM_FALL,                   -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.FallAerial,             File.MRGAWTHREED_ANIM_FALLAERIAL,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Crouch,                 File.MRGAWTHREED_ANIM_CROUCH,                 SLOPES,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CrouchIdle,             File.MRGAWTHREED_ANIM_CROUCHIDLE,            SLOPES,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CrouchEnd,              File.MRGAWTHREED_ANIM_CROUCHEND,             SLOPES,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.LandingLight,           File.MRGAWTHREED_ANIM_LANDING,                SLOPES,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.LandingHeavy,           File.MRGAWTHREED_ANIM_LANDING,                SLOPES,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Pass,                   File.MRGAWTHREED_ANIM_PLATFORMDROP,              -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ShieldDrop,             File.MRGAWTHREED_ANIM_PLATFORMDROP,              -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Teeter,                 File.MRGAWTHREED_ANIM_TEETER,                 SLOPES,                     -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.TeeterStart,            File.MRGAWTHREED_ANIM_TEETERSTART,            SLOPES,                     -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageHigh1,            File.MRGAWTHREED_ANIM_DAMAGEHI1,             -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageHigh2,            File.MRGAWTHREED_ANIM_DAMAGEHI2,             -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageHigh3,            File.MRGAWTHREED_ANIM_DAMAGEHI3,             -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageMid1,             File.MRGAWTHREED_ANIM_DAMAGEMID1,              -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageMid2,             File.MRGAWTHREED_ANIM_DAMAGEMID2,              -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageMid3,             File.MRGAWTHREED_ANIM_DAMAGEMID3,              -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageLow1,             File.MRGAWTHREED_ANIM_DAMAGELOW1,              -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageLow2,             File.MRGAWTHREED_ANIM_DAMAGELOW2,              -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageLow3,             File.MRGAWTHREED_ANIM_DAMAGELOW3,              -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageAir1,             File.MRGAWTHREED_ANIM_DAMAGEAIR1,              -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageAir2,             File.MRGAWTHREED_ANIM_DAMAGEAIR2,              -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageAir3,             File.MRGAWTHREED_ANIM_DAMAGEAIR3,              -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageElec1,            File.MRGAWTHREED_ANIM_DAMAGEELEC,               -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageElec2,            File.MRGAWTHREED_ANIM_DAMAGEELEC,               -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageFlyHigh,          File.MRGAWTHREED_ANIM_DAMAGEFLYHI,           -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageFlyMid,           File.MRGAWTHREED_ANIM_DAMAGEFLYMID,            -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageFlyLow,           File.MRGAWTHREED_ANIM_DAMAGEFLYLOW,            -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageFlyTop,           File.MRGAWTHREED_ANIM_DAMAGEFLYTOP,            -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DamageFlyRoll,          File.MRGAWTHREED_ANIM_DAMAGEFLYROLL,           -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.WallBounce,             File.MRGAWTHREED_ANIM_TUMBLE,                 -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Tumble,                 File.MRGAWTHREED_ANIM_TUMBLE,                 -1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.FallSpecial,            File.MRGAWTHREED_ANIM_FALLSPECIAL,           -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.LandingSpecial,         File.MRGAWTHREED_ANIM_LANDING,                SLOPES,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.EnterPipe,              File.MRGAWTHREED_ANIM_ENTERPIPE,             -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ExitPipe,               File.MRGAWTHREED_ANIM_EXITPIPE,              -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ExitPipeWalk,           File.MRGAWTHREED_ANIM_EXITPIPEWALK,         -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CeilingBonk,            File.MRGAWTHREED_ANIM_CEILINGBONK,           -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DownBounceD,            File.MRGAWTHREED_ANIM_DOWNBOUNCED,            -1,                -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DownBounceU,            File.MRGAWTHREED_ANIM_DOWNBOUNCEU,            -1,                -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DownStandD,             File.MRGAWTHREED_ANIM_DOWNSTANDD,            -1,                 -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DownStandU,             File.MRGAWTHREED_ANIM_DOWNSTANDU,            -1,                 -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.TechF,                  File.MRGAWTHREED_ANIM_TECHF,                 TECHFB,                  -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.TechB,                  File.MRGAWTHREED_ANIM_TECHB,                 TECHFB,                  -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DownForwardD,           File.MRGAWTHREED_ANIM_DOWNFORWARDD,            -1,                  -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DownForwardU,           File.MRGAWTHREED_ANIM_DOWNFORWARDU,            -1,                  -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DownBackD,              File.MRGAWTHREED_ANIM_DOWNBACKD,              -1,                  -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DownBackU,              File.MRGAWTHREED_ANIM_DOWNBACKU,              -1,                  -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DownAttackD,            File.MRGAWTHREED_ANIM_DOWNATTACKD,             DOWN_ATTACK,              -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.DownAttackU,            File.MRGAWTHREED_ANIM_DOWNATTACKU,             DOWN_ATTACK,              -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Tech,                   File.MRGAWTHREED_ANIM_TECH,                   TECH,                       -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ClangRecoil,            File.MRGAWTHREED_ANIM_CLANGRECOIL,           SLOPES,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CliffCatch,             File.MRGAWTHREED_ANIM_CLIFFCATCH,              -1,                -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CliffWait,              File.MRGAWTHREED_ANIM_CLIFFWAIT,               -1,                 -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CliffQuick,             File.MRGAWTHREED_ANIM_CLIFFQUICK,              -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CliffClimbQuick1,       File.MRGAWTHREED_ANIM_CLIFFCLIMBQUICK1,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CliffClimbQuick2,       File.MRGAWTHREED_ANIM_CLIFFCLIMBQUICK2,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CliffSlow,              File.MRGAWTHREED_ANIM_CLIFFSLOW,               -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CliffClimbSlow1,        File.MRGAWTHREED_ANIM_CLIFFCLIMBSLOW1,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CliffClimbSlow2,        File.MRGAWTHREED_ANIM_CLIFFCLIMBSLOW2,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CliffAttackQuick1,      File.MRGAWTHREED_ANIM_CLIFFATTACKQUICK1,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CliffAttackQuick2,      File.MRGAWTHREED_ANIM_CLIFFATTACKQUICK2,            CLIFF_ATK_QUICK_2,          -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CliffAttackSlow1,       File.MRGAWTHREED_ANIM_CLIFFATTACKSLOW1,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CliffAttackSlow2,       File.MRGAWTHREED_ANIM_CLIFFATTACKSLOW2,            CLIFF_ATK_SLOW_2,           -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CliffEscapeQuick1,      File.MRGAWTHREED_ANIM_CLIFFESCAPEQUICK1,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CliffEscapeQuick2,      File.MRGAWTHREED_ANIM_CLIFFESCAPEQUICK2,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CliffEscapeSlow1,       File.MRGAWTHREED_ANIM_CLIFFESCAPESLOW1,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.CliffEscapeSlow2,       File.MRGAWTHREED_ANIM_CLIFFESCAPESLOW2,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.LightItemPickup,        File.MRGAWTHREED_ANIM_ITEMPICKUPLIGHT,           -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.HeavyItemPickup,        File.MRGAWTHREED_ANIM_ITEMPICKUPHEAVY,           -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemDrop,               File.MRGAWTHREED_ANIM_ITEMDROP,               -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemThrowDash,          File.MRGAWTHREED_ANIM_ITEMTHROWDASH,         -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemThrowF,             File.MRGAWTHREED_ANIM_ITEMTHROWF,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemThrowB,             File.MRGAWTHREED_ANIM_ITEMTHROWF,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemThrowU,             File.MRGAWTHREED_ANIM_ITEMTHROWU,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemThrowD,             File.MRGAWTHREED_ANIM_ITEMTHROWD,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemThrowSmashF,        File.MRGAWTHREED_ANIM_ITEMTHROWF,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemThrowSmashB,        File.MRGAWTHREED_ANIM_ITEMTHROWF,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemThrowSmashU,        File.MRGAWTHREED_ANIM_ITEMTHROWU,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemThrowSmashD,        File.MRGAWTHREED_ANIM_ITEMTHROWD,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemThrowAirF,          File.MRGAWTHREED_ANIM_ITEMTHROWAIRF,        -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemThrowAirB,          File.MRGAWTHREED_ANIM_ITEMTHROWAIRF,        -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemThrowAirU,          File.MRGAWTHREED_ANIM_ITEMTHROWAIRU,        -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemThrowAirD,          File.MRGAWTHREED_ANIM_ITEMTHROWAIRD,        -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemThrowAirSmashF,     File.MRGAWTHREED_ANIM_ITEMTHROWAIRF,        -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemThrowAirSmashB,     File.MRGAWTHREED_ANIM_ITEMTHROWAIRF,        -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemThrowAirSmashU,     File.MRGAWTHREED_ANIM_ITEMTHROWAIRU,        -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ItemThrowAirSmashD,     File.MRGAWTHREED_ANIM_ITEMTHROWAIRD,        -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.HeavyItemThrowF,        File.MRGAWTHREED_ANIM_HEAVYITEMTHROW,        -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.HeavyItemThrowB,        File.MRGAWTHREED_ANIM_HEAVYITEMTHROW,        -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.HeavyItemThrowSmashF,   File.MRGAWTHREED_ANIM_HEAVYITEMTHROW,        -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.HeavyItemThrowSmashB,   File.MRGAWTHREED_ANIM_HEAVYITEMTHROW,        -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.BeamSwordNeutral,       File.MRGAWTHREED_ANIM_ITEMNEUTRAL,            BEAMSWORD_JAB,              -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.BeamSwordTilt,          File.MRGAWTHREED_ANIM_ITEMTILT,               BEAMSWORD_TILT,             -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.BeamSwordSmash,         File.MRGAWTHREED_ANIM_ITEMSMASH,              BEAMSWORD_SMASH,            -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.BeamSwordDash,          File.MRGAWTHREED_ANIM_ITEMDASH,               BEAMSWORD_DASH,             -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.BatNeutral,             File.MRGAWTHREED_ANIM_ITEMNEUTRAL,            BAT_JAB,                    -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.BatTilt,                File.MRGAWTHREED_ANIM_ITEMTILT,               BAT_TILT,                   -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.BatSmash,               File.MRGAWTHREED_ANIM_ITEMSMASH,              BAT_SMASH,                  -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.BatDash,                File.MRGAWTHREED_ANIM_ITEMDASH,               BAT_DASH,                   -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.FanNeutral,             File.MRGAWTHREED_ANIM_ITEMNEUTRAL,            FAN_JAB,                    -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.FanTilt,                File.MRGAWTHREED_ANIM_ITEMTILT,               FAN_TILT,                   -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.FanSmash,               File.MRGAWTHREED_ANIM_ITEMSMASH,              FAN_SMASH,                  -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.FanDash,                File.MRGAWTHREED_ANIM_ITEMDASH,               FAN_DASH,                   -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.StarRodNeutral,         File.MRGAWTHREED_ANIM_ITEMNEUTRAL,            STARROD_JAB,                -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.StarRodTilt,            File.MRGAWTHREED_ANIM_ITEMTILT,               STARROD_TILT,               -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.StarRodSmash,           File.MRGAWTHREED_ANIM_ITEMSMASH,              STARROD_SMASH,              -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.StarRodDash,            File.MRGAWTHREED_ANIM_ITEMDASH,               STARROD_DASH,               -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.RayGunShoot,            File.MRGAWTHREED_ANIM_ITEMSHOOT,              -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.RayGunShootAir,         File.MRGAWTHREED_ANIM_ITEMSHOOTAIR,          -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.FireFlowerShoot,        File.MRGAWTHREED_ANIM_ITEMSHOOT,              -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.FireFlowerShootAir,     File.MRGAWTHREED_ANIM_ITEMSHOOTAIR,          -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.HammerIdle,             File.MRGAWTHREED_ANIM_HAMMERIDLE,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.HammerWalk,             File.MRGAWTHREED_ANIM_HAMMERMOVE,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.HammerTurn,             File.MRGAWTHREED_ANIM_HAMMERMOVE,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.HammerJumpSquat,        File.MRGAWTHREED_ANIM_HAMMERMOVE,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.HammerAir,              File.MRGAWTHREED_ANIM_HAMMERMOVE,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.HammerLanding,          File.MRGAWTHREED_ANIM_HAMMERMOVE,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ShieldOn,               File.MRGAWTHREED_ANIM_SHIELDON,              -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ShieldOff,              File.MRGAWTHREED_ANIM_SHIELDOFF,             -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.RollF,                  File.MRGAWTHREED_ANIM_ROLLF,                 -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.RollB,                  File.MRGAWTHREED_ANIM_ROLLB,                 -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ShieldBreak,            File.MRGAWTHREED_ANIM_DAMAGEFLYTOP,           SHIELDBREAK_,                -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ShieldBreakFall,        File.MRGAWTHREED_ANIM_TUMBLE,                 -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.StunLandD,              File.MRGAWTHREED_ANIM_DOWNBOUNCED,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.StunLandU,              File.MRGAWTHREED_ANIM_DOWNBOUNCEU,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.StunStartD,             File.MRGAWTHREED_ANIM_DOWNSTANDD,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.StunStartU,             File.MRGAWTHREED_ANIM_DOWNSTANDU,            -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Stun,                   File.MRGAWTHREED_ANIM_STUN,                   STUN_,                       -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Sleep,                  File.MRGAWTHREED_ANIM_STUN,                   SLEEP_,                     -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Grab,                   File.MRGAWTHREED_ANIM_GRAB,                   GRAB_,                       -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.GrabPull,               File.MRGAWTHREED_ANIM_GRABPULL,              -1,                         -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.ThrowF,                 File.MRGAWTHREED_ANIM_THROWF,                THROW_F_,                    -1)
	Character.edit_action_parameters(MRGAWTHREED, Action.ThrowB,                 File.MRGAWTHREED_ANIM_THROWB,                THROW_B_,                    -1)
    Character.edit_action_parameters(MRGAWTHREED, Action.Tornado,                File.MRGAWTHREED_ANIM_TUMBLE,                 -1,                         -1)
    // Character.edit_action_parameters(MRGAWTHREED, Action.CapturePulled,       File.MRGAWTHREED_ANIM_CAPTURE_PULLED,         -1,                         -1)
    // Character.edit_action_parameters(MRGAWTHREED, Action.InhalePulled,        File.MRGAWTHREED_ANIM_TUMBLE,                 -1,                         -1)
    // Character.edit_action_parameters(MRGAWTHREED, Action.InhaleSpat,          File.MRGAWTHREED_ANIM_TUMBLE,                 -1,                         -1)
    // Character.edit_action_parameters(MRGAWTHREED, Action.InhaleCopied,        File.MRGAWTHREED_ANIM_TUMBLE,                 -1,                         -1)
    // Character.edit_action_parameters(MRGAWTHREED, Action.EggLayPulled,        File.MRGAWTHREED_ANIM_CAPTURE_PULLED,         -1,                         -1)
    // Character.edit_action_parameters(MRGAWTHREED, Action.EggLay,              File.MRGAWTHREED_ANIM_IDLE,                   -1,                         -1)
    // Character.edit_action_parameters(MRGAWTHREED, Action.FalconDivePulled,    File.MRGAWTHREED_ANIM_DMG_HIGH_3,             -1,                         -1)
    // Character.edit_action_parameters(MRGAWTHREED, 0x0B4,                      File.MRGAWTHREED_ANIM_TUMBLE,                 -1,                      -1)
    // Character.edit_action_parameters(MRGAWTHREED, Action.ThrownDKPulled,      File.MRGAWTHREED_ANIM_THROWN_DKPULLED,        -1,                      -1)
    // Character.edit_action_parameters(MRGAWTHREED, Action.ThrownMarioBros,     File.MRGAWTHREED_ANIM_THROWN_MARIO_BROS,      -1,                      -1)
	// Character.edit_action_parameters(MRGAWTHREED, Action.ThrownDK,            File.MRGAWTHREED_ANIM_THROWN_DK,              -1,                      -1)
    // Character.edit_action_parameters(MRGAWTHREED, Action.Thrown1,             File.MRGAWTHREED_ANIM_THROWN_1,               -1,                      -1)
    // Character.edit_action_parameters(MRGAWTHREED, Action.Thrown2,             File.MRGAWTHREED_ANIM_THROWN_2,               -1,                      -1)


    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(MRGAWTHREED,   Action.Taunt,           File.MRGAWTHREED_ANIM_TAUNT,             TAUNT,                      -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.Jab1,            File.MRGAWTHREED_ANIM_JAB1,              JAB_1,                      -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.Jab2,            File.MRGAWTHREED_ANIM_JAB2,              JAB_2,                      -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.DashAttack,      File.MRGAWTHREED_ANIM_DASHATTACK,        DASH_ATTACK,                -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.FTiltHigh,       File.MRGAWTHREED_ANIM_FTILT,             FORWARD_TILT,                   -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.FTilt,           File.MRGAWTHREED_ANIM_FTILT,             FORWARD_TILT,                      -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.FTiltLow,        File.MRGAWTHREED_ANIM_FTILT,             FORWARD_TILT,                   -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.UTilt,           File.MRGAWTHREED_ANIM_UTILT,             UP_TILT,                      -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.DTilt,           File.MRGAWTHREED_ANIM_DTILT,             DOWN_TILT,                      -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.FSmashHigh,      File.MRGAWTHREED_ANIM_FSMASH,            FORWARD_SMASH,                  -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.FSmashMidHigh,   File.MRGAWTHREED_ANIM_FSMASH,            FORWARD_SMASH,                -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.FSmash,          File.MRGAWTHREED_ANIM_FSMASH,            FORWARD_SMASH,                     -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.FSmashMidLow,    File.MRGAWTHREED_ANIM_FSMASH,            FORWARD_SMASH,                -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.FSmashLow,       File.MRGAWTHREED_ANIM_FSMASH,            FORWARD_SMASH,                  -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.USmash,          File.MRGAWTHREED_ANIM_USMASH,            UP_SMASH,                     -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.DSmash,          File.MRGAWTHREED_ANIM_DSMASH,            DOWN_SMASH,                     -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.AttackAirN,      File.MRGAWTHREED_ANIM_AIRN,              NEUTRAL_AERIAL,                       -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.AttackAirF,      File.MRGAWTHREED_ANIM_AIRF,              FORWARD_AERIAL,                       -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.AttackAirB,      File.MRGAWTHREED_ANIM_AIRB,              BACK_AERIAL,                       -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.AttackAirU,      File.MRGAWTHREED_ANIM_AIRU,              UP_AERIAL,                       -1)
    Character.edit_action_parameters(MRGAWTHREED,   Action.AttackAirD,      File.MRGAWTHREED_ANIM_AIRD,              DOWN_AERIAL,                       -1)
    Character.edit_action_parameters(MRGAWTHREED,   0xDC,                   File.MRGAWTHREED_ANIM_JAB3,              JAB_3,                      -1)
    Character.edit_action_parameters(MRGAWTHREED,   0xDD,                   File.MRGAWTHREED_ANIM_ENTRYR,            APPEAR,                     -1)
    Character.edit_action_parameters(MRGAWTHREED,   0xDE,                   File.MRGAWTHREED_ANIM_ENTRYL,            APPEAR,                     -1)
    Character.edit_action_parameters(MRGAWTHREED,   0xDF,                   File.MRGAWTHREED_ANIM_NSPGND,              NEUTRAL_SPECIAL,                 		-1)//0x40000000)
    Character.edit_action_parameters(MRGAWTHREED,   0xE0,                   File.MRGAWTHREED_ANIM_NSPAIR,              NEUTRAL_SPECIAL,                    -1)
    Character.edit_action_parameters(MRGAWTHREED,   0xE1,                   File.MRGAWTHREED_ANIM_USP,               UP_SPECIAL,                        0x50000000)
    Character.edit_action_parameters(MRGAWTHREED,   0xE2,                   File.MRGAWTHREED_ANIM_USP,               UP_SPECIAL,                        0x50000000)
    Character.edit_action_parameters(MRGAWTHREED,   0xE3,                   File.MRGAWTHREED_ANIM_DSPGND,              DOWN_SPECIAL_1,                 		-1)
    Character.edit_action_parameters(MRGAWTHREED,   0xE4,                   File.MRGAWTHREED_ANIM_DSPAIR,              DOWN_SPECIAL_1,                    	-1)
	
    Character.edit_action_parameters(MRGAWTHREED,   0x0D6,                  File.MRGAWTHREED_ANIM_LANDN,     SLOPES,                     -1)
    Character.edit_action_parameters(MRGAWTHREED,   0x0D7,                  File.MRGAWTHREED_ANIM_LANDF,     FAIRLAND,                   -1)
    Character.edit_action_parameters(MRGAWTHREED,   0x0D8,                  File.MRGAWTHREED_ANIM_LANDB,     BAIRLAND,                   -1)
    Character.edit_action_parameters(MRGAWTHREED,   0x0D9,                  File.MRGAWTHREED_ANIM_LANDU,     SLOPES,                     -1)
    Character.edit_action_parameters(MRGAWTHREED,   0x0DA,                  File.MRGAWTHREED_ANIM_LANDD,     DAIRLAND,                   -1)
	
    // Modify Actions           // Action          			// Staling ID   // Main ASM                             // Interrupt/Other ASM          	// Movement/Physics ASM         // Collision ASM
    Character.edit_action(MRGAWTHREED,  Action.Chef,              		-1,             GameAndWatchNSP.main,  			-1,                                     -1,                             -1)
    Character.edit_action(MRGAWTHREED,  Action.ChefAir,              		-1,             GameAndWatchNSP.main,  			-1,                                     -1,                             GameAndWatchNSP.air_collision_)
    Character.edit_action(MRGAWTHREED,  Action.Fire,       			-1,             GameAndWatchUSP.main_air_,  		GameAndWatchUSP.change_direction_,      GameAndWatchUSP.physics_,       GameAndWatchUSP.collision_)
    Character.edit_action(MRGAWTHREED,  Action.FireAir,    			-1,             GameAndWatchUSP.main_air_,  		GameAndWatchUSP.change_direction_,      GameAndWatchUSP.physics_,       GameAndWatchUSP.collision_)
    Character.edit_action(MRGAWTHREED,  Action.JudgeBegin, 			-1,          	GameAndWatchDSP.main,       		-1,					0x800D8BB4,			GameAndWatchDSP.ground_collision_)
    Character.edit_action(MRGAWTHREED,  Action.JudgeBeginAir,   	        -1,             GameAndWatchDSP.main,          		-1,					0x800D90E0,			GameAndWatchDSP.air_collision_)
	
	// Add Action Parameters             // Action Name      // Base Action  // Animation                                   // Moveset Data        // Flags
    Character.add_new_action_params(MRGAWTHREED, DSP_Ground_1,   	 -1,             File.MRGAWTHREED_ANIM_DSPGND,   			DOWN_SPECIAL_1,        -1)
    Character.add_new_action_params(MRGAWTHREED, DSP_Air_1,      	 -1,             File.MRGAWTHREED_ANIM_DSPAIR,   			DOWN_SPECIAL_1,        -1)
    Character.add_new_action_params(MRGAWTHREED, DSP_Ground_2,   	 -1,             File.MRGAWTHREED_ANIM_DSPGND,   			DOWN_SPECIAL_2,        -1)
    Character.add_new_action_params(MRGAWTHREED, DSP_Air_2,      	 -1,             File.MRGAWTHREED_ANIM_DSPAIR,   			DOWN_SPECIAL_2,        -1)
    Character.add_new_action_params(MRGAWTHREED, DSP_Ground_3,   	 -1,             File.MRGAWTHREED_ANIM_DSPGND,   			DOWN_SPECIAL_3,        -1)
    Character.add_new_action_params(MRGAWTHREED, DSP_Air_3,      	 -1,             File.MRGAWTHREED_ANIM_DSPAIR,   			DOWN_SPECIAL_3,        -1)
    Character.add_new_action_params(MRGAWTHREED, DSP_Ground_4,   	 -1,             File.MRGAWTHREED_ANIM_DSPGND,   			DOWN_SPECIAL_4,        -1)
    Character.add_new_action_params(MRGAWTHREED, DSP_Air_4,      	 -1,             File.MRGAWTHREED_ANIM_DSPAIR,   			DOWN_SPECIAL_4,        -1)
    Character.add_new_action_params(MRGAWTHREED, DSP_Ground_5,   	 0xE3,           File.MRGAWTHREED_ANIM_DSPGND,   		        DOWN_SPECIAL_5,        -1)
    Character.add_new_action_params(MRGAWTHREED, DSP_Air_5,      	 0xE4,           File.MRGAWTHREED_ANIM_DSPAIR,   		        DOWN_SPECIAL_5,        -1)
    Character.add_new_action_params(MRGAWTHREED, DSP_Ground_6,   	 -1,             File.MRGAWTHREED_ANIM_DSPGND,   			DOWN_SPECIAL_6,        -1)
    Character.add_new_action_params(MRGAWTHREED, DSP_Air_6,      	 -1,             File.MRGAWTHREED_ANIM_DSPAIR,   			DOWN_SPECIAL_6,        -1)
    Character.add_new_action_params(MRGAWTHREED, DSP_Ground_7,   	 -1,             File.MRGAWTHREED_ANIM_DSPGND,   			DOWN_SPECIAL_7,        -1)
    Character.add_new_action_params(MRGAWTHREED, DSP_Air_7,      	 -1,             File.MRGAWTHREED_ANIM_DSPAIR,   			DOWN_SPECIAL_7,        -1)
    Character.add_new_action_params(MRGAWTHREED, DSP_Ground_8,   	 -1,             File.MRGAWTHREED_ANIM_DSPGND,   			DOWN_SPECIAL_8,        -1)
    Character.add_new_action_params(MRGAWTHREED, DSP_Air_8,      	 -1,             File.MRGAWTHREED_ANIM_DSPAIR,   			DOWN_SPECIAL_8,        -1)
    Character.add_new_action_params(MRGAWTHREED, DSP_Ground_9,   	 -1,             File.MRGAWTHREED_ANIM_DSPGND,   			DOWN_SPECIAL_9,        -1)
    Character.add_new_action_params(MRGAWTHREED, DSP_Air_9,      	 -1,             File.MRGAWTHREED_ANIM_DSPAIR,   			DOWN_SPECIAL_9,        -1)

    Character.add_new_action_params(MRGAWTHREED, USP_Float,      	 -1,             File.MRGAWTHREED_ANIM_USPFLOAT,   			UP_SPECIAL_FLOAT,      0x00000000)
	
    // Add Actions               // Action Name     // Base Action     //Parameters    // Staling ID   	// Main ASM    // Interrupt/Other ASM  // Movement/Physics ASM  // Collision ASM	
    Character.add_new_action(MRGAWTHREED, DSP_Ground_1,	-1, ActionParams.DSP_Ground_1, 0x1E, GameAndWatchDSP.attacks_main_, -1,	0x800D8BB4, GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWTHREED, DSP_Air_1,  	-1, ActionParams.DSP_Air_1,    0x1E, GameAndWatchDSP.attacks_main_, -1, 0x800D90E0, GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAWTHREED, DSP_Ground_2, -1, ActionParams.DSP_Ground_2, 0x1E, GameAndWatchDSP.attacks_main_, -1, 0x800D8BB4, GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWTHREED, DSP_Air_2, 	-1, ActionParams.DSP_Air_2,    0x1E, GameAndWatchDSP.attacks_main_, -1, 0x800D90E0, GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAWTHREED, DSP_Ground_3, -1, ActionParams.DSP_Ground_3, 0x1E, GameAndWatchDSP.attacks_main_, -1, 0x800D8BB4, GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWTHREED, DSP_Air_3, 	-1, ActionParams.DSP_Air_3,    0x1E, GameAndWatchDSP.attacks_main_, -1, 0x800D90E0, GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAWTHREED, DSP_Ground_4, -1, ActionParams.DSP_Ground_4, 0x1E, GameAndWatchDSP.attacks_main_, -1, 0x800D8BB4, GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWTHREED, DSP_Air_4,    -1, ActionParams.DSP_Air_4,    0x1E, GameAndWatchDSP.attacks_main_, -1, 0x800D90E0, GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAWTHREED, DSP_Ground_5, -1, ActionParams.DSP_Ground_5, 0x1E, GameAndWatchDSP.attacks_main_, -1, 0x800D8BB4, GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWTHREED, DSP_Air_5, -1,    ActionParams.DSP_Air_5,    0x1E, GameAndWatchDSP.attacks_main_, -1, 0x800D90E0, GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAWTHREED, DSP_Ground_6, -1, ActionParams.DSP_Ground_6, 0x1E, GameAndWatchDSP.attacks_main_, -1, 0x800D8BB4, GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWTHREED, DSP_Air_6,    -1, ActionParams.DSP_Air_6,    0x1E, GameAndWatchDSP.attacks_main_, -1, 0x800D90E0, GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAWTHREED, DSP_Ground_7, -1, ActionParams.DSP_Ground_7, 0x1E, GameAndWatchDSP.attacks_main_, -1, 0x800D8BB4, GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWTHREED, DSP_Air_7, 	-1, ActionParams.DSP_Air_7,    0x1E, GameAndWatchDSP.attacks_main_, -1, 0x800D90E0, GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAWTHREED, DSP_Ground_8, -1, ActionParams.DSP_Ground_8, 0x1E, GameAndWatchDSP.attacks_main_, -1, 0x800D8BB4, GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWTHREED, DSP_Air_8,    -1, ActionParams.DSP_Air_8,    0x1E, GameAndWatchDSP.attacks_main_, -1, 0x800D90E0, GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAWTHREED, DSP_Ground_9, -1, ActionParams.DSP_Ground_9, 0x1E, GameAndWatchDSP.attacks_main_, -1, 0x800D8BB4, GameAndWatchDSP.ground_collision_)
    Character.add_new_action(MRGAWTHREED, DSP_Air_9,    -1, ActionParams.DSP_Air_9,    0x1E, GameAndWatchDSP.attacks_main_, -1, 0x800D90E0, GameAndWatchDSP.air_collision_)
    Character.add_new_action(MRGAWTHREED, USP_Float,    -1, ActionParams.USP_Float,    -1,   0x00000000, GameAndWatchUSP.float_interrupt_, GameAndWatchUSP.float_physics_, GameAndWatchUSP.float_collision_)
																																			

    //GameAndWatchDSP.air_physics_ for all aerial versions
    // Modify Action Parameters               // Action             // Animation                // Moveset Data             // Flags
	Character.edit_action_parameters(MRGAWTHREED,   0xE3,                 File.MRGAWTHREED_ANIM_DSPGND,              DOWN_SPECIAL_1,                    	-1)
	Character.edit_action_parameters(MRGAWTHREED,   0xE4,                 File.MRGAWTHREED_ANIM_DSPAIR,              DOWN_SPECIAL_1,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xE5,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_1,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xE6,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_1,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xE7,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_2,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xE8,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_2,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xE9,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_3,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xEA,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_3,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xEB,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_4,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xEC,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_4,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xED,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_5,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xEE,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_5,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xEF,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_6,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xF0,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_6,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xF1,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_7,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xF2,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_7,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xF3,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_8,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xF4,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_8,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xF5,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_9,                    	-1)
	//Character.edit_action_parameters(MRGAWTHREED,   0xF6,                 File.MRGAWTHREED_ANIM_DSPA,              DSP_9,                    	-1)

	Character.edit_menu_action_parameters(MRGAWTHREED, 0x0,             File.MRGAWTHREED_ANIM_IDLE,           -1,                        -1)     // CSS IDLE
    Character.edit_menu_action_parameters(MRGAWTHREED, 0x1,             File.MRGAWTHREED_ANIM_VICTORY3,      VICTORY_3,                        -1)     // VICTORY 3
    Character.edit_menu_action_parameters(MRGAWTHREED, 0x2,             File.MRGAWTHREED_ANIM_VICTORY2,      CSS,                  -1)     // CSS
    Character.edit_menu_action_parameters(MRGAWTHREED, 0x3,             File.MRGAWTHREED_ANIM_VICTORY2,      VICTORY_2,                    -1)     // VICTORY 2
    // Character.edit_menu_action_parameters(MRGAWTHREED, 0x4,          File.MRGAWTHREED_ANIM_VICTORY_3,      VICTORY_3,                        -1)     // UNUSED
    Character.edit_menu_action_parameters(MRGAWTHREED, 0x5,             File.MRGAWTHREED_ANIM_CLAP,           CLAP,                       -1)     // NO CONTEST
    // Character.edit_menu_action_parameters(MRGAWTHREED, 0x9,          File.MRGAWTHREED_ANIM_CONTINUE_FALL,  -1,                         -1)
    // Character.edit_menu_action_parameters(MRGAWTHREED, 0xA,          File.MRGAWTHREED_ANIM_CONTINUE_UP,    -1,                         -1)
    Character.edit_menu_action_parameters(MRGAWTHREED, 0xD,             File.MRGAWTHREED_ANIM_1PPOSE,        	 -1,                       -1)     // 1P SCREEN POSE
    Character.edit_menu_action_parameters(MRGAWTHREED, 0xE,             File.MRGAWTHREED_ANIM_1PPOSE,        	 -1,                       -1)     // 1P SCREEN POSE

    // Modify Menu Action Parameters                // Action           // Animation                // Moveset Data             // Flags
    //Character.edit_menu_action_parameters(MRGAWTHREED,      0xE,                File.DRM_1P_CPU_POSE,       0x80000000,                 -1)

    if {defined Character.CHARACTER_ADDED_MRGAW} {
        Character.table_patch_start(variant_original, Character.id.MRGAWTHREED, 0x4)
        dw      Character.id.MRGAW // set Mr. Game & Watch as original character (not Mario, who MRGAWTHREED is a clone of)
        OS.patch_end()
    }

    // Set subroutines for special move initiations.
    Character.table_patch_start(ground_dsp, Character.id.MRGAWTHREED, 0x4)
    dw      GameAndWatchDSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.MRGAWTHREED, 0x4)
    dw      GameAndWatchDSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(ground_usp, Character.id.MRGAWTHREED, 0x4)
    dw      GameAndWatchUSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.MRGAWTHREED, 0x4)
    dw      GameAndWatchUSP.air_initial_
    OS.patch_end()
	
    // Remove entry script (no more warp pipe).
    Character.table_patch_start(entry_script, Character.id.MRGAWTHREED, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.MRGAWTHREED, 0x2)
    dh  FGM.CHANT
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.MRGAWTHREED, 0xC)
    dh 0x25
    OS.patch_end()

	// Set default costumes(id, costume_1, costume_2, costume_3, costume_4, red_team, blue_team, green_team)
    Character.set_default_costumes(Character.id.MRGAWTHREED, 0, 1, 5, 8, 1, 8, 5)
    Teams.add_team_costume(YELLOW, MRGAWTHREED, 0x3)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(MRGAWTHREED, BLACK, RED, ORANGE, YELLOW, LIME, GREEN, CYAN, AZURE, BLUE, PURPLE, MAGENTA, WHITE)

    // Set action strings
    Character.table_patch_start(action_string, Character.id.MRGAWTHREED, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // Insert AI attack options
    include "AI.asm"

    // // Hardcoding for when Mario Clones use Pipes, ensures they face the correct way when entering
    // // TEMP LOCATION
    // scope pipe_turn_enter: {
    //     OS.patch_start(0xBCC40, 0x80142200)
    //     j       pipe_turn_enter
    //     nop                                 // original line 2
    //     _return:
    //     OS.patch_end()

    //     beq     v0, r0, _mario_turn         // modified original line 1, correct turn
    //     addiu   at, r0, Character.id.NDRM   // Poly Dr. Mario ID
    //     beq     v0, at, _mario_turn         // correct turn
    //     addiu   at, r0, Character.id.NWARIO // Poly Wario ID
    //     beq     v0, at, _mario_turn         // correct turn
    //     addiu   at, r0, Character.id.JMARIO // J Mario ID
    //     beq     v0, at, _mario_turn         // correct turn
    //     addiu   at, r0, Character.id.JLUIGI // J Luigi ID
    //     beq     v0, at, _mario_turn         // correct turn
    //     addiu   at, r0, Character.id.MLUIGI // Metal Luigi ID
    //     beq     v0, at, _mario_turn         // correct turn
    //     addiu   at, r0, Character.id.WARIO  // Wario ID
    //     beq     v0, at, _mario_turn         // correct turn
    //     addiu   at, r0, Character.id.GOEMON // Goemon ID
    //     beq     v0, at, _mario_turn         // correct turn
    //     addiu   at, r0, Character.id.EBI    // Ebisumaru ID
    //     beq     v0, at, _mario_turn         // correct turn
    //     addiu   at, r0, Character.id.DRM    // Dr. Mario ID
    //     beq     v0, at, _mario_turn         // correct turn
	// 	addiu   at, r0, Character.id.MRGAWTHREED    // Game And Watch ID
    //     beq     v0, at, _mario_turn         // correct turn
    //     nop
    //     j       _return                     // return
    //     addiu   at, r0, 0x000D              // reinserting in the interest of caution

    //     _mario_turn:
    //     j       0x80142228                  // modified original line 1, routine having Mario properly turn during Pipe animation
    //     addiu   at, r0, 0x000D              // reinserting in the interest of caution
    // }
}

