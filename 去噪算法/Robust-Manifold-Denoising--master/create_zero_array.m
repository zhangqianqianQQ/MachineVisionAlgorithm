function [full_wpall2]= create_zero_array(full_wpall, dim, params)

a=size(full_wpall);
full_wpall2 =  cell(1,params.Nscales+1,dim);
for i=1:dim
     
    wpall = full_wpall(:,:,i);
    for j=1:a(2)
        full_wpall2{:,j,i}= zeros( size(wpall{j} , 1), 1 );
    end
end

