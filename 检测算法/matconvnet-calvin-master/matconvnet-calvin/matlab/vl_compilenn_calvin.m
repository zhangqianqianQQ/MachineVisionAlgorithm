function vl_compilenn_calvin()
% vl_compilenn_calvin()
%
% Compile the C code provided in Matconvnet-calvin.
% Matconvnet code needs to be compiled separately.
%
% Copyright by Holger Caesar, 2016

root = calvin_root();
codeDir = fullfile(root, 'matconvnet-calvin', 'matlab');
mexDir = fullfile(codeDir, 'mex');
mexOpts = {'-largeArrayDims', '-outdir', sprintf('"%s"', mexDir)};

% E2S2-related
mex(mexOpts{:}, fullfile(codeDir, 'labelpresence', 'labelPresence_backward.cpp'));
mex(mexOpts{:}, fullfile(codeDir, 'regiontopixel', 'regionToPixel_backward.cpp'));
mex(mexOpts{:}, fullfile(codeDir, 'regiontopixel', 'regionToPixelSoft_backward.cpp'));
mex(mexOpts{:}, fullfile(codeDir, 'roipool', 'roiPooling_forward.cpp'));
mex(mexOpts{:}, fullfile(codeDir, 'roipool', 'roiPooling_backward.cpp'));

% Misc
mex(mexOpts{:}, fullfile(codeDir, 'misc', 'computeBlobOverlapAnyPair.cpp'));
mex(mexOpts{:}, fullfile(codeDir, 'misc', 'scoreBlobIoUs.cpp'));