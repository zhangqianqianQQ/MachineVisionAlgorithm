function [x, L]= time_step_RBF_new(W,x,lambda,timestep,time_step_value)


% build the degree function ( d_i = sum_j w_ij)
W=sparse(W);
D=sum(W,2);
laplacian = 1;
[dim num] = size(x);
if nargin<5
    
            time_step_value=0.25;
            time_step_value=0.1;
            time_step_value=0.25;
             time_step_value=0.1;
              time_step_value=0.2;%% for depth 
               time_step_value=0.1;
end

% checks if elements of the degree function are zero and correct this
if(sum(D==0)>0)
    disp('Warning, Elements of d are zero');
    for i=1:num
        if(D(i)==0), D(i)=1; end
    end
end
% type of Laplacian (normalized, unnormalized)

% build the final weight matrix - reweighted by some power of the degree
% function \tilde{k}_ij = k_ij / pow(d_i d_j, lambda)
if(lambda~=0)
    f=spdiags(1./(D.^lambda), 0, num, num);
    W=1/(num)*f*W*f;
    clear f;
end
clear d

% final degree function of weights \tilde{k}
e=sum(W,2);
if(sum(e==0)>0)
    disp('Warning, Elements of e are zero');
    for i=1:num
        if(e(i)==0), e(i)=1/(num); end
    end
end

% for the time step it is easier to have the transpose of x
x=x';

tic
if(timestep==0)
    % explicit timestep
    D=spdiags(e,0,num,num);
    L=D-W;
    step=-0.1*L*x;
    x = x + step;
else
    % implicit timestep
    D=spdiags(e,0,num,num);
    
   
   
    L=sparse(D-W);
    %L=sparse(L);
    switch laplacian
        case 0,
            %normalized, solve L*x_new =x_old, where L=Id - E^{-1}W
            
            z=(D+0.25*L)\(D*x);
            % z=(D+0.1*L)\(D*x);
            diff = z - x;
            for i=1:num
                x(i,:) = x(i,:) + diff(i,:);
            end
        case 1,
            %unnormalized
            % z=cholmod(speye(num) + 0.5*L,x);

          
            z = (speye(num) + time_step_value*L)\x;
            diff = z - x;
            
            
            parfor i=1:num
                x(i,:) = x(i,:) + diff(i,:);
            end
            
            
    end
end

x=x'; % transform the data back in column format (one data point=one column in x)
t=toc;
% disp(['Time for time step: ', num2str(t),' seconds']);
% time_step_value