function [st, stack] = stt                                             % setting [directory, number of frames, map setting]

%% main directories
st.dr.nm   = '04';                                                     % dataset name
if     filesep == '/';  mdr = sprintf('%s','~');                       % linux
elseif filesep == '\';  mdr = sprintf('%s','D:');                      % windows  
end
st.dr.pts  = [mdr filesep 'dataset' filesep 'sequences' filesep ...                                        % directory of points
              st.dr.nm filesep 'velodyne' filesep]; 
st.dr.pose = [mdr filesep 'dataset' filesep 'poses' filesep];                                              % directory of poses
st.dr.img  = [mdr filesep 'dataset' filesep 'color' filesep st.dr.nm filesep 'image_2' filesep];           % directory of images
st.dr.clb  = [mdr filesep 'dataset' filesep 'calibration' filesep st.dr.nm filesep];                       % directory of calibration
st.dr.rec  = [filesep 'media' filesep 'ali' filesep 'TOSHIBA EXT' filesep 'result' filesep 'mar' filesep]; % directory of record
%% setting
st.st.st   = 1;                                                        % start frames
st.st.tn   = size(dir(sprintf('%s*.bin',st.dr.pts)),1);                % number of frames
%% local grid options
st.vm.xf   = +40;                                                      % x direction and front (x: -35 ~ +55)
st.vm.xb   = -20;                                                      % x direction and behind
st.vm.yl   = +12;                                                       % left and right (y: -15 ~ +15)
st.vm.yr   = -12; 
st.vm.zu   = 2.5;                                                      % z direction and up (z: 0 ~ +2.5)
st.vm.zd   = -1;                                                       % z direction and down
st.vm.nxf  = +30;                                                       % new x direction and front (x: -35 ~ +55)
st.vm.nxb  = -10;                                                       % new x direction and behind
st.vm.nyl  = +10;                                                       % new left and right (y: -15 ~ +15)
st.vm.nyr  = -10; 
st.vm.bs   = 3;                                                        % blind spot radius
st.vm.tr   = 1;                                                        % minimum number of points to make a valid voxel
%% cell size
st.vx.x    = 0.2;   % 0.2
st.vx.y    = 0.2;   % 0.2
st.vx.ix   = (st.vm.xf - st.vm.xb) / st.vx.x;                          % mat size 
st.vx.iy   = (st.vm.yl - st.vm.yr) / st.vx.y; 
%% road detection options
st.rd.vr   = 0.02;                                                     % road blocks should have variance lower than a threshold
st.rd.mx   = 0.8;                                                      % road blocks should have height lower than a threshold
%% stack option
st.stc.sz  = 90;                                                       % stack size (history)
st.stc.in  = 60;                                                       % number of integrating measurements
stack.mat  = zeros(st.vx.ix, st.vx.iy, st.stc.sz);                     % initialize stack  
stack.ind  = zeros(st.vx.ix, st.vx.iy, st.stc.sz);
stack.pts  = zeros(st.vx.ix* st.vx.iy, 3, st.stc.sz);                  % associated pts
stack.ptn  = zeros(st.vx.ix* st.vx.iy, 3, st.stc.sz);                  % associated ptn
%% foreground detection
st.fr.sz   = 2;                                                        % check neighbourhood (sensor error in x-y) 0.6
%% plot options
figure('units','normalized','outerposition',[0 0 1 1])  % figure()
st.pl.vl   = '.b';                                                     % velodyne point's shape and color
st.pl.cl   = 'g'; 
st.pl.az   = -25;                                                      % driverview (-90, 20) [azimuth, elevation]
st.pl.el   = 45;                                                       % globalview (-25, 45) topview(0, 90)
st.pl.x    = 0.5 * max(st.vm.nxf, abs(st.vm.nxb));                     % the coordinates size
st.pl.y    = 0.5 * st.vm.nyl;
st.pl.z    = st.vm.zu - st.vm.zd;
st.cr.bs   = 8;                                                        % coordinate bias to show on image
%% Colors
st.pl.cv   = zeros(15, 3);
st.pl.cv(1, :)   = [255, 0, 0] / 255;         % red
st.pl.cv(2, :)   = [0, 255, 0] / 255;         % green
st.pl.cv(3, :)   = [0, 0, 255] / 255;         % blue
st.pl.cv(4, :)   = [176, 23, 31] / 255;       % indian red
st.pl.cv(5, :)   = [30, 144, 255] / 255;      % dodger blue
st.pl.cv(6, :)   = [142, 142, 142] / 255;     % gray 56 
st.pl.cv(7, :)   = [142, 142, 56] / 255;      % olive lab
st.pl.cv(8, :)   = [255, 215, 0] / 255;       % gold
st.pl.cv(9, :)   = [128, 0, 128] / 255;       % purple
st.pl.cv(10, :)  = [205, 198, 115] / 255;     % khaki 3
st.pl.cv(11, :)  = [255, 20, 147] / 255;      % deep pink
st.pl.cv(12, :)  = [255, 165, 0] / 255;       % orange
st.pl.cv(13, :)  = [210, 180, 140] / 255;     % tan  
st.pl.cv(14, :)  = [139, 35, 35] / 255;       % brown 4 
st.pl.cv(15, :)  = [139, 69, 19] / 255;       % saddle brown
st.pl.cv(16, :)  = [0, 0, 0] / 255;           % black
st.pl.cv(17, :)  = [255, 255, 255] / 255;     % white

end
