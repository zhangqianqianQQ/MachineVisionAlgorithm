function ESI=esi(X,Y)
% X ÎªÂË²¨ºóÍ¼Ïñ  YÎªÂË²¨Ç°Í¼Ïñ



% load original_sar;
% load noisesar;
% load Kuansar;
X=wav;
Y=noise_image;
% c=X(1:141,143:283);
% d=Y(1:141,143:283);
% figure,imshow(c);
% t1=fliplr((eye(size(c))));
% c=double(c);
% d=c.*t1

dn1=zeros(1,142);
dn2=dn1;
for i=1:142

        dn1(i)=abs(X(142,i)-X(143,i));
        dn2(i)=abs(Y(142,i)-Y(143,i));
    
end
DN1=0;
DN2=0;
for i=1:length(dn1)
    DN1=DN1+dn1(i);
end
for i=1:length(dn1)
    DN2=DN2+dn2(i);
end    
ESI=DN1/DN2

% c=X(1:141,143:283);
% d=Y(1:141,143:283);
% % figure,imshow(c);
% % t1=fliplr((eye(size(c))));
% % c=double(c);
% % d=c.*t1
% 
% s=size(c);
% dn1=zeros(1,141);
% dn2=dn1;
% for i=1:s(1)-1
% 
%         dn1(i)=abs(c(i,142-i)-c(i+1,142-i));
%         dn2(i)=abs(d(i,142-i)-d(i+1,142-i));
%     
% end
% DN1=0;
% DN2=0;
% for i=1:length(dn1)
%     DN1=DN1+dn1(i);
% end
% for i=1:length(dn1)
%     DN2=DN2+dn2(i);
% end    
% ESI=DN1/DN2


