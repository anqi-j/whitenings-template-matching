function responses= norm_template_matching(tar,images,presence,window,radius)
%assumption:
% ---
% Operation: RTM model
% Input:
% - tar: the target
% - images: the background
% - presence: target present (1) or target absent (0)
% - window: window shape used to estimate local contrast, or not used during the normalization
% - radius: radius of the window, or standard deviation of regions in the image
% Output:
% - response: decision variable responses
% Note:
% ---

if ~exist('window','var')
    window = 'dichotomy';
end

if ~exist('radius', 'var')
    radius = 0;
end

%initialization
length = size(images,3);
responses=zeros(length,1);
template = tar - mean(tar(:));
template = template / norm(template, 'fro');
mean_l = mean(images(:));

%there is no target on the image
if presence==0
    parfor i=1:length
        img = images(:,:,i,1);
        %mean_l = mean(img(:));
        img = img - mean_l;
        [mutant_img,sigma]=contrast_normalize(img,window,radius);
        mutant_template=template./sigma;
        responses(i)= dot(mutant_template(:),mutant_img(:));
    end
else
%there is the target on the image
    parfor i=1:length
        img=tar+images(:,:,i,2);
        %mean_l = mean(mean(images(:,:,i,2)));
        img = img - mean_l;
        [mutant_img,sigma]=contrast_normalize(img,window,radius);
        mutant_template=template./sigma;
        responses(i)= dot(mutant_template(:),mutant_img(:));
    end
end
end