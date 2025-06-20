add x2, x0, x1       # x2 = x0 + x1
sll x3, x2, x1       # x3 = x2 << x1
or x4, x2, x3        # x4 = x2 | x3
andi x5, x4, 15      # x5 = x4 & 15
lh x6, 8, x0         # carrega 2 bytes da posição x0 + 8 para x6
sh x5, 4, x6         # armazena 2 bytes de x5 em x6 + 4
bne x3, x5, -4       # se x3 != x5, salta para 4 posições antes