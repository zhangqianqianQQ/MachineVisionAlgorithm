function den = wavewiener(img, wn, level)

    img = double(img);
    
    % Decompose image.
    [A,H,V,D] = swt2(img, level, wn);
    
    % Estimate noise.
    d = D(:,:,1);
    sigma = median(abs(d(:)'))/0.6745;
    sigma2 = sigma^2;
    
    % First iteration
    for l = level:-1:1

        hc = H(:,:,l);
        vc = V(:,:,l);
        dc = D(:,:,l);

         if (l ~= 1)
             bs = 1;
         else
             bs = 3;
         end
         
         
         M = (2*bs+1)^2;
         k = 1 + sqrt(2/M);
         
         fhc = frame(hc, bs);
         [h w] = size(hc);
         for r = bs+1:bs+h
             for c = bs+1:bs+w
                q = sum(sum(fhc(r-1:r+1,c-1:c+1).^2))/M;
                if (q > k*sigma2)
                    nhc(r-bs,c-bs) = hc(r-bs,c-bs);
                else
                    nhc(r-bs,c-bs) = 0.0;
                end
             end
         end
        
        fvc = frame(vc, bs);
        [h w] = size(vc);
        for r = bs+1:bs+h
            for c = bs+1:bs+w
                q = sum(sum(fvc(r-1:r+1,c-1:c+1).^2))/M;
                if (q > k*sigma2)
                    nvc(r-bs,c-bs) = vc(r-bs,c-bs);
                else
                    nvc(r-bs,c-bs) = 0.0;
                end
            end
        end
        
        fdc = frame(dc, bs);
        [h w] = size(dc);
        for r = bs+1:bs+h
            for c = bs+1:bs+w
                q = sum(sum(fdc(r-1:r+1,c-1:c+1).^2))/M;
                if (q > k*sigma2)
                    ndc(r-bs,c-bs) = dc(r-bs,c-bs);
                else
                    ndc(r-bs,c-bs) = 0.0;
                end
            end
        end
        
        fhc = frame(nhc, bs);
        [h w] = size(nhc);
        for r = bs+1:bs+h
            for c = bs+1:bs+w
                q = sum(sum(fhc(r-1:r+1,c-1:c+1).^2))/M;
                if (q == 0)
                    nhc2(r-bs,c-bs) = 0.0*nhc(r-bs,c-bs);
                else
                    nhc2(r-bs,c-bs) = (max([(q-sigma2) 0])/q)*nhc(r-bs,c-bs);
                end
            end
        end
        
        fvc = frame(nvc, bs);
        [h w] = size(nvc);
        for r = bs+1:bs+h
            for c = bs+1:bs+w
                q = sum(sum(fvc(r-1:r+1,c-1:c+1).^2))/M;
                if (q == 0)
                    nvc2(r-bs,c-bs) = 0.0*nvc(r-bs,c-bs);
                else
                    nvc2(r-bs,c-bs) = (max([(q-sigma2) 0])/q)*nvc(r-bs,c-bs);
                end
            end
        end
        
        fdc = frame(ndc, bs);
        [h w] = size(ndc);
        for r = bs+1:bs+h
            for c = bs+1:bs+w
                q = sum(sum(fdc(r-1:r+1,c-1:c+1).^2))/M;
                if (q == 0)
                    ndc2(r-bs,c-bs) = 0.0*ndc(r-bs,c-bs);
                else
                    ndc2(r-bs,c-bs) = (max([(q-sigma2) 0])/q)*ndc(r-bs,c-bs);
                end
            end
        end
        H(:,:,l) = nhc2;
        V(:,:,l) = nvc2;
        D(:,:,l) = ndc2;
    end
    
    den = iswt2(A,H,V,D, wn);
end

function fimg = frame(img, bs)
    [h w] = size(img);
    fimg = zeros(h+2*bs,w+2*bs);
    fimg(bs+1:bs+h,bs+1:bs+w) = img;
end
