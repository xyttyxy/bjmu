masks = [];
Is = [];
for idx_img = 1:42
    %mask_l = imread(strcat('C:\Users\DZ-03-172\AppData\Local\Temp\TrackMate-Cellpose_8568926424230976045\', sprintf('%d_cp_masks.png', idx_img)));
    % I = imread(strcat('C:\Users\DZ-03-172\AppData\Local\Temp\TrackMate-Cellpose_8568926424230976045\', sprintf('%d.tif', idx_img)));
    I = imread(strcat('D:\Work\tailin\wanghuan\DATA示例\DATA\DRUGS\2022-04-14\20553_sorted\D05\s1\w2\', sprintf('TimePoint_%d_DRUGS_D05_s1_w2.tif', idx_img)));
    % I = imread('D:\a_shj\img_db\wanghuan\merged\tp_'+string(idx_img)+'.tif');
    %   masks = cat(4, masks, label2rgb(uint32(mask_l), 'jet', [0,0,0], 'shuffle'));
    Is = cat(4, Is,I);
end
