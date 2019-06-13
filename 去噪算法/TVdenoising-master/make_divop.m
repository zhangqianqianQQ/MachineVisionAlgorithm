function divop = make_divop(W, H)

N = W * H;

row = zeros(1, 4 * N);
col = zeros(1, 4 * N);
val = zeros(1, 4 * N);
idx = 1;
for c = 1:W
    for r = 1:H
        n = r + (c-1) * W;
        
        % p_ij^x
        row(idx) = n;
        col(idx) = n;
        val(idx) = 1;
        idx = idx + 1;
        
        % p_ij^y
        row(idx) = n;
        col(idx) = N + n;
        val(idx) = 1;
        idx = idx + 1;
        
        % -p_i-1j^x
        if (r>1)
            row(idx) = n;
            col(idx) = n-1;
            val(idx) = -1;
            idx = idx + 1;
        end
        
        % -p_ij-1^y
        if (c>1)
            row(idx) = n;
            col(idx) = N + n - H;
            val(idx) = -1;
            idx = idx + 1;
        end
    end
end

row = row(1:idx-1);
col = col(1:idx-1);
val = val(1:idx-1);

divop = sparse(row, col, val, N, 2*N);