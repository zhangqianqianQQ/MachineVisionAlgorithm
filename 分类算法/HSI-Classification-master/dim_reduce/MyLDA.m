function varargout=MyLDA(data,mode,param)
% Perform LDA using the built-in fitcdiscr and prediction function
% Input: data- N*D matrix, each row is a D-dimensional sample
%             mode: 1- LDA model fitting, in which case param is the lable of samples
%                          2- LDA prediction,in which case param is the LDA projection matrix                        
% 2016-10-16, jlfeng
if mode==1
    varargout{1}=fitcdiscr(data,param);    
elseif mode==2
    [varargout{1},varargout{2},~]=predict(param,data);
else
    error('MyLDA: Invalid model.')
end