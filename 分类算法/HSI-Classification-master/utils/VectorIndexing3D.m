function vectors=VectorIndexing3D(tensor_in,idx)
% indexing vectors from a 3D tensor, 
%2016-10-15 jlfeng
if  ndims(tensor_in)~=3
    return
end
dims=size(tensor_in);
data=reshape(tensor_in,[dims(1)*dims(2), dims(3)]);
vectors=data(idx(:),:);

        