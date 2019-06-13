%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Objective : solve matrix estimation on graphs
%  Criterion : 
%      minimize_(M,e) \sum_n||Y_n - M_n X_n||^2 + ...
%                  beta \sum_(i,j\in  N_i) (1-e_ij)^2 ||M_i - M_j||^2 + ...
%                  lambda ||e||_quadl1
%
% Y. Kaloga. Version: 20-05-2019.
%
% Y. Kaloga, M. Foare, N. Pustelnik, and P. Jensen , Discrete Mumford-Shah 
% on graph for mixing matrix estimation, accepted in IEEE Signal Processing 
% Letters, 2019.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc
load('data_test.mat')
param.nx       = size(xloc,1);    
param.ny       = size(yloc,1);
param.nb_nodes = size(xloc,2);    % Nodes number
param.degree   = 8;               % Neighboorhood size
X              = xloc;   % X = (X_n)_n of size nx * nb_nodes
Y              = yloc;   % Y = (Y_n)_n of size ny * nb_nodes
param.beta     = 15;     % Regularization parameter controling smoothness
param.lambda   =  10^-5.5;   % Regularization parameter controling countour length
param.epsilon  = 1e-6;   % Stopping criterion
param.iter_max = 10000;    % Stopping criterion

% This step compute the adjency matrix D
D = buildData(positionX,positionY,param);

% Mumford-Shah iterations
results = ms(X,Y,D,param);
%results = msgpu(X,Y,D,param);


% Display the objective function
figure(1);
semilogy(results.objectiveFunction)

% Display ground truth
figure(2)
subplot(241);
showShp(Mground,polygon,"C2x3",true); title 'Ground truth';
subplot(245);
Frontierground = num2cell(Frontierground);
[edge.('Frontierground')] = Frontierground{:};
colormap('copper')
edgeColors = makesymbolspec('Line',{'Frontierground',[0   ,1],'Color',colormap});
geoshow(edge,'SymbolSpec',edgeColors)
colorbar
caxis([0 1])

% Display resutlts at convergence
subplot(244);
for x=1:param.ny
    for y=1:param.nx        
        for i=1:size(Mground,3)
            temp2(i) = round(results.Mloc(x,y,i),2);
        end
        temp3 = num2cell(temp2);
        columnName = strcat('C', strcat( num2str(x) ,strcat( 'x' , num2str(y) )  ) );
        [polytgonT.(columnName)] = temp3{:};        
    end
end
showShp(results.Mloc,polygon,'C2x3',true);title 'Result at convergence';

subplot(248);
Frontier = num2cell(double(results.Frontier > 0.7));
[edge.('Frontier')] = Frontier{:};
colormap('copper')
edgeColors = makesymbolspec('Line',{'Frontier',[0   ,1],'Color',colormap});
geoshow(edge,'SymbolSpec',edgeColors)
colorbar
caxis([0 1])


% Display results after 1 iterations
param.iter_max = 1;    % Stopping criterion
results = ms(X,Y,D,param);
subplot(242);
for x=1:param.ny
    for y=1:param.nx        
        for i=1:size(Mground,3)
            temp2(i) = round(results.Mloc(x,y,i),2);
        end
        temp3 = num2cell(temp2);
        columnName = strcat('C', strcat( num2str(x) ,strcat( 'x' , num2str(y) )  ) );
        [polytgonT.(columnName)] = temp3{:};        
    end
end
showShp(results.Mloc,polygon,'C2x3',true);title 'Result after 1 iteration';

subplot(246);
Frontier = num2cell(double(results.Frontier > 0.7));
[edge.('Frontier')] = Frontier{:};
colormap('copper')
edgeColors = makesymbolspec('Line',{'Frontier',[0   ,1],'Color',colormap});
geoshow(edge,'SymbolSpec',edgeColors)
colorbar
caxis([0 1])

% Display results after 100 iterations
param.iter_max = 50;    % Stopping criterion
results = ms(X,Y,D,param);
subplot(243);
for x=1:param.ny
    for y=1:param.nx        
        for i=1:size(Mground,3)
            temp2(i) = round(results.Mloc(x,y,i),2);
        end
        temp3 = num2cell(temp2);
        columnName = strcat('C', strcat( num2str(x) ,strcat( 'x' , num2str(y) )  ) );
        [polytgonT.(columnName)] = temp3{:};        
    end
end
showShp(results.Mloc,polygon,'C2x3',true);title 'Result after 50 iterations';

subplot(247);
Frontier = num2cell(double(results.Frontier > 0.7));
[edge.('Frontier')] = Frontier{:};
colormap('copper')
edgeColors = makesymbolspec('Line',{'Frontier',[0   ,1],'Color',colormap});
geoshow(edge,'SymbolSpec',edgeColors)
colorbar
caxis([0 1])