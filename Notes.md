# Setup Env

Neeed to set the envrionment variable *SRM_ROOT* to the current directory and 
add the path the to scripts in bin directory. Note for users with just the distrib
we use the *SRM_HOME* to point to the root directory.

In bash
```
export SRM_ROOT=`pwd`
export PATH=$PATH:$SRM_ROOT/bin
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

