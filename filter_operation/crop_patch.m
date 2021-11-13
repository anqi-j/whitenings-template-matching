function patch = crop_patch(image, row, col, n)
% ---
% Operation: crop n patches randomly out of an image
% Input:
% - image: the image to crop
% - row: the pixel length of the row of each patch
% - col: the pixel length of the column of each patch
% - n: the number of patches
% Output:
% - patch: n patches
% Note:
% ---

[crow, ccol] = size(image);

patch = zeros(row, col, n);

for i = 1:n
    center_x = randi(crow-row)+row/2;
    center_y = randi(ccol-col)+col/2;
    patch(:,:,i) = image(center_x - row/2 : center_x + row/2 -1,...
        center_y -col/2 : center_y + col/2 -1);
end