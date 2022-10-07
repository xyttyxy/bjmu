% setting
jobname = 'DOSE_25_RES_1024';
xml_filename = 'D:\Work\tailin\wanghuan\20220610_images\DOSE_25\25_W1.xml';
w1_folder = 'D:\Work\tailin\wanghuan\20220610_images\DOSE_25\25_W1\'; % must have trailing \
w2_folder = 'D:\Work\tailin\wanghuan\20220610_images\DOSE_25\25_W2\';
mask_folder = 'D:\Work\tailin\wanghuan\20220610_images\DOSE_25\25_W1_masksex\';
output_folder = 'D:\Work\tailin\wanghuan\20220610_images\DOSE_25\';
nframes = 40;

main(jobname, xml_filename, w1_folder, w2_folder, mask_folder, output_folder);