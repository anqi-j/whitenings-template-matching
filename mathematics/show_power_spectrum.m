function [x,y] =  show_power_spectrum(img, bPlot)
% bPlot == 0: no plot
% bPlot == 1: scatter plot
% bPlot == 2: log-log scatter plot

if ~exist('bPlot', 'var')
    bPlot = 0;
end

[row, col] = size(img);
z = zeros(row, col);

for i = 1:row
    for j = 1:col
        z(i,j) = norm([i-row/2-1,j-col/2-1]);
    end
end

x = unique(z);

if x(1) == 0
    x(1)=[];
end

x(1)=[];
x(x>min(row, col)/2)=[];
y = zeros(length(x),1);

for l=1:length(x)
    f_img = abs(fftshift(fft2(img)));
    y(l) = mean(mean(f_img(z==x(l))));
end

if bPlot == 1
    figure;
    scatter(x,y,20,'filled');
    xlabel('frequency', 'fontsize', 100);
    ylabel('frequency amplitude', 'fontsize', 100);
elseif bPlot == 2
    figure;
    scatter(log10(x),log10(y),20,'filled');
    xlabel('log10(frequency)', 'fontsize', 100);
    ylabel('log10(frequency amplitude)', 'fontsize', 100);
end

if bPlot ~= 0
    a = get(gca,'XTickLabel'); 
    set(gca,'xticklabel', a,'fontsize',36);
    set(gca,'XTickLabelMode','auto');
    b = get(gca,'yticklabel');
    set(gca,'yticklabel', b,'fontsize',36);
    set(gca,'YTickLabelMode','auto');
end




