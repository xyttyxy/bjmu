clear all;close all;
%%
bg = [];
for idx_img = 0:36
    % mask_l = readNPY('D:\a_shj\img_db\wanghuan\merged\tp_'+string(idx_img)+'.npy');
    I = imread('D:\a_shj\img_db\wanghuan\merged\tp_'+string(idx_img)+'.tif');
    mask_l = imread(strcat('C:\Users\DZ-03-172\AppData\Local\Temp\TrackMate-Cellpose_8568926424230976045\', sprintf('%d_cp_masks.png', idx_img)));
    % I = imread(strcat('C:\Users\DZ-03-172\AppData\Local\Temp\TrackMate-Cellpose_8568926424230976045\', sprintf('%d.tif', idx_img)));
    bg = [bg, mean(I(mask_l == 0))]
    continue;
    rp = regionprops(mask_l, 'Centroid', 'BoundingBox', 'Area', 'EquivDiameter');
    if idx_img > 1
        M = track_cell(rp_f, rp);
        matches(:, idx_img) = -ones(numcells,1);
        intensities(:, idx_img) = -ones(numcells, 1);
        for idx_M = 1:size(M, 1)
            idx_f = M(idx_M, 1);
            idx_m = M(idx_M, 2);
            matches(find(matches(:, idx_img-1) == idx_f), idx_img) = idx_m;
        end
        intensities_m = calc_intensity(I, mask_l);
        for idx_M = 1:size(M, 1)
            idx_f = M(idx_M, 1);
            idx_m = M(idx_M, 2);
            intensities(find(matches(:, idx_img-1) == idx_f), idx_img) = intensities_m(idx_m);
        end
    else
        % first image
        % just calculate the average intensity in the area
        numcells = max(mask_l, [], 'all');
        % this intensity is in order of current frame
        intensities(:, idx_img) = calc_intensity(I, mask_l);
        matches(:, idx_img) = int16(1:numcells);
    end
    intensities(intensities(:, idx_img) > 0, idx_img) = intensities(intensities(:, idx_img) > 0, idx_img) - bg;
    rp_f = rp;
end

return
%test
name1 = strcat('trace/matches.mat');
save(name1,'matches');
%test

xlswrite('intensities.xls', intensities);
save intensities;


%% loop through all these images
figure; hold on;
for row = 10:40%size(intensities, 1)
    plot(intensities(row, intensities(row, :) ~= -1)/2^16, '-xk');
end
