include "./MetaKnightSpecial.asm"
include "./CPU.asm"

// This file contains file inclusions, action edits, and assembly for METAKNIGHT.

scope MetaKnight {
    THROW_B:; Moveset.THROW_DATA(throwBData); Moveset.GO_TO(throwB)
    THROW_F:; Moveset.THROW_DATA(throwFData); Moveset.GO_TO(throwF)
    GRAB_:  ; Moveset.THROW_DATA(throwFData); Moveset.GO_TO(grab)

    insert SPARKLE_, "moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE_)
    insert SHIELDBREAK_, "moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE_)
    insert STUN_, "moveset/STUN.bin"; Moveset.GO_TO(STUN_)
    insert SLEEP_, "moveset/SLEEP.bin"; Moveset.GO_TO(SLEEP_)
	
    insert run_,"moveset/run.bin"; Moveset.GO_TO(run_) // loops
    insert IDLE_,"moveset/IDLE.bin"; Moveset.GO_TO(IDLE_) // loops

    // LIGHT_ITEM_PICKUP:; dw 0xBC000003;  dw 0x08000004; dw 0x3800009D; dw 0x58000001; dw 0
    // ITEM_DROP:; dw 0xBC000003;  dw 0x08000008; dw 0x54000001; dw 0
    // ITEM_THROW_DASH:; dw 0x08000004; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_DASH); dw 0
    // ITEM_THROW_F:; dw 0xBC000003; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    // ITEM_THROW_B:; dw 0xBC000003; dw 0x60000008; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    // ITEM_THROW_U:; dw 0xBC000003; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    // ITEM_THROW_D:; dw 0xBC000003; dw 0x08000008; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    // ITEM_THROW_SMASH_F:; dw 0xBC000003; dw 0x0800000A; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    // ITEM_THROW_SMASH_B:; dw 0xBC000003; dw 0x60000008; dw 0x0800000A; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    // ITEM_THROW_SMASH_U:; dw 0xBC000003; dw 0x0800000A; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    // ITEM_THROW_SMASH_D:; dw 0xBC000003; dw 0x08000008; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    // ITEM_THROW_AIR_F:; dw 0xBC000003; dw 0x08000009; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    // ITEM_THROW_AIR_B:; dw 0xBC000003; dw 0x60000004; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    // ITEM_THROW_AIR_U:; dw 0xBC000003; dw 0x0800000A; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    // ITEM_THROW_AIR_D:; dw 0xBC000003; dw 0x08000008; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    // ITEM_THROW_AIR_SMASH_F:; dw 0xBC000003; dw 0x08000009; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_AIR_SMASH_FB); dw 0
    // ITEM_THROW_AIR_SMASH_B:; dw 0xBC000003; dw 0x60000006; dw 0x08000009; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_AIR_SMASH_FB); dw 0
    // ITEM_THROW_AIR_SMASH_U:; dw 0xBC000003; dw 0x08000009; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_SMASH_UD); dw 0
    // ITEM_THROW_AIR_SMASH_D:; dw 0xBC000003; dw 0x08000009; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_SMASH_UD); dw 0
    // HEAVY_ITEM_PICKUP:; dw 0xBC000003;  dw 0x08000004; dw 0x58000001; dw 0
    // HEAVY_ITEM_THROW_F:; dw 0xBC000003;  dw 0x08000014; dw 0x54000001; dw 0
    // HEAVY_ITEM_THROW_B:; dw 0xBC000003;  dw 0x08000014; dw 0x54000001; dw 0
    // HEAVY_ITEM_THROW_SMASH_F:; dw 0xBC000003;  dw 0x08000014; dw 0x50000000; dw 0x54000001; dw 0
    // HEAVY_ITEM_THROW_SMASH_B:; dw 0xBC000003;  dw 0x08000014; dw 0x50000000; dw 0x54000001; dw 0
    BEAMSWORD_JAB:; dw 0xBC000003; dw 0x08000003; dw 0xCC040000; dw 0x08000004; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_JAB); dw 0x04000002; dw 0x18000000; dw 0x04000003; dw 0xCC03FFFF; dw 0
    BEAMSWORD_TILT:; dw 0xBC000003; dw 0x6000000A; dw 0x08000006; dw 0xBC000004; dw 0xCC040000; dw 0x08000008; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_TILT); dw 0x04000001; dw 0x18000000; dw 0x04000004; dw 0xCC03FFFF; dw 0x08000026; dw 0xBC000003; dw 0
    BEAMSWORD_SMASH:; dw 0xBC000003; dw 0x0800000D; dw 0xCC040000; dw 0xBC000004; dw 0x50000000; dw 0x0800000F; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_SMASH); dw 0x04000007; dw 0x18000000; dw 0x04000002; dw 0xCC03FFFF; dw 0x0800002D; dw 0xBC000003; dw 0
    BEAMSWORD_DASH:; dw 0xBC000004; dw 0xCC040000; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_DASH); dw 0x04000003; dw 0xCC03FFFF; dw 0x04000005; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    BAT_JAB:; dw 0xBC000003; dw 0x08000004; Moveset.SUBROUTINE(Moveset.shared.BAT_JAB); dw 0x04000002; dw 0x18000000; dw 0
    BAT_TILT:; dw 0xBC000003; dw 0x08000004; dw 0xBC000004; dw 0x08000008; Moveset.SUBROUTINE(Moveset.shared.BAT_TILT); dw 0x04000001; dw 0x18000000; dw 0x08000026; dw 0xBC000003; dw 0
    BAT_SMASH:; dw 0xC4000007; dw 0xBC000003; dw 0xB1300028; dw 0x08000003; dw 0xBC000004; dw 0x50000000; dw 0x0800000F; Moveset.SUBROUTINE(Moveset.shared.BAT_SMASH); dw 0x04000007; dw 0x18000000; dw 0x0800002D; dw 0xBC000003; dw 0
    BAT_DASH:; dw 0xBC000004; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.BAT_DASH); dw 0x04000008; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    FAN_JAB:; dw 0xBC000003; dw 0x08000004; Moveset.SUBROUTINE(Moveset.shared.FAN_JAB); dw 0x04000002; dw 0x18000000; dw 0
    FAN_TILT:; dw 0xBC000003; dw 0x08000004; dw 0xBC000004; dw 0x08000008; Moveset.SUBROUTINE(Moveset.shared.FAN_TILT); dw 0x04000001; dw 0x18000000; dw 0x08000026; dw 0xBC000003; dw 0
    FAN_SMASH:; dw 0xBC000003; dw 0x08000003; dw 0xBC000004; dw 0x50000000; dw 0x0800000F; Moveset.SUBROUTINE(Moveset.shared.FAN_SMASH); dw 0x04000007; dw 0x18000000; dw 0x0800002D; dw 0xBC000003; dw 0
    FAN_DASH:; dw 0xBC000004; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.FAN_DASH); dw 0x04000008; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    STARROD_JAB:; dw 0xBC000003; dw 0xB12C0010; dw 0x08000004; Moveset.SUBROUTINE(Moveset.shared.STARROD_JAB); dw 0x04000002; dw 0x18000000; dw 0
    STARROD_TILT:; dw 0xBC000003; dw 0x08000004; dw 0xBC000004; dw 0xB12C000D; dw 0x08000008; Moveset.SUBROUTINE(Moveset.shared.STARROD_TILT); dw 0x54000001; dw 0x04000001; dw 0x18000000;  dw 0x08000026; dw 0xBC000003; dw 0
    STARROD_SMASH:; dw 0xBC000003; dw 0x08000003; dw 0xBC000004; dw 0xB12C0024; dw 0x50000000; dw 0x0800000F; Moveset.SUBROUTINE(Moveset.shared.STARROD_SMASH); dw 0x04000002; dw 0x54000002; dw 0x04000005; dw 0x18000000; dw 0x0800002D; dw 0xBC000003; dw 0
    STARROD_DASH:; dw 0xBC000004; dw 0xB12C0014; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.STARROD_DASH); dw 0x04000008; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    HAMMER:; dw 0xC4000007; dw 0xBC000004; Moveset.SUBROUTINE(Moveset.shared.HAMMER); dw 0x04000010; dw 0x18000000; Moveset.GO_TO(HAMMER)
    SHOOT:; dw 0x08000009; dw 0x54000001; dw 0;
    DOWN_BOUNCE:; dw 0xAC100001; Moveset.GO_TO(Moveset.shared.DOWN_BOUNCE)

    scope Action: {
        constant USP(0x0DC)
        constant USP_AIR_START(0x0DD)
        constant USP_AIR(0x0DE)

        constant TORNADO_START(0x0E6)
        constant TORNADO_LOOP(0x0E7)
        constant TORNADO_END(0x0E8)
        constant TORNADO_END_AIR(0x0EA)
    }

    // Modify Action Parameters: Action, Animation, Moveset Data, Flags
    Character.edit_action_parameters(METAKNIGHT, Action.Idle, File.METAKNIGHT_ANIM_IDLE, IDLE_, 0x00000000)
    Character.edit_action_parameters(METAKNIGHT, Action.Turn, File.METAKNIGHT_ANIM_TURN, turn, 0x00000000)

    Character.edit_action_parameters(METAKNIGHT, Action.DeadU, File.METAKNIGHT_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.EggLay, File.METAKNIGHT_ANIM_IDLE, -1, -1)

    Character.edit_action_parameters(METAKNIGHT, Action.Walk1, File.METAKNIGHT_ANIM_WALK1, -1, 0x00000000)
    Character.edit_action_parameters(METAKNIGHT, Action.Walk2, File.METAKNIGHT_ANIM_WALK2, -1, 0x00000000)
    Character.edit_action_parameters(METAKNIGHT, Action.Walk3, File.METAKNIGHT_ANIM_WALK3, -1, 0x00000000)

    Character.edit_action_parameters(METAKNIGHT, Action.Dash, File.METAKNIGHT_ANIM_DASH, -1, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.Run, File.METAKNIGHT_ANIM_RUN, run_, 0x0F000000)

    Character.edit_action_parameters(METAKNIGHT, Action.Crouch, File.METAKNIGHT_ANIM_CROUCHSTART, eyesUp, 0x00000000)
    Character.edit_action_parameters(METAKNIGHT, Action.CrouchIdle, File.METAKNIGHT_ANIM_CROUCHWAIT, eyesUp, 0x00000000)
    Character.edit_action_parameters(METAKNIGHT, Action.CrouchEnd, File.METAKNIGHT_ANIM_CROUCHEND, -1, 0x00000000)
    
    Character.edit_action_parameters(METAKNIGHT, Action.TurnRun, File.METAKNIGHT_ANIM_TURNRUN, turnRun, 0x4F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.RunBrake, File.METAKNIGHT_ANIM_RUNBRAKE, -1, 0x0F000000)

    Character.edit_action_parameters(METAKNIGHT, Action.Fall, File.METAKNIGHT_ANIM_FALL, -1, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.FallAerial, File.METAKNIGHT_ANIM_FALLAERIAL, -1, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.FallSpecial, File.METAKNIGHT_ANIM_FALLSPECIAL, -1, 0x0F000000)

    Character.edit_action_parameters(METAKNIGHT, Action.Grab, File.METAKNIGHT_ANIM_GRAB, GRAB_, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.GrabPull, File.METAKNIGHT_ANIM_GRABPULL, eyesLeft, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.GrabWait, File.METAKNIGHT_ANIM_GRABPULL, eyesLeft, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.ThrowF, File.METAKNIGHT_ANIM_THROWF, THROW_F, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.ThrowB, File.METAKNIGHT_ANIM_THROWB, THROW_B, 0x10000000)

    Character.edit_action_parameters(METAKNIGHT, Action.DashAttack, File.METAKNIGHT_ANIM_ATTACKDASH, attackDash, 0x4F000000)

    Character.edit_action_parameters(METAKNIGHT, Action.FTilt, File.METAKNIGHT_ANIM_TILTF, -1, 0x50000000)
    Character.edit_action_parameters(METAKNIGHT, Action.FTiltHigh, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(METAKNIGHT, Action.FTiltLow, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(METAKNIGHT, Action.UTilt, File.METAKNIGHT_ANIM_TILTU, tiltU, 0x00000000)
    Character.edit_action_parameters(METAKNIGHT, Action.DTilt, File.METAKNIGHT_ANIM_TILTD, tiltD, 0x40000000)

    Character.edit_action_parameters(METAKNIGHT, Action.AttackAirN, File.METAKNIGHT_ANIM_AIRN, airN, 0x1F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.AttackAirF, File.METAKNIGHT_ANIM_AIRF, airF, 0x1F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.AttackAirB, File.METAKNIGHT_ANIM_AIRB, airB, 0x1F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.AttackAirU, File.METAKNIGHT_ANIM_AIRU, airU, 0x1F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.AttackAirD, File.METAKNIGHT_ANIM_AIRD, airD, 0x1F000000)

    Character.edit_action_parameters(METAKNIGHT, Action.JumpAerialF, File.METAKNIGHT_ANIM_JUMPAIRF, jump2to6, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.KIRBY.Jump2, File.METAKNIGHT_ANIM_JUMPAIRF, jump2to6, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.KIRBY.Jump3, File.METAKNIGHT_ANIM_JUMPAIRF, jump2to6, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.KIRBY.Jump4, File.METAKNIGHT_ANIM_JUMPAIRF, jump2to6, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.KIRBY.Jump5, File.METAKNIGHT_ANIM_JUMPAIRF, jump2to6, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.KIRBY.Jump6, File.METAKNIGHT_ANIM_JUMPAERIAL6, jump6, 0x0F000000)

    Character.edit_action_parameters(METAKNIGHT, Action.FSmash, File.METAKNIGHT_ANIM_SMASHF, smashF, 0x10000000)
    Character.edit_action_parameters(METAKNIGHT, Action.USmash, File.METAKNIGHT_ANIM_SMASHU, smashU, 0x10000000)
    Character.edit_action_parameters(METAKNIGHT, Action.DSmash, File.METAKNIGHT_ANIM_SMASHD, smashD, 0x10000000)

    Character.edit_action_parameters(METAKNIGHT, Action.Taunt, File.METAKNIGHT_ANIM_TAUNT, taunt, 0x00000000)
    Character.edit_action_parameters(METAKNIGHT, Action.Teeter, -1, teeter, 0x00000000)
	
    Character.edit_action_parameters(METAKNIGHT, Action.ShieldBreak, -1, SHIELDBREAK_, 0x00000000)
    Character.edit_action_parameters(METAKNIGHT, Action.Stun, -1, STUN_, 0x00000000)
    Character.edit_action_parameters(METAKNIGHT, Action.Sleep, -1, SLEEP_, 0x00000000)
	
    Character.edit_action_parameters(METAKNIGHT, Action.TechF, -1, techroll, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.TechB, -1, techroll, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.Tech, -1, techstand, 0x00000000)

    Character.edit_action_parameters(METAKNIGHT, Action.JumpF, File.METAKNIGHT_ANIM_JUMPF, jump, 0x00000000)
    Character.edit_action_parameters(METAKNIGHT, Action.JumpB, File.METAKNIGHT_ANIM_JUMPB, jump, 0x00000000)

    Character.edit_action_parameters(METAKNIGHT, Action.JumpSquat, File.METAKNIGHT_ANIM_LANDINGLIGHT, -1, 0x00000000)
    Character.edit_action_parameters(METAKNIGHT, Action.ShieldJumpSquat, File.METAKNIGHT_ANIM_LANDINGLIGHT, -1, 0x00000000)
    Character.edit_action_parameters(METAKNIGHT, Action.LandingLight, File.METAKNIGHT_ANIM_LANDINGLIGHT, -1, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.LandingSpecial, File.METAKNIGHT_ANIM_LANDINGSPECIAL, -1, 0x00000000)
    Character.edit_action_parameters(METAKNIGHT, Action.LandingHeavy, File.METAKNIGHT_ANIM_LANDINGHEAVY, -1, 0x0F000000)

    Character.edit_action_parameters(METAKNIGHT, Action.Pass, File.METAKNIGHT_ANIM_PLATFORMDROP, -1, 0x80000000)
    Character.edit_action_parameters(METAKNIGHT, Action.ShieldDrop, File.METAKNIGHT_ANIM_PLATFORMDROP, -1, 0x80000000)

    Character.edit_action_parameters(METAKNIGHT, Action.DamageMid1, File.METAKNIGHT_ANIM_DAMAGEN1, eyesDamage, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageMid2, File.METAKNIGHT_ANIM_DAMAGEN2, eyesDamage, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageMid3, File.METAKNIGHT_ANIM_DAMAGEN3, eyesDamage, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageHigh1, File.METAKNIGHT_ANIM_DAMAGEHI1, eyesDamage, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageHigh2, File.METAKNIGHT_ANIM_DAMAGEHI2, eyesDamage, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageHigh3, File.METAKNIGHT_ANIM_DAMAGEHI3, eyesDamage, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageLow1, File.METAKNIGHT_ANIM_DAMAGELW1, eyesDamage, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageLow2, File.METAKNIGHT_ANIM_DAMAGELW2, eyesDamage, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageLow3, File.METAKNIGHT_ANIM_DAMAGELW3, eyesDamage, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageAir1, File.METAKNIGHT_ANIM_DAMAGEAIR1, eyesDamage, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageAir2, File.METAKNIGHT_ANIM_DAMAGEAIR2, eyesDamage, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageAir3, File.METAKNIGHT_ANIM_DAMAGEAIR3, eyesDamage, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageFlyHigh, File.METAKNIGHT_ANIM_DAMAGEFLYHI, eyesDamage, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageFlyLow, File.METAKNIGHT_ANIM_DAMAGEFLYLW, eyesDamage, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageFlyMid, File.METAKNIGHT_ANIM_DAMAGEFLYN, eyesDamage, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.WallBounce, File.METAKNIGHT_ANIM_DAMAGEFALL, eyesDamage, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.Tumble, File.METAKNIGHT_ANIM_DAMAGEFALL, eyesDamage, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageFlyRoll, File.METAKNIGHT_ANIM_DAMAGEFLYROLL, eyesDamage, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageFlyTop, File.METAKNIGHT_ANIM_DAMAGEFLYTOP, eyesDamage, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageElec1, File.METAKNIGHT_ANIM_DAMAGEELEC, eyesDamage, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.DamageElec2, File.METAKNIGHT_ANIM_DAMAGEELEC, eyesDamage, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.FalconDivePulled, File.METAKNIGHT_ANIM_DAMAGEAIR1, eyesDamage, 0x0F000000)
    
    Character.edit_action_parameters(METAKNIGHT, Action.CapturePulled, -1, eyesDamage, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.CaptureWait, -1, eyesDamage, -1)

    Character.edit_action_parameters(METAKNIGHT, Action.ThrownDKPulled, -1, eyesDamage, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.ThrownMarioBros, -1, eyesDamage, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.ThrownFoxFStart, -1, eyesDamage, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.ThrownDK, -1, eyesDamage, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.Thrown1, -1, eyesDamage, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.Thrown2, -1, eyesDamage, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.Thrown3, -1, eyesDamage, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.ThrownFoxB, -1, eyesDamage, -1)

    Character.edit_action_parameters(METAKNIGHT, Action.InhaleCopied, File.METAKNIGHT_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.InhalePulled, File.METAKNIGHT_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.InhaleSpat, File.METAKNIGHT_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.ReviveWait, File.METAKNIGHT_ANIM_IDLE, IDLE_, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.ScreenKO, File.METAKNIGHT_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.ShieldBreak, File.METAKNIGHT_ANIM_DAMAGEFLYTOP, -1, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.ShieldBreakFall, File.METAKNIGHT_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.Tornado, File.METAKNIGHT_ANIM_DAMAGEFALL, -1, -1)

    Character.edit_action_parameters(METAKNIGHT, Action.DownBounceD, File.METAKNIGHT_ANIM_DOWNBOUNCED, DOWN_BOUNCE, 0x0)
    Character.edit_action_parameters(METAKNIGHT, Action.DownBounceU, File.METAKNIGHT_ANIM_DOWNBOUNCEU, DOWN_BOUNCE, 0x0)

    Character.edit_action_parameters(METAKNIGHT, Action.BeamSwordNeutral, File.METAKNIGHT_ANIM_SWING1, BEAMSWORD_JAB, 0x0)
    Character.edit_action_parameters(METAKNIGHT, Action.BeamSwordTilt, File.METAKNIGHT_ANIM_SWING3, BEAMSWORD_TILT, 0x40000000)
    Character.edit_action_parameters(METAKNIGHT, Action.BeamSwordSmash, File.METAKNIGHT_ANIM_SWING4, BEAMSWORD_SMASH, 0x40000000)
    Character.edit_action_parameters(METAKNIGHT, Action.BeamSwordDash, File.METAKNIGHT_ANIM_SWINGDASH, BEAMSWORD_DASH, 0x4F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.BatNeutral, File.METAKNIGHT_ANIM_SWING1, BAT_JAB, 0x0)
    Character.edit_action_parameters(METAKNIGHT, Action.BatTilt, File.METAKNIGHT_ANIM_SWING3, BAT_TILT, 0x40000000)
    Character.edit_action_parameters(METAKNIGHT, Action.BatSmash, File.METAKNIGHT_ANIM_SWING4, BAT_SMASH, 0x40000000)
    Character.edit_action_parameters(METAKNIGHT, Action.BatDash, File.METAKNIGHT_ANIM_SWINGDASH, BAT_DASH, 0x4F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.FanNeutral, File.METAKNIGHT_ANIM_SWING1, FAN_JAB, 0x0)
    Character.edit_action_parameters(METAKNIGHT, Action.FanTilt, File.METAKNIGHT_ANIM_SWING3, FAN_TILT, 0x40000000)
    Character.edit_action_parameters(METAKNIGHT, Action.FanSmash, File.METAKNIGHT_ANIM_SWING4, FAN_SMASH, 0x40000000)
    Character.edit_action_parameters(METAKNIGHT, Action.FanDash, File.METAKNIGHT_ANIM_SWINGDASH, FAN_DASH, 0x4F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.StarRodNeutral, File.METAKNIGHT_ANIM_SWING1, STARROD_JAB, 0x0)
    Character.edit_action_parameters(METAKNIGHT, Action.StarRodTilt, File.METAKNIGHT_ANIM_SWING3, STARROD_TILT, 0x40000000)
    Character.edit_action_parameters(METAKNIGHT, Action.StarRodSmash, File.METAKNIGHT_ANIM_SWING4, STARROD_SMASH, 0x40000000)
    Character.edit_action_parameters(METAKNIGHT, Action.StarRodDash, File.METAKNIGHT_ANIM_SWINGDASH, STARROD_DASH, 0x4F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.RayGunShoot, File.METAKNIGHT_ANIM_SHOOT, SHOOT, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.RayGunShootAir, File.METAKNIGHT_ANIM_SHOOTAIR, SHOOT, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.FireFlowerShoot, File.METAKNIGHT_ANIM_SHOOT, SHOOT, -1)
    Character.edit_action_parameters(METAKNIGHT, Action.FireFlowerShootAir, File.METAKNIGHT_ANIM_SHOOTAIR, SHOOT, 0x0F000000)
    Character.edit_action_parameters(METAKNIGHT, Action.HammerIdle, File.METAKNIGHT_ANIM_HAMMER, HAMMER, 0x0)
    Character.edit_action_parameters(METAKNIGHT, Action.HammerWalk, File.METAKNIGHT_ANIM_HAMMER, HAMMER, 0x0)
    Character.edit_action_parameters(METAKNIGHT, Action.HammerTurn, File.METAKNIGHT_ANIM_HAMMER, HAMMER, 0x0)
    Character.edit_action_parameters(METAKNIGHT, Action.HammerJumpSquat, File.METAKNIGHT_ANIM_HAMMER, HAMMER, 0x0)
    Character.edit_action_parameters(METAKNIGHT, Action.HammerAir, File.METAKNIGHT_ANIM_HAMMER, HAMMER, 0x0)
    Character.edit_action_parameters(METAKNIGHT, Action.HammerLanding, File.METAKNIGHT_ANIM_HAMMER, HAMMER, 0x0)

    //Entry

    Character.edit_action_parameters(METAKNIGHT, 0xE4,            File.METAKNIGHT_ANIM_ENTRYR,           ENTRY,          0x40800008)
    Character.edit_action_parameters(METAKNIGHT, 0xE5,            File.METAKNIGHT_ANIM_ENTRYL,           ENTRY,          0x40800008)

    // Modify Menu Action Parameters              // Action // Animation           // Moveset Data // Flags
    Character.edit_menu_action_parameters(METAKNIGHT, 0x0, File.METAKNIGHT_ANIM_IDLE, IDLE_, -1)
    Character.edit_menu_action_parameters(METAKNIGHT, 0x1, File.METAKNIGHT_ANIM_WIN1, win1, 0x10800000)
    Character.edit_menu_action_parameters(METAKNIGHT, 0x2, File.METAKNIGHT_ANIM_WIN3, win3, -1)
    Character.edit_menu_action_parameters(METAKNIGHT, 0x3, File.METAKNIGHT_ANIM_WIN3, win3, -1)
    Character.edit_menu_action_parameters(METAKNIGHT, 0x4, File.METAKNIGHT_ANIM_WIN3, win3, -1)
    Character.edit_menu_action_parameters(METAKNIGHT, 0x5, File.METAKNIGHT_ANIM_LOSE, -1, -1)
    Character.edit_menu_action_parameters(METAKNIGHT, 0xD, File.METAKNIGHT_ANIM_1PPOSE,  -1, 0x0F000000)
    // // Character.edit_menu_action_parameters(METAKNIGHT, 0xE,      File.GND_1P_CPU,       ONEP,           -1)
    // Character.edit_menu_action_parameters(METAKNIGHT,    0xD,      File.METAKNIGHT_ANIM_CLASSIC, ONEP,           -1)

    // Jab
    Character.add_new_action_params(METAKNIGHT, JAB_START, -1, File.METAKNIGHT_ANIM_JABSTART, jabStart, 0x00000000)
    Character.add_new_action(METAKNIGHT, JAB_START, Action.FTilt, ActionParams.JAB_START, -1, MetaKnightSpecial.Jab.Start.update, 0, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action_params(METAKNIGHT, JAB_LOOP, -1, File.METAKNIGHT_ANIM_JABLOOP, jabLoop, 0x10000000)
    Character.add_new_action(METAKNIGHT, JAB_LOOP, Action.FTilt, ActionParams.JAB_LOOP, -1, MetaKnightSpecial.Jab.Loop.update, 0, 0x800D8BB4, 0x800DDEC4)
    Character.add_new_action_params(METAKNIGHT, JAB_END, -1, File.METAKNIGHT_ANIM_JABEND, jabEnd, 0x50000000)
    Character.add_new_action(METAKNIGHT, JAB_END, Action.FTilt, ActionParams.JAB_END, -1, 0x800D94C4, 0, 0x800D8C14, 0x800DDF44)

    // TiltF
    Character.add_new_action_params(METAKNIGHT, TILTF, -1, File.METAKNIGHT_ANIM_TILTF, tiltF, 0x50000000)
    Character.add_new_action(METAKNIGHT, TILTF, Action.FTilt, ActionParams.TILTF, -1, MetaKnightSpecial.TiltF.update, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action_params(METAKNIGHT, TILTF2, -1, File.METAKNIGHT_ANIM_TILTF2, tiltF2, 0x50000000)
    Character.add_new_action(METAKNIGHT, TILTF2, Action.FTilt, ActionParams.TILTF2, -1, MetaKnightSpecial.TiltF.update, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action_params(METAKNIGHT, TILTF3, -1, File.METAKNIGHT_ANIM_TILTF3, tiltF3, 0x50000000)
    Character.add_new_action(METAKNIGHT, TILTF3, Action.FTilt, ActionParams.TILTF3, -1, 0x800D94C4, 0, 0x800D8C14, 0x800DDF44)

    // Up special
    Character.edit_action_parameters(METAKNIGHT, MetaKnight.Action.USP, File.METAKNIGHT_ANIM_SPECIALU, specialU, 0x5F000000)
    Character.edit_action(METAKNIGHT, MetaKnight.Action.USP, -1, MetaKnightSpecial.USP.main, MetaKnightSpecial.USP.interrupt, MetaKnightSpecial.USP.physics, MetaKnightSpecial.USP.collision)

    Character.edit_action_parameters(METAKNIGHT, MetaKnight.Action.USP_AIR_START, File.METAKNIGHT_ANIM_SPECIALUAIRSTART, 0x80000000, 0x0F000000)
    Character.edit_action(METAKNIGHT, MetaKnight.Action.USP_AIR_START, -1, MetaKnightSpecial.USP.air_start_update, 0, 0, 0x800DE87C)

    Character.edit_action_parameters(METAKNIGHT, MetaKnight.Action.USP_AIR, File.METAKNIGHT_ANIM_SPECIALU, specialUAir, 0x5F000000)
    Character.edit_action(METAKNIGHT, MetaKnight.Action.USP_AIR, -1, MetaKnightSpecial.USP.main, MetaKnightSpecial.USP.interrupt, MetaKnightSpecial.USP.physics, MetaKnightSpecial.USP.collision)

    Character.table_patch_start(air_usp, Character.id.METAKNIGHT, 0x4)
    dw MetaKnightSpecial.USP.air_initial
    OS.patch_end()
	
    Character.table_patch_start(ground_usp, Character.id.METAKNIGHT, 0x4)
    dw MetaKnightSpecial.USP.ground_initial
    OS.patch_end()

    // Neutral Special
    Character.edit_action_parameters(METAKNIGHT, MetaKnight.Action.TORNADO_START, File.METAKNIGHT_ANIM_TORNADOSTART, 0x80000000, 0x1F000000)
    Character.edit_action(METAKNIGHT, MetaKnight.Action.TORNADO_START, -1, MetaKnightSpecial.NSP.Start.update, 0x0, 0x800D90E0, 0x800DE87C)

    Character.edit_action_parameters(METAKNIGHT, MetaKnight.Action.TORNADO_LOOP, File.METAKNIGHT_ANIM_TORNADOLOOP, tornadoLoop, 0x9F000000)
    Character.edit_action(METAKNIGHT, MetaKnight.Action.TORNADO_LOOP, -1, MetaKnightSpecial.NSP.Loop.update, 0x0, MetaKnightSpecial.NSP.Loop.physics, MetaKnightSpecial.NSP.Loop.collision)

    Character.edit_action_parameters(METAKNIGHT, MetaKnight.Action.TORNADO_END, File.METAKNIGHT_ANIM_TORNADOEND, tornadoEnd, 0x1F000000)
    Character.edit_action(METAKNIGHT, MetaKnight.Action.TORNADO_END, -1, 0x800D94C4, 0x0, 0x800D8BB4, 0x800DDF44)

    Character.edit_action_parameters(METAKNIGHT, MetaKnight.Action.TORNADO_END_AIR, File.METAKNIGHT_ANIM_TORNADOENDAIR, 0x80000000, 0x1F000000)
    Character.edit_action(METAKNIGHT, MetaKnight.Action.TORNADO_END_AIR, -1, MetaKnightSpecial.DSP.Attack.air_main, 0x0, 0x800D90E0, MetaKnightSpecial.NSP.End.air_collision)

    Character.table_patch_start(air_nsp, Character.id.METAKNIGHT, 0x4)
    dw MetaKnightSpecial.NSP.air_initial
    OS.patch_end()
	
    Character.table_patch_start(ground_nsp, Character.id.METAKNIGHT, 0x4)
    dw MetaKnightSpecial.NSP.ground_initial
    OS.patch_end()

    // Down Special
    // Grounded
    Character.add_new_action_params(METAKNIGHT, CAPE_START, -1, File.METAKNIGHT_ANIM_SPECIALDSTART, specialDStart, 0x00800000)
    Character.add_new_action(METAKNIGHT, CAPE_START, -1, ActionParams.CAPE_START, -1, MetaKnightSpecial.DSP.Start.update, 0x0, MetaKnightSpecial.DSP.Start.physics, MetaKnightSpecial.DSP.Start.ground_collision)

    Character.add_new_action_params(METAKNIGHT, CAPE_END, -1, File.METAKNIGHT_ANIM_SPECIALDEND, specialDEnd, 0x00800000)
    Character.add_new_action(METAKNIGHT, CAPE_END, -1, ActionParams.CAPE_END, -1, 0x800D94C4, 0x0, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action_params(METAKNIGHT, CAPE_F, -1, File.METAKNIGHT_ANIM_SPECIALDF, specialDF, 0x50000000)
    Character.add_new_action(METAKNIGHT, CAPE_F, -1, ActionParams.CAPE_F, -1, 0x800D94C4, 0x0, 0x800D8C14, 0x800DDF44)

    Character.add_new_action_params(METAKNIGHT, CAPE_B, -1, File.METAKNIGHT_ANIM_SPECIALDB, specialDB, 0x50000000)
    Character.add_new_action(METAKNIGHT, CAPE_B, -1, ActionParams.CAPE_B, -1, 0x800D94C4, 0x0, 0x800D8C14, 0x800DDF44)

    Character.add_new_action_params(METAKNIGHT, CAPE_N, -1, File.METAKNIGHT_ANIM_SPECIALDN, specialDN, 0x50000000)
    Character.add_new_action(METAKNIGHT, CAPE_N, -1, ActionParams.CAPE_N, -1, 0x800D94C4, 0x0, 0x800D8C14, 0x800DDF44)

    Character.table_patch_start(ground_dsp, Character.id.METAKNIGHT, 0x4)
    dw MetaKnightSpecial.DSP.ground_initial
    OS.patch_end()

    //Aerial
    Character.add_new_action_params(METAKNIGHT, CAPE_AIR_START, -1, File.METAKNIGHT_ANIM_SPECIALDAIRSTART, specialDAirStart, 0x0F800000)
    Character.add_new_action(METAKNIGHT, CAPE_AIR_START, -1, ActionParams.CAPE_AIR_START, -1, MetaKnightSpecial.DSP.Start.update, 0, MetaKnightSpecial.DSP.Start.physics, MetaKnightSpecial.DSP.Start.air_collision)

    Character.add_new_action_params(METAKNIGHT, CAPE_AIR_END, -1, File.METAKNIGHT_ANIM_SPECIALDAIREND, specialAirDEnd, 0x00800000)
    Character.add_new_action(METAKNIGHT, CAPE_AIR_END, -1, ActionParams.CAPE_AIR_END, -1, MetaKnightSpecial.DSP.Attack.air_main, 0, 0x800D90E0, 0x800DE978)

    Character.add_new_action_params(METAKNIGHT, CAPE_AIR_F, -1, File.METAKNIGHT_ANIM_SPECIALDAIRF, specialDAirF, 0x50000000)
    Character.add_new_action(METAKNIGHT, CAPE_AIR_F, -1, ActionParams.CAPE_AIR_F, -1, MetaKnightSpecial.DSP.Attack.air_main, 0, MetaKnightSpecial.DSP.Attack.air_physics, 0x800DE978)

    Character.add_new_action_params(METAKNIGHT, CAPE_AIR_B, -1, File.METAKNIGHT_ANIM_SPECIALDAIRB, specialDAirB, 0x50000000)
    Character.add_new_action(METAKNIGHT, CAPE_AIR_B, -1, ActionParams.CAPE_AIR_B, -1, MetaKnightSpecial.DSP.Attack.air_main, 0, MetaKnightSpecial.DSP.Attack.air_physics, 0x800DE978)

    Character.add_new_action_params(METAKNIGHT, CAPE_AIR_N, -1, File.METAKNIGHT_ANIM_SPECIALDAIRN, specialDAirN, 0x50000000)
    Character.add_new_action(METAKNIGHT, CAPE_AIR_N, -1, ActionParams.CAPE_AIR_N, -1, MetaKnightSpecial.DSP.Attack.air_main, 0, MetaKnightSpecial.DSP.Attack.air_physics, 0x800DE978)

    Character.table_patch_start(air_dsp, Character.id.METAKNIGHT, 0x4)
    dw MetaKnightSpecial.DSP.air_initial
    OS.patch_end()

    // Action replacement map
    scope action_replace_map_: {
        dh Action.Jab1; dh MetaKnight.Action.JAB_START;
        dh Action.FTilt; dh MetaKnight.Action.TILTF;
        dw 0xFFFFFFFF // end of map
    }

    // Set action replacement table
    Character.table_patch_start(action_replace_map, Character.id.METAKNIGHT, 0x4)
    dw action_replace_map_
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.METAKNIGHT, 0x2)
    dh  FGM.CHANT
    OS.patch_end()

    // Fix the logic for breaking out of ThrownDK since we're using it for our grabbed opponent
    scope capture_action_fix_: {
        jr ra
        lli v0, 0x1 // return 1, which means it just skips the function completely
    }
    Character.table_patch_start(custom_capture_dk_interrupt, Character.id.METAKNIGHT, 0x4)
    dw capture_action_fix_
    OS.patch_end()

    // Remove entry script (no Blue Falcon).
    Character.table_patch_start(entry_script, Character.id.METAKNIGHT, 0x4)
    dw 0x8013DD68 // skips entry script
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.METAKNIGHT, 0, 1, 4, 5, 2, 0, 3)
    Teams.add_team_costume(YELLOW, METAKNIGHT, 1)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(METAKNIGHT, BLUE, YELLOW, RED, GREEN, BLACK, PINK, NA, NA)

    // @ Description
    // Meta Knight's extra actions
    scope Action {

        string_0x0E1:; String.insert("ShuttleLoop")
        string_0x0E2:; String.insert("ShuttleLoopAirStart")
        string_0x0E3:; String.insert("ShuttleLoopAir")
        string_0x0E4:; String.insert("Jump2")
        string_0x0E5:; String.insert("Jump3")
        string_0x0E6:; String.insert("Jump4")
        string_0x0E7:; String.insert("Jump5")
        string_0x0E8:; String.insert("Jump6")
        string_0x0E9:; String.insert("e9")
        string_0x0EA:; String.insert("ea")
        string_0x0EB:; String.insert("MachTornadoStart")
        string_0x0EC:; String.insert("MachTornadoLoop")
        string_0x0ED:; String.insert("MachTornadoGroundEnd")
        string_0x0EE:; String.insert("ee")
        string_0x0EF:; String.insert("MachTornadoAirEnd")
        string_0x0F0:; String.insert("f0")
        string_0x0F1:; String.insert("f1")
        string_0x0F2:; String.insert("JabLoop")
        string_0x0F3:; String.insert("JabLoopEnd")
        string_0x0F4:; String.insert("f4")
        string_0x0F5:; String.insert("FTilt2")
        string_0x0F6:; String.insert("FTilt3")
        string_0x0F7:; String.insert("DimensionalCape")
        string_0x0F8:; String.insert("DimensionalCancel")
        string_0x0F9:; String.insert("DimensionalCapeAtkB")
        string_0x0FA:; String.insert("DimensionalCapeAtkF")
        string_0x0FB:; String.insert("DimensionalCapeAtk")
        string_0x0FC:; String.insert("DimensionalCapeAir")
        string_0x0FD:; String.insert("DimensionalCancelAir")
        string_0x0FE:; String.insert("DimensionalCapeAirAtkB")
        string_0x0FF:; String.insert("DimensionalCapeAirAtkF")
        string_0x100:; String.insert("DimensionalCapeAirAtk")

        action_string_table:
        dw string_0x0E1
        dw string_0x0E2
        dw string_0x0E3
        dw string_0x0E4
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
        dw Action.COMMON.string_jabloop
        dw Action.COMMON.string_jabloopend
        dw string_0x0F4
        dw string_0x0F5
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
        dw string_0x100
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.METAKNIGHT, 0x4)
    dw Action.action_string_table
    OS.patch_end()

    // Used so that items work on the left hand on reused animations
    Character.table_patch_start(static_part, Character.id.METAKNIGHT, 0x8)
    dw 0x00800000 // withheld part 5 - left hand item
    dw 0x00000000 // table end
    OS.patch_end()

    scope grounded_script_: {
        j Character.grounded_script.DISABLED // back to original routine
        nop
    }
    Character.table_patch_start(grounded_script, Character.id.METAKNIGHT, 0x4)
    dw grounded_script_
    OS.patch_end()

    scope initial_script_: {
        addiu at, r0, -1
        j 0x800D7F0C // back to original routine
        sw at, 0xAE4(v1) // set wings state to hidden
    }
    Character.table_patch_start(initial_script, Character.id.METAKNIGHT, 0x4)
    dw initial_script_
    OS.patch_end()

    scope CloakingFix: {
        scope fix_: {
            // s8 = player struct
            // v0 = first custom part struct (left inner wing)
            _check_mk:
            addiu   sp, sp, -0x0010             // allocate stack space
            sw      t1, 0x0004(sp)              // save return address

            // Check if wings displayed
            lw      t2, 0xAE4(s8)               // t2 = wings state
            li      t1, -1                      // t1 = 0xFFFFFFFF
            bnel    t2, t1, _fix_mk             // if wings, fix
            nop
            lw      t1, 0x0004(sp)              // load return address
            j       CharEnvColor.override_env_color_._return
            addiu   sp, sp, 0x0010              // allocate stack space

            _fix_mk:
            li      t1, _fix_mk_2               // t1 is the address to return to
            j       CharEnvColor.override_env_color_._fix
            nop

            _fix_mk_2:
            li      t1, _fix_mk_3               // t1 is the address to return to
            li      v0, CharEnvColor.custom_display_lists_struct_metaknight_left_wing_outer
            j       CharEnvColor.override_env_color_._fix
            nop

            _fix_mk_3:
            li      v0, CharEnvColor.custom_display_lists_struct_metaknight_right_wing_inner
            li      t1, _fix_mk_4               // t1 is the address to return to
            j       CharEnvColor.override_env_color_._fix
            nop

            _fix_mk_4:
            li      v0, CharEnvColor.custom_display_lists_struct_metaknight_right_wing_outer
            lw      t1, 0x0004(sp)              // load return address
            j       CharEnvColor.override_env_color_._fix
            addiu   sp, sp, 0x0010              // allocate stack space
        }
    }

    // Modify Menu Action Parameters // Action // Animation // Moveset Data // Flags
    // Character.edit_menu_action_parameters(METAKNIGHT, 0x0, File.METAKNIGHT_ANIM_TILTU, 0, 0x00000000)
}