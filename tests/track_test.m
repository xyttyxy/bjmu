
% track results 
data_folder_root = 'D:\a_shj\img_db\wanghuan\merged_results\';
data_folder = strcat(data_folder_root,'traceResults\');
mkdir(data_folder);

load('trace/matches.mat'); %load matches

sz = size(matches);

for idx_m = 1:sz(1)
    idx_folder = strcat(data_folder,num2str(idx_m));
    mkdir(idx_folder);
    
    idx_matches = matches(idx_m,:);
    idx_matches(idx_matches<1) = [];
    for i = 1:numel(idx_matches)
        src_path = strcat(data_folder_root,num2str(i),'\',num2str(idx_matches(i)),'.jpg');
        dst_path = strcat(idx_folder,'\',num2str(i),'_',num2str(idx_matches(i)),'.jpg');
        
        copyfile(src_path,dst_path);
    end
end
