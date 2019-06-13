function [mat, pts] = obs(st, frame)

%% observation
pts          = trj(st, frame);               % observations: transformation
mat          = grd(pts, st);                 %               last grid 

end

function pts = trj(st, frm)        % [transformed velodyne points, velodyne points, rotation, translation]

%% transformation matrixes [rotation 3x3, translation 3x1]
fid.tns     = fopen(sprintf('%s%s.txt', st.dr.pose, st.dr.nm),'rb');         % read from directory of poses
transfrm    = fscanf(fid.tns, '%g', [12 inf])';                              % list of transformations
fclose(fid.tns);
transf      = [transfrm(frm, 1:4); transfrm(frm, 5:8); transfrm(frm, 9:12)]; % transformation matrix in camera coordinate
c2v         = [0   0   1; -1   0   0; 0   -1   0];                           % camera to velodyne transformation
pts.rtn     = c2v * transf(1:3, 1:3) * c2v';                                 % rotation    3x3
pts.trn     = c2v * transf(1:3, 4);                                          % translation 3x1
%% velodyne points [x, y, z total number of pointsx3]
fid.pts     = fopen(sprintf('%s%06d.bin', st.dr.pts, frm - 1), 'rb');        % read from directory of points
velodyne    = fread(fid.pts, [4 inf], 'single')';   
fclose(fid.pts);
pts.pts     = velodyne(:,1:3);                                               % velodyne points
%% post process velodyne points
pts.pts(:, 3) = pts.pts(:, 3) + 1.73;                                        % bias in z direction (dataset is recorded in velodyne coordinate)
tmp.bs      = (~((sqrt((pts.pts(:,1)).^2 + (pts.pts(:,2)).^2)) < st.vm.bs)); % filter false points in the blind spot
pts.pts     = pts.pts(tmp.bs, :);
tmp.in      = ((pts.pts(:,1) > st.vm.xb) & (pts.pts(:,1) < st.vm.xf) & ...   % filter points to inside/outside the local grid
               (pts.pts(:,2) > st.vm.yr) & (pts.pts(:,2) < st.vm.yl) & ...
               (pts.pts(:,3) > st.vm.zd) & (pts.pts(:,3) < st.vm.zu));
pts.pts     = pts.pts(tmp.in,:);
%% transformed velodyne points [x, y, z total number of pointsx3]
pts.ptn     = pts.pts * pts.rtn' ...                                         % transformed points (Xp = RX + T)
            + repmat(pts.trn', size(pts.pts, 1), 1);

end

%% object grids
function mat = grd(pts, st)        % [transformed velodyne points, velodyne points, rotation, translation]

%% quantize and transform point's index
idx.qan   = floor([pts.pts(:,1)/st.vx.x, pts.pts(:,2)/st.vx.y]);                         % index quantized   [x: -175 ~ +274][y: -75 ~ +74]
idx.qat   = [idx.qan(:,1) - st.vm.xb/st.vx.x + 1, idx.qan(:,2) - st.vm.yr/st.vx.y + 1];  % index transformed [x:    1 ~ +450][y:  1 ~ +150]
%% results: matrix data, histogram, mean, maximum [his, ave, var, max]
ix        = (st.vm.xf - st.vm.xb)/st.vx.x; iy = (st.vm.yl - st.vm.yr)/st.vx.y;           % mat size       
cll       =  cell(ix, iy);   mid.his = zeros(ix, iy);   mid.ave = zeros(ix, iy);         % spatial matrix with point cloud data
mid.var   = zeros(ix, iy);   mid.max = zeros(ix, iy);
idx.idx   = false(ix, iy);   idx.idv = false(ix, iy);   idx.idm = false(ix, iy); 
idx.val   = false(ix, iy);   idx.obj = zeros(ix, iy);
for  i    = 1:ix                                                                         % initialize
 for j    = 1:iy
   idx.idx  = (idx.qat(:, 1) == i) & (idx.qat(:, 2) == j);                               % indexes
   if sum(idx.idx) ~= 0                                                                  % if cell is not empty
   cll{i, j}        = pts.pts(idx.idx, 3);                                               % store point data in cells
   mid.ave(i, j)    = mean(cll{i, j});                                                   % average: sum/number
   mid.var(i, j)    = var(cll{i, j});                                                    % variance
   mid.max(i, j)    = max(cll{i, j});                                                    % maximum
   idx.val(i, j)    = ~isempty(cll{i, j});                                               % valid data binary   
   end
 end
end
%% remove road: indexes for 'low variance', 'low height' and 'object'(non-road) cells 
idx.idv = (mid.var < st.rd.vr);                             % low variance blocks show road surface or car roof!
idx.idm = (mid.max < st.rd.mx);                             % low height blocks show road and object with low height!
idx.obj = ~(idx.idv .* idx.idm);                            % object index (road blocks should have variance and height lower than a threshold)
%% refinement of object indexs: strengthen non-statistical feature of max by filtering out weak objects
for  i  = 1:ix                                              % initialize
 for j  = 1:iy
   if idx.obj(i, j) ~= 0                                    % check previously computed object cells
   mid.his(i, j) = sum(cll{i, j} >= st.rd.mx);              % Histogram: number of tall points for object cells
     if mid.his(i, j) ~= 0 && mid.his(i, j) < st.vm.tr      % if number of tall points for that object cell is less than a 'threshold'
     idx.obj(i, j) = false;                                 % filter out those object cells
     end                                         
   end
 end
end
%% matrix to vector (rsl.pts, rsl.ptn)
mat.ind   = idx.val;                                        % valid parts
mat.mat   = idx.obj .* mid.ave;                             % matrix [ave, var, max]
ivx       = 1:size(cll, 1);                                 % vxl pts at the origin
ivy       = 1:size(cll, 2);                                 % index vector
[iy, ix]  = meshgrid(ivy, ivx);                             % notice! ivy ivx
mat.pts   = [(ix(:) - 1) * st.vx.x + st.vm.xb, ...          % map vector at origin
             (iy(:) - 1) * st.vx.y + st.vm.yr, mat.mat(:)]; % for test!
ptm       = pts.rtn * mat.pts(:, 1:3)';                     % vxl pts in the world coordinates
mat.ptn   = [ptm(1,:)' + pts.trn(1), ptm(2,:)' + pts.trn(2), ...
             mat.pts(:, 3)];                                % map vector at real coord

end
