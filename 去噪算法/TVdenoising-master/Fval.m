function tv = Fval(u, img, alpha, huber)
% total variation part of the criterion

[H W] = size(img);
N = W * H;

nabla = make_derivatives_mine(H, W);

if huber
    tv = nabla * u(:);
    tv_size = sqrt(tv(1:N).^2 + tv(N+1:end).^2);
    idx1 = tv_size <= alpha;
    idx2 = tv_size > alpha;
    tv = sum(tv_size(idx1).^2/(2*alpha)) + sum(tv_size(idx2) - alpha/2);
else
    tv = nabla * u(:);
    tv = sum(sqrt(tv(1:N).^2 + tv(N+1:end).^2));
end
