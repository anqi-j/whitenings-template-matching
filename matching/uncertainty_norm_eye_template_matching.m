function responses= uncertainty_norm_eye_template_matching(tar,images,presence,mask,window,radius,d,w)
% ---
% Operation: UERTM model
% Input:
% - tar: the target
% - images: the background
% - presence: target present (1) or target absent (0)
% - mask: the binary mask repsenting the positional uncertainty
% - window: window shape used to estimate local contrast, or not used during the normalization
% - radius: radius of the window, or standard deviation of regions in the image
% - d: the diameter of the pupil
% - w: the wavelength of the stimulus
% Output:
% - response: decision variable responses
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



%there is no target on the image
if presence==0
    parfor i=1:len
        images_i = squeeze(images(:,:,i,1));
        for j=1:L_centers
            [center_x, center_y] = ind2sub([row,col],img_centers(j));
            img=images_i(center_x-t_row/2+1:center_x+t_row/2,center_y-t_col/2+1:center_y+t_col/2);
            dev_col = col/2-center_y;
            [mutant_img,sigma]=contrast_normalize(eye_filter(img,d, w),window,radius, dev_col);
            mutant_template=template./sigma;
            responses_matrix(i,j) = dot(mutant_template(:),mutant_img(:));
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
            dev_col = col/2-center_y;
            [mutant_img,sigma]=contrast_normalize(eye_filter(img,d, w),window,radius, dev_col);
            mutant_template=template./sigma;
            responses_matrix(i,j) = dot(mutant_template(:),mutant_img(:));
        end
    end
end

responses = max(responses_matrix,[],2);

end