function codebook=load_codebook(anno_data, para_sc)

sc_mask = compute_bin_mask(para_sc.bin_r, para_sc.nb_bin_theta);
bwritten=0;

[nb_img, nb_obj]    = size(anno_data);

codebook    = [];
annolist    = [];

model_height= para_sc.model_height;
edge_detector   = para_sc.detector;

for kk=1:nb_img
    for jj=1:nb_obj
        anno_obj=anno_data(kk,jj);
        if(isempty(anno_obj))
            continue;
        end
        img     = anno_obj.img;
        mask    = anno_obj.mask;

        [imgh,imgw] = size(mask);
        if(imgh~=size(img,1) || imgw~=size(img,2))
            error('image and mask should have same dimension');
        end
        [yy,xx] = find(mask);
        min_x   = min(xx);        max_x   = max(xx);
        min_y   = min(yy);        max_y   = max(yy);
        objw    = max_x-min_x+1;
        objh    = max_y-min_y+1;
        
        lt      = max([min_x,min_y]-round([objw/2,objh/2]), [1,1]);
        rb      = min([max_x,max_y]+round([objw/2,objh/2]), [imgw,imgh]);
        
        obj_I   = img(lt(2):rb(2),lt(1):rb(1),:);
        obj_mask= mask(lt(2):rb(2),lt(1):rb(1));
        obj_mask= imresize(obj_mask,model_height/objh);
        obj_I   = imresize(obj_I,size(obj_mask),'bicubic');
        if(strcmp(edge_detector,'pb'))
            [obj_edge,obj_theta]    = compute_edge_pb(obj_I);
        else
            [obj_edge,obj_theta]    = compute_edge_flt(obj_I);
        end
        if(para_sc.edge_bivalue)
            obj_edge=double(obj_edge>para_sc.edge_thresh);
        end
        obj_edge=obj_edge.*obj_mask;
        img_id  = 2*kk-1;
        annolist(img_id,jj).I   =obj_I;
        annolist(img_id,jj).edge =obj_edge;
        annolist(img_id,jj).theta=obj_theta;
        annolist(img_id,jj).mask=obj_mask;
        codebook1 = proc_codebook_oneimage_circlebin(obj_edge, obj_theta,...
            obj_mask,sc_mask,para_sc);
        if(isempty(codebook1))
            warning(sprintf('naita img_id=%, obj_id=%d',img_id,jj));
            continue;
        end
        code_len = size(codebook1.location,1);
        codebook1.img_id=ones(code_len,1)*img_id;
        codebook1.obj_id=ones(code_len,1)*jj;
        codebook1.scale =ones(code_len,1);
      
        
        obj_I       = flipdim(obj_I,2);
        obj_mask    = fliplr(obj_mask);
        obj_edge    = fliplr(obj_edge);
        obj_theta   = pi - fliplr(obj_theta);
        obj_edge    = obj_edge.*obj_mask;
        img_id      = 2*kk;
        annolist(img_id,jj).I=obj_I;
        annolist(img_id,jj).edge =obj_edge;
        annolist(img_id,jj).theta=obj_theta;
        annolist(img_id,jj).mask=obj_mask;

        codebook2 = proc_codebook_oneimage_circlebin(obj_edge, obj_theta,...
            obj_mask,sc_mask,para_sc);
        code_len = size(codebook2.location,1);
        codebook2.img_id=ones(code_len,1)*img_id;
        codebook2.obj_id=ones(code_len,1)*jj;
        codebook2.scale =ones(code_len,1);
        if(isempty(codebook))
            codebook.codes  = [codebook1.codes;codebook2.codes];
            codebook.sc_sum = [codebook1.sc_sum;codebook2.sc_sum];
            codebook.relpos = [codebook1.relpos;codebook2.relpos];
            codebook.location= [codebook1.location;codebook2.location];
            codebook.sc_weight= [codebook1.sc_weight;codebook2.sc_weight];
            codebook.img_id = [codebook1.img_id;codebook2.img_id];
            codebook.obj_id = [codebook1.obj_id;codebook2.obj_id];
            codebook.scale = [codebook1.scale;codebook2.scale];
        else
            codebook.codes = [codebook.codes; codebook1.codes;codebook2.codes];
            codebook.sc_sum= [codebook.sc_sum;codebook1.sc_sum;codebook2.sc_sum];
            codebook.relpos = [codebook.relpos; codebook1.relpos;codebook2.relpos];        
            codebook.location= [codebook.location; codebook1.location;codebook2.location];
            codebook.sc_weight = [codebook.sc_weight; codebook1.sc_weight;codebook2.sc_weight];
            codebook.img_id=[codebook.img_id; codebook1.img_id;codebook2.img_id];
            codebook.obj_id=[codebook.obj_id; codebook1.obj_id;codebook2.obj_id];
            codebook.scale=[codebook.scale;codebook1.scale;codebook2.scale];
        end
    end
end

if(isempty(codebook))
    error('no training data found');
end

codebook.relpos = round(codebook.relpos);

nb_code	= size(codebook.codes,1);

mean_sum= mean(codebook.sc_sum) * 0.35;

sc_threshold = mean_sum;
para_sc.sum_total_thresh = sc_threshold;

codes_idx = find(codebook.sc_sum>sc_threshold);

if(length(codes_idx)<nb_code)
    fprintf(1,'corta %d codes\n',size(codebook.codes,1)-length(codes_idx));
    codebook.location = feature_from_ind(codebook.location,codes_idx);
    codebook.relpos = feature_from_ind(codebook.relpos,codes_idx);    
    codebook.codes  = feature_from_ind(codebook.codes,codes_idx);
    codebook.sc_sum = feature_from_ind(codebook.sc_sum,codes_idx);
    codebook.sc_weight = feature_from_ind(codebook.sc_weight,codes_idx);
    codebook.img_id = feature_from_ind(codebook.img_id,codes_idx);
    codebook.obj_id = feature_from_ind(codebook.obj_id,codes_idx);
    codebook.scale  = feature_from_ind(codebook.scale,codes_idx);
end

codebook.para       = para_sc;
codebook.annolist   = annolist;
