function ind = VOChash_lookup_modified(hash,s)

hsize=numel(hash.key);
if length(s) == 6
    h=mod(str2double(s),hsize)+1;
else
    h=mod(str2double(s([3:4 6:11 13:end])),hsize)+1;
end
ind=hash.val{h}(strmatch(s,hash.key{h},'exact'));
