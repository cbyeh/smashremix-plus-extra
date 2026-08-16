include "./KazuyaSpecial.asm"

// This file contains file inclusions, action edits, and assembly for Kazuya.

scope Kazuya {

    insert SPARKLE_, "moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE_)
    insert SHIELDBREAK_, "moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE_)
    insert STUN_, "moveset/STUN.bin"; Moveset.GO_TO(STUN_)

    CUSTOM_THROWF:; Moveset.THROW_DATA(THROWF_DATA); insert "moveset/THROWF.bin"
    CUSTOM_THROWB:; Moveset.THROW_DATA(THROWB_DATA); insert "moveset/THROWB.bin"
    // GRAB_:; Moveset.THROW_DATA(THROWF_DATA); Moveset.GO_TO(GRAB)


	TAUNT:
	Moveset.AFTER(80);
    dw 0xC0000000
	dw 0x58000001
	dw 0

	insert RUN_,"moveset/RUN.bin"; Moveset.GO_TO(RUN_) // loops

    // Modify Action Parameters // Action // Animation // Moveset Data // Flags
    Character.edit_action_parameters(KAZUYA, Action.Entry, File.KAZUYA_ANIM_IDLE, -1, -1)
    Character.edit_action_parameters(KAZUYA, 0x006, File.KAZUYA_ANIM_IDLE, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.Idle, File.KAZUYA_ANIM_IDLE, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.Turn, File.KAZUYA_ANIM_TURN, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.Dash, File.KAZUYA_ANIM_DASH, -1, 0x00000000)
    Character.edit_action_parameters(KAZUYA, Action.Run, File.KAZUYA_ANIM_RUN, RUN_, -1)
    Character.edit_action_parameters(KAZUYA, Action.RunBrake, File.KAZUYA_ANIM_RUNBRAKE, RUNBRAKE, -1)
    Character.edit_action_parameters(KAZUYA, Action.TurnRun, File.KAZUYA_ANIM_TURNRUN, turnRun, -1)
    Character.edit_action_parameters(KAZUYA, Action.Jab1, File.KAZUYA_ANIM_JAB1, JAB1, 0x40000000)
    Character.edit_action_parameters(KAZUYA, Action.Jab2, File.KAZUYA_ANIM_JAB2, JAB2, 0x40000000)
    Character.edit_action_parameters(KAZUYA, 0xDC, File.KAZUYA_ANIM_JAB3, JAB3, 0x40000000)
    Character.edit_action_parameters(KAZUYA, Action.JumpSquat, File.KAZUYA_ANIM_JUMPSQUAT, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.ShieldJumpSquat, File.KAZUYA_ANIM_JUMPSQUAT, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.Fall, File.KAZUYA_ANIM_FALL, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.FallAerial, File.KAZUYA_ANIM_FALLAERIAL, -1, -1)

    Character.edit_action_parameters(KAZUYA, 0xE0, File.KAZUYA_ANIM_ENTRYR, ENTRY, -1)
    Character.edit_action_parameters(KAZUYA, 0xE1, File.KAZUYA_ANIM_ENTRYL, ENTRY, -1)
    Character.edit_action(KAZUYA, 0xE0, -1, 0x8013DA94, 0, 0x8013DB2C, 0x800DE348) // LEFT ENTRY
    Character.edit_action(KAZUYA, 0xE1, -1, 0x8013DA94, 0, 0x8013DB2C, 0x800DE348) // RIGHT ENTRY

    Character.edit_action_parameters(KAZUYA, Action.Taunt, File.KAZUYA_ANIM_TAUNT, TAUNT, -1)

    Character.edit_action_parameters(KAZUYA, Action.Walk1, File.KAZUYA_ANIM_WALK1, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.Walk2, File.KAZUYA_ANIM_WALK2, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.Walk3, File.KAZUYA_ANIM_WALK3, -1, -1)

    Character.edit_action_parameters(KAZUYA, Action.Grab, File.KAZUYA_ANIM_GRAB, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.GrabPull, File.KAZUYA_ANIM_GRABPULL, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.GrabWait, File.KAZUYA_ANIM_GRABPULL, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.ThrowF, File.KAZUYA_ANIM_THROWF, CUSTOM_THROWF, 0x10000000)
    Character.edit_action_parameters(KAZUYA, Action.ThrowB, File.KAZUYA_ANIM_THROWB, CUSTOM_THROWB, 0x50000000)

    Character.edit_action_parameters(KAZUYA, Action.DashAttack, File.KAZUYA_ANIM_DASHATTACK, DASHATTACK, 0x40000000)

    Character.edit_action_parameters(KAZUYA, Action.Crouch, File.KAZUYA_ANIM_CROUCHSTART, EMPTY, -1)
    Character.edit_action_parameters(KAZUYA, Action.CrouchIdle, File.KAZUYA_ANIM_CROUCHWAIT, EMPTY, -1)
    Character.edit_action_parameters(KAZUYA, Action.CrouchEnd, File.KAZUYA_ANIM_CROUCHEND, EMPTY, -1)

    Character.edit_action_parameters(KAZUYA, Action.JumpF, File.KAZUYA_ANIM_JUMPF, JUMP, 0x00000000)
    Character.edit_action_parameters(KAZUYA, Action.JumpB, File.KAZUYA_ANIM_JUMPF, JUMP, 0x00000000)
    Character.edit_action_parameters(KAZUYA, Action.JumpAerialF, File.KAZUYA_ANIM_JUMPB, JUMP_AERIAL, 0x00000000)
    Character.edit_action_parameters(KAZUYA, Action.JumpAerialB, File.KAZUYA_ANIM_JUMPB, JUMP_AERIAL, 0x00000000)

    Character.edit_action_parameters(KAZUYA, Action.UTilt, File.KAZUYA_ANIM_TILTU1, TILTU1, 0x40000000)

    Character.edit_action_parameters(KAZUYA, Action.FTilt, File.KAZUYA_ANIM_TILTF, TILTF, 0x40000000)

    Character.edit_action_parameters(KAZUYA, Action.FTiltLow, File.KAZUYA_ANIM_TSUNAMI1, TSUNAMI1, 0x40000000)
    Character.edit_action_parameters(KAZUYA, Action.FTiltMidLow, 0, 0x80000000, 0x00000000)

    Character.edit_action_parameters(KAZUYA, Action.FTiltHigh, File.KAZUYA_ANIM_RR3KICKS1, RR3KICKS1, 0x40000000)
    Character.edit_action_parameters(KAZUYA, Action.FTiltMidHigh, 0, 0x80000000, 0x00000000)

    Character.edit_action_parameters(KAZUYA, Action.DTilt, File.KAZUYA_ANIM_TILTD, TILTD, 0x40000000)

    Character.edit_action_parameters(KAZUYA, Action.FSmash, File.KAZUYA_ANIM_SMASHF, SMASHF, 0x40000000)
    Character.edit_action_parameters(KAZUYA, Action.FSmashHigh, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(KAZUYA, Action.FSmashLow, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(KAZUYA, Action.DSmash, File.KAZUYA_ANIM_SMASHD, SMASHD, 0x40000000)
    Character.edit_action_parameters(KAZUYA, Action.USmash, File.KAZUYA_ANIM_LEFT_SPLITS, SMASHU, 0x40000000)

    Character.edit_action_parameters(KAZUYA, Action.AttackAirF, File.KAZUYA_ANIM_AIRF, AIRF, -1)
    Character.edit_action_parameters(KAZUYA, Action.AttackAirU, File.KAZUYA_ANIM_AIRU, AIRU, -1)
    Character.edit_action_parameters(KAZUYA, Action.AttackAirN, File.KAZUYA_ANIM_AIRN, AIRN, -1)
    Character.edit_action_parameters(KAZUYA, Action.AttackAirD, File.KAZUYA_ANIM_AIRD, AIRD, -1)
    Character.edit_action_parameters(KAZUYA, Action.AttackAirB, File.KAZUYA_ANIM_AIRB, AIRB, -1)
	
    Character.edit_action_parameters(KAZUYA, Action.ShieldBreak, -1, SHIELDBREAK_, -1)
    Character.edit_action_parameters(KAZUYA, Action.Stun, -1, STUN_, -1)
	
    Character.edit_action_parameters(KAZUYA, Action.Tech, -1, TECH, -1)
    Character.edit_action_parameters(KAZUYA, Action.TechF, -1, TECHROLL, -1)
    Character.edit_action_parameters(KAZUYA, Action.TechB, -1, TECHROLL, -1)
    Character.edit_action_parameters(KAZUYA, Action.CliffAttackQuick2, -1, CLIFFATKQUICK, -1)
    Character.edit_action_parameters(KAZUYA, Action.CliffAttackSlow2, -1, CLIFFATKSLOW, -1)
    Character.edit_action_parameters(KAZUYA, Action.Teeter, -1, -1, -1)

    Character.edit_action_parameters(KAZUYA, Action.DamageHigh1, File.KAZUYA_ANIM_DAMAGEHI1, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.DamageHigh2, File.KAZUYA_ANIM_DAMAGEHI2, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.DamageHigh3, File.KAZUYA_ANIM_DAMAGEHI3, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.DamageMid1, File.KAZUYA_ANIM_DAMAGEMID1, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.DamageMid2, File.KAZUYA_ANIM_DAMAGEMID2, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.DamageMid3, File.KAZUYA_ANIM_DAMAGEMID3, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.DamageLow1, File.KAZUYA_ANIM_DAMAGELW1, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.DamageLow2, File.KAZUYA_ANIM_DAMAGELW2, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.DamageLow3, File.KAZUYA_ANIM_DAMAGELW3, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.DamageFlyHigh, File.KAZUYA_ANIM_DAMAGEFLYHI, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.DamageFlyMid, File.KAZUYA_ANIM_DAMAGEFLYMID, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.DamageFlyLow, File.KAZUYA_ANIM_DAMAGEFLYLW, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.DamageAir1, File.KAZUYA_ANIM_DAMAGEAIR1, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.DamageAir2, File.KAZUYA_ANIM_DAMAGEAIR2, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.DamageAir3, File.KAZUYA_ANIM_DAMAGEAIR3, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.DamageFlyTop, File.KAZUYA_ANIM_DAMAGEFLYTOP, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.DamageFlyRoll, File.KAZUYA_ANIM_DAMAGEFLYROLL, -1, -1)
    Character.edit_action_parameters(KAZUYA, Action.Tumble, File.KAZUYA_ANIM_DAMAGEFALL, -1, -1)

    Character.edit_action_parameters(KAZUYA, 0xE4, File.KAZUYA_ANIM_SPECIALN, NSP, 0x40000000)
    Character.edit_action_parameters(KAZUYA, 0xE5, File.KAZUYA_ANIM_SPECIALN_AIR, NSP_AIR, 0x40000000)
    Character.edit_action_parameters(KAZUYA, 0xE6, File.KAZUYA_ANIM_SPECIALD, DSP, 0x40000000)
    Character.edit_action_parameters(KAZUYA, 0xE9, File.KAZUYA_ANIM_SPECIALD, DSP, 0x40000000) // aerial dsp

    // Modify Actions // Action // Staling ID // Main ASM // Interrupt/Other ASM // Movement/Physics ASM // Collision ASM
    Character.edit_action(KAZUYA, 0xE4, -1, KazuyaSpecial.NSP.main, KazuyaSpecial.NSP.light_to_hard, 0x800D8C14, 0x800DDF44)
    Character.edit_action(KAZUYA, 0xE5, -1, KazuyaSpecial.NSP.main, 0, KazuyaSpecial.NSP_AIR.physics, KazuyaSpecial.NSP_AIR.collision)
    Character.edit_action(KAZUYA, 0xE6, -1, 0x800D94C4, 0, 0x800D8C14, 0x800DDF44)
    Character.edit_action(KAZUYA, 0xE9, -1, 0x800D94E8, 0, 0x800D91EC, KazuyaSpecial.DSP.air_collision)

    // Add Action Parameters // Action Name // Base Action // Animation // Moveset Data // Flags
    Character.add_new_action_params(KAZUYA, WHILE_STAND, -1, File.KAZUYA_ANIM_WHILE_STAND, WHILE_STAND, 0x40000000)
    Character.add_new_action_params(KAZUYA, WAVEDASH, -1, File.KAZUYA_ANIM_WAVEDASH, WAVEDASH, 0x40000000)
    Character.add_new_action_params(KAZUYA, GODFIST, -1, File.KAZUYA_ANIM_GODFIST, GODFIST, 0x40000000)
    Character.add_new_action_params(KAZUYA, CROUCH_JAB, -1, File.KAZUYA_ANIM_CROUCH_JAB, CROUCH_JAB, 0x40000000)
    Character.add_new_action_params(KAZUYA, SWEEP1, -1, File.KAZUYA_ANIM_SWEEP1, SWEEP1, 0x40000000)
    Character.add_new_action_params(KAZUYA, SWEEP2, -1, File.KAZUYA_ANIM_SWEEP2, SWEEP2, 0x40000000)
    Character.add_new_action_params(KAZUYA, TILTU2, -1, File.KAZUYA_ANIM_TILTU2, TILTU2, 0x40000000)
    Character.add_new_action_params(KAZUYA, CROUCH_TILT, -1, File.KAZUYA_ANIM_CROUCH_TILT, CROUCH_TILT, 0x40000000)
    Character.add_new_action_params(KAZUYA, USP, -1, File.KAZUYA_ANIM_USP, USP, 0x00000000)
    Character.add_new_action_params(KAZUYA, USP_LAND, -1, File.KAZUYA_ANIM_USP_LAND, USP_LAND, 0x00000000)
    Character.add_new_action_params(KAZUYA, TSUNAMI2, -1, File.KAZUYA_ANIM_TSUNAMI2, TSUNAMI2, 0x40000000)
    Character.add_new_action_params(KAZUYA, RR3KICKS2, -1, File.KAZUYA_ANIM_RR3KICKS2, RR3KICKS2, 0x40000000)
    Character.add_new_action_params(KAZUYA, RR3KICKS3, -1, File.KAZUYA_ANIM_RR3KICKS3, RR3KICKS3, 0x40000000)
    Character.add_new_action_params(KAZUYA, RR3KICKS4, -1, File.KAZUYA_ANIM_RR3KICKS4, RR3KICKS4, 0x40000000)
    Character.add_new_action_params(KAZUYA, SPECIALN2, -1, File.KAZUYA_ANIM_SPECIALN2, NSP2, 0x40000000)

    Character.add_new_action_params(KAZUYA, JAB1, Action.Jab1, File.KAZUYA_ANIM_JAB1, JAB1, 0x40000000)
    Character.add_new_action_params(KAZUYA, JAB2, Action.Jab2, File.KAZUYA_ANIM_JAB2, JAB2, 0x40000000)
    Character.add_new_action_params(KAZUYA, JAB3, 0xDC, File.KAZUYA_ANIM_JAB3, JAB3, 0x40000000)
    Character.add_new_action_params(KAZUYA, TILTU1, Action.UTilt, File.KAZUYA_ANIM_TILTU1, TILTU1, 0x40000000)
    Character.add_new_action_params(KAZUYA, TSUNAMI1, Action.FTiltLow, File.KAZUYA_ANIM_TSUNAMI1, TSUNAMI1, 0x40000000)
    Character.add_new_action_params(KAZUYA, RR3KICKS1, Action.FTiltHigh, File.KAZUYA_ANIM_RR3KICKS1, RR3KICKS1, 0x40000000)
    Character.add_new_action_params(KAZUYA, SMASHD, Action.DSmash, File.KAZUYA_ANIM_SMASHD, SMASHD, 0x40000000)
    Character.add_new_action_params(KAZUYA, DASH, Action.Dash, File.KAZUYA_ANIM_DASH, dash, 0x40000000)
    Character.add_new_action_params(KAZUYA, TURN, Action.Turn, File.KAZUYA_ANIM_TURN, turn, 0x0)
    Character.add_new_action_params(KAZUYA, DASHBACK, -1, File.KAZUYA_ANIM_DASHB, 0x80000000, 0x00000000)
    Character.add_new_action_params(KAZUYA, CROUCHSTART, Action.Crouch, File.KAZUYA_ANIM_CROUCHSTART, 0x80000000, 0x00000000)
    Character.add_new_action_params(KAZUYA, CROUCHWAIT, Action.CrouchIdle, File.KAZUYA_ANIM_CROUCHWAIT, 0x80000000, 0x00000000)
    Character.add_new_action_params(KAZUYA, CROUCHEND, Action.CrouchEnd, File.KAZUYA_ANIM_CROUCHEND, 0x80000000, 0x00000000)

    // Add Actions // Action Name // Base Action //Parameters // Staling ID // Main ASM // Interrupt/Other ASM // Movement/Physics ASM // Collision ASM
    Character.add_new_action(KAZUYA, WHILE_STAND, -1, ActionParams.WHILE_STAND, -1, 0x800D94C4, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, WAVEDASH, -1, ActionParams.WAVEDASH, -1, KazuyaSpecial.WAVEDASH.main, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, GODFIST, -1, ActionParams.GODFIST, -1, 0x800D94C4, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, CROUCH_JAB, -1, ActionParams.CROUCH_JAB, -1, KazuyaSpecial.CROUCH_JAB.main, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, SWEEP1, -1, ActionParams.SWEEP1, -1, KazuyaSpecial.SWEEP.main, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, SWEEP2, -1, ActionParams.SWEEP2, -1, 0x800D94C4, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, TILTU2, -1, ActionParams.TILTU2, -1, 0x800D94C4, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, CROUCH_TILT, -1, ActionParams.CROUCH_TILT, -1, KazuyaSpecial.CROUCH_JAB.main, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, USP, -1, ActionParams.USP, -1, 0x0, KazuyaUSP.change_direction_, KazuyaSpecial.USP.main, KazuyaSpecial.USP.collision)
    Character.add_new_action(KAZUYA, USP_LAND, -1, ActionParams.USP_LAND, -1, 0x800D94C4, 0, 0x800D8BB4, 0x800DDF44)
    Character.add_new_action(KAZUYA, TSUNAMI2, -1, ActionParams.TSUNAMI2, -1, 0x800D94C4, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, RR3KICKS2, -1, ActionParams.RR3KICKS2, -1, KazuyaSpecial.RR3KICKS.main, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, RR3KICKS3, -1, ActionParams.RR3KICKS3, -1, KazuyaSpecial.RR3KICKS.main, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, RR3KICKS4, -1, ActionParams.RR3KICKS4, -1, 0x800D94C4, 0, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, SPECIALN2, -1, ActionParams.SPECIALN2, -1, KazuyaSpecial.NSP.main, 0, 0x800D8C14, 0x800DDF44)

    Character.add_new_action(KAZUYA, JAB1, Action.Jab1, ActionParams.JAB1, -1, 0x8014E7B0, 0x8014E91C, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, JAB2, Action.Jab2, ActionParams.JAB2, -1, 0x8014E824, 0x8014E9B4, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, JAB3, 0xDC, ActionParams.JAB3, -1, 0x8014E8B4, 0x8014E9E4, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, TILTU1, Action.UTilt, ActionParams.TILTU1, -1, KazuyaSpecial.UTILT.main, -1, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, TSUNAMI1, Action.FTiltLow, ActionParams.TSUNAMI1, -1, KazuyaSpecial.TSUNAMI.main, -1, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, RR3KICKS1, Action.FTiltHigh, ActionParams.RR3KICKS1, -1, KazuyaSpecial.RR3KICKS.main, -1, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, SMASHD, Action.DSmash, ActionParams.SMASHD, -1, KazuyaSpecial.SMASHD.main, -1, 0x800D8C14, 0x800DDF44)
    Character.add_new_action(KAZUYA, DASH, Action.Dash, ActionParams.DASH, -1, KazuyaSpecial.DASH.main, 0x8013EA90, 0x8013EC58, 0x8013ECB0)
    Character.add_new_action(KAZUYA, TURN, Action.Turn, ActionParams.TURN, -1, KazuyaSpecial.TURN.main, 0x8013E700, 0x800D8BB4, 0x800DDEC4)
    Character.add_new_action(KAZUYA, DASHBACK, -1, ActionParams.DASHBACK, -1, KazuyaSpecial.DASHBACK.main, KazuyaSpecial.DASHBACK.interrupt, 0x8013EC58, 0x8013ECB0)
    Character.add_new_action(KAZUYA, CROUCHSTART, Action.Crouch, ActionParams.CROUCHSTART, -1, 0x80142ED8, 0x80142EFC, 0x800D8BB4, 0x800DDEC4)
    Character.add_new_action(KAZUYA, CROUCHWAIT, Action.CrouchIdle, ActionParams.CROUCHWAIT, -1, 0x8014314C, KazuyaSpecial.CROUCHWAIT.interrupt, 0x800D8BB4, 0x800DDEC4)
    Character.add_new_action(KAZUYA, CROUCHEND, Action.CrouchEnd, ActionParams.CROUCHEND, -1, 0x800D94C4, KazuyaSpecial.CROUCHEND.interrupt, 0x800D8BB4, 0x800DDEC4)

    // Modify Menu Action Parameters // Action // Animation // Moveset Data // Flags
    Character.edit_menu_action_parameters(KAZUYA, 0x0, File.KAZUYA_ANIM_IDLE, -1, -1)
    Character.edit_menu_action_parameters(KAZUYA, 0x1, File.KAZUYA_ANIM_WIN1, EMPTY, -1)
    Character.edit_menu_action_parameters(KAZUYA, 0x2, File.KAZUYA_ANIM_WIN1, EMPTY, -1)
    Character.edit_menu_action_parameters(KAZUYA, 0x3, File.KAZUYA_ANIM_WIN1, EMPTY, -1)
    Character.edit_menu_action_parameters(KAZUYA, 0x4, File.KAZUYA_ANIM_WIN1, EMPTY, -1)
    Character.edit_menu_action_parameters(KAZUYA, 0xD, File.KAZUYA_ANIM_ONEPOSE, ONEPOSE, -1)

    // Action replacement map
    scope action_replace_map_: {
        dh Action.Jab1; dh Kazuya.Action.JAB1;
        dh Action.Jab2; dh Kazuya.Action.JAB2;
        dh 0xDC; dh Kazuya.Action.JAB3;
        dh Action.UTilt; dh Kazuya.Action.TILTU1;
        dh Action.FTiltLow; dh Kazuya.Action.TSUNAMI1;
        dh Action.FTiltHigh; dh Kazuya.Action.RR3KICKS1;
        dh Action.DSmash; dh Kazuya.Action.SMASHD;
        dh Action.Dash; dh Kazuya.Action.DASH;
        dh Action.Turn; dh Kazuya.Action.TURN;
        dh Action.Crouch; dh Kazuya.Action.CROUCHSTART;
        dh Action.CrouchIdle; dh Kazuya.Action.CROUCHWAIT;
        dh Action.CrouchEnd; dh Kazuya.Action.CROUCHEND;
        dw 0xFFFFFFFF // end of map
    }

    // Set action replacement table
    Character.table_patch_start(action_replace_map, Character.id.KAZUYA, 0x4)
    dw action_replace_map_
    OS.patch_end()

    scope grounded_script_: {
        j Character.grounded_script.DISABLED // back to original routine
        nop
    }
    Character.table_patch_start(grounded_script, Character.id.KAZUYA, 0x4)
    dw grounded_script_
    OS.patch_end()

    scope initial_script_: {
        j 0x800D7F0C // back to original routine
        nop
    }
    Character.table_patch_start(initial_script, Character.id.KAZUYA, 0x4)
    dw initial_script_
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.KAZUYA, 0x4)
    float32 1
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.KAZUYA, 0x4)
    dw 0x8013DD68 // skips entry script
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.KAZUYA, 0x2)
    dh 0x02EA
    OS.patch_end()

    // Disable rapid jab
    Character.table_patch_start(rapid_jab, Character.id.KAZUYA, 0x4)
    dw Character.rapid_jab.DISABLED // disable rapid jab
    OS.patch_end()

    Character.table_patch_start(air_usp, Character.id.KAZUYA, 0x4)
    dw KazuyaUSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(ground_usp, Character.id.KAZUYA, 0x4)
    dw KazuyaUSP.ground_initial_
    OS.patch_end()

    // Set Kirby star damage
    Character.table_patch_start(kirby_inhale_struct, 0x8, Character.id.KAZUYA, 0xC)
    dw Character.kirby_inhale_struct.star_damage.DK
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.KAZUYA, 0xC)
    dh 0x11
    OS.patch_end()

    // @ Description
    // Ryu's extra actions
    scope Action {
        //constant Jab3(0x0DC)
        //constant JabLoopStart(0x0DD)
        //constant JabLoop(0x0DE)
        //constant JabLoopEnd(0x0DF)
        // constant AppearLeft1(0x0E0)
        constant Blaster(0x0E4)
        constant BlasterAir(0x0E5)
        // constant AppearRight2(0x0E3)
        constant Hadouken(0x0E4)
        constant HadoukenAir(0x0E5)
        constant WarlockKick(0x0E6)
        constant WarlockKickFromGroundAir(0x0E7)
        constant LandingWarlockKick(0x0E8)
        constant WarlockKickEnd(0x0E9)
        constant CollisionWarlockKick(0x0EA)
        constant WarlockDive(0x0EB)
        constant WarlockDiveCatch(0x0EC)
        constant WarlockDiveEnd1(0x0ED)
        constant WarlockDiveEnd2(0x0EE)

        // strings!
        //string_0x0DC:; String.insert("Jab3")
        //string_0x0DD:; String.insert("JabLoopStart")
        //string_0x0DE:; String.insert("JabLoop")
        //string_0x0DF:; String.insert("JabLoopEnd")
        // string_0x0E0:; String.insert("AppearLeft1")
        // string_0x0E1:; String.insert("AppearRight1")
        // string_0x0E2:; String.insert("AppearLeft1")
        // string_0x0E3:; String.insert("AppearRight2")
        string_0x0E4:; String.insert("---")
        string_0x0E5:; String.insert("---")
        string_0x0E6:; String.insert("---")
        string_0x0E7:; String.insert("---")
        string_0x0E8:; String.insert("LightningUppercut")
        string_0x0E9:; String.insert("LightningUppercutAir")
        string_0x0EA:; String.insert("StoneHead")
        string_0x0EB:; String.insert("---")
        string_0x0EC:; String.insert("---")
        string_0x0ED:; String.insert("StoneHeadAir")
        string_0x0EE:; String.insert("---")

        string_0x0F3:; String.insert("DemonGodFist")
        string_0x0F4:; String.insert("CrouchDash")
        string_0x0F5:; String.insert("WindGodFist")
        string_0x0F6:; String.insert("CrouchJab")
        string_0x0F7:; String.insert("SpinningDemon")
        string_0x0F8:; String.insert("SpinningDemon2")
        string_0x0F9:; String.insert("TwinPistons2")
        string_0x0FA:; String.insert("CrouchTilt")
        string_0x0FB:; String.insert("HopbackPunch")
        string_0x0FC:; String.insert("HopbackPunchLand")
        string_0x0FD:; String.insert("TsunamiKick2")
        string_0x0FE:; String.insert("RoundhouseToTripleSpinKick2")
        string_0x0FF:; String.insert("RoundhouseToTripleSpinKick3")
        string_0x100:; String.insert("RoundhouseToTripleSpinKick4")
        string_0x101:; String.insert("LightningScrewUppercut")
        string_0x102:; String.insert("---")
        string_0x103:; String.insert("---")
        string_0x104:; String.insert("---")
        string_0x105:; String.insert("---")
        string_0x106:; String.insert("---")
        string_0x107:; String.insert("---")
        string_0x108:; String.insert("---")
        string_0x109:; String.insert("---")
        string_0x10A:; String.insert("---")
        string_0x10B:; String.insert("DashBack")

        action_string_table:
        dw Action.COMMON.string_jab3
        dw 0
        dw 0
        dw 0
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

        dw 0
        dw 0
        dw 0
        dw 0
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
        dw string_0x108
        dw string_0x109
        dw string_0x10A
        dw string_0x10B
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.KAZUYA, 0x4)
    dw Action.action_string_table
    OS.patch_end()

    KAZUYA_WAVEDASH:
    // reset stick
    AI.UNPRESS_Z()
    AI.UNPRESS_A(0)
    AI.UNPRESS_B(0)
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    // dash forward
    AI.STICK_X(0x7F, 1) // dash towards opponent for 1f
    AI.CUSTOM(4); // wait for turnaround to finish if needed
    // stick down
    AI.STICK_X(0)
    AI.STICK_Y(-0x7F, 1) // stick down for 1f
    // wavedash (down + forward)
    AI.STICK_Y(-0x7F) // full down
    AI.STICK_X(0x7F, 1) // autofull towards opponent
    AI.STICK_X(0)
    AI.STICK_Y(0, 9)
    // dash forward
    AI.STICK_X(0x7F, 1) // dash towards opponent for 1f
    AI.STICK_X(0)
    AI.STICK_Y(0)
    AI.END(); // End routine
    AI.add_cpu_input_routine(KAZUYA_WAVEDASH)

    WAVEDASH_B:
    // reset stick
    AI.UNPRESS_Z()
    AI.UNPRESS_A(0)
    AI.UNPRESS_B(0)
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    // dash forward
    AI.STICK_X(0x7F, 1) // dash towards opponent for 1f
    AI.CUSTOM(4); // wait for turnaround to finish if needed
    // stick down
    AI.STICK_X(0)
    AI.STICK_Y(-0x7F, 1) // stick down for 1f
    // wavedash (down + forward)
    AI.STICK_Y(-0x7F) // full down
    AI.STICK_X(0x7F, 1) // autofull towards opponent
    AI.STICK_X(0)
    AI.STICK_Y(0, 9)
    AI.PRESS_B(9)
    AI.UNPRESS_B(9)
    AI.PRESS_B(9)
    AI.UNPRESS_B(9)
    AI.PRESS_B(9)
    AI.UNPRESS_B(0)
    AI.STICK_Y(0, 0)
    AI.END(); // End routine
    AI.add_cpu_input_routine(WAVEDASH_B)

    WAVEDASH_ELECTRIC:
    // reset stick
    AI.UNPRESS_Z()
    AI.UNPRESS_A(0)
    AI.UNPRESS_B(0)
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    // dash forward
    AI.STICK_X(0x7F, 1) // dash towards opponent for 1f
    AI.CUSTOM(4); // wait for turnaround to finish if needed
    // stick down
    AI.STICK_X(0)
    AI.STICK_Y(-0x7F, 1) // stick down for 1f
    // wavedash (down + forward)
    AI.STICK_Y(-0x7F) // full down
    AI.STICK_X(0x7F, 1) // autofull towards opponent
    AI.PRESS_A(1)
    AI.UNPRESS_A(0)
    AI.STICK_X(0)
    AI.STICK_Y(0)
    AI.END(); // End routine
    AI.add_cpu_input_routine(WAVEDASH_ELECTRIC)

    WAVEDASH_4_ELECTRIC:
    // reset stick
    AI.UNPRESS_Z()
    AI.UNPRESS_A(0)
    AI.UNPRESS_B(0)
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    // dash forward
    AI.STICK_X(0x7F, 1) // dash towards opponent for 1f
    AI.CUSTOM(4); // wait for turnaround to finish if needed
    // stick down
    AI.STICK_X(0)
    AI.STICK_Y(-0x7F, 1) // stick down for 1f
    // wavedash (down + forward)
    AI.STICK_Y(-0x7F) // full down
    AI.STICK_X(0x7F, 5) // autofull towards opponent, wait 5f
    AI.PRESS_A(1)
    AI.UNPRESS_A(0)
    AI.STICK_X(0)
    AI.STICK_Y(0)
    AI.END(); // End routine
    AI.add_cpu_input_routine(WAVEDASH_4_ELECTRIC)

    WAVEDASH_8_ELECTRIC:
    // reset stick
    AI.UNPRESS_Z()
    AI.UNPRESS_A(0)
    AI.UNPRESS_B(0)
    AI.STICK_X(0)
    AI.STICK_Y(0, 1)
    // dash forward
    AI.STICK_X(0x7F, 1) // dash towards opponent for 1f
    AI.CUSTOM(4); // wait for turnaround to finish if needed
    // stick down
    AI.STICK_X(0)
    AI.STICK_Y(-0x7F, 1) // stick down for 1f
    // wavedash (down + forward)
    AI.STICK_Y(-0x7F) // full down
    AI.STICK_X(0x7F, 9) // autofull towards opponent
    AI.PRESS_A(1)
    AI.UNPRESS_A(0)
    AI.STICK_X(0)
    AI.STICK_Y(0)
    AI.END(); // End routine
    AI.add_cpu_input_routine(WAVEDASH_8_ELECTRIC)

    TRIPLE_SPIN_KICKS:
    AI.UNPRESS_Z()
    AI.STICK_X(0, 0)
    AI.STICK_Y(0x28, 0)
    dh 0xA080 // stick x = tilt to opponent
    AI.PRESS_A(8)
    AI.UNPRESS_A(8)
    AI.PRESS_A(8)
    AI.UNPRESS_A(8)
    AI.PRESS_A(8)
    AI.UNPRESS_A(8)
    AI.PRESS_A(8)
    AI.UNPRESS_A(8)
    AI.PRESS_A(8)
    AI.UNPRESS_A(8)
    AI.PRESS_A(8)
    AI.UNPRESS_A(0)
    AI.END()
    AI.add_cpu_input_routine(TRIPLE_SPIN_KICKS)

    DTILT_F:
    AI.UNPRESS_Z()
    AI.STICK_X(0, 0)
    AI.STICK_Y(-0x28, 0)
    dh 0xA080 // stick x = tilt to opponent
    AI.PRESS_A(9)
    AI.UNPRESS_A(9)
    AI.PRESS_A(9)
    AI.UNPRESS_A(0)
    AI.END()
    AI.add_cpu_input_routine(DTILT_F)

    CPU_ATTACKS:
    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.add_attack_behaviour(JAB, 6, -564, 564, 284, 424)
    AI.add_attack_behaviour(GRAB, 6, 279, 429, 227, 377)
    AI.add_attack_behaviour(UTILT, 9, -391, 391, 303, 664)
    AI.add_custom_attack_behaviour(AI.ROUTINE.WAVEDASH_B, 3+1+12, 122+50, 540+50, 104, 264)
    AI.add_custom_attack_behaviour(AI.ROUTINE.DTILT_F, 10, 211, 555, 196, 632)
    AI.add_attack_behaviour(FSMASH, 11, 407, 766, 328, 537)
    AI.add_attack_behaviour(USMASH, 13, -529, 529, 192, 586)
    AI.add_attack_behaviour(DTILT, 12, -638, 638, 105, 349)
    AI.add_attack_behaviour(FTILT, 12, 149, 640, 309, 533)
    AI.add_custom_attack_behaviour(AI.ROUTINE.WAVEDASH_ELECTRIC, 3+1+8, 93+50, 383+50, 312, 707)
    AI.add_custom_attack_behaviour(AI.ROUTINE.WAVEDASH_4_ELECTRIC, 3+4+8, 93+200, 383+200, 312, 707)
    AI.add_custom_attack_behaviour(AI.ROUTINE.WAVEDASH_8_ELECTRIC, 3+8+8, 93+400, 383+400, 312, 707)
    AI.add_custom_attack_behaviour(AI.ROUTINE.TRIPLE_SPIN_KICKS, 14, 232, 689, 298, 438)
    AI.add_attack_behaviour(DSMASH, 17, 606, 1118, -16, 772)
    AI.add_attack_behaviour(DSPG, 17, 329, 479, 219, 369)
    AI.add_attack_behaviour(NSPG, 26, 761, 1021, 362, 890)
    AI.add_custom_attack_behaviour(AI.ROUTINE.DASH_ATTACK, 16, 697, 1321, 315, 642)

    AI.END_ATTACKS() // end of grounded attacks
    
    AI.add_attack_behaviour(UAIR, 4, 29, 393, 266, 710)
    AI.add_attack_behaviour(NAIR, 6, 169, 365, 294, 416)
    AI.add_attack_behaviour(DAIR, 8, 105, 318, 81, 301)
    AI.add_custom_attack_behaviour(AI.ROUTINE.FAIR, 8, 114, 449, 249, 431)
    AI.add_custom_attack_behaviour(AI.ROUTINE.BAIR, 11, -420, -43, 271, 481)
    AI.add_attack_behaviour(DSPA, 17, 72, 222, 219, 369)
    AI.add_attack_behaviour(NSPA, 26, 92, 388, 380, 827)
    
    AI.END_ATTACKS() // end of aerial attacks
    OS.align(16)

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.KAZUYA, 0x4)
    dw CPU_ATTACKS
    OS.patch_end()

    // Set CPU NSP long range behaviour
    Character.table_patch_start(ai_long_range, Character.id.KAZUYA, 0x4)
    dw AI.LONG_RANGE.ROUTINE.NSP_SHOOT
    OS.patch_end()

    // Custom custom long range action input
    Character.table_patch_start(nsp_shoot_custom_move, Character.id.KAZUYA, 0x4)
    dw AI.ROUTINE.KAZUYA_WAVEDASH
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.KAZUYA, 0, 2, 5, 4, 1, 2, 3)
    Teams.add_team_costume(YELLOW, KAZUYA, 0x4)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(KAZUYA, WHITE, RED, BLUE, GREEN, YELLOW, BLACK, NA, NA)

    scope CloakingFix: {
        scope fix_: {
            // s8 = player struct
            // v0 = first custom part struct (left upper pant)
            addiu   sp, sp, -0x0010             // allocate stack space
            sw      t1, 0x0004(sp)              // save return address

            _fix_kaz_1:
            li      t1, _fix_kaz_2              // t1 is the address to return to
            j       CharEnvColor.override_env_color_._fix
            nop

            _fix_kaz_2:
            li      v0, CharEnvColor.custom_display_lists_struct_kazuya_pant_left_lower
            li      t1, _fix_kaz_3              // t1 is the address to return to
            j       CharEnvColor.override_env_color_._fix
            nop

            _fix_kaz_3:
            li      v0, CharEnvColor.custom_display_lists_struct_kazuya_pant_right_upper
            li      t1, _fix_kaz_4              // t1 is the address to return to
            j       CharEnvColor.override_env_color_._fix
            nop

            _fix_kaz_4:
            li      v0, CharEnvColor.custom_display_lists_struct_kazuya_pant_right_lower
            lw      t1, 0x0004(sp)              // t1 = return address
            j       CharEnvColor.override_env_color_._fix
            addiu   sp, sp, 0x0010              // allocate stack space
        }
    }
}
