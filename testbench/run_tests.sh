#!/bin/bash
if [ ! -d "./output" ]; then
    mkdir output;
fi

echo "== Encoders Test ========================" &&
iverilog -g2005-sv -I ../src/ -o output/tb_encoders tb_Encoders.v && vvp output/tb_encoders &&
echo "== ALU Test ============================" &&
iverilog -g2005-sv -I ../src/ -o output/tb_alu tb_ALU.v && vvp output/tb_alu &&
echo "== RegFile Test=========================" &&
iverilog -g2005-sv -I ../src/ -o output/tb_regfile tb_RegFile.v && vvp output/tb_regfile && 
echo "== ImmediateExtractor Test =============" &&
iverilog -g2005-sv -I ../src/ -o output/tb_immediateextractor tb_ImmediateExtractor.v && vvp output/tb_immediateextractor &&
echo "== RAM Test ============================" &&
iverilog -g2005-sv -I ../src/ -o output/tb_ram tb_RAM.v && vvp output/tb_ram &&
echo "== ROM Test ============================" &&
iverilog -g2005-sv -I ../src/ -o output/tb_rom tb_ROM.v && vvp output/tb_rom &&
echo "========================================" &&
echo "Test finished." || echo "ERROR: One of the modules has been failed to compile!";