for idx_img = 1:50
    mask_l = readNPY('D:\Work\tailin\wanghuan\DATA示例\DATA\merged\tp_'+string(idx_img)+'.npy');
    I = imread('D:\Work\tailin\wanghuan\DATA示例\DATA\merged\tp_'+string(idx_img)+'.tif');
    bg = mean(I(mask_l == 0));
%     rp = regionprops(mask_l, 'Centroid', 'BoundingBox', 'Area', 'EquivDiameter');
%     if idx_img > 1
%         M = track_cell(rp_f, rp);
%         matches(:, idx_img) = -ones(numcells,1);
%         intensities(:, idx_img) = -ones(numcells, 1);
%         for idx_M = 1:size(M, 1)
%             idx_f = M(idx_M, 1);
%             idx_m = M(idx_M, 2);
%             matches(find(matches(:, idx_img-1) == idx_f), idx_img) = idx_m;
%         end
%         intensities_m = calc_intensity(I, mask_l);
%         for idx_M = 1:size(M, 1)
%             idx_f = M(idx_M, 1);
%             idx_m = M(idx_M, 2);
%             intensities(find(matches(:, idx_img-1) == idx_f), idx_img) = intensities_m(idx_m);
%         end
%     else
%         % first image
%         % just calculate the average intensity in the area
%         numcells = max(mask_l, [], 'all');
%         % this intensity is in order of current frame
%         intensities(:, idx_img) = calc_intensity(I, mask_l);
%         matches(:, idx_img) = int16(1:numcells);
%     end
    intensities(intensities(:, idx_img) > 0, idx_img) = intensities(intensities(:, idx_img) > 0, idx_img) - bg;
    rp_f = rp;
end

%% loop through all these images
figure; hold on;
for row = 1:10%size(intensities, 1)
    plot(intensities(row, intensities(row, :) ~= -1)/2^16, '-xk');
end