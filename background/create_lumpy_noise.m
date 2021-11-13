function [img_lp,wn]=create_lumpy_noise(row, col, s, noise_mean, sta_dev)
% ---
% Operation: create lumpy noise from (Rolland, 1992)
% Input:
% - row: pixels of the image row (to be even) 
% - col: pixels of the image column (to be even)
% - s: a decay parameter in the Fourier spectrum
% - noise_mean: the mean of the noise
% - sta_dev: the standard deviation of the noise
% Output:
% - img_lp: lumpy noise
% - wn: related white noise
% Note:
% - reference: Rolland, J. P., and Harrison H. Barrett. "Effect of random background inhomogeneity on observer detection performance." JOSA A 9.5 (1992): 649-658.
% ---

% creates a square image of lumpy noise of given size
% 
% please let row and col be even!

if ~exist('noise_mean','var')
    noise_mean = 0;
end

if ~exist('sta_dev','var')
    sta_dev = 1;
end

% create lumpy Fourier filter.
fil_lp = ones(row, col);
for i=1:row
    for j=1:col
        z=norm([i-row/2-1,j-col/2-1]);
        if z  % leave fft origin at 1
            fil_lp(i,j) = exp(-(pi*s*z)^2);
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
wnf_fil = fil_lp.*wnf;

% ifftshift to first shift back the fourier transform
% to have 0-frequency at the start again. This lets
% ifft2 do inverse Fourier transform correctly:
img_lp = ifft2(ifftshift(wnf_fil));

img_lp = img_lp - mean2(img_lp);
img_lp = img_lp / std2(img_lp)* sta_dev + noise_mean;