%Split video into 20% for training and the rest 80% for testing

videos = {'Board', 'Candela_m1.10', 'CAVIAR1','CAVIAR2','CaVignal',...
    'Foliage', 'HallAndMonitor','HighwayI','HighwayII',...
    'HumanBody2','IBMtest2','PeopleAndFoliage','Snellen','Toscana'};

mkdir('split');

for i = 1 : numel(videos)
   disp(videos(i))
   
   imgs = dir(['SBMIDataset/' videos{i} '/groundtruth/*.png']);
   
   %disp(numel(imgs));
   
   index = randperm(numel(imgs));
   
   num_train = ceil(0.2*numel(imgs));
   
   disp(num_train);
   
   train_index = index(1:num_train);
   test_index = index(num_train+1 : end);
   
   save(['split/' videos{i} '.mat'], 'train_index', 'test_index');
   
end