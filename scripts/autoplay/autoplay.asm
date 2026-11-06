// autoplay.asm - TEST BUILDS ONLY (scripts/autoplay/run.py includes it; release builds never do).
// Replaces the raw controller reads for ports 1 and 2 with a frame script, so a test ROM
// drives the real menus and matches by itself, with no host keyboard involved.

scope Autoplay {
    // Vanilla controller update: jal osContGetReadData(a0 = raw OSContPad[4] @ 0x80045188).
    // a0 is set in the delay slot (0x80003E24), so it is ready when read_ starts.
    OS.patch_start(0x4A20, 0x80003E20)
    jal     Autoplay.read_
    OS.patch_end()

    scope read_: {
        addiu   sp, sp, -0x18
        sw      ra, 0x0014(sp)
        jal     0x80031FF4                  // original: osContGetReadData
        nop
        li      t0, Toggles.entry_fps       // force the FPS counter on (1 = standard clock)
        lli     t1, 1                       // so screenshots show lag
        sw      t1, 0x0004(t0)
        li      t0, state_p1
        li      t1, 0x80045188              // t1 = raw pad, port 1
        jal     apply_
        nop
        li      t0, state_p2
        li      t1, 0x8004518E              // t1 = raw pad, port 2
        jal     apply_
        nop
        lw      ra, 0x0014(sp)
        jr      ra
        addiu   sp, sp, 0x18
    }

    // t0 = {entry ptr, frame the entry ends (0 = not started)}, t1 = OSContPad
    // {u16 buttons, s8 x, s8 y, u8 errno}. The game polls more than once a frame, so entries
    // are timed by Global.frame_counter, not by polls.
    // Script entry: dh frames, buttons; db x, y; dh 0. frames == 0 ends the script (neutral after).
    scope apply_: {
        lui     t6, 0x8004
        lw      t6, 0xCB30(t6)              // t6 = Global.frame_counter (0x8003CB30)
        lw      t2, 0x0000(t0)              // t2 = entry
        lhu     t3, 0x0000(t2)              // t3 = frames for entry
        beqz    t3, _neutral
        lw      t4, 0x0004(t0)              // t4 = end frame
        bnez    t4, _check
        nop
        addu    t4, t6, t3                  // first entry starts now
        sw      t4, 0x0004(t0)
        _check:
        sltu    at, t6, t4
        bnez    at, _apply                  // still inside this entry
        nop
        addiu   t2, t2, 0x0008              // next entry
        sw      t2, 0x0000(t0)
        lhu     t3, 0x0000(t2)
        beqz    t3, _neutral
        addu    t4, t6, t3
        sw      t4, 0x0004(t0)
        _apply:
        lhu     t5, 0x0002(t2)
        sh      t5, 0x0000(t1)              // buttons
        lb      t5, 0x0004(t2)
        sb      t5, 0x0002(t1)              // stick x
        lb      t5, 0x0005(t2)
        sb      t5, 0x0003(t1)              // stick y
        jr      ra
        sb      r0, 0x0004(t1)              // errno 0 = controller connected
        _neutral:
        sh      r0, 0x0000(t1)
        sh      r0, 0x0002(t1)
        jr      ra
        sb      r0, 0x0004(t1)
    }

    OS.align(4)
    state_p1:; dw script_p1, 0
    state_p2:; dw script_p2, 0

    include "autoplay_script.asm"           // generated: script_p1:/script_p2: entries
}
