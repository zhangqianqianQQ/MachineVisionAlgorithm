%%
function [ windows ] = getped( im ,model,sz1,sz2)
%top most function
  imb = segment(im);
  chop = chopp(imb,sz1,sz2);
  cens = purge(chop);
  windows = remark(im, cens, sz1, sz2 ,1, model);
  
end

