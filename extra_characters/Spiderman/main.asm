// Spiderman.asm

// This file contains file inclusions, action edits, and assembly for Spider-Man.

include "./SpidermanSpecial.asm"

scope Spiderman {

    insert SPARKLE_, "moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE_)
    insert SHIELDBREAK_, "moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE_)
    insert STUN_, "moveset/STUN.bin"; Moveset.GO_TO(STUN_)

    CUSTOM_GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); Moveset.GO_TO(GRAB)
    CUSTOM_THROW_B:; Moveset.THROW_DATA(THROW_B_DATA); Moveset.GO_TO(THROW_B)
    CUSTOM_THROW_F:; Moveset.THROW_DATA(THROW_F_DATA); Moveset.GO_TO(THROW_F)
    CUSTOM_USP_AIR_THROW:; Moveset.THROW_DATA(USP_AIR_THROW_DATA); Moveset.GO_TO(USP_AIR_THROW)
    CUSTOM_USP_GROUND_THROW:; Moveset.THROW_DATA(USP_GROUND_THROW_DATA); Moveset.GO_TO(USP_GROUND_THROW)
    CUSTOM_USP:; Moveset.THROW_DATA(USP_RELEASE_DATA); Moveset.GO_TO(USP)
    CUSTOM_USP_PULL:; Moveset.THROW_DATA(USP_RELEASE_DATA); Moveset.GO_TO(USP_PULL)

    // @ Description
    // Spider-Man's extra actions
    scope Action {
        constant Jab3(0x0DC)
        constant JabLoopStart(0x0DD)
        constant JabLoop(0x0DE)
        constant JabLoopEnd(0x0DF)
        constant AppearLeft1(0x0E0)
        constant AppearRight1(0x0E1)
        constant AppearLeft2(0x0E2)
        constant AppearRight2(0x0E3)
        constant WebBall(0x0E4)
        constant WebBallAir(0x0E5)
        constant WebSwing(0x0E6)
        constant WebSwingCollide(0x0E7)
        //constant ?(0x0E8)
        constant WebSwingAir(0x0E9)
        //constant ?(0x0EA)
        //constant ?(0x0EB)
        //constant ?(0x0EC)
        //constant ?(0x0ED)
        //constant ?(0x0EE)
        constant WebGlide(0x0EF)
        constant WebGlideAir(0x0F0)
        constant WebGlideAirPull(0x0F1)
        constant WebGlideWallPull(0x0F2)
        constant UltimateWebThrow(0x0F3)
        constant WebGlideEnd(0x0F4)
        constant WebGlideGroundPull(0x0F5)
        constant WebGlideGroundThrow(0x0F6)

        // strings!
        string_0x0DC:; String.insert("Jab3")
        string_0x0DD:; String.insert("JabLoopStart")
        string_0x0DE:; String.insert("JabLoop")
        string_0x0DF:; String.insert("JabLoopEnd")
        string_0x0E0:; String.insert("AppearLeft1")
        string_0x0E1:; String.insert("AppearRight1")
        string_0x0E2:; String.insert("AppearLeft1")
        string_0x0E3:; String.insert("AppearRight2")
        string_0x0E4:; String.insert("WebBall")
        string_0x0E5:; String.insert("WebBallAir")
        string_0x0E6:; String.insert("WebSwing")
        string_0x0E7:; String.insert("WebSwingCollide")
        // string_0x0E8;: String.insert("?")
        string_0x0E9:; String.insert("WebSwingAir")
        // string_0x0EA;: String.insert("?")
        // string_0x0EB;: String.insert("?")
        // string_0x0EC;: String.insert("?")
        // string_0x0ED;: String.insert("?")
        // string_0x0EE;: String.insert("?")
        string_0x0EF:; String.insert("WebGlide")
        string_0x0F0:; String.insert("WebGlideAir")
        string_0x0F1:; String.insert("WebGlideAirPull")
        string_0x0F2:; String.insert("WebGlideWallPull")
        string_0x0F3:; String.insert("UltimateWebThrow")
        string_0x0F4:; String.insert("WebGlideEnd")
        string_0x0F5:; String.insert("WebGlideGroundPull")
        string_0x0F6:; String.insert("WebGlideGroundThrow")

        action_string_table:
        dw Action.COMMON.string_jab3
        dw string_0x0DD
        dw string_0x0DE
        dw string_0x0DF
        dw string_0x0E0
        dw string_0x0E1
        dw string_0x0E2
        dw string_0x0E3
        dw string_0x0E4
        dw string_0x0E5
        dw string_0x0E6
        dw string_0x0E7
        dw 0
        dw string_0x0E9
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw string_0x0EF
        dw string_0x0F0
        dw string_0x0F1
        dw string_0x0F2
        dw string_0x0F3
        dw string_0x0F4
        dw string_0x0F5
        dw string_0x0F6
    }
    
    // Modify Action Parameters           // Action                      // Animation                    // Moveset Data           // Flags
    Character.edit_action_parameters(SPIDERMAN, Action.Entry,                  File.SPIDERMAN_ANIM_IDLE,                  -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, 0x006,                         File.SPIDERMAN_ANIM_IDLE,                  -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Revive2,                File.SPIDERMAN_ANIM_DOWNSTANDD,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ReviveWait,             File.SPIDERMAN_ANIM_IDLE,                  -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Idle,                   File.SPIDERMAN_ANIM_IDLE,                  -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Walk1,                  File.SPIDERMAN_ANIM_WALK1,                 -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Walk2,                  File.SPIDERMAN_ANIM_WALK2,                 -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Walk3,                  File.SPIDERMAN_ANIM_WALK3,                 -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, 0x00E,                         File.SPIDERMAN_ANIM_WALKEND,               -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Dash,                   File.SPIDERMAN_ANIM_DASH,                  -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Run,                    File.SPIDERMAN_ANIM_RUN,                   -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.RunBrake,               File.SPIDERMAN_ANIM_RUNBRAKE,              -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Turn,                   File.SPIDERMAN_ANIM_TURN,                  -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.TurnRun,                File.SPIDERMAN_ANIM_TURNRUN,               -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.JumpSquat,              File.SPIDERMAN_ANIM_LANDING,               -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ShieldJumpSquat,        File.SPIDERMAN_ANIM_LANDING,               -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.JumpF,                  File.SPIDERMAN_ANIM_JUMPF,                 JUMP1,                    -1)
    Character.edit_action_parameters(SPIDERMAN, Action.JumpB,                  File.SPIDERMAN_ANIM_JUMPB,                 JUMP1,                    -1)
    Character.edit_action_parameters(SPIDERMAN, Action.JumpAerialF,            File.SPIDERMAN_ANIM_JUMPAERIALF,           JUMP2,                    -1)
    Character.edit_action_parameters(SPIDERMAN, Action.JumpAerialB,            File.SPIDERMAN_ANIM_JUMPAERIALB,           JUMP2,                    -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Fall,                   File.SPIDERMAN_ANIM_FALL,                  -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.FallAerial,             File.SPIDERMAN_ANIM_FALLAERIAL,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Crouch,                 File.SPIDERMAN_ANIM_CROUCH,                -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.CrouchIdle,             File.SPIDERMAN_ANIM_CROUCHIDLE,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.CrouchEnd,              File.SPIDERMAN_ANIM_CROUCHEND,             -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.LandingLight,           File.SPIDERMAN_ANIM_LANDING,               -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.LandingHeavy,           File.SPIDERMAN_ANIM_LANDING,               -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Pass,                   File.SPIDERMAN_ANIM_PLATDROP,              -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ShieldDrop,             File.SPIDERMAN_ANIM_PLATDROP,              -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Teeter,                 File.SPIDERMAN_ANIM_TEETER,                0x80000000,               -1)
    Character.edit_action_parameters(SPIDERMAN, Action.TeeterStart,            File.SPIDERMAN_ANIM_TEETERSTART,           0x80000000,               -1)
    Character.edit_action_parameters(SPIDERMAN, Action.FallSpecial,            File.SPIDERMAN_ANIM_FALLSPECIAL,           -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.LandingSpecial,         File.SPIDERMAN_ANIM_LANDING,               -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Tornado,                File.SPIDERMAN_ANIM_TUMBLE,                -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.EnterPipe,              File.SPIDERMAN_ANIM_ENTERPIPE,             -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ExitPipe,               File.SPIDERMAN_ANIM_EXITPIPE,              -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ExitPipeWalk,           File.SPIDERMAN_ANIM_EXITPIPEWALK,          -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.CeilingBonk,            File.SPIDERMAN_ANIM_CEILINGBONK,           -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.DownStandD,             File.SPIDERMAN_ANIM_DOWNSTANDD,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.DownStandU,             File.SPIDERMAN_ANIM_DOWNSTANDU,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.TechF,                  File.SPIDERMAN_ANIM_TECHF,                 TECHROLL,                 -1)
    Character.edit_action_parameters(SPIDERMAN, Action.TechB,                  File.SPIDERMAN_ANIM_TECHB,                 TECHROLL,                 -1)
    Character.edit_action_parameters(SPIDERMAN, Action.DownForwardD,           File.SPIDERMAN_ANIM_DOWNFORWARDD,          -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.DownForwardU,           File.SPIDERMAN_ANIM_DOWNFORWARDU,          -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.DownBackD,              File.SPIDERMAN_ANIM_DOWNBACKD,             -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.DownBackU,              File.SPIDERMAN_ANIM_DOWNBACKU,             -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.DownAttackD,            File.SPIDERMAN_ANIM_DOWNATTACKD,           -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.DownAttackU,            File.SPIDERMAN_ANIM_DOWNATTACKU,           -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Tech,                   File.SPIDERMAN_ANIM_TECH,                  TECH,                     -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ClangRecoil,            File.SPIDERMAN_ANIM_CLANGRECOIL,           -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.CliffClimbQuick2,       File.SPIDERMAN_ANIM_CLIFFCLIMBQUICK2,      -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.CliffClimbSlow2,        File.SPIDERMAN_ANIM_CLIFFCLIMBSLOW2,       -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.CliffAttackQuick2,      File.SPIDERMAN_ANIM_CLIFFATTACKQUICK2,     CLIFFATKQUICK,            -1)
    Character.edit_action_parameters(SPIDERMAN, Action.CliffAttackSlow2,       File.SPIDERMAN_ANIM_CLIFFATTACKSLOW2,      CLIFFATKSLOW,             -1)
    Character.edit_action_parameters(SPIDERMAN, Action.CliffEscapeQuick2,      File.SPIDERMAN_ANIM_CLIFFESCAPEQUICK2,     -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.CliffEscapeSlow2,       File.SPIDERMAN_ANIM_CLIFFESCAPESLOW2,      -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.LightItemPickup,        File.SPIDERMAN_ANIM_LIGHTITEMPICKUP,       -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.HeavyItemPickup,        File.SPIDERMAN_ANIM_HEAVYITEMPICKUP,       -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemDrop,               File.SPIDERMAN_ANIM_ITEMDROP,              -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemThrowDash,          File.SPIDERMAN_ANIM_ITEMTHROWDASH,         -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemThrowF,             File.SPIDERMAN_ANIM_ITEMTHROWF,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemThrowB,             File.SPIDERMAN_ANIM_ITEMTHROWF,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemThrowU,             File.SPIDERMAN_ANIM_ITEMTHROWU,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemThrowD,             File.SPIDERMAN_ANIM_ITEMTHROWD,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemThrowSmashF,        File.SPIDERMAN_ANIM_ITEMTHROWF,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemThrowSmashB,        File.SPIDERMAN_ANIM_ITEMTHROWF,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemThrowSmashU,        File.SPIDERMAN_ANIM_ITEMTHROWU,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemThrowSmashD,        File.SPIDERMAN_ANIM_ITEMTHROWD,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemThrowAirF,          File.SPIDERMAN_ANIM_ITEMTHROWAIRF,         -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemThrowAirB,          File.SPIDERMAN_ANIM_ITEMTHROWAIRF,         -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemThrowAirU,          File.SPIDERMAN_ANIM_ITEMTHROWAIRU,         -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemThrowAirD,          File.SPIDERMAN_ANIM_ITEMTHROWAIRD,         -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemThrowAirSmashF,     File.SPIDERMAN_ANIM_ITEMTHROWAIRF,         -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemThrowAirSmashB,     File.SPIDERMAN_ANIM_ITEMTHROWAIRF,         -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemThrowAirSmashU,     File.SPIDERMAN_ANIM_ITEMTHROWAIRU,         -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ItemThrowAirSmashD,     File.SPIDERMAN_ANIM_ITEMTHROWAIRD,         -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.HeavyItemThrowF,        File.SPIDERMAN_ANIM_HEAVYITEMTHROW,        -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.HeavyItemThrowB,        File.SPIDERMAN_ANIM_HEAVYITEMTHROW,        -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.HeavyItemThrowSmashF,   File.SPIDERMAN_ANIM_HEAVYITEMTHROW,        -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.HeavyItemThrowSmashB,   File.SPIDERMAN_ANIM_HEAVYITEMTHROW,        -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.BeamSwordNeutral,       File.SPIDERMAN_ANIM_ITEMNEUTRAL,           -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.BeamSwordTilt,          File.SPIDERMAN_ANIM_ITEMTILT,              -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.BeamSwordSmash,         File.SPIDERMAN_ANIM_ITEMSMASH,             -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.BeamSwordDash,          File.SPIDERMAN_ANIM_ITEMDASH,              -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.BatNeutral,             File.SPIDERMAN_ANIM_ITEMNEUTRAL,           -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.BatTilt,                File.SPIDERMAN_ANIM_ITEMTILT,              -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.BatSmash,               File.SPIDERMAN_ANIM_ITEMSMASH,             -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.BatDash,                File.SPIDERMAN_ANIM_ITEMDASH,              -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.FanNeutral,             File.SPIDERMAN_ANIM_ITEMNEUTRAL,           -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.FanTilt,                File.SPIDERMAN_ANIM_ITEMTILT,              -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.FanSmash,               File.SPIDERMAN_ANIM_ITEMSMASH,             -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.FanDash,                File.SPIDERMAN_ANIM_ITEMDASH,              -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.StarRodNeutral,         File.SPIDERMAN_ANIM_ITEMNEUTRAL,           -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.StarRodTilt,            File.SPIDERMAN_ANIM_ITEMTILT,              -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.StarRodSmash,           File.SPIDERMAN_ANIM_ITEMSMASH,             -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.StarRodDash,            File.SPIDERMAN_ANIM_ITEMDASH,              -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.RayGunShoot,            File.SPIDERMAN_ANIM_ITEMSHOOT,             -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.RayGunShootAir,         File.SPIDERMAN_ANIM_ITEMSHOOTAIR,          -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.FireFlowerShoot,        File.SPIDERMAN_ANIM_ITEMSHOOT,             -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.FireFlowerShootAir,     File.SPIDERMAN_ANIM_ITEMSHOOTAIR,          -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.HammerIdle,             File.SPIDERMAN_ANIM_HAMMERIDLE,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.HammerWalk,             File.SPIDERMAN_ANIM_HAMMERMOVE,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.HammerTurn,             File.SPIDERMAN_ANIM_HAMMERMOVE,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.HammerJumpSquat,        File.SPIDERMAN_ANIM_HAMMERMOVE,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.HammerAir,              File.SPIDERMAN_ANIM_HAMMERMOVE,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.HammerLanding,          File.SPIDERMAN_ANIM_HAMMERMOVE,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ShieldOn,               File.SPIDERMAN_ANIM_SHIELDON,              SHIELD_ON,                -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ShieldOff,              File.SPIDERMAN_ANIM_SHIELDOFF,             SHIELD_OFF,               -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ShieldBreak,            -1,                                        SHIELDBREAK_,             -1)
    Character.edit_action_parameters(SPIDERMAN, Action.RollF,                  File.SPIDERMAN_ANIM_ROLLF,                 -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.RollB,                  File.SPIDERMAN_ANIM_ROLLB,                 -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.StunStartD,             File.SPIDERMAN_ANIM_DOWNSTANDD,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.StunStartU,             File.SPIDERMAN_ANIM_DOWNSTANDU,            -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Stun,                   File.SPIDERMAN_ANIM_STUN,                  STUN_,                    -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Sleep,                  File.SPIDERMAN_ANIM_STUN,                  -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Grab,                   File.SPIDERMAN_ANIM_GRAB,                  CUSTOM_GRAB,                     0x10000000)
    Character.edit_action_parameters(SPIDERMAN, Action.GrabPull,               File.SPIDERMAN_ANIM_GRABPULL,              GRAB_PULL,                0x10000000)
    Character.edit_action_parameters(SPIDERMAN, Action.ThrowF,                 File.SPIDERMAN_ANIM_THROWF,                CUSTOM_THROW_F,                  -1)
    Character.edit_action_parameters(SPIDERMAN, Action.ThrowB,                 File.SPIDERMAN_ANIM_THROWB,                CUSTOM_THROW_B,                  -1)
    Character.edit_action_parameters(SPIDERMAN, Action.CapturePulled,          File.SPIDERMAN_ANIM_CAPTUREPULLED,         -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.EggLayPulled,           File.SPIDERMAN_ANIM_CAPTUREPULLED,         -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.EggLay,                 File.SPIDERMAN_ANIM_IDLE,                  -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Taunt,                  File.SPIDERMAN_ANIM_TAUNT,                 TAUNT,                    -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Jab1,                   File.SPIDERMAN_ANIM_JAB1,                  JAB1,                     -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Jab2,                   File.SPIDERMAN_ANIM_JAB2,                  JAB2,                     -1)
    Character.edit_action_parameters(SPIDERMAN, Action.Jab3,                   File.SPIDERMAN_ANIM_JAB3,                  JAB3,                      0x40000000)
    Character.edit_action_parameters(SPIDERMAN, Action.JabLoopStart,           File.SPIDERMAN_ANIM_JAB1,                  JAB1,                     0)
    Character.edit_action_parameters(SPIDERMAN, Action.JabLoop,                File.SPIDERMAN_ANIM_JAB2,                  JAB2,                     0)
    Character.edit_action_parameters(SPIDERMAN, Action.DashAttack,             File.SPIDERMAN_ANIM_DASHATTACK,            DASH_ATTACK,              -1)
    Character.edit_action_parameters(SPIDERMAN, Action.FTiltHigh,              0,                              0x80000000,               0)
    Character.edit_action_parameters(SPIDERMAN, Action.FTiltMidHigh,           0,                              0x80000000,               0)
    Character.edit_action_parameters(SPIDERMAN, Action.FTilt,                  File.SPIDERMAN_ANIM_FTILT,                 FORWARD_TILT,             -1)
    Character.edit_action_parameters(SPIDERMAN, Action.FTiltMidLow,            0,                              0x80000000,               0)
    Character.edit_action_parameters(SPIDERMAN, Action.FTiltLow,               0,                              0x80000000,               0)
    Character.edit_action_parameters(SPIDERMAN, Action.UTilt,                  File.SPIDERMAN_ANIM_UTILT,                 UP_TILT,                  -1)
    Character.edit_action_parameters(SPIDERMAN, Action.DTilt,                  File.SPIDERMAN_ANIM_DTILT,                 DOWN_TILT,                -1)
    Character.edit_action_parameters(SPIDERMAN, Action.FSmashHigh,             0,                              0x80000000,               0)
    Character.edit_action_parameters(SPIDERMAN, Action.FSmashMidHigh,          0,                              0x80000000,               0)
    Character.edit_action_parameters(SPIDERMAN, Action.FSmash,                 File.SPIDERMAN_ANIM_FSMASH,                FORWARD_SMASH,            -1)
    Character.edit_action_parameters(SPIDERMAN, Action.FSmashMidLow,           0,                              0x80000000,               0)
    Character.edit_action_parameters(SPIDERMAN, Action.FSmashLow,              0,                              0x80000000,               0)
    Character.edit_action_parameters(SPIDERMAN, Action.USmash,                 File.SPIDERMAN_ANIM_USMASH,                UP_SMASH,                 -1)
    Character.edit_action_parameters(SPIDERMAN, Action.DSmash,                 File.SPIDERMAN_ANIM_DSMASH,                DOWN_SMASH,               -1)
    Character.edit_action_parameters(SPIDERMAN, Action.AttackAirN,             File.SPIDERMAN_ANIM_ATTACKAIRN,            NEUTRAL_AERIAL,           -1)
    Character.edit_action_parameters(SPIDERMAN, Action.AttackAirF,             File.SPIDERMAN_ANIM_ATTACKAIRF,            FORWARD_AERIAL,           -1)
    Character.edit_action_parameters(SPIDERMAN, Action.AttackAirB,             File.SPIDERMAN_ANIM_ATTACKAIRB,            BACK_AERIAL,              -1)
    Character.edit_action_parameters(SPIDERMAN, Action.AttackAirU,             File.SPIDERMAN_ANIM_ATTACKAIRU,            UP_AERIAL,                -1)
    Character.edit_action_parameters(SPIDERMAN, Action.AttackAirD,             File.SPIDERMAN_ANIM_ATTACKAIRD,            DOWN_AERIAL,              -1)
    Character.edit_action_parameters(SPIDERMAN, Action.LandingAirF,            File.SPIDERMAN_ANIM_LANDINGAIRF,           FORWARD_AERIAL_LANDING,   -1)
    Character.edit_action_parameters(SPIDERMAN, Action.LandingAirB,            File.SPIDERMAN_ANIM_LANDINGAIRB,           -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.LandingAirX,            File.SPIDERMAN_ANIM_LANDING,               -1,                       -1)
    Character.edit_action_parameters(SPIDERMAN, Action.AppearLeft1,            File.SPIDERMAN_ANIM_ENTRY_1_LEFT,          ENTRY_1,                  0x40000008)
	Character.edit_action_parameters(SPIDERMAN, Action.AppearRight1,           File.SPIDERMAN_ANIM_ENTRY_1_RIGHT,         ENTRY_1,                  0x40000008)
	Character.edit_action_parameters(SPIDERMAN, Action.AppearLeft2,            File.SPIDERMAN_ANIM_ENTRY_2_LEFT,          ENTRY_2,                  0x40000008)
	Character.edit_action_parameters(SPIDERMAN, Action.AppearRight2,           File.SPIDERMAN_ANIM_ENTRY_2_RIGHT,         ENTRY_2,                  0x40000008)
    Character.edit_action_parameters(SPIDERMAN, Action.WebBall,                File.SPIDERMAN_ANIM_NSP_GROUND,            NSP_GROUND,               -1)
    Character.edit_action_parameters(SPIDERMAN, Action.WebBallAir,             File.SPIDERMAN_ANIM_NSP_AIR,               NSP_AIR,                  -1)
    Character.edit_action_parameters(SPIDERMAN, Action.WebSwing,               File.SPIDERMAN_ANIM_DSP_GROUND,            DSP,                      0x40000000)          //DSP_Ground
    Character.edit_action_parameters(SPIDERMAN, 0xE7,                          0,                              0x80000000,               0)          //DSP_Collide
    Character.edit_action_parameters(SPIDERMAN, 0xE8,                          0,                              0x80000000,               0)          //DSP_Land
    Character.edit_action_parameters(SPIDERMAN, Action.WebSwingAir,            File.SPIDERMAN_ANIM_DSP_AIR,               DSP,                      -1)          //DSP_Air
    Character.edit_action_parameters(SPIDERMAN, 0xEA,                          0,                              0x80000000,               0)          
    Character.edit_action_parameters(SPIDERMAN, 0xEB,                          0,                              0x80000000,               0)          //Originally USP starts here, however it seemed easier to set it up as new actions like Goemon DSP.
    Character.edit_action_parameters(SPIDERMAN, 0xEC,                          0,                              0x80000000,               0)
    Character.edit_action_parameters(SPIDERMAN, 0xED,                          0,                              0x80000000,               0)
    Character.edit_action_parameters(SPIDERMAN, 0xEE,                          0,                              0x80000000,               0)

    // Modify Actions            // Action                      // Staling ID   // Main ASM                   // Interrupt/Other ASM          // Movement/Physics ASM       // Collision ASM
	Character.edit_action(SPIDERMAN,   Action.WebBall,                -1,             SpidermanNSP.main,  	      -1,                             -1,                           -1)
	Character.edit_action(SPIDERMAN,   Action.WebBallAir,             -1,             SpidermanNSP.main,  	      -1,                             SpidermanNSP.physics_,        SpidermanNSP.air_collision_)
    Character.edit_action(SPIDERMAN,   Action.WebSwing,               -1,             -1,  		                  SpidermanDSP.change_direction_, SpidermanDSP.ground_physics_, SpidermanDSP.ground_collision_)
    Character.edit_action(SPIDERMAN,   Action.WebSwingAir,            -1,             -1,                           SpidermanDSP.change_direction_, 0x800D93E4,                 SpidermanDSP.air_collision_)

    // Add Action Parameters             // Action Name      // Base Action  // Animation                   // Moveset Data        // Flags
    Character.add_new_action_params(SPIDERMAN, USPGround,          -1,             File.SPIDERMAN_ANIM_USP_GROUND,           CUSTOM_USP,                   0x10000000)
    Character.add_new_action_params(SPIDERMAN, USPAir,             -1,             File.SPIDERMAN_ANIM_USP_AIR,              CUSTOM_USP,                   0x10000000)
    Character.add_new_action_params(SPIDERMAN, USPAirPull,         -1,             File.SPIDERMAN_ANIM_USP_AIR_GRABPULL,     CUSTOM_USP_PULL,              0x50000000)
    Character.add_new_action_params(SPIDERMAN, USPAAttack,         -1,             File.SPIDERMAN_ANIM_USP_AIR_GRABTHROW,    CUSTOM_USP_AIR_THROW,         0x10000000)
    Character.add_new_action_params(SPIDERMAN, USPEnd,             -1,             File.SPIDERMAN_ANIM_USP_WALLEND,          0x80000000,            0x00000000)
    Character.add_new_action_params(SPIDERMAN, USPGroundPull,      -1,             File.SPIDERMAN_ANIM_USP_GROUND_GRABPULL,  CUSTOM_USP_PULL,              0x10000000)
    Character.add_new_action_params(SPIDERMAN, USPGAttack,         -1,             File.SPIDERMAN_ANIM_USP_GROUND_GRABTHROW, CUSTOM_USP_GROUND_THROW,      0x50000000)

    // Add Actions                // Action Name     // Base Action  //Parameters                    // Staling ID   // Main ASM                        // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(SPIDERMAN, USPGround,         -1,             ActionParams.USPGround,         0x11,           SpidermanUSP.main_,                SpidermanUSP.change_direction_, 0x800D8BB4,                         SpidermanUSP.ground_collision_)
    Character.add_new_action(SPIDERMAN, USPAir,            -1,             ActionParams.USPAir,            0x11,           SpidermanUSP.main_,                SpidermanUSP.change_direction_, SpidermanUSP.air_physics_,          SpidermanUSP.air_collision_)
    Character.add_new_action(SPIDERMAN, USPAirPull,        -1,             ActionParams.USPAirPull,        0x11,           SpidermanUSP.air_pull_main_,       0,                              0x800D93E4,                         SpidermanUSP.shared_air_collision_)
    Character.add_new_action(SPIDERMAN, USPAirWallPull,    -1,             ActionParams.USPAirPull,        0x11,           SpidermanUSP.wall_pull_main_,      0,                              0x800D93E4,                         SpidermanUSP.shared_air_collision_)
    Character.add_new_action(SPIDERMAN, USPAAttack,        -1,             ActionParams.USPAAttack,        0x11,           0x8014A0C0,                        0,                              SpidermanUSP.throw_air_physics_,    SpidermanUSP.throw_air_collision_)
    Character.add_new_action(SPIDERMAN, USPEnd,            -1,             ActionParams.USPEnd,            0x11,           0x800D94E8,                        0,                              0x800D9160,                         0x800DE99C)
    Character.add_new_action(SPIDERMAN, USPGroundPull,     -1,             ActionParams.USPGroundPull,     0x11,           SpidermanUSP.ground_pull_main_,    0,                              0x800D8BB4,                         SpidermanUSP.shared_ground_collision_)
    Character.add_new_action(SPIDERMAN, USPGAttack,        -1,             ActionParams.USPGAttack,        0x11,           0x8014A0C0,                        0,                              0x800D93E4,                         SpidermanUSP.throw_air_collision_)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(SPIDERMAN,   0x0,               File.SPIDERMAN_ANIM_IDLE,              -1,                         -1)          // CSS Idle
    Character.edit_menu_action_parameters(SPIDERMAN,   0x1,               File.SPIDERMAN_ANIM_VICTORY_1,         VICTORY_1,                  -1)          // Victory1
    Character.edit_menu_action_parameters(SPIDERMAN,   0x2,               File.SPIDERMAN_ANIM_VICTORY_2,         VICTORY_2,                  -1)          // Victory2
    Character.edit_menu_action_parameters(SPIDERMAN,   0x3,               File.SPIDERMAN_ANIM_VICTORY_3,         VICTORY_3,                  -1)          // Victory3
    Character.edit_menu_action_parameters(SPIDERMAN,   0x4,               File.SPIDERMAN_ANIM_VICTORY_1,         VICTORY_1,                  -1)          // CSS Select
    Character.edit_menu_action_parameters(SPIDERMAN,   0xD,               File.SPIDERMAN_ANIM_1P_POSE,           -1,                         -1)          // 1P Mode Pose
    Character.edit_menu_action_parameters(SPIDERMAN,   0xE,               File.SPIDERMAN_ANIM_CPU_POSE,          -1,                         -1)          // CPU Pose
    Character.edit_menu_action_parameters(SPIDERMAN,   0x5,               File.SPIDERMAN_ANIM_CLAP,              -1,                         -1)
    Character.edit_menu_action_parameters(SPIDERMAN,   0x9,               File.SPIDERMAN_ANIM_CONTINUEFALL,      -1,                         -1)
    Character.edit_menu_action_parameters(SPIDERMAN,   0xA,               File.SPIDERMAN_ANIM_CONTINUEUP,        -1,                         -1)

    // Set action strings
    Character.table_patch_start(action_string, Character.id.SPIDERMAN, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    Character.table_patch_start(ground_usp, Character.id.SPIDERMAN, 0x4)
    dw      SpidermanUSP.ground_initial_
    OS.patch_end()
	
    Character.table_patch_start(air_usp, Character.id.SPIDERMAN, 0x4)
    dw      SpidermanUSP.air_initial_
    OS.patch_end()
	
    Character.table_patch_start(ground_dsp, Character.id.SPIDERMAN, 0x4)
    dw      SpidermanDSP.ground_initial_
    OS.patch_end()
	
    Character.table_patch_start(air_dsp, Character.id.SPIDERMAN, 0x4)
    dw      SpidermanDSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(rapid_jab, Character.id.SPIDERMAN, 0x4)
    dw      Character.rapid_jab.DISABLED        // disable rapid jab
    OS.patch_end()

    // Set crowd chant FGM to none
    Character.table_patch_start(crowd_chant_fgm, Character.id.SPIDERMAN, 0x2)
    dh  0x02B7
    OS.patch_end()

    // Use Mario's initial/grounded script.
    Character.table_patch_start(initial_script, Character.id.SPIDERMAN, 0x4)
    dw 0x800D7DCC
    OS.patch_end()
	
    Character.table_patch_start(grounded_script, Character.id.SPIDERMAN, 0x4)
    dw 0x800DE428
    OS.patch_end()

    // Remove entry script (no Blue Falcon).
    Character.table_patch_start(entry_script, Character.id.SPIDERMAN, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.SPIDERMAN, 0, 1, 2, 3, 0, 4, 2)
    Teams.add_team_costume(YELLOW, SPIDERMAN, 0x6)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(SPIDERMAN, RED, CYAN, GREEN, BLACK, BLUE, BLUE, YELLOW, WHITE)

    // Set Kirby star damage
    Character.table_patch_start(kirby_inhale_struct, 0x8, Character.id.SPIDERMAN, 0xC)
    dw Character.kirby_inhale_struct.star_damage.FALCON
    OS.patch_end()
}
