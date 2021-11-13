function mask = crop_patch_mask(i_row, i_col, t_row, t_col, dist, radius)
% ---
% Operation: generate a circular binary mask according to 2D uniform or normal distribution
% Input:
% - i_row: pixel length of the row of the whole image
% - i_col: pixel length of the column of the whole image
% - t_row: pixel length of the row of the target region
% - t_col: pixel length of the column of the target
% - dist: type of the distribution
% - radius: radius of considered mask region
% Output:
% - mask: the binary mask
% Note:
% ---


mask = zeros(i_row, i_col);

if strcmp(dist, 'uniform')
    for i=t_row/2:i_row-t_row/2
        for j=t_col/2:i_col-t_col/2
            z2=(i-i_row/2-1)^2+(j-i_col/2-1)^2;
            if z2 < radius^2
                mask(i,j)=1;
            end
        end
    end
elseif strcmp(dist, 'normal')
    for i=t_row/2:i_row-t_row/2
        for j=t_col/2:i_col-t_col/2
            z2=(i-i_row/2-1)^2+(j-i_col/2-1)^2;
            if rand < 0.5*exp(-0.5*z2/(radius^2))
                mask(i,j)=1;
            end
        end
    end
end
