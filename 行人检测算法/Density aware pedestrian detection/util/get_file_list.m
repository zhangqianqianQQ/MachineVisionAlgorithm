function [path_list, name_list, short_name_list] = get_file_list(datadir,filetypes)

dirStr = dir(datadir);
path_list       = [];
name_list       = [];
short_name_list = [];
fileIdx = 1;

if(~exist('filetypes','var') || isempty(filetypes))
    b_type=0;
else
    b_type=1;
    if(ischar(filetypes))
        filetypes_T{1}=filetypes;
        filetypes=filetypes_T;
    end
    for tt=1:length(filetypes)
        filetypes{tt}=['.',filetypes{tt}];
    end
end

for ff = 1:size(dirStr,1)
    f_name = dirStr(ff).name;
    if(~strcmp(f_name,'.') & ~strcmp(f_name,'..') & ...
            ~dirStr(ff).isdir)
        f_name = dirStr(ff).name;
        [pathstr, name, ext, versn] = fileparts(f_name);
        if(~b_type || (b_type && any(strcmp(ext,filetypes))))
            path_list(fileIdx).name = fullfile(datadir,f_name);
            name_list(fileIdx).name = f_name;
            short_name_list(fileIdx).name = f_name(1:(end-length(ext)));
            fileIdx = fileIdx + 1;
        end
    end
end