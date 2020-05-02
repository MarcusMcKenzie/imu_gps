#!/usr/bin/env python
import serial
import lcm
import time
import sys
import numpy as np

from sensorpackages import imu_t

class Imu(object):
	def __init__(self, port_name = "/dev/ttyUSB0"):
		self.port = serial.Serial(port_name,115200,timeout=1)
		self.lcm = lcm.LCM("udpm://?ttl=12")
		self.packet = imu_t()
		while True:
		    imu_line=self.port.readline()
		    imu_string=np.array(imu_line.split(','))
		   
		    if  imu_string[0]=='$VNYMR' :
			imu_string[imu_string=='']='0'
			print imu_string
		    	self.packet.yaw     =float(imu_string[1])
			self.packet.pitch	=float(imu_string[2])
			self.packet.roll 	=float(imu_string[3])
			self.packet.mag_x	=float(imu_string[4])
			self.packet.mag_y	=float(imu_string[5])
			self.packet.mag_z	=float(imu_string[6])
			self.packet.acc_x	=float(imu_string[7])
			self.packet.acc_y	=float(imu_string[8])
			self.packet.acc_z	=float(imu_string[9])
			self.packet.gyro_x_radps=float(imu_string[10])
			self.packet.gyro_y_radps=float(imu_string[11])
		    	imu12		=imu_string[12]	
			imusep		=np.array(imu12.split('*'))
			self.packet.gyro_z_radps=float(imusep[0])
			self.lcm.publish("IMU", self.packet.encode())
		pass

if __name__ == "__main__":
    if len(sys.argv) != 2: 
	myimu = Imu()
    else:
    	myimu = Imu(sys.argv[1])

