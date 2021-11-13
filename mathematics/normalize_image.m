function n_img =  normalize_image(image, img_mean, sta_dev)

if ~exist('img_mean','var')
    img_mean = 0;
end

if ~exist('sta_dev','var')
    sta_dev = 1;
end

n_img = image - mean(image, 'all');
n_img = n_img / std(n_img(:)) .* sta_dev + img_mean;