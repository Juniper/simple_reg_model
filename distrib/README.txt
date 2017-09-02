The UVM kit is licensed under the MIT license.  The full text of
the license is provided in this kit in the file LICENSE.txt

Extenal Dependecny
-------------------
This kit requires UVM package to be already installed. Please refer to the
accellera website to download and install it.

Installing the kit
------------------

Installation of SRM requires first unpacking the kit in a convenient
location.

    % mkdir path/to/convenient/location
    % cd path/to/convenient/location
    % gunzip -c path/to/SRM/distribution/tar.gz | tar xvf -

You should define the $SRM_HOME environment variable to that
convenient location using an absolute path name. The following
instructions assume that this variable is appropriately set.

   % setenv SRM_HOME /absolute/path/to/convenient/location


Using the SRM 
-------------

You must compile the file $SRM_HOME/src/srm.sv first. You will need
to specify the location of $SRM_HOME/src as a include directory in your
compilation command line using the +incdir+ command-line option.

You can then make the SRM library accessible to your SystemVerilog
code by importing the package 'srm_pkg' in the appropriate scope.


Prerequisites
-------------

- IEEE1800 compliant SV simulator
- gmake-compliant make to execute Makefile based examples
- uvm package installed


Running the examples
--------------------

The examples assume the following steps to be completed:

- The Compiler/Simulator environment has been setup according to the vendors 
  instruction and you can execute compile/simulation on the commandline.

- Following environment variables have been defined.
  UVM_HOME points to the uvm install directory.

To run any of the examples:

1. change to the example dir (ex: cd examples/trivial)
2. execute "make -f Makefile.{ius|vcs}" depending upon your simulator vendor to run the example. 
The makefiles assume a gmake compiliant make tool.

optional:
- to see the commands and steps executed use "make -f Makefile.{ius|vcs} -n"

  
 


------------------------------------------------------------------------
