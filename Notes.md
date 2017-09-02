# Setup Env

source setup.csh 

This will setup the SRM_ROOT to point to the current working dir.

# Run Unit Tests

srun -f unit_tests/sim.cfiles 

This will create the run directory where the stdout.txt and stderr.txt holds the output of command.

## Run Individual Test

srun -f unit_tests/sim.cfiles -u <testname>
