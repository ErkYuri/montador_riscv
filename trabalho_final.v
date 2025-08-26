// Módulo da ALU para o Grupo 11
module alu (
    input [31:0] a,
    input [31:0] b,
    input [2:0] alu_op,
    output reg [31:0] result,
    output zero
);

    assign zero = (result == 32'd0);

    always @(*) begin
        case (alu_op)
            3'b000: begin
                result = a + b;
            end
            3'b001: begin
                result = a | b;
            end
            3'b010: begin
                result = a & b;
            end
            3'b011: begin
                result = a << b;
            end
            default: begin
                result = 32'bx;
            end
        endcase
    end
endmodule

// Módulo do Banco de Registradores para o RISC-V
module registers (
    input clk,
    input [4:0] read_reg_1,
    input [4:0] read_reg_2,
    input [4:0] write_reg,
    input [31:0] write_data,
    input reg_write,
    output [31:0] read_data_1,
    output [31:0] read_data_2
);

    reg [31:0] reg_file [0:31];

    assign read_data_1 = reg_file[read_reg_1];
    assign read_data_2 = reg_file[read_reg_2];

    always @(posedge clk) begin
        if (reg_write) begin
            if (write_reg != 5'b00000) begin
                reg_file[write_reg] <= write_data;
            end
        end
    end

    initial begin
        for (integer i = 0; i < 32; i = i + 1) begin
            reg_file[i] = 32'd0;
        end
    end
endmodule


// Módulo da Unidade de Controle para o RISC-V
module control_unit (
    input [6:0] opcode,
    output reg reg_write,
    output reg mem_write,
    output reg mem_read,
    output reg mem_to_reg,
    output reg alu_src,
    output reg [2:0] alu_op,
    output reg branch
);

    always @(*) begin
        reg_write = 1'b0;
        mem_write = 1'b0;
        mem_read = 1'b0;
        mem_to_reg = 1'b0;
        alu_src = 1'b0;
        alu_op = 3'b000;
        branch = 1'b0;

        case (opcode)
            7'b0110011: begin // Tipo-R (add, sub, sll, or, and)
                reg_write = 1'b1;
                alu_src = 1'b0;
                mem_read = 1'b0;
                mem_write = 1'b0;
                mem_to_reg = 1'b0;
                alu_op = 3'b111;
            end
            7'b0000011: begin // ld (Load)
                reg_write = 1'b1;
                mem_read = 1'b1;
                alu_src = 1'b1;
                mem_to_reg = 1'b1;
                alu_op = 3'b000;
            end
            7'b0100011: begin // sd (Store)
                mem_write = 1'b1;
                alu_src = 1'b1;
                alu_op = 3'b000;
            end
            7'b0010011: begin // andi (AND imediato)
                reg_write = 1'b1;
                alu_src = 1'b1;
                alu_op = 3'b010;
            end
            7'b1100011: begin // bne (Branch on not equal)
                branch = 1'b1;
                alu_op = 3'b000;
            end
            default: begin
                reg_write = 1'b0;
                mem_write = 1'b0;
                mem_read = 1'b0;
                mem_to_reg = 1'b0;
                alu_src = 1'b0;
                alu_op = 3'b000;
                branch = 1'b0;
            end
        endcase
    end
endmodule

// Módulo da Unidade de Controle da ALU
module alu_control (
    input [2:0] alu_op_in,
    input [2:0] funct3_in,
    input funct7_in,
    output reg [2:0] alu_op_out
);

    always @(*) begin
        case (alu_op_in)
            3'b111: begin // Operações tipo-R
                case (funct3_in)
                    3'b000: begin
                        if (funct7_in == 1'b0) begin
                            alu_op_out = 3'b000; // add
                        end else begin
                            alu_op_out = 3'b000; // sub
                        end
                    end
                    3'b110: begin
                        alu_op_out = 3'b001; // or
                    end
                    3'b111: begin
                        alu_op_out = 3'b010; // and
                    end
                    3'b001: begin
                        alu_op_out = 3'b011; // sll
                    end
                    default: alu_op_out = 3'b111;
                endcase
            end
            3'b010: alu_op_out = 3'b010; // andi
            default: alu_op_out = 3'b000; // Operação padrão 'add'
        endcase
    end
endmodule

// Módulo do Gerador de Imediato (Imm Gen)
module imm_gen (
    input [31:0] instruction,
    output reg [31:0] immediate
);

    wire [6:0] opcode = instruction[6:0];
    
    always @(*) begin
        case (opcode)
            7'b0010011: begin // Tipo-I (andi)
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end
            7'b0000011: begin // Tipo-I (lh)
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end
            7'b0100011: begin // Tipo-S (sh)
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            7'b1100011: begin // Tipo-B (bne)
                immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            default: begin
                immediate = 32'b0;
            end
        endcase
    end
endmodule

// Módulo da Memória de Instruções RISC-V
module instruction_memory (
    input [31:0] pc,
    output [31:0] instruction
);

    reg [31:0] mem[0:31];

    assign instruction = mem[pc[7:2]];

    initial begin
        mem[0] = 32'b00000000000000000000000010000011;
        mem[1] = 32'b00000000000100001000000100110011;
        mem[2] = 32'b00000000001000001001000010110011;
        mem[3] = 32'b00000000001000001001000010110011;
        mem[4] = 32'b00000000000000000010000100110011;
        mem[5] = 32'b00000000000000000010000100110011;
        mem[6] = 32'b00000000001000001001011110010011;
        mem[7] = 32'b00000000000000010001000010110011;
        mem[8] = 32'b00000000000100001000000000100011;
        mem[9] = 32'b00000000001000001001000010110011;
        mem[10] = 32'b00000000000000000110000100110011;
        mem[11] = 32'b00000000000100001000000000100011;
    end
endmodule

// Módulo da Memória de Dados RISC-V simplificado
module data_memory (
    input clk,
    input [31:0] addr,
    input [31:0] write_data,
    input mem_read,
    input mem_write,
    output reg [31:0] read_data
);

    reg [31:0] mem[0:1023];

    always @(posedge clk) begin
        if (mem_write) begin
            mem[addr[31:2]] <= write_data;
        end
    end

    always @(*) begin
        if (mem_read) begin
            read_data = mem[addr[31:2]];
        end
        else begin
            read_data = 32'bx;
        end
    end

    initial begin
        mem[4] = 32'h00000007;
    end

endmodule

// Módulo de um Multiplexador 2 para 1 parametrizado
module mux2x1 #(
    parameter WIDTH = 32
) (
    input sel,
    input [WIDTH-1:0] in0,
    input [WIDTH-1:0] in1,
    output [WIDTH-1:0] out
);
    
    assign out = sel ? in1 : in0;
endmodule


// Testbench Final: Módulo principal que contém toda a lógica
module riscv_testbench_final;

    // Sinais para a conexão entre os módulos
    reg clk;
    reg reset;
    
    // Sinais internos que conectam os módulos do datapath
    reg [31:0] pc_reg;
    wire [31:0] instruction;
    wire [31:0] read_data_1, read_data_2;
    wire [31:0] alu_result, alu_b_src;
    wire [31:0] immediate;
    wire [31:0] mem_read_data;
    wire zero;
    wire branch, mem_read, mem_write, alu_src, reg_write, mem_to_reg;
    wire [2:0] alu_op_main, alu_op_control;
    wire [31:0] write_data_mux_out;

    // Instanciação de todos os módulos
    instruction_memory im (
        .pc(pc_reg),
        .instruction(instruction)
    );
    
    control_unit uc (
        .opcode(instruction[6:0]),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .alu_op(alu_op_main),
        .branch(branch)
    );
    
    alu_control ac (
        .alu_op_in(alu_op_main),
        .funct3_in(instruction[14:12]),
        .funct7_in(instruction[30]),
        .alu_op_out(alu_op_control)
    );
    
    registers reg_file (
        .clk(clk),
        .read_reg_1(instruction[19:15]),
        .read_reg_2(instruction[24:20]),
        .write_reg(instruction[11:7]),
        .write_data(write_data_mux_out),
        .reg_write(reg_write),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );
    
    imm_gen ig (
        .instruction(instruction),
        .immediate(immediate)
    );
    
    mux2x1 #(
        .WIDTH(32)
    ) mux_alu_b (
        .sel(alu_src),
        .in0(read_data_2),
        .in1(immediate),
        .out(alu_b_src)
    );
    
    alu alu_inst (
        .a(read_data_1),
        .b(alu_b_src),
        .alu_op(alu_op_control),
        .result(alu_result),
        .zero(zero)
    );
    
    mux2x1 #(
        .WIDTH(32)
    ) mux_reg_write (
        .sel(mem_to_reg),
        .in0(alu_result),
        .in1(mem_read_data),
        .out(write_data_mux_out)
    );

    data_memory dm (
        .clk(clk),
        .addr(alu_result),
        .write_data(read_data_2),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .read_data(mem_read_data)
    );

    // Lógica do PC (Program Counter)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_reg <= 32'd0;
        end else begin
            if (branch && !zero) begin
                pc_reg <= pc_reg + immediate;
            end else begin
                pc_reg <= pc_reg + 4;
            end
        end
    end
    
    // Geração de clock automático para a simulação
    always #5 clk = ~clk;

    // Lógica principal de simulação
    initial begin
        $dumpfile("riscv_sim.vcd");
        $dumpvars(0, riscv_testbench_final);

        $display("-------------------------------------------");
        $display("Iniciando a simulação do processador RISC-V");
        $display("-------------------------------------------");

        clk = 1'b0;
        reset = 1'b1;
        
        #10;
        reset = 1'b0;
        
        for (integer i = 0; i < 20; i = i + 1) begin
            #10;
            
            if (!reset) begin
                $display("-------------------------------------------");
                $display("Estado dos Registradores no Tempo %0t", $time);
                for (integer j = 0; j < 32; j = j + 1) begin
                    $display("Reg[%0d]: %h", j, reg_file.reg_file[j]);
                end
                $display("-------------------------------------------");
            end
        end

        #10;
        $finish;
    end

endmodule