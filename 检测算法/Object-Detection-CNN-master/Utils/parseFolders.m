function [ list_path, list_img, list_event, list_event2 ] = parseFolders( folders, path_folders, format, path_labels )
%PARSEFOLDERS Gets all image paths and all image labels from the passed
% folders.
%   Returns the list of images found, their list of events indices
%   (list_event) and their list of events labels (list_event2), all
%   parameters with the same length as images found.
%%%%

    list_path = {}; % store all the intermediate paths
    list_img = {}; % store all image paths in this list
    list_event = []; % store event ids for each image
    list_event2 = []; % store event labels for each image
    count_event = 0;
    count = 1;
    last_event = 0;
    for f = folders
        %%%%%
%         fold = [path_folders '/Datasets/' f{1}]; % LINUX
        fold = [path_folders '/' f{1}]; % WINDOWS & MAC (or PASCAL LINUX)
        %%%%%

        % Load images list
        if(iscell(format))
            fileList = []; 
            nFormat = 1;
            fileList = dir([fold '/*' format{nFormat}]);
            while(isempty(fileList))
                nFormat = nFormat+1;
                nFormat = mod(nFormat, length(format)+1);
                if(nFormat == 0)
                    nFormat = 1;
                end
                fileList = dir([fold '/*' format{nFormat}]);
            end
        else
            fileList = dir([fold '/*' format]);
        end
        fileList = fileList(arrayfun(@(x) ~strcmp(x.name(1),'.'),fileList));

        % Load labels
        %%%%%%
        % tmp line (PASCAL, Perina and Toy Problem)
        labels = ones(1,length(fileList));
%         labels = load([path_folders '/Event Labels/' f{1} '_1to' num2str(length(fileList)) '/labels.mat']); % LINUX
%         labels = load([path_labels '/' f{1} '_1to' num2str(length(fileList)) '/labels.mat']); % WINDOWS
        %%%%%%

        % tmp commment (PASCAL, Perina and Toy Problem)
%         labels = labels.labels';
%         labels = [labels(1) labels];

        for i = 1:length(fileList)
            list_path{count} = f{1};
            % Store the paths to each image
            list_img{count} = [fold '/' fileList(i).name];
            % Store the event number for each image
            if(labels(i) ~= last_event)
                count_event = count_event +1;
                last_event = labels(i);
            end
            list_event2 = [list_event2 labels(i)]; % event labels
            list_event = [list_event count_event]; % event idx
            count = count+1;
        end
    end

end

