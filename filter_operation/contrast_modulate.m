function img_cm=contrast_modulate(img,scale)
% ---
% Operation: modulate the contrast of an image over space
% Input:
% - img: input image
% - scale: square root of the overall contrast ratio
% Output:
% - img_cm: contrast-modulated image
% Note:
% ---

col_num=size(img,2);
half=floor(col_num/2);

img_mean = mean(img(:));
img = img - img_mean;
left = img(:,1:half);
right = img(:,(half+1):col_num);
img_cm = [(1.0/scale).*left,scale.*right];
img_cm = img_cm * sqrt(2/(scale^2+1/(scale^2)));
img_cm = img_cm + img_mean;
end