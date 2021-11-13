function [img_cn, sigma]= contrast_normalize_dichotomy_bound(img, s, dev)
% ---
% Operation: normalize the contrast of the image knowing contrast, regions and boundary
% Input:
% - img: input image
% - s: standard deviation in the left and right part of the image
% - dev: deviation of the region boundary relative to the center
% Output:
% - img_cn: contrast normalized image
% - sigma: standard deviation matrix
% Note:
% ---

%divide the area by half
col=size(img,2);
half=floor(col/2);
sigma=ones(col,col);

if size(s,1) == 1 && size(s,2) == 2  %two_sigmas
    sigma_left = s(1);
    sigma_right = s(2);
    sigma(:,1:half+dev)=sigma_left;
    sigma(:,half+dev+1:col)=sigma_right;
else
    error('No specific action!');
end

img_cn=img./sigma;
end
