setup ;
close all;

% Initial CNN parameters:
w = 10 * randn(27, 27) ;
w = single(w - mean(w(:))) ;
b = single(0);

sample = 80;
global_w = w;
global_b = b;

% SGD parameters:
% - numIterations: maximum number of iterations
% - rate: learning rate
% - momentum: momentum rate
% - shrinkRate: shrinkage rate (or coefficient of the L2 regulariser)
% - plotPeriod: how often to plot

numIterations = 100;
rate = 5 ;
momentum = 0.9;
shrinkRate = 0.0001 ;
plotPeriod = 5;

for i = 1:sample 
    close all;
    load(['Detection/img' num2str(i) '/img' num2str(i) '_detection.mat']);
    im = rgb2gray(im2single(imread(['Detection/img' num2str(i) '/img' num2str(i) '.bmp'])));
    
    % -------------------------------------------------------------------------
    % Process the ground true data
    % -------------------------------------------------------------------------
    temp = zeros(500);
    for j=1:size(detection, 1)
        temp(max(floor(detection(j, 2)), 1), min(floor(detection(j, 1)), 500)) = 1;
    end
    neg = ~imdilate(temp, strel('disk', 5, 0)) ; % draw a circle around the pixel
    pos = logical(temp);

    % Plot the ground true
    figure('Name',['Image: ' num2str(i)]) ; clf ;
    subplot(1,3,1) ; imagesc(im) ; axis equal ; title('image') ;
    hold on;
    plot(detection(:, 1), detection(:, 2), 's', 'MarkerSize',10, 'Color', 'g');
    subplot(1,3,2) ; imagesc(pos) ; axis equal ; title('positive points (blob centres)') ;
    subplot(1,3,3) ; imagesc(neg) ; axis equal ; title('negative points (not a blob)') ;
    colormap gray ;

    % -------------------------------------------------------------------------
    % Image preprocessing
    % -------------------------------------------------------------------------
    % % Pre-smooth the image
    % im = vl_imsmooth(im,3) ;
    % 
    % % Subtract median value
    % im = im - median(im(:)) ;

    % -------------------------------------------------------------------------
    % Learning with stochastic gradient descent
    % -------------------------------------------------------------------------

    % Initial CNN parameters:
    w = global_w;
    b = global_b;

    % Create pixel-level labes to compute the loss
    y = zeros(size(pos),'single') ;
    y(pos) = +1 ;
    y(neg) = -1 ;

    % Initial momentum
    w_momentum = zeros('like', w) ;
    b_momentum = zeros('like', b) ;

    minE = 1000;
    minW = w;
    minb = b;

    % SGD with momentum
    for t = 1:numIterations

      % Forward pass
      res = tinycnn(im, w, b) ;

      E(1,t) = ...
        mean(max(0, 1 - res.x3(pos))) + ...
        mean(max(0, res.x3(neg))) ;
      E(2,t) = 0.5 * shrinkRate * sum(w(:).^2) ;
      E(3,t) = E(1,t) + E(2,t) ;

      dzdx3 = ...
        - single(res.x3 < 1 & pos) / sum(pos(:)) + ...
        + single(res.x3 > 0 & neg) / sum(neg(:)) ;

      % Backward pass
      res = tinycnn(im, w, b, dzdx3) ;

      % Update momentum
      w_momentum = momentum * w_momentum + rate * (res.dzdw + shrinkRate * w) ;
      b_momentum = momentum * b_momentum + rate * 0.1 * res.dzdb ;

      % Gradient step
      w = w - w_momentum ;
      b = b - b_momentum ;

      % Keep the weight when the objective function is the smallest
        if minE > E(3,t)
            minW = w;
            minb = b;
        end

      % Plots
      if mod(t-1, plotPeriod) == 0 || t == numIterations
        fp = res.x3 > 0 & y < 0 ;
        fn = res.x3 < 1 & y > 0 ;
        tn = res.x3 <= 0 & y < 0 ;
        tp = res.x3 >= 1 & y > 0 ;
        err = cat(3, fp|fn , tp|tn, y==0) ;

        figure('Name',['Image: ' num2str(i)]) ; clf ;
        colormap gray ;

        subplot(2,3,1) ;
        plot(1:t, E(:,1:t)') ;
        grid on ; title('objective') ;
        ylim([0 100]) ; legend('error', 'regularizer', 'total') ;

        subplot(2,3,2) ; hold on ;
        [h,x]=hist(res.x3(pos(:)),30) ; plot(x,h/max(h),'g') ;
        [h,x]=hist(res.x3(neg(:)),30) ; plot(x,h/max(h),'r') ;
        plot([0 0], [0 1], 'b--') ;
        plot([1 1], [0 1], 'b--') ;
        xlim([-2 3]) ;
        title('histograms of scores') ; legend('pos', 'neg') ;

        subplot(2,3,3) ;
        vl_imarraysc(w) ;
        title('learned filter') ; axis equal ;

        subplot(2,3,4) ;
        imagesc(res.x3) ;
        title('network output') ; axis equal ;

        subplot(2,3,5) ;
        
        imagesc(my_non_maxima(res.x3, 4, 2000))
        title('nuclie location output') ; axis equal ;

        subplot(2,3,6) ;
        image(err) ;
        title('red: pred. error, green: correct, blue: ignore') ;

        if verLessThan('matlab', '8.4.0')
          drawnow ;
        else
          drawnow expose ;
        end
      end
    end

    global_w = minW;
    global_b = minb;
end
