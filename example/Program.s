start:
    nop
    addi x1, x0, 1
    addi x6, x0, 1
    addi x12, x0, 4
    sw x6, 0(x1)        # x6 -> R2 Data Dependency (WriteBack)
loop:
    lw x6, 0(x1)        # Load Stall
    addi x6, x6, 1      # x6 -> R1 Data Dependency
    sw x6, 0(x1)
    blt x6, x12, loop   # x6 -> R1 Data Dependency (WriteBack) & Control Hazard
data_dep_test:
    addi x8, x0, 55
    add x8, x0, x8      # x8 -> R2 Data Dependency
    addi x8, x8, 1      # x8 -> R1 Data Dependency
finish:
    nop