% image segmentation by bw mask
function bw = imbinarize_mask(gr, mask)
% parameter validity
assert(numel(gr) == numel(mask));
% Normalized to uint16
gr = im2uint16(gr);

gr1 = reshape(gr,1,[]);
mask1 = reshape(mask,1,[]);
[rows,cols] = find(mask1 == 0);
gr1(:,cols) = []; % remove nonzreo pixels
T = otsuthresh( imhist(gr1) );
% Binarize image using computed threshold
bw0 = imbinarize(gr,T);
bw = bw0 & mask;

end