# Simple Register Model
Simple Register Model (srm) are system verilog classes that help to develop register model (aka regstore, register abstraction layer) for [uvm testbenches](http://accellera.org/downloads/standards/uvm).  

It is open sourced and available under MIT license.  

It is designed to be used in uvm testbenches instead of the *uvm_reg* package that is shipped with uvm distribution.  

The intended users of the package are design verificatipn (DV) engineers involved in developing uvm testbneches and writing uvm sequences for verifying the design.

## Getting Started
Easiest way to get started with srm is to download the tar file from the [release area](https://github.com/Juniper/simple_reg_model/releases) and follow the instructions. 

## Installing the Package 
1. Download tar file from release area. Say the name of file is svm-1.0.tar.gz

2. Unpack the tar file in the install directory.
```
   cd <install_dir>
   tar cvfz svm-1.0.tar.gz
```

3. Setup the environment variable SRM_HOME to point to the install directory. 
For example in Bash shell.  

```
   export SRM_HOME=<install_dir>/srm-1.0
```

## Using the Package
You must compile the file $SRM_HOME/src/srm.sv first. You will need to specify the location of $SRM_HOME/src as a include directory in your
compilation command line using the +incdir+ command-line option.  

You can then make the SRM library accessible to your SystemVerilog code by importing the package 'srm_pkg' in the appropriate scope.  

Examples for different simulator can be found in the installation directory $SRM_HOME/examples/  


## Demo 
A example uvm testbench can be downloaded from [here](https://github.com/sanjeevs/srm_sap).  

## Documentation
Srm docuementation can be found [here](https://github.com/Juniper/simple_reg_model/wiki).
