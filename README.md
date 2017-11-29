# Introduction
This is the top level directory of the simple reg model repository. The distrib directory will contain code that is intended for distribution.

## Simple Register Model
Simple Register Model (srm) are system verilog classes that help to develop register model (aka regstore, register abstraction layer) for uvm testbenches.

It is designed to be used in uvm testbenches instead of the *uvm_reg* package that is shipped with uvm distribution. 

The intended users of the package are design verificatipn (DV) engineers involved in developing uvm testbneches and writing uvm sequences for verifying the design.

## Links
1. For a overall introduction to a DV engineer refer to [Introduction](Introduction.md)

2. For a 10K view of the class hier refer to [ClassHier](docs/ClassHier.md)

3. For some sequence diagrams of the api refer to [AccessSeq](docs/AccessSeq.md)

4. For just getting started with the repository refer to [HowTo](docs/HOW_TO.md)

5. Misc API

     a. [Reset API](docs/ResetAPI.md)

