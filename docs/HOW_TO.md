# Setup
This describes how to naviagate around in the source code.

## Running Tests
1. Setup the env.
```
source setup.csh
```
2. Use *srun* for running the tests.
```
srun -h
Usage: srun -f <sim.cfile> -t <testname>
    -f, --file SIMFILE               Require the path to the simulation control file
    -t, --testname TEST              Require the name of the uvm top level test to run
    -u, --unit_test TEST             Optional name of the unit test to run
    -o, --out output_dir             output directory to create the build and run dir.
    -l, --log logfile                test.log output file.
```
3. Run the regression suite.
```
srun -f unit_tests/sim.cfiles
< Runs verilog unit tests>


SRUN_TEST_PASS:PassCnt=293
```
