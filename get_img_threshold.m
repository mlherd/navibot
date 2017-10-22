function [mid_th,left_th,right_th] = get_img_threshold(ii);
clrdata = screencapture(0,  [0,80,600,80+380]);
imgdata = im2bw(rgb2gray(clrdata));

mid_img = imgdata(300:400,50:550);
left_img = imgdata(50:150,50:100);
right_img = imgdata(50:150,500:550);

% imgdata(300:400,50:550) = false; %-- useful for mid
% imgdata(50:150,50:150) = false; %-- useful for left
% imgdata(50:150,450:550) = false; %-- useful for right

%%
imshow(imgdata);
hold on;
w(1,1:4) = [50 300 500 100];     %mid
w(2,1:4) = [50 50 50 100];  %left
w(3,1:4) = [500 50 50 100];   %right
for ii=1:3
rectangle('Position',w(ii,:));
end
movegui(gcf, 'southeast');

%%
% mid_th = mean([mean(find(mid_img(1,:) == 0)) mean(find(mid_img(1,:) == 0))]);
mid_th = mean([min(find(mid_img(1,:) == 0)) max(find(mid_img(1,:) == 0))]);

for ii=1:10
    lth(ii) = mean(find(left_img(55+ii,:) == 0));
end
left_th = mean(lth);

for ii=1:5
    rth(ii) = mean(find(right_img(89+ii,:) == 0));
end
right_th = mean(rth);
str = sprintf('ii=%d,M=%d,L=%d,R=%d',ii,mid_th,left_th,right_th);
text(50,50,str);
% saveas(gcf,['imgdata\file_' num2str(ii) '.png']);
%imwrite(midpart,['imgdata/' 'file_' num2str(ii) '.bmp'],'bmp');

%in mid window


%  t1 = rgb2gray(clrdata);
%  imshow(im2bw(t1))

% malized','paperposition',[0.25 2.5 8 6]);
% midpart = imgdata(300:400,50:500); 
% imshow(midpart);
%midpart = imgdata(imgwin,200:600); 
% imwrite(midpart,['imgdata/' 'file_' num2str(ii) '.bmp'],'bmp');
% subplot(1,2,1), imshow(infront); xlim([0 100]); ylim([0 550]);
% subplot(1,2,2), imshow(midpart); xlim([0 100]); ylim([0 550]);
% topmin = min(find(midpart(1,:) == 0));
% botmax = max(find(midpart(end,:) == 0));
% th = mean([topmin botmax]);

