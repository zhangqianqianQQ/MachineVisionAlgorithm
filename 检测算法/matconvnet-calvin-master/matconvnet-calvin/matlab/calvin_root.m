function[root] = calvin_root()
% [root] = calvin_root()
%
% Returns the absolute path to the root directory of matconvnet-calvin.
%
% Copyright by Holger Caesar, 2016

root = fileparts(fileparts(fileparts(mfilename('fullpath'))));