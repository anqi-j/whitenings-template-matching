function [line_sigmas, line_sigmas_std] = evaluate_line_sigmas(images)

[~, col, length] = size(images);
collectors = ones(length,col);

for i=1:length
    for j=1:col
        collectors(i,j) = std2(images(:,j,i));
    end
end

line_sigmas = mean(collectors,1);
line_sigmas_std = std(collectors,0,1);

end