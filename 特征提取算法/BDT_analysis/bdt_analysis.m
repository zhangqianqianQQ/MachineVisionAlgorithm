    

function bdt_analysis() %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Workspace initialization
%  The workspace is cleaned and some parameters and deffined
clear all ; % this removes all variables stored in your current workspace

% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% The next parameters are choosen to produce an optimal solution. I would
% recommend not to modify them, but they could be changed by the user to
% produce different scnearios.
%
% (1) <NoDT> The Number of Decission Trees to construct the embedded model.
%     For example:
%     NoDT = 100 ;
      NoDT = 100 ;
%
% (2) <seed> This parameter is the seed of the random-number generator. By
%     fixing it, we have controlled the randomness of the results and we 
%     could reproduce it at any moment. The seed could have any integer
%     value, but I would recommend to reset it always by ussing zero.
%     For example:
%     seed = 0 ;
      seed = 0 ;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all force ; % this closes all plotted figures
clc ; % this clears the command window log
rng(seed) ; % random seed is set here

disp( ['==============================================='] ) ;
disp( ['= Classification using Bagged Decission Trees ='] ) ;
disp( ['==============================================='] ) ; disp( char(10) ) ;


%% Loading and examinating the data
%  Data are read from an Excel or CSV file (genes at columns and samples at rows)
%  which must have the next structure:
%  - First column: the name of the class (cell-type, treatment, stage, etc)
%  - Second column: the name of the sample
%  - First row: a header with the name of the genes at each column. Notice
%  that the first two cells of the header corresponds to the sample's
%  class and samples's name.
tic ;  disp( [' - Loading data...'] ) ; disp( char(10) ) ;
[ input_file,input_path ] = uigetfile( {'*.csv','Comma Sparated Values (*.csv)';'*.xls','Excel 97-2003 (*.xls)';'*.xlsx','Excel 2010 (*.xlsx)'},'MultiSelect','off' ) ;
[ vector ] = strsplit( input_file,'.' ) ;
file_name = vector(1) ;
extension = vector(2) ;
if ( strcmp(extension,'csv') )
  T = readtable( [input_path,input_file],'Delimiter',',','ReadVariableNames',false ) ;
  classes_names = T{2:end,1} ;
  samples = T{2:end,2} ;
  if ( sum(sum(isnan(char(T{:,end})))) > 0 )
    genes = T{1,3:end-1} ;  
    data = str2double(T{2:end,3:end-1}) ;
  else
    genes = T{1,3:end} ;
    data = str2double(T{2:end,3:end}) ;
  end%if
  clear T ;
else
  if ( strcmp(extension,'xls') ||  strcmp(extension,'xlsx') )
    [ data,txt ] = xlsread( [input_path,input_file] ) ;
    classes_names = txt(2:end,1) ;
    samples = txt(2:end,2) ;
    genes = txt(1,3:end) ;
    clear txt ;
  else
    disp('   file-format error.')
    return ;
  end%if
end%if
whos('data','samples','classes_names','genes') ;
%  "data" is the matrix containing the normalized expression profiles from
%  single-cell qPCR data, with genes as columns and samples as rows. The
%  name of the genes at each column are in "genes", a row-vector.
%  Similarly, the name of each sample at each row of the "data" matrix are
%  stored in "cell_names", a column-vector. The names on these vectors must
%  be unique. The name of the classes at each row are stored in
%  "classes_names". This column vector has non-unique classes names.
N = size(data,1) ;
G = size(data,2) ;
classes_unique = unique( sort(classes_names) ) ;
K = size(classes_unique(:),1) ;
classes_keys = zeros(N,1) ;
classes_matrix = zeros(N,N) ;
% The population of classes can be introduced as a prior knowledge by
% indicating the frecuency of each class. A non informative prior should be
% a constant value for all the classes, for instances: 
  classes_prior = ones(K,1) ;
% Alternatively you can use your custom values.
% classes_prior = [ 1.42 , 1.42 , 0.4 , 0.25 , 0.5 , 0.20 , 0.07 , 1.42 , 1.42 ]' ;
  for k = 1:K 
    indexes = strcmp( classes_unique(k),classes_names ) ;
    classes_keys(indexes) = k ;
    classes_matrix = classes_matrix + 1.0*indexes*indexes' ;
  end%for
%  "classes_keys" is a column vector in which the classes names are mapped
%  to a key column-vector of integers.
fprintf('   dataset with %i samples, %i genes and %i unique classes.',N,G,K ) ; disp( char(10) ) ;


%% Building the model
%  The Bagged Decission Tree builds an ensemble with a fixed Number Of
%  Deicission Trees (NODT). The ensemble is generated for the whole dataset and the Out-Of-Bag (OOB)
%  infromation is stored for evaluation purposes.
tic ;  disp( [' - Building the model with ',num2str(NoDT),' trees...'] ) ;
dbt = TreeBagger( NoDT,data,classes_names,'names',genes,'method','classification','NVarToSample','all','oobvarimp','on','oobpred','on','Prior',classes_prior ) ;
fprintf('   ( +%0.2f s ) done!',toc) ; disp( char(10) ) ;


%% Biased evaluation of the model
%  This is a first test of the model, consisting of the prediction the
%  classes of the same dataset used for the trainning. This is a biased
%  evaluation that is not significant.
[ predicted_classes predicted_scores ] = predict( dbt,data ) ;
%  First, we plot the scores of all the predicted classes for each sample.
%  The color key corresponds to the actual class of each sample.
figure(1) ;  set(1,'WindowStyle','docked') ; clf ;
bp = nan(size(predicted_scores)) ;
colors = hsv(K+1) ;
h = [] ;
for k = 1:K
  indexes = classes_keys == k ;
  bp(indexes,k) = predicted_scores(indexes,k) ;
end%for
subplot(2,1,1) ; cla ;
hold on ;
  boxplot(bp,'Colors',colors) ;
hold off ;
grid on ;
xlim([1 K]) ; xlabel( 'Classes' ) ;
ylim([0 1]) ; ylabel( 'Scores' ) ; 
title('Scores of predicted classes (biased evaluation).') ;
set(gca,'XTick',[1:K]) ;
set(gca,'XTickLabel',classes_unique) ;
%  Second, we compute the confusion matrix (CM). The main diagonal of the
%  CM holds the number of correct classified samples. Otherwise, the
%  elements out of the main diagonal denotes wrongly classified samples.
[ cm cm_labels ] = confusionmat( classes_names,predicted_classes,'order',classes_unique ) ;
%  For a full inspection of the matrix, use the next command.
disp( dataset({cm,cm_labels{:}},'obsnames',cm_labels) ) ;
%  Alternatively, use a stacked-bar plot to visualize the proportions of
%  predicted classes for each class.
subplot(2,1,2) ; cla ;
hold on ;
  bar( cm,'stacked' ) ;
hold off ;
grid on ;
colormap( colors ) ;
xlabel( 'Classes' ) ; xlim([0 K]+0.5) ;
ylabel( 'Number of samples' ) ;
title('Fraction of predicted classes versus the actual ones (biased evaluation).') ;
legend( cm_labels,'EdgeColor',[1 1 1],'Location','NO','Orientation','horizontal' ) ;
set(gca,'XTick',[1:K]) ;
set(gca,'XTickLabel',cm_labels) ;


%% Evaluating the model with the OOB samples
%  This evaluation takes into account the out-of-bag (OOB) samples, that
%  have been not considered to build the model.
[ predicted_classes predicted_scores ] = oobPredict( dbt ) ;
figure(2) ; set(2,'WindowStyle','docked') ; cla ;
bp = nan(size(predicted_scores)) ;
colors = hsv(K+1) ;
h = [] ;
hold on ;
  for k = 1:K
    indexes = classes_keys == k ;
    bp(indexes,k) = predicted_scores(indexes,k) ;
  end%for
subplot(2,1,1) ;
hold on ;
  boxplot(bp,'Colors',colors) ;
hold off ;
grid on ;
xlim([1 K]) ; xlabel( 'Classes' ) ;
ylim([0 1]) ; ylabel( 'Scores' ) ; 
title('Scores of predicted classes (OOB evaluation).') ;
set(gca,'XTick',[1:K]) ;
set(gca,'XTickLabel',classes_unique) ;
[ cm cm_labels ] = confusionmat( classes_names,predicted_classes,'order',classes_unique ) ;
disp( dataset({cm,cm_labels{:}},'obsnames',cm_labels) ) ;
subplot(2,1,2) ; cla ;
hold on ;
  bar( cm,'stacked' ) ;
hold off ;
grid on ;
colormap( colors ) ;
xlabel( 'Classes' ) ; xlim([0 K]+0.5) ;
ylabel( 'Number of samples' ) ;
title('Fraction of predicted classes versus the actual ones (OOB evaluation).') ;
legend( cm_labels,'EdgeColor',[1 1 1],'Location','NO','Orientation','horizontal' ) ;
set(gca,'XTick',[1:K]) ;
set(gca,'XTickLabel',cm_labels) ;


%% Examining the errors of the individual models
%  To test the model objectively we use the OOB error (its missclasication
%  probability) and its margin (the difference between the score for the
%  actual class and the largest one for other classes) for each
%  individual tree and theirs cumulative values for the emsembled model.
figure(3) ; set(3,'WindowStyle','docked') ; cla ;
subplot(2,1,1) ; cla ;
hold on ;
  plot( oobError(dbt,'mode','individual'),'ro','Color',[1 0.2 0] ) ;
  curve=smooth(oobError(dbt,'mode','cumulative')) ;
  plot( curve,'r-','Color',[1 0.2 0] ) ;
  index=find(abs(diff(curve))<0.001*max(curve(:)),1) ;
  plot( [1,NoDT],curve(index)*[1 1],'r--','Color',[1 0.2 0] ) ;
hold off ;
grid on ;
xlabel( 'Number of trees in the ensemble' ) ; xlim([1 NoDT]) ;
ylabel( 'Misclassification probability' ) ; ylim([0 1]) ;
title( 'Missclassification probability for the OOB samples using an incremental ensembling.' ) ;
legend( {'Individual';'Cumulative';'Steady level'},'EdgeColor',[1 1 1],'Location','NE','Orientation','horizontal' ) ;
%  The margin can be considered as a confidence interval of the score. The
%  highest the margin, the bigger the confidence on the predicted class.
subplot(2,1,2) ; cla ;
hold on ;
  plot( oobMeanMargin(dbt,'mode','individual'),'bo','Color',[0 0.6 1] ) ;
  curve=smooth(oobMeanMargin(dbt,'mode','cumulative')) ;
  plot( curve,'r-','Color',[0 0.6 1] ) ;
  index=find(abs(diff(curve))<0.001*max(curve(:)),1) ;
  plot( [1,NoDT],curve(index)*[1 1],'r--','Color',[0 0.6 1] ) ;
hold off ;
grid on ;
xlabel( 'Number of trees in the ensemble' ) ; xlim([1 NoDT]) ;
ylabel( 'Margin' ) ; ylim([0 1]) ;
title( 'Mean of the margin for the OOB samples using an incremental ensembling.' ) ;
legend( {'Individual';'Cumulative';'Steady level'},'EdgeColor',[1 1 1],'Location','NE','Orientation','horizontal' ) ;


%% Examining the correlation among the predicted classes
%  The proximitry matrix is defined as the fraction of trees in the ensemble
%  for which any two observations land on the same leaf.
dbt = fillProximities( dbt ) ;
hold on ;
  HeatMap( dbt.Proximity,'ColumnLabels',classes_names,'RowLabels',classes_names,'Colormap',redgreencmap(20) ) ;
hold off ;
title('Proximity matrix.') ;


%% Examining the confidence of the invidual variables
%  The relevance of each gene on the emsenble may be computed as the
%  predictor importance. The predictor importance averages the changes in
%  the risk due to split on every predictor at each node for the whole
%  ensemble. This risk depends on the seleted split criterion (typically
%  GDI that measure the impurity of the node). "DeltaCritDecisionSplit"
%  measure the changes in the split criterion summed over splits on each
%  variable, averaged across the entire ensemble.
[ sorted_improvement_criteria sorted_improvement_keys ] = sort( dbt.DeltaCritDecisionSplit,'descend' ) ;
figure(4) ; set(4,'WindowStyle','docked') ; cla ;
hold on ;
  bar( sorted_improvement_criteria,'FaceColor',[0 0.6 1],'EdgeColor',[0 0.4 0.6] ) ;
hold off ;
grid on ;
xlabel( 'Genes' ) ; xlim([0 G]+0.5) ;
ylabel( 'Changes in the split criterion' ) ;
title('Predictor improvement in the split criterion (descending sorted).') ;
set( gca,'XTick',[1:G] ) ;
set( gca,'XTickLabel',genes(sorted_improvement_keys) ) ;


%% Examining the errors of the individual variables
%  Alternaitvely, the relevance of each variable may be computed by
%  "OOBPermutedVarDeltaError". This variable measures the increase in the
%  OOB prediction error if the values of that variables are permutted for
%  every tree, then averaged over the entire ensemble and lastly divided by
%  the standard deviation.
[ sorted_error_criteria sorted_error_keys ] = sort( dbt.OOBPermutedVarDeltaError,'descend' ) ;
figure(5) ; set(5,'WindowStyle','docked') ; cla ;
hold on ;
  bar( sorted_error_criteria,'FaceColor',[0 0.6 1],'EdgeColor',[0 0.4 0.8] ) ;
hold off ;
grid on ;
xlabel( 'Genes' ) ; xlim([0 G]+0.5) ;
ylabel( 'Effect on the prediction error' ) ;
title( 'Predictor improvement in the OOB error (descending sorted).' ) ;
legend( {'Error rate'},'EdgeColor',[1 1 1],'Location','NE' ) ;
set(gca,'XTick',[1:G]) ;
set(gca,'XTickLabel',genes(sorted_error_keys)) ;


%% Plotting the performance curves
figure(6) ; set(6,'WindowStyle','docked') ; cla ;
text_legend = [] ;
hold on ;
for k = 1:K
  [ fpr tpr threshold AUC(k) ] = perfcurve( classes_names,predicted_scores(:,k),classes_unique{k} ) ;
  plot(fpr,tpr,'Color',colors(k,:)) ;
  text_legend = [ text_legend ; {[classes_unique{k},' (',num2str(AUC(k)),')']} ] ;
end%for
 plot([0 1],[0 1],'g--','Color',[1 1 1]*0.5)
hold off ;
grid on ;
legend( [ text_legend(:) ; 'ND line' ] ,'EdgeColor',[1 1 1],'Location','SE' ) ;
title('ROC curve (TPR and FPR trade off).') ;
xlabel( '1-Specificity (FPR)' ) ; xlim([0 1]) ;
ylabel( 'Sensitivity (TPR)' ) ; ylim([0 1]) ;
figure(7) ; set(7,'WindowStyle','docked') ; cla ;
text_legend = [] ;
hold on ;
for k = 1:K
  [ ppv tpr threshold AUC(k) ] = perfcurve( classes_names,predicted_scores(:,k),classes_unique{k},'xcrit','ppv' ) ;
  plot(tpr,ppv,'Color',colors(k,:)) ;
  text_legend = [ text_legend ; {[classes_unique{k},' (',num2str(AUC(k)),')']} ] ;
end%for
hold off ;
grid on ;
legend( [ text_legend(:) ] ,'EdgeColor',[1 1 1],'Location','SW' ) ;
title('PR curve (PPV and TPR trade off).') ;
xlabel( 'Recall (TPR)' ) ; xlim([0 1]) ;
ylabel( 'Precission (PPV)' ) ; ylim([0 1]) ;


%% Plotting the tree and loading super cells
% Plotting the embedded tree
view(dbt.Trees{:},'mode','graph')
% Tracking a subset of cells along the tree
choice = questdlg(['Do you want to track a superclass along the tree?'],'Track Superclass','Yes','No','Yes');
switch choice
case 'Yes'
%  Data should be provided in a column TXT file with no header.
tic ;  disp( [' - Loading data...'] ) ; disp( char(10) ) ;
[ input_file_super,input_path_super ] = uigetfile( {'*.txt','One column text format (*.txt)'},'MultiSelect','off','Select File to Open',input_path ) ;
super_samples = readtable( [input_path_super,input_file_super],'Delimiter',',','ReadVariableNames',false ) ;
super_samples = super_samples{:,1} ;
indexes = zeros(N,1) ;
for k = 1:size(super_samples(:),1)
  indexes = indexes + strcmp( samples,super_samples(k) ) ;
end%for
super_indexes = indexes == 1 ;
import bioma.data.*
dm = DataMatrix( data(super_indexes,:),samples(super_indexes),genes ) ;
super_classes = classes_names(super_indexes) ;
super_classes_uinque = unique(sort(super_classes)) ;
colors = hsv( size(super_classes_uinque(:),1) ) ;
markers = { 'o' ; 's' ; 't' ; 'x' ; 'h' ; 'p' }' ;
%dm = DataMatrix(data,classes_names,genes) ;
embedded = dbt.Trees{:} ;
node = 1 ;
leave = 1 ;
splitting_variables = {} ;
splitting_values = [] ;
parents = ones(size(dm,1),1) ;
tree = [ 0 ] ;
family = parents(:)' ;
[ tree , family , splitting_variables , splitting_values ] = growtree( dm,embedded,node,leave,parents,tree,family,splitting_variables,splitting_values ) ;
tree = tree(:)' ;
count = size(tree,2) ;
[ x , y ] = treelayout( tree ) ;
figure(8) ; cla ; hold on ; xlim([0 1]) ; ylim([0 1]) ;
    h=[] ; legend_text = [] ;
    for k = 1:size(super_classes_uinque(:),1)
      legend_text = [ legend_text ; super_classes_uinque(k) ] ;
      h(k) = plot( 2,2,'k.-','Color',colors(k,:) ) ;
    end%for
for k = 1:1:size(splitting_variables(:),1)
    if sum( tree == k ) > 0 
      indexes2 = find( tree==k ) ;
      for j=1:size(indexes2(:),1)
        plot([x(k) x(indexes2(j))],[y(k) y(indexes2(j))],'k--','Color',[1 1 1]*0.5) ;
      end%if
      if sum( tree == k ) == 2
        text( -0.01+x(k),0.02+y(k),splitting_variables(k) ) ;
        population = [] ;        
        for i=1:size(super_classes_uinque(:),1)
          population = [ population ; sum( family(k,:).*strcmp(super_classes,super_classes_uinque(i))' ) ] ;
        end%for       
        for i=1:size(population(:),1)
          if sum( population(i) ) > 0
            plot( x(k)+0.005*i-0.005*size(super_classes_uinque(:),1)/1.75,y(k),'ro--','Color',colors(i,:),'MarkerSize',50*population(i)/size(super_classes,1) ) ;
          end%if
        end%for
      end%if
    else
      %plot(x(k),y(k),'r.') ;
        population = [] ;        
        for i=1:size(super_classes_uinque(:),1)
          population = [ population ; sum( family(k,:).*strcmp(super_classes,super_classes_uinque(i))' ) ] ;
          if population(i) > 0
            plot( x(k),y(k)+0.005*i-0.005*size(super_classes_uinque(:),1)/1.75,'ro--','Color',colors(i,:),'MarkerSize',50*population(i)/size(super_classes,1) ) ;
          end%if
        end%for
    end%if
    drawnow ;
end%for
hold off ;
legend( h(:),legend_text,'EdgeColor',[1 1 1],'Location','NE' ) ; set(gca,'XTick',[]) ; set(gca,'YTick',[]) ;
end%switch

set(8,'WindowStyle','docked') ;

% http://stackoverflow.com/questions/5065051/add-node-numbers-get-node-locations-from-matlabs-treeplot

end%function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ tree , family , splitting_variables , splitting_values ] = growtree( dm,embedded,node,leave,parents,tree,family,splitting_variables,splitting_values )

  if ~( strcmp(embedded.CutVar(leave),'') )
    c1 = ( parents.*( dm( :,embedded.CutVar(leave) ) < embedded.CutPoint(leave) ) ) == 1 ;
    node1 = 0 ;
    c2 = ( parents.*( c1 == 0 ) ) == 1 ;
    node2 = 0 ;
    if sum( c1 ) >= 2 % minimun number of children at last leave
      tree = [ tree(:) ; node ] ;
      family = [ family ; c1(:)' ] ;
      node1 = size(tree(:),1) ;
      splitting_variables = [ splitting_variables ; embedded.CutVar(leave) ] ;
      splitting_values = [ splitting_values ; embedded.CutPoint(leave) ] ;
      [ tree , family , splitting_variables , splitting_values ] = growtree( dm,embedded,node1,embedded.Children(leave,1),c1,tree,family,splitting_variables,splitting_values ) ;
    end%if
    if sum( c2 ) >= 2 % minimun number of children at last leave
      tree = [ tree(:) ; node ] ;
      family = [ family ; c2(:)' ] ;
      node2 = size(tree(:),1) ;
      splitting_variables = [ splitting_variables ; embedded.CutVar(leave) ] ;
      splitting_values = [ splitting_values ; embedded.CutPoint(leave) ] ;
      [ tree , family , splitting_variables , splitting_values ] = growtree( dm,embedded,node2,embedded.Children(leave,2),c2,tree,family,splitting_variables,splitting_values ) ;
    end%if
  end%if

end%function


