clear all;

javaaddpath /home/marcus/my_robot/my_types.jar 
javaaddpath /usr/local/share/java/lcm.jar

log_file = lcm.logging.Log('/home/marcus/my_robot/log/forsyth', 'r'); 


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


gps_data(~any(gps_data,2), :) = [];
imu_data(~any(imu_data,2), :) = [];  
gps_time = gps_data(:,1)/10^10;

d = 1:length(imu_data);

%5
%hard iron corrections
mag_z = imu_data(d,7);
xmax = max(imu_data(:,5)); %max of mag_x
xmin = min(imu_data(:,5)); %min of mag_x

ymax = max(imu_data(:,6)); %max of mag_y
ymin = min(imu_data(:,6)); %min of mag_y

alpha = (xmax + xmin)/2;
beta = (ymax + ymin)/2;

magx_hcorr = (imu_data(:,5) - alpha);
magy_hcorr = (imu_data(:,6) - beta);
mag_hcorr = [magx_hcorr magy_hcorr];

%soft iron corrections

x1 = .03915
y1 = .03575
x2 = .03365
y2 = -.03475

distance = sqrt((magx_hcorr(:,1)).^2 + (magy_hcorr(:,1)).^2);
max_distance = max(distance);
points = [magx_hcorr magy_hcorr distance];

rad = sqrt((x1)^2 + (y1)^2);
q = sqrt((x2)^2 + (y2)^2);
s = (q/rad);

theta = asin(y1/rad);

R = [cos(theta) sin(theta); -sin(theta) cos(theta)];
Rn = [cos(-theta) sin(-theta); -sin(-theta) cos(-theta)];

mag_scorr = mag_hcorr * R;
mag_scorrn(:,1) = (mag_scorr(:,1)/s);
mag_scorrn(:,2) = mag_scorr(:,2);

magscorrn = mag_scorrn *Rn;
mag_x = magscorrn(:,1);
mag_y = magscorrn(:,2);


%figure(1);
% plot(imu_mag_x(1:length(d)-2,1), imu_mag_y) before correction
%axis([-.20 0 .10 .30)]

%figure(2);
%plot(mag_x, mag_y)
%line(xlim, [0 0]);
%line(ylim, [0 0]);
%axis([-.06 .06 -.06 .06]);

%yaw angle calculations
yaw_mag_ang = (180*atan2(-mag_y, mag_x))/pi;
yaw_angle = cumtrapz(imu_data(d,13));
yaw_imu_ang = imu_data(d,2);

for i=1:length(magy_hcorr)-1
yaw_gyro_ang(i,1) = yaw_angle(i+1,1) - yaw_angle(i,1) ;
i = i + 1;
end
yaw_gyro_ang = yaw_gyro_ang*180/pi

%plot(yaw_mag_ang);
%figure(2)
%plot(yaw_acc_ang);

%calibrations-sensor fusion
c = .98;
dt = .001;
filter = 0;

for i=2:length(d)-1
filter(i,1) = c * (filter(i-1,1) + yaw_gyro_ang(i,1) * dt) + (1-c)*yaw_mag_ang(i,1);
i = i + 1;
end

%figure(3)
%plot(filter)

%6
%imu velocity
x_vels = 0;
y_vels = 0;
imu_vel = 0;
imu_vel2 = 0;
x_vel = 0;
y_vel = 0;
imu_xvel3 = 0;
imu_yvel3 = 0;
imu_acc_xs = imu_data(:,8);
imu_acc_ys = imu_data(:,9);

imu_acc_x = imu_acc_xs .*cos(yaw_imu_ang(:,1));
imu_acc_y = imu_acc_ys .*sin(yaw_imu_ang(:,1));

x_vels = cumtrapz(imu_acc_x +.17);
y_vels = cumtrapz(imu_acc_y);


for iii=2:length(d)-1
x_vel(iii,1) = (1-.98)*x_vels(iii,1) + .98*x_vel(iii-1,1);
y_vel(iii,1) = (1-.98)*y_vels(iii,1) + .98*y_vel(iii-1,1);
iii = iii + 1;
end


for i=2:length(d)-2
 imu_xvel(i,1) = x_vel(i+1,1) - x_vel(i,1);
 imu_xvel2(i,1) = imu_xvel(i-1) + imu_acc_x(i-1) +((imu_acc_x(i,1)-imu_acc_x(i-1))/2);
 imu_yvel(i,1) = y_vel(i+1,1) - y_vel(i,1);
 imu_yvel2(i,1) = imu_yvel(i-1) + imu_acc_y(i-1) +((imu_acc_y(i,1)-imu_acc_y(i-1))/2);
 i = i +1;
end



imu_vels = sqrt((imu_xvel2.^2 + imu_yvel2.^2)*15); 

for ii = 2:length(d)-2
imu_vel(ii,1) = (1-.99)*imu_vels(ii,1) + .99*imu_vel(ii-1,1);
ii = ii + 1;
end

%plot(imu_vel)

%gps velocity

gps_xvel = diff(gps_data(:,5));
gps_yvel = diff(gps_data(:,6));

gps_vels = sqrt(gps_xvel.^2 + gps_yvel.^2);
t = linspace(1,10,187);
ti = linspace(1, 10, 7469);
gps_vel(:,1) = interp1(t,gps_vels,ti);

plot(gps_vel)

%7ps
%imu displacement
%a.
imu_gyro_xvel = imu_data(:,11);
imu_gyro_yvel = imu_data(:,12);
imu_gyro_angvel = imu_data(:,13)*pi;

wX = imu_gyro_angvel(1:length(d)-2,1).*imu_xvel2(:,1);
%plot(wX)
%hold on

yobs = imu_acc_y(1:length(d)-2,1) %+ wX(:,1);
%figure(2)
%plot(yobs)

%b. 
imu_gyrox_accel = imu_data(1:length(d),12);
imu_mag_x = imu_data(1:length(d),5);
imu_mag_y = imu_data(1:length(d)-2,6);
xe=0; xn=0;

ve = imu_yvel2/15;
vn = imu_xvel2/15;
v = [ve(:,1), vn(:,1)];

ixe = cumtrapz(ve);
ixn = cumtrapz(vn);

for iii=2:length(d)-2
xe(iii,1) = (1-.98)*ixe(iii,1) + .98*xe(iii-1,1);
xn(iii,1) = (1-.98)*ixn(iii,1) + .98*xn(iii-1,1);
iii = iii + 1;
end


x = [xe, xn];
xmag = sqrt(ixe.^2 + ixn.^2);
%figure(1)
%plot(xe, xn);

gps_utmx = gps_data(:,5);
gps_utmy = gps_data(:,6); 
gps_xdisp = gps_utmx(:,1) - gps_utmx(1,1);
gps_ydisp = gps_utmy(:,1) - gps_utmy(1,1);


%figure(2)
%plot(gps_lat,gps_lon)

%7.3
xc = -.5;
imu_gyro_angacc = diff(imu_gyro_angvel);

xobs_calc = imu_acc_x(1:length(d)-2,1) - imu_gyro_angvel(1:length(d)-2,1).*imu_xvel - ((imu_gyro_angvel(1:length(d)-2,1).^2)*xc);
yobs_calc = imu_acc_y(1:length(d)-2,1) + imu_gyro_angvel(1:length(d)-2,1).*imu_yvel + (imu_gyro_angacc(1:length(d)-2,1)*xc);