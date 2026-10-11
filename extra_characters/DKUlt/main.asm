include "./DKUltSpecial.asm"

scope DKUlt {
    insert dspLoop_,"moveset/dspLoop.bin"; Moveset.GO_TO(dspLoop_) // loops

    // Modify Action Parameters: Action, Animation, Moveset Data, Flags
    Character.edit_action_parameters(DKULT, Action.Idle, File.DKULT_ANIM_IDLE, -1, -1)

    Character.edit_action_parameters(DKULT, Action.Taunt, -1, taunt, -1)

    Character.edit_action_parameters(DKULT, Action.Fall, File.DKULT_ANIM_FALL, -1, -1)
    Character.edit_action_parameters(DKULT, Action.FallAerial, File.DKULT_ANIM_FALLAERIAL, -1, -1)

    Character.edit_action_parameters(DKULT, Action.Jab1, File.DKULT_ANIM_JAB1, jab1, -1)
    Character.edit_action_parameters(DKULT, Action.Jab2, File.DKULT_ANIM_JAB2, jab2, -1)

    Character.edit_action_parameters(DKULT, Action.AttackAirN, File.DKULT_ANIM_AIRN, airN, -1)
    Character.edit_action_parameters(DKULT, Action.AttackAirF, File.DKULT_ANIM_AIRF, airF, -1)
    Character.edit_action_parameters(DKULT, Action.AttackAirB, File.DKULT_ANIM_AIRB, airB, -1)
    Character.edit_action_parameters(DKULT, Action.AttackAirU, File.DKULT_ANIM_AIRU, airU, -1)
    Character.edit_action_parameters(DKULT, Action.AttackAirD, File.DKULT_ANIM_AIRD, airD, -1)

    Character.edit_action_parameters(DKULT, Action.DashAttack, File.DKULT_ANIM_DASHATTACK, dashAttack, -1)

    Character.edit_action_parameters(DKULT, Action.DTilt, File.DKULT_ANIM_TILTD, tiltD, -1)
    Character.edit_action_parameters(DKULT, Action.FTilt, File.DKULT_ANIM_TILTF, tiltF, -1)
    Character.edit_action_parameters(DKULT, Action.FTiltHigh, File.DKULT_ANIM_TILTFHI, tiltFHiLw, -1)
    Character.edit_action_parameters(DKULT, Action.FTiltLow, File.DKULT_ANIM_TILTFLW, tiltFHiLw, -1)
    Character.edit_action_parameters(DKULT, Action.UTilt, File.DKULT_ANIM_TILTU, tiltU, -1)

    Character.edit_action_parameters(DKULT, Action.FSmashHigh, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(DKULT, Action.FSmashMidHigh, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(DKULT, Action.FSmash, File.DKULT_ANIM_SMASHF, smashF, 0x40000000)
    Character.edit_action_parameters(DKULT, Action.FSmashMidLow, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(DKULT, Action.FSmashLow, 0, 0x80000000, 0x00000000)
    Character.edit_action_parameters(DKULT, Action.USmash, File.DKULT_ANIM_SMASHU, smashU, -1)
    Character.edit_action_parameters(DKULT, Action.DSmash, File.DKULT_ANIM_SMASHD, smashD, -1)

    Character.edit_action_parameters(DKULT, Action.DashAttack, File.DKULT_ANIM_DASHATTACK, -1, -1)

    Character.edit_action_parameters(DKULT, Action.DK.SpinningKong, File.DKULT_ANIM_USP, usp, -1)
    Character.edit_action_parameters(DKULT, Action.DK.SpinningKongAir, File.DKULT_ANIM_USPAIR, uspAir, -1)

    Character.edit_action_parameters(DKULT, Action.DK.GiantPunchLoopStart, File.DKULT_ANIM_NSPSTART, -1, -1)
    Character.edit_action_parameters(DKULT, Action.DK.GiantPunchLoop, File.DKULT_ANIM_NSPCHARGE, -1, -1)
    Character.edit_action_parameters(DKULT, Action.DK.GiantPunch, File.DKULT_ANIM_NSP, nsp, -1)
    Character.edit_action_parameters(DKULT, Action.DK.GiantPunchFullyCharged, File.DKULT_ANIM_NSP, nspMax, -1)
    Character.edit_action_parameters(DKULT, Action.DK.GiantPunchLoopStartAir, File.DKULT_ANIM_NSPAIRSTART, -1, -1)
    Character.edit_action_parameters(DKULT, Action.DK.GiantPunchLoopAir, File.DKULT_ANIM_NSPAIRCHARGE, -1, -1)
    Character.edit_action_parameters(DKULT, Action.DK.GiantPunchAir, File.DKULT_ANIM_NSPAIR, nspAir, -1)
    Character.edit_action_parameters(DKULT, Action.DK.GiantPunchFullyChargedAir, File.DKULT_ANIM_NSPAIR, nspAirMax, -1)

    Character.edit_action(DKULT, Action.DK.GiantPunchLoopStart, -1, DKUltSpecial.NSP_START.update, -1, -1, -1)
    Character.edit_action(DKULT, Action.DK.GiantPunchLoopStartAir, -1, DKUltSpecial.NSP_START.update_air, -1, -1, -1)

    Character.edit_action(DKULT, Action.DK.GiantPunchLoop, -1, DKUltSpecial.NSP_LOOP.update, -1, -1, -1)
    Character.edit_action(DKULT, Action.DK.GiantPunchLoopAir, -1, DKUltSpecial.NSP_LOOP.update, -1, -1, -1)

    Character.edit_action_parameters(DKULT, Action.DK.HandSlapStart, File.DKULT_ANIM_DSPSTART, dspStart, -1)
    Character.edit_action_parameters(DKULT, Action.DK.HandSlapLoop, File.DKULT_ANIM_DSPLOOP, dspLoop_, -1)
    Character.edit_action_parameters(DKULT, Action.DK.HandSlapEnd, File.DKULT_ANIM_DSPEND, dspEnd, -1)

    Character.edit_action(DKULT, Action.DK.SpinningKong, -1, -1, -1, DKUltSpecial.USP.physics, 0x800DDF44)

    Character.add_new_action_params(DKULT, DSP_AIR, -1, File.DKULT_ANIM_DSPAIR, dspAir, 0x0)
    Character.add_new_action(DKULT, DSP_AIR, -1, ActionParams.DSP_AIR, -1, 0x800D94E8, 0, 0x800D90E0, 0x800DE99C)

    Character.table_patch_start(air_dsp, Character.id.DKULT, 0x4)
    dw DKUltSpecial.DSP_AIR.initial
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.DKULT, 0x2)
    dh 0x25B
    OS.patch_end()

    // Modify Actions            // Action              // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM

    // Set default costumes
    Character.set_default_costumes(Character.id.DKULT, 0, 1, 2, 3, 2, 3, 4)
    Teams.add_team_costume(YELLOW, DKULT, 0x1)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(DKULT, BROWN, BLACK, RED, BLUE, GREEN, PINK, WHITE, YELLOW)
}
