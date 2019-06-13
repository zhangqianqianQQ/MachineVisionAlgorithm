function varargout=MyPCA(data,mode,param)
% Perform PCA transformation
% Input: data- N*D matrix, each row is a D-dimensional sample
%             mode: 1- PCA with eigenvectors computed from the input data,
%                          2- PCA with given projection matrix in param
%                          param: when mode=1, can be a float number in range (0,1) or a interger number specifics the
%                                        number of components to preserve, when mode=2, param should be a projection matrix
% 2016-10-16, jlfeng

[~,num_dim]=size(data);
if 1==mode
    if (param>1)
        num_compnents=ceil(param);        
    elseif (param>0 && param<1)
        num_compnents=min(num_dim,ceil(num_dim*param));
    else
        disp('The number of components cannot be negative!');
        return;
    end
    [eigvectors,~,eigvalues]=pca(data,'NumComponents',num_compnents);
    varargout{1}=data*eigvectors;
    varargout{2}=eigvectors;
    varargout{3}=eigvalues;
elseif 2==mode
    if (size(param,1)~=num_dim)
        return;
    end
    varargout{1}=data*param;    
end