function label_mv=SpatialMajorityVoting(label, sp_label)
% Perform majority voting in superpixels for the input label map
% Input:
%    label: the input label
%    sp_label: superpixel label
% Output:
%    label_mv: label obtained by majority voting
% 2016-10-22, jlfeng
[nr,nc]=size(label);
if (nr~=size(sp_label,1) || nc~=size(sp_label,2))
    error('The size of input label and superpixel label are not equal.')
end
label_mv=zeros(nr,nc);
sp_label_list=unique(sp_label(:));
num_sp=length(sp_label_list);
num_class=max(label(:));
for kk=1:num_sp
    class_vote=zeros(1,num_class);
    idx_sp=(sp_label==sp_label_list(kk));
    label_in_sp=label(idx_sp);
    for ll=1:num_class
        class_vote(ll)=length(find(label_in_sp==ll));
    end
    [~,idx_max_vote]=max(class_vote);
    label_mv(idx_sp)=idx_max_vote;
end