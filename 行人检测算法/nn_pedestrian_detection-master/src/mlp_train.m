function [W1, W2] = mlp_train(Xtrain, ytrain, Xval, yval)
    %% Check if dataset file already exists and only execute script if not
    if exist('cache/mlp.mat', 'file') == 2
        display('Cache file found, loading precomputed data ...')
        tic
        
        load('cache/mlp')
        
        display(['   ... Completed in ' num2str(toc) ' seconds.'])
        return
    end
    
    %% Setup initial values
    display('Training MLP ...')
    total_time = tic;
    epoch = 0;
    eta = 1e-2;
    N1 = ceil(sqrt(size(Xtrain, 2) / size(ytrain, 2)));
    N2 = size(ytrain, 2);

    mean_e_train_prev = single(1e10);
    mean_e_val_prev = single(1e10);
    mean_e_hist = NaN * ones(200,2);

    Xtrain = [-ones(size(Xtrain, 1), 1), Xtrain];
    Xval = [-ones(size(Xval, 1), 1), Xval];

    %% Start weight matrices
    W1 = single(rand(N1, size(Xtrain, 2))) / 10;
    W2 = single(rand(N2, N1 + 1)) / 10;

    %% Iterate until convergence
    while true
        display(['   ... Executing epoch ' num2str(epoch + 1)])
        tic
        for i = 1:size(Xtrain, 1)
            x = Xtrain(i, :)';
            d = ytrain(i, :)';

            I1 = W1 * x;
            O1 = [-1; g(I1)];
            I2 = W2 * O1;
            o = g(I2);

            delta2 = diag(g_dot(I2)) * (d - o);
            delta1 = diag(g_dot(I1)) * W2(:,2:end)' * delta2;
            W2 = W2 + eta * delta2 * O1';
            W1 = W1 + eta * delta1 * x';
        end
        epoch = epoch + 1;

        o = g(W2 * [-ones(1, size(Xtrain, 1)); g(W1 * Xtrain')])';
        mean_e_train = mean_error(ytrain, o);
        o = g(W2 * [-ones(1, size(Xval, 1)); g(W1 * Xval')])';
        mean_e_val = mean_error(yval, o);
        mean_e_hist(epoch, :) = [mean_e_train, mean_e_val];
        
        display(['       Error: ' num2str(mean_e_train), ' execution time: ' num2str(toc)])

        if (epoch >= 10) && ...
           ((abs(mean_e_train - mean_e_train_prev) < 1e-8 * size(Xtrain, 1)) || ...
            (mean_e_val - mean_e_val_prev > 0) || ...
            (abs(mean_e_val - mean_e_val_prev) < 1e-8 * size(Xval, 1)))
            break
        end

        mean_e_train_prev = mean_e_train;
        mean_e_val_prev = mean_e_val;

    end
    
    %% Save result
    save('cache/mlp', 'W1', 'W2')
    
    %% Plot error convergence
    figure(1)
    clf
    semilogy(mean_e_hist(:, 1) / size(Xtrain, 1))
    hold on
    semilogy(mean_e_hist(:, 2) / size(Xval, 1), '--')
    grid on
    xlabel('Número de épocas')
    ylabel('Erro quadrático médio')
    legend('Treinamento', 'Validação')
    drawnow()
    set(gcf, 'paperunits', 'centimeters', 'paperposition', [0 0 10 10])
    print -dpng -r300 results/mlp_train.png
    
    display(['   ... Completed in ' num2str(epoch) ' epochs and ' num2str(toc(total_time)) ' seconds.'])
end

function y = g(x)
    y = 1 ./ (1 + exp(-x));
end

function y = g_dot(x)
    y = g(x) .* (1 - g(x));
end