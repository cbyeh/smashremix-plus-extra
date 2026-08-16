include "./SnakeSpecial.asm"

// This file contains file inclusions, action edits, and assembly for Snake.

scope Snake {

    insert SPARKLE_, "moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE_)
    insert SHIELDBREAK_, "moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE_)
    insert STUN_, "moveset/STUN.bin"; Moveset.GO_TO(STUN_)
    insert SLEEP_, "moveset/SLEEP.bin"; Moveset.GO_TO(SLEEP_)
    CUSTOM_THROWB:; Moveset.THROW_DATA(throwBData); Moveset.GO_TO(throwB)
    CUSTOM_THROWF:; Moveset.THROW_DATA(throwFData); Moveset.GO_TO(throwF)
    GRAB_:; Moveset.THROW_DATA(throwFData); Moveset.GO_TO(grab)

	insert RUN_,"moveset/RUN.bin"; Moveset.GO_TO(RUN_) // loops

    C4_VOICE_ARRAY:; dh Snake.FGM.NOW; dh Snake.FGM.THERE; OS.align(4);
    c4Detonate:
		Moveset.HIDE_ITEM()
        Moveset.AFTER(8);
        Moveset.RANDOM_SFX(100, 0x1, 0x2, C4_VOICE_ARRAY);
        Moveset.AFTER(22);
        Moveset.CREATE_GFX(17, 31, 0, 0, 0, 0, 0, 0);
        Moveset.END();
	
	hide_item:
		Moveset.HIDE_ITEM()
	    Moveset.END();

	UAIR_LANDING:
	dw 0x38000049, 0x98003400, 0x00000000, 0x00000000, 0x00000000, 0x00000000

    ITEM_THROW_DASH:; dw 0x08000005; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_DASH); dw 0
    ITEM_THROW_F:; dw 0xBC000003; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_B:; dw 0xBC000003; dw 0x60000008; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_U:; dw 0xBC000003; dw 0x0800000C; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_D:; dw 0xBC000003; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_SMASH_F:; dw 0xBC000003; dw 0x08000007; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_SMASH_B:; dw 0xBC000003; dw 0x60000008; dw 0x08000007; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_SMASH_U:; dw 0xBC000003; dw 0x0800000C; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_SMASH_D:; dw 0xBC000003; dw 0x08000006; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_F:; dw 0xBC000003; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_B:; dw 0xBC000003; dw 0x60000004; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_U:; dw 0xBC000003; dw 0x0800000B; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_D:; dw 0xBC000003; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW); dw 0
    ITEM_THROW_AIR_SMASH_F:; dw 0xBC000003; dw 0x08000007; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_AIR_SMASH_FB); dw 0
    ITEM_THROW_AIR_SMASH_B:; dw 0xBC000003; dw 0x60000006; dw 0x08000007; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_AIR_SMASH_FB); dw 0
    ITEM_THROW_AIR_SMASH_U:; dw 0xBC000003; dw 0x0800000B; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_SMASH_UD); dw 0
    ITEM_THROW_AIR_SMASH_D:; dw 0xBC000003; dw 0x08000006; dw 0x50000000; Moveset.SUBROUTINE(Moveset.shared.ITEM_THROW_SMASH_UD); dw 0

    // Modify Action Parameters // Action // Animation // Moveset Data // Flags
    Character.edit_action_parameters(SNAKE, Action.Entry, File.SNAKE_ANIM_IDLE, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.Idle, File.SNAKE_ANIM_IDLE, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.Revive1, File.SNAKE_ANIM_DOWNBOUNCED, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.Revive2, File.SNAKE_ANIM_DOWNSTANDD, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.ReviveWait, File.SNAKE_ANIM_IDLE, -1, -1)

    Character.edit_action_parameters(SNAKE, Action.Taunt, File.SNAKE_ANIM_TAUNT, tauntColonel, 0x10000000)

    Character.edit_action_parameters(SNAKE, Action.Walk1, File.SNAKE_ANIM_WALK1, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.Walk2, File.SNAKE_ANIM_WALK2, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.Walk3, File.SNAKE_ANIM_WALK3, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.Turn, File.SNAKE_ANIM_TURN, -1, -1)

    Character.edit_action_parameters(SNAKE, Action.Crouch, File.SNAKE_ANIM_CROUCHSTART, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.CrouchEnd, File.SNAKE_ANIM_CROUCHEND, -1, -1)

    Character.edit_action_parameters(SNAKE, Action.Dash, File.SNAKE_ANIM_DASH, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.Run, File.SNAKE_ANIM_RUN, RUN_, -1)
    Character.edit_action_parameters(SNAKE, Action.TurnRun, File.SNAKE_ANIM_TURNRUN, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.RunBrake, File.SNAKE_ANIM_RUNBRAKE, -1, -1)

    Character.edit_action_parameters(SNAKE, Action.JumpF, File.SNAKE_ANIM_JUMPF, jump, -1)
    Character.edit_action_parameters(SNAKE, Action.JumpB, File.SNAKE_ANIM_JUMPB, jump, -1)
    Character.edit_action_parameters(SNAKE, Action.JumpAerialF, File.SNAKE_ANIM_JUMPAERIALF, jumpAerial, -1)
    Character.edit_action_parameters(SNAKE, Action.JumpAerialB, File.SNAKE_ANIM_JUMPAERIALB, jumpAerial, -1)
    Character.edit_action_parameters(SNAKE, Action.Fall, File.SNAKE_ANIM_FALL, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.FallAerial, File.SNAKE_ANIM_FALLAERIAL, -1, -1)
    
    Character.edit_action_parameters(SNAKE, Action.Jab1, File.SNAKE_ANIM_JAB1, jab1, -1)
    Character.edit_action_parameters(SNAKE, Action.Jab2, File.SNAKE_ANIM_JAB2, jab2, -1)
    Character.edit_action_parameters(SNAKE, 0xDC, File.SNAKE_ANIM_JAB3, jab3, -1)

    Character.edit_action_parameters(SNAKE, Action.DashAttack, File.SNAKE_ANIM_ATTACKDASH, attackDash, -1)

    Character.edit_action_parameters(SNAKE, Action.AttackAirN, File.SNAKE_ANIM_AIRN, airN, -1)
    Character.edit_action_parameters(SNAKE, Action.AttackAirF, File.SNAKE_ANIM_AIRF, airF, -1)
    Character.edit_action_parameters(SNAKE, Action.AttackAirB, File.SNAKE_ANIM_AIRB, airB, -1)
    Character.edit_action_parameters(SNAKE, Action.AttackAirU, File.SNAKE_ANIM_AIRU, airU, -1)
    Character.edit_action_parameters(SNAKE, Action.AttackAirD, File.SNAKE_ANIM_AIRD, airD, -1)

    Character.edit_action_parameters(SNAKE, Action.FTiltHigh, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(SNAKE, Action.FTiltMidHigh, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(SNAKE, Action.FTilt, File.SNAKE_ANIM_TILTF, 0, 0x40000000)
    Character.edit_action_parameters(SNAKE, Action.FTiltMidLow, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(SNAKE, Action.FTiltLow, 0, 0x80000000, 0x00000000)

    Character.edit_action_parameters(SNAKE, Action.FSmashHigh, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(SNAKE, Action.FSmashMidHigh, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(SNAKE, Action.FSmash, File.SNAKE_ANIM_SMASHF, smashF, 0x00000000)
    Character.edit_action_parameters(SNAKE, Action.FSmashMidLow, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(SNAKE, Action.FSmashLow, 0, 0x80000000, 0x00000000)

    Character.edit_action_parameters(SNAKE, Action.USmash, File.SNAKE_ANIM_SMASHU, smashU, 0x00000000)

    Character.edit_action_parameters(SNAKE, Action.DSmash, File.SNAKE_ANIM_SMASHF, smashF, 0x00000000)

    Character.edit_action_parameters(SNAKE, Action.DTilt, File.SNAKE_ANIM_TILTD, tiltD, -1)
    Character.edit_action_parameters(SNAKE, Action.UTilt, File.SNAKE_ANIM_TILTU, tiltU, -1)

    Character.edit_action_parameters(SNAKE, Action.Grab, File.SNAKE_ANIM_GRAB, GRAB_, -1)
    Character.edit_action_parameters(SNAKE, Action.GrabPull, File.SNAKE_ANIM_GRABPULL, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.ThrowF, File.SNAKE_ANIM_THROWF, CUSTOM_THROWF, -1)
    Character.edit_action_parameters(SNAKE, Action.ThrowB, File.SNAKE_ANIM_THROWB, CUSTOM_THROWB, -1)

    Character.edit_action_parameters(SNAKE, Action.ShieldBreak, -1, SHIELDBREAK_, -1)
    Character.edit_action_parameters(SNAKE, Action.Stun, -1, STUN_, -1)
    Character.edit_action_parameters(SNAKE, Action.Sleep, -1, SLEEP_, -1)

    Character.edit_action_parameters(SNAKE, Action.DamageHigh1, File.SNAKE_ANIM_DAMAGEHI1, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DamageHigh2, File.SNAKE_ANIM_DAMAGEHI2, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DamageHigh3, File.SNAKE_ANIM_DAMAGEHI3, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DamageMid1, File.SNAKE_ANIM_DAMAGEN1, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DamageMid2, File.SNAKE_ANIM_DAMAGEN2, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DamageMid3, File.SNAKE_ANIM_DAMAGEN3, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DamageLow1, File.SNAKE_ANIM_DAMAGELW1, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DamageLow2, File.SNAKE_ANIM_DAMAGELW2, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DamageLow3, File.SNAKE_ANIM_DAMAGELW3, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DamageAir1, File.SNAKE_ANIM_DAMAGEAIR1, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DamageAir2, File.SNAKE_ANIM_DAMAGEAIR2, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DamageAir3, File.SNAKE_ANIM_DAMAGEAIR3, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DamageFlyHigh, File.SNAKE_ANIM_DAMAGEFLYHI, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DamageFlyMid, File.SNAKE_ANIM_DAMAGEFLYN, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DamageFlyLow, File.SNAKE_ANIM_DAMAGEFLYLW, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.Tumble, File.SNAKE_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DamageFlyTop, File.SNAKE_ANIM_DAMAGEFLYTOP, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DamageFlyRoll, File.SNAKE_ANIM_DAMAGEFLYROLL, -1, -1)

    Character.edit_action_parameters(SNAKE, Action.ShieldOn, File.SNAKE_ANIM_SHIELDON, -1, 0xA0000000);
    Character.edit_action_parameters(SNAKE, Action.ShieldOff, File.SNAKE_ANIM_SHIELDOFF, -1, 0xA0000000);

    Character.edit_action_parameters(SNAKE, Action.RollB, File.SNAKE_ANIM_ROLLB, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.RollF, File.SNAKE_ANIM_ROLLF, -1, -1)
	
    Character.edit_action_parameters(SNAKE, Action.Tech, File.SNAKE_ANIM_TECH, Tech, -1)
    Character.edit_action_parameters(SNAKE, Action.TechF, File.SNAKE_ANIM_TECHF, TechRoll, -1)
    Character.edit_action_parameters(SNAKE, Action.TechB, File.SNAKE_ANIM_TECHB, TechRoll, -1)
    Character.edit_action_parameters(SNAKE, Action.CliffAttackQuick2, -1, CliffATKQuick, -1)
    Character.edit_action_parameters(SNAKE, Action.CliffAttackSlow2, -1, CliffATKSlow, -1)
    Character.edit_action_parameters(SNAKE, Action.Teeter, -1, Teeter, -1)

    Character.edit_action_parameters(SNAKE, Action.CapturePulled, File.SNAKE_ANIM_CAPTUREPULLED, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DownBounceD, File.SNAKE_ANIM_DOWNBOUNCED, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DownBounceU, File.SNAKE_ANIM_DOWNBOUNCEU, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.StunLandD, File.SNAKE_ANIM_DOWNBOUNCED, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.StunLandU, File.SNAKE_ANIM_DOWNBOUNCEU, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.Pass, File.SNAKE_ANIM_PASSPLATFORMDROP, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.ClangRecoil, File.SNAKE_ANIM_CLANGRECOIL, -1, -1)

    Character.edit_action_parameters(SNAKE, Action.DownAttackD, File.SNAKE_ANIM_DOWNATTACKD, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DownAttackU, File.SNAKE_ANIM_DOWNATTACKU, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DownStandD, File.SNAKE_ANIM_DOWNSTANDD, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DownStandU, File.SNAKE_ANIM_DOWNSTANDU, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DownForwardD, File.SNAKE_ANIM_DOWNFORWARDD, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DownForwardU, File.SNAKE_ANIM_DOWNFORWARDU, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DownBackD, File.SNAKE_ANIM_DOWNBACKD, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DownBackU, File.SNAKE_ANIM_DOWNBACKU, -1, -1)

    Character.edit_action_parameters(SNAKE, Action.InhalePulled, File.SNAKE_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.InhaleSpat, File.SNAKE_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.InhaleCopied, File.SNAKE_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(SNAKE, 0x0B4, File.SNAKE_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.DeadU, File.SNAKE_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.ScreenKO, File.SNAKE_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.WallBounce, File.SNAKE_ANIM_DAMAGEFALL, -1, -1)
    
    Character.edit_action_parameters(SNAKE, Action.ShieldDrop, File.SNAKE_ANIM_PASSPLATFORMDROP, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.ShieldBreakFall, File.SNAKE_ANIM_DAMAGEFALL, -1, -1)
    Character.edit_action_parameters(SNAKE, Action.ShieldBreak, File.SNAKE_ANIM_DAMAGEFLYTOP, -1, -1)

    Character.edit_action_parameters(SNAKE, Action.FalconDivePulled, File.SNAKE_ANIM_DAMAGEHI3, -1, -1)

    Character.edit_action_parameters(SNAKE, Action.JumpSquat, File.SNAKE_ANIM_LANDING, -1, -1);
    Character.edit_action_parameters(SNAKE, Action.ShieldJumpSquat, File.SNAKE_ANIM_LANDING, -1, -1);
    Character.edit_action_parameters(SNAKE, Action.LandingLight, File.SNAKE_ANIM_LANDING, -1, -1);
    Character.edit_action_parameters(SNAKE, Action.LandingHeavy, File.SNAKE_ANIM_LANDING, -1, -1);
    Character.edit_action_parameters(SNAKE, Action.LandingAirX, File.SNAKE_ANIM_LANDING, -1, -1);
    Character.edit_action_parameters(SNAKE, Action.LandingAirU, File.SNAKE_ANIM_LANDINGAIRU, UAIR_LANDING, -1);
    Character.edit_action_parameters(SNAKE, Action.LandingAirF, File.SNAKE_ANIM_LANDINGAIRF, -1, -1);
    Character.edit_action_parameters(SNAKE, Action.LandingAirB, File.SNAKE_ANIM_LANDINGAIRB, -1, -1);

    Character.edit_action_parameters(SNAKE, Action.ItemThrowDash, File.SNAKE_ANIM_ITEMTHROWDASH, ITEM_THROW_DASH, -1)
    Character.edit_action_parameters(SNAKE, Action.ItemThrowF, File.SNAKE_ANIM_ITEMTHROWF, ITEM_THROW_F, -1)
    Character.edit_action_parameters(SNAKE, Action.ItemThrowB, File.SNAKE_ANIM_ITEMTHROWF, ITEM_THROW_B, -1)
    Character.edit_action_parameters(SNAKE, Action.ItemThrowU, File.SNAKE_ANIM_ITEMTHROWU, ITEM_THROW_U, -1)
    Character.edit_action_parameters(SNAKE, Action.ItemThrowD, File.SNAKE_ANIM_ITEMTHROWD, ITEM_THROW_D, -1)
    Character.edit_action_parameters(SNAKE, Action.ItemThrowSmashF, File.SNAKE_ANIM_ITEMTHROWF, ITEM_THROW_SMASH_F, -1)
    Character.edit_action_parameters(SNAKE, Action.ItemThrowSmashB, File.SNAKE_ANIM_ITEMTHROWF, ITEM_THROW_SMASH_B, -1)
    Character.edit_action_parameters(SNAKE, Action.ItemThrowSmashU, File.SNAKE_ANIM_ITEMTHROWU, ITEM_THROW_SMASH_U, -1)
    Character.edit_action_parameters(SNAKE, Action.ItemThrowSmashD, File.SNAKE_ANIM_ITEMTHROWD, ITEM_THROW_SMASH_D, -1)
    Character.edit_action_parameters(SNAKE, Action.ItemThrowAirF, File.SNAKE_ANIM_ITEMTHROWAIRF, ITEM_THROW_AIR_F, -1)
    Character.edit_action_parameters(SNAKE, Action.ItemThrowAirB, File.SNAKE_ANIM_ITEMTHROWAIRF, ITEM_THROW_AIR_B, -1)
    Character.edit_action_parameters(SNAKE, Action.ItemThrowAirU, File.SNAKE_ANIM_ITEMTHROWAIRU, ITEM_THROW_AIR_U, -1)
    Character.edit_action_parameters(SNAKE, Action.ItemThrowAirD, File.SNAKE_ANIM_ITEMTHROWAIRD, ITEM_THROW_AIR_D, -1)
    Character.edit_action_parameters(SNAKE, Action.ItemThrowAirSmashF, File.SNAKE_ANIM_ITEMTHROWAIRF, ITEM_THROW_AIR_SMASH_F, -1)
    Character.edit_action_parameters(SNAKE, Action.ItemThrowAirSmashB, File.SNAKE_ANIM_ITEMTHROWAIRF, ITEM_THROW_AIR_SMASH_B, -1)
    Character.edit_action_parameters(SNAKE, Action.ItemThrowAirSmashU, File.SNAKE_ANIM_ITEMTHROWAIRU, ITEM_THROW_AIR_SMASH_U, -1)
    Character.edit_action_parameters(SNAKE, Action.ItemThrowAirSmashD, File.SNAKE_ANIM_ITEMTHROWAIRD, ITEM_THROW_AIR_SMASH_D, -1)

    Character.edit_action_parameters(SNAKE, 0xE0, File.SNAKE_ANIM_ENTRYR, entry, 0x40000009)
    Character.edit_action_parameters(SNAKE, 0xE1, File.SNAKE_ANIM_ENTRYL, entry, 0x40000009)

    // Modify Actions // Action // Staling ID // Main ASM // Interrupt/Other ASM // Movement/Physics ASM // Collision ASM
    Character.edit_action(SNAKE, 0xE0, -1, 0x8013DA94, 0, 0x8013DB2C, 0x800DE348) // LEFT ENTRY
    Character.edit_action(SNAKE, 0xE1, -1, 0x8013DA94, 0, 0x8013DB2C, 0x800DE348) // RIGHT ENTRY

    // Modify Menu Action Parameters // Action // Animation // Moveset Data // Flags
    Character.edit_menu_action_parameters(SNAKE, 0x0, File.SNAKE_ANIM_IDLECSS, BOX, -1)
    Character.edit_menu_action_parameters(SNAKE, 0x1, File.SNAKE_ANIM_VICTORY1, WIN1, -1)
    Character.edit_menu_action_parameters(SNAKE, 0x2, File.SNAKE_ANIM_VICTORY2, WIN2, -1)
    Character.edit_menu_action_parameters(SNAKE, 0x3, File.SNAKE_ANIM_VICTORY3, WIN3, -1)
    Character.edit_menu_action_parameters(SNAKE, 0x4, File.SNAKE_ANIM_VICTORY1, CSS, -1)
    Character.edit_menu_action_parameters(SNAKE, 0x5, File.SNAKE_ANIM_CLAPS, -1, -1)
    Character.edit_menu_action_parameters(SNAKE, 0xE, File.SNAKE_ANIM_IDLE, -1, -1)
    Character.edit_menu_action_parameters(SNAKE, 0xD, File.SNAKE_ANIM_1PPOSE, BOX, -1)

    // Add new actions
    // Jab 2 (with root motion)
    Character.add_new_action_params(SNAKE, JAB2_, -1, File.SNAKE_ANIM_JAB2, jab2, 0x40000000)
    Character.add_new_action(SNAKE, JAB2_, -1, ActionParams.JAB2_, -1, 0x8014E824, 0x8014E9B4, 0x800D8C14, 0x800DDF44)

    // Dash attack
    Character.add_new_action_params(SNAKE, DASHATTACK, -1, File.SNAKE_ANIM_ATTACKDASH, attackDash, 0x40000000)
    Character.add_new_action(SNAKE, DASHATTACK, Action.DashAttack, ActionParams.DASHATTACK, -1, SnakeSpecial.DashAttack.main, 0, 0x800D8C14, 0x800DDF44)

    // Crouch, crawl
    Character.add_new_action_params(SNAKE, CROUCH, -1, File.SNAKE_ANIM_CROUCH, crouch, 0x0)
    Character.add_new_action(SNAKE, CROUCH, Action.CrouchIdle, ActionParams.CROUCH, -1, 0x8014314C, SnakeSpecial.Crawl.interrupt, 0x800D8BB4, 0x800DDEC4)

    Character.add_new_action_params(SNAKE, CROUCHF, -1, File.SNAKE_ANIM_CROUCHF, crouch, 0x0)
    Character.add_new_action(SNAKE, CROUCHF, Action.CrouchIdle, ActionParams.CROUCHF, -1, 0x8014314C, SnakeSpecial.Crawl.interrupt, SnakeSpecial.Crawl.physics, 0x800DDEC4)

    Character.add_new_action_params(SNAKE, CROUCHB, -1, File.SNAKE_ANIM_CROUCHB, crouch, 0x0)
    Character.add_new_action(SNAKE, CROUCHB, Action.CrouchIdle, ActionParams.CROUCHB, -1, 0x8014314C, SnakeSpecial.Crawl.interrupt, SnakeSpecial.Crawl.physics, 0x800DDEC4)

    // Ftilt
    Character.add_new_action_params(SNAKE, TILTF, -1, File.SNAKE_ANIM_TILTF, tiltF, 0x40000000)
    Character.add_new_action(SNAKE, TILTF, Action.FTilt, ActionParams.TILTF, -1, SnakeSpecial.TiltF.main, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action_params(SNAKE, TILTF2, -1, File.SNAKE_ANIM_TILTF2, tiltF2, 0x40000000)
    Character.add_new_action(SNAKE, TILTF2, Action.FTilt, ActionParams.TILTF2, -1, 0x800D94C4, 0, 0x800D8C14, 0x800DDF44)

    // Grenade actions (grounded)
    Character.add_new_action_params(SNAKE, GRENADESTART, -1, File.SNAKE_ANIM_SPECIALNSTART, grenadeStart, 0x00000000)
    Character.add_new_action(SNAKE, GRENADESTART, -1, ActionParams.GRENADESTART, -1, SnakeSpecial.Grenade.Start.main, 0, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action_params(SNAKE, GRENADEWAIT, -1, File.SNAKE_ANIM_SPECIALNWAIT, 0, 0x00000000)
    Character.add_new_action(SNAKE, GRENADEWAIT, -1, ActionParams.GRENADEWAIT, -1, SnakeSpecial.Grenade.Wait.main, SnakeSpecial.Grenade.Walk.interrupt, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action_params(SNAKE, GRENADETHROWN, -1, File.SNAKE_ANIM_SPECIALNTHROWN, grenadeThrowN, 0x00000000)
    Character.add_new_action(SNAKE, GRENADETHROWN, -1, ActionParams.GRENADETHROWN, -1, SnakeSpecial.Grenade.Throw.main, 0, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action_params(SNAKE, GRENADETHROWEMPTY, -1, File.SNAKE_ANIM_SPECIALNTHROWN, grenadeThrowEmpty, 0x00000000)
    Character.add_new_action(SNAKE, GRENADETHROWEMPTY, -1, ActionParams.GRENADETHROWEMPTY, -1, 0x800D94C4, 0, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action_params(SNAKE, GRENADETHROWF, -1, File.SNAKE_ANIM_SPECIALNTHROWF, grenadeThrowF, 0x00000000)
    Character.add_new_action(SNAKE, GRENADETHROWF, -1, ActionParams.GRENADETHROWF, -1, SnakeSpecial.Grenade.Throw.main, 0, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action_params(SNAKE, GRENADETHROWB, -1, File.SNAKE_ANIM_SPECIALNTHROWB, grenadeThrowB, 0x00000000)
    Character.add_new_action(SNAKE, GRENADETHROWB, -1, ActionParams.GRENADETHROWB, -1, SnakeSpecial.Grenade.Throw.main, 0, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action_params(SNAKE, GRENADEWALKF, -1, File.SNAKE_ANIM_SPECIALNWALKF, 0, 0x00000000)
    Character.add_new_action(SNAKE, GRENADEWALKF, -1, ActionParams.GRENADEWALKF, -1, SnakeSpecial.Grenade.Wait.main, SnakeSpecial.Grenade.Walk.interrupt, SnakeSpecial.Grenade.Walk.physics, 0x800DDF44)

    Character.add_new_action_params(SNAKE, GRENADEWALKB, -1, File.SNAKE_ANIM_SPECIALNWALKB, 0, 0x00000000)
    Character.add_new_action(SNAKE, GRENADEWALKB, -1, ActionParams.GRENADEWALKB, -1, SnakeSpecial.Grenade.Wait.main, SnakeSpecial.Grenade.Walk.interrupt, SnakeSpecial.Grenade.Walk.physics, 0x800DDF44)

    Character.add_new_action_params(SNAKE, GRENADEJUMPSQUAT, -1, File.SNAKE_ANIM_SPECIALNJUMPSQUAT, 0, 0x00000000)
    Character.add_new_action(SNAKE, GRENADEJUMPSQUAT, -1, ActionParams.GRENADEJUMPSQUAT, -1, SnakeSpecial.Grenade.JumpSquat.main, 0, 0x800D8BB4, 0x800DDF44)

    // Grenade actions (aerial)
    Character.add_new_action_params(SNAKE, GRENADESTARTAIR, -1, File.SNAKE_ANIM_SPECIALNSTARTAIR, grenadeStart, 0x00000000)
    Character.add_new_action(SNAKE, GRENADESTARTAIR, -1, ActionParams.GRENADESTARTAIR, -1, SnakeSpecial.Grenade.Start.main, 0, 0x800D90E0, SnakeSpecial.Grenade.Start.air_collision)

    Character.add_new_action_params(SNAKE, GRENADEWAITAIR, -1, File.SNAKE_ANIM_SPECIALNWAITAIR, 0, 0x00000000)
    Character.add_new_action(SNAKE, GRENADEWAITAIR, -1, ActionParams.GRENADEWAITAIR, -1, SnakeSpecial.Grenade.Wait.main, 0, 0x800D90E0, SnakeSpecial.Grenade.Wait.air_collision)

    Character.add_new_action_params(SNAKE, GRENADETHROWNAIR, -1, File.SNAKE_ANIM_SPECIALNTHROWNAIR, grenadeThrowN, 0x00000000)
    Character.add_new_action(SNAKE, GRENADETHROWNAIR, -1, ActionParams.GRENADETHROWNAIR, -1, SnakeSpecial.Grenade.Throw.main, 0, 0x800D90E0, SnakeSpecial.Grenade.Throw.air_collision)

    Character.add_new_action_params(SNAKE, GRENADETHROWEMPTYAIR, -1, File.SNAKE_ANIM_SPECIALNTHROWNAIR, grenadeThrowEmpty, 0x00000000)
    Character.add_new_action(SNAKE, GRENADETHROWEMPTYAIR, -1, ActionParams.GRENADETHROWEMPTYAIR, -1, 0x800D94E8, 0, 0x800D90E0, SnakeSpecial.Grenade.Throw.air_collision)

    Character.add_new_action_params(SNAKE, GRENADETHROWFAIR, -1, File.SNAKE_ANIM_SPECIALNTHROWFAIR, grenadeThrowF, 0x00000000)
    Character.add_new_action(SNAKE, GRENADETHROWFAIR, -1, ActionParams.GRENADETHROWFAIR, -1, SnakeSpecial.Grenade.Throw.main, 0, 0x800D90E0, SnakeSpecial.Grenade.Throw.air_collision)

    Character.add_new_action_params(SNAKE, GRENADETHROWBAIR, -1, File.SNAKE_ANIM_SPECIALNTHROWBAIR, grenadeThrowB, 0x00000000)
    Character.add_new_action(SNAKE, GRENADETHROWBAIR, -1, ActionParams.GRENADETHROWBAIR, -1, SnakeSpecial.Grenade.Throw.main, 0, 0x800D90E0, SnakeSpecial.Grenade.Throw.air_collision)

    // grenadethrowbair
    // grenadethrowfair

    // C4 actions (grounded)
    Character.add_new_action_params(SNAKE, C4START, -1, File.SNAKE_ANIM_C4START, hide_item, 0x00000000)
    Character.add_new_action(SNAKE, C4START, -1, ActionParams.C4START, -1, SnakeSpecial.C4.Start.main, 0, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action_params(SNAKE, C4GROUND, -1, File.SNAKE_ANIM_C4GROUND, hide_item, 0x00000000)
    Character.add_new_action(SNAKE, C4GROUND, -1, ActionParams.C4GROUND, -1, SnakeSpecial.C4.Ground.main_ground, 0, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action_params(SNAKE, C4WALL, -1, File.SNAKE_ANIM_C4WALL, hide_item, 0x00000000)
    Character.add_new_action(SNAKE, C4WALL, -1, ActionParams.C4WALL, -1, SnakeSpecial.C4.Ground.main_ground, 0, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action_params(SNAKE, C4ENEMY, -1, File.SNAKE_ANIM_C4ENEMY, hide_item, 0x00000000)
    Character.add_new_action(SNAKE, C4ENEMY, -1, ActionParams.C4ENEMY, -1, SnakeSpecial.C4.Ground.main_ground, 0, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action_params(SNAKE, C4DETONATE, -1, File.SNAKE_ANIM_C4DETONATE, c4Detonate, 0x00000000)
    Character.add_new_action(SNAKE, C4DETONATE, -1, ActionParams.C4DETONATE, -1, SnakeSpecial.C4.Detonate.main_ground, 0, 0x800D8BB4, 0x800DDF44)

    // C4 actions (air)
    Character.add_new_action_params(SNAKE, C4AIRSTART, -1, File.SNAKE_ANIM_C4AIRSTART, hide_item, 0x00000000)
    Character.add_new_action(SNAKE, C4AIRSTART, -1, ActionParams.C4AIRSTART, -1, SnakeSpecial.C4.Start.main, 0, 0x800D90E0, SnakeSpecial.C4.Start.air_collision)

    Character.add_new_action_params(SNAKE, C4AIRGROUND, -1, File.SNAKE_ANIM_C4AIRGROUND, hide_item, 0x00000000)
    Character.add_new_action(SNAKE, C4AIRGROUND, -1, ActionParams.C4AIRGROUND, -1, SnakeSpecial.C4.Ground.main_air, 0, 0x800D90E0, 0x800DE978)

    Character.add_new_action_params(SNAKE, C4AIRWALL, -1, File.SNAKE_ANIM_C4AIRWALL, hide_item, 0x00000000)
    Character.add_new_action(SNAKE, C4AIRWALL, -1, ActionParams.C4AIRWALL, -1, SnakeSpecial.C4.Ground.main_air, 0, 0x800D90E0, 0x800DE978)

    Character.add_new_action_params(SNAKE, C4AIRENEMY, -1, File.SNAKE_ANIM_C4AIRENEMY, hide_item, 0x00000000)
    Character.add_new_action(SNAKE, C4AIRENEMY, -1, ActionParams.C4AIRENEMY, -1, SnakeSpecial.C4.Ground.main_air, 0, 0x800D90E0, 0x800DE978)

    Character.add_new_action_params(SNAKE, C4AIRDETONATE, -1, File.SNAKE_ANIM_C4AIRDETONATE, c4Detonate, 0x00000000)
    Character.add_new_action(SNAKE, C4AIRDETONATE, -1, ActionParams.C4AIRDETONATE, -1, SnakeSpecial.C4.Detonate.main_air, 0, 0x800D90E0, SnakeSpecial.C4.Detonate.air_collision)

    Character.table_patch_start(ground_dsp, Character.id.SNAKE, 0x4)
    dw SnakeSpecial.C4.initial
    OS.patch_end()

    Character.table_patch_start(air_dsp, Character.id.SNAKE, 0x4)
    dw SnakeSpecial.C4.initial
    OS.patch_end()

    // Nikita actions (grounded)
    Character.add_new_action_params(SNAKE, NIKITASTART, -1, File.SNAKE_ANIM_NIKITASTART, nikitaStart, 0x00000000)
    Character.add_new_action(SNAKE, NIKITASTART, -1, ActionParams.NIKITASTART, -1, SnakeSpecial.Nikita.Start.main, 0, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action_params(SNAKE, NIKITAOPERATION, -1, File.SNAKE_ANIM_NIKITAOPERATION, nikitaOperation, 0x00000000)
    Character.add_new_action(SNAKE, NIKITAOPERATION, -1, ActionParams.NIKITAOPERATION, -1, SnakeSpecial.Nikita.Operation.main, 0, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action_params(SNAKE, NIKITAEND, -1, File.SNAKE_ANIM_NIKITAEND, nikitaEnd, 0x00000000)
    Character.add_new_action(SNAKE, NIKITAEND, -1, ActionParams.NIKITAEND, -1, 0x800D94C4, 0, 0x800D8BB4, 0x800DDF44)

    Character.add_new_action_params(SNAKE, NIKITASUCCESS, -1, File.SNAKE_ANIM_NIKITASUCCESS, 0, 0x00000000)
    Character.add_new_action(SNAKE, NIKITASUCCESS, -1, ActionParams.NIKITASUCCESS, -1, 0x800D94C4, 0, 0x800D8BB4, 0x800DDF44)

    // Nikita actions (air)
    Character.add_new_action_params(SNAKE, NIKITAAIRSTART, -1, File.SNAKE_ANIM_NIKITASTART, nikitaStart, 0x00000000)
    Character.add_new_action(SNAKE, NIKITAAIRSTART, -1, ActionParams.NIKITAAIRSTART, -1, SnakeSpecial.Nikita.Start.main, 0, 0x800D90E0, SnakeSpecial.Nikita.Start.air_collision)

    Character.add_new_action_params(SNAKE, NIKITAAIROPERATION, -1, File.SNAKE_ANIM_NIKITAOPERATION, nikitaOperation, 0x00000000)
    Character.add_new_action(SNAKE, NIKITAAIROPERATION, -1, ActionParams.NIKITAAIROPERATION, -1, SnakeSpecial.Nikita.Operation.main, 0, 0x800D90E0, SnakeSpecial.Nikita.Operation.air_collision)

    Character.add_new_action_params(SNAKE, NIKITAAIREND, -1, File.SNAKE_ANIM_NIKITAEND, nikitaEnd, 0x00000000)
    Character.add_new_action(SNAKE, NIKITAAIREND, -1, ActionParams.NIKITAAIREND, -1, 0x800D94E8, 0, 0x800D90E0, SnakeSpecial.Nikita.End.air_collision)

    Character.add_new_action_params(SNAKE, NIKITAAIRSUCCESS, -1, File.SNAKE_ANIM_NIKITASUCCESS, 0, 0x00000000)
    Character.add_new_action(SNAKE, NIKITAAIRSUCCESS, -1, ActionParams.NIKITAAIRSUCCESS, -1, 0x800D94E8, 0, 0x800D90E0, SnakeSpecial.Nikita.Success.air_collision)

    Character.table_patch_start(ground_nsp, Character.id.SNAKE, 0x4)
    dw SnakeSpecial.Grenade.initial
    OS.patch_end()

    Character.table_patch_start(air_nsp, Character.id.SNAKE, 0x4)
    dw SnakeSpecial.Grenade.initial
    OS.patch_end()

    // Cypher actions
    Character.add_new_action_params(SNAKE, CYPHERSTART, -1, File.SNAKE_ANIM_CYPHERSTART, cypherStart, 0x00000000)
    Character.add_new_action(SNAKE, CYPHERSTART, -1, ActionParams.CYPHERSTART, -1, SnakeSpecial.Cypher.Start.main, 0, 0x800D8BB4, 0x800DDF44)
    
    Character.add_new_action_params(SNAKE, CYPHERAIRSTART, -1, File.SNAKE_ANIM_CYPHERAIRSTART, cypherStart, 0x00000000)
    Character.add_new_action(SNAKE, CYPHERAIRSTART, -1, ActionParams.CYPHERAIRSTART, -1, SnakeSpecial.Cypher.Start.main, 0, 0x800D90E0, SnakeSpecial.Cypher.Start.air_collision)
    
    Character.add_new_action_params(SNAKE, CYPHERAIRHANG, -1, File.SNAKE_ANIM_CYPHERAIRHANG, cypher, 0x00000000)
    Character.add_new_action(SNAKE, CYPHERAIRHANG, -1, ActionParams.CYPHERAIRHANG, -1, SnakeSpecial.Cypher.Hang.main, SnakeSpecial.Cypher.Hang.interrupt, 0x800D90E0, 0x800DE87C)
    
    Character.add_new_action_params(SNAKE, CYPHERAIRCUT, -1, File.SNAKE_ANIM_CYPHERAIRCUT, 0x0, 0x00000000)
    Character.add_new_action(SNAKE, CYPHERAIRCUT, -1, ActionParams.CYPHERAIRCUT, -1, 0x800D94E8, 0x8013F660, 0x800D90E0, 0x800DE99C)

    Character.table_patch_start(ground_usp, Character.id.SNAKE, 0x4)
    dw SnakeSpecial.Cypher.initial
    OS.patch_end()

    Character.table_patch_start(air_usp, Character.id.SNAKE, 0x4)
    dw SnakeSpecial.Cypher.initial
    OS.patch_end()

    // USmash
    Character.add_new_action_params(SNAKE, SMASHU, -1, File.SNAKE_ANIM_SMASHU, smashU, 0x00000000)
    Character.add_new_action(SNAKE, SMASHU, Action.USmash, ActionParams.SMASHU, -1, SnakeSpecial.USmash.main, 0, 0x800D8BB4, 0x800DDF44)

    // Taunt
    Character.add_new_action_params(SNAKE, TAUNT_COLONEL, -1, File.SNAKE_ANIM_TAUNT, tauntColonel, 0x10000000)
    Character.add_new_action(SNAKE, TAUNT_COLONEL, Action.Taunt, ActionParams.TAUNT_COLONEL, -1, SnakeSpecial.Taunt.main, 0x8014E6A0, 0x800D8BB4, 0x800DDEE8)

    Character.add_new_action_params(SNAKE, TAUNT_MEILING, -1, File.SNAKE_ANIM_TAUNT, tauntMeiling, 0x10000000)
    Character.add_new_action(SNAKE, TAUNT_MEILING, Action.Taunt, ActionParams.TAUNT_MEILING, -1, 0x800D94C4, 0x8014E6A0, 0x800D8BB4, 0x800DDEE8)

    Character.add_new_action_params(SNAKE, TAUNT_OTACON, -1, File.SNAKE_ANIM_TAUNT, tauntOtacon, 0x10000000)
    Character.add_new_action(SNAKE, TAUNT_OTACON, Action.Taunt, ActionParams.TAUNT_OTACON, -1, 0x800D94C4, 0x8014E6A0, 0x800D8BB4, 0x800DDEE8)

    Character.add_new_action_params(SNAKE, TAUNT_FALCON, -1, File.SNAKE_ANIM_TAUNT, tauntFalcon, 0x10000000)
    Character.add_new_action(SNAKE, TAUNT_FALCON, Action.Taunt, ActionParams.TAUNT_FALCON, -1, 0x800D94C4, 0x8014E6A0, 0x800D8BB4, 0x800DDEE8)

    Character.add_new_action_params(SNAKE, TAUNT_SLIPPY, -1, File.SNAKE_ANIM_TAUNT, tauntSlippy, 0x10000000)
    Character.add_new_action(SNAKE, TAUNT_SLIPPY, Action.Taunt, ActionParams.TAUNT_SLIPPY, -1, 0x800D94C4, 0x8014E6A0, 0x800D8BB4, 0x800DDEE8)

    // Action replacement map
    scope action_replace_map_: {
        dh Action.Jab2; dh Snake.Action.JAB2_;
        dh Action.DashAttack; dh Snake.Action.DASHATTACK;
        dh Action.CrouchIdle; dh Snake.Action.CROUCH;
        dh Action.FTilt; dh Snake.Action.TILTF;
        dh Action.USmash; dh Snake.Action.SMASHU;
        dh Action.Taunt; dh Snake.Action.TAUNT_COLONEL;
        dh Action.FSmash; dh Snake.Action.NIKITASTART;
        dw 0xFFFFFFFF // end of map
    }

    // Set action replacement table
    Character.table_patch_start(action_replace_map, Character.id.SNAKE, 0x4)
    dw action_replace_map_
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.SNAKE, 0, 1, 2, 3, 1, 5, 2)
    Teams.add_team_costume(YELLOW, SNAKE, 6)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(SNAKE, BLACK, RED, GREEN, WHITE, BLACK, AZURE, YELLOW, NA)

    // Character.table_patch_start(ground_usp, Character.id.SNAKE, 0x4)
    // dw SnakeUSP.begin_initial_
    // OS.patch_end()
	
    // Character.table_patch_start(air_usp, Character.id.SNAKE, 0x4)
    // dw SnakeUSP.air_initial_
    // OS.patch_end()

    // Remove entry script (no Blue Falcon).
    Character.table_patch_start(entry_script, Character.id.SNAKE, 0x4)
    dw 0x8013DD68 // skips entry script
    OS.patch_end()

    scope grounded_script_: {
        j Character.grounded_script.DISABLED // back to original routine
        sw r0, 0x0AE4(v0) // clear usp flag
    }
    Character.table_patch_start(grounded_script, Character.id.SNAKE, 0x4)
    dw grounded_script_
    OS.patch_end()

    scope initial_script_: {
        j 0x800D7F0C // back to original routine
        sw r0, 0x0AE4(v1) // clear usp flag
    }
    Character.table_patch_start(initial_script, Character.id.SNAKE, 0x4)
    dw initial_script_
    OS.patch_end()

    // Use custom action for the grabbed character when grabbing
    Character.table_patch_start(custom_capture_action, Character.id.SNAKE, 0x4)
    dw Action.ThrownDK
    OS.patch_end()

    // Fix the logic for breaking out of ThrownDK since we're using it for our grabbed opponent
    scope capture_action_fix_: {
        jr ra
        lli v0, 0x1 // return 1, which means it just skips the function completely
    }
    Character.table_patch_start(custom_capture_dk_interrupt, Character.id.SNAKE, 0x4)
    dw capture_action_fix_
    OS.patch_end()

    // // Set crowd chant FGM.
    // Character.table_patch_start(crowd_chant_fgm, Character.id.SNAKE, 0x2)
    // dh FGM.CHANT
    // OS.patch_end()

    // // Set action strings
    // Character.table_patch_start(action_string, Character.id.SNAKE, 0x4)
    // dw Action.CAPTAIN.action_string_table
    // OS.patch_end()
    
    Character.table_patch_start(rapid_jab, Character.id.SNAKE, 0x4)
    dw Character.rapid_jab.DISABLED // disable rapid jab
    OS.patch_end()

    // Insert AI attack options
    include "AI.asm"

    scope Action {
        string_0x0F6:; String.insert("CrawlF")
        string_0x0F7:; String.insert("CrawlB")
        string_0x0F8:; String.insert("FTilt")
        string_0x0F9:; String.insert("FTilt2")
        string_0x0FA:; String.insert("GrenadePull")
        string_0x0FB:; String.insert("GrenadeWait")
        string_0x0FC:; String.insert("GrenadeThrowN")
        string_0x0FD:; String.insert("GrenadeThrowEmpty")
        string_0x0FE:; String.insert("GrenadeThrowF")
        string_0x0FF:; String.insert("GrenadeThrowB")
        string_0x100:; String.insert("GrenadeWalkF")
        string_0x101:; String.insert("GrenadeWalkB")
        string_0x102:; String.insert("GrenadeJumpsquat")
        string_0x103:; String.insert("GrenadeStartAir")
        string_0x104:; String.insert("GrenadeWaitAir")
        string_0x105:; String.insert("GrenadeThrowNAir")
        string_0x106:; String.insert("GrenadeThrowEmptyAir")
        string_0x107:; String.insert("GrenadeThrowFAir")
        string_0x108:; String.insert("GrenadeThrowBAir")
        string_0x109:; String.insert("C4Start")
        string_0x10A:; String.insert("C4SetGround")
        string_0x10B:; String.insert("C4SetWall")
        string_0x10C:; String.insert("C4SetEnemy")
        string_0x10D:; String.insert("C4Detonate")
        string_0x10E:; String.insert("C4StartAir")
        string_0x10F:; String.insert("C4SetGroundAir")
        string_0x110:; String.insert("C4SetWallAir")
        string_0x111:; String.insert("C4SetEnemyAir")
        string_0x112:; String.insert("C4DetonateAir")
        string_0x113:; String.insert("NikitaStart")
        string_0x114:; String.insert("NikitaOperation")
        string_0x115:; String.insert("NikitaEnd")
        string_0x116:; String.insert("NikitaSuccess")
        string_0x117:; String.insert("NikitaStartAir")
        string_0x118:; String.insert("NikitaOperationAir")
        string_0x119:; String.insert("NikitaEndAir")
        string_0x11A:; String.insert("NikitaSuccessAir")
        string_0x11B:; String.insert("CypherStart")
        string_0x11C:; String.insert("CypherStartAir")
        string_0x11D:; String.insert("CypherHang")
        string_0x11E:; String.insert("CypherCancel")

        action_string_table:
        dw Action.CAPTAIN.string_0x0DC // Jab 3
        dw 0; dw 0; dw 0; dw 0; dw 0; dw 0;
        dw 0; dw 0; dw 0; dw 0; dw 0; dw 0;
        dw 0; dw 0; dw 0; dw 0; dw 0; dw 0;
        dw Action.string_0x0BF // Jab 2
        dw Action.string_0x0C0 // Dash attack
        dw Action.string_0x01D // CrouchIdle
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
        dw string_0x108
        dw string_0x109
        dw string_0x10A
        dw string_0x10B
        dw string_0x10C
        dw string_0x10D
        dw string_0x10E
        dw string_0x10F
        dw string_0x110
        dw string_0x111
        dw string_0x112
        dw string_0x113
        dw string_0x114
        dw string_0x115
        dw string_0x116
        dw string_0x117
        dw string_0x118
        dw string_0x119
        dw string_0x11A
        dw string_0x11B
        dw string_0x11C
        dw string_0x11D
        dw string_0x11E
        dw Action.string_0x0CF // USmash
        dw Action.string_0x0BD // Taunt
        dw Action.string_0x0BD // Taunt
        dw Action.string_0x0BD // Taunt
        dw Action.string_0x0BD // Taunt
        dw Action.string_0x0BD // Taunt
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.SNAKE, 0x4)
    dw Action.action_string_table
    OS.patch_end()
	
	// Chant FGM
    Character.table_patch_start(crowd_chant_fgm, Character.id.SNAKE, 0x2)
    dh FGM.CHANT
    OS.patch_end()
	
}
