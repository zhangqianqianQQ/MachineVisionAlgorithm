if ~exist('lib','dir')
    mkdir('lib');
    unzip('http://wiki.epfl.ch/sgwt/documents/sgwt_toolbox-1.02.zip','lib')
end
run 'lib/sgwt_toolbox/sgwt_setpath.m'

