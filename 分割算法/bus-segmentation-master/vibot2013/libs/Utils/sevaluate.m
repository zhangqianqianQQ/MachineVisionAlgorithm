%http://www.mathworks.com/matlabcentral/fileexchange/29737-segmentation-evaluatation/content/sevaluate.m
function [Jaccard,Dice,rfp,rfn]=sevaluate(m,o)
% gets label matrix for one tissue in segmented and ground truth 
% and returns the similarity indices
% m is a tissue in gold truth
% o is the same tissue in segmented image
% rfp false pasitive ratio
% rfn false negative ratio
% rm 12/04/2012: added condition >0 
m=m(:)>0;
o=o(:)>0;
common=sum(m & o); 
union=sum(m | o); 
cm=sum(m); % the number of voxels in m
co=sum(o); % the number of voxels in o
Jaccard=common/union;
Dice=(2*common)/(cm+co);
rfp=(co-common)/cm;
rfn=(cm-common)/cm;