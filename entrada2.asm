add x2, x0, x1      
sll x3, x2, x1       
or x4, x2, x3       
andi x5, x4, 15     
lh x6, 8, x0          
sh x5, 4, x6         
bne x3, x5, -4