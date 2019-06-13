function display_hypo_rect(edge_map,vote_map,hypo_list,score_list,bbox,axes1,score_thresh)

if(exist('score_thresh','var')&&~isempty(score_thresh))
    vh_idx  = find(score_list>score_thresh);
    hypo_list   = hypo_list(vh_idx,:);
    score_list  = score_list(vh_idx);
    bbox        = bbox(vh_idx,:);
end

if(~exist('axes1','var') || isempty(axes1))
    figure;
    if(~isempty(vote_map))
        subplot(1,2,1);
        imagesc(vote_map);axis image;

        hold on;
        plot(hypo_list(:,1), hypo_list(:,2), 'g+');
        subplot(1,2,2);
    else
        subplot(1,1,1);
    end
else
    axes(axes1);
end
max_score=max(score_list);
imshow(edge_map);
hold on;axis on;
colors=jet(64);
nb_hypo = length(score_list);
colors  = colors(round(score_list*64/max_score),:);
for hypo=1:nb_hypo
    plot(hypo_list(hypo,1),hypo_list(hypo,2), ...
        'o', 'MarkerSize', 8, 'MarkerFaceColor', colors(hypo,:));
    hypo_bbox   = bbox(hypo,:);    
    rectangle('Position',[hypo_bbox(1), hypo_bbox(2), hypo_bbox(3)-hypo_bbox(1), hypo_bbox(4)-hypo_bbox(2)],...
        'LineWidth',1,'EdgeColor',colors(hypo,:));
end
text(hypo_list(:,1)+2,hypo_list(:,2)+3,...
    num2cell(score_list),'BackgroundColor',[.7,.9,.7]);
