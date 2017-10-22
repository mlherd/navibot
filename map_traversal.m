clear all; clc;
addpath('./ScreenCapture/');

esp_url = 'http://192.168.43.236/';

%% Wifi commands
botreset = [esp_url '?txval=0'];
l_blink_on = [esp_url '?txval=1'];
r_blink_on = [esp_url '?txval=2'];
l_blink_off = [esp_url '?txval=3'];
r_blink_off = [esp_url '?txval=4'];
l0r0 = [esp_url '?txval=5'];
l0r1 = [esp_url '?txval=6'];
l1r0 = [esp_url '?txval=7'];
l1r1 = [esp_url '?txval=8'];
blinkers_on = [esp_url '?txval=9'];
blinkers_off = [esp_url '?txval=0'];
full_mtr_l = [esp_url '?txval=L'];
full_mtr_r = [esp_url '?txval=R'];


%% Tes wifi link
send2esp8266(botreset);
send2esp8266(l_blink_on);
send2esp8266(r_blink_on);
pause(5);
send2esp8266(l_blink_off);
send2esp8266(r_blink_off);

%% Image capture
close all;
ii = 1; 
[init_mth init_lth init_rth] = get_img_threshold(ii);
send2esp8266(l1r1);
save_th(ii) = init_mth;
stopFlag = 0;

while(~stopFlag)
    ii = ii + 1;
    [new_mth new_lth new_rth] = get_img_threshold(ii);
    save_th(ii) = new_mth;
    if(~isnan(new_lth))
        fprintf(1,'Saw a left..\n');
        %send2esp8266(l0r0);
        %send2esp8266(l_blink_on);
        %stopFlag = 1;
    end
    if(~isnan(new_rth))
        fprintf(1,'Saw a right..\n');
        %send2esp8266(l0r0);
        %send2esp8266(r_blink_on);
        %stopFlag = 1;
    end
    if((new_mth - init_mth) > 30)
        fprintf(1,'Turning left ..\n');
        send2esp8266(full_mtr_l);
%         pause(0.2);
%                 send2esp8266(l1r0);

    end
    if((init_mth - new_mth) > 10)
       
        fprintf(1,'Turning right ..\n');
        send2esp8266(full_mtr_r); 
%         pause(0.2);
%         send2esp8266(l0r1);
    end
    pause(0.5);
    send2esp8266(l1r1);
    stopFlag = (~isnan(new_lth)) && (~isnan(new_rth));
fprintf(1,'ii=%d : %d %d %d\n',ii,new_mth,new_lth,new_rth);
end

% plot(save_th);
% plot(act)
send2esp8266(l0r0);
