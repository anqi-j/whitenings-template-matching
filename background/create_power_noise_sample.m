function img = create_power_noise_sample(row, col, crow, ccol, n, p, noise_mean, sta_dev)
% ---
% Operation: extract 1/(f^p) noise patches from a larger 1/(f^p) field
% Input:
% - row: pixels of the patch row (to be even) 
% - col: pixels of the patch column (to be even)
% - crow: pixels of the field row (to be even and larger than row) 
% - ccol: pixels of the field column (to be even and larger than col)
% - n: numbers of patches selected
% - p: power parameter in the Fourier spectrum
% - noise_mean: the mean of the noise
% - sta_dev: the standard deviation of the noise
% Output:
% - img: a list (last 1 dimension) of 1/(f^p) noise patches (first 2 dimensions)
% Note:
% - 
% ---

if ~exist('p','var') 
    p=1;
end

if ~exist('cp','var')
    cp=0;
end

if ~exist('cb','var')
    cb=1;
end

if row > crow || col > ccol
    error('infeasible!');
end

scene = create_power_noise(crow, ccol, p, noise_mean, sta_dev); % rms contrast = sta_dev/noise_mean

img = zeros(row, col, n);

for i = 1:n
    center_x = randi(crow-row)+row/2;
    center_y = randi(ccol-col)+col/2;
    img(:,:,i) = scene(center_x - row/2 : center_x + row/2 -1,...
        center_y -col/2 : center_y + col/2 -1);
end




