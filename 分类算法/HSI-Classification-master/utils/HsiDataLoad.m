function dataInfo=HsiDataLoad(data_name)
if (strcmp(data_name,'PaviaCenter'))
    spectral_data=load('E:\Data\HyperSpectral\HSI_Data\Pavia.mat');    
    gt_data=load('E:\Data\HyperSpectral\HSI_Data\Pavia_gt.mat');
    class_dict={'water','tree','meadow','brick','bare soil','asphalt','bitumen','tile','shadow'};
    dataInfo=struct('data_name','PaviaCenter','num_class',9,'class_dict',{class_dict},...
       'spectral_data',spectral_data.pavia,'gt_data',gt_data.pavia_gt);
elseif (strcmp(data_name,'PaviaUniv'))
    spectral_data=load('E:\Data\HyperSpectral\HSI_Data\PaviaU.mat');
    gt_data=load('E:\Data\HyperSpectral\HSI_Data\PaviaU_gt.mat');
    class_dict={'asphalt','meadow','gravel','tree','metal sheet','bare soil',...
        'bitumen','brick','shadow'};
    dataInfo=struct('data_name','PaviaUniv','num_class',9,'class_dict',{class_dict},...
       'spectral_data',spectral_data.paviaU,'gt_data',gt_data.paviaU_gt);
elseif (strcmp(data_name,'IndianPine'))
    spectral_data=load('E:\Data\HyperSpectral\HSI_Data\Indian_pines_corrected.mat');
    gt_data=load('E:\Data\HyperSpectral\HSI_Data\Indian_pines_gt.mat');
    class_dict={'corn-no till','corn-min till','corn','soybeans-no till','soybeans-min till',...
        'soybeans-clean till','alfalfa','grass/pasture','grass/trees','grass/pasture-mowed',...
        'hay-windrowed','oats','wheat','woods','bldg-grass-tree-drives','stone-steel tower'};
    dataInfo=struct('data_name','IndianPine','num_class',16,'class_dict',{class_dict},...
       'spectral_data',spectral_data.indian_pines_corrected,'gt_data',gt_data.indian_pines_gt);
else
   dataInfo=struct();
end