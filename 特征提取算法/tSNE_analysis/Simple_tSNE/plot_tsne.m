
%clear all ; close all ; clc

cd C:\Users\Manuel\Desktop\ana
load Simple_tSNE\results ;

% PLOTTING PARAMETERS % % % % % % % % % % % % % % % % % % % % % % % % % % %
marker = {'r+' 'go' 'b*' 'cx' 'ms' 'yd' 'kv'} ;
text = {} ;
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

%[pc,score,latent,tsquare] = princomp(data') ; Y = pc(:,1:size(Y,2)) ; [cumsum(latent)./sum(latent)] ; disp( ['The two first component have the ',num2str(ans(size(Y,2))*100),'% of the information within the original data. '] )

tags_list = unique( sort(tags(:)) )' ;

figure(1) ;
hold on ;

for k = tags_list
    
    index = [tags == k] ; 
    if ( size(Y,2) > 3 )
      disp( 'Unable to plot more than 3 dimensions.' )  
    else
       if ( size(Y,2) > 2 )
           plot3( Y(index,1),Y(index,2),Y(index,3),marker{k} ) ;
           view(45,30) ;
           grid on ;
       else
           plot( Y(index,1),Y(index,2),marker{k} ) ;
       end%if
    end%if
    text = [ text ; unique(classes(index)) ] ;
    
end%for

xlim([(min(Y(:,1))),(max(Y(:,1)))]) ;
ylim([(min(Y(:,2))),(max(Y(:,2)))]) ;

hold off ;
legend( text,'EdgeColor',[1 1 1],'Location','SE' ) ;