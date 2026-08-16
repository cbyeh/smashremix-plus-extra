include "./KenSpecial.asm"

// This file contains file inclusions, action edits, and assembly for Ken.

scope Ken {
    CUSTOM_THROWB:; Moveset.THROW_DATA(THROWB_DATA); Moveset.GO_TO(THROWB)
    CUSTOM_THROWF:; Moveset.THROW_DATA(THROWF_DATA); Moveset.GO_TO(THROWF)
    GRAB_: ; Moveset.THROW_DATA(THROWF_DATA); Moveset.GO_TO(GRAB)

    // insert SLEEP_, "moveset/SLEEP.bin"; Moveset.GO_TO(SLEEP_) // loops
    insert SPARKLE_, "moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE_) // loops
    insert SHIELD_BREAK_, "moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE_) // goes to sparkle
    insert STUN_, "moveset/STUN.bin"; Moveset.GO_TO(STUN_) // loops
	
    insert RUN_, "moveset/RUN.bin"; Moveset.GO_TO(RUN_) // loops

    dspAirLoop:
        insert "moveset/DSP_M.bin";
        insert "moveset/DSP_M.bin";
        insert "moveset/DSP_M.bin";
        Moveset.END()
    
    dspH:
        insert "moveset/DSP_H.bin";
        insert "moveset/DSP_H.bin";
        insert "moveset/DSP_H.bin";
        Moveset.END()

    // Item moveset definitions, copied from Cloud
    LIGHT_ITEM_PICKUP:; dw 0xBC000003;  dw 0x08000004; dw 0x3800009D; dw 0x58000001; dw 0
    ITEM_DROP:; dw 0xBC000003;  dw 0x08000009; dw 0x54000001; dw 0
    ITEM_THROW_DASH:; dw 0x08000005; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_DASH); dw 0
    ITEM_THROW_F:; dw 0xBC000003; dw 0x08000008; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_B:; dw 0xBC000003; dw 0x60000008; dw 0x08000008; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_U:; dw 0xBC000003; dw 0x0800000C; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_D:; dw 0xBC000003; dw 0x08000008; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_SMASH_F:; dw 0xBC000003; dw 0x08000008; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_SMASH_B:; dw 0xBC000003; dw 0x60000008; dw 0x08000008; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_SMASH_U:; dw 0xBC000003; dw 0x0800000C; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_SMASH_D:; dw 0xBC000003; dw 0x08000008; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_F:; dw 0xBC000003; dw 0x08000008; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_B:; dw 0xBC000003; dw 0x60000004; dw 0x08000008; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_U:; dw 0xBC000003; dw 0x0800000C; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_D:; dw 0xBC000003; dw 0x08000008; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_SMASH_F:; dw 0xBC000003; dw 0x08000008; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_AIR_SMASH_FB); dw 0
    ITEM_THROW_AIR_SMASH_B:; dw 0xBC000003; dw 0x60000006; dw 0x08000008; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_AIR_SMASH_FB); dw 0
    ITEM_THROW_AIR_SMASH_U:; dw 0xBC000003; dw 0x0800000C; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_SMASH_UD); dw 0
    ITEM_THROW_AIR_SMASH_D:; dw 0xBC000003; dw 0x08000008; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_SMASH_UD); dw 0
    BEAMSWORD_JAB:; dw 0xBC000003; dw 0x08000003; dw 0xCC040000; dw 0x08000003; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_JAB); dw 0x04000004; dw 0x18000000; dw 0x04000004; dw 0xCC03FFFF; dw 0
    BEAMSWORD_TILT:; dw 0xBC000003; dw 0x6000000A; dw 0x08000006; dw 0xBC000004; dw 0xCC040000; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_TILT); dw 0x04000004; dw 0x18000000; dw 0xCC03FFFF; dw 0x08000026; dw 0xBC000003; dw 0
    BEAMSWORD_SMASH:; dw 0xBC000003; dw 0x0800000D; dw 0xCC040000; dw 0x0800000E; dw 0xBC000004; dw 0x50000000; dw 0x0800000E; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_SMASH); dw 0x04000004; dw 0x18000000; dw 0x04000005; dw 0xCC03FFFF; dw 0x0800002D; dw 0xBC000003; dw 0
    BEAMSWORD_DASH:; dw 0xBC000004; dw 0xCC040000; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_DASH); dw 0x04000003; dw 0xCC03FFFF; dw 0x0400000F; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    BAT_JAB:; dw 0xBC000003; dw 0x08000003; Moveset.SUBROUTINE(Moveset.shared.BAT_JAB); dw 0x04000004; dw 0x18000000; dw 0
    BAT_TILT:; dw 0xBC000003; dw 0x08000006; dw 0xBC000004; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.BAT_TILT); dw 0x04000004; dw 0x18000000; dw 0x08000026; dw 0xBC000003; dw 0
    BAT_SMASH:; dw 0xC4000007; dw 0xBC000003; dw 0xB1300028; dw 0x0800000E; dw 0xBC000004; dw 0x50000000; dw 0x0800000E; Moveset.SUBROUTINE(Moveset.shared.BAT_SMASH); dw 0x04000004; dw 0x18000000; dw 0x0800002D; dw 0xBC000003; dw 0
    BAT_DASH:; dw 0xBC000004; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.BAT_DASH); dw 0x04000012; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    FAN_JAB:; dw 0xBC000003; dw 0x08000003; Moveset.SUBROUTINE(Moveset.shared.FAN_JAB); dw 0x04000004; dw 0x18000000; dw 0
    FAN_TILT:; dw 0xBC000003; dw 0x08000006; dw 0xBC000004; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.FAN_TILT); dw 0x04000004; dw 0x18000000; dw 0x08000026; dw 0xBC000003; dw 0
    FAN_SMASH:; dw 0xBC000003; dw 0x0800000E; dw 0xBC000004; dw 0x50000000; dw 0x0800000E; Moveset.SUBROUTINE(Moveset.shared.FAN_SMASH); dw 0x04000004; dw 0x18000000; dw 0x0800002D; dw 0xBC000003; dw 0
    FAN_DASH:; dw 0xBC000004; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.FAN_DASH); dw 0x04000012; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    STARROD_JAB:; dw 0xBC000003; dw 0xB12C0010; dw 0x08000003; Moveset.SUBROUTINE(Moveset.shared.STARROD_JAB); dw 0x04000004; dw 0x18000000; dw 0
    STARROD_TILT:; dw 0xBC000003; dw 0x08000006; dw 0xBC000004; dw 0xB12C000D; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.STARROD_TILT); dw 0x04000001; dw 0x54000001; dw 0x04000000; dw 0x18000000;  dw 0x08000026; dw 0xBC000003; dw 0
    STARROD_SMASH:; dw 0xBC000003; dw 0x0800000E; dw 0xBC000004; dw 0xB12C0024; dw 0x50000000; dw 0x0800000E; Moveset.SUBROUTINE(Moveset.shared.STARROD_SMASH); dw 0x0800000F; dw 0x54000002; dw 0x04000004; dw 0x18000000; dw 0x0800002D; dw 0xBC000003; dw 0
    STARROD_DASH:; dw 0xBC000004; dw 0xB12C0014; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.STARROD_DASH); dw 0x04000012; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    HAMMER:; dw 0xC4000007; dw 0xBC000004; dw 0xAC000001; dw 0xAC100001; Moveset.SUBROUTINE(Moveset.shared.HAMMER); dw 0x04000010; dw 0x18000000; Moveset.GO_TO(HAMMER)

    // Modify Action Parameters // Action // Animation // Moveset Data // Flags
    Character.edit_action_parameters(KEN, Action.Entry, File.KEN_ANIM_IDLE, IDLE, -1)
    Character.edit_action_parameters(KEN, 0x006, File.KEN_ANIM_IDLE, IDLE, -1)
    Character.edit_action_parameters(KEN, Action.Idle, File.KEN_ANIM_IDLE, IDLE, -1)
    Character.edit_action_parameters(KEN, Action.Revive1, File.KEN_ANIM_DOWNBOUNCED, -1, -1)
    Character.edit_action_parameters(KEN, Action.ReviveWait, File.KEN_ANIM_IDLE, -1, -1)
    Character.edit_action_parameters(KEN, Action.Dash, File.KEN_ANIM_DASH, -1, -1)
    Character.edit_action_parameters(KEN, Action.Walk1, File.KEN_ANIM_WALK1, -1, -1)
    Character.edit_action_parameters(KEN, Action.Walk2, File.KEN_ANIM_WALK2, -1, -1)
    Character.edit_action_parameters(KEN, Action.Walk3, File.KEN_ANIM_WALK3, -1, -1)
    Character.edit_action_parameters(KEN, Action.Teeter, File.KEN_ANIM_TEETER, IDLE, -1)
    Character.edit_action_parameters(KEN, Action.TeeterStart, File.KEN_ANIM_TEETERSTART, IDLE, -1)
    Character.edit_action_parameters(KEN, Action.Fall, File.KEN_ANIM_FALL, -1, 0x00000000)
    Character.edit_action_parameters(KEN, Action.FallAerial, File.KEN_ANIM_FALLAERIAL, -1, 0x00000000)
    Character.edit_action_parameters(KEN, Action.FallSpecial, File.KEN_ANIM_FALLSPECIAL, -1, -1)
    Character.edit_action_parameters(KEN, Action.JumpF, File.KEN_ANIM_JUMPF, JUMP, 0x00000000)
    Character.edit_action_parameters(KEN, Action.JumpB, File.KEN_ANIM_JUMPB, JUMP, 0x80000000)
    Character.edit_action_parameters(KEN, Action.Grab, File.KEN_ANIM_GRAB, GRAB_, -1)
    Character.edit_action_parameters(KEN, Action.GrabPull, File.KEN_ANIM_GRABPULL, -1, -1)
    Character.edit_action_parameters(KEN, Action.ThrowF, File.KEN_ANIM_THROWF, CUSTOM_THROWF, 0x10000000)
    Character.edit_action_parameters(KEN, Action.ThrowB, File.KEN_ANIM_THROWB, CUSTOM_THROWB, 0x50000000)
    Character.edit_action_parameters(KEN, Action.JumpAerialF, File.KEN_ANIM_JUMPAIRF, JUMP_AERIAL, -1)
    Character.edit_action_parameters(KEN, Action.JumpAerialB, File.KEN_ANIM_JUMPAIRB, JUMP_AERIAL, 0x00000000)
    Character.edit_action_parameters(KEN, Action.TechF, -1, TECHFROLL, -1)
    Character.edit_action_parameters(KEN, Action.TechB, -1, TECHFROLL, -1)
    Character.edit_action_parameters(KEN, Action.Tech, -1, TECHSTAND, -1)
    Character.edit_action_parameters(KEN, Action.CliffCatch, -1, CLIFFCATCH, -1)
    Character.edit_action_parameters(KEN, Action.CliffWait, -1, CLIFFWAIT, -1)
    Character.edit_action_parameters(KEN, Action.CliffQuick, -1, CLIFFQUICK, -1)
    Character.edit_action_parameters(KEN, Action.CliffSlow, -1, CLIFFSLOW, -1)
    Character.edit_action_parameters(KEN, Action.CliffAttackQuick2, -1, EDGEATTACKF, -1)
    Character.edit_action_parameters(KEN, Action.CliffAttackSlow2, -1, EDGEATTACKS, -1)
    Character.edit_action_parameters(KEN, Action.Taunt, File.KEN_ANIM_TAUNT, TAUNT, -1)
    Character.edit_action_parameters(KEN, Action.ShieldBreak, -1, SHIELD_BREAK_, -1)
    Character.edit_action_parameters(KEN, Action.Stun, -1, STUN_, -1)
    Character.edit_action_parameters(KEN, Action.Jab1, File.KEN_ANIM_JABH, JAB_FAR, 0x40000000)
    Character.edit_action_parameters(KEN, Action.DashAttack, File.KEN_ANIM_DASHATTACK, DASH_ATTACK, 0x40000000)
    Character.edit_action_parameters(KEN, Action.FTiltHigh, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(KEN, Action.FTiltMidHigh, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(KEN, Action.FTilt, File.KEN_ANIM_TILTFH, FTILTH, 0x40000000)
    Character.edit_action_parameters(KEN, Action.FTiltMidLow, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(KEN, Action.FTiltLow, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(KEN, Action.UTilt, File.KEN_ANIM_TILTUH, UTILTH, 0x00000000)
    Character.edit_action_parameters(KEN, Action.DTilt, File.KEN_ANIM_TILTDH, DTILTH, 0)
    Character.edit_action_parameters(KEN, Action.FSmashHigh, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(KEN, Action.FSmash, File.KEN_ANIM_SMASHF, FSMASH, 0x40000000)
    Character.edit_action_parameters(KEN, Action.FSmashLow, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(KEN, Action.USmash, File.KEN_ANIM_SMASHU, USMASH, 0x40000000)
    Character.edit_action_parameters(KEN, Action.DSmash, File.KEN_ANIM_SMASHD, DSMASH, -1)
    Character.edit_action_parameters(KEN, Action.AttackAirN, File.KEN_ANIM_AIRN, NAIR, -1)
    Character.edit_action_parameters(KEN, Action.AttackAirF, File.KEN_ANIM_AIRF, FAIR, -1)
    Character.edit_action_parameters(KEN, Action.AttackAirB, File.KEN_ANIM_AIRB, BAIR, -1)
    Character.edit_action_parameters(KEN, Action.AttackAirU, File.KEN_ANIM_AIRU, UAIR, -1)
    Character.edit_action_parameters(KEN, Action.AttackAirD, File.KEN_ANIM_AIRD, DAIR, -1)
    Character.edit_action_parameters(KEN, Action.LandingAirF, 0, 0x80000000, -1)
    Character.edit_action_parameters(KEN, Action.LandingAirB, File.KEN_ANIM_LANDINGAIRB, -1, -1)
    Character.edit_action_parameters(KEN, 0xE0, File.KEN_ANIM_ENTRYR, ENTRY, 0x40000009)
    Character.edit_action_parameters(KEN, 0xE1, File.KEN_ANIM_ENTRYL, ENTRY, 0x40000009)
    Character.edit_action_parameters(KEN, 0xE4, File.KEN_ANIM_HADOUKENGND, NSP_AIR, 0x40000000)
    Character.edit_action_parameters(KEN, 0xE5, File.KEN_ANIM_HADOUKENGND, NSP_AIR, 0x40000000)
    Character.edit_action_parameters(KEN, 0xE6, File.KEN_ANIM_DSPSTART, dspStart, 0x40000000)
    Character.edit_action_parameters(KEN, 0xE9, File.KEN_ANIM_DSPAIRSTART, dspAirStart, 0x0) // aerial dsp
    Character.edit_action_parameters(KEN, Action.Crouch, File.KEN_ANIM_CROUCHSTART, -1, -1)
    Character.edit_action_parameters(KEN, Action.CrouchIdle, File.KEN_ANIM_CROUCHWAIT, -1, -1)
    Character.edit_action_parameters(KEN, Action.CrouchEnd, File.KEN_ANIM_CROUCHEND, -1, -1)
    
    Character.edit_action_parameters(KEN, Action.Run, File.KEN_ANIM_RUN, RUN_, -1)
    Character.edit_action_parameters(KEN, Action.RunBrake, File.KEN_ANIM_RUNBRAKE, -1, -1)
    Character.edit_action_parameters(KEN, Action.Turn, File.KEN_ANIM_TURN, -1, -1);
    Character.edit_action_parameters(KEN, Action.TurnRun, File.KEN_ANIM_TURNRUN, RUNTURN, -1);

    Character.edit_action_parameters(KEN, Action.DownBounceD, File.KEN_ANIM_DOWNBOUNCED, -1, -1)
    Character.edit_action_parameters(KEN, Action.DownBounceU, File.KEN_ANIM_DOWNBOUNCEU, -1, -1)

    Character.edit_action_parameters(KEN, Action.ClangRecoil, File.KEN_ANIM_CLANGRECOIL, -1, -1);

    Character.edit_action_parameters(KEN, Action.JumpSquat, File.KEN_ANIM_JUMPSQUAT, -1, -1);
    Character.edit_action_parameters(KEN, Action.ShieldJumpSquat, File.KEN_ANIM_JUMPSQUAT, -1, -1);
    Character.edit_action_parameters(KEN, Action.LandingLight, File.KEN_ANIM_JUMPSQUAT, -1, -1);
    Character.edit_action_parameters(KEN, Action.LandingHeavy, File.KEN_ANIM_LANDINGHEAVY, -1, -1);
    Character.edit_action_parameters(KEN, Action.LandingAirX, File.KEN_ANIM_LANDINGHEAVY, -1, -1);
    Character.edit_action_parameters(KEN, Action.LandingSpecial, File.KEN_ANIM_SPECIALLAND, -1, -1);

    Character.edit_action_parameters(KEN, Action.ShieldOn, File.KEN_ANIM_SHIELDON, -1, 0xA0000000);
    Character.edit_action_parameters(KEN, Action.ShieldOff, File.KEN_ANIM_SHIELDOFF, -1, 0xA0000000);

    Character.edit_action_parameters(KEN, Action.Pass, File.KEN_ANIM_PASS_PLATDROP, -1, -1)
    Character.edit_action_parameters(KEN, Action.ShieldDrop, File.KEN_ANIM_PASS_PLATDROP, -1, -1)

    Character.edit_action_parameters(KEN, Action.DamageMid1, File.KEN_ANIM_DAMAGEN1, -1, -1)
    Character.edit_action_parameters(KEN, Action.DamageMid2, File.KEN_ANIM_DAMAGEN2, -1, -1)
    Character.edit_action_parameters(KEN, Action.DamageMid3, File.KEN_ANIM_DAMAGEN3, -1, -1)
    Character.edit_action_parameters(KEN, Action.DamageHigh1, File.KEN_ANIM_DAMAGEHI1, -1, -1)
    Character.edit_action_parameters(KEN, Action.DamageHigh2, File.KEN_ANIM_DAMAGEHI2, -1, -1)
    Character.edit_action_parameters(KEN, Action.DamageHigh3, File.KEN_ANIM_DAMAGEHI3, -1, -1)
    Character.edit_action_parameters(KEN, Action.DamageLow1, File.KEN_ANIM_DAMAGELOW1, -1, -1)
    Character.edit_action_parameters(KEN, Action.DamageLow2, File.KEN_ANIM_DAMAGELOW2, -1, -1)
    Character.edit_action_parameters(KEN, Action.DamageLow3, File.KEN_ANIM_DAMAGELOW3, -1, -1)
    Character.edit_action_parameters(KEN, Action.DamageAir1, File.KEN_ANIM_DAMAGEAIR1, -1, -1)
    Character.edit_action_parameters(KEN, Action.DamageAir2, File.KEN_ANIM_DAMAGEAIR2, -1, -1)
    Character.edit_action_parameters(KEN, Action.DamageAir3, File.KEN_ANIM_DAMAGEAIR3, -1, -1)
    Character.edit_action_parameters(KEN, Action.DamageFlyHigh, File.KEN_ANIM_DAMAGEFLYHI, -1, -1)
    Character.edit_action_parameters(KEN, Action.DamageFlyLow, File.KEN_ANIM_DAMAGEFLYLOW, -1, -1)
    Character.edit_action_parameters(KEN, Action.DamageFlyMid, File.KEN_ANIM_DAMAGEFLYN, -1, -1)
    Character.edit_action_parameters(KEN, Action.WallBounce, File.KEN_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(KEN, Action.Tumble, File.KEN_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(KEN, Action.DamageFlyRoll, File.KEN_ANIM_DAMAGEFLYROLL, -1, -1)
    Character.edit_action_parameters(KEN, Action.DamageFlyTop, File.KEN_ANIM_DAMAGEFLYTOP, -1, -1)

    Character.edit_action_parameters(KEN, Action.RollF, File.KEN_ANIM_ROLLF, -1, -1)
    Character.edit_action_parameters(KEN, Action.RollB, File.KEN_ANIM_ROLLB, -1, -1)

    Character.edit_action_parameters(KEN, Action.DownAttackD, File.KEN_ANIM_DOWNATTACKD, -1, -1)
    Character.edit_action_parameters(KEN, Action.DownAttackU, File.KEN_ANIM_DOWNATTACKU, -1, -1)
    Character.edit_action_parameters(KEN, Action.DownStandD, File.KEN_ANIM_DOWNSTANDD, -1, -1);
    Character.edit_action_parameters(KEN, Action.DownStandU, File.KEN_ANIM_DOWNSTANDU, -1, -1);
    Character.edit_action_parameters(KEN, Action.Tech, File.KEN_ANIM_TECH, -1, -1);
    Character.edit_action_parameters(KEN, Action.TechF, File.KEN_ANIM_TECHF, -1, -1)
    Character.edit_action_parameters(KEN, Action.TechB, File.KEN_ANIM_TECHB, -1, -1)
    Character.edit_action_parameters(KEN, Action.DownForwardD, File.KEN_ANIM_DOWNFORWARDD, -1, -1)
    Character.edit_action_parameters(KEN, Action.DownForwardU, File.KEN_ANIM_DOWNFORWARDU, -1, -1)
    Character.edit_action_parameters(KEN, Action.DownBackD, File.KEN_ANIM_DOWNBACKD, -1, -1)
    Character.edit_action_parameters(KEN, Action.DownBackU, File.KEN_ANIM_DOWNBACKU, -1, -1)

    Character.edit_action_parameters(KEN, Action.LightItemPickup,    File.KEN_ANIM_LIGHTGET,        LIGHT_ITEM_PICKUP,       -1)
    Character.edit_action_parameters(KEN, Action.ItemDrop,           File.KEN_ANIM_LIGHTDROP,       ITEM_DROP,                -1)
    Character.edit_action_parameters(KEN, Action.ItemThrowDash,      File.KEN_ANIM_LIGHTTHROWDASH,  ITEM_THROW_DASH,          -1)
    Character.edit_action_parameters(KEN, Action.ItemThrowF,         File.KEN_ANIM_LIGHTTHROWF,     ITEM_THROW_F,             -1)
    Character.edit_action_parameters(KEN, Action.ItemThrowB,         File.KEN_ANIM_LIGHTTHROWF,     ITEM_THROW_B,             -1)
    Character.edit_action_parameters(KEN, Action.ItemThrowU,         File.KEN_ANIM_LIGHTTHROWU,     ITEM_THROW_U,             -1)
    Character.edit_action_parameters(KEN, Action.ItemThrowD,         File.KEN_ANIM_LIGHTTHROWD,     ITEM_THROW_D,             -1)
    Character.edit_action_parameters(KEN, Action.ItemThrowSmashF,    File.KEN_ANIM_LIGHTTHROWF,     ITEM_THROW_SMASH_F,       -1)
    Character.edit_action_parameters(KEN, Action.ItemThrowSmashB,    File.KEN_ANIM_LIGHTTHROWF,     ITEM_THROW_SMASH_B,       -1)
    Character.edit_action_parameters(KEN, Action.ItemThrowSmashU,    File.KEN_ANIM_LIGHTTHROWU,     ITEM_THROW_SMASH_U,       -1)
    Character.edit_action_parameters(KEN, Action.ItemThrowSmashD,    File.KEN_ANIM_LIGHTTHROWD,     ITEM_THROW_SMASH_D,       -1)
    Character.edit_action_parameters(KEN, Action.ItemThrowAirF,      File.KEN_ANIM_LIGHTTHROWAIRF,  ITEM_THROW_AIR_F,         -1)
    Character.edit_action_parameters(KEN, Action.ItemThrowAirB,      File.KEN_ANIM_LIGHTTHROWAIRF,  ITEM_THROW_AIR_B,         -1)
    Character.edit_action_parameters(KEN, Action.ItemThrowAirU,      File.KEN_ANIM_LIGHTTHROWAIRU,  ITEM_THROW_AIR_U,         -1)
    Character.edit_action_parameters(KEN, Action.ItemThrowAirD,      File.KEN_ANIM_LIGHTTHROWAIRD,  ITEM_THROW_AIR_D,         -1)
    Character.edit_action_parameters(KEN, Action.ItemThrowAirSmashF, File.KEN_ANIM_LIGHTTHROWAIRF,  ITEM_THROW_AIR_SMASH_F,   -1)
    Character.edit_action_parameters(KEN, Action.ItemThrowAirSmashB, File.KEN_ANIM_LIGHTTHROWAIRF,  ITEM_THROW_AIR_SMASH_B,   -1)
    Character.edit_action_parameters(KEN, Action.ItemThrowAirSmashU, File.KEN_ANIM_LIGHTTHROWAIRU,  ITEM_THROW_AIR_SMASH_U,   -1)
    Character.edit_action_parameters(KEN, Action.ItemThrowAirSmashD, File.KEN_ANIM_LIGHTTHROWAIRD,  ITEM_THROW_AIR_SMASH_D,   -1)

    Character.edit_action_parameters(KEN, Action.RayGunShoot,        File.KEN_ANIM_ITEMSHOOT,       -1, 0x00000000)
    Character.edit_action_parameters(KEN, Action.RayGunShootAir,     File.KEN_ANIM_ITEMSHOOTAIR,    -1, 0x00000000)
    Character.edit_action_parameters(KEN, Action.FireFlowerShoot,    File.KEN_ANIM_ITEMSHOOT,       -1, 0x00000000)
    Character.edit_action_parameters(KEN, Action.FireFlowerShootAir, File.KEN_ANIM_ITEMSHOOTAIR,    -1, 0x00000000)

    Character.edit_action_parameters(KEN, Action.HammerIdle,         File.KEN_ANIM_HAMMER,          HAMMER, -1)
    Character.edit_action_parameters(KEN, Action.HammerWalk,         File.KEN_ANIM_HAMMER,          HAMMER, -1)
    Character.edit_action_parameters(KEN, Action.HammerTurn,         File.KEN_ANIM_HAMMER,          HAMMER, -1)
    Character.edit_action_parameters(KEN, Action.HammerJumpSquat,    File.KEN_ANIM_HAMMER,          HAMMER, -1)
    Character.edit_action_parameters(KEN, Action.HammerAir,          File.KEN_ANIM_HAMMER,          HAMMER, -1)
    Character.edit_action_parameters(KEN, Action.HammerLanding,      File.KEN_ANIM_HAMMER,          HAMMER, -1)

    Character.edit_action_parameters(KEN, Action.BeamSwordNeutral,   File.KEN_ANIM_SWING1,          BEAMSWORD_JAB,   -1)
    Character.edit_action_parameters(KEN, Action.BeamSwordTilt,      File.KEN_ANIM_SWING3,          BEAMSWORD_TILT,  -1)
    Character.edit_action_parameters(KEN, Action.BeamSwordSmash,     File.KEN_ANIM_SWING4,          BEAMSWORD_SMASH, -1)
    Character.edit_action_parameters(KEN, Action.BeamSwordDash,      File.KEN_ANIM_SWINGDASH,       BEAMSWORD_DASH,  -1)
    Character.edit_action_parameters(KEN, Action.BatNeutral,         File.KEN_ANIM_SWING1,          BAT_JAB,         -1)
    Character.edit_action_parameters(KEN, Action.BatTilt,            File.KEN_ANIM_SWING3,          BAT_TILT,        -1)
    Character.edit_action_parameters(KEN, Action.BatSmash,           File.KEN_ANIM_SWING4,          BAT_SMASH,       -1)
    Character.edit_action_parameters(KEN, Action.BatDash,            File.KEN_ANIM_SWINGDASH,       BAT_DASH,        -1)
    Character.edit_action_parameters(KEN, Action.FanNeutral,         File.KEN_ANIM_SWING1,          FAN_JAB,         -1)
    Character.edit_action_parameters(KEN, Action.FanTilt,            File.KEN_ANIM_SWING3,          FAN_TILT,        -1)
    Character.edit_action_parameters(KEN, Action.FanSmash,           File.KEN_ANIM_SWING4,          FAN_SMASH,       -1)
    Character.edit_action_parameters(KEN, Action.FanDash,            File.KEN_ANIM_SWINGDASH,       FAN_DASH,        -1)
    Character.edit_action_parameters(KEN, Action.StarRodNeutral,     File.KEN_ANIM_SWING1,          STARROD_JAB,     -1)
    Character.edit_action_parameters(KEN, Action.StarRodTilt,        File.KEN_ANIM_SWING3,          STARROD_TILT,    -1)
    Character.edit_action_parameters(KEN, Action.StarRodSmash,       File.KEN_ANIM_SWING4,          STARROD_SMASH,   -1)
    Character.edit_action_parameters(KEN, Action.StarRodDash,        File.KEN_ANIM_SWINGDASH,       STARROD_DASH,    -1)

    // Modify Actions // Action // Staling ID // Main ASM // Interrupt/Other ASM // Movement/Physics ASM // Collision ASM
    Character.edit_action(KEN, 0xE0, -1, 0x8013DA94, 0, 0x8013DB2C, 0x800DE348) // LEFT ENTRY
    Character.edit_action(KEN, 0xE1, -1, 0x8013DA94, 0, 0x8013DB2C, 0x800DE348) // RIGHT ENTRY
    
    Character.edit_action(KEN, 0xE4, -1, KenSpecial.NSP.main, KenSpecial.NSP.change_direction_, KenSpecial.NSP.physics_, -1)
    Character.edit_action(KEN, 0xE5, -1, KenSpecial.NSP.main, KenSpecial.NSP.change_direction_, KenSpecial.NSP.physics_, KenSpecial.NSP.air_collision_)
    
    Character.edit_action(KEN, 0xE6, -1, KenSpecial.DSP.Start.main, 0, KenSpecial.DSP.Start.physics, 0x800DDF44)
    Character.edit_action(KEN, 0xE9, -1, KenSpecial.DSP.Start.main, 0, KenSpecial.DSP.Start.physics, 0x800DE978)

    // Add Action Parameters // Action Name // Base Action // Animation // Moveset Data // Flags
    Character.add_new_action_params(KEN, JAB_H, -1, File.KEN_ANIM_JABH, JAB_FAR, 0x40000000)
    Character.add_new_action_params(KEN, DTILT_H, -1, File.KEN_ANIM_TILTDH, DTILTH, 0x00000000)
    Character.add_new_action_params(KEN, UTILT_H, -1, File.KEN_ANIM_TILTUH, UTILTH, 0x00000000)
    Character.add_new_action_params(KEN, FTILT_H, -1, File.KEN_ANIM_TILTFH, FTILTH, 0x40000000)
    Character.add_new_action_params(KEN, USP_L, -1, File.KEN_ANIM_SHORYUKEN, USP_L, 0x40000000)
    Character.add_new_action_params(KEN, USP_AIR_L, -1, File.KEN_ANIM_SHORYUKEN, USP_L, 0x40000000)
    Character.add_new_action_params(KEN, JAB_L, -1, File.KEN_ANIM_JAB1, JAB_1, 0x00000000)
    Character.add_new_action_params(KEN, JAB_L2, -1, File.KEN_ANIM_JAB2, JAB_2, 0x40000000)
    Character.add_new_action_params(KEN, JAB_L3, -1, File.KEN_ANIM_JAB3, JAB_3, 0x40000000)
    Character.add_new_action_params(KEN, DTILT_L, -1, File.KEN_ANIM_TILTD, DTILTL, 0x00000000)
    Character.add_new_action_params(KEN, UTILT_L, -1, File.KEN_ANIM_TILTU, UTILTL, 0x00000000)
    Character.add_new_action_params(KEN, FTILT_L, -1, File.KEN_ANIM_TILTF, FTILTL, 0x40000000)
    Character.add_new_action_params(KEN, JAB_CLOSE, -1, File.KEN_ANIM_TILTUH, JAB_CLOSE, 0x00000000)
    Character.add_new_action_params(KEN, FTILT_CLOSE, -1, File.KEN_ANIM_TILTFCLOSE, FTILTCLOSE, 0x00000000)
    Character.add_new_action_params(KEN, DSP_L, 0xE6, File.KEN_ANIM_DSPLOOP, DSP_L, 0x0)
    Character.add_new_action_params(KEN, DSP_H, 0xE6, File.KEN_ANIM_DSPLOOP, dspH, 0x0)
    Character.add_new_action_params(KEN, DSP_AIR, 0xE6, File.KEN_ANIM_DSPLOOP, dspAirLoop, 0x0)
    Character.add_new_action_params(KEN, DSP_END, 0xE6, File.KEN_ANIM_DSPEND, dspEnd, 0x0)
    Character.add_new_action_params(KEN, DSP_AIREND, 0xE6, File.KEN_ANIM_DSPAIREND, 0x0, 0x0)
    Character.add_new_action_params(KEN, USP_H, -1, File.KEN_ANIM_SHORYUKEN, USP_H, 0x40000000)
    Character.add_new_action_params(KEN, USP_AIR_H, -1, File.KEN_ANIM_SHORYUKEN, USP_H, 0x40000000)
    Character.add_new_action_params(KEN, USP_FALL, -1, File.KEN_ANIM_SPECIALHI2, -1, 0x0)

    Character.add_new_action_params(KEN, ROUNDHOUSE, -1, File.KEN_ANIM_ROUNDHOUSE, ROUNDHOUSE, 0)
    Character.add_new_action_params(KEN, COMMAND_KICK_2, -1, File.KEN_ANIM_COMMANDKICK2, COMMAND_KICK_2, 0x40000000)
    Character.add_new_action_params(KEN, COMMAND_KICK, -1, File.KEN_ANIM_COMMANDKICK1, COMMAND_KICK, 0x40000000)

    // Add Actions // Action Name // Base Action //Parameters // Staling ID // Main ASM // Interrupt/Other ASM // Movement/Physics ASM // Collision ASM
    Character.add_new_action(KEN, JAB_H, -1, ActionParams.JAB_H, -1, 0x800D94C4, KenSpecial.SpecialCancel.interrupt, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KEN, DTILT_H, -1, ActionParams.DTILT_H, -1, 0x8014FBF0, KenSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)
	Character.add_new_action(KEN, UTILT_H, -1, ActionParams.UTILT_H, -1, 0x800D94C4, KenSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action(KEN, FTILT_H, -1, ActionParams.FTILT_H, -1, 0x800D94C4, KenSpecial.SpecialCancel.interrupt, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KEN, USP_L, -1, ActionParams.USP_L, -1, KenSpecial.USP.main_, KenSpecial.USP.change_direction_, KenSpecial.USP.physics_, KenSpecial.USP.collision_)
    Character.add_new_action(KEN, USP_AIR_L, -1, ActionParams.USP_AIR_L, -1, KenSpecial.USP.main_, KenSpecial.USP.change_direction_, KenSpecial.USP.physics_, KenSpecial.USP.collision_)
    Character.add_new_action(KEN, JAB_L, -1, ActionParams.JAB_L, -1, 0x800D94C4, KenSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action(KEN, JAB_L2, -1, ActionParams.JAB_L2, -1, 0x800D94C4, KenSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action(KEN, JAB_L3, -1, ActionParams.JAB_L3, -1, 0x800D94C4, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KEN, DTILT_L, -1, ActionParams.DTILT_L, -1, KenSpecial.CancelItselfDtilt.main, KenSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action(KEN, UTILT_L, -1, ActionParams.UTILT_L, -1, KenSpecial.CancelItselfUtilt.main, KenSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action(KEN, FTILT_L, -1, ActionParams.FTILT_L, -1, 0x800D94C4, KenSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action(KEN, JAB_CLOSE, -1, ActionParams.JAB_CLOSE, -1, 0x800D94C4, KenSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action(KEN, FTILT_CLOSE, -1, ActionParams.FTILT_CLOSE, -1, 0x800D94C4, KenSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action(KEN, DSP_L, -1, ActionParams.DSP_L, -1, KenSpecial.DSP.Loop.main, 0, KenSpecial.DSP.Loop.physics, 0x800DDF44)
    Character.add_new_action(KEN, DSP_H, -1, ActionParams.DSP_H, -1, KenSpecial.DSP.Loop.main, 0, KenSpecial.DSP.Loop.physics, 0x800DDF44)
    Character.add_new_action(KEN, DSP_AIR, -1, ActionParams.DSP_AIR, -1, KenSpecial.DSP.Loop.main, 0, KenSpecial.DSP.Loop.physics, 0x800DE978)
    Character.add_new_action(KEN, DSP_END, -1, ActionParams.DSP_END, -1, 0x800D94C4, 0, KenSpecial.DSP.End.physics, 0x800DDF44)
    Character.add_new_action(KEN, DSP_AIREND, -1, ActionParams.DSP_AIREND, -1, 0x800D94E8, 0, KenSpecial.DSP.End.physics, 0x800DE978)

    Character.add_new_action(KEN, USP_H, -1, ActionParams.USP_H, -1, KenSpecial.USP.main_, KenSpecial.USP.change_direction_, KenSpecial.USP.physics_, KenSpecial.USP.collision_)
    Character.add_new_action(KEN, USP_AIR_H, -1, ActionParams.USP_AIR_H, -1, KenSpecial.USP.main_, KenSpecial.USP.change_direction_, KenSpecial.USP.physics_, KenSpecial.USP.collision_)
    Character.add_new_action(KEN, USP_FALL, -1, ActionParams.USP_FALL, -1, KenSpecial.USP.fall_main, 0, KenSpecial.USP.fall_physics, KenSpecial.USP.fall_collision)

    Character.add_new_action(KEN, ROUNDHOUSE, -1, ActionParams.ROUNDHOUSE, -1, 0x800D94C4, KenSpecial.CommandKick.interrupt, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action(KEN, COMMAND_KICK_2, -1, ActionParams.COMMAND_KICK_2, -1, 0x800D94C4, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KEN, COMMAND_KICK, -1, ActionParams.COMMAND_KICK, -1, 0x800D94C4, KenSpecial.CommandKick.interrupt, 0x800D8C14, 0x800DDF44)

    // Action replacement map
    scope action_replace_map_: {
        dh Action.Jab1; dh Ken.Action.JAB_H;
        dh Action.DTilt; dh Ken.Action.DTILT_H;
        dh Action.UTilt; dh Ken.Action.UTILT_H;
        dh Action.FTilt; dh Ken.Action.FTILT_H;
        dw 0xFFFFFFFF // end of map
    }

    // Set action replacement table
    Character.table_patch_start(action_replace_map, Character.id.KEN, 0x4)
    dw action_replace_map_
    OS.patch_end()

    scope grounded_script_: {
        j Character.grounded_script.DISABLED // back to original routine
        nop
    }
    Character.table_patch_start(grounded_script, Character.id.KEN, 0x4)
    dw grounded_script_
    OS.patch_end()

    scope initial_script_: {
        j 0x800D7F0C // back to original routine
        nop
    }
    Character.table_patch_start(initial_script, Character.id.KEN, 0x4)
    dw initial_script_
    OS.patch_end()

    // Modify Menu Action Parameters // Action // Animation // Moveset Data // Flags
    Character.edit_menu_action_parameters(KEN, 0x0, File.KEN_ANIM_IDLE, -1, -1)
    Character.edit_menu_action_parameters(KEN, 0x1, File.KEN_ANIM_WIN1, VICTORY_POSE_1, -1)
    Character.edit_menu_action_parameters(KEN, 0x2, File.KEN_ANIM_WIN1, VICTORY_POSE_1, -1)
    Character.edit_menu_action_parameters(KEN, 0x3, File.KEN_ANIM_WIN1, VICTORY_POSE_1, -1)
    Character.edit_menu_action_parameters(KEN, 0x4, File.KEN_ANIM_WIN1, VICTORY_POSE_1, -1)
    Character.edit_menu_action_parameters(KEN, 0x5, File.KEN_ANIM_CLAPS, -1, -1)
    // Character.edit_menu_action_parameters(KEN, 0xE, File.GND_1P_CPU, ONEP, -1)
    Character.edit_menu_action_parameters(KEN, 0xD, File.KEN_ANIM_CLASSIC, ONEP, -1)

    Character.table_patch_start(air_usp, Character.id.KEN, 0x4)
    dw KenSpecial.USP.air_initial_
    OS.patch_end()
	
    Character.table_patch_start(ground_usp, Character.id.KEN, 0x4)
    dw KenSpecial.USP.ground_initial_
    OS.patch_end()

    Character.table_patch_start(ground_dsp, Character.id.KEN, 0x4)
    dw KenSpecial.DSP.ground_initial
    OS.patch_end()

    Character.table_patch_start(ground_nsp, Character.id.KEN, 0x4)
    dw KenSpecial.NSP.ground_initial
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.KEN, 0x4)
    float32 1
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.KEN, 0x4)
    dw 0x8013DD68 // skips entry script
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.KEN, 0x2)
    dh FGM.CHANT
    OS.patch_end()

    // Set down bound FGM.
    Character.table_patch_start(down_bound_fgm, Character.id.KEN, 0x2)
    dh Ken.FGM.GROUND_BUMP
    OS.patch_end()

    // Disable rapid jab
    Character.table_patch_start(rapid_jab, Character.id.KEN, 0x4)
    dw Character.rapid_jab.DISABLED // disable rapid jab
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.KEN, 0, 1, 2, 3, 0, 6, 4)
    Teams.add_team_costume(YELLOW, KEN, 5)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(KEN, RED, BLACK, PURPLE, WHITE, GREEN, YELLOW, AZURE, MAGENTA)

    // Set Kirby star damage
    Character.table_patch_start(kirby_inhale_struct, 0x8, Character.id.KEN, 0xC)
    dw Character.kirby_inhale_struct.star_damage.DK
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.KEN, 0xC)
    dh 0x11
    OS.patch_end()

    KEN_SMASH_SIDEB:
    AI.UNPRESS_Z()
    AI.UNPRESS_A(0)
    AI.UNPRESS_B(0)
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    dh 0xA07F // stick x = dash to opponent
    AI.PRESS_B(1)
    AI.UNPRESS_B(0)
    AI.END(); // End routine
    AI.add_cpu_input_routine(KEN_SMASH_SIDEB)

    KEN_SMASH_DOWNB:
    AI.UNPRESS_Z()
    AI.UNPRESS_A(0)
    AI.UNPRESS_B(0)
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    AI.STICK_Y(0xB0) // point stick down
    AI.PRESS_B(1)
    AI.UNPRESS_B(9)
    AI.UNPRESS_B(9)
    AI.UNPRESS_B(9)
    AI.UNPRESS_B(9)
    AI.UNPRESS_B(9)
    AI.STICK_Y(0)
    dh 0xA080 // stick x = tilt to opponent
    AI.PRESS_A(1) // light ftilt
    AI.UNPRESS_A(9)
    AI.END(); // End routine
    AI.add_cpu_input_routine(KEN_SMASH_DOWNB)

    KEN_DTILTS_HADOKEN:
    AI.UNPRESS_Z()
    AI.UNPRESS_A(0)
    AI.UNPRESS_B(0)
    AI.STICK_Y(-0x20, 1)
    AI.PRESS_A(1) // dtilt
    AI.UNPRESS_A(5)
    AI.UNPRESS_A(5)
    AI.PRESS_A(9) // hard dtilt
    AI.PRESS_A(9) // hold A for long enough
    AI.STICK_Y(0, 3)
    AI.PRESS_B(9) // hadouken
    AI.PRESS_B(5) // make sure it's the strong one
    AI.END(); // End routine
    AI.add_cpu_input_routine(KEN_DTILTS_HADOKEN)

    KEN_SHIELD_BREAK_FAR:
    AI.UNPRESS_Z()
    AI.UNPRESS_A(0)
    AI.UNPRESS_B(0)
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    AI.STICK_Y(0xB0)
    AI.PRESS_A(4) // dsmash
    AI.UNPRESS_A(9)
    AI.STICK_Y(0, 1)
    dh 0xA07F // stick x = dash to opponent
    AI.PRESS_B(9)
    AI.END(); // End routine
    AI.add_cpu_input_routine(KEN_SHIELD_BREAK_FAR)

    KEN_HARD_DTILT:
    AI.UNPRESS_Z()
    AI.STICK_X(0, 0)
    AI.STICK_Y(-0x28, 0)
    AI.PRESS_A(9)
    AI.UNPRESS_A(0)
    AI.END()
    AI.add_cpu_input_routine(KEN_HARD_DTILT)

    KEN_HARD_UTILT:
    AI.UNPRESS_Z()
    AI.STICK_X(0, 0)
    AI.STICK_Y(0x28, 0)
    AI.PRESS_A(9)
    AI.UNPRESS_A(0)
    AI.END()
    AI.add_cpu_input_routine(KEN_HARD_UTILT)

    KEN_HARD_FTILT:
    AI.UNPRESS_Z()
    dh 0xA080 // stick x = tilt to opponent
    AI.STICK_Y(0, 0)
    AI.PRESS_A(9)
    AI.UNPRESS_A(0)
    AI.END()
    AI.add_cpu_input_routine(KEN_HARD_FTILT)

    KEN_MASH_DTILT:
    AI.UNPRESS_Z()
    AI.UNPRESS_A(0)
    AI.UNPRESS_B(0)
    AI.STICK_X(0, 0)
    AI.STICK_Y(-0x28, 1)
    AI.PRESS_A(1)
    AI.UNPRESS_A(9)
    AI.UNPRESS_A(5)
    AI.PRESS_A(1)
    AI.UNPRESS_A(9)
    AI.UNPRESS_A(5)
    AI.PRESS_A(1)
    AI.UNPRESS_A(9)
    AI.UNPRESS_A(5)
    AI.END()
    AI.add_cpu_input_routine(KEN_MASH_DTILT)

    KEN_MASH_UTILT:
    AI.UNPRESS_Z()
    AI.UNPRESS_A(0)
    AI.UNPRESS_B(0)
    AI.STICK_X(0, 0)
    AI.STICK_Y(0x28, 1)
    AI.PRESS_A(1)
    AI.UNPRESS_A(9)
    AI.UNPRESS_A(5)
    AI.PRESS_A(1)
    AI.UNPRESS_A(9)
    AI.UNPRESS_A(5)
    AI.PRESS_A(1)
    AI.UNPRESS_A(9)
    AI.UNPRESS_A(5)
    AI.END()
    AI.add_cpu_input_routine(KEN_MASH_UTILT)

    KEN_AIRU_SHORYUKEN:
    AI.UNPRESS_Z()
    AI.UNPRESS_A()
    AI.UNPRESS_B()
    AI.STICK_X(0)
    AI.STICK_Y(0x28, 1)
    AI.PRESS_A(5)
    AI.UNPRESS_A(0)
    dh 0xA080 // stick x = tilt to opponent
    AI.PRESS_B(9)
    AI.PRESS_B(9)
    AI.UNPRESS_B(0)
    AI.END()
    AI.add_cpu_input_routine(KEN_AIRU_SHORYUKEN)

    KEN_AIRN_HADOUKEN:
    AI.UNPRESS_Z()
    AI.UNPRESS_A()
    AI.UNPRESS_B()
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    AI.PRESS_A(5)
    AI.UNPRESS_A(0)
    dh 0xA080 // stick x = tilt to opponent
    AI.PRESS_B(9)
    AI.PRESS_B(9)
    AI.UNPRESS_B(0)
    AI.END()
    AI.add_cpu_input_routine(KEN_AIRN_HADOUKEN)

    KEN_HARD_JAB_SHORYUKEN:
    AI.UNPRESS_Z()
    AI.UNPRESS_A()
    AI.UNPRESS_B()
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    AI.PRESS_A(9)
    AI.UNPRESS_A(0)
    AI.STICK_Y(0x28, 0)
    dh 0xA080 // stick x = tilt to opponent
    AI.PRESS_B(9)
    AI.UNPRESS_A(0)
    AI.END()
    AI.add_cpu_input_routine(KEN_HARD_JAB_SHORYUKEN)

    KEN_FTILT_SHORYUKEN:
    AI.UNPRESS_Z()
    AI.UNPRESS_A()
    AI.UNPRESS_B()
    dh 0xA080 // stick x = tilt to opponent
    AI.STICK_Y(0, 1)
    AI.PRESS_A(9)
    AI.UNPRESS_A(0)
    AI.STICK_Y(0x28, 0)
    dh 0xA080 // stick x = tilt to opponent
    AI.PRESS_B(9)
    AI.UNPRESS_A(0)
    AI.UNPRESS_B(0)
    AI.END()
    AI.add_cpu_input_routine(KEN_FTILT_SHORYUKEN)

    KEN_JAB_JAB_SHORYUKEN:
    AI.UNPRESS_Z()
    AI.UNPRESS_A()
    AI.UNPRESS_B()
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    AI.PRESS_A(1)
    AI.UNPRESS_A(9)
    AI.UNPRESS_A(9)
    AI.PRESS_A(1)
    AI.UNPRESS_A(9)
    AI.STICK_Y(0x28, 0)
    dh 0xA080 // stick x = tilt to opponent
    AI.PRESS_B(9)
    AI.UNPRESS_A(0)
    AI.UNPRESS_B(0)
    AI.END()
    AI.add_cpu_input_routine(KEN_JAB_JAB_SHORYUKEN)

    OS.align(4)
    CPU_ATTACKS:
    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.add_attack_behaviour(USPG, 2, 128, 314, 240, 471)
    AI.add_custom_attack_behaviour(AI.ROUTINE.KEN_DTILTS_HADOKEN, 3, -412, 412, -8, 144)
    AI.add_custom_attack_behaviour(AI.ROUTINE.KEN_FTILT_SHORYUKEN, 3, 206, 408, 163, 500)
    AI.add_custom_attack_behaviour(AI.ROUTINE.KEN_MASH_UTILT, 3, -255, 255, 375, 570)
    AI.add_custom_attack_behaviour(AI.ROUTINE.KEN_MASH_DTILT, 3, -412, 412, -8, 144)
    AI.add_custom_attack_behaviour(AI.ROUTINE.KEN_JAB_JAB_SHORYUKEN, 4, -356, 356, 292, 392)
    AI.add_attack_behaviour(JAB, 4, -356, 356, 292, 392)
    AI.add_custom_attack_behaviour(AI.ROUTINE.KEN_SHIELD_BREAK_FAR, 5, -564, 564, 12, 150)
    AI.add_attack_behaviour(DSMASH, 5, -564, 564, 12, 150)
    AI.add_attack_behaviour(GRAB, 6, 240, 390, 263, 413)
    AI.add_custom_attack_behaviour(AI.ROUTINE.KEN_HARD_JAB_SHORYUKEN, 7, 111, 452, 210, 703)
    AI.add_custom_attack_behaviour(AI.ROUTINE.KEN_HARD_DTILT, 7, -590, 590, -12, 152)
    AI.add_custom_attack_behaviour(AI.ROUTINE.KEN_HARD_UTILT, 7, -452, 452, 333, 703)
    AI.add_attack_behaviour(USMASH, 9, -416, 416, 191, 758)
    AI.add_attack_behaviour(DSPG, 8, 142, 836, 282, 434)
    AI.add_attack_behaviour(FTILT, 9, -20, 461, 289, 487)
    AI.add_custom_attack_behaviour(AI.ROUTINE.KEN_HARD_FTILT, 10, 166, 527, 365, 520)
    AI.add_custom_attack_behaviour(AI.ROUTINE.KEN_SMASH_DOWNB, 11, 465, 465, 190, 623)
    AI.add_custom_attack_behaviour(AI.ROUTINE.KEN_SMASH_SIDEB, 11, 280, 692, 325, 584)
    AI.add_attack_behaviour(FSMASH, 13, 335, 825, 264, 448)
    AI.add_attack_behaviour(NSPG, 12, 600, 2000, 100, 480)
    AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 7, 362, 929, 246, 439)
    AI.END_ATTACKS() // end of grounded attacks
    
    AI.add_attack_behaviour(USPA, 2, 128, 314, 240, 471)
    AI.add_custom_attack_behaviour(AI.ROUTINE.KEN_AIRU_SHORYUKEN, 5, 61, 315, 426, 698)
    AI.add_attack_behaviour(UAIR, 5, 61, 315, 426, 698)
    AI.add_attack_behaviour(UAIR, 5+4, 61, 315, 426, 698)
    AI.add_custom_attack_behaviour(AI.ROUTINE.KEN_AIRN_HADOUKEN, 6, -156, 401, 94, 302)
    AI.add_attack_behaviour(NAIR, 6, -156, 401, 94, 302)
    AI.add_attack_behaviour(NAIR, 6+4, -156, 401, 94, 302) // late hit
    AI.add_attack_behaviour(NAIR, 6+8, -156, 401, 94, 302) // later hit
    AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 8, 20, 385, 65, 205)
    AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 8, -528, -165, 235, 445)
    AI.add_attack_behaviour(DAIR, 8, 211, 401, -14, 184)
    AI.add_attack_behaviour(DAIR, 8+4, 211, 401, -14, 184)
    AI.add_attack_behaviour(DSPA, 8, 142, 836, 282, 434)
    AI.add_attack_behaviour(NSPA, 12, 600, 2000, 100, 480)
    AI.END_ATTACKS() // end of aerial attacks
    OS.align(16)

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.KEN, 0x4)
    dw CPU_ATTACKS
    OS.patch_end()

    // Set CPU NSP long range behaviour
    Character.table_patch_start(ai_long_range, Character.id.KEN, 0x4)
    dw AI.LONG_RANGE.ROUTINE.NSP_SHOOT
    OS.patch_end()

    // Set CPU SD prevent routine
    Character.table_patch_start(ai_attack_prevent, Character.id.KEN, 0x4)
    dw AI.PREVENT_ATTACK.ROUTINE.MARIO
    OS.patch_end()

    // @ Description
    // Ken's extra actions
    scope Action {
        string_0x0E4:; String.insert("Hadouken")
        string_0x0E5:; String.insert("HadoukenAir")
        string_0x0E6:; String.insert("TatsumakiStart")
        string_0x0E9:; String.insert("TatsumakiStartAir")

        string_0x0F2:; String.insert("ShoryukenLight")
        string_0x0F3:; String.insert("ShoryukenLightAir")
        string_0x0F4:; String.insert("JabLight1")
        string_0x0F5:; String.insert("JabLight2")
        string_0x0F6:; String.insert("JabLight3")
        string_0x0F7:; String.insert("DTiltLight")
        string_0x0F8:; String.insert("UTiltLight")
        string_0x0F9:; String.insert("FTiltLight")
        string_0x0FA:; String.insert("JabClose")
        string_0x0FB:; String.insert("FTiltClose")
        string_0x0FC:; String.insert("TatsumakiLight")
        string_0x0FD:; String.insert("TatsumakiStrong")
        string_0x0FE:; String.insert("TatsumakiAir")
        string_0x0FF:; String.insert("TatsumakiEnd")
        string_0x100:; String.insert("TatsumakiEndAir")
        string_0x101:; String.insert("ShoryukenStrong")
        string_0x102:; String.insert("ShoryukenStrongAir")
        string_0x103:; String.insert("ShoryukenFall")
        string_0x104:; String.insert("OosotoMawashiGeri")
        string_0x105:; String.insert("InazumaKick")
        string_0x106:; String.insert("NataOtoshiGeri")
        string_0x107:; String.insert("ShoryukenFall")

        action_string_table:
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw string_0x0E4
        dw string_0x0E5
        dw string_0x0E6
        dw 0
        dw 0
        dw string_0x0E9
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw string_0x0F2
        dw string_0x0F3
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
        dw string_0x101
        dw string_0x102
        dw string_0x103
        dw string_0x104
        dw string_0x105
        dw string_0x106
        dw string_0x107
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.KEN, 0x4)
    dw Action.action_string_table
    OS.patch_end()

    KEN_RECOVERY: {
        OS.routine_begin(0x20)

        lw v0, 0x0024(a0) // v0 = current action ID
        addiu at, r0, Ken.Action.USP_AIR_L // at = Light USP
        beq at, v0, _upB
        nop

        lw v0, 0x0024(a0) // v0 = current action ID
        addiu at, r0, Action.JumpAerialF // at = JumpAerialF
        beq at, v0, _helicopter_downB
        nop

        b _end // no override
        nop

        _upB:
        lh v0, 0x01C6(a0) // v0 = buttons pressed
        ori v0, v0, 0x4000 // press B
        sh v0, 0x01C6(a0) // save press B mask
        b _end
        nop

        scope _helicopter_downB: {
            lw t0, 0x78(a0) // load location vector
            lwc1 f2, 0x0(t0) // f2 = location X
            lwc1 f4, 0x4(t0) // f4 = location Y

            mtc1 r0, f0 // guarantee f0 = 0

            // check if facing ledge
            scope direction_check: {
                lw t0, 0x44(a0) // t0 = player facing direction

                bltz t0, _recovering_left
                nop

                _recovering_right:
                lwc1 f6, 0x01CC+0x4c(a0) // load nearest LEFT ledge X
                lwc1 f8, 0x01CC+0x50(a0) // load nearest LEFT ledge Y

                sub.s f14, f6, f2 // f14 = x diff
                sub.s f12, f8, f4 // f12 = y diff

                c.le.s f14, f0 // if going reverse, skip
                nop
                bc1t _end // do not try to DSP when not facing ledge
                nop
                
                b _check_end
                nop

                _recovering_left:
                lwc1 f6, 0x01CC+0x54(a0) // load nearest RIGHT ledge X
                lwc1 f8, 0x01CC+0x58(a0) // load nearest RIGHT ledge Y

                sub.s f14, f6, f2 // f14 = x diff
                sub.s f12, f8, f4 // f12 = y diff

                c.le.s f0, f14 // if going reverse, skip
                nop
                bc1t _end // do not try to DSP when not facing ledge
                nop

                _check_end:
            }

            lui at, 0x44BB
            mtc1 at, f22 // f22 = ~1500.0

            abs.s f16, f14 // f16 = abs(x distance to ledge)

            c.le.s f16, f22 // if distance to ledge is lower than threshold
            nop
            bc1t _end // do not go for DSP if already close to ledge
            nop

            _execute:
            jal 0x80132758 // execute AI command
            addiu a1, r0, AI.ROUTINE.DSP // arg1 = use downB
            b _end
            nop
        }

        _end:
        OS.routine_end(0x20)
    }
    Character.table_patch_start(recovery_logic, Character.id.KEN, 0x4)
    dw KEN_RECOVERY
    OS.patch_end()
}