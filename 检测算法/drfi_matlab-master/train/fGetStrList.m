function [ strList ] = fGetStrList( fileName )
    fid = fopen(fileName);
    count = 0;
    tline = fgetl(fid);
    strList = cell(1, 10000);
    while ischar(tline)
        count = count+1;
        strList{count} = tline;
        tline = fgetl(fid);
    end
    fclose(fid);
    strList = strList(1:count);
end

