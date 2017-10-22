clear all; clc;
addpath('./ScreenCapture/');

%%Enter 192.168.43.133 into IP entry in APP

%% Wifi commands
esp_url = 'http://192.168.43.236/';
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
% send2esp8266(botreset);
% send2esp8266(l_blink_on);
% send2esp8266(r_blink_on);
% pause(5);
% send2esp8266(l_blink_off);
% send2esp8266(r_blink_off);

%% Get sensors
instrreset
UDPComIn=udp('192.168.43.133','LocalPort',12345);
set(UDPComIn,'DatagramTerminateMode','off')
fopen(UDPComIn);
while 1
    data=fscanf(UDPComIn);
    flds = regexp(data,',','split');
    s_f = str2num(flds{5});
    l_r = str2num(flds{6});
    act = 0;
    if(l_r < -45)
        act = 1;
        fprintf(1,'Left\n');
        send2esp8266(full_mtr_l);
    end
    if(l_r > 45)
        act = 1;
        fprintf(1,'Right\n');
        send2esp8266(full_mtr_r);
    end
    if((abs(s_f) < 15) && (act ==0))
        fprintf(1,'Forward\n');
        send2esp8266(l1r1);
    end
    if((abs(s_f) > 60) && (act ==0))
        fprintf(1,'Stop\n');
        send2esp8266(l0r0);
    end

    pause(0.05);
    %disp(data)
end
fclose(UDPComIn);
delete(UDPComIn)
