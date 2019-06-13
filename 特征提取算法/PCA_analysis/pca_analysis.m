
%% Workspace initialization
%  The workspace is cleaned and some parameters and deffined
clear all ; % this removes all variables stored in your current workspace
close all force ; % this closes all plotted figures
clc ; % this clears the command window log

% PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Set up the next parameters as your convenience.
%
% (2) <PCA_level> This parameter must be an integer between 0 and 100.
%     It will be use to compute how many components you need explain a
%     given level of variance in the data.
%     For example:
%     PCA_level = 95 ;
      PCA_level = 95 ;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp( ['================'] ) ;
disp( ['= PCA analysis ='] ) ;
disp( ['================'] ) ; disp( char(10) ) ;


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
  if ( sum(strcmp(T{:,end},'')) > 1 )
    T(:,end) = [] ;
  end%if  
  classes = T{2:end,1} ;
  names = T{2:end,2} ;
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
    classes = txt(2:end,1) ;
    names = txt(2:end,2) ;
    genes = txt(1,3:end) ;
    clear txt ;
  else
    disp('   file-format error.')
    return ;
  end%if
end%if
whos('data','names','classes','genes') ;
%  "data" is the matrix containing the normalized expression profiles from
%  single-cell qPCR data, with genes as columns and samples as rows. The
%  name of the genes at each column are in "genes", a row-vector.
%  Similarly, the name of each sample at each row of the "data" matrix are
%  stored in "cell_names", a column-vector. The names on these vectors must
%  be unique. The name of the classes at each row are stored in
%  "classes_names". This column vector has non-unique classes names.
N = size(data,1) ;
G = size(data,2) ;
classes_unique = unique( sort(classes) ) ;
C = size(classes_unique,1) ;
classes_keys = zeros(N,1) ;
K = size(classes_unique(:),1) ;
for k = 1:C
    classes_keys(strcmp(classes_unique(k),classes)) = k ;
  end%for
  
% plotting parameters
  colors = hsv( C ) ;
  colors_soft = hsv2rgb( rgb2hsv(colors).*[ones(C,1) 0.5*ones(C,1) ones(C,1)] ) ;
  markers = {'+' 'o' '*' 's' 'x' 'd' '.' 'v' 'p' 'h'}' ;
  for k=1:ceil( C/size(markers,1)-1 )
    markers = [ markers(:) ; markers(:) ] ;
  end%for

  
%% PCA
%  PCA is calculated using the corresponding function from the MATLAB's
%  statistical toolbox. 
   disp( [char(10),'Performing PCA analysis...'] ) ;
   [coefficient,score,latent,tsquare,explained] = pca( data,'Algorithm','svd' ) ;
 % score*coefficient' = data - repmat(mean(data),size(data,1),1)
   PCA2 = rotatefactors(score(:,1:2),'Method','varimax') ;
   PCA3 = rotatefactors(score(:,1:3),'Method','varimax') ;
   IC = cumsum(explained) ;
   disp( ['  Information content on the two first component: ',num2str(round(IC(2))),'%.'] ) ;
   disp( ['  Information content on the three first component: ',num2str(round(IC(3))),'%.'] ) ;
% writing output
  output_file = strjoin( [ input_path,file_name,'__PCA.csv' ],'' ) ;
  fid = fopen(output_file,'w') ;
  for k = 1:N
    fprintf( fid,'%s,%s,%f,%f,%f\r\n',names{k},classes{k},PCA3(k,:) ) ;
  end%for  
  fclose(fid) ;
% plotting the 2D PCA    
    d = 0.1*( max(PCA2(:,1)) - min(PCA2(:,1)) ) ;
    x_min = min(PCA2(:,1))-d ;
    x_max = max(PCA2(:,1))+d ;
    d = 0.1*( max(PCA2(:,2)) - min(PCA2(:,2)) ) ;
    y_min = min(PCA2(:,2))-d ; 
    y_max = max(PCA2(:,2))+d ;
    [ x y ] = meshgrid( x_min:(x_max-x_min)/100:x_max,y_min:(y_max-y_min)/100:y_max ) ;
    x = x(:) ; y = y(:) ;
    classification_result = classify( [x y],PCA2(:,1:2),classes,'quadratic' ) ;
    figure(1) ; set(1,'WindowStyle','docked') ;
  % set(1,'WindowStyle','normal','units','normalized','outerposition',[0 0 1 1]) ;
    hold on ; cla ; title(['2D PCA plot and discriminant analysis classification.']) ;
    if C > 1
    for k = 1:C
      index = strcmp( classification_result,classes_unique(k) ) ;
      scatter( x(index),y(index),100,colors_soft(k,:),'s','fill' ) ;
    end%for
    end%if
    h=[] ; text = [] ;
    for k = 1:C
      index = [classes_keys == k] ;
      text = [ text ; unique(classes(index)) ] ;
      h(k) = plot( PCA2(index,1),PCA2(index,2),markers{k},'Color',colors(k,:) ) ;
    end%for
    hold off ; grid on ;
    legend( h(:),text,'EdgeColor',[1 1 1],'Location','EO' ) ;
    xlabel('PC1 (first component)') ; xlim([x_min x_max]) ;
    ylabel('PC2 (second component)') ; ylim([y_min y_max]) ; 
% plotting the 3D PCA 
    d = 0.1*( max(PCA3(:,3)) - min(PCA3(:,3)) ) ;
    z_min = min(PCA3(:,3))-d ; 
    z_max = max(PCA3(:,3))+d ; 
    figure(2) ; title(['3D PCA analysis.']) ;
    set(2,'WindowStyle','docked') ;
    cla ; hold on ; 
    for k = 1:C
      index = [classes_keys == k] ;
      plot3( PCA3(index,1),PCA3(index,2),PCA3(index,3),markers{k},'Color',colors(k,:),'MarkerFaceColor','none','LineWidth',0.1 ) ;
    end%for
    hold off ; grid on ; view(135,25) ;
    legend( text,'EdgeColor',[1 1 1],'Location','EO' ) ;    
    xlabel('PC1 (first component)') ; xlim([x_min x_max]) ;
    ylabel('PC2 (second component)') ; ylim([y_min y_max]) ; 
    zlabel('PC3 (third component)') ; zlim( [z_min z_max] ) ; 
% plotting PCA information
  figure(3) ; set(3,'WindowStyle','docked') ; cla ;   
  noc = min( sum(IC <= PCA_level)+1,G )  ;
  title(['PCA analysis. The ',num2str(PCA_level),'% is explained by the first ',num2str(noc),' copmonents.']) ;   
  subplot(2,2,[1,2]) ; title(['Percentage of explained variance accumulated at each PCA component.']) ;
  hold on ; cla ;
   bar( IC(1:noc),1,'r' ) ;
   bar( IC.*([zeros(noc,1);ones(numel(IC)-noc,1)]),1,'b' ) ;
  hold off ;
  grid on ;
  legend( {['Less or equal than ',num2str(PCA_level),'%.'],['More than the ',num2str(PCA_level),'%.']},'EdgeColor',[1 1 1],'Location','NW' ) ; 
  xlabel('component') ; xlim([0.5,size(IC,1)+0.5]) ;
  ylabel('% of variance') ; ylim( [0 100] ) ; 
  subplot(2,2,3) ; title('PCA reconstruction, using all the components.') ;
  hold on ; cla ; 
   imagesc( score*coefficient' + repmat(mean(data),size(data,1),1),[-1 1]*max(abs(data(:))) ) ;
   colormap( redgreencmap(100) ) ;
  hold off ;
  axis off ;
  subplot(2,2,4) ; title(['PCA approximation using ',num2str(noc),' of components.']) ;
  hold on ; cla ;
   imagesc( score*(coefficient.*[ones(G,noc) zeros(G,numel(IC)-noc)])' + repmat(mean(data),size(data,1),1),[-1 1]*max(abs(data(:))) ) ;
   colormap( redgreencmap(100) ) ;
  hold off ;
  axis off ; 
     
%% Picking data-points from the 2D plot
  choice = questdlg(['Do you want to identify a super class in you dataset?'],'Select superclass','Yes','No','Yes');
  switch choice
  case 'Yes'
    choice='No, I want to do it again' ;
    msgbox({'Select the data you are interested in by:','',' - doing click on a single point ',' - clicking and dragging to select all points in an area','','Press RETURN when you were ready.',''}) ;
    while strcmp(choice,'No, I want to do it again')
    figure(5) ; clf ; set(5,'WindowStyle','docked') ;
    hold on ;
    title(['2D PCA']) ;
    gscatter( PCA2(:,1),PCA2(:,2),classes,colors,strjoin([markers(1:C)'],'') ) ;
    hold off ; grid on ;
    xlim( [x_min x_max] ) ; xlabel('PCA1') ;
    ylim( [y_min y_max] ) ; ylabel('PCA2') ;
    legend( 'Location','EO' ) ;
    h=gname(names,5) ;
    superclass=get(h,'String') ; superclass=unique([superclass{:}]) ;
    fileID = fopen( strjoin( [ input_path,file_name,'__PCA_superclass.txt' ],'' ),'w' ) ;
    fprintf(fileID,'%s\r\n',superclass) ;
    fclose(fileID) ;  
    choice = questdlg(['You have selected ',num2str(size(h,1)),' data points.',char(10),'Do you want to keep this selection or do you want to try it again'],'Are you Happy with your selection?','Yes, it is fine','No, I want to do it again','No, I want to do it again');
    end%while
  end%switch    