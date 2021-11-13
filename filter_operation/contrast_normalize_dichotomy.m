function [img_cn, sigma, sigma_left, sigma_right]= contrast_normalize_dichotomy(img, s)
% ---
% Operation: normalize the contrast of the image knowing contrast and regions
% Input:
% - img: input image
% - s: standard deviation in the left and right part of the image
% Output:
% - img_cn: contrast normalized image
% - sigma: standard deviation matrix
% Note:
% ---

%divide the area by half
row=size(img,1);
col=size(img,2);
half=floor(col/2);
sigma=ones(col,col);

img_mean = mean(img(:));
img = img - img_mean;

if size(s,1) == 1 && size(s,2) == 1 %real time estimation
    sigma_left = std2(img(:,1:half));
    sigma_right = std2(img(:,half+1:col));
    sigma_all = std2(img);
    sigma(:,1:half)=sigma_left/sigma_all;
    sigma(:,half+1:col)=sigma_right/sigma_all;
elseif size(s,1) == 1 && size(s,2) == 2  %two_sigmas
    sigma_left = s(1);
    sigma_right = s(2);
    sigma(:,1:half)=sigma_left;
    sigma(:,half+1:col)=sigma_right;
elseif size(s,1) == 1 && size(s,2) == col %line_sigmas
    sigma = repmat(s, row, 1);
else
    error('No specific action!');
end

img_cn=img./sigma + img_mean;
end
