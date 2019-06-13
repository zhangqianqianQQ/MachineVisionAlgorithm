function [im_blob, im_scale, org_size] = my_image_blob(conf, cur_img_path, multi_frame)

    [folder,name,ext]=fileparts(cur_img_path);
    piece=strsplit(name,'_');
    
    im_blob=[];
    imgs=cell(1,multi_frame*2+1);
    
    if(~contains(piece{1},'set')) % generated
        set=-1;
    else
        if(contains(folder,'caltech')) % caltech
            set=0;
        else % kaist
            set=str2num(piece{1}(4:end)); % 'setxx' -> xx
        end
    end
    id=str2num(piece{end}(2:end)); % 'I000xx' -> xx
    
    if(multi_frame==0)
        imgs={imread(cur_img_path)};
    else
        count=1;
        for i= -multi_frame:multi_frame
            cont_name=strcat(strrep(name,piece{end},sprintf('I%05d',id+i)),ext);
            cont_path=fullfile(conf.skip1_img_path,cont_name);
            if(exist(cont_path, 'file'))
                imgs{count}=imread(cont_path);
            else
                imgs{count}=imread(cur_img_path);
            end
            count=count+1;
        end
    end
    org_size = size(imgs{1});
    
    for i=1:length(imgs)
        if(set>=0 && set<=2)
            level=randi(5);
            img= manipulator(imgs{i},level);
        else
            img= imgs{i};
        end
%         img= imgs{i};
%         img=im2single(img);
%         img=denoiser(conf.dncnn,img);
%         img=im2uint8(img);
%         imgs{i}=myhisteq(img);
%         
%         [imgs{i}, im_scale] = prep_im_for_blob(imgs{i}, conf.image_means, conf.scales, conf.max_size);% normalize & resize
        img=single(img);
        R=single(img(:,:,1)); mr=mean2(R); vr=mean2((R-mr).^2)^0.5; img(:,:,1)=(R-mr)/vr;
        G=single(img(:,:,2)); mg=mean2(G); vg=mean2((G-mg).^2)^0.5; img(:,:,2)=(G-mg)/vg;
        B=single(img(:,:,3)); mb=mean2(B); vb=mean2((B-mb).^2)^0.5; img(:,:,3)=(B-mb)/vb;
        im_scale=conf.max_size/max(size(img));
        img=imresize(img,im_scale);
        img=img*(255/2);
        
        im_blob=cat(4,im_blob,img);
    end
    
    im_blob=single(im_blob);
end