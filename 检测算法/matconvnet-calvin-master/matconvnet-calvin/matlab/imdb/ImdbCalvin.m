classdef ImdbCalvin < handle
    %IMDBCALVIN
    % Base image database that holds information about the
    % dataset and various retrieval functions, such as getBatch(..).
    %
    % Copyright by Holger Caesar & Jasper Uijlings, 2015
    
    properties
        numClasses
        datasetMode % train, val or test
        epoch
        misc        % structure for arbitrary other info

        data        % data.train data.val data.test
    end
    
    methods (Abstract)
        % This is the main method which needs to be implemented.
        % It is used by CalvinNN.train()
        [inputs, numElements] = getBatch(obj, batchInds, net, nnOpts);
    end
    
    methods
        function setDatasetMode(obj, datasetMode)
            % 'train', 'val', or 'test' set
            if ~ismember(datasetMode, {'train', 'val', 'test'}),
                error('Unknown datasetMode');
            end
            
            obj.datasetMode = datasetMode;
        end
        
        function allBatchInds = getAllBatchInds(obj)
            % Obtain the indices and ordering of all batches (for this epoch)
            switch obj.datasetMode
                case 'train'
                    allBatchInds = randperm(size(obj.data.train, 1));
                otherwise
                    allBatchInds = 1:size(obj.data.(obj.datasetMode), 1);
            end
        end
        
        function initEpoch(obj, epoch)
            obj.epoch = epoch;
        end
    end
end