function mirror_img = double_mirror(img)
    mirror_img = [img,flip(img,2);flip(img,1),flip(flip(img,1),2)];
end