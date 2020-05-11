# imu_gps

### Required
* LCM
* GPS

### Installing LCM
download lcm-1.2.1    	

cd ~/lcm-1.2.1	      	# Goto the directory
sudo ./configure      	# note we will use sudo so that executables are installed properly
sudo make
sudo make install
sudo ldconfig

cd test/python	      	# Now you can do some simple tests to see that the install is fine
make 
./lcm_file_test.py   	

cd ~/lcm-1.2.1       

cd examples/python   	
more ../types/example_t.lcm  	

more gen-types.sh    	
./gen-types.sh       
ls		     
ls exlcm	     		
more exlcm/example_t.py   
     		     
python listener.py &   	
python send-message.py & 	

 cd ../lcm-spy/	       	

 more runspy.sh      	
 ./buildjar.sh	      
 ./runspy.sh		

### LCM Setup
```
#/usr/bin/env bash
#sudo chmod 666 /dev/ttyUSB0
export CLASSPATH=$PWD

lcm-logger -s ./log/lcm-log-%F-%T &
lcm-spy & 

./imu_xsens /dev/ttyUSB0

kill %1 %2  # %3  %4 %5 %6 %7 %8 %9
```
### References
```
lcm-spy: https://linux.die.net/man/1/lcm-spy
lcm-gen: https://linux.die.net/man/1/lcm-gen
lcm-logger: https://linux.die.net/man/1/lcm-logger
lcm-logplayer: https://linux.die.net/man/1/lcm-logplayer
```

## Results
