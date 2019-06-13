function [out_img, criterion] = TVdenoising(img, method, num_steps, lambda, clear_img, alpha, showfigs)

[H, W] = size(img);
N = H * W;

%% method aspects
switch method
    case 'ROFalg1'
        alg = 1;
        Lone = 0;
        huber = 0;
    case 'ROFalg2'
        alg = 2;
        Lone = 0;
        huber = 0;
    case 'TVL1ROFalg1'
        alg = 1;
        Lone = 1;
        huber = 0;
    case 'HuberROFalg3'
        alg = 3;
        Lone = 0;
        huber = 1;
    case 'HuberL1ROFalg1'
        alg = 1;
        Lone = 1;
        huber = 1;
    otherwise
        disp(['Unknown method: ' method]);
        return;
end


%% parameters
L = sqrt(8);

switch alg
    case 0      % Arrow-Hurwics version of Alg 2 (AHMOD)
        tau = 1/L;
        sigma = 1/L;
        gamma = 0.35 * lambda;
        theta = 0;
    case 1
        tau = 0.01;
        sigma = 1/(tau * L * L);
        theta = 1;
    case 2
        tau = 1/L;
        sigma = 1/L;
        gamma = 0.35*lambda;
    case 3
        gamma = lambda;
        delta = alpha;
        mu = 2 * sqrt(gamma * delta) / L;
        theta = 1/(1+mu);
        tau = mu / (2 * gamma);
        sigma = mu / (2 * delta);
end


%% initial solution
% primal task variables
u = img(:);
ubar = u;

% dual task variable
p = zeros(N * 2, 1);

%% precomputed
nabla = make_derivatives_mine(H, W);
divop = nabla';
% divop = make_divop(H, W);
denom = 1 + tau * lambda;

%% initial criterion value
if (Lone)
    lambda_denom = 1;
else
    lambda_denom = 2;
end

criterion = zeros(1, num_steps+1);
criterion(1) = Fval(u, img, alpha, huber) + lambda / lambda_denom * Gval(u, img, Lone);


%% plot the initial state
if showfigs
    fh1 = sfigure;
    
    imshow([img reshape(u, H, W)]);
    
    fh2 = sfigure;
    plot(0, criterion(1), 'b-');
    xlabel('step');
    ylabel('J(u)');
end

%% main loop
for step = 1:num_steps
    disp(['step: ' num2str(step)]);
    
    % ------ update p^n+1 ------
    p = p + sigma * nabla * ubar;
    
    if huber
        p = p / (1 + sigma * alpha);
    end
    
    % projection of p onto L2 ball
    p_len = sqrt(p(1:N).^2 + p(N+1:end).^2);
    p_len = max(1, p_len);
    p = p ./ repmat(p_len, 2, 1);
    
    % ----- update u^n+1 ------
    divp = divop * p;
    u_tilde = u - tau * divp;

    if Lone
        dif = u_tilde - img(:);
        idx1 = dif > tau * lambda;
        idx2 = dif < -tau * lambda;
        idx3 = abs(dif) <= tau * lambda;
        u_new = zeros(size(u));
        u_new(idx1) = u_tilde(idx1) - tau * lambda;
        u_new(idx2) = u_tilde(idx2) + tau * lambda;
        u_new(idx3) = img(idx3);
    else
        if alg == 2 || alg == 0
            denom = 1 + tau * lambda;
        end
        u_new = (u_tilde + tau * lambda * img(:)) / denom;
    end

    % ----- update tau and sigma -----
    if alg == 2
        theta = 1/(sqrt(1+2*gamma*tau));
        tau = tau * theta;
        sigma = sigma / theta;
    end
    if alg == 0
        theta_tmp = 1/(sqrt(1+2*gamma*tau));
        tau = tau * theta_tmp;
        sigma = sigma / theta_tmp;
    end

    
    % update ubar^n+1
    ubar = u_new + theta * (u_new - u);
    
    u = u_new;
    
    % compute the criterion function value
    criterion(step+1) = Fval(u, clear_img, alpha, huber) + lambda / lambda_denom * Gval(u, img, Lone);
    
    % plot current result
    if showfigs
        sfigure(fh1);
        imshow([img reshape(u, H, W)]);
        drawnow;
        
        sfigure(fh2);
        plot(0:step, criterion(1:step+1), 'b-');
        xlabel('step');
        ylabel('J(u)');
        drawnow;
    end
end

out_img = u;
