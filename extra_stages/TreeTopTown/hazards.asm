// @ Description
// This establishes Tree Top Town hazard (Congo Jungle barrel)
scope setup: {
    addiu   sp, sp,-0x0060              // allocate stack space
    sw      ra, 0x0024(sp)              // ~
    sw      s0, 0x0028(sp)              // store ra, s0

    jal     0x80109FB4
    nop

    lw      ra, 0x0024(sp)              // ~
    lw      s0, 0x0028(sp)              // load ra, s0
    addiu   sp, sp, 0x0060              // deallocate stack space

    hazard_toggle(0x80109E84)
}