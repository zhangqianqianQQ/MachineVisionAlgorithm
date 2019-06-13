function w = ppbweight(input,hw,hd,L);
D=2*hd;
W=2*hw+1;
D1=D+1;
alpha = 0.92;
h = quantile_nakagami(L, D1, alpha) .* D1.^2;
h0 = h;
[width,height] = size(input);
hD0=hd;
hW0=hw;
W0 =W;
D0 = D;
ima_nse2 = padarray(input,[hD0 hD0],'symmetric'); 
ima_nse3 = padarray(input,[hW0+hD0 hW0+hD0],'symmetric'); 
w = cell(W0*W0-1);
for m = -hW0:hW0
            for n = -hW0:hW0
                if(m==0 && n==0) 
                    continue; 
                end;    %保证搜索窗比较窗不重叠
                R1 = min(ima_nse2./ima_nse3(hW0+1+m:hW0+m+width+D0,hW0+1+n:hW0+n+height+D0),ima_nse3(hW0+1+m:hW0+m+width+D0,hW0+1+n:hW0+n+height+D0)./ima_nse2);
                Sd1 = log(R1+1./R1);
                Sd1 = cumsum(Sd1,1);
                Sd1 = cumsum(Sd1,2);   
                [Sd1width,Sd1height] = size(Sd1);
                Sd1_temp  = zeros(Sd1width+1,Sd1height+1);
                Sd1_temp(2:Sd1width+1,2:Sd1height+1)=Sd1;
                temp1 = Sd1_temp(D0+2:D0+width+1,D0+2:D0+height+1)+ Sd1_temp(1:width,1:height)-Sd1_temp(D0+2:D0+width+1,1:height)-Sd1_temp(1:width,D0+2:D0+height+1);
                w{k} = exp(-temp1./h0);
            end
end
end

function r = quantile_nakagami(L, ws, alphas)
    L2=L*2;
    L3=2*L-1;
    for kw = 1:size(ws, 2);
        w = ws(kw);
        ima_nse = zeros(w * 256);
        i = sqrt(-1);
        for l = 1:L
            ima_nse = ima_nse + abs(randn(size(ima_nse)) + i * randn(size(ima_nse))).^2 / 2;
        end
        ima_nse = sqrt(ima_nse / L);

        k = 1;
        for i = 1:(2*w):(size(ima_nse,1) - 2*w)
            for j = 1:w:(size(ima_nse,2) - w)
                sub_nse_1 = ima_nse(i:(i + w - 1), j:(j + w - 1));
                sub_nse_2 = ima_nse((i + w):(i + 2 * w - 1), j:(j + w - 1));
                
%                 temp1 = sub_nse_1.*sub_nse_2;
%                 temp2 = sub_nse_1.^2+sub_nse_2.^2;
%                 lsl = (2*L-1)*log(temp1)-(2*L-1/2)*log(temp2);  
                
                lsl = log(sub_nse_1 ./ sub_nse_2 + sub_nse_2 ./ sub_nse_1);
                
                v(k) = mean(mean(lsl));
                k = k + 1;
            end
        end

        for q = 1:size(alphas, 2)
            r(q, kw) = quantile(v, alphas(q)) - mean(v);
        end
    end

end