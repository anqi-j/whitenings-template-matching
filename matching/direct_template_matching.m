function [responses,two_sigmas,line_sigmas] = direct_template_matching(tar,images,presence)
% ---
% Operation: TM model
% Input:
% - tar: the target
% - images: the background
% - presence: target present (1) or target absent (0)
% Output:
% - response: decision variable responses
% - two_sigmas: the standard deviation on the left and right
% - line_sigmas: the standard deviation assuming vertical homogeneity
% Note:
% ---

%initialization
length = size(images,3);
responses=zeros(length,1);
template = tar - mean(tar(:));
template = template / norm(template, 'fro');
template = template(:);
mean_l = mean(images(:));

%there is no target on the image
if presence == 0
    parfor i=1:length
        img=images(:,:,i,1);
        %mean_l = mean(img(:));
        img = img - mean_l;
        responses(i)= dot(template,img(:));
    end
elseif presence == 1
%there is the target on the image
    parfor i=1:length
        img=tar+images(:,:,i,2);
        %mean_l = mean(mean(images(:,:,i,2)));
        img = img - mean_l;
        responses(i)= dot(template,img(:));
    end
end

if nargout > 1
    two_sigmas = evaluate_two_sigmas(images(:,:,:,presence+1));
    line_sigmas = evaluate_line_sigmas(images(:,:,:,presence+1));
end

end