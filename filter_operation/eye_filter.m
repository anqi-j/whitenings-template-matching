function [img_ef, eye_filter] = eye_filter(img,d,w)
% ---
% Operation: filter the image with an eye filter
% Input:
% - img: the image to filter
% - d: the pupil diameter
% - w: the wavelength of the image
% Output:
% - img_ef: the image filtered with the eye filter
% - eye_filter: the eye filter used
% Note:
% ---

[row,col]=size(img);

if row~=col
    error("It's not a square matrix!");
end

x = ones(row, col);
for i=1:row
    for j=1:col
        x(i,j)=norm([i-row/2-1,j-col/2-1]);
    end
end

parameters = zeros(1,4);
parameters(1) = 0.85;
parameters(2) = 0.15;
parameters(3) = 2;
parameters(4) = 0.065;

ppd = 60;
eye_filter = CSF_cpi(x, row, ppd, d, w, parameters);
eye_filter = eye_filter / max(eye_filter(:));

img_ef=ifft2(ifftshift(eye_filter.*fftshift(fft2(img))));
end