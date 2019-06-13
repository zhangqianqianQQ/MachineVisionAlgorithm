function all_sal = computeSaliency(options)

    if( ~exist( options.outfolder, 'dir' ) ), mkdir( options.outfolder ), end;
    if( ~exist( fullfile( options.outfolder, 'intra-frame_saliency'), 'dir' ) )
        mkdir(fullfile( options.outfolder, 'intra-frame_saliency'));
    end
    if( ~exist( fullfile( options.outfolder, 'inter-frame_saliency'), 'dir' ) )
        mkdir(fullfile( options.outfolder, 'inter-frame_saliency'));
    end
    if( ~exist( fullfile( options.outfolder, 'final_saliency'), 'dir' ) )
        mkdir(fullfile( options.outfolder, 'final_saliency'));
    end
    % Cache all frames in memory
    [data.frames,data.names,height,width,nframe ]= readAllFrames( options );
     % Load optical flow (or compute if file is not found)
    data.flow = loadFlow( options );
    if( isempty( data.flow ) )
        data.flow = computeOpticalFlow( options, data.frames );
    end
    % Load superpixels (or compute if not found)
    data.superpixels = loadSuperpixels( options );
    if( isempty( data.superpixels ) )
        data.superpixels = computeSuperpixels(  options, data.frames );
    end
    % Load Boundary (or compute if not found)
    % computeBoundary
    % 
    
    [ superpixels, ~, bounds, labels ] = makeSuperpixelIndexUnique( data.superpixels );
    [ colours, centres, ~ ] = getSuperpixelStats( data.frames(1:nframe-1), superpixels, double(labels) );%
    valLAB = [];
    for index = 1:nframe-1
        valLAB = [valLAB;data.superpixels{index}.Sup1, data.superpixels{index}.Sup2, data.superpixels{index}.Sup3];     
    end
    
    k =1:6:nframe-1;
    k(end) = [];
    global_saliency_track = zeros(height,width);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%computing global and local location cues %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:size(k,2)
        all_flowmagnitude = zeros(height,width);
        if i > 1
            for index = k(i):k(i)+5
                flowgradient = getFlowGradient( data.flow{index} );
                flowmagnitude = getMagnitude( flowgradient );
                flowmagnitude = (0.5+saliency_trac).*reshape(flowmagnitude(:),height,width);
                all_flowmagnitude = max(all_flowmagnitude,flowmagnitude);
            end
        else
            for index = k(i):k(i)+5
                flowgradient = getFlowGradient( data.flow{index} );
                flowmagnitude = getMagnitude( flowgradient );
                flowmagnitude = reshape(flowmagnitude(:),height,width);
                all_flowmagnitude = max(all_flowmagnitude,flowmagnitude);
            end
        end
        
        all_flowmagnitude = imresize(all_flowmagnitude,0.1,'bilinear');
        [h,w] = size(all_flowmagnitude);
        all_flowmagnitudex = all_flowmagnitude(:);
        all_flowmagnitudex(h*w+1)=0;
        all_Label = zeros(h,w);
        all_Label(:) = 1:size(all_flowmagnitude,1)*size(all_flowmagnitude,2);
        all_Labelx = zeros(h+2,w+2);
        all_Labelx(2:end-1,2:end-1) = all_Label;
        all_Labelx(1,:)=h*w+1;
        all_Labelx(end,:)=h*w+1;
        all_Labelx(:,1)=h*w+1;
        all_Labelx(:,end)=h*w+1;
        [ConSPix,~]= find_connect_superpixel(all_Labelx, h*w+1, h+2 ,w+2 );             
        ConSPix = ConSPix + eye(size(ConSPix,1));
        all_fDistM = squareform(pdist(all_flowmagnitudex(:)));  
        bdIds = GetBndPatchIds(all_Label,1);        
        clipVal = EstimateDynamicParas(ConSPix,all_fDistM);
        geoDist = GeodesicSaliency(ConSPix, double(bdIds), all_fDistM, clipVal,true,[]);
        geoDist = geoDist(1:end-1);
        saliency_trac = reshape(geoDist,h,w);
        saliency_trac = imresize(saliency_trac,[height,width],'bilinear');
        global_saliency_track = max(global_saliency_track,saliency_trac);       
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%computing saliency via intra-frame graph %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    if( options.vocal )
          disp( 'compute saliency via intra-frame graph:');
    end
    all_sal = cell(1,nframe-1);
    for index = 1:nframe-1
        if( options.vocal )
                fprintf( 'Processing frame: %i of %i... \n', ...
                    index, nframe-1);
        end
        FGR = [];
        frame = data.frames{index};        
        frameName = data.names{index};    
        nLabel = double(max(data.superpixels{index}.Label(:)));
        Label = data.superpixels{index}.Label; 
        G = edge_detect(imfilter(uint8(frame),fspecial('average',3),'same','replicate'));
        flowgradient = getFlowGradient( data.flow{index} );
        flowmagnitude = getMagnitude( flowgradient );
        gradBoundary = 1 - exp( -flowmagnitude); 
        flowmagnitude = G.*( gradBoundary +0.1);
        flowmagnitude = reshape(flowmagnitude(:),height,width);
        for  i = 1:nLabel
             flowmagnitude_R = flowmagnitude(Label==i);
             [flowmagnitude_R,~] = sort(flowmagnitude_R, 'descend');
             FGR(i)=mean(flowmagnitude_R(1:10));
             flowmagnitude(Label==i) = FGR(i);
        end

        [ConSPix,~]= find_connect_superpixel( Label, nLabel, height ,width );             
        ConSPix = ConSPix + eye(nLabel);
        FGRM = squareform(pdist(FGR'));
        bdIds = GetBndPatchIds(Label,1);        
        clipVal = EstimateDynamicParas(ConSPix,FGRM);
        geoDist = GeodesicSaliency(ConSPix, double(bdIds), FGRM, clipVal,true,[]);
        geo_sal = geoDist(data.superpixels{index}.Label);
        all_sal{index}=geo_sal.*(global_saliency_track+0.3);
        all_sal{index}=all_sal{index}/max(all_sal{index}(:));
        
        imwrite(all_sal{index}, [options.outfolder '\intra-frame_saliency\' frameName  '.bmp']);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%computing saliency via inter-frame graph %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if( options.vocal )
          disp( 'compute saliency via inter-frame graph:');
    end
    all_geoDist = cell(1,nframe-1);
    for index = 1:nframe-2
        if( options.vocal )
                fprintf( 'Processing frame: %i of %i... \n', ...
                    index, nframe-1);
        end
        nLabel = double(max(data.superpixels{index}.Label(:)));
        
        colDistM = squareform(pdist(valLAB( bounds(index):bounds(index+2)-1,:)));
        Conedge = [];   
        Label_1 = data.superpixels{index}.Label;
        [~,conedge]= find_connect_superpixel( Label_1, max(Label_1(:)), height ,width ); 
        Conedge = [Conedge;conedge];
        
        [x,y] = meshgrid(1:bounds(index+1)-bounds(index),1:bounds(index+2)-bounds(index+1));
        conedge = [x(:),y(:)+bounds(index+1)-bounds(index)];
        connect = sum((centres(conedge(:,1)+bounds(index)-1,:) - centres(conedge(:,2)+bounds(index)-1,:)).^2,2 );
        cross_po_dis = conedge(connect<800,:);       
        Conedge = [Conedge;cross_po_dis];
        
        Label_2 = data.superpixels{index+1}.Label;
        [~,conedge]= find_connect_superpixel( Label_2, max(Label_2(:)), height ,width ); 
        Conedge = [Conedge;conedge + bounds(index+1)-bounds(index)];
        ConSPix=sparse([Conedge(:,1);Conedge(:,2)],[Conedge(:,2);Conedge(:,1)], ...
         [ones(size(Conedge(:,1)));ones(size(Conedge(:,1)))],bounds(index+2)-bounds(index),bounds(index+2)-bounds(index));
        ConSPix = full(ConSPix);
        ConSPix = ConSPix +eye(size(ConSPix));
        
        firstmap = all_sal{index}>mean(all_sal{index}(:));
        str = strel('disk',1);  firstmap = imdilate(firstmap,str);
        fd = int32(firstmap).*data.superpixels{index}.Label;
        fd = unique(fd(:));
        fd(fd==0) = [];
        bd = setdiff(unique(data.superpixels{index}.Label(:)),fd);
        
        bdIds = bd;   
        
        secondmap = all_sal{index+1}>mean(all_sal{index+1}(:));
        secondmap = ~((~secondmap).*(~firstmap));
        str = strel('disk',1);  secondmap = imdilate(secondmap,str);
        fd = int32(secondmap).*data.superpixels{index+1}.Label;
        fd = unique(fd(:));
        fd(fd==0) = [];
        bd = setdiff(unique(data.superpixels{index+1}.Label(:)),fd);
        bdIds = [bdIds;bd+bounds(index+1)-bounds(index)]; 
        
        clipVal = EstimateDynamicParas(ConSPix,colDistM);
        geoDist = GeodesicSaliency(ConSPix, double(bdIds), colDistM, clipVal, false,[]);
        geoDist_1 = geoDist(1:bounds(index+1)-bounds(index));
        geoDist_2 = geoDist(bounds(index+1)-bounds(index)+1:end);
        
        tmp = sort(geoDist_1, 'descend');
        pos = round(options.topRate * length(tmp));
        maxVal = tmp(pos);
        geoDist_1 = geoDist_1 / maxVal; 
        geoDist_1(geoDist_1 > 1) = 1;
        
        tmp = sort(geoDist_2, 'descend');
        pos = round(options.topRate * length(tmp));
        maxVal = tmp(pos);
        geoDist_2 = geoDist_2 / maxVal; 
        geoDist_2(geoDist_2 > 1) = 1;
        
        all_geoDist{index} = geoDist_1;
        all_geoDist{index+1} = geoDist_2;
        geo_sal = geoDist_1(data.superpixels{index}.Label);
        

        all_sal{index} = geo_sal*0.5+all_sal{index}*0.5;
        all_sal{index} = all_sal{index}./max( all_sal{index}(:));

        L{1} = uint32(data.superpixels{index}.Label);
        S{1} = repmat(all_sal{index},[1 3]);
        [ R, ~, ~ ] = getSuperpixelStats(S(1:1),L, nLabel );
        R = double(R(:,1));
        sR = sort(R);
        t = sum(sR(end-9:end))/10;
        R = (R-min(R))/(t-min(R));
        R(R>1)=1;
        all_geoDist{index} = R';
     
        geo_sal = geoDist_2(data.superpixels{index+1}.Label);
        
        all_sal{index+1} = geo_sal*0.5+all_sal{index+1}*0.5;
        all_sal{index+1} = all_sal{index+1}./max( all_sal{index+1}(:)); 

        nLabel = double(max(data.superpixels{index+1}.Label(:)));
        L{1} = uint32(data.superpixels{index+1}.Label);
        S{1} = repmat(all_sal{index+1},[1 3]);
        [ R, ~, ~ ] = getSuperpixelStats(S(1:1),L, nLabel );
        R = double(R(:,1));
        sR = sort(R);
        t = sum(sR(end-9:end))/10;
        R = (R-min(R))/(t-min(R));
        R(R>1)=1;
        all_geoDist{index+1} = R';  

    end
          
    RegionSal = [];
    for index = 1:nframe-1
        nLabel = double(max(data.superpixels{index}.Label(:)));
        all_sal{index} = all_sal{index}.*(global_saliency_track+0.1);
        all_sal{index} = all_sal{index}/max(all_sal{index}(:));        
        
        sal = reshape( all_sal{index},height*width,1);
        L{1} = uint32(data.superpixels{index}.Label);
        S{1} = repmat(sal,[1 3]);
        [ R, ~, ~ ] = getSuperpixelStats(S(1:1),L, nLabel );
        R = double(R(:,1));
        sR = sort(R);
        t = sum(sR(end-9:end))/10;
        R = (R-min(R))/(t-min(R));
        R(R>1)=1;
        all_geoDist{index} = R';
        RegionSal = [RegionSal;all_geoDist{index}(:)];
        all_sal{index} = double(R(data.superpixels{index}.Label));
        imwrite(all_sal{index}, [options.outfolder '\inter-frame_saliency\' data.names{index} '.bmp']);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Spatio-temporal consistance optimization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%you can uncomment this part for computation efficiency %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if( options.vocal )
          disp( 'spatio-temporal consistance optimization');
    end
    Conedge = [];      
    for index = 1:nframe-1
        Label = data.superpixels{index}.Label;
        [~,conedge]= find_connect_superpixel( Label, max(Label(:)), height ,width );      
        Conedge = [Conedge;conedge + bounds(index)-1];
    end
    intralength = size(Conedge,1);
    for index = 1:nframe-2
        [x,y] = meshgrid(1:bounds(index+1)-bounds(index),1:bounds(index+2)-bounds(index+1));
        conedge = [x(:)+bounds(index)-1,y(:)+bounds(index+1)-1];
        connect = sum((centres(conedge(:,1),:) - centres(conedge(:,2),:)).^2,2 );
        Conedge = [Conedge;conedge(connect<800,:)];
    end
    valDistances=sqrt(sum((valLAB(Conedge(:,1),:)-valLAB(Conedge(:,2),:)).^2,2));
    valDistances(intralength+1:end)=valDistances(intralength+1:end)/5;
    valDistances=normalize(valDistances);
    weights=exp(-options.valScale*valDistances)+ 1e-5;
    weights=sparse([Conedge(:,1);Conedge(:,2)],[Conedge(:,2);Conedge(:,1)], ...
    [weights;weights],labels,labels);
    E = sparse(1:labels,1:labels,ones(labels,1)); iD = sparse(1:labels,1:labels,1./sum(weights));
    P = iD*weights;
    RegionSal = (E-P+10*options.alpha*E)\RegionSal;
    for index = 1:nframe-1
        R = RegionSal(bounds(index):bounds(index+1)-1);
        sR = sort(R);
        t = sum(sR(end-9:end))/10;
        R = (R-min(R))/(t-min(R));
        R(R>1)=1;
        all_geoDist{index} = R';
        all_sal{index} = 0.6*double(R(data.superpixels{index}.Label))+0.4*all_sal{index};
        imwrite(all_sal{index}, [options.outfolder '\final_saliency\' data.names{index}  '.bmp']);
    end

