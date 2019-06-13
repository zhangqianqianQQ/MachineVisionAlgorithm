
%% This script prepares the processes fo a cross validation on the splitted 
%   validation data for selecting the best parameter combination for each 
%   margin method.

images_per_process = 5;
command = 'qsub -q short.q -l mem=2M -cwd -v INI=%d,FIN=%d,ID_PROCESS=%d objDetectCV.sh\n';

%% Load Parameters
cd ..
cd ..
loadParameters;

%% Load validation data split
load(train_val_split); % images_list
val_split = images_list{2};
nImages = size(val_split,1);

cd Results_Evaluation
cd ParallelCrossValidation

%% Splits the image list for nProcesses
nProcesses = round(nImages/images_per_process);
split_images = round(linspace(0, length(val_split), nProcesses+1));

%% Write submit file for putting processes in queue
f = fopen('submit.sh','w');
for i = 1:nProcesses
    fprintf(f, command, split_images(i)+1, split_images(i+1), i);
end
fclose(f);

