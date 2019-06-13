function morph_profile=GetMP(img,SEs)
% Extract Morphological Profiles of the input image with the given SEs
%2016-10-20, jlfeng
[nr,nc]=size(img);
numSE=length(SEs);
morph_profile=zeros(nr,nc,numSE*8);
%%
% Opening and Closing
mp1=zeros(nr, nc,numSE);mp2=zeros(nr, nc,numSE);
for kk=1:numSE
    mp1(:,:,kk)=imclose(img,SEs{kk});
    mp2(:,:,kk)=imopen(img,SEs{numSE+1-kk});
end
dmp=diff(cat(3,mp1,img,mp2),[],3);
morph_profile(:,:,1:numSE*4)=cat(3,mp1,mp2,dmp);
% OpenRec and CloseRec
for kk=1:numSE
    marker=imerode(img,SEs{numSE+1-kk});
    mp1(:,:,kk)=imreconstruct(marker,img);
    marker=imdilate(img,SEs{kk});
    mp2(:,:,kk)=imreconstruct(imcomplement(marker),imcomplement(img));
end
dmp=diff(cat(3,mp1,img,mp2),[],3);
morph_profile(:,:,(numSE*4+1):numSE*8)=cat(3, mp1,mp2,dmp);

