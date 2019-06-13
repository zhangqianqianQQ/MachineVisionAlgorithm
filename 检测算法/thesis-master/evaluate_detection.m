% Evaluate detection performance, based on VOCevaldet
init;

% load test set
fid = fopen([VOC07PATH 'ImageSets/Main/test.txt']);
gtids = textscan(fid,'%s');
gtids = gtids{1};
anno_dir = [VOC07PATH 'Annotations/'];
draw = 1;

aps = zeros(20, 1);
for cls=1:20
    disp(['Class ' num2str(cls) ' ' VOCCLASS{cls}]);
    
    % load ground truth objects
    disp(['Load ground truth objects']);
    npos=0;
    gt(length(gtids))=struct('BB',[],'diff',[],'det',[]);
    for i=1:length(gtids)

        % read annotation
        rec=PASreadrecord([anno_dir gtids{i} '.xml']);

        % extract objects of class
        clsinds=find(strcmp({rec.objects(:).class}, VOCCLASS{cls}));
        gt(i).BB=cat(1,rec.objects(clsinds).bbox)';
        gt(i).diff=[rec.objects(clsinds).difficult];
        gt(i).det=false(length(clsinds),1);
        npos=npos+sum(~gt(i).diff);
    end
    
    % load results
    disp(['Load results']);
    fid = fopen(['results/' VOCCLASS{cls} '.txt']);
    %[ids,confidence,b1,b2,b3,b4]=textscan(fid,'%s %f %f %f %f %f');
    results = textscan(fid,'%s %f %f %f %f %f');
    ids = results{1};
    confidence = results{2};
    b1 = results{3};
    b2 = results{4};
    b3 = results{5};
    b4 = results{6};
    BB=[b1 b2 b3 b4]';

    % sort detections by decreasing confidence
    [sc,si]=sort(-confidence);
    ids=ids(si);
    BB=BB(:,si);

    % assign detections to ground truth objects
    nd=length(confidence);
    tp=zeros(nd,1);
    fp=zeros(nd,1);
    tic;
    for d=1:nd
        % display progress
        if toc>1
            fprintf('%s: pr: compute: %d/%d\n',cls,d,nd);
            drawnow;
            tic;
        end

        % find ground truth image
        i=find(strcmp(gtids, ids{d}));
        if isempty(i)
            error('unrecognized image "%s"',ids{d});
        elseif length(i)>1
            error('multiple image "%s"',ids{d});
        end

        % assign detection to ground truth object if any
        bb=BB(:,d);
        ovmax=-inf;
        for j=1:size(gt(i).BB,2)
            bbgt=gt(i).BB(:,j);
            bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
            iw=bi(3)-bi(1)+1;
            ih=bi(4)-bi(2)+1;
            if iw>0 && ih>0                
                % compute overlap as area of intersection / area of union
                ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
                   (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
                   iw*ih;
                ov=iw*ih/ua;
                if ov>ovmax
                    ovmax=ov;
                    jmax=j;
                end
            end
        end
        % assign detection as true positive/don't care/false positive
        if ovmax>=0.5
            if ~gt(i).diff(jmax)
                if ~gt(i).det(jmax)
                    tp(d)=1;            % true positive
            gt(i).det(jmax)=true;
                else
                    fp(d)=1;            % false positive (multiple detection)
                end
            end
        else
            fp(d)=1;                    % false positive
        end
    end

    % compute precision/recall
    fp=cumsum(fp);
    tp=cumsum(tp);
    rec=tp/npos;
    prec=tp./(fp+tp);

    % compute average precision

    ap=0;
    for t=0:0.1:1
        p=max(prec(rec>=t));
        if isempty(p)
            p=0;
        end
        ap=ap+p/11;
    end

    draw = 0;
    if draw
        % plot precision/recall
        plot(rec,prec,'-');
        grid;
        xlabel 'recall'
        ylabel 'precision'
        title(sprintf('class: %s, subset: %s, AP = %.3f',cls,'test',ap));
    end
    
    aps(cls) = ap
end