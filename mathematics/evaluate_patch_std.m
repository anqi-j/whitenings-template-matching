function std = evaluate_patch_std(scene, row, col)

scene_row = size(scene,1);
scene_col = size(scene,2);

std=0;
iteration = 1e5;
for n=1:iteration
    i = randi([row, scene_row - row]);
    j = randi([col, scene_col - col]);
    std = std + std2(scene(i-row/2:i+row/2-1,j-col/2:j+col/2-1));
end

std = std / iteration;
end

