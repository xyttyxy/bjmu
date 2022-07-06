% setting
jobname = 'DOSE_0_RES_512';
xml_filename = 'D:\Work\tailin\wanghuan\20220610_images\DOSE_0\0_W1_512.xml';
w1_folder = 'D:\Work\tailin\wanghuan\20220610_images\DOSE_0\0_W1_512\'; % must have trailing \
w2_folder = 'D:\Work\tailin\wanghuan\20220610_images\DOSE_0\0_W2_512\';
mask_folder = 'D:\Work\tailin\wanghuan\20220610_images\DOSE_0\0_W1_512_mask\';
output_folder = 'D:\Work\tailin\wanghuan\20220610_images\DOSE_0\';
nframes = 40;

main(jobname, xml_filename, w1_folder, w2_folder, mask_folder, output_folder);