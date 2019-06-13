function [ objects ] = buildObjStruct( list_path, list_img, list_event, list_event2 )
%BUILDOBJSTRUCT Builds the objects structure for storing all the
%   information.
%%%%

    %% Build struct for storing all objects found and their classes
    objects = struct('folder', [], 'imgName', [], 'idEvent', [], 'labelEvent', [], 'objects', struct('ULx', [], 'ULy', [], ...
        'BRx', [], 'BRy', [], 'objScore', [], 'eventAwareScore', [], 'features', [], 'label', 0));
    % label = 0 ---> not analyzed
    % label = 1 ---> no object

    %% Extract object candidates and objectness from each of them
    lenImgs = length(list_img);
    disp(['Starting extraction of objects from ' num2str(lenImgs) ' images.']);
    for i = 1:lenImgs
        % Initialize info for this image
        path = regexp(list_img{i}, '/', 'split');
        objects(i).folder = list_path{i};
        objects(i).imgName = path{length(path)};
        objects(i).idEvent = list_event(i);
        objects(i).labelEvent = list_event2(i);
    end

end


