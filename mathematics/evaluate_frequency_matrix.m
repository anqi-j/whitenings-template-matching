function freq_mat = evaluate_frequency_matrix(imgs)

[row, col, len] = size(imgs);
freq_mat = zeros(row,col);

for i=1:len
    freq_mat = freq_mat + abs(fftshift(fft2(imgs(:,:,i))));
end

freq_mat = freq_mat ./ len;

