
%% Parameters

%%% PASCAL 12 Test dataset
volume_path = '/Volumes/SHARED HD';
path_folders = [volume_path '/Video Summarization Project Data Sets/PASCAL_12_test/VOCdevkit/VOC2012/'];
folders = {'JPEGImages'};
format = '.jpg';
feat_path = [volume_path '/Video Summarization Objects/Features/Data PASCAL_12_test']; % folder where we want to store the features for each object


%% Parse folders
disp('# PARSING FOLDERS looking for all images...');
[ list_path, list_img, list_event, list_event2 ] = parseFolders( folders, path_folders, format, '' );


%% Build 'objects' structure
disp('# BUILD OBJECTS STRUCTURE.');
objects = buildObjStruct(list_path, list_img, list_event, list_event2);
mkdir(feat_path);
save([feat_path '/objects.mat'], 'objects');
