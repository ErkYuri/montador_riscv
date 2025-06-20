/*
 * Montador RISC-V Simplificado - Grupo 11
 * Instruções suportadas: lh, sh, add, or, andi, sll, bne
 * Linguagem: C
 * Compile com: gcc montador.c -o montador
 * Rode com: ./montador entrada.asm [-o saida.txt]
 */

#include <stdio.h>    // Biblioteca padrão de entrada e saída
#include <stdlib.h>   // Biblioteca para uso de atoi, malloc, etc.
#include <string.h>   // Biblioteca para manipulação de strings

#define MAX_LINE 100  // Tamanho máximo de uma linha do .asm
#define MAX_BIN 35    // Tamanho máximo da string binária da instrução

// Remove o '\n' do final de uma string (linha do arquivo)
void remove_newline(char *str) {
    str[strcspn(str, "\n")] = 0;
}

// Converte registrador "xN" para binário de 5 bits
void reg_to_bin(char *reg, char *bin) {
    int num = atoi(reg + 1); // Ignora o 'x' e pega o número
    for (int i = 4; i >= 0; i--) {
        bin[4 - i] = ((num >> i) & 1) + '0';
    }
    bin[5] = '\0'; // Finaliza string
}

// Converte um inteiro para binário com sinal, com quantidade de bits definida
void imm_to_bin(int num, char *bin, int bits) {
    unsigned val = (unsigned)(num & ((1 << bits) - 1));
    for (int i = bits - 1; i >= 0; i--) {
        bin[bits - 1 - i] = ((val >> i) & 1) + '0';
    }
    bin[bits] = '\0';
}

// Imprime no terminal e salva no arquivo (se houver)
void print_and_save(FILE *out, const char *binstr) {
    printf("%s\n", binstr);               // Sempre imprime no terminal
    if (out && out != stdout) {
        fprintf(out, "%s\n", binstr);     // Escreve no arquivo, se necessário
    }
}

// Formato R - ADD
void add_instr(char *rd, char *rs1, char *rs2, FILE *out) {
    char rd_bin[6], rs1_bin[6], rs2_bin[6], binstr[33];
    reg_to_bin(rd, rd_bin);
    reg_to_bin(rs1, rs1_bin);
    reg_to_bin(rs2, rs2_bin);
    sprintf(binstr, "0000000%s%s000%s0110011", rs2_bin, rs1_bin, rd_bin);
    print_and_save(out, binstr);
}

// Formato R - OR
void or_instr(char *rd, char *rs1, char *rs2, FILE *out) {
    char rd_bin[6], rs1_bin[6], rs2_bin[6], binstr[33];
    reg_to_bin(rd, rd_bin);
    reg_to_bin(rs1, rs1_bin);
    reg_to_bin(rs2, rs2_bin);
    sprintf(binstr, "0000000%s%s110%s0110011", rs2_bin, rs1_bin, rd_bin);
    print_and_save(out, binstr);
}

// Formato I - ANDI
void andi_instr(char *rd, char *rs1, int imm, FILE *out) {
    char rd_bin[6], rs1_bin[6], imm_bin[13], binstr[33];
    reg_to_bin(rd, rd_bin);
    reg_to_bin(rs1, rs1_bin);
    imm_to_bin(imm, imm_bin, 12);
    sprintf(binstr, "%s%s111%s0010011", imm_bin, rs1_bin, rd_bin);
    print_and_save(out, binstr);
}

// Formato R - SLL
void sll_instr(char *rd, char *rs1, char *rs2, FILE *out) {
    char rd_bin[6], rs1_bin[6], rs2_bin[6], binstr[33];
    reg_to_bin(rd, rd_bin);
    reg_to_bin(rs1, rs1_bin);
    reg_to_bin(rs2, rs2_bin);
    sprintf(binstr, "0000000%s%s001%s0110011", rs2_bin, rs1_bin, rd_bin);
    print_and_save(out, binstr);
}

// Formato I - LH
void lh_instr(char *rd, int imm, char *rs1, FILE *out) {
    char rd_bin[6], rs1_bin[6], imm_bin[13], binstr[33];
    reg_to_bin(rd, rd_bin);
    reg_to_bin(rs1, rs1_bin);
    imm_to_bin(imm, imm_bin, 12);
    sprintf(binstr, "%s%s001%s0000011", imm_bin, rs1_bin, rd_bin);
    print_and_save(out, binstr);
}

// Formato S - SH
void sh_instr(char *rs2, int imm, char *rs1, FILE *out) {
    char rs2_bin[6], rs1_bin[6], imm_bin[13], imm_hi[8], imm_lo[6], binstr[33];
    reg_to_bin(rs2, rs2_bin);
    reg_to_bin(rs1, rs1_bin);
    imm_to_bin(imm, imm_bin, 12);
    strncpy(imm_hi, imm_bin, 7); imm_hi[7] = '\0';
    strncpy(imm_lo, imm_bin + 7, 5); imm_lo[5] = '\0';
    sprintf(binstr, "%s%s001%s%s0100011", imm_hi, rs2_bin, rs1_bin, imm_lo);
    print_and_save(out, binstr);
}

// Formato B - BNE
void bne_instr(char *rs1, char *rs2, int imm, FILE *out) {
    char rs1_bin[6], rs2_bin[6], imm_bin[14], imm12[2], imm10_5[7], imm4_1[5], imm11[2], binstr[33];
    reg_to_bin(rs1, rs1_bin);
    reg_to_bin(rs2, rs2_bin);
    imm_to_bin(imm, imm_bin, 13);
    imm12[0] = imm_bin[0]; imm12[1] = '\0';
    strncpy(imm10_5, imm_bin + 1, 6); imm10_5[6] = '\0';
    strncpy(imm4_1, imm_bin + 7, 4); imm4_1[4] = '\0';
    imm11[0] = imm_bin[11]; imm11[1] = '\0';
    sprintf(binstr, "%s%s%s001%s%s1100011", imm12, imm10_5, rs2_bin, rs1_bin, imm4_1);
    print_and_save(out, binstr);
}

int main(int argc, char *argv[]) {
    // Verifica se o usuário passou o nome do arquivo .asm
    if (argc < 2) {
        printf("Uso: %s arquivo.asm [-o saida.txt]\n", argv[0]);
        return 1;
    }

    // Abre o arquivo de entrada
    FILE *in = fopen(argv[1], "r");
    if (!in) {
        perror("Erro ao abrir arquivo de entrada");
        return 1;
    }

    // Define a saída padrão (terminal), a menos que seja especificado um arquivo
    FILE *out = stdout;
    if (argc == 4 && strcmp(argv[2], "-o") == 0) {
        out = fopen(argv[3], "w");
        if (!out) {
            perror("Erro ao abrir arquivo de saída");
            return 1;
        }
    }

    // Lê e processa linha por linha do arquivo
    char linha[MAX_LINE];
    while (fgets(linha, MAX_LINE, in)) {
        remove_newline(linha);

        char instr[10], op1[10], op2[10], op3[10];
        int lidos = sscanf(linha, "%s %[^,], %[^,], %s", instr, op1, op2, op3);

        // Chama a função correspondente à instrução lida
        if (strcmp(instr, "add") == 0 && lidos == 4) {
            add_instr(op1, op2, op3, out);
        } else if (strcmp(instr, "or") == 0 && lidos == 4) {
            or_instr(op1, op2, op3, out);
        } else if (strcmp(instr, "andi") == 0 && lidos == 4) {
            andi_instr(op1, op2, atoi(op3), out);
        } else if (strcmp(instr, "sll") == 0 && lidos == 4) {
            sll_instr(op1, op2, op3, out);
        } else if (strcmp(instr, "lh") == 0 && lidos == 4) {
            lh_instr(op1, atoi(op2), op3, out);
        } else if (strcmp(instr, "sh") == 0 && lidos == 4) {
            sh_instr(op1, atoi(op2), op3, out);
        } else if (strcmp(instr, "bne") == 0 && lidos == 4) {
            bne_instr(op1, op2, atoi(op3), out);
        } else {
            fprintf(stderr, "Instrução não suportada ou inválida: %s\n", linha);
        }
    }

    // Fecha os arquivos
    fclose(in);
    if (out != stdout) fclose(out);
    return 0;
}
