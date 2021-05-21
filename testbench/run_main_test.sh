#!/bin/bash
if [ ! -d "./output" ]; then
    mkdir output;
fi

echo "== Main Test =============" &&
iverilog -g2005-sv -I ../src/ -o output/tb_main tb_Main.v && vvp output/tb_main &&
echo "DONE!" || echo "An error occured!";