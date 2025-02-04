%% This function converts pixels to degrees
% width = 1920; %pixels
% height = 1200; %pixels
% ppi = 96; %pixels per inch

function [x_deg,y_deg,dva_center_x,dva_center_y] = pix2deg(x,y,width,height)

ppi = 96; %screen resolution in px per inch
width_px_to_mm = px2mm(width,ppi);
screen_width = width_px_to_mm * 0.1; %width in cm

screen_resolution  =  [width height];%[w h];                 % screen resolution
CM_per_inc = 2.54;
screen_distance = 34 * CM_per_inc; %cm
screen_angle  =  2*(180/pi)*(atan((screen_width/2) / screen_distance)) ; % total visual angle of screen
screen_ppd  =  screen_resolution(1) / screen_angle;  % pixels per degree
screen_fixposxy  =  screen_resolution .* [.5 .5]; % fixation position



% x_deg  =  (x-screen_fixposxy(1))/screen_ppd;
% y_deg  =  (y-screen_fixposxy(2))/screen_ppd;

x_deg  =  (x)/screen_ppd;
y_deg  =  (y)/screen_ppd;

dva_center_x = screen_fixposxy(1)/screen_ppd;
dva_center_y = screen_fixposxy(2)/screen_ppd;

