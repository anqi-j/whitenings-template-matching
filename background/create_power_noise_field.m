function [img_pp,wn]=create_power_noise_field(row, col, p, field_ratio, noise_mean, sta_dev)
% ---
% Operation: create 1/(f^p) noise with lower frequencies removed
% Input:
% - row: pixels of the patch row (to be even) 
% - col: pixels of the patch column (to be even)
% - p: power parameter in the Fourier spectrum
% - field_ratio: threshold to cut off lower frequencies
% - noise_mean: the mean of the noise
% - sta_dev: the standard deviation of the noise
% Output:
% - img_pp: 1/(f^p) noise (power noise)
% - wn: related white noise
% Note:
% - 
% ---

if ~exist('noise_mean','var')
    noise_mean = 0;
end

if ~exist('sta_dev','var')
    sta_dev = 1;
end

% create 1/f Fourier filter.
fil_pp = ones(row, col);
for i=1:row
    for j=1:col
        z=norm([i-row/2-1,j-col/2-1]);
        if z  % leave fft origin at 1
            if z >= field_ratio
                fil_pp(i,j) = z^(-p);
            else
                fil_pp(i,j) = 0;
            end
        end
    end
end
% white noise image:
wn = normrnd(0,1,[row, col]);

% Fourier transform image, then fftshift to shift 0-frequency
% to the center of the image, to align with 1/f filter whose
% 0-frequency is also at the center. Otherwise multiplying
% them together will not multiply corresponding elements.
wnf = fftshift(fft2(wn));

% multiply with 1/f filter
wnf_fil = fil_pp.*wnf;

% ifftshift to first shift back the fourier transform
% to have 0-frequency at the start again. This lets
% ifft2 do inverse Fourier transform correctly:
img_pp = ifft2(ifftshift(wnf_fil));

img_pp = img_pp - mean2(img_pp);
img_pp = img_pp / std2(img_pp) * sta_dev + noise_mean;