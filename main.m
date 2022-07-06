function main(jobname, xml_filename, w1_folder, w2_folder, masks_folder, output_folder, varargin)
if nargin == 7nar
    app = varargin{1};
    app.TextArea.Value = '';
    cla(app.UIAxes);
else
    clc; close all;
    app = 'NA';
end
num_w1 = size(dir([w1_folder, '\*.tif']), 1);
num_w2 = size(dir([w2_folder, '\*.tif']), 1);
num_masks = size(dir([masks_folder, '\*.png']), 1);
if num_w1 == num_w2 && num_w1 == num_masks
    nframes = num_w1;
    logout(app, sprintf('%d frames found.', nframes));
else
    logout(app, 'ERR: Number of images mismatch');
    return;
end
frames = 0:nframes-1;
%% read images
w1 = [];
w2 = [];
w1_masks = [];
logout(app, 'Reading Images...');
try
    for f = 1:numel(frames)
    frame = frames(f);
    w1 = cat(3, w1, imread(strcat(w1_folder, '\', sprintf('%d.tif', frame))));
    w2 = cat(3, w2, imread(strcat(w2_folder, '\', sprintf('%d.tif', frame))));
    w1_masks = cat(3, w1_masks, imread(strcat(masks_folder, '\', sprintf('%d_cp_masks.png', frame)))); % masks are gone...forgot to save them
    end
catch ME
    msgbox(ME.message, ['Error: ', ME.identifier], 'Error');
    return;
end
logout(app, 'Done');

%% calculate intensities of regions, excluding nuclei
intensities_w1s = {};
intensities_w2s = {};
logout(app, 'Calculating per-cell intensities (ex. nuclei) ...');
wbar = waitbar(0, 'Calculating per-cell intensties (ex. nuclei) ...');
for idx_f = 1:nframes
    w1_f = w1(:, :, idx_f);
    w2_f = w2(:, :, idx_f);
    w1_mask_f = w1_masks(:, :, idx_f);
    intensities_w1s{idx_f} = calc_intensity(w1_f, w1_mask_f);
    intensities_w2s{idx_f} = calc_intensity(w2_f, w1_mask_f);
    waitbar(idx_f/nframes, wbar);
end
delete(wbar);
logout(app, 'Done');

%% calculate background intensities
bg_2 = [];
bg_1 = [];
logout(app, 'Calculating background intensities...');
for idx_f = 1:nframes
    w1_f = w1(:, :, idx_f);
    w2_f = w2(:, :, idx_f);
    w1_mask_f = w1_masks(:, :, idx_f);
    bg_1 = [bg_1, mean(w1_f(w1_mask_f == 0 & w1_f < 5e3))];
    bg_2 = [bg_2, mean(w2_f(w1_mask_f == 0 & w1_f < 5e3))];
end
logout(app, 'Done');

%% read trackmate output
logout(app, 'Reading Cellpose XML...');
try
    G_asimport = trackmateGraph(xml_filename);
catch ME
    msgbox(ME.message, ['Error: ', ME.identifier], 'Error');
    return;    
end
G_backwards = flipedge(G_asimport);
logout(app, 'Done');

%% clean graph
logout(app, 'Cleaning Cellpose Graph');
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
G_cleaned = rmnode(G_asimport, to_remove);
logout(app, 'Done');

%% plot intensity history for each region
logout(app, 'Aligning tracks and calculating ratios...');
N_frame1 = G_cleaned.Nodes(G_cleaned.Nodes{:, 'FRAME'} == 0,:);

close all; 
if class(app) == 'app1'
    hold(app.UIAxes, 'on');
else
    figure; hold on;
end
wbar = waitbar(0, 'Aligning tracks and calculating Ratios');
w1_ints = {};
w2_ints = {};

for idx_n = 1:height(N_frame1)
    waitbar(idx_n/height(N_frame1), wbar);
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
        nodes_in_this_frame = G_asimport.Nodes(G_asimport.Nodes{:,'FRAME'} == frame & G_asimport.Nodes{:,'AREA'} > 10, :);
        
        % check region is what you're looking for
        % find mask region corresponding to node
        rp = regionprops(w1_mask_f);
        centers = reshape([rp.Centroid], 2, [])';
        dist = vecnorm(centers - [pos_x, pos_y], 2, 2);
        [~, idx_in_this_frame] = min(dist);
        area = rp(idx_in_this_frame).Area;
        w1_int_f = intensities_w1s{1, frame+1}(idx_in_this_frame) * area - area * bg_1(frame+1);
        w2_int_f = intensities_w2s{1, frame+1}(idx_in_this_frame) * area - area * bg_2(frame+1);
        
        w1_int = [w1_int, w1_int_f];
        w2_int = [w2_int, w2_int_f];
    end
    w1_ints{end+1} = w1_int;
    w2_ints{end+1} = w2_int;
    
    if class(app) == 'app1'
        if app.PlotCheckBox.Value ~= 0
            plot(app.UIAxes, 1:numel(w1_int), -w1_int./w2_int+1);
        end
    else
        plot(1:numel(w1_int), -w1_int./w2_int+1);
    end
end
delete(wbar);
logout(app, 'Done');

%% outputting the cell array
w1_out = outputcellarray(w1_ints);
w2_out = outputcellarray(w2_ints);
ratio_out = -w1_out ./ w2_out + 1;
ratio_out(isnan(ratio_out)) = 0;
all_out = zeros(size(w1_out, 1)*3, size(w1_out,2));
% interleave the matrices
for idx1 = 0:size(w1_out, 1)-1
    all_out(idx1*3+1,:) = w1_out(idx1+1, :);
    all_out(idx1*3+2,:) = w2_out(idx1+1, :);
    all_out(idx1*3+3,:) = ratio_out(idx1+1, :);
end
fileID = fopen([output_folder, '\', jobname, '.csv'],'w');
msgbox(['Output written to ', output_folder, '\', jobname, '.csv'], 'All done!');
logout(app, ['Output written to ', output_folder, '\', jobname, '.csv']);

for row = 1:size(all_out, 1)
    fprintf(fileID, '%11.4e, ', all_out(row,:));
    fprintf(fileID, '\n');
end
fclose(fileID);

logout(app, 'All Done!');

end

function outarray = outputcellarray(w1_ints)
rowlength=cellfun(@length,w1_ints);
maxrowlength=max(rowlength);
outarray=zeros(length(w1_ints), maxrowlength);
for idx2=1:size(w1_ints, 2)
    tmp = w1_ints{1, idx2};
    outarray(idx2,1:rowlength(idx2)) = tmp';
end
end

function logout(app, message)
    if class(app) == 'app1'
        app.TextArea.Value{end+1} = message;
    else
        fprintf('%s\n', message);
    end
end