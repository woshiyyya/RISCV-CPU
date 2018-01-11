//ȫ��
`define RstEnable 1'b1
`define RstDisable 1'b0
`define ZeroWord 32'h00000000
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define AluOpBus 10:0
`define AluSelBus 2:0
`define InstValid 1'b0
`define InstInvalid 1'b1
`define Stop 1'b1
`define NoStop 1'b0
`define InDelaySlot 1'b1
`define NotInDelaySlot 1'b0
`define Branch 1'b1
`define NotBranch 1'b0
`define InterruptAssert 1'b1
`define InterruptNotAssert 1'b0
`define TrapAssert 1'b1
`define TrapNotAssert 1'b0
`define True_v 1'b1
`define False_v 1'b0
`define ChipEnable 1'b1
`define ChipDisable 1'b0

// Level1 opcode
`define OP_LUI      7'b0110111  //U
`define OP_AUIPC    7'b0010111  //U
`define OP_JAL      7'b1101111  //  J
`define OP_JALR     7'b1100111  //      I
`define OP_BRANCH   7'b1100011  //          B
`define OP_LOAD     7'b0000011  //      I
`define OP_STORE    7'b0100011  //              S
`define OP_ALUI     7'b0010011  //      I
`define OP_ALU      7'b0110011  //                  R
`define OP_FENCE    7'b0001111  //X
`define OP_NOP      7'b0000000  //X

//ALU OP    width = 11
//SINGULAR
`define EXE_LUI     11'b00000110111
`define EXE_AUIPC   11'b00000010111
`define EXE_JAL     11'b00001101111
`define EXE_JALR    11'b00001100111
// BRANCH
`define EXE_BEQ     11'b00001100011//
`define EXE_BNE     11'b00011100011//
`define EXE_BLT     11'b01001100011//
`define EXE_BGE     11'b01011100011//
`define EXE_BLTU    11'b01101100011//
`define EXE_BGEU    11'b01111100011//
// LOAD
`define EXE_LB      11'b00000000011//003
`define EXE_LH      11'b00010000011//083
`define EXE_LW      11'b00100000011//103
`define EXE_LBU     11'b01000000011//203
`define EXE_LHU     11'b01010000011//243
// STORE
`define EXE_SB      11'b00000100011//023
`define EXE_SH      11'b00010100011//0B3
`define EXE_SW      11'b00100100011//123
// OP-IMM
`define EXE_ADDI      11'b00000010011//
`define EXE_SLTI      11'b00100010011//
`define EXE_SLTIU     11'b00110010011//
`define EXE_XORI      11'b01000010011//
`define EXE_ORI       11'b01100010011//
`define EXE_ANDI      11'b01110010011//
`define EXE_SLLI      11'b00010010011//
`define EXE_SRLI      11'b01010010011//
`define EXE_SRAI      11'b11010010011//
// OP
`define EXE_ADD       11'b00000110011//
`define EXE_SUB       11'b10000110011//
`define EXE_SLL       11'b00010110011//
`define EXE_SLT       11'b00100110011//
`define EXE_SLTU      11'b00110110011//
`define EXE_XOR       11'b01000110011//
`define EXE_SRL       11'b01010110011//
`define EXE_SRA       11'b11010110011//
`define EXE_OR        11'b01100110011//
`define EXE_AND       11'b01110110011//
// MISC-MEM
`define EXE_FENCE     11'b00000001111
`define EXE_FENCEI    11'b00010001111 

`define EXE_NOP 6'b000000
`define SSNOP 32'b00000000000000000000000001000000
`define SPECIAL  ((aluopT == 10'b1010010011)||(aluopT == 10'b0000110011)||(aluopT == 10'b1010110011))

`define EXE_SPECIAL_INST    6'b000000
`define EXE_REGIMM_INST     6'b000001
`define EXE_SPECIAL2_INST   6'b011100

//AluSel
`define EXE_RES_LOGIC       3'b001
`define EXE_RES_SHIFT       3'b010
`define EXE_RES_BRANCH      3'b011	
`define EXE_RES_ARITHMETIC  3'b100	
`define EXE_RES_LDST        3'b101

`define EXE_RES_NOP         3'b000


//ָ���?��inst_rom
`define InstAddrBus 31:0
`define InstBus 31:0
`define InstMemNum 131071
`define InstMemNumLog2 17

//data RAM
`define DataAddrBus 31:0
`define DataBus 31:0
`define DataMemNum 1024
//`define DataMemNum 131071
`define DataMemNumLog2 17
`define ByteWidth 7:0


//ͨ�üĴ���regfile
`define RegAddrBus 4:0
`define RegBus 31:0
`define RegWidth 32
`define DoubleRegWidth 64
`define DoubleRegBus 63:0
`define RegNum 32
`define RegNumLog2 5
`define NOPRegAddr 5'b00000
