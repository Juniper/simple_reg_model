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
setenv PATH $PATH:$SRM_ROOT/bin
```

Try running. May require additonal ruby packages like "Rainbow".
```
srun -h
```

# Run Unit Tests

srun -f unit_tests/sim.cfiles 

This will create the run directory where the stdout.txt and stderr.txt holds the output of command.

## Run Individual Test

srun -f unit_tests/sim.cfiles -u <testname>
