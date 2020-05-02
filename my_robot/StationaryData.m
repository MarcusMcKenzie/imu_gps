%Stationary_Lot
clear all;

javaaddpath /home/marcus/my_robot/my_types.jar 
javaaddpath /usr/local/share/java/lcm.jar

log_file = lcm.logging.Log('/home/marcus/my_robot/log/a', 'r'); 


while true
 try
   
   for i=1:10000 
    ev = log_file.readNext();
   
   if strcmp(ev.channel, 'IMU')
        
        imu = sensorpackages.imu_t(ev.data);
        
        imu_time(i,1) = imu.utime;    
        imu_yaw(i,1) = imu.yaw; % (timestamp in microseconds since the epoch)
        imu_pitch(i,1) = imu.pitch;
        imu_roll(i,1) = imu.roll;
        imu_mag_x(i,1) = imu.mag_x;
        imu_mag_y(i,1) = imu.mag_y;
        imu_mag_z(i,1) = imu.mag_z;
        imu_acc_x(i,1) = imu.acc_x;
        imu_acc_y(i,1) = imu.acc_y;
        imu_acc_z(i,1) = imu.acc_z;
        imu_gyro_x(i,1) = imu.gyro_x_radps;
        imu_gyro_y(i,1) = imu.gyro_y_radps;
        imu_gyro_z(i,1) = imu.gyro_z_radps;
               
   end   
   
    end
  catch err   % exception will be thrown when you hit end of file
     break;
  end
end

figure
subplot(3,1,1)
plot(imu_acc_x)
title('Accelerometer Time-Series - x-axis')
xlabel('time(s)')
ylabel('Acceleration(m/s^2)')

subplot(3,1,2)
plot(imu_acc_y)
title('Accelerometer Time-Series - y-axis')
xlabel('time(s)')
ylabel('Acceleration(m/s^2)')

subplot(3,1,3)
plot(imu_acc_z)
title('Accelerometer Time-Series - z-axis')
xlabel('time(s)')
ylabel('Acceleration(m/s^2)')


figure
subplot(3,1,1);
plot(imu_gyro_x);
title('Gyroscope Time-Series - x-axis')
xlabel('time(s)')
ylabel('Angular Velocity(rad/s)')

subplot(3,1,2);
plot(imu_gyro_y);
title('Gyroscope Time-Series - y-axis')
xlabel('time(s)')
ylabel('Angular Velocity(rad/s)')

subplot(3,1,3);
plot(imu_gyro_z);
title('Gyroscope Time-Series - z-axis')
xlabel('time(s)')
ylabel('Angular Velocity(rad/s)')


figure
subplot(3,1,1);
plot(imu_mag_x);
title('Magnetometer Time-Series - x-axis')
xlabel('time(s)')
ylabel('Magnetic Field(Gauss)')

subplot(3,1,2);
plot(imu_mag_y);
title('Magnetometer Time-Series - y-axis')
xlabel('time(s)')
ylabel('Magnetic Field(Gauss)')

subplot(3,1,3);
plot(imu_mag_z);
title('Magnetometer Time-Series - z-axis')
xlabel('time(s)')
ylabel('Magnetic Field(Gauss)')