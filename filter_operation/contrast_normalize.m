function [img_cn, sigma]= contrast_normalize(img,window,radius, dev)

% ---
% Operation: overall function to normalize the contrast of the image
% Input:
% - img: input image
% - window: window shape used to estimate local contrast, or not used during the normalization
% - radius: radius of the window, or standard deviation of regions in the image
% - dev: deviation of the boundary relative to the center used only considering positional uncertainty
% Output:
% - img_cn: contrast normalized image
% - sigma: standard deviation matrix
% Note:
% ---

[row, col]=size(img);
sigma=ones(row,col);
bound = 1e-8; %minimum sigma value

if ~exist('dev','var')
    dev = 0;
end

%situation 1:square neiborhood
if window =='s'
    for i=1:row
        for j=1:col
            left=1;up=1;right=col;down=row;
            if i-radius>0, up=i-radius; end
            if i+radius<=row, down=i+radius; end
            if j-radius>0, left=j-radius; end
            if j+radius<=col, right=j+radius; end
            sigma(i,j)=std2(img(up:down,left:right));
        end
    end

%situation 2:
elseif strcmp(window, 'rcos')
    for i=1:row
        for j=1:col
            left=1;up=1;right=col;down=row;
            if i-radius>0, up=i-radius; end
            if i+radius<=row, down=i+radius; end
            if j-radius>0, left=j-radius; end
            if j+radius<=col, right=j+radius; end
            weight0=cosWindow2([2*radius+1,2*radius+1]);
            %select the size to match neighborhood size
            weight=weight0(round(1+radius-i+up):round(1+radius-i+down),...
                round(1+radius-j+left):round(1+radius-j+right));
            %normalized condition
            weight=weight/sum(sum(weight));
            
            ave=sum(sum(weight.*img(up:down,left:right)));
            sigma(i,j)=sqrt(sum(sum(weight.*((img(up:down,left:right)-ave).^2))));
        end
    end

%situation 3:
elseif strcmp(window, 'dichotomy')
    [~,sigma]=contrast_normalize_dichotomy(img, radius);

%situation 4:
elseif strcmp(window, 'dichotomy_bound')
    [~,sigma]=contrast_normalize_dichotomy_bound(img, radius, dev);
    
%situation 5:
elseif strcmp(window, 'heuristic')
    [~,sigma]=contrast_normalize_heuristic(img);
end

sigma(sigma<bound) = bound;
img_cn=img./sigma;
end


