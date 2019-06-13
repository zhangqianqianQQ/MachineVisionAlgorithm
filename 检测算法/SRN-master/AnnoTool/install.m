rootpath = strrep(fileparts(mfilename('fullpath')),'\','/');

% add the external toolbox: edges-master, piotr_toolbox, LBPcode
addpath(genpath([rootpath '/External/']));

% add the VOCdevkit
VOC2011Path = '\\samba.ee.oulu.fi\r-imag\personal\wke\VOC2011';
addpath(genpath(VOC2007Path));