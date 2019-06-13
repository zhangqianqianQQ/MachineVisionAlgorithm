classdef ML_Ridge
% Weighted ridge regression, Weighted Kernel Ridge Regression (Least Square SVM), 
% Unsupervised ridge/kernel ridge regression
% By: Minh Hoai Nguyen (minhhoai@robots.ox.ac.uk)
% Created: 08-Jun-2014
% Last modified: 17-Oct-2014    
    
    methods (Static)        
        %% Ridge regression functions
        
        % Weighted Ridge Regression. No need to return leave-one-out estimates.
        % X: d*n matrix
        % y: n*1 value (label) vector (doesn't have to be binary)
        % s: n*1 non-negative weight vector. The default is ones(n,1);
        % lambda: ridge regression param
        % minimize: lambda*||w||^2 + sum_i s_i*(w'*x_i + b - y_i)^2
        function [w, b, obj] = ridgeReg(X, y, lambda, s)
            if ~exist('s', 'var')
                s = [];
            end;
            
            [C, X1S] = ML_Ridge.ridgeReg_step0(X, lambda, s);            
            wb = C\(X1S*y);
            b = wb(end);
            w = wb(1:end-1);
            if nargout > 2
                err = X'*w + b - y;
                if isempty(s)
                    obj = sum(err.^2) + lambda*(w'*w);
                else
                    obj = sum(s.*(err.^2)) + lambda*(w'*w);
                end
            end;
        end
        
        % Weighted Ridge Regression with leave-one-out estimates
        % minimize: lambda*||w||^2 + sum_i s_i*(w'*x_i + b - y_i)^2                
        % X: d*n matrix
        % y: n*1 value (label) vector (doesn't have to be binary)
        % s: n*1 non-negative weight vector. The default is ones(n,1);
        % lambda: ridge regression param
        % Outputs:
        %   w, b: weight vector and bias term
        %   cvErrs: 1*n vector cvErrs(i): difference between predicted and gt value.
        %   cvWs(:,i), cvBs(i): weight vector and bias term for leaving the i^th training data out
        function [w,b, cvErrs, cvWs, cvBs] = ridgeReg_cv(X, y, lambda, s)
            if ~exist('s', 'var')
                s = ones(size(X,2),1);
            end;
            [M, diagH] = ML_Ridge.ridgeReg_step1(X, lambda, s);
            if nargout > 3
                [w, b, cvErrs, cvWs, cvBs] = ML_Ridge.ridgeReg_step2(X, y, s, M, diagH);
            else
                [w, b, cvErrs] = ML_Ridge.ridgeReg_step2(X, y, s, M, diagH);
            end
        end        

        
        % Divide ridgeReg into several steps.
        % Steps 0 and 1 do not depend on the label vector. 
        % This is for reusing computation for multiple regression problems with diff label vectors
        % See ridgeReg, ridgeReg_cv for explanation of inputs, outputs
        function [C, X1S, X1] = ridgeReg_step0(X, lambda, s)
            X1 = X;
            d = size(X,1);
            X1(d+1,:) = 1; 
            if exist('s', 'var') && ~isempty(s)
                X1S = X1.*repmat(s(:)', d+1, 1);
            else
                X1S = X1;
            end;            
            I0 = eye(d+1);
            I0(d+1,d+1) = 0;
            C = X1S*X1' + lambda*I0;
        end;
        
        % Divide ridgeReg into several steps.
        % Steps 0 and 1 do not depend on the label vector. 
        % This is for reusing computation for multiple regression problems with diff label vectors
        % See ridgeReg, ridgeReg_cv for explanation of inputs, outputs
        function [M, diagH] = ridgeReg_step1(X, lambda, s)
            [C, ~, X1] = ML_Ridge.ridgeReg_step0(X, lambda, s);
            M = C\X1;
            diagH = sum(X1.*M,1)';
        end;
        
        % Divide ridgeReg into several steps.
        % Steps 0 and 1 do not depend on the label vector. 
        % This is for reusing computation for multiple regression problems with diff label vectors
        % See ridgeReg, ridgeReg_cv for explanation of inputs, outputs
        function [w, b, cvErrs, cvWs, cvBs] = ridgeReg_step2(X, y, s, M, diagH)
            wb = M*(s.*y);
            b = wb(end);
            w = wb(1:end-1);            
            e = X'*w + b - y;
            cvErrs = e./(1 - s.*diagH);
                        
            if nargout > 3
                cvWBs = repmat(wb, 1, size(M,2)) + M.*repmat((cvErrs.*s)', size(M,1), 1);
                cvBs  = cvWBs(end,:);
                cvWs  = cvWBs(1:end-1,:);
            end
        end;
        
        % Compute the objective value
        function [obj, totalErr] = cmpObjVal(X, y, s, lambda, w, b)
            err = X'*w + b - y;
            totalErr = sum(s.*(err.^2));
            obj = lambda*(w'*w) + totalErr;      
        end;
        
        %% Kernel Ridge Regression (Least Square SVMs)
        
        % Weighted Kernel ridge regression
        % minimize: 
        %   lambda*alphas'*K*alphas + sum_i s_i*(K(:,i)'*alphas + b - y_i)^2
        % Inputs:
        %   K: n*n similarity matrix 
        %   y: label vector
        %   s: weight vector, should be non-negative
        % Outputs:
        %   alphas, b: coefficients and bias, for test data the predict value: K_tst*alphas + b
        function [alphas, b] = kerRidgeReg(K, y, lambda, s) 
            n = size(K,1);
            K = K.*repmat(s, 1, n); %
           % K = diag(s)*K;
            diagIdxs = sub2ind([n,n], 1:n, 1:n);
            K(diagIdxs) = K(diagIdxs) + lambda; % K = K + lambda*eye(n);                        
            K = [K, s; ones(1,n), 0];                        
            alphasb = K\[s.*y;0];   
            
            b  = alphasb(end);                        
            alphas = alphasb(1:end-1); 
        end

        % Weighted Kernel ridge regression with cross validation errors
        % minimize: 
        %   lambda*alphas'*K*alphas + sum_i s_i*(K(:,i)'*alphas + b - y_i)^2
        % K: n*n kernel matrix 
        % y: label vector
        % s: weight vector, should be non-negative
        % Ouputs:
        %   alphas, b: coefficients and bias, for test data the predict value: K_tst*alphas + b
        %   cvAlphas, cvBs: sets of coefficients and biases for LOOCV
        %     cvAlphas(:,i) and cvBs(i): is the coefficient and bias for leaving i^th traing data out
        %     cvAlphas(:,i) is a n*1 vector, and cvAlphas(i,i) is theoretically zero (~0 in practice)
        %   cvErrs: pred_val - desire_val
        % Base on "Fast Exact Leave-one-out cross-validation of sparse least-squares SVMs"
        function [alphas, b, cvErrs, cvAlphas, cvBs] = kerRidgeReg_cv(K, y, lambda, s) 
            [M, diagH, K1] = ML_Ridge.kerRidgeReg_step1(K, lambda, s);
            if nargout > 3
                [alphas, b, cvErrs, cvAlphas, cvBs] = ML_Ridge.kerRidgeReg_step2(M, diagH, K1, y, s);
            else
                [alphas, b, cvErrs] = ML_Ridge.kerRidgeReg_step2(M, diagH, K1, y, s);
            end;
        end;
        
        function [M, diagH, K1] = kerRidgeReg_step1(K, lambda, s)
            n = size(K,1);            
            K1 = [K; ones(1,n)];            

            % Old and obsolete method of finding M.
            % This is inefficient, and often leads to bad-conditioned linear equations
            % R = [lambda*K, zeros(n,1); zeros(1,n+1)];  
            % K1S = K1.*repmat(s', n+1, 1);             
            % C = R + K1S*K1';                         
            % M = C\K1; % equivalent to Cinv = inv(C); M = Cinv*K1;            

            K = K.*repmat(s, 1, n); % K = diag(s)*K
            Ks = sum(K,1);
            diagIdxs = sub2ind([n,n], 1:n, 1:n);
            K(diagIdxs) = K(diagIdxs) + lambda; % K = K + lambda*eye(n);                        
            K = [K, s; Ks, sum(s)];                        
            M = K\[eye(n);ones(1,n)];   
            
            if any(isnan(M(:))) || any(isinf(M(:)))
                warning('Backslash fail, try psuedo inverse instead. Solution might not be accurate.\n');
                M = pinv(C)*K1;
            end;            
            if any(isnan(M(:))) || any(isinf(M(:)))
                error('Both backslash and psudo-inverse fail\n');
            end;
            diagH = sum(K1.*M,1)'; % equiv to: H = K1'*M; diagH = diag(H);            
        end;

        function [alphas, b, cvErrs, cvAlphas, cvBs] = kerRidgeReg_step2(M, diagH, K1, y, s)            
            n = length(y);
            alphasb = M*(s.*y);
            e = K1'*alphasb - y;
            cvErrs = e./(1-s.*diagH);  
            b = alphasb(end);
            alphas = alphasb(1:end-1);  
            
            if nargout > 3
                cvAlphas = repmat(alphasb, 1, n) + M.*repmat((cvErrs.*s)', n+1,1);
                cvBs = cvAlphas(end,:);
                cvAlphas = cvAlphas(1:end-1,:);
            end
        end;
        
        %% Unsupervised 
        
        % Unsupervised Ridge Regression
        % D: d*n matrix for labeled data
        % lambda: parameter of Ridge Regression
        % s: n*1 weight vector
        % Outputs:
        %   A: n*n matrix.
        %   If x is the label of data, the leave-one-out regression value for data is A'*x 
        %   In other words, if we remove D(:,i) out of traing set, 
        %       the ridge regression value for that data point is A(:,i)'*x
        %   N: (n+1)*n matrix. 
        %       If x is the label, the weight vector for using all data is: [w, b] = N*x
        function [A, N] = unsupRidgeReg(D, lambda, s)
            n = size(D, 2);  % number of labled data points            
                        
            [C, ~, X1] = ML_Ridge.ridgeReg_step0(D, lambda, s);
            M = C\X1;
            H = M'*X1;
            P = H.*repmat(s, 1, size(H,2));
            A = P; 
            diagIdxs = sub2ind([n,n], 1:n, 1:n);
            A(diagIdxs) = 0;
            diagP = diag(P);
            A = A./repmat(1 - diagP', n, 1);            
            N = M.*repmat(s', size(M,1), 1); % M*diag(s)
        end
        
        % Semi-supervised Ridge Regression
        % D: d*n matrix for labeled data
        % lb: n*1 label vector. The values need not binary
        % UD: d*m matrix for unlabeled data
        % lambda: parameter of Ridge Regression
        % s: (n+m)*1 instance weight vector
        % Outputs:
        %   A: m*n matrix, b: n*1 vector
        %   If x (m*1 vector) is the label for UD, the leave-one-out regression values of labeled 
        %       data is A'*x + b. In other words, if we remove D(:,i) out of traing set, 
        %       the ridge regression value for that data point is A(:,i)'*x + b(i);         
        function [A, b] = semiRidgeReg(D, lb, UD, lambda, s)
            n = size(D, 2);  % number of labled data points
            m = size(UD, 2); % number of unlabled data points                       
                        
            [C, ~, X1] = ML_Ridge.ridgeReg_step0([D, UD], lambda, s);
            M = C\X1;
            H = M'*X1;
            P = H.*repmat(s, 1, size(H,2));
            A = P(n+1:n+m,1:n);            
            diagP = diag(P);
            diagP = diagP(1:n);
            b = P(1:n,1:n)'*lb - (diagP.*lb);
            denom = 1 - diagP;
            
            A = A./repmat(denom', m, 1);
            b = b./denom;
        end

        
        % Unsupervised Kernel Ridge Regression
        % K: n*n kernel matrix
        % lambda: parameter of Ridge Regression
        % s: n*1 weight vector
        % Outputs:
        %   A: n*n matrix.
        %   If x is the label of data, the leave-one-out regression value for data is A'*x 
        %   In other words, if we remove i^th training data K(:,i)
        %       the ridge regression value for that data point is A(:,i)'*x
        %   N: (n+1)*n matrix. 
        %       If x is the label, the weight vector for using all data is: [alphas, b] = N*x        
        function [A, N] = unsupKerRidgeReg(K, lambda, s)
            n = size(K,1);
            [M, ~, K1] = ML_Ridge.kerRidgeReg_step1(K, lambda, s);

            H = M'*K1;
            P = H.*repmat(s, 1, size(H,2));
            A = P; 
            diagIdxs = sub2ind([n,n], 1:n, 1:n);
            A(diagIdxs) = 0;
            diagP = diag(P);
            A = A./repmat(1 - diagP', n, 1);            
            N = M.*repmat(s', size(M,1), 1); % M*diag(s)
        end;
        

        %% Testing functions
        
        % Very simple test of, as lambda increases, the error should increase
        function test1()
            d = 20;
            n = 10;
            X = rand(d, n);
            y = 2*randi(2, [n, 1]) - 3;   
            
            lambdas = n*[0, 10.^(-10:3)];
            fprintf('As lambda increase, the error should increase\n');
            for i=1:length(lambdas)
                lambda = lambdas(i);
                [w, b] = ML_Ridge.ridgeReg(X, y, lambda, []);            
                err = X'*w + b - y;
                totalErr = sum(err.^2);
                fprintf('lambda: %10g, err: %15g\n', lambda, totalErr);
            end;
        end;
        
        % check weighted version
        % If some data points are repeated several times, it should be the same as increase the
        % weights for those data points
        function test2()
            d = 100;
            n = 500;
            X = rand(d, n);
            y = 2*randi(2, [n, 1]) - 3;   
                       
            AddX = [X(:,2), X(:,2), X(:,5), X(:,8), X(:,8), X(:,8)];
            addY = y([2,2,5,8,8,8]);
            s = ones(n, 1);
            s(2) = 3;
            s(5) = 2;
            s(8) = 4;

            lambda = 1e-1;
            [w1, b1] = ML_Ridge.ridgeReg(X, y, lambda, s);            
            [w2, b2] = ML_Ridge.ridgeReg([X, AddX], [y; addY], lambda, ones(n+length(addY),1));
            
            fprintf('sum(abs(w1 - w2)): %10g\n', sum(abs(w1 - w2)));
            fprintf('abs(b1 - b2):      %10g\n', abs(b1 - b2));
            
            [w3, b3] = ML_Ridge.ridgeReg_cv(X, y, lambda, s);            
            [w4, b4] = ML_Ridge.ridgeReg_cv([X, AddX], [y; addY], lambda, ones(n+length(addY),1));
            fprintf('sum(abs(w3 - w2)): %10g\n', sum(abs(w3 - w2)));
            fprintf('abs(b3 - b2):      %10g\n', abs(b3 - b2));
            fprintf('sum(abs(w3 - w4)): %10g\n', sum(abs(w3 - w4)));
            fprintf('abs(b3 - b4):      %10g\n', abs(b3 - b4));
        end;
        
        % Verify the consistency between ridgeReg and leave-one-out estimates
        function test3()
            d = 20;
            n = 10;
            X = rand(d, n);
            y = 2*randi(2, [n, 1]) - 3;   

            lambda = 0.01;
            s = (1:n)';
            
            [~,~, cvErrs, cvWs, cvBs] = ML_Ridge.ridgeReg_cv(X, y, lambda, s);            
            for i=1:n
                Xi = X;
                Xi(:,i) = [];
                si = s;
                si(i) = [];
                yi = y;
                yi(i) = [];
                [wi,bi] = ML_Ridge.ridgeReg(Xi, yi, lambda, si);
                erri = X(:,i)'*wi + bi - y(i);
                fprintf('Leaving %d^th traiing data out\n', i);
                fprintf('  diff in ws: %10g\n', sum(abs(cvWs(:,i) - wi)));
                fprintf('  diff in bs: %10g\n', abs(cvBs(i) - bi));
                fprintf('  diff in error: %10g\n', abs(cvErrs(i) - erri));
            end;
        end;
        
        % Compare two kerRidgeReg_cv and ridgeReg
        function test4()
            d = 20;
            n = 100;
            X = rand(d, n);
            y = 2*randi(2, [n, 1]) - 3;   
            s = 2*ones(n,1);
            lambda = 1e-2;
            [w1, b1] = ML_Ridge.ridgeReg(X, y, lambda, s);

            K = X'*X;
            [alphas, b2] = ML_Ridge.kerRidgeReg_cv(K, y, lambda, s);            
            w2 = X*alphas;
                        
            diff1 = sum(abs(w1 - w2));
            diff2 = abs(b1 - b2);
            fprintf('sum(abs(w1 - w2)): %10g\n', sum(abs(w1 - w2)));
            fprintf('abs(b1 - b2):      %10g\n', abs(b1 - b2)); 
            if diff1 < 1e-8 && diff2 < 1e-8
                fprintf('pass\n');
            else
                fprintf('===============> fail\n');
            end;            
        end;
        
        % Compare kerRidgeReg_cv and ridgeReg_cv
        function test5()
            d = 20;
            n = 10;
            X = rand(d, n);
            y = 2*randi(2, [n, 1]) - 3;   
            K = X'*X;
            lambda = 0.01;
            s = (1:n)';
            
            [w1,b1, cvErrs1, cvWs1, cvBs1] = ML_Ridge.ridgeReg_cv(X, y, lambda, s);            
            
            [alphas2,b2, cvErrs2, cvAlphas2, cvBs2] = ML_Ridge.kerRidgeReg_cv(K, y, lambda, s);
            w2 = X*alphas2;
            
            fprintf('sum(abs(w1 - w2)): %10g\n', sum(abs(w1 - w2)));
            fprintf('abs(b1 - b2):      %10g\n', abs(b1 - b2)); 
            fprintf('sum(abs(cvErrs1 - cvErrs2)): %10g\n', sum(abs(cvErrs1 - cvErrs2)));
            fprintf('sum(abs(cvBs1 - cvBs2)): %10g\n', sum(abs(cvBs1 - cvBs2)));
            
            for i=1:n
                Xi = X;
                Xi(:,i) = [];
                si = s;
                si(i) = [];
                yi = y;
                yi(i) = [];
                Ki = Xi'*Xi;
                
                [alphasi, bi] = ML_Ridge.kerRidgeReg_cv(Ki, yi, lambda, si);
                wi = Xi*alphasi;                
                erri = X(:,i)'*wi + bi - y(i);
                                
                fprintf('Leaving %d^th traiing data out\n', i);
                fprintf('  diff in ws: %10g\n', sum(abs(cvWs1(:,i) - wi)));
                
                cvAlpha2i = cvAlphas2(:,i);
                cvAlpha2i(i) = [];
                fprintf('  diff in alphas: %10g\n', sum(abs(cvAlpha2i - alphasi)));
                fprintf('  diff in bs: %10g\n', abs(cvBs2(i) - bi));
                fprintf('  diff in error: %10g\n', abs(cvErrs2(i) - erri));
            end;
        end;
        
        % check weighted version
        % If some data points are repeated several times, it should be the same as increase the
        % weights for those data points
        function test6()
            d = 50;
            n = 10;
            X = rand(d, n);
            y = 2*randi(2, [n, 1]) - 3;   
                       
            AddX = [X(:,2), X(:,2), X(:,5), X(:,8), X(:,8), X(:,8)];
            addY = y([2,2,5,8,8,8]);
            s = ones(n, 1);
            s(2) = 3;
            s(5) = 2;
            s(8) = 4;

            lambda = 1e-1;
            K = X'*X;
            X2 = [X, AddX];
            K2 = X2'*X2;
            [alpha1, b1] = ML_Ridge.kerRidgeReg_cv(K, y, lambda, s);            
            [alpha2, b2] = ML_Ridge.kerRidgeReg_cv(K2, [y; addY], lambda, ones(n+length(addY),1));
            w1 = X*alpha1;
            w2 = X2*alpha2;
            
            fprintf('sum(abs(w1 - w2)): %10g\n', sum(abs(w1 - w2)));
            fprintf('abs(b1 - b2):      %10g\n', abs(b1 - b2));
        end;

        % Compare two kerRidgeReg and kerRidgeReg_cv
        function test7()
            d = 200;
            n = 50;
            X = rand(d, n);
            y = 2*randi(2, [n, 1]) - 3;   

            K = X'*X;
%             s = (1:n)';
            s = rand(n,1);
            
            lambda = 0.01;
            
            [alphas1, b1] = ML_Ridge.kerRidgeReg(K, y, lambda, s);            
            w1 = X*alphas1;
            [alphas2, b2] = ML_Ridge.kerRidgeReg_cv(K, y, lambda, s);
            w2 = X*alphas2;
                        
            fprintf('sum(abs(alphas1 - alphas2)): %10g (could be big due to non-uniqueness)\n', sum(abs(alphas1 - alphas2)));
            fprintf('abs(w1 - w2):      %10g\n', sum(abs(w1 - w2))); 
            fprintf('abs(b1 - b2):      %10g\n', abs(b1 - b2)); 
        end;
        
        % Comparing speed
        function test8()
            d = 2000;
            n = 5000;
            X = rand(d, n);
            y = 2*randi(2, [n, 1]) - 3;   

            K = X'*X;
            s = rand(n,1);
            
            lambda = 0.01;

            startT = tic;
            [alphas1, b1] = ML_Ridge.kerRidgeReg(K, y, lambda, s);            
            w1 = X*alphas1;            
            dur1 = toc(startT);
            
            startT = tic;
            [alphas2, b2] = ML_Ridge.kerRidgeReg_cv(K, y, lambda, s);
            w2 = X*alphas2;            
            dur2 = toc(startT);
            
            startT = tic;
            [w3, b3] = ML_Ridge.ridgeReg(X, y, lambda, s);            
            dur3 = toc(startT);
            
            obj1 = ML_Ridge.cmpObjVal(X, y, s, lambda, w1, b1);
            obj2 = ML_Ridge.cmpObjVal(X, y, s, lambda, w2, b2);
            obj3 = ML_Ridge.cmpObjVal(X, y, s, lambda, w3, b3);
            
            fprintf('Obj  - kerRidgeReg: %.2f, kerRidgeReg_cv: %.2f, ridgeReg: %.2f\n', obj1, obj2, obj3);
            fprintf('Time - kerRidgeReg: %.2f, kerRidgeReg_cv: %.2f, ridgeReg: %.2f\n', dur1, dur2, dur3);            
            fprintf('abs(w1 - w2):      %10g\n', sum(abs(w1 - w2))); 
            fprintf('abs(b1 - b2):      %10g\n', abs(b1 - b2)); 
            fprintf('abs(w1 - w3):      %10g\n', sum(abs(w1 - w3))); 
            fprintf('abs(b1 - b3):      %10g\n', abs(b1 - b3)); 
        end
        
        function test9()
            d = 20;
            n = 50;
            m = 30;
            D = rand(d, n);
            lb = 2*randi(2, [n, 1]) - 3;   
            
            lambda = 1e-3*(m+n);
            
            UD = rand(d, m);
            s = ones(n+m,1);  
            [A1, b1] = ML_Ridge.semiRidgeReg(D, lb, UD, lambda, s);
            
            [A2, N2] = ML_Ridge.unsupRidgeReg([D, UD], lambda, s);            
            [A3, N3] = ML_Ridge.unsupKerRidgeReg([D,UD]'*[D,UD], lambda, s);
            fprintf('sum(abs(A2(:) - A3(:))): %.2f\n', sum(abs(A2(:) - A3(:))));
            
            udLbs = {ones(m,1), zeros(m,1), -ones(m,1), randn(m,1)};
            
            diffs = zeros(3, length(udLbs));
            for i=1:length(udLbs)
                udLb = udLbs{i};                
                allLb = [lb; udLb];
                [~, ~, cvErr] = ML_Ridge.ridgeReg_cv([D, UD], allLb, lambda);
                cvVal = cvErr(1:n) + lb;                 
                
                cvVal1 = A1'*udLb + b1;
                cvVal2 = A2'*allLb;
                cvVal3 = A3'*allLb;

                diffs(1,i) = sum(abs(cvVal - cvVal1));
                diffs(2,i) = sum(abs(cvVal - cvVal2(1:n)));
                diffs(3,i) = sum(abs(cvVal - cvVal3(1:n)));
                fprintf('sum(abs(cvVal - cvVal1)): %g\n', diffs(1,i));
                fprintf('sum(abs(cvVal - cvVal2)): %g\n', diffs(2,i));
                fprintf('sum(abs(cvVal - cvVal3)): %g\n', diffs(3,i));
            end;
            if any(diffs(:) > 1e-8)
                fprintf('================> Fail\n')
            else
                fprintf('================> Pass\n')
            end;
            
        end;

    end
    
end

