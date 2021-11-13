function [responses,two_sigmas,line_sigmas] = eye_template_matching(tar,images,presence, d, w)
% ---
% Operation: ETM model
% Input:
% - tar: the target
% - images: the background
% - presence: target present (1) or target absent (0)
% - d: the diameter of the pupil
% - w: the wavelength of the stimulus
% Output:
% - response: decision variable responses
% - two_sigmas: the standard deviation on the left and right
% - line_sigmas: the standard deviation assuming vertical homogeneity
% Note:
% ---

%initialization
[row, col, length, ~] = size(images);
responses=zeros(length,1);
template = tar - mean(tar(:));
template = template / norm(template, 'fro');
template = eye_filter(template, d, w);
img_sigmas = zeros(row, col, length);

%there is no target on the image
if presence==0
    for i=1:length
        img=images(:,:,i,1);
        mutant_img=eye_filter(img,d, w);
        responses(i) = dot(template(:),mutant_img(:));
        img_sigmas(:,:,i) = mutant_img;
    end
else
%there is the target on the image
    for i=1:length
        img=tar+images(:,:,i,2);
        mutant_img=eye_filter(img,d, w); %convolution linearity
        responses(i)= dot(template(:),mutant_img(:));
        img_sigmas(:,:,i) = mutant_img;
    end
end

if nargout > 1
    two_sigmas = evaluate_two_sigmas(img_sigmas);
    line_sigmas = evaluate_line_sigmas(img_sigmas);
end

end