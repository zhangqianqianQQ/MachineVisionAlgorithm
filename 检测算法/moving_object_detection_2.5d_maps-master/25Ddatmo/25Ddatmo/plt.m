function x = plt(x, k, pts, frm, st, frame)

%% record
fn              = frame - st.st.st + 1;                                    % frame number
for i           = 1 : size(k, 2)                                           % for every kalman filter
x(i).trc(fn, :) = [k(i).s.x(1) k(i).s.x(3)];                               % save the last estimate
if ~isempty(k(i).sz)
x(i).sz(fn, :)  = [k(i).sz(1) k(i).sz(2) k(i).sz(3)];                      % save size
end
x(i).trc((x(i).trc(:, 1).^2 + x(i).trc(:, 2).^2) == 0, :) = [];            % fix bug: start from middle puts zero on previous
x(i).sz((x(i).trc(:, 1).^2 + x(i).trc(:, 2).^2) == 0, :)  = [];
end
%% plot
clf
% subplot(3, 1, 1);   
pim(x, pts, frm, st, frame)                            % image
% subplot(3, 1, 2:3); pgr(x, pts, frm, st, frame)                            % grid
pause(0.02)

end

function pgr(x, pts, mat, st, frm)

hold on
vld(pts, st)                                                               % velodyne points   : pts.ptn
gds(mat, st);                                                              % 2.5d grid bars
crd(st)                                                                    % coordinate vector
boc(x, pts, st)                                                            % tracks and boxes
pst(st)                                                                    % setting           : st
hold off   
% title(['measurement no. ', num2str(frm), '/',num2str(st.st.tn)])
%% velodyne points
function vld(pts, st)
plot3(pts.pts(:, 1), pts.pts(:, 2), pts.pts(:, 3), st.pl.vl, 'MarkerSize', 1)
end    
%% coordinates
function crd(st)
v1  = quiver3(0, 0, 0.5, 1, 0, 0, st.pl.x);                                % coordinates
v2  = quiver3(0, 0, 0.5, 0, 1, 0, st.pl.y);
v3  = quiver3(0, 0, 0.5, 0, 0, 1, st.pl.z);
set(v1,'Color','r', 'LineWidth', 2, 'MaxHeadSize',2)                       % velodyne X red
set(v2,'Color','g', 'LineWidth', 2, 'MaxHeadSize',2)                       % velodyne Y green
set(v3,'Color','b', 'LineWidth', 2, 'MaxHeadSize',2)                       % velodyne Z blue
end
%% 2.5d grid
function gds(mat, st) 
lbl     = mat.lbl(:);    
for  i  = 1 : size(mat.pts, 1)                                             % initialize
if lbl(i) ~= 0                                                             % if it is object
st.pl.al = 0.4;                                                            % default color and opacity for object (0.3)
st.pl.cl = st.pl.cv(rem(lbl(i), size(st.pl.cv, 1)) + 1, :);
vxl([mat.pts(i, 1:2) 0], [st.vx.x st.vx.y mat.pts(i, 3)], st.pl.cl, st.pl.al);
end
end
end
%% voxel
function vxl(sr, sz, cl, al)  
vt.o  = [ 0 0 0; sz(1) 0 0; sz(1) sz(2) 0; 0 sz(2) 0; 0 sz(2) sz(3); 
          0 0 sz(3); sz(1) 0 sz(3); sz(1) sz(2) sz(3)];                    % vertices    
vt.t  = vt.o + repmat([sr(1) sr(2) sr(3)], 8, 1);
fc    = [ 1 2 3 4; 3 4 5 8; 1 4 5 6; 1 6 7 2; 2 3 8 7; 5 6 7 8];           % voxel faces 
h     = patch('Vertices', vt.t, 'Faces', fc, 'FaceColor', cl);             % plot faces
set( h, 'FaceAlpha', al);
end
%% plot tracks and boxes
function boc(x, pts, st)
for      i = 1 : size(x, 2)                                                % for every detected objects
if ~isempty(x(i).trc)                                                      % fixed bug!
ptrc(x(i).trc, pts, st, i);                                                   % plot for every track
if ~isempty(x(i).sz) 
pbox(x(i).trc, x(i).sz, pts, st, i);
end
end
end
end
%% compute each track in the vehicle coordinate
function ptrc(x, pts, st, i)
x   = pts.rtn \ ([x(:, 1)'; x(:, 2)'; zeros(1, size(x, 1))]...             % transform back world to origin (3 x n)
      - repmat(pts.trn, 1, size(x, 1))); x = x(1 : 2, :)';                 % change mat arrangement
idx = (x(: , 1) > st.vm.nxb) & (x(:, 1) < st.vm.nxf) &...                  % index of tracks inside the local grid
      (x(:, 2) > st.vm.nyr) &  (x(:, 2) < st.vm.nyl);
col = st.pl.cv(rem(i, size(st.pl.cv, 1)) + 1, :);  
plot3(x(idx, 1), x(idx, 2), ones(sum(idx), 1), 'Color', col, 'LineWidth', 2)        % measurement
plot3(x(idx, 1), x(idx, 2), ones(sum(idx), 1), 'k*', 'LineWidth', 3)       % estimate  
end
%% box
function pbox(m, n, pts, st, i)
m   = pts.rtn \ ([m(end, 1); m(end, 2); 0] - pts.trn);                     % transform back world to origin (3 x n)          
sta = [m(1) - n(end, 1)/2, m(2) - n(end, 2)/2, 0];                         % start
sz  = [n(end, 1), n(end, 2), n(end, 3)];                                   % size
ps  = [  0,  0, 0 ];                                                       % pose
cl  = [  0,  1, 0 ];                                                       % color
al  = 0;                                                                   % alpha
% check if it is inside local grid
if ((m(1) - n(end, 1)/2) > st.vm.nxb) && ((m(1) + n(end, 1)/2) <...         % index of tracks inside the local grid
   st.vm.nxf) && ((m(2) - n(end, 2)/2) > st.vm.nyr) && ((m(2) +  ...
   n(end, 2)/2) < st.vm.nyl)
col = st.pl.cv(rem(i, size(st.pl.cv, 1)) + 1, :);
pvxl(sta, sz, ps, cl, al, col);
end
end
%% voxel box
function pvxl(st, sz, ps, cl, al, col)
% vertices
vt.o  = [ st(1)           st(2)           st(3)           ;  % 1
          st(1) + sz(1)   st(2)           st(3)           ;  % 2
          st(1) + sz(1)   st(2) + sz(2)   st(3)           ;  % 3
          st(1)           st(2) + sz(2)   st(3)           ;  % 4
          st(1)           st(2) + sz(2)   st(3) + sz(3)   ;  % 5
          st(1)           st(2)           st(3) + sz(3)   ;  % 6
          st(1) + sz(1)   st(2)           st(3) + sz(3)   ;  % 7
          st(1) + sz(1)   st(2) + sz(2)   st(3) + sz(3)  ];  % 8
% transformation
ph    = degtorad(ps);                                        % degree to radian
rx    = [ 1       ,  0           ,  0           ;            % rotation around x-axis
          0       ,  cos(ph(1))  , -sin(ph(1))  ; 
          0       ,  sin(ph(1))  ,  cos(ph(1)) ]; 
ry    = [ cos(ph(2)),  0         ,  sin(ph(2))  ;            % rotation around y-axis 
          0         ,  1         ,  0           ; 
         -sin(ph(2)),  0         ,  cos(ph(2)) ];   
rz    = [ cos(ph(3)), -sin(ph(3)),  0           ;            % rotation around z-axis 
          sin(ph(3)),  cos(ph(3)),  0           ; 
          0         ,  0         ,  1          ];     
r     = rx * ry * rz;                                        % total rotation around xyz-axes
% transformed vertices      
vt.t  = (r * vt.o')';     
% voxel faces      
fc    = [ 1 2 3 4;  % a 
          3 4 5 8;  % b 
          1 4 5 6;  % c 
          1 6 7 2;  % d 
          2 3 8 7;  % e 
          5 6 7 8]; % f 
% plot box (voxel) - using patch
h     = patch('Vertices', vt.t, 'Faces', fc, 'FaceColor', cl);
set( h, 'FaceAlpha', al, 'EdgeColor', col, 'LineWidth', 2);
end
%% setting
function pst(st)
xlabel('X') 
ylabel('Y') 
zlabel('Z')
grid on
view(st.pl.az, st.pl.el)
axis equal tight
end

end

function pim(X, pts, mat, st, frm)

img     = imread( [st.dr.img, sprintf('%06d.png', frm - 1)] );             % load image
imshow(img)
hold on
% lcl(img, st)                                                             % local grid
% rod(img, st)                                                             % road grid
% vld(pts, img, st)                                                        % velodyne points   :       pts.pts
% crd(img, st)                                                             % coordinate vector :       img, st.pl, st.cr.bs
gds(mat, st, img)                                                          % bars (1 to show density): rsl.his, rsl.hei, rsl.max
% boc(X, pts, st, img)                                                       % tracks and boxes
hold off 
title(['measurement no. ', num2str(frm), '/',num2str(st.st.tn)])
%% plot tracks and boxes
function boc(x, pts, st, img)
for i = 1 : size(x, 2)                                                     % for every detected objects
if ~isempty(x(i).trc)                                                      % fixed bug!
% ptrc(x(i).trc, pts, st, img, i);                                              % plot for every track
end
if ~isempty(x(i).sz) 
ppbox(x(i).trc, x(i).sz, pts, st, img, i);
end
end
end
%% compute each track in the vehicle coordinate
function x = ptrc(x, pts, st, img, i)
x    = pts.rtn \ ([x(:, 1)'; x(:, 2)'; zeros(1, size(x, 1))]...            % transform back world to origin (3 x n)
       - repmat(pts.trn, 1, size(x, 1))); x(3, :) = ones(1, size(x, 2));   % change mat arrangement and set height
pxs  = clb(st, x', img);                                                   % project track points on image 
col = st.pl.cv(rem(i, size(st.pl.cv, 1)) + 1, :);
plot(pxs(:, 1), pxs(:, 2), 'k*', 'LineWidth', 3);                          % show - estimated track points projected into image
plot(pxs(:, 1), pxs(:, 2), 'Color', col, 'LineWidth', 2);
end
%% box %% clb - needs new set
function ppbox(m, n, pts, st, img, i)
m   = pts.rtn \ ([m(end, 1); m(end, 2); 0] - pts.trn);                     % transform back world to origin (3 x n) 
sta = [m(1) - n(end, 1)/2, m(2) - n(end, 2)/2, 0];                         % start
sz  = [n(end, 1), n(end, 2), n(end, 3)];                                   % size
al  = 0;                                                                   % alpha
ppvxl(sta, sz, img, st, al, i)
end
%% voxel box
function ppvxl(sr, sz, img, st, al, i)  
vt.o  = [ 0 0 0; sz(1) 0 0; sz(1) sz(2) 0; 0 sz(2) 0; 0 sz(2) sz(3); 
          0 0 sz(3); sz(1) 0 sz(3); sz(1) sz(2) sz(3)];                    % vertices
vt.t  = vt.o + repmat([sr(1) sr(2) sr(3)], 8, 1);
pxs   = clb(st, vt.t, img);
if size(pxs, 1) == 8
col   = st.pl.cv(rem(i, size(st.pl.cv, 1)) + 1, :);    
fc    = [ 1 2 3 4; 3 4 5 8; 1 4 5 6; 1 6 7 2; 2 3 8 7; 5 6 7 8];           % voxel faces 
h     = patch('Vertices', pxs, 'Faces', fc, 'FaceColor', st.pl.cl);        % plot faces
set( h, 'FaceAlpha', al, 'EdgeColor', col, 'LineWidth', 2);
end
end
%% velodyne points
function vld(pts, img, st)
pxs  = clb(st, pts.pts, img);                                              % project velodyne points on image
plot(pxs(:,1),pxs(:,2),'.b', 'MarkerSize', 1);                             % show - velodyne points projected into image
end
%% coordinates
function crd(img, st)
crds = [st.cr.bs + 0, 0, 0; st.cr.bs + 1, 0, 0;                            % comute start and end points of coordinates
        st.cr.bs + 0, 1, 0; st.cr.bs + 0, 0, 1];
pxs  = clb(st, crds, img);                                                 % project coordinates into image
if size(pxs, 1) == 4
% show - coordinates projected into image
v1   = quiver(pxs(1,1), pxs(1,2), pxs(2,1) - pxs(1,1), pxs(2,2) - pxs(1,2), st.pl.x); % coordinates
v2   = quiver(pxs(1,1), pxs(1,2), pxs(3,1) - pxs(1,1), pxs(3,2) - pxs(1,2), st.pl.y);
v3   = quiver(pxs(1,1), pxs(1,2), pxs(4,1) - pxs(1,1), pxs(4,2) - pxs(1,2), st.pl.z);
set(v1,'Color','r', 'LineWidth', 2, 'MaxHeadSize',2)                       % velodyne X red
set(v2,'Color','g', 'LineWidth', 2, 'MaxHeadSize',2)                       % velodyne Y green
set(v3,'Color','b', 'LineWidth', 2, 'MaxHeadSize',2)                       % velodyne Z blue
end
end
%% 2.5d grid on image
function gds(mat, st, img)
lbl     = mat.lbl(:);    
for  i  = 1 : size(mat.pts, 1)                                             % initialize
if lbl(i) ~= 0                                                             % if it is object
st.pl.al = 0.2;                                                            % default color and opacity for object (0.3)
st.pl.cl = st.pl.cv(rem(lbl(i), size(st.pl.cv, 1)) + 1, :);
vxl([mat.pts(i, 1:2) 0], [st.vx.x st.vx.y mat.pts(i, 3)], img, st);
end
end
end
%% local grid frame
function lcl(img, st)  
                                                                           % show right face, left face, bottom face    
lgr  = [st.cr.bs, st.vm.yr, st.vm.zd;                                      % right face:  brd [x, y, z: behind, right, down]  
        st.cr.bs, st.vm.yr, st.vm.zu;                                      %              bru [x, y, z: behind, right, up]
        st.vm.xf, st.vm.yr, st.vm.zu;                                      %              fru [x, y, z: front, right, up] 
        st.vm.xf, st.vm.yr, st.vm.zd];                                     %              frd [x, y, z: front, right, down]
lgl  = [st.cr.bs, st.vm.yl, st.vm.zd;                                      % left face:   bld [x, y, z: behind, left, down]  
        st.cr.bs, st.vm.yl, st.vm.zu;                                      %              blu [x, y, z: behind, left, up]
        st.vm.xf, st.vm.yl, st.vm.zu;                                      %              flu [x, y, z: front, left, up] 
        st.vm.xf, st.vm.yl, st.vm.zd];                                     %              fld [x, y, z: front, left, down]
lgb  = [st.vm.xf, st.vm.yr, st.vm.zd;                                      % bottom face: frd [x, y, z: front, right, down]  
        st.vm.xf, st.vm.yr, st.vm.zu;                                      %              fru [x, y, z: front, right, up]
        st.vm.xf, st.vm.yl, st.vm.zu;                                      %              flu [x, y, z: front, left, up] 
        st.vm.xf, st.vm.yl, st.vm.zd];                                     %              fld [x, y, z: front, left, down]    
pxr  = clb(st, lgr, img, 1);                                               % project right face of the local grid points into image
pxl  = clb(st, lgl, img, 1);                                               % project left face of the local grid points into image
pxb  = clb(st, lgb, img, 1);                                               % project bottom face of the local grid points into image
if (size(pxr, 1) == 4) && (size(pxl, 1) == 4) && (size(pxb, 1) == 4)
plot([pxr(:, 1); pxr(1, 1)], [pxr(:, 2); pxr(1, 2)], 'g', 'LineWidth', 1)
plot([pxl(:, 1); pxl(1, 1)], [pxl(:, 2); pxl(1, 2)], 'g', 'LineWidth', 1)
plot([pxb(:, 1); pxb(1, 1)], [pxb(:, 2); pxb(1, 2)], 'g', 'LineWidth', 1)
end
end
%% road
function rod(img, st)                                                      % road grid
[x, y] = meshgrid(st.cr.bs:st.vx.x:st.vm.xf, st.vm.yr:st.vx.y:st.vm.yl);
csp  = [x(:), y(:), zeros(size(y(:), 1), 1)];                              % cross points
pxs  = clb(st, csp, img);                                                  % project road points into image
if st.vm.zd > 0; mrk = '+r'; else mrk = '+g'; end
plot(pxs(:, 1), pxs(:, 2), mrk, 'LineWidth', 1)
end
%% voxel
function vxl(sr, sz, img, st)  
vt.o  = [ 0 0 0; sz(1) 0 0; sz(1) sz(2) 0; 0 sz(2) 0; 0 sz(2) sz(3); 
          0 0 sz(3); sz(1) 0 sz(3); sz(1) sz(2) sz(3)];                    % vertices
vt.t  = vt.o + repmat([sr(1) sr(2) sr(3)], 8, 1);
pxs   = clb(st, vt.t, img);
if size(pxs, 1) == 8
fc    = [ 1 2 3 4; 3 4 5 8; 1 4 5 6; 1 6 7 2; 2 3 8 7; 5 6 7 8];           % voxel faces 
h     = patch('Vertices', pxs, 'Faces', fc, 'FaceColor', st.pl.cl);        % plot faces
set( h, 'FaceAlpha', st.pl.al);
end
end

end

function pxs = clb(st, pnt, img, flag)                                     % calibration - velodyne to image

if nargin == 4; fl = flag; else fl = 0; end                                % remove points outside image or not? (flag = 1 -> remove)
T   = calib(st);                                                           % read and provide calibration matrixes P2 & Tr
pxs = ind(T, pnt, img, fl);                                                % projection of points on image
function T = calib(st)
%% calibration - read calibration matrixes P2 & Tr
fid.clb    = fopen([st.dr.clb,'calib.txt']);                               % read matrixes Pi & Tr
data       = fscanf(fid.clb,'%c');                                         % load calibration data
fclose(fid.clb);
sl         = find(data == ':') + 1;                                        % locations of start of the lines
el         = find(data == 10 );                                            % locations of end of the lines
T.P2       = str2num( data(sl(3):el(3)) );                                 % load calibration for left camera(its from start to the end of the line 3)
T.Tr       = str2num( data(sl(5):el(5)) );                                 % load transformation(its from start to the end of the line 5)
T.P2       = reshape(T.P2,4,3)'; T.P2(4,:) = [0 0 0 1];                    % reshape calibrations
T.Tr       = reshape(T.Tr,4,3)'; T.Tr(4,:) = [0 0 0 1];                    % Tr transforms a point from velodyne coordinates into the left rectified 
                                                                           % camera coordinate system.
end
function pxs = ind(T, pnt, img, fl)                                        % project velodyne points on image
%% filter a
pne        = [pnt zeros(size(pnt, 1), 1)];                                 % points extended
pne(:, 3)  = pne(:, 3) - 1.73;                                             % send back to velodyne coordinate (for valid transformation)
idx.f      = pne(:,1) >= 0;                                                % index of points in front of the car (points visible on the image)
pnt        = pne(idx.f, :);                                                % points visible on the image 
%% projection
pxs        = (T.P2 * T.Tr * pnt')';                                        % map a point X from the velodyne scanner to image plane: x = Pi * Tr * X
pxs(:,1)   = pxs(:,1) ./ pxs(:,3);                                         % point's x & y are cor. to image's c & nr - r (nr: number of raws)
pxs(:,2)   = pxs(:,2) ./ pxs(:,3);
pxs        = round(pxs(:, 1:2));                                           % interpolate (it is not that much precise, round is enough!)
%% filter b
if fl == 0;                                                                % default
idx.i      = (pxs(:,1) >= 1) & (pxs(:,1) <= size(img, 2)) & ...            % index of points that are inside image 
             (pxs(:,2) >= 1) & (pxs(:,2) <= size(img, 1));                 % index of points that r inside local grid & in front of car & inside image
pxs        = pxs(idx.i, :);                                                % pixels 
end
end

end

