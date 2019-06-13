function saveState(obj, fileName)
% saveState(obj, fileName)
%
% Save network and statistics for the current epoch.
% Depending on file size the net is saved in v7.3 format to allow nets with > 2GB size.
%
% Copyright by Holger Caesar, 2016

% Get fields from CalvinNN
net = obj.net;
stats = obj.stats; %#ok<NASGU>

% Extract the fields from the DAG class
net = net.saveobj() ; %#ok<NASGU>

% Determine whether to use new matfile format
netInfo = whos('net');
netSize = netInfo.bytes;
if netSize > 2e9,
    matVer = '-v7.3';
else
    matVer = '-v6';
end

% Save to file
save(fileName, 'net', 'stats', matVer);