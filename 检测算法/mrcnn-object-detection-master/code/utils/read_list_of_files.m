function [ list_files ] = read_list_of_files( list_file_path )


list_files = {};
fid = fopen(list_file_path);
tline = fgets(fid);
c = 0;
while ischar(tline)
    c = c + 1;
    list_files{c} = tline;
%     fprintf('%s\n',list_files{c})
    tline = fgets(fid);
end
fclose(fid);
end

