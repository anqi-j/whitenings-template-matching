function [responses,two_sigmas,line_sigmas] = uncertainty_eye_template_matching(tar,images,presence, mask, d, w)
% ---
% Operation: UETM model
% Input:
% - tar: the target
% - images: the background
% - presence: target present (1) or target absent (0)
% - mask: the binary mask repsenting the positional uncertainty
% - d: the diameter of the pupil
% - w: the wavelength of the stimulus
% Output:
% - response: decision variable responses
% - two_sigmas: the standard deviation on the left and right
% - line_sigmas: the standard deviation assuming vertical homogeneity
% Note:
% ---

%initialization
[row, col, len,~] = size(images);
[t_row, t_col] = size(tar);
template = tar - mean(tar(:));
template = template / norm(template, 'fro');
template = eye_filter(template, d, w);

% wear mask
img_centers = find(mask==1);
L_centers = length(img_centers);
responses_matrix=zeros(len,length(img_centers));

img_sigmas = zeros(t_row, t_col, len);

%there is no target on the image
if presence==0
    parfor i=1:len
        images_i = squeeze(images(:,:,i,1));
        for j=1:L_centers
            [center_x, center_y] = ind2sub([row,col],img_centers(j));
            img=images_i(center_x-t_row/2+1:center_x+t_row/2,center_y-t_col/2+1:center_y+t_col/2);
            mutant_img=eye_filter(img,d, w);
            responses_matrix(i,j) = sum(dot(template,mutant_img));
            img_sigmas(:,:,i) = mutant_img;
        end
    end
else
%there is the target on the image
    parfor i=1:len
        for j=1:L_centers
            [center_x, center_y] = ind2sub([row,col],img_centers(j));
            img_tar = squeeze(images(:,:,i,2));
            img_tar((row-t_row)/2+1:(row+t_row)/2,(col-t_col)/2+1:(col+t_col)/2)=...
                img_tar((row-t_row)/2+1:(row+t_row)/2,(col-t_col)/2+1:(col+t_col)/2)+tar;
            img=img_tar(center_x-t_row/2+1:center_x+t_row/2,center_y-t_col/2+1:center_y+t_col/2);
            mutant_img=eye_filter(img,d, w); %convolution linearity
            responses_matrix(i,j)= sum(dot(template,mutant_img));
            img_sigmas(:,:,i) = mutant_img;
        end
    end
end

responses = max(responses_matrix,[],2);

if nargout > 1
    two_sigmas = evaluate_two_sigmas(img_sigmas);
    line_sigmas = evaluate_line_sigmas(img_sigmas);
end

end