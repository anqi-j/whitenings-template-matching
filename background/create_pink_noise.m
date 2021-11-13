function [img_1f,fil_1f]=create_pink_noise(row, col, noise_mean, sta_dev)
% ---
% Operation: create 1/f noise
% Input:
% - row: pixels of the patch row (to be even) 
% - col: pixels of the patch column (to be even)
% - noise_mean: the mean of the noise
% - sta_dev: the standard deviation of the noise
% Output:
% - img_1f: 1/f noise
% - fil_1f: 1/f filter
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
fil_1f = ones(row, col);
for i=1:row
    for j=1:col
        z=norm([i-row/2-1,j-col/2-1]);
        if z  % leave fft origin at 1
            fil_1f(i,j) = 1/z;
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
wnf_fil = fil_1f.*wnf;

% ifftshift to first shift back the fourier transform
% to have 0-frequency at the start again. This lets
% ifft2 do inverse Fourier transform correctly:
img_1f = ifft2(ifftshift(wnf_fil));

img_1f = img_1f - mean2(img_1f);
img_1f = img_1f / std2(img_1f) * sta_dev + noise_mean;