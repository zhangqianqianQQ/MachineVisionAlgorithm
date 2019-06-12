function sim = mat_sim(A,B,FLAG)
    if strcmp(FLAG, 'roipool')
        A = A.roipool;
        B = B.roipool;
        A = (A-mean(A(:))) / std(A(:));
        B = (B-mean(B(:))) / std(B(:));
        C = A.*B;
        sim = sum(C(:))/size(A(:),1);
    end
    if strcmp(FLAG, 'contrib_roipool')
        A = A.contrib_roipool .* A.roipool;
        B = B.contrib_roipool .* B.roipool;
        A = (A-mean(A(:))) / std(A(:));
        B = (B-mean(B(:))) / std(B(:));
        C = A.*B;
        sim = sum(C(:))/size(A(:),1);
    end
    if strcmp(FLAG, 'contrib_img')
        A = A.contrib_img;
        B = B.contrib_img;
        A = (A-mean(A(:))) / std(A(:));
        B = (B-mean(B(:))) / std(B(:));
        A = gpuArray(sum(A,3));
        B = gpuArray(sum(B,3));
        C = gather(conv2(rot90(A,2),B));
        sim = max(C(:));
    end
    if strcmp(FLAG, 'color_hist')
        sim = (A-B).*(A-B);
        sim = sum(sim(:));
    end
end