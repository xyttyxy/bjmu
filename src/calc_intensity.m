function intensities_out = calc_intensity(I, mask_l, varargin)
% excluding nuclei
bw_ret = false(size(I));
num_labels = max(mask_l, [], 'all');
intensities = zeros(num_labels, 1);

for idx_m = 1:num_labels
    bw_cell = bwareaopen(mask_l == idx_m, 10);
    bw_cytoplasm = imbinarize_mask(I,bw_cell);
    %imshowpair(I,imfuse(bw_cell,bw_cytoplasm),'montage');
    I_cr_plasma = bsxfun(@times, I, cast(bw_cytoplasm, class(I)));
    intensity = I_cr_plasma(:);
    intensity = intensity(intensity > 0);
    mean_intensity = mean(intensity);
    intensities(idx_m) = mean_intensity;
    
%     rp = regionprops(bw_cell, 'BoundingBox', 'Image', 'Area');
%     [~, idx_maxrp] = max([rp.Area]);
%     bbox = uint16(rp(idx_maxrp).BoundingBox);
%     bw_cr = rp(idx_maxrp).Image;
%     I_cr = imcrop(I, bbox-uint16([0 0 1 1]));
%     I_cr_cell = bsxfun(@times, I_cr, cast(bw_cr,class(I_cr)));
%     h = imhist(I_cr_cell);
%     thresh = otsuthresh(h(2:end));
%     bw = ~imbinarize(I_cr_cell, thresh);
%     
%     bw_clearedborder = imclearborder(bw);
%     if bwarea(bw_clearedborder) > size(bw, 1) * size(bw, 2) / 5
%         bw = bw_clearedborder;
%     end
%     
%     % now calculate the intensity
%     I_cr_plasma = bsxfun(@times, I_cr_cell, cast(bw,class(I_cr_cell)));
%     intensity = I_cr_plasma(:);
%     intensity = intensity(intensity > 0);
%     mean_intensity = mean(intensity);
%     intensities(idx_m) = mean_intensity;
%     %     bw_big = false(size(I));
%     %     bw_big(bbox(2):bbox(2)+bbox(4)-1,bbox(1):bbox(1)+bbox(3)-1) = bw;
%     %     bw_ret = bw_ret | bw_big;
end

intensities_out = intensities;

% %test
% name1 = strcat('trace/',num2str(idx_img),'.png');
% plot(counts_all1);
% print(gcf,'-dpng',name1);
% %test

clearvars -except intensities_out;
end