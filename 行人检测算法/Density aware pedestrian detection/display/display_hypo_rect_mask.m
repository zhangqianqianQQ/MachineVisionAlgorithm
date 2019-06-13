function display_hypo_rect_mask(edge_map,vote_map,hypo_list,score_list,...
    bbox,voterec,valid_vote_idx,testpos,hypo_mask)

nb_plot = 1;
plot_idx= 1;

if(~isempty(vote_map))
    nb_plot = nb_plot+1;
end
if(exist('hypo_mask','var') && ~isempty(hypo_mask) && ~isempty(score_list))
    nb_plot = nb_plot+1;
end
figure;

subplot(1,nb_plot,1);
max_score=max(score_list);
[dummy,s_idx]=sort(score_list,'ascend');
imshow(edge_map);
title(sprintf('Voto maximo:%.4f',max_score));
hold on;axis on;
colors=jet(64);
nb_hypo = length(score_list);
colors  = colors(round(score_list*64/max_score),:);
marker_size = 8;
nb_test = size(testpos,1);
for hypo=1:nb_hypo
    % plot voters
    idx_code_curhypo= voterec(hypo).voter_id;
    idx_code_curhypo= valid_vote_idx(idx_code_curhypo);
    idx_fea_curhypo = mod(idx_code_curhypo-1, nb_test) + 1; % feature id
    x_pos	= testpos(idx_fea_curhypo, 1);
    y_pos	= testpos(idx_fea_curhypo, 2);
    
    plot(x_pos,y_pos,'o','MarkerEdgeColor', colors(hypo,:), 'MarkerSize', (s_idx(hypo)*marker_size/nb_hypo),...
        'MarkerFaceColor', colors(hypo,:));    
    
    plot(hypo_list(hypo,1),hypo_list(hypo,2), ...
        'o', 'MarkerSize', 8, 'MarkerFaceColor', colors(hypo,:));
    hypo_bbox   = bbox(hypo,:);    
    rectangle('Position',[hypo_bbox(1), hypo_bbox(2), hypo_bbox(3)-hypo_bbox(1), hypo_bbox(4)-hypo_bbox(2)],...
        'LineWidth',1,'EdgeColor',colors(hypo,:));
end
text(hypo_list(:,1)+2,hypo_list(:,2)+3,...
    num2cell(score_list),'BackgroundColor',[.7,.9,.7]);
if(~isempty(vote_map))
    plot_idx    = plot_idx+1;
    subplot(1,nb_plot, plot_idx);
    imagesc(vote_map);
    axis image;
    hold on;
    plot(hypo_list(:,1), hypo_list(:,2), 'g+');
    title('vote map');
end

if(exist('hypo_mask','var') && ~isempty(hypo_mask) && ~isempty(score_list))
    plot_idx    = plot_idx+1;
    subplot(1,nb_plot,plot_idx);
    if(~isempty(score_list))
        [dummy,m_id]=max(score_list);
        imagesc(hypo_mask(:,:,m_id));
        axis image;
        title('mask of hypothesis with max score');
    end
end
