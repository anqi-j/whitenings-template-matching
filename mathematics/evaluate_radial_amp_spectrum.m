function [freq, amp] = evaluate_radial_amp_spectrum(img, replication)

if ~exist('replication', 'var')
    replication = 0;
end

if replication == 0
    image = img;
elseif replication == 1
    image = double_mirror(img);
end

[row, col] = size(image);


z = zeros(row, col);
for i = 1:row
    for j = 1:col
        z(i,j) = norm([i-row/2-1,j-col/2-1]);
    end
end
freq = unique(z);

if freq(1) == 0
    freq(1)=[];
end

freq(1)=[];
freq(freq>min(size(img,1),size(img,2))/2)=[];

amp = zeros(length(freq),1);
f_image = fftshift(fft2(image));

for i=1:length(freq)
    amp(i) = mean(f_image(z==freq(i)),'all');
end

