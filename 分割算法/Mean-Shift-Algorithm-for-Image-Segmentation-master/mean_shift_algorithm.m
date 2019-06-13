function [clustCent,data2cluster,cluster2dataCell] = mean_shift_algorithm(dataPts,bandwidth,threshold);

[dim_dataset,no_data_dataset] = size(dataPts);
no_cluster = 0;         bandSq = (bandwidth).^2;
dataset_index = 1:no_data_dataset;
threshold_convergence =  threshold;% bandwidth(1,1)*exp(-3);  % this condition is taken from a reference paper on the web
tracking_array= false(1,no_data_dataset); % tracking: if a points been seen already
no_point_4_initial = no_data_dataset; % number of points to posibaly use as initilization points
clusterV = zeros(1,no_data_dataset,'uint16'); % cluster allotment method
clustMembsCell = [];
clustCent = []; % center of clust

while no_point_4_initial
    % choosing random data set for and then converging it
    random_index = ceil( (no_point_4_initial-1e-6)*rand); % pick a random seed point
    random_data_point = dataset_index(random_index); % use this point as start of mean
    mean_cur = dataPts(:,random_data_point);  % intilize mean to this points location
    cluster_members = []; % points that will get added to this cluster
    cluster_mem = zeros(1,no_data_dataset,'uint16');
    % convergence loop
    while true
        squ_Euclidean_distance(1,:) = sum(bsxfun(@minus,mean_cur(1:2,:),dataPts(1:2,:)).^2); % dist squared from mean to all points still active
        squ_Euclidean_distance(2,:) = sum(bsxfun(@minus,mean_cur(3:5,:),dataPts(3:5,:)).^2);
        kernel_range_datapoint_index = find(squ_Euclidean_distance(1,:) < bandSq(1,1)  );% points within bandWidth
        kernel_range_datapoint_index= find(squ_Euclidean_distance(2,:) < bandSq(1,2) );
        cluster_mem(kernel_range_datapoint_index) = cluster_mem(kernel_range_datapoint_index)+1; 
        mean_previous = mean_cur; % save the old mean
        mean_cur = gaussian_kernel(dataPts(:,kernel_range_datapoint_index),sqrt(squ_Euclidean_distance(1,kernel_range_datapoint_index)),sqrt(squ_Euclidean_distance(2,kernel_range_datapoint_index)),bandwidth); % compute the new mean
        cluster_members = [cluster_members kernel_range_datapoint_index]; % add any point within bandWidth to the cluster
        tracking_array(cluster_members) = true; % mark that these points have been visited
        % converging condition
        if norm(mean_cur-mean_previous) < threshold_convergence
            join_cluster = 0;
            for cno = 1:no_cluster
                dist1 = norm(mean_cur(1:2)-clustCent(1:2,cno)); % spatial
                dist2 = norm(mean_cur(3:5)-clustCent(3:5,cno)); %range
                if( dist1 < bandwidth(1,1) &&dist2<bandwidth(1,2)) % condition to join the kernel
                    join_cluster = cno;
                    break;
                end
            end
            
            if join_cluster > 0
                nc = numel(cluster_members);
                no = numel(clustMembsCell{join_cluster});
                nw = [nc;no]/(nc+no);
                clustMembsCell{join_cluster} = unique([clustMembsCell{join_cluster},cluster_members]);
                clustCent(:,join_cluster) = mean_cur*nw(1) + mean_previous*nw(2);
                clusterV(join_cluster,:) = clusterV(join_cluster,:) + cluster_mem;
            else 
                no_cluster = no_cluster+1;
                clustCent(:,no_cluster) = mean_cur;
                clustMembsCell{no_cluster} = cluster_members;
                clusterV(no_cluster,:) = cluster_mem;
            end
            break;
        end
    end
    dataset_index = find(~tracking_array);
    no_point_4_initial = length(dataset_index);
end
[~,data2cluster] = max(clusterV,[],1);
if nargout > 2
    cluster2dataCell = cell(no_cluster,1);
    for cno = 1:no_cluster
        cluster_members = find(data2cluster == cno);
        cluster2dataCell{cno} = cluster_members;
    end
end

end
