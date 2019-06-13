function ima_fil=ppb_nakagamifastnon(ima_nse, L, ...
                         hW, hD, ...
                         alpha, T, ...
                         nbit)

D=2*hD;
W=2*hW+1;
D1=D+1;

h = quantile_nakagami(L, D1, alpha) .* D1.^2;
[width,height] = size(ima_nse);

output = zeros(width,height);
for l = 1:size(nbit, 2)
    hD0=hD(l);
    hW0=hW(l);
    W0 =W(l);
    D0 = D(l);
    h0=h(l);
    ima_nse2 = padarray(ima_nse,[hD0 hD0],'symmetric'); 
    ima_nse3 = padarray(ima_nse,[hW0+hD0 hW0+hD0],'symmetric'); 
    ima_nse4 = ima_nse3.^2;

    w = cell(W0*W0-1);

    for count = 1:nbit(l)
        k=1;

        output0 =zeros(width,height);
        Z =zeros(width,height);
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

                temp1(abs(temp1)<=0)=min(min(temp1(abs(temp1)>0)));
                temp1(isnan(abs(temp1)))=min(min(temp1(abs(temp1)>0)));
                
                    w{k} = exp(-temp1./h0);

                Z=Z+w{k};
                output0 = w{k}.*ima_nse4(hW0+hD0+1+m:hW0+hD0+m+width,hW0+hD0+1+n:hW0+hD0+n+height)+output0;
                k=k+1;
            end
        end
        wmax = zeros(size(ima_nse));
        for k = 1:W0*W0-1
            wmax = max(w{k},wmax);
        end
        Z=Z+wmax;
        Z(Z<eps)=eps;
        output0 = wmax.*ima_nse.^2+output0;%%%
        output0 = output0./Z;
        output=sqrt(output0);
%         output=output0;%%%%
%         
%         outputpsnr = output(25:230,25:230);
%         imapsnr = ima(25:230,25:230);
%         psnr2 = PSNR(outputpsnr,imapsnr);
%         psnr0 = PSNR(output,ima);
    end
end
ima_fil = output;
end


function m = min2(mat)
    m = min(min(mat));
end

function r = quantile(x, alpha) % SAS-5
       x = sort(x);
       N = size(x, 2);
       h = N * alpha + 0.5;
       if alpha == 0
           r = x(1);
           return;
       end
       if alpha == 1
           r = x(N);
           return;
       end
       r = (x(ceil(h - 0.5)) + x(floor(h + 0.5))) / 2;
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