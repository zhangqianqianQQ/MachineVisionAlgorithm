function [set, contiguous_paths]=adjacent_path(full_path, imgs_path,multi_frame)

[folder,name,ext]=fileparts(full_path);
piece=strsplit(name,'_');

if(contains(piece{1},'set'))
    set=-1;
else
    if(contains(folder,'caltech'))
        set='caltech';
    else
        set=str2num(piece{1}(4:end)); % 'setxx' -> xx
        id=str2num(piece{3}(2:end)); % 'I000xx' -> xx
    end
end % cycleGAN image name에 'AtoB' or 'BtoA'가 붙으므로

contiguous_paths=cell(1,1+multi_frame*2);
count=1;
interval=1;
for i= -multi_frame:multi_frame
    if(i==0) 
        contiguous_paths{count}=full_path; 
        count=count+1;
        continue;
    end
    contiguous_id=sprintf('I%05d',id+i*interval);
    contiguous_name=strcat(strrep(name,piece{3},contiguous_id),ext);
    contiguous_paths{count}=fullfile(imgs_path,contiguous_name);  
    count=count+1;
end

 
