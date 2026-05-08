#if __riscv_xlen == 64
# define LREG         ld
# define SREG         sd
# define REGBYTES     8
#else
# define LREG         lw
# define SREG         sw
# define REGBYTES     4
#endif


.global _start
.global timer_setup
.global end

_start:
    csrr    t0,mhartid             # read current hart id
    bnez    t0,park                # single core only, park hart != 0

   

    // set pmp to avoid access faults
    li      t0,-1
    csrw    pmpaddr0,t0
    li      t0,0x1F
    csrw    pmpcfg0,t0

    // set trap_vector
    la      t0,trap_vector
    csrw    mtvec,t0 

    la      sp,stack_top           # setup stack
    
    # mstatus: MPP=U,MPIE=1,MIE=0
    csrr    t0,mstatus
    li      t1,~((1<<3)|(3<<11))
    and     t0,t0,t1
    li      t1,(1<<7)
    or      t0,t0,t1
    csrw    mstatus,t0

    # mepc = main
    la      t0, main
    csrw    mepc, t0

    mret


timer_setup:
    csrr  t0,mie
    li    t1,0x80
    beqz  a0,1f
    or    t0,t0,t1
    j     2f

1:
    not   t1,t1
    and   t0,t0,t1
    
2:
    csrw  mie,t0
    // some actions with mie(sdelal)
    ret

trap_vector:
  addi sp, sp, -32*REGBYTES
  SREG x1, 1*REGBYTES(sp)
  SREG x2, 2*REGBYTES(sp)
  SREG x3, 3*REGBYTES(sp)
  SREG x4, 4*REGBYTES(sp)
  SREG x5, 5*REGBYTES(sp)
  SREG x6, 6*REGBYTES(sp)
  SREG x7, 7*REGBYTES(sp)
  SREG x8, 8*REGBYTES(sp)
  SREG x9, 9*REGBYTES(sp)
  SREG x10, 10*REGBYTES(sp)
  SREG x11, 11*REGBYTES(sp)
  SREG x12, 12*REGBYTES(sp)
  SREG x13, 13*REGBYTES(sp)
  SREG x14, 14*REGBYTES(sp)
  SREG x15, 15*REGBYTES(sp)
  SREG x16, 16*REGBYTES(sp)
  SREG x17, 17*REGBYTES(sp)
  SREG x18, 18*REGBYTES(sp)
  SREG x19, 19*REGBYTES(sp)
  SREG x20, 20*REGBYTES(sp)
  SREG x21, 21*REGBYTES(sp)
  SREG x22, 22*REGBYTES(sp)
  SREG x23, 23*REGBYTES(sp)
  SREG x24, 24*REGBYTES(sp)
  SREG x25, 25*REGBYTES(sp)
  SREG x26, 26*REGBYTES(sp)
  SREG x27, 27*REGBYTES(sp)
  SREG x28, 28*REGBYTES(sp)
  SREG x29, 29*REGBYTES(sp)
  SREG x30, 30*REGBYTES(sp)
  SREG x31, 31*REGBYTES(sp)
  csrr a0, mcause
  csrr a1, mepc
  mv a2, sp
  la t0, handle_trap
  jalr t0
  csrw mepc, a0
  LREG x1, 1*REGBYTES(sp)
  LREG x2, 2*REGBYTES(sp)
  LREG x3, 3*REGBYTES(sp)
  LREG x4, 4*REGBYTES(sp)
  LREG x5, 5*REGBYTES(sp)
  LREG x6, 6*REGBYTES(sp)
  LREG x7, 7*REGBYTES(sp)
  LREG x8, 8*REGBYTES(sp)
  LREG x9, 9*REGBYTES(sp)
  LREG x10, 10*REGBYTES(sp)
  LREG x11, 11*REGBYTES(sp)
  LREG x12, 12*REGBYTES(sp)
  LREG x13, 13*REGBYTES(sp)
  LREG x14, 14*REGBYTES(sp)
  LREG x15, 15*REGBYTES(sp)
  LREG x16, 16*REGBYTES(sp)
  LREG x17, 17*REGBYTES(sp)
  LREG x18, 18*REGBYTES(sp)
  LREG x19, 19*REGBYTES(sp)
  LREG x20, 20*REGBYTES(sp)
  LREG x21, 21*REGBYTES(sp)
  LREG x22, 22*REGBYTES(sp)
  LREG x23, 23*REGBYTES(sp)
  LREG x24, 24*REGBYTES(sp)
  LREG x25, 25*REGBYTES(sp)
  LREG x26, 26*REGBYTES(sp)
  LREG x27, 27*REGBYTES(sp)
  LREG x28, 28*REGBYTES(sp)
  LREG x29, 29*REGBYTES(sp)
  LREG x30, 30*REGBYTES(sp)
  LREG x31, 31*REGBYTES(sp)
  addi sp, sp, 32*REGBYTES
  mret

park:
    wfi
    j       park


end:
    j end