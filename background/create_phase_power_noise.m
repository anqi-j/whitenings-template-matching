function [img_pp,wn]=create_phase_power_noise(row, col, p, phase)
% ---
% Operation: create 1/(f^p) noise with phase selected
% Input:
% - row: pixels of the image row (to be even) 
% - col: pixels of the image column (to be even)
% - p: power parameter in the Fourier spectrum
% - phase: the selected phase ([0, 2*pi])
% Output:
% - img_pp: power noise with phase selected (mean of 0 and standard deviation of 1)
% - wn: related white noise
% Note:
% - 
% ---

% create 1/f Fourier filter with phase
fil_pp = zeros(row, col);
for i=1:row
    for j=1:col
        if norm([i-row/2-1,j-col/2-1])==0
            fil_pp(i,j) = 1;% leave fft origin at 1
        else
            if j-col/2-1 > 0
                   angle = atan((i-row/2-1)/(j-col/2-1));
            elseif j-col/2-1 == 0
                if i-row/2-1>0 ,angle = pi/2;else ,angle = -pi/2;end
            else
                angle = atan((i-row/2-1)/(j-col/2-1))+pi;
            end
            
            if phase > 3*pi/2 && phase <= 2*pi
                if (angle < phase - 2*pi) || (angle >= phase - pi/2)
                    fil_pp(i,j) = norm([i-row/2-1,j-col/2-1])^(-p);
                end
            elseif phase < 0 && phase >= -pi/2
                if (angle < phase) || (angle >= phase + 3*pi/2)
                    fil_pp(i,j) = norm([i-row/2-1,j-col/2-1])^(-p);
                end
            else
                if angle>=phase-pi/2 && angle < phase
                    fil_pp(i,j) = norm([i-row/2-1,j-col/2-1])^(-p);
                end
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

% ifftshift to first shift back the fourier transform
% to have 0-frequency at the start again. This lets
% ifft2 do inverse Fourier transform correctly:
img_pp = abs(ifft2(ifftshift(fil_pp.*wnf)));

img_pp = img_pp - mean2(img_pp);
img_pp = img_pp / std2(img_pp); % make std to 1