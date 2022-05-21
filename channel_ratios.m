% I have the xml file covering up to frame 37
% For each track in this file, I can plot the brightness
% filename = 'trackmate_model_220517.xml';
filename = 'D:\Work\tailin\wanghuan\DATA\merged\w1_track.xml';
[ spot_table, spot_ID_map ] = trackmateSpots( file_path );
G_asimport = trackmateGraph(filename);
G_backwards = flipedge(G_asimport);

%%
to_remove = [];
for idx_n = 1:numnodes(G_asimport)
    edges_down = G_asimport.dfsearch(idx_n);
    edges_up = G_backwards.dfsearch(idx_n);
    edges = unique(edges_down + edges_up');
    if G_asimport.indegree(idx_n) == 0 && G_asimport.outdegree(idx_n) == 0
        to_remove = [to_remove, idx_n];
    elseif numel(edges) < 8
        to_remove = [to_remove, idx_n];
    elseif G_backwards.Nodes{edges_up(end), 'FRAME'} ~= 0
        to_remove = [to_remove, idx_n];
    end
end
%%
G_cleaned = rmnode(G_asimport, to_remove);
plot(G_cleaned, 'layout', 'layered');
frames = unique(G_cleaned.Nodes{:, 'FRAME'});

%%
w1 = [];
w2 = [];
w1_masks = [];
for f = 1:numel(frames)
    frame = frames(f);
    w1 = cat(3, w1, imread(strcat('D:\Work\tailin\wanghuan\DATA\merged\w1_aligned\', sprintf('tp_%02d.tif', frame))));
    w2 = cat(3, w2, imread(strcat('D:\Work\tailin\wanghuan\DATA\merged\w2_aligned\', sprintf('tp_%02d.tif', frame))));
    w1_masks = cat(3, w1_masks, imread(strcat('D:\Work\tailin\wanghuan\DATA\merged\w1_aligned_mask\', sprintf('%d_cp_masks.png', frame)))); % masks are gone...forgot to save them
end
%%
% for each node in frame 1, after cleaning
% find the edges connecting them
% calculate the 
N_frame1 = G_cleaned.Nodes(G_cleaned.Nodes{:, 'FRAME'} == 0,:);
for idx_n = 1:height(N_frame1)
    ID = N_frame1{idx_n, 'ID'};
    n_idx_in_G = find(G_cleaned.Nodes{:, 'ID'} == ID);
    track = G_cleaned.dfsearch(n_idx_in_G);
    
    w1_int = [];
    w2_int = [];
    for idx_t = 1:numel(track)
        t = track(idx_t); % index in Nodes table
        pos_x = G_cleaned.Nodes{t, 'POSITION_X'};
        pos_y = G_cleaned.Nodes{t, 'POSITION_Y'};
        frame = G_cleaned.Nodes{t, 'FRAME'};
        w1_f = w1(:, :, frame+1);
        w2_f = w2(:, :, frame+1);
        w1_mask_f = w1_masks(:, :, frame+1);
        nodes_in_this_frame = G_asimport.Nodes(G_asimport.Nodes{:,'FRAME'} == frame, :);
        idx_in_this_frame = nodes_in_this_frame{:, 'ID'} == G_cleaned.Nodes{t, 'ID'};
        
        intensity_w1 = calc_intensity(w1_f, w1_masks_f);
        intensity_w2 = calc_intensity(w2_f, w1_masks_f);
        
        fprintf('frame=%d, idx_in_frame=%d\n', frame, find(idx_in_this_frame));
    end
    break
end
return
%%
for idx_n = 1:10%numnodes(G_cleaned)
    
    % intensities = calc_intensity(w1(1), w1_masks(1));
    % xml does not have correspondance between mask label and the id. ID
    % and name are the same
    % read masks
end
    