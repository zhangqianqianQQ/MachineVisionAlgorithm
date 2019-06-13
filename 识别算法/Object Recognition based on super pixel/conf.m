
% Simple check to see whether we have those files or not..
if exist('slicmex.mexw64', 'file')
    fprintf('It seems files are compiled. Lets move on..');
else
    mex slicmex.c;
    mex slicomex.c;
end