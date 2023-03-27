
## ☞ RISC-V CPU 
### 2022 NTU CSIE Computer Architecture Lab 2
* Features: 
  * off-chip data memory + 2-way associative cache
    * Cache Size: 16 KB 
    * LRU Replacement policy 
    * Cache Block/Line size: 32 bytes 
    * RW Alignment: align to 8 bytes 
    * Write Hit/Miss Policy: write back, write allocate
    * Bit-length: cache tag = 23, cache idx = 4, block offset = 5 
  * on-chip instruction memory 
  * 5-stage pipelined pipeline 
* Supported instructions: 
  `AND, XOR, SLL, ADD, SUB, MUL, ADDI, SRAI, LW, SW, BEQ`
* Env: `Mac with Intel(R) Core(TM) i5-8257U CPU @ 1.40GHz`
        ,`Vscode`
        ,`iverilog`
* Additional specs: 
    * 32-bit instruction
    * support Forwarding, Hazard Detection
    * 10-cycle memory latency 
* Compile (using lab2 testbench, namely `testbench.v`)
    ```
    cd codes # make sure you're at codes directory level
    iverilog -o ./testbench.vvp ./testbench.v
    vvp ./CPU/testbench.vvp
    // outputs: output_{}.txt, cache_{}.txt for register/dmem states and cache history repectively. 
    ```
 
![CPU](https://github.com/Nana2929/CAlab2/blob/master/cpu_fig.png)
