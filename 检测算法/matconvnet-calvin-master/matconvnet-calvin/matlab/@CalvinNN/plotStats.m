function plotStats(obj, epochs, stats, plotAccuracy) %#ok<INUSL>
% plotStats(obj, epochs, stats, plotAccuracy)
%
% Plot the results of different metrics on train and validation set.
%
% Copyright by Holger Caesar, 2016

% Define color map
cmap = parula(3);
cmap(3, :) = [255, 140, 0] / 255;

if true
    figure(1);
    clf;
    if plotAccuracy
        hsp1 = subplot(2, 1, 1);
    end
    hold on;
    leg = {};
    datasetModes = {'train', 'val'};
    for datasetModeIdx = 1 : numel(datasetModes)
        datasetMode = datasetModes{datasetModeIdx};
        field = 'objective';
        fieldValues = [stats.(datasetMode).(field)];
        if datasetModeIdx == 1
            marker = '-';
        else
            marker = '--';
        end
        
        % For i.e. objective with 1 value
        leg{end + 1} = sprintf('%s (%s)', field, datasetMode); %#ok<AGROW>
        values = fieldValues(1, :)';
        plot(epochs, values, 'Color', cmap(1, :), 'LineStyle', marker);
    end
    hleg1 = legend(leg, 'Location', 'NorthEastOutSide');
    
    xlabel('epoch');
    ylabel('objective');
    grid on;
end

if plotAccuracy
    hsp2 = subplot(2, 1, 2);
    hold on;
    
    leg = {};
    datasetModes = {'train', 'val'};
    for datasetModeIdx = 1 : numel(datasetModes)
        datasetMode = datasetModes{datasetModeIdx};
        field = 'accuracy';
        fieldValues = [stats.(datasetMode).(field)];
        if datasetModeIdx == 1
            marker = '-';
        else
            marker = '--';
        end
        
        leg{end + 1} = sprintf('Pix. Acc. (%s)', datasetMode); %#ok<AGROW>
        values = fieldValues(1, :)';
        plot(epochs, values, 'Color', cmap(1, :), 'LineStyle', marker);
        
        leg{end + 1} = sprintf('Class. Acc. (%s)', datasetMode); %#ok<AGROW>
        values = fieldValues(2, :)';
        plot(epochs, values, 'Color', cmap(2, :), 'LineStyle', marker);
        
        leg{end + 1} = sprintf('Mean IU (%s)', datasetMode); %#ok<AGROW>
        values = fieldValues(3, :)';
        plot(epochs, values, 'Color', cmap(3, :), 'LineStyle', marker);
    end
    
    % Define legend
    hleg2 = legend(leg, 'Location', 'NorthEastOutSide');
    
    % Align both plots
    if false
        plotPos1 = get(hsp1, 'Position');
        plotPos2 = get(hsp2, 'Position');
        set(hsp2, 'Position', [plotPos1(1), plotPos2(2), plotPos1(3:4)]);
        legPos1 = get(hleg1, 'Position');
        legPos2 = get(hleg2, 'Position');
        set(hleg2, 'Position', [legPos1(1), legPos2(2), legPos1(3:4)]);
    end
    
    xlabel('epoch');
    ylabel('accuracy');
    grid on;
end