include "./TerrySpecial.asm"

// This file contains file inclusions, action edits, and assembly for Terry.

scope Terry {
    THROW_B:; Moveset.THROW_DATA(THROWB_DATA); Moveset.GO_TO(THROWB)
    THROW_F:; Moveset.THROW_DATA(THROWF_DATA); Moveset.GO_TO(THROWF)
    GRAB_: ; Moveset.THROW_DATA(THROWF_DATA); Moveset.GO_TO(grab)

    insert SPARKLE_, "moveset/SPARKLE.bin" ; Moveset.GO_TO(SPARKLE_) // loops
    insert SHIELD_BREAK_,"moveset/SHIELD_BREAK.bin" ; Moveset.GO_TO(SPARKLE_) // goes to sparkle
    insert STUN_, "moveset/STUN.bin" ; Moveset.GO_TO(STUN_) // loops
    insert SLEEP_, "moveset/SLEEP.bin" ; Moveset.GO_TO(SLEEP_) // loops

    insert RUN_, "moveset/RUN.bin" ; Moveset.GO_TO(RUN_) // loops

    // Modify Action Parameters // Action // Animation // Moveset Data // Flags
    Character.edit_action_parameters(TERRY, Action.DeadU, File.TERRY_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ScreenKO, File.TERRY_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(TERRY, Action.Entry, File.TERRY_ANIM_IDLE, -1, -1)
    Character.edit_action_parameters(TERRY, 0x006, File.TERRY_ANIM_IDLE, -1, -1)
    Character.edit_action_parameters(TERRY, Action.Revive1, File.TERRY_ANIM_DOWNBOUNCED, -1, -1)
    Character.edit_action_parameters(TERRY, Action.Revive2, File.TERRY_ANIM_DOWNSTANDD, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ReviveWait, File.TERRY_ANIM_IDLE, -1, -1)

    Character.edit_action_parameters(TERRY, 0xE0, File.TERRY_ANIM_ENTRYR, null, 0x40000009)
    Character.edit_action_parameters(TERRY, 0xE1, File.TERRY_ANIM_ENTRYL, null, 0x40000009)

    Character.edit_action_parameters(TERRY, Action.Idle, File.TERRY_ANIM_IDLE, -1, -1)

    Character.edit_action_parameters(TERRY, Action.Walk1, File.TERRY_ANIM_WALK1, -1, -1)
    Character.edit_action_parameters(TERRY, Action.Walk2, File.TERRY_ANIM_WALK2, -1, -1)
    Character.edit_action_parameters(TERRY, Action.Walk3, File.TERRY_ANIM_WALK3, -1, -1)

    Character.edit_action_parameters(TERRY, Action.Teeter, File.TERRY_ANIM_TEETER, 0x0, -1)
    Character.edit_action_parameters(TERRY, Action.TeeterStart, File.TERRY_ANIM_TEETERSTART, 0x0, -1)

    Character.edit_action_parameters(TERRY, Action.Dash, File.TERRY_ANIM_DASH, -1, -1)
    Character.edit_action_parameters(TERRY, Action.Run, File.TERRY_ANIM_RUN, RUN_, -1)

    Character.edit_action_parameters(TERRY, Action.RunBrake, File.TERRY_ANIM_RUNBRAKE, -1, -1)

    Character.edit_action_parameters(TERRY, Action.Taunt, File.TERRY_ANIM_TAUNT, taunt, -1)

    Character.edit_action_parameters(TERRY, Action.DamageMid1, File.TERRY_ANIM_DAMAGEN1, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageMid2, File.TERRY_ANIM_DAMAGEN2, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageMid3, File.TERRY_ANIM_DAMAGEN3, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageHigh1, File.TERRY_ANIM_DAMAGEHI1, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageHigh2, File.TERRY_ANIM_DAMAGEHI2, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageHigh3, File.TERRY_ANIM_DAMAGEHI3, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageLow1, File.TERRY_ANIM_DAMAGELW1, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageLow2, File.TERRY_ANIM_DAMAGELW2, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageLow3, File.TERRY_ANIM_DAMAGELW3, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageAir1, File.TERRY_ANIM_DAMAGEAIR1, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageAir2, File.TERRY_ANIM_DAMAGEAIR2, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageAir3, File.TERRY_ANIM_DAMAGEAIR3, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageFlyHigh, File.TERRY_ANIM_DAMAGEFLYHI, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageFlyLow, File.TERRY_ANIM_DAMAGEFLYLW, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageFlyMid, File.TERRY_ANIM_DAMAGEFLYMID, -1, -1)
    Character.edit_action_parameters(TERRY, Action.WallBounce, File.TERRY_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(TERRY, Action.Tumble, File.TERRY_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageFlyRoll, File.TERRY_ANIM_DAMAGEFLYROLL, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageFlyTop, File.TERRY_ANIM_DAMAGEFLYTOP, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageElec1, File.TERRY_ANIM_DAMAGEELEC, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DamageElec2, File.TERRY_ANIM_DAMAGEELEC, -1, -1)
    
    Character.edit_action_parameters(TERRY, Action.CapturePulled, File.TERRY_ANIM_CAPTUREPULLED, -1, -1)
    Character.edit_action_parameters(TERRY, Action.EggLayPulled, File.TERRY_ANIM_CAPTUREPULLED, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DownBounceD, File.TERRY_ANIM_DOWNBOUNCED, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DownBounceU, File.TERRY_ANIM_DOWNBOUNCEU, -1, -1)
    Character.edit_action_parameters(TERRY, Action.Pass, File.TERRY_ANIM_PASS_PLATFORM_DROP, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ShieldDrop, File.TERRY_ANIM_PASS_PLATFORM_DROP, -1, -1)
    Character.edit_action_parameters(TERRY, Action.CliffCatch, File.TERRY_ANIM_CLIFFCATCH, -1, -1)
    Character.edit_action_parameters(TERRY, Action.CliffWait, File.TERRY_ANIM_CLIFFWAIT, -1, -1)
    Character.edit_action_parameters(TERRY, Action.Turn, File.TERRY_ANIM_TURN, -1, -1);
    Character.edit_action_parameters(TERRY, Action.TurnRun, File.TERRY_ANIM_TURNRUN, -1, -1);
    Character.edit_action_parameters(TERRY, Action.JumpF, File.TERRY_ANIM_JUMPF, jump, -1);
    Character.edit_action_parameters(TERRY, Action.JumpB, File.TERRY_ANIM_JUMPB, jump, -1);
    Character.edit_action_parameters(TERRY, Action.JumpAerialF, File.TERRY_ANIM_JUMPAERIALF, jumpAerial, -1);
    Character.edit_action_parameters(TERRY, Action.JumpAerialB, File.TERRY_ANIM_JUMPAERIALB, jumpAerial, -1);
    Character.edit_action_parameters(TERRY, Action.Fall, File.TERRY_ANIM_FALL, fall, -1);
    Character.edit_action_parameters(TERRY, Action.FallAerial, File.TERRY_ANIM_FALLAERIAL, fall, -1);
    Character.edit_action_parameters(TERRY, Action.Crouch, File.TERRY_ANIM_CROUCH, -1, -1);
    Character.edit_action_parameters(TERRY, Action.CrouchIdle, File.TERRY_ANIM_CROUCHIDLE, -1, -1);
    Character.edit_action_parameters(TERRY, Action.CrouchEnd, File.TERRY_ANIM_CROUCHEND, -1, -1);
    Character.edit_action_parameters(TERRY, Action.JumpSquat, File.TERRY_ANIM_JUMPSQUAT, -1, -1);
    Character.edit_action_parameters(TERRY, Action.ShieldJumpSquat, File.TERRY_ANIM_JUMPSQUAT, -1, -1);
    Character.edit_action_parameters(TERRY, Action.LandingLight, File.TERRY_ANIM_JUMPSQUAT, -1, -1);
    Character.edit_action_parameters(TERRY, Action.LandingHeavy, File.TERRY_ANIM_JUMPSQUAT, -1, -1);
    Character.edit_action_parameters(TERRY, Action.LandingAirX, File.TERRY_ANIM_JUMPSQUAT, -1, -1);
    Character.edit_action_parameters(TERRY, Action.CeilingBonk, File.TERRY_ANIM_CEILINGBONK, -1, -1);
    Character.edit_action_parameters(TERRY, Action.DownStandD, File.TERRY_ANIM_DOWNSTANDD, -1, -1);
    Character.edit_action_parameters(TERRY, Action.DownStandU, File.TERRY_ANIM_DOWNSTANDU, -1, -1);
    Character.edit_action_parameters(TERRY, Action.Tech, File.TERRY_ANIM_TECH, tech, -1);
    Character.edit_action_parameters(TERRY, Action.TechF, File.TERRY_ANIM_TECHF, techRoll, -1)
    Character.edit_action_parameters(TERRY, Action.TechB, File.TERRY_ANIM_TECHB, techRoll, -1)
    Character.edit_action_parameters(TERRY, Action.DownForwardD, File.TERRY_ANIM_DOWNFORWARDD, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DownForwardU, File.TERRY_ANIM_DOWNFORWARDU, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DownBackD, File.TERRY_ANIM_DOWNBACKD, -1, -1)
    Character.edit_action_parameters(TERRY, Action.DownBackU, File.TERRY_ANIM_DOWNBACKU, -1, -1)

    Character.edit_action_parameters(TERRY, Action.ClangRecoil, File.TERRY_ANIM_CLANGRECOIL, -1, -1);

    Character.edit_action_parameters(TERRY, Action.LandingAirF, File.TERRY_ANIM_LANDINGAIRF, -1, -1);
    Character.edit_action_parameters(TERRY, Action.LandingAirB, File.TERRY_ANIM_LANDINGAIRB, -1, -1);
    Character.edit_action_parameters(TERRY, Action.LandingSpecial, File.TERRY_ANIM_SPECIALLAND, -1, -1);

    Character.edit_action_parameters(TERRY, Action.ShieldOn, File.TERRY_ANIM_SHIELDON, -1, 0xA0000000);
    Character.edit_action_parameters(TERRY, Action.ShieldOff, File.TERRY_ANIM_SHIELDOFF, -1, 0xA0000000);
    Character.edit_action_parameters(TERRY, Action.RollF, File.TERRY_ANIM_ROLLF, rollF, -1)
    Character.edit_action_parameters(TERRY, Action.RollB, File.TERRY_ANIM_ROLLB, rollB, -1)
    Character.edit_action_parameters(TERRY, Action.Grab, File.TERRY_ANIM_GRAB, GRAB_, -1)
    Character.edit_action_parameters(TERRY, Action.GrabPull, File.TERRY_ANIM_GRABPULL, -1, 0x10000000)
    Character.edit_action_parameters(TERRY, Action.ThrowF, File.TERRY_ANIM_THROWF, THROW_F, 0x10000000)
    Character.edit_action_parameters(TERRY, Action.ThrowB, File.TERRY_ANIM_THROWB, THROW_B, 0x10000000)

    Character.edit_action_parameters(TERRY, Action.ShieldBreak, File.TERRY_ANIM_DAMAGEFLYTOP, SHIELD_BREAK_, -1)
    Character.edit_action_parameters(TERRY, Action.ShieldBreakFall, File.TERRY_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(TERRY, Action.StunLandD, File.TERRY_ANIM_DOWNBOUNCED, -1, -1)
    Character.edit_action_parameters(TERRY, Action.StunLandU, File.TERRY_ANIM_DOWNBOUNCEU, -1, -1)
    Character.edit_action_parameters(TERRY, Action.StunStartD, File.TERRY_ANIM_DOWNSTANDD, -1, -1)
    Character.edit_action_parameters(TERRY, Action.StunStartU, File.TERRY_ANIM_DOWNSTANDU, -1, -1)
    Character.edit_action_parameters(TERRY, Action.Stun, File.TERRY_ANIM_STUN, STUN_, -1)
    Character.edit_action_parameters(TERRY, Action.Sleep, File.TERRY_ANIM_STUN, SLEEP_, -1)

    Character.edit_action_parameters(TERRY, Action.Jab1, File.TERRY_ANIM_JAB1, jab1, -1);
    Character.edit_action_parameters(TERRY, Action.Jab2, File.TERRY_ANIM_JAB2, jab2, -1);
    Character.edit_action_parameters(TERRY, 0xDC, File.TERRY_ANIM_JAB3, jab3, -1);
    Character.edit_action_parameters(TERRY, Action.DashAttack, File.TERRY_ANIM_DASHATTACK, dashAttack, -1);
    Character.edit_action_parameters(TERRY, Action.FTiltHigh, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(TERRY, Action.FTiltMidHigh, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(TERRY, Action.FTilt, File.TERRY_ANIM_FTILT, ftilt, 0x40000000);
    Character.edit_action_parameters(TERRY, Action.FTiltMidLow, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(TERRY, Action.FTiltLow, 0, 0x80000000, 0x00000000)

    Character.edit_action_parameters(TERRY, Action.AttackAirB, File.TERRY_ANIM_AIRB, airB, -1);
    Character.edit_action_parameters(TERRY, Action.AttackAirD, File.TERRY_ANIM_AIRD, airD, -1);
    Character.edit_action_parameters(TERRY, Action.AttackAirF, File.TERRY_ANIM_AIRF, airF, -1);
    Character.edit_action_parameters(TERRY, Action.AttackAirN, File.TERRY_ANIM_AIRN, airN, -1);
    Character.edit_action_parameters(TERRY, Action.AttackAirU, File.TERRY_ANIM_AIRU, airU, -1);

    Character.edit_action_parameters(TERRY, Action.FSmash, File.TERRY_ANIM_SMASHF, smashF, -1);
    Character.edit_action_parameters(TERRY, Action.FSmashHigh, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(TERRY, Action.FSmashLow, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(TERRY, Action.DSmash, File.TERRY_ANIM_SMASHD, smashD, 0x40000000);
    Character.edit_action_parameters(TERRY, Action.USmash, File.TERRY_ANIM_SMASHU, smashU, -1);

    Character.edit_action_parameters(TERRY, Action.DTilt, File.TERRY_ANIM_DTILT, dtilt, -1);
    Character.edit_action_parameters(TERRY, Action.UTilt, File.TERRY_ANIM_UTILT, utilt, -1);

    Character.edit_action_parameters(TERRY, Action.FallSpecial, File.TERRY_ANIM_FALLSPECIAL, -1, -1);

    Character.edit_action_parameters(TERRY, Action.InhalePulled, File.TERRY_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(TERRY, Action.InhaleSpat, File.TERRY_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(TERRY, Action.InhaleCopied, File.TERRY_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(TERRY, 0x0B4, File.TERRY_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(TERRY, Action.EggLay, File.TERRY_ANIM_IDLE, -1, -1)
    Character.edit_action_parameters(TERRY, Action.FalconDivePulled, File.TERRY_ANIM_DAMAGEHI3, -1, -1)

    Character.edit_action_parameters(TERRY, Action.DownAttackD, File.TERRY_ANIM_DOWNATTACKD, downAtkD, -1)
    Character.edit_action_parameters(TERRY, Action.DownAttackU, File.TERRY_ANIM_DOWNATTACKU, downAtkU, -1)

    Character.edit_action_parameters(TERRY, Action.CliffQuick, File.TERRY_ANIM_CLIFFQUICK, -1, -1)
    Character.edit_action_parameters(TERRY, Action.CliffSlow, File.TERRY_ANIM_CLIFFSLOW, -1, -1)
    Character.edit_action_parameters(TERRY, Action.CliffClimbQuick1, File.TERRY_ANIM_CLIFFCLIMBQUICK1, -1, -1)
    Character.edit_action_parameters(TERRY, Action.CliffClimbQuick2, File.TERRY_ANIM_CLIFFCLIMBQUICK2, -1, -1)
    Character.edit_action_parameters(TERRY, Action.CliffAttackQuick1, File.TERRY_ANIM_CLIFFATTACKQUICK1, -1, -1)
    Character.edit_action_parameters(TERRY, Action.CliffAttackQuick2, File.TERRY_ANIM_CLIFFATTACKQUICK2, cliffATK, -1)
    Character.edit_action_parameters(TERRY, Action.CliffEscapeQuick1, File.TERRY_ANIM_CLIFFESCAPEQUICK1, -1, -1)
    Character.edit_action_parameters(TERRY, Action.CliffEscapeQuick2, File.TERRY_ANIM_CLIFFESCAPEQUICK2, -1, -1)

    Character.edit_action_parameters(TERRY, Action.LightItemPickup, File.TERRY_ANIM_LIGHTITEMPICKUP, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemDrop, File.TERRY_ANIM_ITEMDROP, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemThrowDash, File.TERRY_ANIM_ITEMTHROWDASH, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemThrowF, File.TERRY_ANIM_ITEMTHROWF, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemThrowB, File.TERRY_ANIM_ITEMTHROWF, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemThrowU, File.TERRY_ANIM_ITEMTHROWU, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemThrowD, File.TERRY_ANIM_ITEMTHROWD, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemThrowSmashF, File.TERRY_ANIM_ITEMTHROWF, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemThrowSmashB, File.TERRY_ANIM_ITEMTHROWF, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemThrowSmashU, File.TERRY_ANIM_ITEMTHROWU, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemThrowSmashD, File.TERRY_ANIM_ITEMTHROWD, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemThrowAirF, File.TERRY_ANIM_ITEMTHROWAIRF, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemThrowAirB, File.TERRY_ANIM_ITEMTHROWAIRF, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemThrowAirU, File.TERRY_ANIM_ITEMTHROWAIRU, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemThrowAirD, File.TERRY_ANIM_ITEMTHROWAIRD, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemThrowAirSmashF, File.TERRY_ANIM_ITEMTHROWAIRF, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemThrowAirSmashB, File.TERRY_ANIM_ITEMTHROWAIRF, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemThrowAirSmashU, File.TERRY_ANIM_ITEMTHROWAIRU, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ItemThrowAirSmashD, File.TERRY_ANIM_ITEMTHROWAIRD, -1, -1)

    Character.edit_action_parameters(TERRY, Action.ThrownDKPulled, File.TERRY_ANIM_THROWNDKPULLED, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ThrownDK, File.TERRY_ANIM_THROWNDK, -1, -1)
    Character.edit_action_parameters(TERRY, Action.Thrown1, File.TERRY_ANIM_THROWN1, -1, -1)
    Character.edit_action_parameters(TERRY, Action.Thrown2, File.TERRY_ANIM_THROWN2, -1, -1)
    Character.edit_action_parameters(TERRY, Action.ThrownMarioBros, File.TERRY_ANIM_THROWNMARIOBROS, -1, -1)

    Character.edit_action_parameters(TERRY, Action.BeamSwordNeutral, File.TERRY_ANIM_SWINGJAB, -1, -1)
    Character.edit_action_parameters(TERRY, Action.BeamSwordTilt, File.TERRY_ANIM_SWINGTILT, -1, -1)
    Character.edit_action_parameters(TERRY, Action.BeamSwordSmash, File.TERRY_ANIM_SWINGSMASH, -1, -1)
    Character.edit_action_parameters(TERRY, Action.BeamSwordDash, File.TERRY_ANIM_SWINGDASH, -1, -1)
    Character.edit_action_parameters(TERRY, Action.BatNeutral, File.TERRY_ANIM_SWINGJAB, -1, -1)
    Character.edit_action_parameters(TERRY, Action.BatTilt, File.TERRY_ANIM_SWINGTILT, -1, -1)
    Character.edit_action_parameters(TERRY, Action.BatSmash, File.TERRY_ANIM_SWINGSMASH, -1, -1)
    Character.edit_action_parameters(TERRY, Action.BatDash, File.TERRY_ANIM_SWINGDASH, -1, -1)
    Character.edit_action_parameters(TERRY, Action.FanNeutral, File.TERRY_ANIM_SWINGJAB, -1, -1)
    Character.edit_action_parameters(TERRY, Action.FanTilt, File.TERRY_ANIM_SWINGTILT, -1, -1)
    Character.edit_action_parameters(TERRY, Action.FanSmash, File.TERRY_ANIM_SWINGSMASH, -1, -1)
    Character.edit_action_parameters(TERRY, Action.FanDash, File.TERRY_ANIM_SWINGDASH, -1, -1)
    Character.edit_action_parameters(TERRY, Action.StarRodNeutral, File.TERRY_ANIM_SWINGJAB, -1, -1)
    Character.edit_action_parameters(TERRY, Action.StarRodTilt, File.TERRY_ANIM_SWINGTILT, -1, -1)
    Character.edit_action_parameters(TERRY, Action.StarRodSmash, File.TERRY_ANIM_SWINGSMASH, -1, -1)
    Character.edit_action_parameters(TERRY, Action.StarRodDash, File.TERRY_ANIM_SWINGDASH, -1, -1)
    Character.edit_action_parameters(TERRY, Action.RayGunShoot, File.TERRY_ANIM_ITEMSHOOT, -1, -1)
    Character.edit_action_parameters(TERRY, Action.RayGunShootAir, File.TERRY_ANIM_ITEMSHOOTAIR, -1, -1)
    Character.edit_action_parameters(TERRY, Action.FireFlowerShoot, File.TERRY_ANIM_ITEMSHOOT, -1, -1)
    Character.edit_action_parameters(TERRY, Action.FireFlowerShootAir, File.TERRY_ANIM_ITEMSHOOTAIR, -1, -1)
    Character.edit_action_parameters(TERRY, Action.HammerIdle, File.TERRY_ANIM_HAMMERWAIT, -1, -1)
    Character.edit_action_parameters(TERRY, Action.HammerWalk, File.TERRY_ANIM_HAMMERMOVE, -1, -1)
    Character.edit_action_parameters(TERRY, Action.HammerTurn, File.TERRY_ANIM_HAMMERMOVE, -1, -1)
    Character.edit_action_parameters(TERRY, Action.HammerJumpSquat, File.TERRY_ANIM_HAMMERMOVE, -1, -1)
    Character.edit_action_parameters(TERRY, Action.HammerAir, File.TERRY_ANIM_HAMMERMOVE, -1, -1)
    Character.edit_action_parameters(TERRY, Action.HammerLanding, File.TERRY_ANIM_HAMMERMOVE, -1, -1)
    Character.edit_action_parameters(TERRY, Action.HeavyItemPickup, File.TERRY_ANIM_HEAVYGET, -1, -1)
    Character.edit_action_parameters(TERRY, Action.HeavyItemThrowF, File.TERRY_ANIM_HEAVYTHROW, -1, -1)
    Character.edit_action_parameters(TERRY, Action.HeavyItemThrowB, File.TERRY_ANIM_HEAVYTHROW, -1, -1)
    Character.edit_action_parameters(TERRY, Action.HeavyItemThrowSmashF, File.TERRY_ANIM_HEAVYTHROW, -1, -1)
    Character.edit_action_parameters(TERRY, Action.HeavyItemThrowSmashB, File.TERRY_ANIM_HEAVYTHROW, -1, -1)

    Character.edit_action_parameters(TERRY, Action.Tornado, File.TERRY_ANIM_DAMAGEFALL, -1, -1)

    // TODO
    Character.edit_action_parameters(TERRY, Action.CliffClimbSlow1, File.TERRY_ANIM_CLIFFCLIMBQUICK1, -1, -1)
    Character.edit_action_parameters(TERRY, Action.CliffClimbSlow2, File.TERRY_ANIM_CLIFFCLIMBQUICK2, -1, -1)
    Character.edit_action_parameters(TERRY, Action.CliffAttackSlow1, File.TERRY_ANIM_CLIFFATTACKQUICK1, -1, -1)
    Character.edit_action_parameters(TERRY, Action.CliffAttackSlow2, File.TERRY_ANIM_CLIFFATTACKQUICK2, cliffATK, -1)
    Character.edit_action_parameters(TERRY, Action.CliffEscapeSlow1, File.TERRY_ANIM_CLIFFESCAPEQUICK1, -1, -1)
    Character.edit_action_parameters(TERRY, Action.CliffEscapeSlow2, File.TERRY_ANIM_CLIFFESCAPEQUICK2, -1, -1)

    Character.edit_action_parameters(TERRY, 0xE4, File.TERRY_ANIM_BK_GND_START, bkStart, 0x00000000)
    Character.edit_action_parameters(TERRY, 0xE5, File.TERRY_ANIM_BK_AIR_START, bkStart, 0x00000000)
    Character.edit_action_parameters(TERRY, 0xE6, File.TERRY_ANIM_DSP_GND_START, pdStart, 0x40000000)
    Character.edit_action_parameters(TERRY, 0xE9, File.TERRY_ANIM_DSP_AIR_START, pdStart, 0x40000000)

    // Modify Actions // Action // Staling ID // Main ASM // Interrupt/Other ASM // Movement/Physics ASM // Collision ASM
    Character.edit_action(TERRY, 0xE4, -1, TerrySpecial.BK.begin_main_, 0, TerrySpecial.BK.begin_physics_, -1)
    Character.edit_action(TERRY, 0xE5, -1, TerrySpecial.BK.begin_main_, 0, TerrySpecial.BK.begin_physics_, -1) 
    Character.edit_action(TERRY, 0xE6, -1, TerrySpecial.PD.begin_main_, 0, 0x800D93E4, -1)
    Character.edit_action(TERRY, 0xE9, -1, TerrySpecial.PD.begin_main_, 0, 0x800D93E4, -1)
    Character.edit_action(TERRY, 0xE0, -1, 0x8013DA94, 0, 0x8013DB2C, 0x800DE348) // LEFT ENTRY
    Character.edit_action(TERRY, 0xE1, -1, 0x8013DA94, 0, 0x8013DB2C, 0x800DE348) // RIGHT ENTRY

    // new Ftilt
    Character.add_new_action_params(TERRY, TILTF, -1, File.TERRY_ANIM_FTILT, ftilt, 0x40000000)
    Character.add_new_action(TERRY, TILTF, Action.FTilt, ActionParams.TILTF, -1, 0x800D94C4, TerrySpecial.SpecialCancel.interrupt, 0x800D8C14, 0x800DDF44)

    // new Dsmash
    Character.add_new_action_params(TERRY, SMASHD, -1, File.TERRY_ANIM_SMASHD, smashD, 0x40000000)
    Character.add_new_action(TERRY, SMASHD, Action.DSmash, ActionParams.SMASHD, -1, 0x800D94C4, 0, 0x800D8C14, 0x800DDF44)

    // new Jab1
    Character.add_new_action_params(TERRY, JAB1, -1, File.TERRY_ANIM_JAB1, jab1, 0x00000000)
    Character.add_new_action(TERRY, JAB1, Action.Jab1, ActionParams.JAB1, -1, 0x8014E7B0, TerrySpecial.Jab1.interrupt, 0x800D8BB4, 0x800DDF44)

    // new Jab2
    Character.add_new_action_params(TERRY, JAB2, -1, File.TERRY_ANIM_JAB2, jab2, 0x00000000)
    Character.add_new_action(TERRY, JAB2, Action.Jab2, ActionParams.JAB2, -1, 0x8014E824, TerrySpecial.Jab2.interrupt, 0x800D8BB4, 0x800DDF44)

    // new Dtilt
    Character.add_new_action_params(TERRY, DTILT, -1, File.TERRY_ANIM_DTILT, dtilt, 0x00000000)
    Character.add_new_action(TERRY, DTILT, Action.DTilt, ActionParams.DTILT, -1, 0x8014FBF0, TerrySpecial.DTilt.interrupt, 0x800D8CCC, 0x800DDF44)

    // Action replacement map
    scope action_replace_map_: {
        dh Action.FTilt; dh Terry.Action.TILTF;
        dh Action.DSmash; dh Terry.Action.SMASHD;
        dh Action.Jab1; dh Terry.Action.JAB1;
        dh Action.Jab2; dh Terry.Action.JAB2;
        dh Action.DTilt; dh Terry.Action.DTILT;
        dw 0xFFFFFFFF // end of map
    }

    // Set action replacement table
    Character.table_patch_start(action_replace_map, Character.id.TERRY, 0x4)
    dw action_replace_map_
    OS.patch_end()

    // add new actions
    // USP
    Character.add_new_action_params(TERRY, USP_L, -1, File.TERRY_ANIM_SPECIALUW, usp, 0x40000000)
    Character.add_new_action(TERRY, USP_L, -1, ActionParams.USP_L, -1, TerrySpecial.USP.main_, TerrySpecial.USP.change_direction_, TerrySpecial.USP.physics_, TerrySpecial.USP.collision_)

    Character.add_new_action_params(TERRY, USP_H, -1, File.TERRY_ANIM_SPECIALUS, uspStrong, 0x40000000)
    Character.add_new_action(TERRY, USP_H, -1, ActionParams.USP_H, -1, TerrySpecial.USP.main_, TerrySpecial.USP.change_direction_, TerrySpecial.USP.physics_, TerrySpecial.USP.collision_)

    // Burning Knuckle
    Character.add_new_action_params(TERRY, BK_ATTACK_W, -1, File.TERRY_ANIM_BK_ATTACK, bkWeak, 0x0)
    Character.add_new_action(TERRY, BK_ATTACK_W, -1, ActionParams.BK_ATTACK_W, -1, TerrySpecial.BK.attack_main_, 0, TerrySpecial.BK.attack_physics_, TerrySpecial.BK.attack_collision_)

    Character.add_new_action_params(TERRY, BK_ATTACK_S, -1, File.TERRY_ANIM_BK_ATTACK, bkStrong, 0x0)
    Character.add_new_action(TERRY, BK_ATTACK_S, -1, ActionParams.BK_ATTACK_S, -1, TerrySpecial.BK.attack_main_, 0, TerrySpecial.BK.attack_physics_, TerrySpecial.BK.attack_collision_)

    Character.add_new_action_params(TERRY, BK_GND_END, -1, File.TERRY_ANIM_BK_GND_END, bkEnd, 0x0)
    Character.add_new_action(TERRY, BK_GND_END, -1, ActionParams.BK_GND_END, -1, 0x800D94C4, 0, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action_params(TERRY, BK_AIR_END, -1, File.TERRY_ANIM_BK_AIR_END, null, 0x0)
    Character.add_new_action(TERRY, BK_AIR_END, -1, ActionParams.BK_AIR_END, -1, 0x800D94E8, 0, 0x800D90E0, TerrySpecial.BK.end_air_collision_)

    // Power Dunk
    Character.add_new_action_params(TERRY, PD_RISE_W, -1, File.TERRY_ANIM_DSP_RISE_W, pdRiseWeak, 0x40000000)
    Character.add_new_action(TERRY, PD_RISE_W, -1, ActionParams.PD_RISE_W, -1, TerrySpecial.PD.rise_main_, 0, 0x800D93E4, TerrySpecial.PD.rise_collision_)

    Character.add_new_action_params(TERRY, PD_RISE_S, -1, File.TERRY_ANIM_DSP_RISE_S, pdRiseStrong, 0x40000000)
    Character.add_new_action(TERRY, PD_RISE_S, -1, ActionParams.PD_RISE_S, -1, TerrySpecial.PD.rise_main_, 0, 0x800D93E4, TerrySpecial.PD.rise_collision_)

    Character.add_new_action_params(TERRY, PD_FALL_W, -1, File.TERRY_ANIM_DSP_FALL, pdFallWeak, 0x40000000)
    Character.add_new_action(TERRY, PD_FALL_W, -1, ActionParams.PD_FALL_W, -1, 0x800D94E8, 0, TerrySpecial.PD.fall_physics_, TerrySpecial.PD.fall_collision_)

    Character.add_new_action_params(TERRY, PD_FALL_S, -1, File.TERRY_ANIM_DSP_FALL, pdFallStrong, 0x40000000)
    Character.add_new_action(TERRY, PD_FALL_S, -1, ActionParams.PD_FALL_S, -1, 0x800D94E8, 0, TerrySpecial.PD.fall_physics_, TerrySpecial.PD.fall_collision_)

    Character.add_new_action_params(TERRY, PD_LAND, -1, File.TERRY_ANIM_DSP_LAND, pdLand, 0x40000000)
    Character.add_new_action(TERRY, PD_LAND, -1, ActionParams.PD_LAND, -1, 0x800D94C4, 0, 0x800D8BB4, 0x800DDF44)

    // Power Wave
    Character.add_new_action_params(TERRY, PWAVE_W, -1, File.TERRY_ANIM_PWAVEW, pwW, 0x00000000)
    Character.add_new_action(TERRY, PWAVE_W, -1, ActionParams.PWAVE_W, -1, TerrySpecial.PW.main, 0, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action_params(TERRY, PWAVE_S, -1, File.TERRY_ANIM_PWAVES, pwS, 0x00000000)
    Character.add_new_action(TERRY, PWAVE_S, -1, ActionParams.PWAVE_S, -1, TerrySpecial.PW.main, 0, 0x800D8BB4, 0x800DDF44)

    // Crackshoot
    Character.add_new_action_params(TERRY, CSHOOT_START, -1, File.TERRY_ANIM_CSHOOTSTART, cShootStart, 0x40000000)
    Character.add_new_action(TERRY, CSHOOT_START, -1, ActionParams.CSHOOT_START, -1, TerrySpecial.CS.begin_main_, 0, 0x800D8C14, 0x800DDF44)

    Character.add_new_action_params(TERRY, CSHOOT_AIRSTART, -1, File.TERRY_ANIM_CSHOOTAIRSTART, cShootStart, 0x40000000)
    Character.add_new_action(TERRY, CSHOOT_AIRSTART, -1, ActionParams.CSHOOT_AIRSTART, -1, TerrySpecial.CS.begin_main_, 0, 0x800D8C14, TerrySpecial.CS.collision_)

    Character.add_new_action_params(TERRY, CSHOOT_W, -1, File.TERRY_ANIM_CSHOOTW, cShootW, 0x40000000)
    Character.add_new_action(TERRY, CSHOOT_W, -1, ActionParams.CSHOOT_W, -1, 0x800D94E8, 0, 0x800D93E4, TerrySpecial.CS.collision_)

    Character.add_new_action_params(TERRY, CSHOOT_S, -1, File.TERRY_ANIM_CSHOOTS, cShootS, 0x40000000)
    Character.add_new_action(TERRY, CSHOOT_S, -1, ActionParams.CSHOOT_S, -1, 0x800D94E8, 0, 0x800D93E4, TerrySpecial.CS.collision_)

    Character.add_new_action_params(TERRY, CSHOOT_LAND, -1, File.TERRY_ANIM_CSHOOTLAND, bkEnd, 0x40000000)
    Character.add_new_action(TERRY, CSHOOT_LAND, -1, ActionParams.CSHOOT_LAND, -1, 0x800D94C4, 0, 0x800D8C14, 0x800DDF44)

    // Modify Action Parameters // Action // Animation // Moveset Data // Flags
    Character.edit_menu_action_parameters(TERRY, 0x0, File.TERRY_ANIM_IDLE, -1, -1)
    Character.edit_menu_action_parameters(TERRY, 0x1, File.TERRY_ANIM_SELECTED, selected, 0x10000000)
    Character.edit_menu_action_parameters(TERRY, 0x2, File.TERRY_ANIM_WIN1, win1, 0x10000000)
    Character.edit_menu_action_parameters(TERRY, 0x3, File.TERRY_ANIM_WIN1, win1, 0x10000000)
    Character.edit_menu_action_parameters(TERRY, 0x4, File.TERRY_ANIM_WIN1, win1, 0x10000000)
    Character.edit_menu_action_parameters(TERRY, 0x5, File.TERRY_ANIM_CLAPS, -1, -1)
    Character.edit_menu_action_parameters(TERRY, 0xD, File.TERRY_ANIM_1P, -1, -1)

    // Disable rapid jab
    Character.table_patch_start(rapid_jab, Character.id.TERRY, 0x4)
    dw Character.rapid_jab.DISABLED // disable rapid jab
    OS.patch_end()

    Character.table_patch_start(air_usp, Character.id.TERRY, 0x4)
    dw TerrySpecial.USP.air_initial_
    OS.patch_end()

    Character.table_patch_start(ground_usp, Character.id.TERRY, 0x4)
    dw TerrySpecial.USP.ground_initial_
    OS.patch_end()

    Character.table_patch_start(air_nsp, Character.id.TERRY, 0x4)
    dw TerrySpecial.BK.air_initial_
    OS.patch_end()

    Character.table_patch_start(ground_nsp, Character.id.TERRY, 0x4)
    dw TerrySpecial.BK.ground_initial_
    OS.patch_end()

    Character.table_patch_start(ground_dsp, Character.id.TERRY, 0x4)
    dw TerrySpecial.PD.ground_initial_
    OS.patch_end()

    scope grounded_script_: {
        j Character.grounded_script.DISABLED // back to original routine
        sw r0, 0xADC(v0) // set nsp special bool to FALSE
    }

    Character.table_patch_start(grounded_script, Character.id.TERRY, 0x4)
    dw grounded_script_
    OS.patch_end()

    scope initial_script_: {
        j 0x800D7F0C // back to original routine
        sw r0, 0xADC(v1) // set nsp special bool to FALSE
    }

    Character.table_patch_start(initial_script, Character.id.TERRY, 0x4)
    dw initial_script_
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.TERRY, 0, 1, 2, 3, 0, 1, 3)
    Teams.add_team_costume(YELLOW, TERRY, 0x6)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(TERRY, RED, BLUE, BROWN, GREEN, RED, BLACK, YELLOW, NA)

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.TERRY, 0x4)
    dw 0x8013DD68 // skips entry script
    OS.patch_end()

    // @ Description
    // Terry's extra actions
    scope Action {
        string_0x0E1:; String.insert("e1")
        string_0x0E2:; String.insert("e2")
        string_0x0E3:; String.insert("e3")
        string_0x0E4:; String.insert("BurningKnuckleStart")
        string_0x0E5:; String.insert("BurningKnuckleAirStart")
        string_0x0E6:; String.insert("PowerDunkStart")
        string_0x0E7:; String.insert("e7")
        string_0x0E8:; String.insert("e8")
        string_0x0E9:; String.insert("PowerDunkAirStart")
        string_0x0EA:; String.insert("ea")
        string_0x0EB:; String.insert("eb")
        string_0x0EC:; String.insert("ec")
        string_0x0ED:; String.insert("ed")
        string_0x0EE:; String.insert("ee")
        string_0x0F1:; String.insert("f1")
        string_0x0F2:; String.insert("f2")
        string_0x0F3:; String.insert("f3")
        string_0x0F4:; String.insert("RisingTackleLight")
        string_0x0F5:; String.insert("RisingTackleStrong")
        string_0x0F6:; String.insert("BurningKnuckleLight")
        string_0x0F7:; String.insert("BurningKnuckleStrong")
        string_0x0F8:; String.insert("BurningKnuckleEnd")
        string_0x0F9:; String.insert("BurningKnuckleAirEnd")
        string_0x0FA:; String.insert("PowerDunkRiseLight")
        string_0x0FB:; String.insert("PowerDunkRiseStrong")
        string_0x0FC:; String.insert("PowerDunkFallLight")
        string_0x0FD:; String.insert("PowerDunkFallStrong")
        string_0x0FE:; String.insert("PowerDunkLand")
        string_0x0FF:; String.insert("PowerWaveLight")
        string_0x100:; String.insert("PowerWaveStrong")
        string_0x101:; String.insert("CrackShootStart")
        string_0x102:; String.insert("CrackShootAirStart")
        string_0x103:; String.insert("CrackShootLight")
        string_0x104:; String.insert("CrackShootStrong")
        string_0x105:; String.insert("CrackShootLand")

        action_string_table:
        dw Action.COMMON.string_jab3
        dw Action.COMMON.string_jabloop
        dw Action.COMMON.string_jabloopend
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw 0;
        dw 0;
        dw 0;
        dw string_0x0E4
        dw string_0x0E5
        dw string_0x0E6
        dw 0;
        dw 0;
        dw string_0x0E9
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
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
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.TERRY, 0x4)
    dw Action.action_string_table
    OS.patch_end()

    // Custom CPU inputs
    TERRY_USP_HARD:
    AI.UNPRESS_Z()
    AI.UNPRESS_A()
    AI.UNPRESS_B()
    dh 0xA080 // stick x = tilt to opponent
    AI.STICK_Y(0, 1)
    AI.PRESS_B(9)
    AI.UNPRESS_B(1)
    AI.END()
    AI.add_cpu_input_routine(TERRY_USP_HARD)

    TERRY_CS_W:
    AI.UNPRESS_Z()
    AI.UNPRESS_A()
    AI.UNPRESS_B()
    AI.STICK_X(0) // reset stick for 1f
    AI.STICK_Y(0, 1)
    AI.STICK_X(0x84) // stick away from facing direction
    AI.PRESS_B(1)
    AI.STICK_X(0)
    AI.UNPRESS_B(1)
    AI.END()
    AI.add_cpu_input_routine(TERRY_CS_W)

    TERRY_CS_S:
    AI.UNPRESS_Z()
    AI.UNPRESS_A()
    AI.UNPRESS_B()
    AI.STICK_X(0) // reset stick for 1f
    AI.STICK_Y(0, 1)
    AI.STICK_X(0x84) // stick away from facing direction
    AI.PRESS_B(9)
    AI.STICK_X(0)
    AI.UNPRESS_B(1)
    AI.END()
    AI.add_cpu_input_routine(TERRY_CS_S)

    TERRY_PD_W:
    AI.UNPRESS_Z()
    AI.UNPRESS_A()
    AI.UNPRESS_B()
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    AI.STICK_Y(0xB0) // point stick down
    AI.PRESS_B(1)
    AI.UNPRESS_B()
    AI.STICK_Y(0, 1)
    AI.END()
    AI.add_cpu_input_routine(TERRY_PD_W)

    TERRY_PD_S:
    AI.UNPRESS_Z()
    AI.UNPRESS_A()
    AI.UNPRESS_B()
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    AI.STICK_Y(0xB0) // point stick down
    AI.PRESS_B(9)
    AI.UNPRESS_B()
    AI.STICK_Y(0, 1)
    AI.END()
    AI.add_cpu_input_routine(TERRY_PD_S)

    TERRY_BK_W:
    AI.UNPRESS_Z()
    AI.UNPRESS_A()
    AI.UNPRESS_B()
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    AI.STICK_X(0x83) // stick towards facing direction
    AI.PRESS_B(1)
    AI.UNPRESS_B()
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    AI.END()
    AI.add_cpu_input_routine(TERRY_BK_W)

    TERRY_BK_S:
    AI.UNPRESS_Z()
    AI.UNPRESS_A()
    AI.UNPRESS_B()
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    AI.STICK_X(0x83) // stick towards facing direction
    AI.PRESS_B(9)
    AI.UNPRESS_B()
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    AI.END()
    AI.add_cpu_input_routine(TERRY_BK_S)

    TERRY_PW_W:
    AI.UNPRESS_Z()
    AI.UNPRESS_A()
    AI.UNPRESS_B()
    AI.STICK_Y(0xB0) // point stick down
    AI.STICK_X(0, 9)
    AI.PRESS_B(1)
    AI.UNPRESS_B()
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    AI.END()
    AI.add_cpu_input_routine(TERRY_PW_W)

    TERRY_PW_S:
    AI.UNPRESS_Z()
    AI.UNPRESS_A()
    AI.UNPRESS_B()
    AI.STICK_Y(0xB0) // point stick down
    AI.STICK_X(0, 9)
    AI.PRESS_B(9)
    AI.UNPRESS_B()
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    AI.END()
    AI.add_cpu_input_routine(TERRY_PW_S)

    TERRY_AIRN_BK:
    AI.UNPRESS_Z()
    AI.UNPRESS_A()
    AI.UNPRESS_B()
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    AI.PRESS_A(5)
    AI.UNPRESS_A(0)
    AI.STICK_X(0x83) // stick towards facing direction
    AI.PRESS_B(9)
    AI.PRESS_B(9)
    AI.UNPRESS_B(0)
    AI.END()
    AI.add_cpu_input_routine(TERRY_AIRN_BK)

    TERRY_JAB_JAB_PD:
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
    AI.STICK_Y(0xB0) // point stick down
    AI.STICK_X(0)
    AI.PRESS_B(9)
    AI.UNPRESS_A(0)
    AI.UNPRESS_B(0)
    AI.END()
    AI.add_cpu_input_routine(TERRY_JAB_JAB_PD)

    OS.align(4)
    CPU_ATTACKS:
    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.add_attack_behaviour(JAB, 3, -450, 450, 330, 430)
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_JAB_JAB_PD, 3, -450, 450, 330, 430)
    AI.add_attack_behaviour(DTILT, 6, -430, 430, 50, 210)
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_USP_HARD, 9, -202, 316, 200, 929)
    AI.add_attack_behaviour(GRAB, 6, 71, 405, 238, 399)
    AI.add_attack_behaviour(UTILT, 7, -345, 345, 157, 809)
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_PD_W, 6, 110, 290, 210, 390)
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_PD_S, 6, 110, 290, 210, 390)
    AI.add_attack_behaviour(FTILT, 8, 169, 620, 262, 426)
    AI.add_attack_behaviour(DSMASH, 8, -733, 733, 151, 361)
    AI.add_attack_behaviour(USMASH, 10, -420, 420, 300, 860)
    // AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_CS_W, 12, 40, 1421, 293, 748)
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_CS_S, 12, 41, 571, 297, 629)
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_CS_S, 21, 1000, 1610, 293, 629)
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_BK_W, 15, 135, 1325, 325, 455) // ground
    AI.add_attack_behaviour(FSMASH, 18, 495, 908, 280, 400)
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_BK_S, 21, 135, 2100, 325, 455) // ground
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_PW_W, 17, 1400, 3200, 0, 400)
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_PW_S, 20, 1400, 3300, 0, 400)
    AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 11, 337, 1263, 80, 370)

    AI.END_ATTACKS() // end of grounded attacks
    AI.add_attack_behaviour(NAIR, 4, 15, 230, 40, 224)
    AI.add_attack_behaviour(NAIR, 4+4, 15, 230, 40, 224) // late hit
    AI.add_attack_behaviour(NAIR, 4+8, 15, 230, 40, 224) // later hit
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_AIRN_BK, 3, 69, 278, 85, 264)
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_USP_HARD, 9, -236, 275, 145, 570)
    AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 7, -26, 423, -77, 248)
    AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 7+4, -26, 423, -77, 248)
    AI.add_attack_behaviour(UAIR, 7, -381, 312, 258, 737)
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_PD_W, 6, 110, 290, 210, 390)
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_PD_S, 6, 110, 290, 210, 390)
    AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 11, -445, 62, 295, 472)
    AI.add_attack_behaviour(DAIR, 12, 73, 443, -60, 313)
    AI.add_attack_behaviour(DAIR, 12+4, 73, 443, -60, 313)
    AI.add_attack_behaviour(DAIR, 12+8, 73, 443, -60, 313)
    // AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_CS_W, 12, 40, 1421, 293, 748)
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_CS_S, 12, 41, 571, 297, 629)
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_CS_S, 21, 1000, 1610, 293, 629)
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_BK_W, 15, 135, 1325, 325, 455) // ground
    AI.add_custom_attack_behaviour(AI.ROUTINE.TERRY_BK_S, 21, 135, 2100, 325, 455) // ground

    AI.END_ATTACKS() // end of aerial attacks
    OS.align(16)

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.TERRY, 0x4)
    dw CPU_ATTACKS
    OS.patch_end()

    // Set CPU SD prevent routine
    Character.table_patch_start(ai_attack_prevent, Character.id.TERRY, 0x4)
    dw AI.PREVENT_ATTACK.ROUTINE.MARIO
    OS.patch_end()

    TERRY_RECOVERY: {
        OS.routine_begin(0x20)

        lw v0, 0x0024(a0) // v0 = current action ID
        addiu at, r0, Terry.Action.USP_L // at = Light USP
        beq at, v0, _upB
        nop
        addiu at, r0, Terry.Action.USP_H // at = Hard USP
        beq at, v0, _upB
        nop

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
            bc1t _end // do not try to NSP when not facing ledge
            nop

            _check_end:
        }

        lw at, 0xADC(a0) // flag to know if aerial nsp was already used
        bnez at, _end // if aerial nsp was already used, skip
        nop

        lui at, 0x44FA
        mtc1 at, f22 // f22 = 2000.0

        abs.s f16, f14 // f16 = abs(x distance to ledge)

        c.le.s f16, f22 // if distance to ledge is lower than 2000.0
        nop
        bc1t _end // do not go for NSP if already close to ledge
        nop

        _nsp:
        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.NSP // arg1 = NSP
        b _end
        nop

        _upB:
        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.POINT_STICK_TO_TARGET // arg1 = point to target

        lh at, 0x01C6(a0) // at = cpu buttons pressed
        ori at, at, 0x4000 // press B
        sh at, 0x01C6(a0) // save press B mask

        _end:
        OS.routine_end(0x20)
    }

    Character.table_patch_start(recovery_logic, Character.id.TERRY, 0x4)
    dw TERRY_RECOVERY
    OS.patch_end()
}
