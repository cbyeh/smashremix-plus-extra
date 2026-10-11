include "./RebeccaSpecial.asm"

scope Rebecca {
    // insert _IDLE,"moveset/IDLE.bin"; Moveset.GO_TO(_IDLE) // loops

    insert SPARKLE_, "moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE_)
    insert SHIELD_BREAK_, "moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE_)
    insert STUN_, "moveset/STUN.bin"; Moveset.GO_TO(STUN_) // loops
    insert SLEEP_, "moveset/SLEEP.bin"; Moveset.GO_TO(SLEEP_) // loops

    GRAB_:;    Moveset.THROW_DATA(GRAB_RELEASE_DATA); Moveset.GO_TO(GRAB)
    THROW_F_:; Moveset.THROW_DATA(THROW_F_DATA); Moveset.GO_TO(THROW_F)
    THROW_B_:;  Moveset.THROW_DATA(THROW_B_DATA); Moveset.GO_TO(THROW_B)

    // @ Description
    // Rebecca's extra actions
    scope Action {
        constant JabLoopStart(0x0DC)
        constant JabLoop(0x0DD)
        constant JabLoopEnd(0x0DE)
        constant Appear1(0x0DF)
        constant Appear2(0x0E0)
        constant Gun(0x0E1)
        constant GunAir(0x0E2)
        constant PistolWhipStartAir(0x0E3)
        constant PistolWhipStart(0x0E4)
        constant ReadyingFireFox(0x0E5)
        constant PistolWhip(0x0E6)
        constant FireFox(0x0E7)
        constant PistolWhipAir(0x0E8)
        constant FireFoxEnd(0x0E9)
        constant FireFoxEndAir(0x0EA)
        constant LandingFireFoxAir(0x0EB)
        constant ReflectorStart(0x0EC)
        constant Reflecting(0x0ED)
        constant ReflectorEnd(0x0EE)
        constant ReflectorLoop(0x0EF)
        constant ReflectorTurn(0x0F0)
        constant ReflectorStartAir(0x0F1)
        constant ReflectingAir(0x0F2)
        constant ReflectorEndAir(0x0F3)
        constant ReflectorAir(0x0F4)
        constant ReflectorTurnAir(0x0F5)

        // strings!
        string_0x0E1:; String.insert("Gun")
        string_0x0E2:; String.insert("GunAir")
        string_0x0E3:; String.insert("PistolWhipStartAir")
        string_0x0E4:; String.insert("PistolWhipStart")
        string_0x0E5:; String.insert("ReadyingFireFox")
        string_0x0E6:; String.insert("PistolWhip")
        string_0x0E7:; String.insert("FireFox")
        string_0x0E8:; String.insert("PistolWhipAir")
        string_0x0E9:; String.insert("FireFoxEnd")
        string_0x0EA:; String.insert("FireFoxEndAir")
        string_0x0EB:; String.insert("FireFoxBounce")
        string_0x0EC:; String.insert("ReflectorStart")
        string_0x0ED:; String.insert("Reflecting")
        string_0x0EE:; String.insert("ReflectorEnd")
        string_0x0EF:; String.insert("ReflectorLoop")
        string_0x0F0:; String.insert("ReflectorTurn")
        string_0x0F1:; String.insert("ReflectorStartAir")
        string_0x0F2:; String.insert("ReflectingAir")
        string_0x0F3:; String.insert("ReflectorEndAir")
        string_0x0F4:; String.insert("ReflectorAir")
        string_0x0F5:; String.insert("ReflectorTurnAir")

        action_string_table:
        dw Action.COMMON.string_jabloopstart
        dw Action.COMMON.string_jabloop
        dw Action.COMMON.string_jabloopend
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
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
        dw 0 //dw string_0x0F2
        dw string_0x0F3
        dw string_0x0F4
        dw string_0x0F5
    }

    // Modify Action Parameters               // Action                     // Animation                            // Moveset Data                     // Flags
    Character.edit_action_parameters(REBECCA, Action.Taunt,                 -1,                                     TAUNT,                              -1)
    Character.edit_action_parameters(REBECCA, Action.JumpAerialF,           -1,                                     JUMP_AIR,                           -1)
    Character.edit_action_parameters(REBECCA, Action.JumpAerialB,           -1,                                     JUMP_AIR,                           -1)
    Character.edit_action_parameters(REBECCA, Action.Tech,                  -1,                                     TECH,                               -1)
    Character.edit_action_parameters(REBECCA, Action.TechF,                 -1,                                     TECH_FB,                            -1)
    Character.edit_action_parameters(REBECCA, Action.TechB,                 -1,                                     TECH_FB,                            -1)
    Character.edit_action_parameters(REBECCA, Action.RollF,                 -1,                                     ROLL_F,                             -1)
    Character.edit_action_parameters(REBECCA, Action.RollB,                 -1,                                     ROLL_B,                             -1)
    Character.edit_action_parameters(REBECCA, Action.Grab,                  -1,                                     GRAB_,                              -1)
    Character.edit_action_parameters(REBECCA, Action.ThrowF,                -1,                                     THROW_F_,                           -1)
    Character.edit_action_parameters(REBECCA, Action.ThrowB,                -1,                                     THROW_B_,                           -1)
    Character.edit_action_parameters(REBECCA, Action.DTilt,                 File.WOLF_DTILT,                        DTILT,                              -1)
    Character.edit_action_parameters(REBECCA, Action.Teeter,                -1,                                     TEETER,                             -1)
    Character.edit_action_parameters(REBECCA, Action.AttackAirU,            File.PEPPY_UAIR,                        UAIR,                               -1)
    Character.edit_action_parameters(REBECCA, Action.AttackAirF,            -1,                                     FAIR,                               -1)

    Character.edit_action_parameters(REBECCA,    Action.FallSpecial,       File.WOLF_FALLSPECIAL,    -1,                       -1)

    Character.edit_action_parameters(REBECCA,  0xE3,                       File.WOLF_USP_1,            USP_1,               			0x00000000)
	Character.edit_action_parameters(REBECCA,  0xE8,                       File.WOLF_USP_2,            USP_2,               			0x00000000)
    Character.edit_action_parameters(REBECCA,  0xE4,                       File.WOLF_USP_1,            USP_1,               			0x00000000)
	Character.edit_action_parameters(REBECCA,  0xE6,                       File.WOLF_USP_2,            USP_2,               			0x00000000)

    Character.edit_action_parameters(REBECCA, Action.ShieldBreak,           -1,                                     SHIELD_BREAK_,                      -1)
    Character.edit_action_parameters(REBECCA, Action.ShieldBreakFall,       -1,                                     SPARKLE_,                           -1)
    Character.edit_action_parameters(REBECCA, Action.Stun,                  -1,                                     STUN_,                              -1)
    Character.edit_action_parameters(REBECCA, Action.Sleep,                 -1,                                     SLEEP_,                             -1)

    Character.edit_action_parameters(REBECCA, Action.Gun,                 -1,                                     LASER,                              -1)
    Character.edit_action_parameters(REBECCA, Action.GunAir,              -1,                                     LASER_AIR,                          -1)

    Character.edit_action_parameters(REBECCA, Action.ReflectorLoop,         -1,                                     DSP_LOOP,                           -1)
    Character.edit_action_parameters(REBECCA, Action.ReflectorTurn,         -1,                                     DSP_LOOP,                           -1)
    Character.edit_action_parameters(REBECCA, Action.ReflectorAir,          -1,                                     DSP_LOOP,                           -1)
    Character.edit_action_parameters(REBECCA, Action.ReflectorTurnAir,      -1,                                     DSP_LOOP,                           -1)

    // Modify Actions                   // Action           // Staling ID   // Main ASM                 // Interrupt/Other ASM              // Movement/Physics ASM     // Collision ASM
    Character.edit_action(REBECCA,      Action.Gun,       0x12,           RebeccaNSP.main_,           0x8015BBD8,                         0x800D8BB4,                 0x800DDF44) // Gun
    Character.edit_action(REBECCA,      Action.GunAir,    0x12,           RebeccaNSP.main_,           0x8015BBD8,                         0x800D90E0,                 0x800DE934) // Gun (Air)
    Character.edit_action(REBECCA,  0xE4,              -1,             RebeccaUSP.main_air,           RebeccaUSP.change_direction_,      RebeccaUSP.physics_,              RebeccaUSP.collision_)
	Character.edit_action(REBECCA,  0xE3,              -1,             RebeccaUSP.main_ground,        RebeccaUSP.change_direction_,      RebeccaUSP.physics_,              RebeccaUSP.collision_)
	Character.edit_action(REBECCA,  0xE6,              -1,             RebeccaUSP.main_2,             RebeccaUSP.change_direction_,      RebeccaUSP.physics_,              RebeccaUSP.collision_)
	Character.edit_action(REBECCA,  0xE8,              -1,             RebeccaUSP.main_2,             RebeccaUSP.change_direction_,      RebeccaUSP.physics_,              RebeccaUSP.collision_)


    // Character.edit_action_parameters(REBECCA, Action.Idle,                  File.REBECCA_ANIM_IDLE,                 _IDLE,                              -1)
    // Character.edit_action_parameters(REBECCA, Action.Entry,                 File.REBECCA_ANIM_IDLE,                 _IDLE,                              -1)
    // Character.edit_action_parameters(REBECCA, Action.ReviveWait,            File.REBECCA_ANIM_IDLE,                 _IDLE,                              -1)
    // Character.edit_action_parameters(REBECCA, 0x06,                         File.REBECCA_ANIM_IDLE,                 _IDLE,                              -1)

    // Modify Menu Action Parameters               // Action    // Animation                        // Moveset Data         // Flags
    // Character.edit_menu_action_parameters(REBECCA, 0x0,         File.REBECCA_ANIM_IDLE,             _IDLE,                  -1)
    Character.edit_menu_action_parameters(REBECCA, 0x1,         -1,                                 VICTORY1,               -1)
    Character.edit_menu_action_parameters(REBECCA, 0x2,         -1,                                 VICTORY2,               -1)
    Character.edit_menu_action_parameters(REBECCA, 0x3,         -1,                                 VICTORY3,               -1)
    Character.edit_menu_action_parameters(REBECCA, 0x4,         -1,                                 SELECTED,               -1)
    Character.edit_menu_action_parameters(REBECCA, 0x5,         -1,                                 0,                      -1) // Clap
    // Character.edit_menu_action_parameters(REBECCA, 0x9,         File.REBECCA_ANIM_PUPPET_FALL,      -1,                     -1)
    // Character.edit_menu_action_parameters(REBECCA, 0xA,         File.REBECCA_ANIM_PUPPET_REVIVE,    -1,                     -1)
    // Character.edit_menu_action_parameters(REBECCA, 0xD,         File.REBECCA_ANIM_1P_POSE,          SPPOSE,                 -1)
    // Character.edit_menu_action_parameters(REBECCA, 0xE,         File.REBECCA_ANIM_1P_CPU_POSE,      CPU_POSE,               -1)

    // Set crowd chant FGM.
    // Character.table_patch_start(crowd_chant_fgm, Character.id.REBECCA, 0x2)
    // dh FGM.CHANT
    // OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.REBECCA, 0x4)
    dw Action.action_string_table
    OS.patch_end()

    // Set entry script
    Character.table_patch_start(entry_script, Character.id.REBECCA, 0x4)
    dw 0x8013DD68   // skips entry script
    OS.patch_end()

    Character.table_patch_start(air_usp, Character.id.REBECCA, 0x4)
    dw      RebeccaUSP.initial_air
    OS.patch_end()
	Character.table_patch_start(ground_usp, Character.id.REBECCA, 0x4)
    dw      RebeccaUSP.initial_ground
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.REBECCA, 0, 4, 1, 2, 0, 1, 2)
    Teams.add_team_costume(YELLOW, REBECCA, 0x4)

    // Set default costume shield colors
    Character.set_costume_shield_colors(REBECCA, RED, BLUE, GREEN, BLACK, YELLOW, NA, NA, NA)

    // Reflector structs and routines
    OS.align(16)
    reflect_graphic_struct:
    dw  0x060F0000
    dw  Character.REBECCA_file_7_ptr
    OS.copy_segment(0xA98F4, 0x8)
    dw  reflector_graphic_routine
    dw  0x80014038
    dw  0x000002B0
    dw  0x00000000
    dw  0x00000340
    dw  0x00000000

    reflector_graphic_routine:
    OS.copy_segment(0x7C6D0, 0x70)
    jal     reflector_graphic_subroutine
    sw      a2, 0x0024(sp)
    OS.copy_segment(0x7C748, 0x34)
    jal     reflector_graphic_subroutine
    sw      a2, 0x0024(sp)
    OS.copy_segment(0x7C784, 0x20)

    reflector_graphic_subroutine:
    OS.copy_segment(0x7C684, 0x10)
    sw      a1, 0x0018(v0)
    li      t7, reflector_struct
    addu    t7, t7, t6
    lw      t7, 0x0000(t7)
    li      t8, Character.REBECCA_file_7_ptr
    lw      t8, 0x0000(t8)
    OS.copy_segment(0x7C6AC, 0x28)

    reflector_struct:
    dw  0x00000320
    dw  0x000004C0
    dw  0x000003A0
    dw  0x00000430

    DSP_GFX:
    dw 0x3C001FB0;
    GFXRoutine.OVERLAY(0xFF000050);
    GFXRoutine.WAIT(1);
    GFXRoutine.CLEAR_OVERLAY();
    GFXRoutine.WAIT(1);
    GFXRoutine.OVERLAY(0x00000030);
    GFXRoutine.WAIT(1);
    GFXRoutine.GO_TO(DSP_GFX);
}