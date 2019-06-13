function rename(path,ext)
% RENAME function to rename all the variable names of the model
% inside of the .mat file as the name of the .mat file.

    files = rdir([path,'\*',ext]);
    
    for i=1:size(files)
        file = files(i).name;
        [~, name, ~]= fileparts(file);
        
        struct = load(file);
        if max(size(fieldnames(struct))) == 1
            fprintf('renaming file %s...\n',name);
            old_name = fieldnames(struct);  % as only has one field
            s.(name) = getfield(struct,old_name{1}); % return the name as cell
            save(file,'-struct','s',name);
            
        else
            fprintf('file %s skipped.\n',name);
        end
    end
end