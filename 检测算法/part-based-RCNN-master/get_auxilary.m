%% Get auxilary informations for the geometric constraints
%% Written by Ning Zhang

function feat_opts = get_auxilary(config)

for p = 1 : config.N_parts - 1
    X{p} = [];
    for k = 1 : length(config.impathtrain)
      if config.train_box{p + 1}(k, 1) ~= -1
        part_box = config.train_box{1}(k, :) - ...
            [config.train_box{p + 1}(k, 1) config.train_box{p + 1}(k, 2) ...
	    config.train_box{p + 1}(k, 1) config.train_box{p + 1}(k, 2)];
        w = config.train_box{p + 1}(k, 3) - config.train_box{p + 1}(k, 1);
        h = config.train_box{p + 1}(k, 4) - config.train_box{p + 1}(k, 2);
        part_box = part_box ./ [w h w h];
        center_x = (part_box(2) + part_box(4))/2;
        center_y = (part_box(1) + part_box(3))/2;
        scale_x =  (part_box(4) - part_box(2));
        scale_y = (part_box(3) - part_box(1));
        X{p} = [X{p}; center_x center_y scale_x scale_y];
      else
        X{p} = [X{p}; -1 -1 -1 -1];
      end
    end
    try
      prior{p} = gmdistribution.fit(X{p}, 4);
    catch
      try
      	prior{p} = gmdistribution.fit(X{p}, 2);
      catch
        prior{p} = gmdistribution.fit(X{p}, 1);
      end
    end
end
feat_opts.prior = prior;
feat_opts.X = X;

% load groundtruth bounding box fea
load('caches/finetune_train_fea_fc7')
feat_opts.train_fea = train_fea{1};
end

