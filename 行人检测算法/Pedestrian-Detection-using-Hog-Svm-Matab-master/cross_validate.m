function svm_params = cross_validate(kernel_type, cost_range, gamma_range, train_matrix, labels, model_save_path)
% CROSS_VALIDATE Tests a (lib)SVM classifier from the specified image paths
%
% INPUT:
%       kernel_type: svm kernel function (linear or rbf)
%       cost_range, gamma_range: cost and gamma values to cross validate 
%       train_matrix: training matrix (rows: cases, columns: features)
%       labels: columns matrix with th training cases labels
%       model_save_path: path where to save the final svm model
%
% OUTPUTS:
%       svm_params: string in libSBM format with the best parameters found.
%
%$ Author: Jose Marcos Rodriguez $    
%$ Date: 2013/11/09 $    
%$ Revision: 1.00 $
    
    
    fprintf('Beginning crossvalidation\n')
    log = '';
    crossval_start = tic;
    
    % ---------------------------------------------------------------------
    %% Radial Basis Function
    % ---------------------------------------------------------------------
    if strcmp(kernel_type, 'rbf')
        crossval_matrix = zeros(numel(gamma_range), numel(cost_range));
        best_cv = 0;
        best_g = 0;
        best_c = 0;
        k = 3;  % number of folds

        for g_ind=1:numel(gamma_range)
            g = gamma_range(g_ind);
            for c_ind=1:numel(cost_range)
                c = cost_range(c_ind);
                svm_params = ['-q -v ', num2str(k), ' -t ', num2str(2),' -g ', num2str(g),' -c ', num2str(c)];
                cv = svmtrain(labels, train_matrix, svm_params);
                crossval_matrix(g_ind, c_ind) = cv;
                fprintf('<gamma=%d, cost=%d> \n\n',g,c);
                
                % writing crossvalidation log file
                log_file = fopen([model_save_path,'.cv'],'a');
                fprintf(log_file, sprintf('<gamma=%f, cost=%f>: acc=%f \n\n',g,c,cv));
                fclose(log_file);

                % updating best cv value
                if (cv >= best_cv),
                    best_cv = cv; 
                    best_g = g;
                    best_c = c;
                end
            end
        end

        crossval_elapsed = toc(crossval_start);
        fprintf('SVM crosvalidation done in: %f seconds.\n',crossval_elapsed);

        % final training params
        fprintf('Best crossval reached: %d, with gamma=%d, cost=%d\n\n', best_cv, best_g, best_c);
        svm_params = ['-q -t ', num2str(2),' -g ', num2str(best_g),' -c ', num2str(best_c),' -b 1'];

        % Plot the cross validation grid
        figure;
        imagesc(crossval_matrix'); colormap('jet'); colorbar;
        set(gca,'XTick',1:numel(gamma_range))
        set(gca,'XTickLabel',sprintf('%.2d|',gamma_range))
        xlabel('gamma');
        set(gca,'YTick',numel(cost_range))
        set(gca,'YTickLabel',sprintf('%.2d|',cost_range))
        ylabel('cost');

    % --------------------------------------------------------------------- 
    %% Linear SVM
    % ---------------------------------------------------------------------
    elseif strcmp(kernel_type, 'linear')
        crossval_matrix = zeros(1,numel(cost_range));
        best_cv = 0;
        best_c = 0;
        k = 3;  % number of folds

        for c_ind=1:numel(cost_range)
            c = cost_range(c_ind);
            svm_params = ...
                ['-q -v ', num2str(k),' -t ',num2str(0) ,' -c ', num2str(c)];
            cv = svmtrain(labels, train_matrix, svm_params);
            crossval_matrix(1,c_ind) = cv;
            fprintf('<cost=%d> \n\n',c);
            
            % writing crossvalidation log file
            log_file = fopen([model_save_path,'.cv'],'a');
            fprintf(log_file, sprintf('<cost=%f>: acc=%f \n\n',c, cv));
            fclose(log_file);
            
            % updating best cv value
            if (cv >= best_cv),
                best_cv = cv; 
                best_c = c;
            end
        end

        crossval_elapsed = toc(crossval_start);
        fprintf('SVM crosvalidation done in: %f seconds.\n',crossval_elapsed);

        % final training params
        fprintf('Best crossval reached: %d, with cost=%d\n\n', best_cv, best_c);
        svm_params = ['-q -t ',num2str(0) ,' -c ', num2str(best_c),' -b 1'];

        % Plot the cross validation grid
        figure;
        plot(crossval_matrix');
        set(gca,'XTickLabel',sprintf('%.2d|',cost_range))
        xlabel('cost');
        ylabel('accuracy');
    end
