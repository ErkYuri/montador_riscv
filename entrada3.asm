add x2, x0, x1
sll x3, x2, x1
or x4, x2, x3
andi x5, x3, 7
lh x6, 8, x2
sh x5, 12, x6
bne x4, x5, -16
