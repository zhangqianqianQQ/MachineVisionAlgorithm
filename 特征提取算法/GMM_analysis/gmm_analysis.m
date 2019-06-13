

function [] = gmm_analysis()


%% Workspace initialization
%  The workspace is cleaned and some parameters and deffined
clear all ; % this removes all variables stored in your current workspace

% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% The next parameters are choosen to produce an optimal solution. I would
% recommend not to modify them, but they could be changed by the user to
% produce different scnearios.
%
% (1) <seed> This parameter is the seed of the random-number generator. By
%     fixing it, we have controlled the randomness of the results and we 
%     could reproduce it at any moment. The seed could have any integer
%     value, but I would recommend to reset it always by ussing zero.
%     For example:
%     seed = 0 ;
      seed = 0 ;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

import bioma.data.* % loads the DataMatrix class
close all force ; % this closes all plotted figures
clc ; % this clears the command window log
rng(seed) ; % random seed is set here

disp( ['================================'] ) ;
disp( ['= Multimodal Gaussian analysis ='] ) ;
disp( ['================================'] ) ; disp( char(10) ) ;


%% Loading and examinating the data
%  Data are read from an Excel or CSV file (genes at columns and samples at rows)
%  which must have the next structure:
%  - First column: the name of the class (cell-type, treatment, stage, etc)
%  - Second column: the name of the sample
%  - First row: a header with the name of the genes at each column. Notice
%  that the first two fields of the header corresponds to the sample's
%  class and samples's name.
   disp( [' - Loading data...'] ) ; disp( char(10) ) ;
   [ input_file,input_path ] = uigetfile( {'*.csv','Comma Sparated Values (*.csv)';'*.xls','Excel 97-2003 (*.xls)';'*.xlsx','Excel 2010 (*.xlsx)'},'MultiSelect','off' ) ;
   [ vector ] = strsplit( input_file,'.' ) ;
   file_name = vector(1) ;
   extension = vector(2) ;
   if ( strcmp(extension,'csv') )
     T = readtable( [input_path,input_file],'Delimiter',',','ReadVariableNames',false ) ;
     classes_names = T{2:end,1} ;
     samples = T{2:end,2} ;
     if ( sum(isnan(str2double(T{1,end}))) > 0 )
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
   C = size(classes_unique(:),1) ;
   classes_keys = zeros(N,1) ;
   classes_matrix = zeros(N,N) ;
   dm = DataMatrix(data,classes_names,genes) ;
    
   
%% Initializing output file
  output_file = strjoin([input_path,file_name,'__qPCR_analysis.csv'],'') ;
  text_to_file = ['gene'] ;
  for c = 1:C
    text_to_file = [text_to_file,[',','mean_',num2str(c),char(177),'std_',num2str(c)]] ;
  end%for
  fileID = fopen(output_file,'w') ;
  fprintf(fileID,[text_to_file,char(10)]) ;
  fclose(fileID) ;
  
  
 %% Computing histograms 
    [ X Y ] = histogram( data,min(data(:)),max(data(:)),0.1 ) ; Y = Y/N ;
  for g = 1:G
    colors = hsv( C ) ; colors = hsv2rgb( rgb2hsv(colors).*[ones(C,1) 0.5*ones(C,1) ones(C,1)] ) ;
    figure( ceil(g/9) ) ;
    subplot(3,3,mod(g-1,9)+1) ; title( genes(g) ) ; grid on
    hold on ;
      h = [] ; legend_text = [] ;
      [ x y ] = histogram( data(:,g),min(data(:)),max(data(:)),0.1 ) ; y = y/N ;
      plot( x,abs(smooth(x,y)),'k--','LineWidth',1.2) ;
  % plotting individual histograms for each class =========================    
      for c = 1:C
        [ x y ] = histogram( data(strcmp(classes_names,classes_unique(c)),g),min(data(:)),max(data(:)),0.1 ) ;  y = y/N ;
        h(c) = plot( x,abs(smooth(x,y)),'-','Color',colors(c,:),'LineWidth',0.6 ) ;
        legend_text = [ legend_text ; classes_unique(c) ] ;
        drawnow ;
      end%for
  % computing the number of Gaussian modes ================================   
      options = statset('Display','off','MaxIter',50) ;
      disp( strjoin([' - Computing Gaussiam mixture model for',genes(g),'...']) ) ;      
      for c = 1:5
        warning off ;
        models{c} = gmdistribution.fit( data(:,g),c,'Replicates',100,'Regularize',eps,'Options',options ) ;
        %models{c} = gmdistribution.fit( data(data(:,g)>0.9*max(data(:))==0,g),c,'Replicates',100,'Regularize',eps,'Options',options ) ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        AIC(c) = models{c}.AIC ;
        warning on ;        
      end%for
      [ vals nodes ] = min( AIC ) ;
      colors = hsv( nodes ) ;
      text_to_file = [genes(g)] ;
      for k = 1:nodes
        mu = models{nodes}.mu(k) ;
        s2 = models{nodes}.Sigma(k) ;
        text_to_file = [text_to_file,[num2str(mu),char(177),num2str(sqrt(s2))]] ;
        x = X ;
        y = max( [ smooth( Y( (X(:)>=mu-sqrt(s2)).*(X(:)<= mu+sqrt(s2))==1,g ) ) ; 0 ] ).*exp(-0.5*(x-mu).^2/s2)/sqrt(2*pi*s2) ;
        plot( x,y,'-','Color',colors(k,:),'LineWidth',1.2 ) ;
        plot(mu,0,'^','Color',colors(k,:),'MarkerFaceColor',colors(k,:),'LineStyle','none','MarkerSize',5) ;
        drawnow ;
      end%for
      if mod(g-1,9) == 0 ; legend( h(:),legend_text,'EdgeColor',[1 1 1],'Location','NE' ) ; legend(gca,'boxoff') ; end%if
      xlim( [min(data(:)) max(data(:))] ) ;
      ylim( [0 min([1 1.1*max(smooth(Y(:,g)))])] ) ;
    hold off ; 
  % saving results ========================================================   
    fileID = fopen(output_file,'a') ;
    fprintf(fileID,[strjoin(text_to_file,','),char(10)]) ;
    fclose(fileID) ;
    set( gcf,'PaperPosition',[-0.5 -0.25 30+[1 0.5]] ) ; 
    set( gcf,'PaperSize',[0 0]+30) ;
    saveas( gcf,strjoin([input_path,file_name,'__qPCR0',num2str(ceil(g/9))],''),'pdf' ) ;
  end%for

end%function

function [ x,y ] = histogram( data,x_min,x_max,step )
  [ y x ] = hist( data,x_min:step:x_max ) ;
  return
end%for

