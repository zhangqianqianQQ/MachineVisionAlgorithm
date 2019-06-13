function [Ordered_Reversed_V]=Ordered_Reversed_Votes(Reversed_Votes,N,intrinsic_dimention,D,index_mat)
%% Reversed_Votes{i}(:,j) correspond to the stick tensor vote from point i emmited at point j
% Orderded_Reversed_Votes- votes emmitted at point i from j
%N=size(Data_STV,1);
%temp_nei_i=index_mat(:,i);
Ordered_Reversed_V=cell(1,N);
%intrinsic_dimetion=1;
I_D = eye(D);
for i=1:N
    temp_nei_i=index_mat(:,i);
    for j=1:length(temp_nei_i)
        idxNeig = temp_nei_i(j);
        Ordered_Reversed_V{idxNeig}=zeros(D*intrinsic_dimention,N);
        
        temp_votes=Reversed_Votes{i}(:,idxNeig);
        temp_votes=reshape(temp_votes,D,D);
        [Vec, Lam] = eig(temp_votes);
        temp_stick=zeros(intrinsic_dimention*D,1);
        if ~all(Vec==I_D)
            [L,J] = sort( diag(Lam) );
            for k = 1 : intrinsic_dimention
                %for k = 1 : D
                % temp_stick=zeros(intrinsic_dimetion*D,1); % FIX ME
                temp_stick((k-1)*D+1 :k*D) = Vec(:,J(D-k+1));
            end
            Ordered_Reversed_V{idxNeig}(:,i) = temp_stick;
        end
    end
end
