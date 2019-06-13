function [D] = buildData(positionX,positionY,param)
% This function build the adjency matrix from the locations of the nodes. 
% The nodes locations are given by positionX and positionY.
%
% Y. Kaloga. Version: 20-05-2019.
%
% Y. Kaloga, M. Foare, N. Pustelnik, and P. Jensen , Discrete Mumford-Shah 
% on graph for mixing matrix estimation, accepted in IEEE Signal Processing 
% Letters, 2019.


positionX = reshape(positionX,1,param.nb_nodes);
positionY = reshape(positionY,1,param.nb_nodes);
n2 = param.ny;
nloc = param.nb_nodes;
degree = param.degree;


%% AdjencyList
adjency_list = zeros(nloc,degree);

for i = 1:nloc
    if sum(sign(adjency_list(i,:))) ~= degree
        storage= inf*ones(degree,2); 
        for j = 1:nloc
            n = norm([positionX(i)-positionX(j),positionY(i)-positionY(j)]);
            if i~=j && n < storage(end,2)
                storage(2:end,:) = storage(1:end-1,:);
                storage(1,:) = [j,n];
                [~,idx] = sort(storage(:,2));
                storage = storage(idx,:);
            end
        end
    end
    adjency_list(i,:) = storage(:,1)';
end
data.adjency_list = adjency_list;


% data.edge = edge;
% data.polygon = polygon;
% data.node = node;
%% Differential Operator
ind = 1;
ind2 = 1;
dec = 0;
nedge = size(adjency_list(adjency_list>0),1);
D = sparse(n2*nedge,n2*nloc);
listedge = [];
for a=1:size(adjency_list,1)
    dec = (a-1)*n2;
    ind2 = 1 + dec;
    for b=1:size(adjency_list,2)
        for c =1:n2
            %%%%%%%%%%%%%%%%%%%% attention au critere qui permet de déusquer les
            %%%%%%%%%%%%%%%%%%%% "doublons" ~ismember(10^6*a+b+10^6*b+a)
            if adjency_list(a,b)>0
                D(ind,ind2) = 1;
                D(ind,n2*adjency_list(a,b)-n2+1+(c-1)) = -1;
                ind = ind + 1;
            else
            end          
            ind2 = ind2 + 1;
        end
        ind2 = 1 + dec ;% (a-1)*b+;% a*ind2+n2;
        listedge = [listedge',[a,b]']';
    end     %a*ind2+n2;
end
data.D = D;