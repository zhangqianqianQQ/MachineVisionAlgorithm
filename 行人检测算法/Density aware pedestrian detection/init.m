function startup(rootpath)


if (~exist('rootpath'))
    rootpath = cd;
end;

cd('..');
cd_up   = pwd;
cd(rootpath);
addpath(genpath(rootpath));

