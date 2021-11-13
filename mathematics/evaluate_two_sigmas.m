function two_sigmas = evaluate_two_sigmas(images)

[~, col, length] = size(images);
collectors = ones(length,2);
half=floor(col/2);

for i=1:length
    collectors(i,1) = std2(images(:,1:half));
    collectors(i,2) = std2(images(:,half+1:col));
end
two_sigmas = mean(collectors,1);

end