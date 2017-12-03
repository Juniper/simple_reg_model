# Test Unit Framework
This is a small test unit framework designed for testing the simple reg model package.

## Overview
The test writer creates test cases by creating a derived class from 'srm_unit_test'. The derived test
class then overwrites the 'run' method and registers all the test cases. If required, *setup* and *teardown* methods can also be overwritten. These are invoked by the framework before and after each test case.

To run the tests, a ruby script file 'gen_unit_tests' is used. This will create a 'main.sv' which instantiates all the tests and a 'Makefile' that will run the simulation.

## Assumptions
The framework assumes that each test case is in a file called *test*.sv which has a class of the same name.
