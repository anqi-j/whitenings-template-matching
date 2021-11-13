function img = create_pink_noise_sample(row, col, crow, ccol, n, noise_mean, sta_dev)
% ---
% Operation: extract 1/f noise patches from a larger 1/f field
% Input:
% - row: pixels of the patch row (to be even) 
% - col: pixels of the patch column (to be even)
% - crow: pixels of the field row (to be even and larger than row) 
% - ccol: pixels of the field column (to be even and larger than col)
% - n: numbers of patches selected
% - noise_mean: the mean of the noise
% - sta_dev: the standard deviation of the noise
% Output:
% - img: a list (last 1 dimension) of 1/f noise patches (first 2 dimensions)
% Note:
% - 
% ---

if row > crow || col > ccol
    error('infeasible!');
end

if ~exist('noise_mean','var')
    noise_mean=0;
end

if ~exist('sta_dev','var')
    sta_dev=1;
end

scene = create_pink_noise(crow, ccol, noise_mean, sta_dev); % rms contrast = sta_dev/noise_mean

img = zeros(row, col, n);

for i = 1:n
    center_x = randi(crow-row)+row/2;
    center_y = randi(ccol-col)+col/2;
    img(:,:,i) = scene(center_x - row/2 : center_x + row/2 -1,...
        center_y -col/2 : center_y + col/2 -1);
end




