%Script para ACM MM. Pruba 5. Ver 2.1

ratio       = 1/1.2; 
verbose     = 3;    
dataroot    = getDataRoot;
img_dir     = fullfile(dataroot,'images');
edge_dir    = fullfile(dataroot,'edge');
out_dir     = fullfile(dataroot,'result');
if(~exist(out_dir,'dir'))
    mkdir(out_dir);
end

out_format  = 'txt';
detData     = [];   
img_cnt     = 0;
result_file = fullfile(out_dir,['test1.',out_format]);
cb_file     = fullfile(dataroot,'codebook/cb_pb_height_150_bin_30.mat');
load(cb_file);

para    = set_parameter(codebook,ratio);
ratio   = para{2}.ratio;

[img_path, img_file, file_name]	= get_file_list(img_dir,{'png','jpg','bmp'});

for ff = 1:length(img_path)
    fprintf(1,'pensando en %s\n',img_file(ff).name);
    edge_file   = fullfile(edge_dir,[file_name(ff).name,'.mat']);
    clear I_edge;
    if(~exist(edge_file,'file'))
        img = imread(img_path(ff).name);
        if(verbose>1)
            fprintf(1,'ED...');
            tic;
        end
        I_edge  = compute_edge_pyramid(img, para{1}.detector,...
            para{3}.min_height, para{2}.ratio);
        if(verbose>1)
            fprintf(1,'ED: %f secs\n',toc);
        end
        save(edge_file,'I_edge','img','ratio');
    else
        load(edge_file);
    end
    para{2}.ratio   = ratio;
    [hypo_list,score_list, bbox_list] = sc_detector(img,codebook,I_edge, para, verbose);
    img_cnt = img_cnt + 1;
    detData(img_cnt).imgname    = file_name(ff).name;
    detData(img_cnt).hypo_list  = hypo_list;
    detData(img_cnt).score_list = score_list;
    detData(img_cnt).bbox_list  = bbox_list;
end


if(strcmp(out_format,'mat'))
    save(result_file,'detData');
else
    fid = fopen(result_file,'w');
    if(fid==-1)
        fprintf(1,'Abre %s fallo.\n', result_file);
        return;
    end
    for det_id=1:img_cnt
        nb_hypo = size(detData(det_id).hypo_list,1);
        for hypo=1:nb_hypo
            fprintf(fid,'%s\t%f\t%d\t%d\t%d\t%d\n',detData(det_id).imgname,...
                detData(det_id).score_list(hypo),...
                detData(det_id).bbox_list(hypo,1),...
                detData(det_id).bbox_list(hypo,2),...
                detData(det_id).bbox_list(hypo,3),...
                detData(det_id).bbox_list(hypo,4));
        end
    end
    fclose(fid);
end
