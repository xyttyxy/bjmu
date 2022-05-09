function M = track_cell(rp_f, rp)
rp_m = rp;
centers_m = reshape([rp_m.Centroid], 2, [])';
centers_f = reshape([rp_f.Centroid], 2, [])';

size_f = size(centers_f, 1);
size_m = size(centers_m, 1);

dist_fm = zeros(size_f, size_m);
for f = 1:size_f
    dist_fm(f, :) = vecnorm(centers_m - centers_f(f, :), 2, 2);
end
dist_fm_norm = dist_fm ./ (([rp_f.EquivDiameter]'/2 + [rp_m.EquivDiameter]/2));
area_m = [rp_m.Area];
area_f = [rp_f.Area];
% area_min = min(repmat(area_f, numel(area_m), 1), repmat(area_m, numel(area_f), 1));
area_change_f2m = kron(area_m', 1./area_f);
area_change_m2f = kron(area_f', 1./area_m);
area_change = max(area_change_f2m', area_change_m2f);
cost = dist_fm_norm .* area_change;
[M, ~, ~] = matchpairs(cost, 50);
end