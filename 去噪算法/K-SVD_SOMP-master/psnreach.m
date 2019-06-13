function [imageper output0] = psnreach(O_image,pos_arr,BETA_sigma_pad2,Dictionary,errorGoal,blocknum,L)
output=zeros(size(O_image)); weight=zeros(size(O_image));
mean_noise     = gamma(L+0.5)*(1/L)^(1/2)/gamma(L);
O_image_ = O_image*mean_noise;
blockresize = 256-8+1;
ppppp = 1;
for opi = 1:size(pos_arr,2)
    idx_matrix = pos_arr(:,opi);
    for mmmm=1:size(idx_matrix,1);
                    idp = idx_matrix(mmmm);
                    if mod(idp,blockresize) == 0
                        idx = blockresize;idy = idp/blockresize;
                    else
                        idx = mod(idp,blockresize);idy = floor(idp/blockresize)+1;
                    end
                   tempblk=O_image(idx:idx+7,idy:idy+7);
                   temp(:,mmmm)=tempblk(:);
                   tempbeta=BETA_sigma_pad2(idx:idx+7,idy:idy+7);
                   tempbetablks(:,mmmm)=tempbeta(:);
    end
        tempsimblocks=temp;
        tempsimbeta=tempbetablks;
        BETA=mean(tempsimbeta,2);
         CoefMatrix =  SOMPerr(Dictionary,tempsimblocks, errorGoal,BETA,16 );
         denoiseblk=Dictionary*CoefMatrix;
idx_matrix = pos_arr(:,opi);
            for r=1:blocknum
                f2=denoiseblk(:,r);
                 W = reshape(f2,[8 8]);
                    idp = idx_matrix(r);
                    if mod(idp,blockresize) == 0
                        idx = blockresize;idy = idp/blockresize;
                    else
                        idx = mod(idp,blockresize);idy = floor(idp/blockresize)+1;
                    end
                 output(idx:idx+7,idy:idy+7)=output(idx:idx+7,idy:idy+7)+W;
                  weight(idx:idx+7,idy:idy+7)=weight(idx:idx+7,idy:idy+7)+1;
            end
               
           ppppp = ppppp+1;
           
end


output=output./weight;
output0 = output;
imageper = output0(:);
% psnrper = 20*log10(255/sqrt(mean((output0(:)-O_image_(:)).^2)));
end