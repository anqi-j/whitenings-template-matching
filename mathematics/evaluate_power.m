function [power,x,y] = evaluate_power(imgs, replication)

if ~exist('replication', 'var')
    replication = 0;
end

if replication == 0
    images = imgs;
elseif replication == 1
    images = zeros(size(imgs,1)*2,size(imgs,2)*2,size(imgs,3));
    for i=1:size(imgs,3)
        img = imgs(:,:,i);
        images(:,:,i) = double_mirror(img);
    end
end

[row, col, len] = size(images);
powers = zeros(len,1);
z = zeros(row, col);

for i = 1:row
    for j = 1:col
        z(i,j) = norm([i-row/2-1,j-col/2-1]);
    end
end

x = unique(z);

if x(1) == 0
    x(1)=[];
end

x(1)=[];
x(x>min(size(imgs,1),size(imgs,2))/2)=[];

y = zeros(length(x),1);
    
for n=1:len
    f_img = abs(fftshift(fft2(images(:,:,n))));
    for l=1:length(x)
        y(l) = mean(f_img(z==x(l)),'all');
    end
    k = polyfit(log(x(y~=0)),log(y(y~=0)),1);
    powers(n) = -k(1);
end

power = mean(powers);

