function [img_whiten,filter]=pink_to_white(img, DC)
% ---
% Operation: whitens a 1/f image back to a white image
% Input:
% - img: the image to be whitened
% - DC: the boost of the mean of the image
% Output:
% - img_whiten: the whitened image
% - filter: the whitening filter
% Note:
% ---

if ~exist('DC','var')
    DC = 1;
end
    
[row,col]=size(img);

filter=ones(row,col);

for i=1:row
    for j=1:col
        z = norm([i-row/2-1,j-col/2-1]);
        if z
            filter(i,j) = z;
        else
            filter(i,j) = DC;
        end
    end
end
    
img_whiten=ifft2(ifftshift(filter.*fftshift(fft2(img))));
end