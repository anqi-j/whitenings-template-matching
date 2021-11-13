function [img_cn, sigma]= contrast_normalize_heuristic(img)
% ---
% Operation: normalize the contrast of the image by assuming the regions and estimating contrast per trial
% Input:
% - img: input image
% Output:
% - img_cn: contrast normalized image
% - sigma: standard deviation matrix
% Note:
% ---

%assume a heuristic strategy dealing with contrast-split background
%ignore the information on the high contrast side

%divide the area by half
col=size(img,2);
half=floor(col/2);

img_mean = mean(img(:));
img = img - img_mean;

sigma=zeros(col,col);
sigma_left = std2(img(:,1:half));
sigma_right = std2(img(:,half+1:col));

if sigma_left > sigma_right
    sigma_left = sigma_left * 1E8;
else
    sigma_right = sigma_right * 1E8;
end

sigma(:,1:half)=sigma_left;
sigma(:,half+1:col)=sigma_right;

img_cn=img./sigma + img_mean;
end
