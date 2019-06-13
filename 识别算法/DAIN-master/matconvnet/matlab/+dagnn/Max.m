classdef Max < dagnn.ElementWise
  %MAX DagNN max layer
  %   The Max layer takes the max of all its inputs and store the result
  %   as its only output.

  properties (Transient)
    numInputs
%     inputSize
  end

  methods
    function outputs = forward(obj, inputs, params)
      obj.numInputs = numel(inputs) ;
%       [h w d]=size(inputs{1});
%       obj.inputSize = ones(h,w,d);
      outputs{1} = inputs{1} ;
      for k = 2:obj.numInputs
          outputs{1} = max(outputs{1},inputs{k});
          
          
          
%           for hight = 1:h
%               for width = 1:w
%                   for depth = 1:d                      
%         if(outputs{1}(hight,width,depth) < inputs{k}(hight,width,depth)) 
%             outputs{1}(hight,width,depth) = inputs{k}(hight,width,depth);
%             obj.inputSize(hight,width,depth) = k;
%         end
%                   end
%               end
%           end
      end
    end

    function [derInputs, derParams] = backward(obj, inputs, params, derOutputs)
        sz = size(inputs{1});
        if numel(sz) < 4, sz(4) = 1; 
        sz(5) = obj.numInputs;
        tempinputs = single(zeros(sz));
        tempinputs = gpuArray(tempinputs);
        end
      for k = 1:obj.numInputs
          
          tempinputs(:,:,:,:,k) = inputs{k};
      end
         testinputs{1} = permute(tempinputs, [1 2 5 3 4]);
         sz_in = size(testinputs{1});
         [~, idx]  = mex_maxpool3d(testinputs{1},...
        'pool',[1,1,obj.numInputs], 'stride', [1,1,obj.numInputs], 'pad', [0,0,0,0,0,0]);
    
%          sz = size(derOutputs{1}); 
%          if numel(sz) < 4, sz(4) = 1; 
%          sz(5) = obj.numInputs;
%          tempoutputs = single(zeros(sz));
% %          tempoutputs = gpuArray(tempoutputs);
%          end
%          for k = 1:obj.numInputs
%              tempoutputs(:,:,:,:,k) = derOutputs{1};
%          end
        
         derOutputs{1} = permute(derOutputs{1}, [1 2 5 3 4]);
         derInputs{1} = mex_maxpool3d(derOutputs{1}, idx, sz_in ,...
        'pool',[1,1,obj.numInputs], 'stride', [1,1,obj.numInputs], 'pad', [0,0,0,0,0,0]);
         tempoutputs = permute(derInputs{1}, [1 2 4 5 3]);
         for k = 1:obj.numInputs
          
          derInputs{k} = tempoutputs(:,:,:,:,k);
         end
%         for hight = 1:h
%               for width = 1:w
%                   for depth = 1:d 
%                derInputs{obj.inputSize(hight,width,depth)}(hight,width,depth) = derOutputs{1}(hight,width,depth);
% %              if (obj.inputSize(hight,width,depth) ==k)        
% %           derInputs{k}(hight,width,depth) = derOutputs{1}(hight,width,depth) ; %not sure whether times obj.numInputs             
% %              end
%                   end
%               end
%         end
      
      derParams = {} ;
    end

    function outputSizes = getOutputSizes(obj, inputSizes)
      outputSizes{1} = inputSizes{1} ;
      for k = 2:numel(inputSizes)
        if all(~isnan(inputSizes{k})) && all(~isnan(outputSizes{1}))
          if ~isequal(inputSizes{k}, outputSizes{1})
            warning('Max layer: the dimensions of the input variables is not the same.') ;
          end
        end
      end
    end

    function rfs = getReceptiveFields(obj)
      numInputs = numel(obj.net.layers(obj.layerIndex).inputs) ;
      rfs.size = [1 1] ;
      rfs.stride = [1 1] ;
      rfs.offset = [1 1] ;
      rfs = repmat(rfs, numInputs, 1) ;
    end

    function obj = Max(varargin)
      obj.load(varargin) ;
    end
  end
end
