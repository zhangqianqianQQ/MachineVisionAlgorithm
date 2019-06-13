function id = SelectIdleGpu()
% id = SelectIdleGpu()
%
% Selects idle GPU.
% It's a bit hacky since it actually checks if less than 400 MB GPU memory is used.
% There is no way yet in Matlab to check how active the GPU is currently.
%
% id:       index. Call gpuDevice(id) afterwards (maybe not even necessary);

persistent theId;
if ~isempty(theId)
    id = theId;
    return;
end

numGpus = gpuDeviceCount;

for id = numGpus : -1 : 1
    g = gpuDevice(id);
    
    if isprop(g, 'AvailableMemory')
        memUsed = g.TotalMemory - g.AvailableMemory;
    else
        memUsed = g.TotalMemory - g.FreeMemory;
    end
    
    if memUsed < 4e8
        theId = id;
        return
    end
end

warning('No GPU available');
id = [];
