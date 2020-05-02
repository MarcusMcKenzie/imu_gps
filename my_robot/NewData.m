%New Data
clear all;

javaaddpath /home/marcus/my_robot/my_types.jar 
javaaddpath /usr/local/share/java/lcm.jar

log_file = lcm.logging.Log('/home/marcus/my_robot/log/new_a', 'r'); 


while true
 try
   
   for i=1:10000 
    ev = log_file.readNext();
   
    if strcmp(ev.channel, 'GPS')
        
        gps = sensorpackages.gps_t(ev.data);
        
        gps_data(i,1) = gps.utime;
        gps_data(i,2) = gps.latitude;
        gps_data(i,3) = gps.longitude;
        gps_data(i,4) = gps.altitude;
        gps_data(i,5) = gps.utm_x;
        gps_data(i,6) = gps.utm_y;
        
   end
   
   if strcmp(ev.channel, 'IMU')
        
        imu = sensorpackages.imu_t(ev.data);
        
        imu_data(i,1) = imu.utime;    
        imu_data(i,2) = imu.yaw; % (timestamp in microseconds since the epoch)
        imu_data(i,3) = imu.pitch;
        imu_data(i,4) = imu.roll;
        imu_data(i,5) = imu.mag_x;
        imu_data(i,6) = imu.mag_y;
        imu_data(i,7) = imu.mag_z;
        imu_data(i,8) = imu.acc_x;
        imu_data(i,9) = imu.acc_y;
        imu_data(i,10) = imu.acc_z;
        imu_data(i,11) = imu.gyro_x_radps;
        imu_data(i,12) = imu.gyro_y_radps;
        imu_data(i,13) = imu.gyro_z_radps;
               
        end    
   
    end
  catch err   % exception will be thrown when you hit end of file
     break;
  end
end

