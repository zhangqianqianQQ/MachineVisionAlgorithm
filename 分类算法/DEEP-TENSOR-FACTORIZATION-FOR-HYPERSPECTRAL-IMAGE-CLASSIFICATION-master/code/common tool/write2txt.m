function write2txt(layer,initial,type,varargin)
% save middle results to txt file
% layer: the number of layers
% initial: initial features of first hidden layer
% type: deliver data file you want to save
% varargin{1}: decide which kind of file you want to save:
%              1 Accuracy;2 dnorm;3 H;4 Z
% varargin{2}: string states kind of accuacy you want to save
switch varargin{1}
    case 1
        fid = fopen(['E:\Workspace\Deep-Semi-NMF-master\matlab\Log\accuracy\LogOfAccuracy_' varargin{2} '.txt'],'w+');
        fprintf(fid,'features:\t');
        for iter_feature = 1:10
            fprintf(fid,[num2str(initial+10*iter_feature) ';' num2str(initial+10*(iter_feature-1)) ';' num2str(initial+10*(iter_feature-2)) '\t']);
        end
        fprintf(fid,'\n');
        for iter_layer = 1:layer
            fprintf(fid,'H%d:',iter_layer);
            for iter_feature = 1:10
                fprintf(fid,[num2str(type{iter_layer,iter_feature}) '\t']);
            end
            fprintf(fid,'\n');
        end
    case 2
        fid = fopen(['E:\Workspace\Deep-Semi-NMF-master\matlab\Log\dnorm\LogOfDnorm_' varargin{2} '.txt'],'w+');
        fprintf(fid,'features:\t');
        for iter_feature = 1:10
            fprintf(fid,[num2str(initial+10*iter_feature) ';' num2str(initial+10*(iter_feature-1)) ';' num2str(initial+10*(iter_feature-2)) '\t']);
        end
        fprintf(fid,'\n');
        fprintf(fid,'dnorm:\t');
        for iter_feature = 1:10
            fprintf(fid,[num2str(type{iter_feature}) '\t']);
        end
    case 3
        for iter_increase = 1:10
            for iter_layer = 1:3
                % [m,n] = size(data);
                % for iter_row= 1:m
                %   for iter_column = 1:n
                %       fprintf();
                %   end
                % end
                path = ['E:\Workspace\Deep-Semi-NMF-master\matlab\Log\H\LogOfH' num2str(iter_layer) '_' num2str(initial+10*(iter_increase-iter_layer+1)) '.txt'];
                data = type{1,iter_increase}{1,iter_layer};
                save(path,'data','-ascii');
            end
        end
    case 4
        for iter_increase = 1:10
            for iter_layer = 1:3
                path = ['E:\Workspace\Deep-Semi-NMF-master\matlab\Log\Z\LogOfZ' num2str(iter_layer) '_' num2str(initial+10*(iter_increase-iter_layer+1)) '.txt'];
                data = type{1,iter_increase}{1,iter_layer};
                save(path,'data','-ascii');
            end
        end
end
if (varargin{1} == 1) || (varargin{1} == 2)
    fclose(fid);
end