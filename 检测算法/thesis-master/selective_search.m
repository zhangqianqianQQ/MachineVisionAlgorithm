function boxes = selective_search(im, strategy)

    colorTypes = {'Hsv', 'Lab', 'RGI', 'H', 'Intensity'};
    simFunctionHandles = {@SSSimColourTextureSizeFillOrig, @SSSimTextureSizeFill, @SSSimBoxFillOrig, @SSSimSize};

    if strcmp(strategy, 'single')
        colorTypes = colorTypes{1};
        simFunctionHandles = simFunctionHandles(1);
        k = 100;        % lower k gives more regions
        minSize = k;
        sigma = 0.8;
        [boxes, ~, ~, ~] = Image2HierarchicalGrouping(im, sigma, k, minSize, colorTypes, simFunctionHandles);
        boxes = BoxRemoveDuplicates(boxes);
    elseif strcmp(strategy, 'fast')
        boxes = [];
        similarity_function = simFunctionHandles(1:2);
        ks = {50, 100};
        for ii=1:2
            color_type = colorTypes{ii};
            for kk=1:2
               k = ks{kk};
               sigma = 0.8;
               minSize = k;
               [regions, ~, ~, ~] = Image2HierarchicalGrouping(im, sigma, ...
                   k, minSize, color_type, similarity_function);
               boxes = [boxes; regions];
            end
        end
        boxes = BoxRemoveDuplicates(boxes);
    end
end
