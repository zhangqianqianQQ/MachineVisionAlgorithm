function attr_profile=GetAP(img,graylevel_list, max_tree, attr_name, vec_thresh, prun_strategy)
% Extract Attribute Profile of the input image
%2016-10-20, jlfeng
if ~isfield(max_tree(1),attr_name)
    error('The attribue does not exist!');
end
[nr,nc]=size(img);
num_thresh=length(vec_thresh);
attr_profile=zeros(nr,nc,num_thresh);
for kk=1:num_thresh
    lambda=vec_thresh(kk);
    tree_prun=FilterMaxTree(max_tree,attr_name,lambda, prun_strategy);
    attr_profile(:,:,kk)=RestoreImgFromTree(img,tree_prun,graylevel_list);
end


function img_out=RestoreImgFromTree(img_in,max_tree,graylevel_list)
% Restoring feature img from a maxtree
%2016-10-20, jlfeng
num_node=length(max_tree);
[nr,nc]=size(img_in);
img_out=ones(nr,nc)*graylevel_list(1);
for kk=2:num_node
    if max_tree(kk).level~=0
       img_out(max_tree(kk).idx_pix)=graylevel_list(max_tree(kk).level);
    end
end


function tree_out=FilterMaxTree(tree_in,attr_name,lambda,prun_strategy)
% Prunning a maxtree with given attribute and threshold
%2016-10-20, jlfeng

num_node=length(tree_in);
switch lower(prun_strategy)
    case 'min'
        for kk=2:num_node
            if tree_in(tree_in(kk).idx_parent).level==0
               tree_in(kk).level=0;
            elseif tree_in(kk).(attr_name)<lambda
               tree_in(kk).level=0;
            end
        end 
        tree_out=tree_in; 
    case 'max'
        for kk=0:num_node-2
            if tree_in(num_node-kk).(attr_name)<lambda
                supress_flag=0;
                for ll=1:length(tree_in(num_node-kk).idx_children)
                    if tree_in(tree_in(num_node-kk).idx_children(ll)).level~=0
                       supress_flag=1;
                       break;
                    end
                end
                if supress_flag==0;
                   tree_in(num_node-kk).level=0;
                end
            end
        end 
        tree_out=tree_in; 
    case 'direct'
        for kk=2:num_node
            if tree_in(kk).(attr_name)<lambda
               tree_in(kk).level=0;
            end
        end    
        tree_out=tree_in; 
    case 'subtractive'
        for kk=2:num_node
            if tree_in(kk).(attr_name)<lambda
               tree_in(kk).level=0;
            else
               backtrack_flag=1;
               idx_node_now=tree_in(kk).idx_parent;
               while backtrack_flag
                   if tree_in(idx_node_now).level~=0
                      tree_in(kk).level=tree_in(idx_node_now).level+1;
                      backtrack_flag=0;
                   else
                      idx_node_now=tree_in(idx_node_now).idx_parent;
                   end
               end
            end                   
        end
        tree_out=tree_in; 
    otherwise
        disp('Unknown Pruning Strategy!')
        tree_out=[];
end
       


    




    