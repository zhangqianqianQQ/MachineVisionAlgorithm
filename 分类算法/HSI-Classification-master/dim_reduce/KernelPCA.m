function varargout = KernelPCA(data,mode,varargin)
% Perform KPCA transformation
% Input: data- N*D matrix, each row is a D-dimensional sample
%             mode: 1- PCA with eigenvectors computed from the input data,
%                          2- PCA with given projection matrix in param
%                          param: when mode=1, can be a float number in range (0,1) or a interger number specifics the
%                                        number of components to preserve, when mode=2, param should be a projection matrix
% 2016-10-16, jlfeng
if nargin==3
   grammat=data;   
elseif nargin==6    
   grammat=GetKernelMat(varargin{2},data,varargin{3},varargin{4});
else
    error('Bad input! nargin should be 3 or 7.');
end
clear data;

if mode==1
     [n1,n2]=size(grammat);
    if n1~=n2
        error('The Gram matrix should be a Hermite matrix for mode 1.');
    end
    % Data centering   
    sum_row=sum(grammat,1);
    mat_temp=repmat(sum_row/n1,[n1 1]);
    grammat_c = grammat - mat_temp-mat_temp' +sum(sum_row)/(n1*n2);
    [eigvector, eigvalue] = eig(grammat_c);
    eigvalue = diag(eigvalue);    
    [~, idx_sort] = sort(eigvalue,1,'descend');
    eigvalue = eigvalue(idx_sort);
    eigvector = eigvector(:,idx_sort);
    
    % Compute the number components to preserve
    num_component=varargin{1};
    if num_component>=1 % fix number of components
        num_component=min(round(num_component),length(eigvalue));
    elseif num_component>0% fix energy ratio
        temp1=num_component*sum(abs(eigvalue));
        temp2=cumsum(abs(eigvalue));
        num_component=find(temp1-temp2<=0,1);        
    else
        error('The number of component should be non-negative.');
    end
    eigvalue = eigvalue(1:num_component);
    eigvector = eigvector(:,1:num_component);
    
    varargout{1}=grammat*eigvector;
    varargout{2}=eigvector;
    varargout{3}=eigvalue;
elseif mode==2
     varargout{1}=grammat*varargin{1};
end
    

