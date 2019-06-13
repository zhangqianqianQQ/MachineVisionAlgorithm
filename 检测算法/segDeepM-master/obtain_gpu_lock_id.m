function id = obtain_gpu_lock_id(no_error)
%OBTAIN_GPU_LOCK_ID get a free Nvidia GPU id to use and lock it
%
%     id = obtain_gpu_lock_id([no_error]);
%
% Inputs:
%     no_error - if true, return id=-1 rather than throwing an error
%                Default: false.
%
% Outputs:
%          id  1x1 Integer id of free GPU.
%
% This is a discretionary locking scheme. It doesn't actually know anything
% about the real usage of GPUs.
%
% The lock will automatically be freed on ending the Matlab session.

% Iain Murray, November 2009

% Find gpu_lock utiltiy in set place on Toronto system:
gpu_lock = '/u/yukun/gpu_lock2.py';
if ~exist(gpu_lock, 'file')
    % Or find it in the same directory as this m-file.
    me = mfilename('fullpath');
    my_dir = me(1:find(me == filesep, 1, 'last'));
    gpu_lock = [my_dir, 'gpu_lock.py'];
    if ~exist(gpu_lock, 'file')
        error('Cannot find gpu_lock.py utility');
    end
end

if ~exist('no_error', 'var')
    no_error = false;
end

for i=0:3
    [status, result] = system(['exec ', gpu_lock, ' --ids ' num2str(i)]);
    if (status==0) && (str2num(result)~=-1)
        break;
    end
    if i==3
        error('cannot find a free GPU ID')
    end
end

if (status ~= 0)
    result = '-1';
end
id = str2num(result);

if (~no_error) && (id == -1)
    error('Was unable to lock a free GPU id.')
end
