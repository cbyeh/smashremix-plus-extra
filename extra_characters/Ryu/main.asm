include "./RyuSpecial.asm"

// This file contains file inclusions, action edits, and assembly for Ryu.

scope Ryu {
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
    Character.edit_action_parameters(RYU, Action.Entry, File.RYU_ANIM_IDLE, IDLE, -1)
    Character.edit_action_parameters(RYU, 0x006, File.RYU_ANIM_IDLE, IDLE, -1)
    Character.edit_action_parameters(RYU, Action.Idle, File.RYU_ANIM_IDLE, IDLE, -1)
    Character.edit_action_parameters(RYU, Action.Revive1, File.RYU_ANIM_DOWNBOUNCED, -1, -1)
    Character.edit_action_parameters(RYU, Action.ReviveWait, File.RYU_ANIM_IDLE, -1, -1) 
    Character.edit_action_parameters(RYU, Action.Dash, File.RYU_ANIM_DASH, -1, -1)
    Character.edit_action_parameters(RYU, Action.Walk1, File.RYU_ANIM_WALK1, -1, -1)
    Character.edit_action_parameters(RYU, Action.Walk2, File.RYU_ANIM_WALK2, -1, -1)
    Character.edit_action_parameters(RYU, Action.Walk3, File.RYU_ANIM_WALK3, -1, -1)
    Character.edit_action_parameters(RYU, Action.Teeter, File.RYU_ANIM_TEETER, IDLE, -1)
    Character.edit_action_parameters(RYU, Action.TeeterStart, File.RYU_ANIM_TEETERSTART, IDLE, -1)
    Character.edit_action_parameters(RYU, Action.Fall, File.RYU_ANIM_FALL, -1, 0x00000000)
    Character.edit_action_parameters(RYU, Action.FallAerial, File.RYU_ANIM_FALLAERIAL, -1, 0x00000000)
    Character.edit_action_parameters(RYU, Action.FallSpecial, File.RYU_ANIM_FALLSPECIAL, -1, -1)
    Character.edit_action_parameters(RYU, Action.JumpF, File.RYU_ANIM_JUMPF, JUMP, 0x00000000)
    Character.edit_action_parameters(RYU, Action.JumpB, File.RYU_ANIM_JUMPB, JUMP, 0x80000000)
    Character.edit_action_parameters(RYU, Action.Grab, File.RYU_ANIM_GRAB, GRAB_, -1)
    Character.edit_action_parameters(RYU, Action.GrabPull, File.RYU_ANIM_GRABPULL, -1, -1)
    Character.edit_action_parameters(RYU, Action.ThrowF, File.RYU_ANIM_THROWF, CUSTOM_THROWF, 0x10000000)
    Character.edit_action_parameters(RYU, Action.ThrowB, File.RYU_ANIM_THROWB, CUSTOM_THROWB, 0x50000000)
    Character.edit_action_parameters(RYU, Action.JumpAerialF, File.RYU_ANIM_JUMPAIRF, JUMP_AERIAL, -1)
    Character.edit_action_parameters(RYU, Action.JumpAerialB, File.RYU_ANIM_JUMPAIRB, JUMP_AERIAL, 0x00000000)
    Character.edit_action_parameters(RYU, Action.TechF, -1, TECHFROLL, -1)
    Character.edit_action_parameters(RYU, Action.TechB, -1, TECHFROLL, -1)
    Character.edit_action_parameters(RYU, Action.Tech, -1, TECHSTAND, -1)
    Character.edit_action_parameters(RYU, Action.CliffCatch, -1, CLIFFCATCH, -1)
    Character.edit_action_parameters(RYU, Action.CliffWait, -1, CLIFFWAIT, -1)
    Character.edit_action_parameters(RYU, Action.CliffQuick, -1, CLIFFQUICK, -1)
    Character.edit_action_parameters(RYU, Action.CliffSlow, -1, CLIFFSLOW, -1)
    Character.edit_action_parameters(RYU, Action.CliffAttackQuick2, -1, EDGEATTACKF, -1)
    Character.edit_action_parameters(RYU, Action.CliffAttackSlow2, -1, EDGEATTACKS, -1)
    Character.edit_action_parameters(RYU, Action.Taunt, File.RYU_ANIM_TAUNT, TAUNT, -1)
    Character.edit_action_parameters(RYU, Action.ShieldBreak, -1, SHIELD_BREAK_, -1)
    Character.edit_action_parameters(RYU, Action.Stun, -1, STUN_, -1)
    Character.edit_action_parameters(RYU, Action.Jab1, File.RYU_ANIM_JABH, ROUNDHOUSE, 0)
    Character.edit_action_parameters(RYU, Action.DashAttack, File.RYU_ANIM_DASHATTACK, DASH_ATTACK, 0x40000000)
    Character.edit_action_parameters(RYU, Action.FTiltHigh, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(RYU, Action.FTiltMidHigh, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(RYU, Action.FTilt, File.RYU_ANIM_TILTFH, FTILTH, 0x40000000)
    Character.edit_action_parameters(RYU, Action.FTiltMidLow, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(RYU, Action.FTiltLow, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(RYU, Action.UTilt, File.RYU_ANIM_TILTUH, UTILTH, 0x00000000)
    Character.edit_action_parameters(RYU, Action.DTilt, File.RYU_ANIM_TILTDH, DTILTH, 0)
    Character.edit_action_parameters(RYU, Action.FSmashHigh, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(RYU, Action.FSmash, File.RYU_ANIM_SMASHF, FSMASH, 0x40000000)
    Character.edit_action_parameters(RYU, Action.FSmashLow, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(RYU, Action.USmash, File.RYU_ANIM_SMASHU, USMASH, 0x40000000)
    Character.edit_action_parameters(RYU, Action.DSmash, File.RYU_ANIM_SMASHD, DSMASH, -1)
    Character.edit_action_parameters(RYU, Action.AttackAirN, File.RYU_ANIM_AIRN, NAIR, -1)
    Character.edit_action_parameters(RYU, Action.AttackAirF, File.RYU_ANIM_AIRF, FAIR, -1)
    Character.edit_action_parameters(RYU, Action.AttackAirB, File.RYU_ANIM_AIRB, BAIR, -1)
    Character.edit_action_parameters(RYU, Action.AttackAirU, File.RYU_ANIM_AIRU, UAIR, -1)
    Character.edit_action_parameters(RYU, Action.AttackAirD, File.RYU_ANIM_AIRD, DAIR, -1)
    Character.edit_action_parameters(RYU, Action.LandingAirF, 0, 0x80000000, -1)
    Character.edit_action_parameters(RYU, Action.LandingAirB, File.RYU_ANIM_LANDINGAIRB, -1, -1)
    Character.edit_action_parameters(RYU, 0xE0, File.RYU_ANIM_ENTRYR, ENTRY, 0x40000009)
    Character.edit_action_parameters(RYU, 0xE1, File.RYU_ANIM_ENTRYL, ENTRY, 0x40000009)
    Character.edit_action_parameters(RYU, 0xE4, File.RYU_ANIM_HADOUKENGND, NSP_AIR, 0x40000000)
    Character.edit_action_parameters(RYU, 0xE5, File.RYU_ANIM_HADOUKENGND, NSP_AIR, 0x40000000)
    Character.edit_action_parameters(RYU, 0xE6, File.RYU_ANIM_DSPSTART, dspStart, 0x40000000)
    Character.edit_action_parameters(RYU, 0xE9, File.RYU_ANIM_DSPAIRSTART, dspAirStart, 0x0) // aerial dsp
    Character.edit_action_parameters(RYU, Action.Crouch, File.RYU_ANIM_CROUCHSTART, -1, -1)
    Character.edit_action_parameters(RYU, Action.CrouchIdle, File.RYU_ANIM_CROUCHWAIT, -1, -1)
    Character.edit_action_parameters(RYU, Action.CrouchEnd, File.RYU_ANIM_CROUCHEND, -1, -1)
    
    Character.edit_action_parameters(RYU, Action.Run, File.RYU_ANIM_RUN, RUN_, -1)
    Character.edit_action_parameters(RYU, Action.RunBrake, File.RYU_ANIM_RUNBRAKE, -1, -1)
    Character.edit_action_parameters(RYU, Action.Turn, File.RYU_ANIM_TURN, -1, -1);
    Character.edit_action_parameters(RYU, Action.TurnRun, File.RYU_ANIM_TURNRUN, RUNTURN, -1);

    Character.edit_action_parameters(RYU, Action.DownBounceD, File.RYU_ANIM_DOWNBOUNCED, -1, -1)
    Character.edit_action_parameters(RYU, Action.DownBounceU, File.RYU_ANIM_DOWNBOUNCEU, -1, -1)

    Character.edit_action_parameters(RYU, Action.ClangRecoil, File.RYU_ANIM_CLANGRECOIL, -1, -1);

    Character.edit_action_parameters(RYU, Action.JumpSquat, File.RYU_ANIM_JUMPSQUAT, -1, -1);
    Character.edit_action_parameters(RYU, Action.ShieldJumpSquat, File.RYU_ANIM_JUMPSQUAT, -1, -1);
    Character.edit_action_parameters(RYU, Action.LandingLight, File.RYU_ANIM_JUMPSQUAT, -1, -1);
    Character.edit_action_parameters(RYU, Action.LandingHeavy, File.RYU_ANIM_LANDINGHEAVY, -1, -1);
    Character.edit_action_parameters(RYU, Action.LandingAirX, File.RYU_ANIM_LANDINGHEAVY, -1, -1);
    Character.edit_action_parameters(RYU, Action.LandingSpecial, File.RYU_ANIM_SPECIALLAND, -1, -1);

    Character.edit_action_parameters(RYU, Action.ShieldOn, File.RYU_ANIM_SHIELDON, -1, 0xA0000000);
    Character.edit_action_parameters(RYU, Action.ShieldOff, File.RYU_ANIM_SHIELDOFF, -1, 0xA0000000);

    Character.edit_action_parameters(RYU, Action.Pass, File.RYU_ANIM_PASS_PLATDROP, -1, -1)
    Character.edit_action_parameters(RYU, Action.ShieldDrop, File.RYU_ANIM_PASS_PLATDROP, -1, -1)

    Character.edit_action_parameters(RYU, Action.DamageMid1, File.RYU_ANIM_DAMAGEN1, -1, -1)
    Character.edit_action_parameters(RYU, Action.DamageMid2, File.RYU_ANIM_DAMAGEN2, -1, -1)
    Character.edit_action_parameters(RYU, Action.DamageMid3, File.RYU_ANIM_DAMAGEN3, -1, -1)
    Character.edit_action_parameters(RYU, Action.DamageHigh1, File.RYU_ANIM_DAMAGEHI1, -1, -1)
    Character.edit_action_parameters(RYU, Action.DamageHigh2, File.RYU_ANIM_DAMAGEHI2, -1, -1)
    Character.edit_action_parameters(RYU, Action.DamageHigh3, File.RYU_ANIM_DAMAGEHI3, -1, -1)
    Character.edit_action_parameters(RYU, Action.DamageLow1, File.RYU_ANIM_DAMAGELOW1, -1, -1)
    Character.edit_action_parameters(RYU, Action.DamageLow2, File.RYU_ANIM_DAMAGELOW2, -1, -1)
    Character.edit_action_parameters(RYU, Action.DamageLow3, File.RYU_ANIM_DAMAGELOW3, -1, -1)
    Character.edit_action_parameters(RYU, Action.DamageAir1, File.RYU_ANIM_DAMAGEAIR1, -1, -1)
    Character.edit_action_parameters(RYU, Action.DamageAir2, File.RYU_ANIM_DAMAGEAIR2, -1, -1)
    Character.edit_action_parameters(RYU, Action.DamageAir3, File.RYU_ANIM_DAMAGEAIR3, -1, -1)
    Character.edit_action_parameters(RYU, Action.DamageFlyHigh, File.RYU_ANIM_DAMAGEFLYHI, -1, -1)
    Character.edit_action_parameters(RYU, Action.DamageFlyLow, File.RYU_ANIM_DAMAGEFLYLOW, -1, -1)
    Character.edit_action_parameters(RYU, Action.DamageFlyMid, File.RYU_ANIM_DAMAGEFLYN, -1, -1)
    Character.edit_action_parameters(RYU, Action.WallBounce, File.RYU_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(RYU, Action.Tumble, File.RYU_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(RYU, Action.DamageFlyRoll, File.RYU_ANIM_DAMAGEFLYROLL, -1, -1)
    Character.edit_action_parameters(RYU, Action.DamageFlyTop, File.RYU_ANIM_DAMAGEFLYTOP, -1, -1)

    Character.edit_action_parameters(RYU, Action.RollF, File.RYU_ANIM_ROLLF, -1, -1)
    Character.edit_action_parameters(RYU, Action.RollB, File.RYU_ANIM_ROLLB, -1, -1)

    Character.edit_action_parameters(RYU, Action.DownAttackD, File.RYU_ANIM_DOWNATTACKD, -1, -1)
    Character.edit_action_parameters(RYU, Action.DownAttackU, File.RYU_ANIM_DOWNATTACKU, -1, -1)
    Character.edit_action_parameters(RYU, Action.DownStandD, File.RYU_ANIM_DOWNSTANDD, -1, -1);
    Character.edit_action_parameters(RYU, Action.DownStandU, File.RYU_ANIM_DOWNSTANDU, -1, -1);
    Character.edit_action_parameters(RYU, Action.Tech, File.RYU_ANIM_TECH, -1, -1);
    Character.edit_action_parameters(RYU, Action.TechF, File.RYU_ANIM_TECHF, -1, -1)
    Character.edit_action_parameters(RYU, Action.TechB, File.RYU_ANIM_TECHB, -1, -1)
    Character.edit_action_parameters(RYU, Action.DownForwardD, File.RYU_ANIM_DOWNFORWARDD, -1, -1)
    Character.edit_action_parameters(RYU, Action.DownForwardU, File.RYU_ANIM_DOWNFORWARDU, -1, -1)
    Character.edit_action_parameters(RYU, Action.DownBackD, File.RYU_ANIM_DOWNBACKD, -1, -1)
    Character.edit_action_parameters(RYU, Action.DownBackU, File.RYU_ANIM_DOWNBACKU, -1, -1)

    Character.edit_action_parameters(RYU, Action.LightItemPickup,    File.RYU_ANIM_LIGHTGET,        LIGHT_ITEM_PICKUP,       -1)
    Character.edit_action_parameters(RYU, Action.ItemDrop,           File.RYU_ANIM_LIGHTDROP,       ITEM_DROP,                -1)
    Character.edit_action_parameters(RYU, Action.ItemThrowDash,      File.RYU_ANIM_LIGHTTHROWDASH,  ITEM_THROW_DASH,          -1)
    Character.edit_action_parameters(RYU, Action.ItemThrowF,         File.RYU_ANIM_LIGHTTHROWF,     ITEM_THROW_F,             -1)
    Character.edit_action_parameters(RYU, Action.ItemThrowB,         File.RYU_ANIM_LIGHTTHROWF,     ITEM_THROW_B,             -1)
    Character.edit_action_parameters(RYU, Action.ItemThrowU,         File.RYU_ANIM_LIGHTTHROWU,     ITEM_THROW_U,             -1)
    Character.edit_action_parameters(RYU, Action.ItemThrowD,         File.RYU_ANIM_LIGHTTHROWD,     ITEM_THROW_D,             -1)
    Character.edit_action_parameters(RYU, Action.ItemThrowSmashF,    File.RYU_ANIM_LIGHTTHROWF,     ITEM_THROW_SMASH_F,       -1)
    Character.edit_action_parameters(RYU, Action.ItemThrowSmashB,    File.RYU_ANIM_LIGHTTHROWF,     ITEM_THROW_SMASH_B,       -1)
    Character.edit_action_parameters(RYU, Action.ItemThrowSmashU,    File.RYU_ANIM_LIGHTTHROWU,     ITEM_THROW_SMASH_U,       -1)
    Character.edit_action_parameters(RYU, Action.ItemThrowSmashD,    File.RYU_ANIM_LIGHTTHROWD,     ITEM_THROW_SMASH_D,       -1)
    Character.edit_action_parameters(RYU, Action.ItemThrowAirF,      File.RYU_ANIM_LIGHTTHROWAIRF,  ITEM_THROW_AIR_F,         -1)
    Character.edit_action_parameters(RYU, Action.ItemThrowAirB,      File.RYU_ANIM_LIGHTTHROWAIRF,  ITEM_THROW_AIR_B,         -1)
    Character.edit_action_parameters(RYU, Action.ItemThrowAirU,      File.RYU_ANIM_LIGHTTHROWAIRU,  ITEM_THROW_AIR_U,         -1)
    Character.edit_action_parameters(RYU, Action.ItemThrowAirD,      File.RYU_ANIM_LIGHTTHROWAIRD,  ITEM_THROW_AIR_D,         -1)
    Character.edit_action_parameters(RYU, Action.ItemThrowAirSmashF, File.RYU_ANIM_LIGHTTHROWAIRF,  ITEM_THROW_AIR_SMASH_F,   -1)
    Character.edit_action_parameters(RYU, Action.ItemThrowAirSmashB, File.RYU_ANIM_LIGHTTHROWAIRF,  ITEM_THROW_AIR_SMASH_B,   -1)
    Character.edit_action_parameters(RYU, Action.ItemThrowAirSmashU, File.RYU_ANIM_LIGHTTHROWAIRU,  ITEM_THROW_AIR_SMASH_U,   -1)
    Character.edit_action_parameters(RYU, Action.ItemThrowAirSmashD, File.RYU_ANIM_LIGHTTHROWAIRD,  ITEM_THROW_AIR_SMASH_D,   -1)

    Character.edit_action_parameters(RYU, Action.RayGunShoot,        File.RYU_ANIM_ITEMSHOOT,       -1, 0x00000000)
    Character.edit_action_parameters(RYU, Action.RayGunShootAir,     File.RYU_ANIM_ITEMSHOOTAIR,    -1, 0x00000000)
    Character.edit_action_parameters(RYU, Action.FireFlowerShoot,    File.RYU_ANIM_ITEMSHOOT,       -1, 0x00000000)
    Character.edit_action_parameters(RYU, Action.FireFlowerShootAir, File.RYU_ANIM_ITEMSHOOTAIR,    -1, 0x00000000)

    Character.edit_action_parameters(RYU, Action.HammerIdle,         File.RYU_ANIM_HAMMER,          HAMMER, -1)
    Character.edit_action_parameters(RYU, Action.HammerWalk,         File.RYU_ANIM_HAMMER,          HAMMER, -1)
    Character.edit_action_parameters(RYU, Action.HammerTurn,         File.RYU_ANIM_HAMMER,          HAMMER, -1)
    Character.edit_action_parameters(RYU, Action.HammerJumpSquat,    File.RYU_ANIM_HAMMER,          HAMMER, -1)
    Character.edit_action_parameters(RYU, Action.HammerAir,          File.RYU_ANIM_HAMMER,          HAMMER, -1)
    Character.edit_action_parameters(RYU, Action.HammerLanding,      File.RYU_ANIM_HAMMER,          HAMMER, -1)

    Character.edit_action_parameters(RYU, Action.BeamSwordNeutral,   File.RYU_ANIM_SWING1,          BEAMSWORD_JAB,   -1)
    Character.edit_action_parameters(RYU, Action.BeamSwordTilt,      File.RYU_ANIM_SWING3,          BEAMSWORD_TILT,  -1)
    Character.edit_action_parameters(RYU, Action.BeamSwordSmash,     File.RYU_ANIM_SWING4,          BEAMSWORD_SMASH, -1)
    Character.edit_action_parameters(RYU, Action.BeamSwordDash,      File.RYU_ANIM_SWINGDASH,       BEAMSWORD_DASH,  -1)
    Character.edit_action_parameters(RYU, Action.BatNeutral,         File.RYU_ANIM_SWING1,          BAT_JAB,         -1)
    Character.edit_action_parameters(RYU, Action.BatTilt,            File.RYU_ANIM_SWING3,          BAT_TILT,        -1)
    Character.edit_action_parameters(RYU, Action.BatSmash,           File.RYU_ANIM_SWING4,          BAT_SMASH,       -1)
    Character.edit_action_parameters(RYU, Action.BatDash,            File.RYU_ANIM_SWINGDASH,       BAT_DASH,        -1)
    Character.edit_action_parameters(RYU, Action.FanNeutral,         File.RYU_ANIM_SWING1,          FAN_JAB,         -1)
    Character.edit_action_parameters(RYU, Action.FanTilt,            File.RYU_ANIM_SWING3,          FAN_TILT,        -1)
    Character.edit_action_parameters(RYU, Action.FanSmash,           File.RYU_ANIM_SWING4,          FAN_SMASH,       -1)
    Character.edit_action_parameters(RYU, Action.FanDash,            File.RYU_ANIM_SWINGDASH,       FAN_DASH,        -1)
    Character.edit_action_parameters(RYU, Action.StarRodNeutral,     File.RYU_ANIM_SWING1,          STARROD_JAB,     -1)
    Character.edit_action_parameters(RYU, Action.StarRodTilt,        File.RYU_ANIM_SWING3,          STARROD_TILT,    -1)
    Character.edit_action_parameters(RYU, Action.StarRodSmash,       File.RYU_ANIM_SWING4,          STARROD_SMASH,   -1)
    Character.edit_action_parameters(RYU, Action.StarRodDash,        File.RYU_ANIM_SWINGDASH,       STARROD_DASH,    -1)

    // Modify Actions // Action // Staling ID // Main ASM // Interrupt/Other ASM // Movement/Physics ASM // Collision ASM
    Character.edit_action(RYU, 0xE0, -1, 0x8013DA94, 0, 0x8013DB2C, 0x800DE348) // LEFT ENTRY
    Character.edit_action(RYU, 0xE1, -1, 0x8013DA94, 0, 0x8013DB2C, 0x800DE348) // RIGHT ENTRY
    
    Character.edit_action(RYU, 0xE4, -1, RyuSpecial.NSP.main, RyuSpecial.NSP.change_direction_, RyuSpecial.NSP.physics_, -1)
    Character.edit_action(RYU, 0xE5, -1, RyuSpecial.NSP.main, RyuSpecial.NSP.change_direction_, RyuSpecial.NSP.physics_, RyuSpecial.NSP.air_collision_)
    
    Character.edit_action(RYU, 0xE6, -1, RyuSpecial.DSP.Start.main, 0, RyuSpecial.DSP.Start.physics, 0x800DDF44)
    Character.edit_action(RYU, 0xE9, -1, RyuSpecial.DSP.Start.main, 0, RyuSpecial.DSP.Start.physics, 0x800DE978)

    // Add Action Parameters // Action Name // Base Action // Animation // Moveset Data // Flags
    Character.add_new_action_params(RYU, JAB_H, -1, File.RYU_ANIM_JABH, ROUNDHOUSE, 0x0)
    Character.add_new_action_params(RYU, DTILT_H, -1, File.RYU_ANIM_TILTDH, DTILTH, 0x00000000)
    Character.add_new_action_params(RYU, UTILT_H, -1, File.RYU_ANIM_TILTUH, UTILTH, 0x00000000)
    Character.add_new_action_params(RYU, FTILT_H, -1, File.RYU_ANIM_TILTFH, FTILTH, 0x40000000)
    Character.add_new_action_params(RYU, USP_L, -1, File.RYU_ANIM_SHORYUKEN, USP_L, 0x40000000)
    Character.add_new_action_params(RYU, USP_AIR_L, -1, File.RYU_ANIM_SHORYUKEN, USP_L, 0x40000000)
    Character.add_new_action_params(RYU, JAB_L, -1, File.RYU_ANIM_JAB1, JAB_1, 0x00000000)
    Character.add_new_action_params(RYU, JAB_L2, -1, File.RYU_ANIM_JAB2, JAB_2, 0x40000000)
    Character.add_new_action_params(RYU, JAB_L3, -1, File.RYU_ANIM_JAB3, JAB_3, 0x40000000)
    Character.add_new_action_params(RYU, DTILT_L, -1, File.RYU_ANIM_TILTD, DTILTL, 0x00000000)
    Character.add_new_action_params(RYU, UTILT_L, -1, File.RYU_ANIM_TILTU, UTILTL, 0x00000000)
    Character.add_new_action_params(RYU, FTILT_L, -1, File.RYU_ANIM_TILTF, FTILTL, 0x40000000)
    Character.add_new_action_params(RYU, JAB_CLOSE, -1, File.RYU_ANIM_TILTUH, JAB_CLOSE, 0x00000000)
    Character.add_new_action_params(RYU, FTILT_CLOSE, -1, File.RYU_ANIM_TILTFCLOSE, FTILTCLOSE, 0x00000000)
    Character.add_new_action_params(RYU, DSP_L, 0xE6, File.RYU_ANIM_DSPLOOP, DSP_L, 0x0)
    Character.add_new_action_params(RYU, DSP_H, 0xE6, File.RYU_ANIM_DSPLOOP, dspH, 0x0)
    Character.add_new_action_params(RYU, DSP_AIR, 0xE6, File.RYU_ANIM_DSPLOOP, dspAirLoop, 0x0)
    Character.add_new_action_params(RYU, DSP_END, 0xE6, File.RYU_ANIM_DSPEND, dspEnd, 0x0)
    Character.add_new_action_params(RYU, DSP_AIREND, 0xE6, File.RYU_ANIM_DSPAIREND, 0x0, 0x0)
    Character.add_new_action_params(RYU, USP_H, -1, File.RYU_ANIM_SHORYUKEN, USP_H, 0x40000000)
    Character.add_new_action_params(RYU, USP_AIR_H, -1, File.RYU_ANIM_SHORYUKEN, USP_H, 0x40000000)
    Character.add_new_action_params(RYU, USP_FALL, -1, File.RYU_ANIM_SPECIALHI2, -1, 0x0)

    // Add Actions // Action Name // Base Action //Parameters // Staling ID // Main ASM // Interrupt/Other ASM // Movement/Physics ASM // Collision ASM
    Character.add_new_action(RYU, JAB_H, -1, ActionParams.JAB_H, -1, 0x800D94C4, RyuSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action(RYU, DTILT_H, -1, ActionParams.DTILT_H, -1, 0x8014FBF0, RyuSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action(RYU, UTILT_H, -1, ActionParams.UTILT_H, -1, 0x800D94C4, RyuSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action(RYU, FTILT_H, -1, ActionParams.FTILT_H, -1, 0x800D94C4, RyuSpecial.SpecialCancel.interrupt, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(RYU, USP_L, -1, ActionParams.USP_L, -1, RyuSpecial.USP.main_, RyuSpecial.USP.change_direction_, RyuSpecial.USP.physics_, RyuSpecial.USP.collision_)
    Character.add_new_action(RYU, USP_AIR_L, -1, ActionParams.USP_AIR_L, -1, RyuSpecial.USP.main_, RyuSpecial.USP.change_direction_, RyuSpecial.USP.physics_, RyuSpecial.USP.collision_)
    Character.add_new_action(RYU, JAB_L, -1, ActionParams.JAB_L, -1, 0x800D94C4, RyuSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action(RYU, JAB_L2, -1, ActionParams.JAB_L2, -1, 0x800D94C4, RyuSpecial.SpecialCancel.interrupt, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(RYU, JAB_L3, -1, ActionParams.JAB_L3, -1, 0x800D94C4, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(RYU, DTILT_L, -1, ActionParams.DTILT_L, -1, RyuSpecial.CancelItselfDtilt.main, RyuSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action(RYU, UTILT_L, -1, ActionParams.UTILT_L, -1, RyuSpecial.CancelItselfUtilt.main, RyuSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action(RYU, FTILT_L, -1, ActionParams.FTILT_L, -1, 0x800D94C4, RyuSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action(RYU, JAB_CLOSE, -1, ActionParams.JAB_CLOSE, -1, 0x800D94C4, RyuSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action(RYU, FTILT_CLOSE, -1, ActionParams.FTILT_CLOSE, -1, 0x800D94C4, RyuSpecial.SpecialCancel.interrupt, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action(RYU, DSP_L, -1, ActionParams.DSP_L, -1, RyuSpecial.DSP.Loop.main, 0, RyuSpecial.DSP.Loop.physics, 0x800DDF44)
    Character.add_new_action(RYU, DSP_H, -1, ActionParams.DSP_H, -1, RyuSpecial.DSP.Loop.main, 0, RyuSpecial.DSP.Loop.physics, 0x800DDF44)
    Character.add_new_action(RYU, DSP_AIR, -1, ActionParams.DSP_AIR, -1, RyuSpecial.DSP.Loop.main, 0, RyuSpecial.DSP.Loop.physics, 0x800DE978)
    Character.add_new_action(RYU, DSP_END, -1, ActionParams.DSP_END, -1, 0x800D94C4, 0, RyuSpecial.DSP.End.physics, 0x800DDF44)
    Character.add_new_action(RYU, DSP_AIREND, -1, ActionParams.DSP_AIREND, -1, 0x800D94E8, 0, RyuSpecial.DSP.End.physics, 0x800DE978)

    Character.add_new_action(RYU, USP_H, -1, ActionParams.USP_H, -1, RyuSpecial.USP.main_, RyuSpecial.USP.change_direction_, RyuSpecial.USP.physics_, RyuSpecial.USP.collision_)
    Character.add_new_action(RYU, USP_AIR_H, -1, ActionParams.USP_AIR_H, -1, RyuSpecial.USP.main_, RyuSpecial.USP.change_direction_, RyuSpecial.USP.physics_, RyuSpecial.USP.collision_)
    Character.add_new_action(RYU, USP_FALL, -1, ActionParams.USP_FALL, -1, RyuSpecial.USP.fall_main, 0, RyuSpecial.USP.fall_physics, RyuSpecial.USP.fall_collision)

    // Action replacement map
    scope action_replace_map_: {
        dh Action.Jab1; dh Ryu.Action.JAB_H;
        dh Action.DTilt; dh Ryu.Action.DTILT_H;
        dh Action.UTilt; dh Ryu.Action.UTILT_H;
        dh Action.FTilt; dh Ryu.Action.FTILT_H;
        dw 0xFFFFFFFF // end of map
    }

    // Set action replacement table
    Character.table_patch_start(action_replace_map, Character.id.RYU, 0x4)
    dw action_replace_map_
    OS.patch_end()

    scope grounded_script_: {
        j Character.grounded_script.DISABLED // back to original routine
        nop
    }
    Character.table_patch_start(grounded_script, Character.id.RYU, 0x4)
    dw grounded_script_
    OS.patch_end()

    scope initial_script_: {
        j 0x800D7F0C // back to original routine
        nop
    }
    Character.table_patch_start(initial_script, Character.id.RYU, 0x4)
    dw initial_script_
    OS.patch_end()

    // Modify Menu Action Parameters // Action // Animation // Moveset Data // Flags
    Character.edit_menu_action_parameters(RYU, 0x0, File.RYU_ANIM_IDLE, -1, -1)
    Character.edit_menu_action_parameters(RYU, 0x1, File.RYU_ANIM_WIN1, VICTORY_POSE_1, -1)
    Character.edit_menu_action_parameters(RYU, 0x2, File.RYU_ANIM_WIN1, VICTORY_POSE_1, -1)
    Character.edit_menu_action_parameters(RYU, 0x3, File.RYU_ANIM_WIN1, VICTORY_POSE_1, -1)
    Character.edit_menu_action_parameters(RYU, 0x4, File.RYU_ANIM_WIN1, VICTORY_POSE_1, -1)
    Character.edit_menu_action_parameters(RYU, 0x5, File.RYU_ANIM_CLAPS, -1, -1)
    // Character.edit_menu_action_parameters(RYU, 0xE, File.GND_1P_CPU, ONEP, -1)
    Character.edit_menu_action_parameters(RYU, 0xD, File.RYU_ANIM_CLASSIC, ONEP, -1)

    Character.table_patch_start(air_usp, Character.id.RYU, 0x4)
    dw RyuSpecial.USP.air_initial_
    OS.patch_end()
	
    Character.table_patch_start(ground_usp, Character.id.RYU, 0x4)
    dw RyuSpecial.USP.ground_initial_
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.RYU, 0x4)
    float32 1
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.RYU, 0x4)
    dw 0x8013DD68 // skips entry script
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.RYU, 0x2)
    dh FGM.CHANT
    OS.patch_end()

    // Set down bound FGM.
    Character.table_patch_start(down_bound_fgm, Character.id.RYU, 0x2)
    dh Ryu.FGM.GROUND_BUMP
    OS.patch_end()

    // Disable rapid jab
    Character.table_patch_start(rapid_jab, Character.id.RYU, 0x4)
    dw Character.rapid_jab.DISABLED // disable rapid jab
    OS.patch_end()

    // Set Kirby star damage
    Character.table_patch_start(kirby_inhale_struct, 0x8, Character.id.RYU, 0xC)
    dw Character.kirby_inhale_struct.star_damage.DK
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.RYU, 0xC)
    dh 0x11
    OS.patch_end()

    RYU_SHAKU_STRONG:
    AI.UNPRESS_Z()
    AI.UNPRESS_A(0)
    AI.UNPRESS_B(0)
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    dh 0xA07F // stick x = dash to opponent
    AI.PRESS_B(9)
    AI.UNPRESS_B(0)
    AI.END(); // End routine
    AI.add_cpu_input_routine(RYU_SHAKU_STRONG)

    RYU_SHAKU_WEAK:
    AI.UNPRESS_Z()
    AI.UNPRESS_A(0)
    AI.UNPRESS_B(0)
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    dh 0xA07F // stick x = dash to opponent
    AI.PRESS_B(1)
    AI.UNPRESS_B(0)
    AI.END(); // End routine
    AI.add_cpu_input_routine(RYU_SHAKU_WEAK)

    RYU_DTILTS_HADOKEN:
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
    AI.add_cpu_input_routine(RYU_DTILTS_HADOKEN)

    RYU_HARD_DTILT_TATSU:
    AI.UNPRESS_Z()
    AI.UNPRESS_A()
    AI.UNPRESS_B()
    AI.STICK_Y(-0x21, 1)
    AI.PRESS_A(9) // hard dtilt
    AI.PRESS_A(9) // hold A for long enough
    AI.UNPRESS_A(9)
    AI.PRESS_B(9) // tatsu
    AI.PRESS_B(9) // make sure it's the strong one
    AI.END(); // End routine
    AI.add_cpu_input_routine(RYU_HARD_DTILT_TATSU)

    RYU_SHIELD_BREAK_FAR:
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
    AI.add_cpu_input_routine(RYU_SHIELD_BREAK_FAR)

    RYU_HARD_DTILT:
    AI.UNPRESS_Z()
    AI.STICK_X(0, 0)
    AI.STICK_Y(-0x28, 0)
    AI.PRESS_A(9)
    AI.UNPRESS_A(0)
    AI.END()
    AI.add_cpu_input_routine(RYU_HARD_DTILT)

    RYU_HARD_UTILT:
    AI.UNPRESS_Z()
    AI.STICK_X(0, 0)
    AI.STICK_Y(0x28, 0)
    AI.PRESS_A(9)
    AI.UNPRESS_A(0)
    AI.END()
    AI.add_cpu_input_routine(RYU_HARD_UTILT)

    RYU_HARD_FTILT:
    AI.UNPRESS_Z()
    dh 0xA080 // stick x = tilt to opponent
    AI.STICK_Y(0, 0)
    AI.PRESS_A(9)
    AI.UNPRESS_A(0)
    AI.END()
    AI.add_cpu_input_routine(RYU_HARD_FTILT)

    RYU_MASH_DTILT:
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
    AI.add_cpu_input_routine(RYU_MASH_DTILT)

    RYU_MASH_UTILT:
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
    AI.add_cpu_input_routine(RYU_MASH_UTILT)

    RYU_HARD_JAB_SHORYUKEN:
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
    AI.add_cpu_input_routine(RYU_HARD_JAB_SHORYUKEN)

    RYU_FTILT_SHORYUKEN:
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
    AI.add_cpu_input_routine(RYU_FTILT_SHORYUKEN)

    RYU_ROUNDHOUSE:
    AI.UNPRESS_Z()
    AI.UNPRESS_A()
    AI.UNPRESS_B()
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    AI.PRESS_A(9)
    AI.UNPRESS_A(0)
    AI.END()
    AI.add_cpu_input_routine(RYU_ROUNDHOUSE)

    RYU_JAB_JAB_SHORYUKEN:
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
    AI.add_cpu_input_routine(RYU_JAB_JAB_SHORYUKEN)

    RYU_AIRU_SHORYUKEN:
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
    AI.add_cpu_input_routine(RYU_AIRU_SHORYUKEN)

    RYU_AIRN_HADOUKEN:
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
    AI.add_cpu_input_routine(RYU_AIRN_HADOUKEN)

    OS.align(4)

    CPU_ATTACKS:
    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.add_attack_behaviour(USPG, 2, 151, 368, 245, 453)
    AI.add_custom_attack_behaviour(AI.ROUTINE.RYU_DTILTS_HADOKEN, 3, -412, 412, -8, 144)
    AI.add_custom_attack_behaviour(AI.ROUTINE.RYU_MASH_UTILT, 3, -255, 255, 375, 570)
    AI.add_custom_attack_behaviour(AI.ROUTINE.RYU_MASH_DTILT, 3, -412, 412, -8, 144)
    AI.add_custom_attack_behaviour(AI.ROUTINE.RYU_FTILT_SHORYUKEN, 3, 206, 408, 163, 500)
    AI.add_custom_attack_behaviour(AI.ROUTINE.RYU_JAB_JAB_SHORYUKEN, 4, -356, 356, 292, 392)
    AI.add_attack_behaviour(JAB, 4, -356, 356, 292, 392)
    AI.add_custom_attack_behaviour(AI.ROUTINE.RYU_SHIELD_BREAK_FAR, 5, -564, 564, 12, 150)
    AI.add_attack_behaviour(DSMASH, 5, -564, 564, 12, 150)
    AI.add_attack_behaviour(GRAB, 6, 240, 390, 263, 413)
    AI.add_custom_attack_behaviour(AI.ROUTINE.RYU_HARD_JAB_SHORYUKEN, 7, 111, 452, 210, 703)
    AI.add_custom_attack_behaviour(AI.ROUTINE.RYU_HARD_DTILT_TATSU, 7, -590, 590, -12, 152)
    AI.add_custom_attack_behaviour(AI.ROUTINE.RYU_HARD_DTILT, 7, -590, 590, -12, 152)
    AI.add_custom_attack_behaviour(AI.ROUTINE.RYU_HARD_UTILT, 7, -452, 452, 333, 703)
    AI.add_attack_behaviour(USMASH, 9, -416, 416, 191, 758)
    AI.add_attack_behaviour(DSPG, 8, 142, 836, 282, 434)
    AI.add_attack_behaviour(FTILT, 9, -20, 461, 289, 487)
    AI.add_custom_attack_behaviour(AI.ROUTINE.RYU_ROUNDHOUSE, 9, 280, 584, 370, 620)
    AI.add_attack_behaviour(FSMASH, 15, 355, 896, 264, 448)
    AI.add_custom_attack_behaviour(AI.ROUTINE.RYU_HARD_FTILT, 14, 307, 699, 117, 510)
    AI.add_custom_attack_behaviour(AI.ROUTINE.RYU_SHAKU_WEAK, 12, 600, 2000, 100, 480)
    AI.add_custom_attack_behaviour(AI.ROUTINE.RYU_SHAKU_STRONG, 12, 800, 3200, 100, 480)
    AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 7, 362, 929, 246, 439)

    AI.END_ATTACKS() // end of grounded attacks

    AI.add_attack_behaviour(USPA, 2, 151, 368, 245, 453)
    AI.add_custom_attack_behaviour(AI.ROUTINE.RYU_AIRN_HADOUKEN, 4, -41, 188, 85, 324)
    AI.add_attack_behaviour(NAIR, 4, -41, 188, 85, 324)
    AI.add_attack_behaviour(NAIR, 4+4, -41, 188, 85, 324) // late hit
    AI.add_attack_behaviour(NAIR, 4+8, -41, 188, 85, 324) // later hit
    AI.add_custom_attack_behaviour(AI.ROUTINE.RYU_AIRU_SHORYUKEN, 6, 70, 319, 305, 647)
    AI.add_attack_behaviour(UAIR, 6, 70, 319, 305, 647)
    AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 8, 20, 385, 65, 205)
    AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 8+4, 20, 385, 65, 205) // late hit
    AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 8, -528, -165, 235, 445)
    AI.add_attack_behaviour(DAIR, 8, 211, 401, -14, 184)
    AI.add_attack_behaviour(DAIR, 8+4, 211, 401, -14, 184) // late hit
    AI.add_attack_behaviour(DSPA, 8, 142, 836, 282, 434)
    AI.add_attack_behaviour(NSPA, 12, 600, 2000, 100, 480)
    AI.END_ATTACKS() // end of aerial attacks
    OS.align(16)

    RYU_RECOVERY: {
        OS.routine_begin(0x20)

        lw v0, 0x0024(a0) // v0 = current action ID
        addiu at, r0, Ryu.Action.USP_AIR_L // at = Light USP
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
    Character.table_patch_start(recovery_logic, Character.id.RYU, 0x4)
    dw RYU_RECOVERY
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.RYU, 0x4)
    dw CPU_ATTACKS
    OS.patch_end()

    // Set CPU NSP long range behaviour
    Character.table_patch_start(ai_long_range, Character.id.RYU, 0x4)
    dw AI.LONG_RANGE.ROUTINE.NSP_SHOOT
    OS.patch_end()

    // Custom custom long range action input
    Character.table_patch_start(nsp_shoot_custom_move, Character.id.RYU, 0x4)
    dw AI.ROUTINE.RYU_SHAKU_WEAK
    OS.patch_end()

    // Set CPU SD prevent routine
    Character.table_patch_start(ai_attack_prevent, Character.id.RYU, 0x4)
    dw AI.PREVENT_ATTACK.ROUTINE.MARIO
    OS.patch_end()

    // @ Description
    // Ryu's extra actions
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
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.RYU, 0x4)
    dw Action.action_string_table
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.RYU, 0, 7, 1, 3, 0, 5, 6)
    Teams.add_team_costume(YELLOW, RYU, 0x4)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(RYU, WHITE, AZURE, CYAN, BLACK, YELLOW, BLUE, GREEN, PURPLE)
}