## Introduction
This document describes how to add/run the unit tests for testing out the simple register
package.

Each unit test is derived from the base class *srm_unit_test*. This has a virtual method *run*
that the derived class must override. 
```
  virtual task run();
    assert(!"Derived class must override this");
  endtask

```

Also there are 2 other optional methods "setup" and "teardown" that can also be overridden.
```

  virtual function void setup();
  endfunction

  virtual function void teardown();
  endfunction

```

Inside the *run* method, the derived class, runs each of the different tests using the macro 'RUN_TEST'.  
By convention, I call each of the test methods as "test_". Before invoking each of the methods, the framework will call the *setup*, and then call *teardown* at the end.

Currently, I use a script *srun* to run the unit tests. This is written in Ruby and so you
need to have ruby (>2.0) installed in your env. You may need to install additional ruby gem
like "Rainbow" which produces colored console messages.

# Setup Env

Neeed to set the envrionment variable *SRM_ROOT* to the current directory and 
add the path the to script directory. Note for users with just the distrib
we use the *SRM_HOME* to point to the root directory.

In bash
```
export SRM_ROOT=`pwd`
export PATH=$PATH:$SRM_ROOT/scripts
```

In Csh
```
setenv SRM_ROOT `pwd`
set path = ( $path $SRM_ROOT/bin )
```

Try running. May require additonal ruby packages like "Rainbow".
```
srun -h
Usage: srun -f <sim.cfile> -t <testname>
    -f, --file SIMFILE               Require the path to the simulation control file
    -t, --testname TEST              Require the name of the uvm top level test to run
    -u, --unit_test TEST             Optional name of the unit test to run
    -o, --out output_dir             output directory to create the build and run dir.
    -l, --log logfile                test.log output file.

```

# Run Unit Tests

srun -f unit_tests/sim.cfiles 

This will create the run directory where the stdout.txt and stderr.txt holds the output of command.

## Run Individual Test

srun -f unit_tests/sim.cfiles -u <testname>


# Generate NaturalDocs
1. Setup SRM_HOME to the distrib directory. 
2. Run srm_ref/nd/gen_nd
```
setenv SRM_HOME `pwd`/distrib
cd srm_ref/nd
./gen_nd
cd $SRM_HOME
firefox SRM_Reference.html
```

