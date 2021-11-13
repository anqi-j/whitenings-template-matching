function [responses,two_sigmas,line_sigmas] = adaptX_white_template_matching(tar,images,presence, rev_func, power)
% ---
% Operation: WTM model
% Input:
% - tar: the target
% - images: the background
% - presence: target present (1) or target absent (0)
% - rev_function: a number for power exponent, or a matrix for extra filtering
% - power: the power exponent for the whitening filter
% Output:
% - response: decision variable responses
% - two_sigmas: the standard deviation on the left and right
% - line_sigmas: the standard deviation assuming vertical homogeneity
% Note:
% ---

if ~exist('power','var')
    power = 0;
end

%initialization
[row, col, length, ~] = size(images);
responses=zeros(length,1);
template = tar - mean(tar(:));
template = template / norm(template, 'fro');
template = pink_to_white_adapt_DC0(template, rev_func, power);
img_sigmas = zeros(row, col, length);

%there is no target on the image
if presence==0
    for i=1:length
        img=images(:,:,i,1);
        mutant_img=pink_to_white_adapt_DC0(img,rev_func, power);
        responses(i) = dot(template(:),mutant_img(:));
        img_sigmas(:,:,i) = mutant_img;
    end
else
%there is the target on the image
    for i=1:length
        img=tar+images(:,:,i,2);
        mutant_img=pink_to_white_adapt_DC0(img,rev_func, power); %convolution linearity
        responses(i)= dot(template(:),mutant_img(:));
        img_sigmas(:,:,i) = mutant_img;
    end
end

if nargout > 1
    two_sigmas = evaluate_two_sigmas(img_sigmas);
    line_sigmas = evaluate_line_sigmas(img_sigmas);
end

end