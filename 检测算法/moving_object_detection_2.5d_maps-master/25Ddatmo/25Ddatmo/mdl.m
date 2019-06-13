%% background model around vehicle
function [bgr, stack]  = mdl(stack, pts, mat, st)                          % background model

%% fill stack: shift previous + insert new
stack         = stck(stack, pts, mat, st);                                 % transform previous mats and put new mat in stack
%% background modeling
bgr.mat       = zeros(st.vx.ix, st.vx.iy);
bgr.con       = zeros(st.vx.ix, st.vx.iy);                                 % confidence
for i         = 1 : size(stack.mat, 1)
   for j      = 1 : size(stack.mat, 2)         
      if sum(stack.ind(i, j, :) ~= 0)                                      % if that cell has any valid data on it 
      ind.val = stack.ind(i, j, :) ~= 0;                                   % find indexes of those valid cells
      if sum(ind.val) > st.stc.in                                          % if it is more than st.stc.in, just take first st.stc.in measurements
      ind.ind = find(ind.val == 1);                                        % keep first st.stc.in indexes
      ind.val(ind.ind(st.stc.in) + 1 : end) = 0;                           % to average over first st.stc.in filled stack's cells     
      end
      bgr.mat(i, j) = mean(stack.mat(i, j, ind.val ~= 0));                 % average over all
      bgr.con(i, j) = sum(double(ind.val));                                % confidence (number of measurements)
      end
   end
end
bgr.mat       = (bgr.con >= 5) .* bgr.mat;                                 % add to option! cell must have been observed for minimum number of 5
%% matrix to vector (bgr.pts, bgr.ptn)
ivx           = 1 : size(bgr.mat, 1);                                      % vxl pts at the origin
ivy           = 1 : size(bgr.mat, 2);                                      % index vector
[iy, ix]      = meshgrid(ivy, ivx);                                        % notice! ivy ivx
bgr.pts       = [(ix(:) - 1) * st.vx.x + st.vm.xb, ...                     % map vector at origin
                 (iy(:) - 1) * st.vx.y + st.vm.yr, bgr.mat(:)];              
ptm           = pts.rtn * bgr.pts(:, 1:3)';                                % vxl pts in the world coordinates
bgr.ptn       = [ptm(1,:)' + pts.trn(1), ptm(2,:)' + pts.trn(2), ...
                 bgr.pts(:, 3)];                                           % map vector at real coord

end

%% fill stack: shift previous + insert new
function stack  = stck(stack, pts, mat, st)            % fill stack

%% stack: shift
for i     = st.stc.sz - 1 : -1 : 1       % stack process from bottom to top    
bef.mat   = stack.mat(:, :, i);          % load previous mat
bef.pts   = stack.pts(:, :, i);
bef.ptn   = stack.ptn(:, :, i);
aftm      = trns(bef, pts, st);          % transformation: mat [frm - 1], pts [frm]
bef.mat   = stack.ind(:, :, i);          % put index instead of mat
afti      = trns(bef, pts, st);          % do the same for index
stack.mat(:, :, i + 1) = aftm.mat;       % shift stack
stack.ind(:, :, i + 1) = afti.mat;
stack.pts(:, :, i + 1) = aftm.pts;
stack.ptn(:, :, i + 1) = aftm.ptn;
end
%% stack: insert
stack.mat(:, :, 1)     = mat.mat;        % insert new observation
stack.ind(:, :, 1)     = mat.ind;
stack.pts(:, :, 1)     = mat.pts;  
stack.ptn(:, :, 1)     = mat.ptn;                          
               
end

%% transform map frm - 1 (on the map frm)
function mat  = trns(mat, pts, st)                                         % mat (frm - 1), pts [trans] (frm)

%% move the map [frm] (mat.ptn) to the origin by transformation of [frm + 1] (pts.trn, pts.rtn)
nts           = zeros(size(mat.pts));
nts(:, 1:3)   = mat.ptn - repmat(pts.trn', size(mat.pts, 1), 1);           % trajectory at frm + 1: translation
nts(:, 1:3)   = (pts.rtn \ nts(:, 1:3)')';                                 %                        rotation
nts(:, 3)     = mat.mat(:);                                                % put map values on corresponding locations:[x y values]
%%  move the map [x, y] to the matrix coordinate [i, j]
nts(:, 1:2)   = nts(:, 1:2) ./ repmat([st.vx.x, st.vx.y], ...              % compensate voxel size
                 size(nts, 1), 1);        
nts(:, 1:2)   = nts(:, 1:2) + repmat([(-st.vm.xb / st.vx.x + 1), ...       % bias (start index from 1)
                (-st.vm.yr / st.vx.y + 1)], size(nts, 1), 1);           
nts(:, 1:2)   = round(nts(:, 1:2));                                        % interpolate: use round!
%% keep valid values [valid indexes]
vind          = ((nts(:,1) >= 1) & (nts(:,1) <= (st.vm.xf - st.vm.xb) / st.vx.x) & ...
                 (nts(:,2) >= 1) & (nts(:,2) <= (st.vm.yl - st.vm.yr) / st.vx.y)); 
nts(~vind, :) = [];                                                        % filter points inside grid [remove points outsdie grid]
%% convert points (vectors) to matrix with valid index
mat.mat       = zeros(size(mat.mat));                                      % matrix
for i         = 1 : size(nts, 1)
if nts(i, 3) ~= 0                                                          % for object cells
mat.mat(nts(i, 1), nts(i, 2)) = nts(i, 3);                                 % vector to matrix
end
end
%% matrix to vector (mat.pts, mat.ptn)
ivx           = 1 : size(mat.mat, 1);                                      % vxl pts at the origin
ivy           = 1 : size(mat.mat, 2);                                      % index vector
[iy, ix]      = meshgrid(ivy, ivx);                                        % notice! ivy ivx
mat.pts       = [(ix(:) - 1) * st.vx.x + st.vm.xb, ...                     % map vector at origin
                 (iy(:) - 1) * st.vx.y + st.vm.yr, mat.mat(:)];              
ptm           = pts.rtn * mat.pts(:, 1:3)';                                % vxl pts in the world coordinates
mat.ptn       = [ptm(1,:)' + pts.trn(1), ptm(2,:)' + pts.trn(2), ...
                 mat.pts(:, 3)];                                           % map vector at real coord                            
               
end