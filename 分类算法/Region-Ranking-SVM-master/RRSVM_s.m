classdef RRSVM_s
    % Region Ranking SVM with quadratically constrained programming for s on
    % small scale data (data can be loaded directly into memory one time)
    % By: Minh Hoai Nguyen (minhhoai@cs.stonybrook.edu), Zijun Wei(zijwei@cs.stonybrook.edu)
    
    
    methods (Static)
        % Train RRSVM
        % Bs: 1*n cell structure for bags of instances. Bs{i} is a d*m_i matrix for m_i instances
        % lb: n*1 label vector, lb(i) is 1 or -1.
        % lambda: lambda for LSSVM
        % opts:
        %   opts.initOpt: either {'wb', 'mean', 'random'}. The default is 'mean'
        %   opts.nIter:  default inf
        % This solves the optimization problem
        %   min_{w,s,b} lambda*(w'*w) + sum_i (max_P w'*Bs{i}*P*s + b) - lb(i))^2
        %          s.t. s(1) >= ... >= s(m) >= 0
        %               max_P ||Bs{i}*P*s|| <= 1 for all i. % quadratic constraint
        function [w,b,s, objVals] = train(Bs, lb, lambda, opts)
            
            m = min(100, min(cellfun(@(x)size(x,2), Bs))); % TESTING
            
            n = length(Bs);
            d = size(Bs{1},1);
            
            nIter = 100;
 
            BR = cellfun( @(x)sum(x,2),Bs,'UniformOutput', false) ;
            BR=ML_Norm.l2norm( cat(2,BR{:}));
            
            if isfield(opts,'w') && isfield(opts,'b')
               w=opts.w;
               b=opts.b;
            else
            
            [w,b] = ML_Ridge.ridgeReg(BR, lb, lambda, ones(size(lb)));
            end
            
            
            mBR = mean(BR, 2);
            ub4sumQC = sum(sum((BR - repmat(mBR, 1, n)).^2));
            ub4sumQC = ub4sumQC/n;
            fprintf('ub4sumQC: %g\n', ub4sumQC);
            
            
            BtBs = cell(1, n);
            for i=1:n
                ml_progressBar(i, n, 'Precomputing BtBs');
                BtBs{i} = Bs{i}'*Bs{i};
            end;
            
            
            objVals = zeros(1, 2*nIter);
            for iter=1:nIter
                fprintf('----->  iter: %d\n',  iter);
                % update the order of instances
                IS = zeros(m, n); % instance score
                Q4S = 0;
                MB = 0;
                for i=1:n
                    ml_progressBar(i, n, 'Getting QCs');
                    score_i = Bs{i}'*w;
                    [brIdxs, IS(:,i)] = RRSVM_s.scoreSample(score_i, m);
                    %Q4S = Q4S + Bs{i}(:,brIdxs)'*Bs{i}(:,brIdxs);
                    Q4S = Q4S + BtBs{i}(brIdxs, brIdxs);
                    MB = MB + Bs{i}(:, brIdxs);
                end;
                MB = MB/n; % mean
                Q4S = Q4S/n - MB'*MB; % centralized
                
                [s, b, objVal] = RRSVM_s.update_sb(IS, lb, Q4S, ub4sumQC);
                objVal = objVal + lambda*(w'*w);
                objVals(2*iter-1) = objVal;
                fprintf('  After updating s,b:  %.6f\n', objVal);
                fprintf('  s: ');fprintf('%g ', s(1:10)); fprintf('\n');
                
                [w,b,objVal,isSuccess, nIter2] = RRSVM_s.update_wb(Bs, lb, lambda, w, b, s);
                fprintf('  Updating w,b, isSuccess: %d, nIter2: %d\n', isSuccess, nIter2);
                fprintf('  After updating w,b:  %.6f\n', objVal);
                objVals(2*iter) = objVal;
                
                if iter > 1 && ((objVals(2*iter-2) - objVals(2*iter)) < 1e-3*objVals(2*iter-2))
                    fprintf('  Decrease in obj val is small, terminating\n');
                    break;
                end;
            end;
            objVals(2*iter+1:end) = [];
        end
        
        
        % Fixing s, making a single step update to w,b
        % Bs: 1*n cell structure for bags of instances. Bs{i} is a d*m_i matrix for m_i instances
        % lb: n*1 label vector, lb(i) is 1 or -1.
        % lambda: lambda for LSSVM
        % opts:
        %   opts.initOpt: default 'mean';
        %   opts.nIter:  default inf
        % This solves the optimization problem
        %   min_{w,b} lambda*(w'*w) + sum_i (max_P w'*Bs{i}*P*s + b) - lb(i))^2
        %        s/t: max_P ||Bs{i}*P*s|| <= 1
        function [w_new,b_new, objVal_new, isSuccess, iter] = update_wb(Bs, lb, lambda, w_old, b_old, s)
            objVal_old = RRSVM_s.cmpObj(Bs, lb, lambda, w_old, b_old, s);
            
            n = length(Bs);
            d = size(Bs{1},1);
            m = length(s);
            BR = zeros(d, n); % bag representation
            for i=1:n
                score_i = Bs{i}'*w_old;
                irIdxs = RRSVM_s.scoreSample(score_i, m);
                BR(:,i) = Bs{i}(:,irIdxs)*s;
            end;
            [w_new,b_new] = ML_Ridge.ridgeReg(BR, lb, lambda, ones(size(lb))); % line search direction
            
            % Do binary line search to find a point with lower energy
            iter = 0;
            nIter = 20;
            while iter < nIter
                objVal_new = RRSVM_s.cmpObj(Bs, lb, lambda, w_new, b_new, s);
                if objVal_new < objVal_old
                    break;
                end;
                w_new = (w_old + w_new)/2;
                b_new = (b_old + b_new)/2;
                iter = iter + 1;
            end;
            if iter == nIter % fail
                w_new = w_old;
                b_new = b_old;
                objVal_new = objVal_old;
                isSuccess = false;
            else
                isSuccess = true;
            end;
        end
        
        % compute the objective value
        function objVal = cmpObj(Bs, lb, lambda, w, b, s)
            n = length(Bs);
            m = length(s);
            score = zeros(n, 1);
            BR = cell(1, n);
            for i=1:n
                score_i = Bs{i}'*w;
                [brIdxs, score_i2] = RRSVM_s.scoreSample(score_i, m);
                score(i) = score_i2'*s;
                BR{i} = Bs{i}(:, brIdxs)*s;
            end;
            BR = cat(2, BR{:});
            mBR = mean(BR, 2);
            sumQC = sum(sum((BR - repmat(mBR, 1, n)).^2));
            sumQC = sumQC/n;
            
            if sumQC > 1 + 1e-3 % constraint not satisfied
                objVal = inf;
            else
                objVal = lambda*(w'*w) + sum((score +b - lb).^2);
            end;
        end
        
        % D: d*n matrix
        % lb: n*1 vector of 1 or -1 for label
        % Solve the linear programming:
        %   min_{s, b} \sum_i (s'*D(:,i) + b - lb(i))^2
        %         s.t. s_1 >= s_2 >= ... >= s_d
        %              s'*Q4S*s <= ub4sumQC
%         function [s, b, objVal] = update_sb(D, lb, Q4S, ub4sumQC)
%             d = size(D,1);
%             
%             % variable x = [s; b; xi] = [s_1; ...; s_d; b; xi_1; ...; xi_n];
%             cplex = Cplex('update_sb');
%             cplex.Model.sense = 'minimize';
%             
%             d1 = d+1;
%             D(end+1,:) = 1;
%             cplex.Model.Q = D*D';
%             
%             % Add linear part of the objective
%             obj = - D*lb;
%             
%             % cplex.Model.obj = obj; % this syntax doesn't work, use the below
%             cplex.addCols(obj);
%             
%             % Add constraint: s_k >= 0
%             lbound = zeros(d1,1);
%             lbound(d1) = -inf; % no lower bound for bias b
%             cplex.Model.lb = lbound;
%             
%             %             % Add constraint: s'Q4S*s <= 1
%             Q4S(end+1,end+1) = 0;
%             cplex.addQCs(zeros(d1, 1), double(Q4S), 'L', ub4sumQC);
%             
%             % Add constraint: s_1 >= s_2 >= ... >= s_d
%             constrVecs = zeros(d-1, d1);
%             linIdx = sub2ind([d-1, d1], 1:(d-1), 1:(d-1));
%             constrVecs(linIdx) = 1;
%             constrVecs(linIdx + (d-1)) = -1;
%             cplex.addRows(zeros(d-1,1), constrVecs, inf(d-1,1));
%             
%             % Callback function for display
%             cplex.DisplayFunc = []; %@disp;
%             
%             % solve
%             cplex.Param.threads.Cur = 1; % use a single thread
%             cplex.solve();
%             x = cplex.Solution.x;
%             objVal = 2*cplex.Solution.objval + sum(lb.^2);
%             s = x(1:d);
%             b = x(d1);
%         end
        

% This is for 12.8 and up
        function [s, b, objVal] = update_sb(D, lb, Q4S, ub4sumQC)
            d = size(D,1);
            

            options = cplexoptimset;
            options.Display = 'off';
            
            d1 = d+1;
            D(end+1,:) = 1;
            H =   D*D';
            
            % Add linear part of the objective
            f =   - 2 * D*lb;
            
            
            % Add constraint: s_k >= 0
            lbound = zeros(d1,1);
            lbound(d1) = -inf; % no lower bound for bias b
            

            %             % Add constraint: s'Q4S*s <= 1
            Q4S(end+1,end+1) = 0;
            l = zeros(d1, 1);            
            Qr = Q4S;
            r = ub4sumQC;
            
            % Add constraint: s_1 >= s_2 >= ... >= s_d
            constrVecs = zeros(d-1, d1);
            linIdx = sub2ind([d-1, d1], 1:(d-1), 1:(d-1));
            constrVecs(linIdx) = -1;
            constrVecs(linIdx + (d-1)) = 1;
            Aineq = constrVecs;
            bineq = zeros(d-1, 1);
            
             [x, fval, ~, ~] = ...
            cplexqcp (H, f, Aineq, bineq, [ ], [ ], l, Qr, r, lbound, [], [ ], options);


            objVal = 2*fval + sum(lb.^2);
            s = x(1:d);
            b = x(d1);
        end


         function [sampleIdxs, sampleScore] = scoreSample(score, m)
            score = score(:);
            n = length(score);
            [~, sortedIdxs] = sort(score, 'descend');
            
            q = floor(m/n); % number of full rounds
            r = m - n*q; % remainder
            
            sampleIdxs = [];
            if q > 0
                sampleIdxs = repmat(sortedIdxs, q, 1); 
            end;
            sampleIdxs = [sampleIdxs; sortedIdxs(1:r)];            
            
            sampleScore = score(sampleIdxs);
            [sampleScore, sortedIdxs] = sort(sampleScore, 'descend');
            sampleIdxs = sampleIdxs(sortedIdxs);
        end;
        
           % prediction
        % Bs: 1*n cell structure for bags of instances. Bs{i} is a d*m_i matrix for m_i instances
        % w: weight vector of SVM, b: bias term
        % s: distribution weight vecor of non-increasding order        
        function score = predict(Bs, w, b, s)
            m = length(s);
            n = length(Bs);
            score = zeros(n, 1);
            for i=1:n
                score_i = Bs{i}'*w;
                [~, score_i2] = RRSVM_s.scoreSample(score_i, m);                                
                score(i) = score_i2'*s;
            end;            
            score = score + b;
        end
        
    end
end

