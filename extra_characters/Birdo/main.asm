// Birdo.asm

// This file contains file inclusions, action edits, and assembly for Birdo.

include "./BirdoSpecial.asm"

scope Birdo {

    insert SPARKLE_, "moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE_)
    insert SHIELDBREAK_, "moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE_)
    insert STUN_, "moveset/STUN.bin"; Moveset.GO_TO(STUN_)
    insert SLEEP_, "moveset/SLEEP.bin"; Moveset.GO_TO(SLEEP_)
    Grab_:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    THROWF_:; Moveset.THROW_DATA(THROWF_DATA); insert "moveset/THROWF.bin"
    THROWB_:; Moveset.THROW_DATA(THROWB_DATA); insert "moveset/THROWB.bin"

    // @ Description
    // Birdo's extra actions
    scope Action: {
        constant Appear1(0x0DC)
        constant Appear2(0x0DD)
        constant POWBlockGround(0x0E0)
        constant POWBlockLand(0x0E1)
        constant POWBlockAir(0x0E2)
        constant POWBlockDrop(0x0E3)
        constant EggShoot(0x0E4)
        constant EggShootAir(0x0E7)
        constant TennisServeStart(0x0EA)
        constant TennisServeEnd(0x0EB)
        constant TennisServeStartAir(0x0EC)
        constant TennisServeEndAir(0x0ED)

    // strings!
        string_0x0DC:; String.insert("")
        string_0x0DD:; String.insert("")
        string_0x0E0:; String.insert("POWBlockGround")
        string_0x0E1:; String.insert("POWBlockLand")
        string_0x0E2:; String.insert("POWBlockAir")
        string_0x0E3:; String.insert("POWBlockDrop")
        string_0x0E4:; String.insert("EggShoot")
        string_0x0E7:; String.insert("EggShootAir")
        string_0x0EA:; String.insert("TennisServeStart")
        string_0x0EB:; String.insert("TennisServeEnd")
        string_0x0EC:; String.insert("TennisServeStartAir")
        string_0x0ED:; String.insert("TennisServeEndAir")

        action_string_table:
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw 0
        dw 0
        dw string_0x0E0
        dw string_0x0E1
        dw string_0x0E2
        dw string_0x0E3
        dw string_0x0E4
        dw 0
        dw 0
        dw string_0x0E7
        dw 0
        dw 0
        dw string_0x0EA
        dw string_0x0EB
        dw string_0x0EC
        dw string_0x0ED
    }


    // Modify Action Parameters             // Action                 // Animation                // Moveset Data   // Flags

    //BASICS
    Character.edit_action_parameters(BIRDO, Action.Idle,              File.BIRDO_ANIM_IDLE,        -1,               -1)
    Character.edit_action_parameters(BIRDO, Action.ReviveWait,        File.BIRDO_ANIM_IDLE,        -1,               -1)
    Character.edit_action_parameters(BIRDO, Action.JumpF,             -1,                          Jump,             -1)
    Character.edit_action_parameters(BIRDO, Action.JumpB,             -1,                          Jump,             -1)
    Character.edit_action_parameters(BIRDO, Action.JumpAerialF,       File.BIRDO_ANIM_JUMPAERIAL,  JumpAerial,       -1)
    Character.edit_action_parameters(BIRDO, Action.JumpAerialB,       File.BIRDO_ANIM_JUMPAERIAL,  JumpAerial,       -1)
    Character.edit_action_parameters(BIRDO, Action.FallAerial,        File.BIRDO_ANIM_FALLAERIAL,  -1,               -1)
    Character.edit_action_parameters(BIRDO, Action.Tech,              -1,                          Tech,             -1)
    Character.edit_action_parameters(BIRDO, Action.TechF,             -1,                          TechRoll,         -1)
    Character.edit_action_parameters(BIRDO, Action.TechB,             -1,                          TechRoll,         -1)
    Character.edit_action_parameters(BIRDO, Action.ShieldBreak,       -1,                          SHIELDBREAK_,     -1)
    Character.edit_action_parameters(BIRDO, Action.Stun,              -1,                          STUN_,            -1)
    Character.edit_action_parameters(BIRDO, Action.Sleep,             -1,                          SLEEP_,           -1)
    Character.edit_action_parameters(BIRDO, Action.CliffAttackQuick2, -1,                          CliffAtkQuick,    -1)
    Character.edit_action_parameters(BIRDO, Action.CliffAttackSlow2,  -1,                          CliffAtkSlow,     -1)
    Character.edit_action_parameters(BIRDO, Action.Teeter,            -1,                          Teeter,           -1)
 
    //ATTACKS 
    //Jab Attacks 
    Character.edit_action_parameters(BIRDO, Action.Jab1,               File.BIRDO_ANIM_JAB1,       JAB_1,            -1)
    Character.edit_action_parameters(BIRDO, Action.Jab2,               File.BIRDO_ANIM_JAB2,       JAB_2,            -1)
 
    //Tilt Attacks 
    Character.edit_action_parameters(BIRDO, Action.FTiltHigh,          File.BIRDO_ANIM_TILTF,      FTILT,            -1)
    Character.edit_action_parameters(BIRDO, Action.FTiltMidHigh,       File.BIRDO_ANIM_TILTF,      FTILT,            -1)
    Character.edit_action_parameters(BIRDO, Action.FTilt,              File.BIRDO_ANIM_TILTF,      FTILT,            -1)
    Character.edit_action_parameters(BIRDO, Action.FTiltMidLow,        File.BIRDO_ANIM_TILTF,      FTILT,            -1)
    Character.edit_action_parameters(BIRDO, Action.FTiltLow,           File.BIRDO_ANIM_TILTF,      FTILT,            -1)
    Character.edit_action_parameters(BIRDO, Action.UTilt,              File.BIRDO_ANIM_TILTU,      UTILT,            -1)
    

    //Other Attacks
    Character.edit_action_parameters(BIRDO, Action.DashAttack,         File.BIRDO_ANIM_DASHATTACK, DashAttack,       -1)

    //Aerial Attacks
    Character.edit_action_parameters(BIRDO, Action.AttackAirN,         File.BIRDO_ANIM_NAIR,       NAir,             -1)
    Character.edit_action_parameters(BIRDO, Action.AttackAirF,         File.BIRDO_ANIM_FAIR,       FAir,             -1)
    Character.edit_action_parameters(BIRDO, Action.AttackAirB,         File.BIRDO_ANIM_BAIR,       BAir,             -1)
    Character.edit_action_parameters(BIRDO, Action.AttackAirD,         File.BIRDO_ANIM_DAIR,       DAir,             0x40000001)
 
    //Smash Attacks 
    Character.edit_action_parameters(BIRDO, Action.DSmash,             File.BIRDO_ANIM_DSMASH,     DSmash,           -1)
    Character.edit_action_parameters(BIRDO, Action.USmash,             File.BIRDO_ANIM_USMASH,     USmash,           -1)
    Character.edit_action_parameters(BIRDO, Action.FSmashHigh,         File.BIRDO_ANIM_FSMASHHIGH, FSmash,           -1)
    Character.edit_action_parameters(BIRDO, Action.FSmash,             File.BIRDO_ANIM_FSMASH,     FSmash,           -1)
    Character.edit_action_parameters(BIRDO, Action.FSmashLow,          File.BIRDO_ANIM_FSMASHLOW,  FSmash,           -1)
 
    //Special Attacks 
    Character.edit_action_parameters(BIRDO, Action.EggShoot,           File.BIRDO_ANIM_NSP,        NSP_GROUND,       0x18000001)
    Character.edit_action_parameters(BIRDO, Action.EggShootAir,        File.BIRDO_ANIM_NSPAIR,     NSP_AIR,          0x18000001)
    Character.edit_action_parameters(BIRDO, Action.POWBlockGround,     File.BIRDO_ANIM_DSPGROUND,  DSPGROUND,        0x50000000)
    Character.edit_action_parameters(BIRDO, Action.POWBlockLand,       File.BIRDO_ANIM_DSPEND,     DSPLAND,          0x50000000)
    Character.edit_action_parameters(BIRDO, Action.POWBlockAir,        File.BIRDO_ANIM_DSPAIR,     DSPGROUND,        0x50000000)
    Character.edit_action_parameters(BIRDO, Action.POWBlockDrop,       -1,                         DSPDROP,          0x50000000)
 
    //Grab/Throws 
    Character.edit_action_parameters(BIRDO, Action.Grab,               File.BIRDO_ANIM_GRAB,       Grab_,            -1)
    Character.edit_action_parameters(BIRDO, Action.GrabPull,           File.BIRDO_ANIM_GRABPULL,   GrabPull,         -1)
    Character.edit_action_parameters(BIRDO, Action.ThrowF,             File.BIRDO_ANIM_THROWF,     THROWF_,          -1)
    Character.edit_action_parameters(BIRDO, Action.ThrowB,             File.BIRDO_ANIM_THROWB,     THROWB_,          -1)

    //DAMAGE

    //OTHER
    Character.edit_action_parameters(BIRDO, Action.Taunt,              File.BIRDO_ANIM_TAUNT,      Taunt,            -1)
    

    // Add Action Parameters               // Action Name      // Base Action   // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(BIRDO, USP_Ground_Begin,   -1,              File.BIRDO_ANIM_USP1,       USP_BEGIN,                  0x10000000)
    Character.add_new_action_params(BIRDO, USP_Ground_End,     -1,              File.BIRDO_ANIM_USP2,       USP_END,                    0x10000000)
    Character.add_new_action_params(BIRDO, USP_Air_Begin,      -1,              File.BIRDO_ANIM_USPAIR1,    USP_BEGIN,                  0x10000000)
    Character.add_new_action_params(BIRDO, USP_Air_End,        -1,              File.BIRDO_ANIM_USPAIR2,    USP_END,                    0x10000000)

    // Add Actions                  // Action Name     // Base Action  //Parameters                        // Staling ID   // Main ASM                    // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(BIRDO, USP_Ground_Begin,  -1,             ActionParams.USP_Ground_Begin,      0x12,           BirdoUSP.ground_begin_main_,   0,                              0x800D8BB4,                         BirdoUSP.ground_collision_)
    Character.add_new_action(BIRDO, USP_Ground_End,    -1,             ActionParams.USP_Ground_End,        0x12,           BirdoUSP.end_main_,            0,                              0x800D8BB4,                         BirdoUSP.ground_collision_)
    Character.add_new_action(BIRDO, USP_Air_Begin,     -1,             ActionParams.USP_Air_Begin,         0x12,           BirdoUSP.air_begin_main_,      0,                              0x800D90E0,                         BirdoUSP.air_collision_)
    Character.add_new_action(BIRDO, USP_Air_End,       -1,             ActionParams.USP_Air_End,           0x12,           BirdoUSP.end_main_,            0,                              0x800D90E0,                         BirdoUSP.air_collision_)

    
    // Modify Actions            // Action              // Staling ID   // Main ASM      // Interrupt/Other ASM   // Movement/Physics ASM   // Collision ASM
	Character.edit_action(BIRDO, Action.EggShoot,       -1,             BirdoNSP.main,   -1,                      -1,                       -1)
	Character.edit_action(BIRDO, Action.EggShootAir,    -1,             BirdoNSP.main,   -1,                      BirdoNSP.physics_,        BirdoNSP.air_collision_)
    Character.edit_action(BIRDO, Action.POWBlockGround, -1,             0,               BirdoDSP.ground_move_,   BirdoDSP.physics_,        -1)
    Character.edit_action(BIRDO, Action.POWBlockAir,    -1,             0,               BirdoDSP.air_move_,      BirdoDSP.physics_,        -1)
    
    


    // Modify Menu Action Parameters                    // Action         // Animation                     // Moveset Data       // Flags
    Character.edit_menu_action_parameters(BIRDO,        0x0,              File.BIRDO_ANIM_IDLE,            -1,                   -1)
    Character.edit_menu_action_parameters(BIRDO,        0x1,              File.BIRDO_ANIM_VICTORY1,        Win1,                 -1)
    Character.edit_menu_action_parameters(BIRDO,        0x2,              File.BIRDO_ANIM_VICTORY2,        Win2,                 -1)
    Character.edit_menu_action_parameters(BIRDO,        0x3,              File.BIRDO_ANIM_VICTORY3,        Win3,                 -1)
    Character.edit_menu_action_parameters(BIRDO,        0x4,              File.BIRDO_ANIM_VICTORY2,        Win2,                 -1)
    Character.edit_menu_action_parameters(BIRDO,        0x5,              File.BIRDO_ANIM_CLAP,            Clap,                 -1)
    Character.edit_menu_action_parameters(BIRDO,        0xD,              File.BIRDO_ANIM_1PPOSE,          -1,                   -1)
    Character.edit_menu_action_parameters(BIRDO,        0xE,              File.BIRDO_ANIM_CPUPOSE,         CPUPose,              -1)


    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.BIRDO, 0x2)
    dh FGM.CHANT
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.BIRDO, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    Character.table_patch_start(air_usp, Character.id.BIRDO, 0x4)
    dw      BirdoUSP.air_begin_initial_
    OS.patch_end()

    Character.table_patch_start(ground_usp, Character.id.BIRDO, 0x4)
    dw      BirdoUSP.ground_begin_initial_
    OS.patch_end()

    // Use Mario's initial/grounded script.
    Character.table_patch_start(initial_script, Character.id.BIRDO, 0x4)
    dw 0x800D7DCC
    OS.patch_end()
	
    Character.table_patch_start(grounded_script, Character.id.BIRDO, 0x4)
    dw 0x800DE428
    OS.patch_end()

    Character.table_patch_start(ground_dsp, Character.id.BIRDO, 0x4)
    dw      BirdoDSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.BIRDO, 0x4)
    dw      BirdoDSP.air_initial_
    OS.patch_end()

    // Set Remix 1P ending music
    Character.table_patch_start(remix_1p_end_bgm, Character.id.BIRDO, 0x2)
    dh {MIDI.id.SMB2OVERWORLD}
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.BIRDO, 0, 2, 1, 4, 1, 2, 4)
    Teams.add_team_costume(YELLOW, BIRDO, 0x3)

    // Set default egg shield color for Birdo
    Character.table_patch_start(yoshi_egg_color, Character.id.BIRDO, 0x2)
    dh Shield.color.MAGENTA
    OS.patch_end()

    // Shield colors for costume matching
    Character.set_costume_shield_colors(BIRDO, MAGENTA, RED, BLUE, YELLOW, GREEN, WHITE, BLACK, PURPLE, BROWN, NA, NA, NA)

    scope CloakingFix: {
        scope fix_: {
            // s8 = player struct
            // v0 = first custom part struct (racket)
            _check_birdo:
            addiu   sp, sp, -0x0010             // allocate stack space
            sw      t1, 0x0004(sp)              // save return address

            // Check which part is being displayed
            lbu     t2, 0x0999(s8)              // t2 = birdo right hand part_id
            beqzl   t2, _fix_birdo              // if holding racket, then already have correct v0
            nop
            b       _check_birdo_2              // otherwise, check if ball needs fixing
            nop

            _fix_birdo:
            li      t1, _check_birdo_2          // t1 is the address to return to
            j       CharEnvColor.override_env_color_._fix
            nop

            _check_birdo_2:
            // Check which part is being displayed
            lbu     t2, 0x09B3(s8)              // t2 = birdo item(?) part_id
            beqz    t2, _fix_birdo_2            // if holding ball, then fix
            lw      t1, 0x0004(sp)              // t1 = return address
            j       CharEnvColor.override_env_color_._return
            addiu   sp, sp, 0x0010              // allocate stack space

            _fix_birdo_2:
            li      v0, CharEnvColor.custom_display_lists_struct_birdo_ball
            j       CharEnvColor.override_env_color_._fix
            addiu   sp, sp, 0x0010              // allocate stack space
        }
    }

}
