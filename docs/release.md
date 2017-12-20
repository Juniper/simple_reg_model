1. Create a sandbox
```
  mkdir <sandbox>/srm-1.0
```

2. Generate the documentation.
```
source env/setup.bash
cd docs/nd
./gen_nd
```

3. Copy the distrib directory
```
cd ../../
cp -r distrib/* <sandbox>
tar cvfz srm-1.0.tar.gz *
mv srm-1.0.tar.gz <download_area>
```
