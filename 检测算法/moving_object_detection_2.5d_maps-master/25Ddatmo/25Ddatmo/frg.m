%% moving cells/objects around vehicle
function [frm, pts, ocn, szn] = frg(brm, pts, mat, st)                               % moving objects

%% foreground modeling
bsz          = ceil(st.fr.sz / min(st.vx.x, st.vx.y));                     % block size
frm.mat      = zeros(size(mat.mat));
for i        = 1 : size(mat.mat, 1)
   for j     = 1 : size(mat.mat, 2)      
Id           = i - bsz; if Id < 1; Id = 1; end                             % find indexes 
Iu           = i + bsz; if Iu > size(frm.mat, 1); Iu = size(frm.mat, 1); end
Jd           = j - bsz; if Jd < 1; Jd = 1; end
Ju           = j + bsz; if Ju > size(frm.mat, 2); Ju = size(frm.mat, 2); end
blk          = brm.mat(Id : Iu, Jd : Ju);                                  % find neighbourhood block from background
blk          = abs(blk - mat.mat(i, j));                                   % find difference between foreground and neighbourhood background
if min(blk(:)) > 0.3 * mat.mat(i, j)                                       % if difference is less than a threshod take foreground as a background
frm.mat(i, j) = mat.mat(i, j);
end
   end
end
%% crop center
xn           = (st.vm.nxf - st.vm.nxb) / st.vx.x; yn = (st.vm.nyl - st.vm.nyr) / st.vx.y;  % mat size 
mxl          = (st.vm.nxb - st.vm.xb)  / st.vx.x + 1; mxh = mxl + xn - 1; 
myl          = (st.vm.nyr - st.vm.yr)  / st.vx.y + 1; myh = myl + yn - 1;
frm.mat      = frm.mat(mxl : mxh, myl : myh);
ivx          = 1 : size(frm.mat, 1); ivy = 1 : size(frm.mat, 2);           % vxl pts at the origin (index vector)
[iy, ix]     = meshgrid(ivy, ivx);                                         % notice! ivy ivx
frm.pts      = [(ix(:) - 1) * st.vx.x + st.vm.nxb, ...                     % map vector at origin
                (iy(:) - 1) * st.vx.y + st.vm.nyr, frm.mat(:)];            % for test!
ptm          = pts.rtn * frm.pts(:, 1:3)';                                 % vxl pts in the world coordinates
frm.ptn      = [ptm(1,:)' + pts.trn(1), ptm(2,:)' + pts.trn(2), ...
                frm.pts(:, 3)];                                            % map vector at real coord
tmp          = ((pts.pts(:,1) > st.vm.nxb) & (pts.pts(:,1) < st.vm.nxf) & ... % filter points
                (pts.pts(:,2) > st.vm.nyr) & (pts.pts(:,2) < st.vm.nyl));
pts.pts      = pts.pts(tmp,:);
%% post process - morphological operators
% remove average heigher than a threshold
frm.mat      = (frm.mat < 2) .* frm.mat;                                   % remove average values more than 2 meters (add it to options!)
% morphological operators - fill small holes inside objects(dilation in x & y)
st.fr.dx     = 2;                                                          % Morphology (Dilation - x & y) 1 1
st.fr.dy     = 2;
se.dx        = strel('rectangle',[ceil(st.fr.dx / st.vx.x), 2]);           % extension in x direction
se.dy        = strel('rectangle',[2, ceil(st.fr.dy / st.vx.y)]);           % extension in y direction
mx           = imdilate(frm.mat, se.dx); mx = imfill(mx, 'holes');         % dilation and fill holes: x
my           = imdilate(frm.mat, se.dy); my = imfill(my, 'holes');         % dilation and fill holes: y
jm           = mx.* my;                                                    % joint areas
% morphological operators - compensate velodyne sensor (dilation in car direction: x)
st.fr.dn     = 2;
se.dn        = strel('rectangle', [ceil(st.fr.dn / st.vx.x), 1]);          % extension in x direction 1.5
jm           = imdilate(jm, se.dn); jm = imfill(jm,'holes');               % dilation and fill holes: x
se.dm        = strel('ball', 1, 0.5, 2); jm = imerode(jm, se.dm);          % ball [disk: strel('disk',1) line: strel('line', 3, 0)] 
vbin         = (frm.mat > 0) & (jm > 0);                                   % keep valid part of frm.mat: foreground motion bars
%% post process - find and remove small and unusual size regions 
tr.mmn       = ceil(0.5  / (st.vx.x * st.vx.y));                           % 0.5 m2 is minimum size of motion bars to keep
tr.smn       = floor(1.2 / (st.vx.x * st.vx.y));                           % 1.2 m2 is minimum size of segment to keep
tr.smx       = ceil(15   / (st.vx.x * st.vx.y));                           % 15  m2 is maximum size of segment to keep
seg.mat      = zeros(size(frm.mat));                                       % initialize result segmented region (high-level) with label
mtn.mat      = zeros(size(frm.mat));                                       % initialize result motion bars (low-level)
[l, num]     = bwlabel(jm > 0);                                            % rgn.bin: segmented reigons (connected component)
for i        = 1 : num                                                     % check every segment
seg.mid      = zeros(size(vbin));                                          % intialize   
seg.mid(l   == i) = l(l == i);                                             % segmented region (high-level)
mtn.mid      = vbin & seg.mid;                                             % motion bars (low-level)
area.s       = sum(seg.mid(:) > 0);                                        % area of segmented region
area.m       = sum(mtn.mid(:));                                            % area of motion region
if (area.m  >= tr.mmn) && (area.s >= tr.smn) && (area.s <= tr.smx)         % put it in option!
seg.mat(l   == i) = l(l  == i);                                            % segments with labels
mtn.mat(l   == i) = frm.mat(l  == i);                                      % valid motion bars
end
end
[l, num]     = bwlabel(seg.mat > 0); frm.lbl = l;                          % because some labels are eliminated (label numbers may not consecutive)
%% mat, pts and ptn
frm.mat       = mtn.mat;
frm.pts(:, 3) = mtn.mat(:);
frm.ptn(:, 3) = mtn.mat(:);
%% centroid of objects in current frame
[ocn, szn] = dtn(frm, pts, st);                                            % centroid of objects in the world coordinate

end

%% centroid of objects in current frame
function [ocn, szn] = dtn(frm, pts, st)
n            = max(frm.lbl(:));                                            % no of objects
ocs          = zeros(3, n);                                                % initialize object centroid
szn          = zeros(3, n);                                                % initialize object size
for i        = 1 : n                                                       % for each object in current frame find centroid
[row, col]   = find(frm.lbl == i);                                         % row and column of each object
ocs(:, i)    = [(mean(row) - 1) * st.vx.x + st.vm.nxb; (mean(col) - 1) *...% object centroid at the origin (3 x n)
                st.vx.y + st.vm.nyr; 0];
szn(:, i)    = [(max(row) - min(row)) * st.vx.x; (max(col) -min(col)) *... % object size
                 st.vx.y; max(frm.mat(frm.lbl == i))];                             
end             
ocn          = pts.rtn * ocs + repmat(pts.trn, 1, n);                      % object centroid at the world coordinates (3 x n)
end
