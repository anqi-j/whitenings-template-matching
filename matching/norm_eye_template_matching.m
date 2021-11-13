function responses= norm_eye_template_matching(tar,images,presence,window,radius,d,w)
%assumption:
% ---
% Operation: ERTM model
% Input:
% - tar: the target
% - images: the background
% - presence: target present (1) or target absent (0)
% - window: window shape used to estimate local contrast, or not used during the normalization
% - radius: radius of the window, or standard deviation of regions in the image
% - d: the diameter of the pupil
% - w: the wavelength of the stimulus
% Output:
% - response: decision variable responses
% Note:
% ---

if ~exist('power','var')
    w = 0;
end

%initialization
length = size(images,3);
responses=zeros(length,1);
template = tar - mean(tar(:));
template = template / norm(template, 'fro');
template = eye_filter(template, d, w);

%there is no target on the image
if presence==0
    
    parfor i=1:length
        img=images(:,:,i,1);
        [mutant_img,sigma]=contrast_normalize(eye_filter(img,d, w),window,radius);
        mutant_template=template./sigma;
        responses(i)= dot(mutant_template(:),mutant_img(:));
    end
else
%there is the target on the image
    parfor i=1:length
        img=tar+images(:,:,i,2);
        [mutant_img,sigma]=contrast_normalize(eye_filter(img,d, w),window,radius);
        mutant_template=template./sigma;
        responses(i)= dot(mutant_template(:),mutant_img(:));
    end
end
end