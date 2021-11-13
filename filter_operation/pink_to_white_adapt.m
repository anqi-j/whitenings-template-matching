function img_whiten=pink_to_white_adapt(img, rev_func, power)
% ---
% Operation: whitens the image
% Input:
% - img: the image to be whitened
% - rev_function: a number for power exponent, or a matrix for extra filtering
% - power: the power exponent when including extra filtering
% Output:
% - img_whiten: the whitened image
% Note:
% ---

if ~exist('power','var')
    power = 0;
end

[row,col]=size(img);
filter = ones(row,col);

if size(rev_func,1) == 1 && size(rev_func,2) == 1 % if a number
    for i=1:row
        for j=1:col
            z= norm([i-row/2-1,j-col/2-1]);
            if z
                filter(i,j)=z^rev_func;
            end
        end
    end
    
elseif size(rev_func,1) == row && size(rev_func,2) == col % if a matrix
    for i=1:row
        for j=1:col
            z= norm([i-row/2-1,j-col/2-1]);
            if z
                filter(i,j)=z^power;
            end
        end
    end
    filter = rev_func .* filter;
end

img_whiten=ifft2(ifftshift(filter.*fftshift(fft2(img))));
end