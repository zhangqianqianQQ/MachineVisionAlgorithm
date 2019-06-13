function skeletonLabeler( objTypes, vidNm, annNm )
% Video bound box (vbb) Labeler.
%
% USAGE
%  vbbLabeler( [objTypes], [vidNm], [annNm] )
%
% INPUTS
%  objTypes - [{'object'}] list of object types to annotate
%  imgDir   - [] initial video to load
%  resDir   - [] initial annotation to load
%

    % defaults
    if(nargin<1 || isempty(objTypes)), objTypes={'object'}; end
    if(nargin<2 || isempty(vidNm)), vidNm=''; end
    if(nargin<3 || isempty(annNm)), annNm=''; end
    
    % handles to gui objects / other globals
    [hFig, pSet, pCp, pMp] = deal([]);
    [curInd,curSeg, setApi,dispApi] = deal([]);   
    
    makeLayout();
    setApi = setMakeApi(); % set the parameters
    dispApi  = dispMakeApi(); % display & update
    setApi.closeVid();
    set(hFig,'Visible','on');
    drawnow;
    
    
    % optionally load default data
    if(~isempty(vidNm)), setApi.openVid(vidNm); end
    if(~isempty(annNm)), setApi.openAnn(annNm); end
    
    function makeLayout()
        % hFig: main figure
        set(0,'Units','pixels'); ss=get(0,'ScreenSize');
        if( ss(3)<800 || ss(4)<600 ), error('screen too small'); end
        pos = [(ss(3)-580-400)/2 (ss(4)-650-200)/2 580+400 680+200];
        hFig = figure( 'Name','Labeler', 'NumberTitle','off', ...
          'Toolbar','auto', 'MenuBar','none', 'Resize','on', ...
          'Color','k', 'Visible','off', 'DeleteFcn',@exitLb, 'Position',pos, ...
          'keyPressFcn',@keyPress );

        % pSet: top panel containing setting
        pSet.h=uipanel('Units','pixels', 'BackgroundColor',[.1 .1 .1],'BorderType','none','Position', [8 645+200 580 30], 'Parent',hFig); 
        pSet.hOpen   = uicontrol(pSet.h,'BackgroundColor',[.7 .7 .7],'FontSize', 10, 'Position', [5  3 90 20],'String','Open');
        pSet.nImgLbl = uicontrol(pSet.h,'Style','text','FontSize',8,'BackgroundColor',[.1 .1 .1],'ForegroundColor','w','Position',[185 0 50 20],'HorizontalAlignment','Left', 'String', '/');
        pSet.IndLbl  = uicontrol(pSet.h,'Style','edit','FontSize',8,'BackgroundColor',[.1 .1 .1],'ForegroundColor','w','Position',[135 3 50 20],'HorizontalAlignment','Right');
        pSet.hImageName = uicontrol(pSet.h,'Style','text','FontSize',8,'BackgroundColor',[.1 .1 .1],'ForegroundColor','w','Position',[240 0 90 20],'HorizontalAlignment','Left');
        
        % pCp: control pannel
        pCp.h=uipanel('Units','pixels', 'BackgroundColor',[.1 .1 .1],'BorderType','none','Position', [8 613+200 580 30],'Parent',hFig); 
        pCp.hBtPrvImg    = uicontrol(pCp.h,'BackgroundColor',[.7 .7 .7],'FontSize', 10, 'Position', [5  3 90 25],'String','PreviousImage');
        pCp.hBtShowImg   = uicontrol(pCp.h,'BackgroundColor',[.7 .7 .7],'FontSize', 10, 'Position', [100  3 90 25],'String','ShowImage');
        pCp.hBtShowMask  = uicontrol(pCp.h,'BackgroundColor',[.7 .7 .7],'FontSize', 10, 'Position', [195 3 80 25],'String','ShowMask');
        pCp.hBtShowSkel  = uicontrol(pCp.h,'BackgroundColor',[.7 .7 .7],'FontSize', 10, 'Position', [280 3 90 25],'String','ShowSkeleton');
        pCp.hBtNextImg   = uicontrol(pCp.h,'BackgroundColor',[.7 .7 .7],'FontSize', 10, 'Position', [375 3 80 25],'String','NextImage');
        pCp.hBtAnnSave   = uicontrol(pCp.h,'BackgroundColor',[.7 .7 .7],'FontSize', 10, 'Position', [460 3 95 25],'String','AnnotationSave');
        
        % pMp main panel
        pMp.h=uipanel('Units','pixels', 'BackgroundColor',[.1 .1 .1],'BorderType','none','Position', [8 8 580+400 604+200],'Parent',hFig); 
        pMp.hAx=axes('Units','pixels', 'Position', [5 40 560+400 560+200], 'Parent',pMp.h, 'Color', [1 1 1]);
        pMp.hBtPrvObj  = uicontrol(pMp.h,'BackgroundColor',[.7 .7 .7],'FontSize', 10, 'Position', [5  3 90 25],'String','PreviousObject');
        pMp.hBtOriMask = uicontrol(pMp.h,'BackgroundColor',[.7 .7 .7],'FontSize', 10, 'Position',[100  3 90 25],'String','OriginalMask');
        pMp.hBtExdDisc = uicontrol(pMp.h,'BackgroundColor',[.7 .7 .7],'FontSize', 10, 'Position',[195 3 80 25],'String','ExtendDisc');
        pMp.hBtExdPoly = uicontrol(pMp.h,'BackgroundColor',[.7 .7 .7],'FontSize', 10, 'Position',[280 3 80 25],'String','ExtendPoly');
        pMp.hBtAnn     = uicontrol(pMp.h,'BackgroundColor',[.7 .7 .7],'FontSize', 10, 'Position',[365 3 80 25],'String','Annotation');
        pMp.hBtNxtObj  = uicontrol(pMp.h,'BackgroundColor',[.7 .7 .7],'FontSize', 10, 'Position',[450 3 80 25],'String','NextObject');
        
        
        function exitLb( h, e ) %#ok<INUSD>
        	setApi.closeVid();
        end

        function keyPress( h, evnt ) %#ok<INUSL>
            char=int8(evnt.Character); if(isempty(char)), char=0; end;
            if( char==28 ), dispApi.setPlay(-inf); end
            if( char==29 ), dispApi.setPlay(+inf); end
            if( char==31 ), dispApi.setPlay(0); end
        end
    end

    function api = setMakeApi()
        % variables
        [imgPath, segPath, imgLst] = deal([]);
        [imgROI, seg, segIdx, skeGt,skeInst, extIdx] = deal([]);
        [segMask, extMask, skelFlag, annFlag] = deal([]);
        [h, w] = deal([]);
        
        imgPath     = [VOC2011Path '\VOCdevkit\VOC2011\JPEGImages';
        segPath     = [VOC2011Path '\VOCdevkit\VOC2011\SegmentationObject';
        imgLstPath  = [VOC2011Path '\VOCdevkit\VOC2011\ImageSets\Segmentation\train.txt';
        f=fopen(imgLstPath); imgLst=textscan(f,'%s %*s'); imgLst=imgLst{1}; fclose(f);
        set(pSet.nImgLbl, 'String', ['\' num2str(length(imgLst))]);

        % callbacks
        set(pSet.hOpen, 'callback', @(h,e) imgOpen());
        set(pCp.hBtNextImg, 'callback', @(h,e) nextImg());
        set(pCp.hBtPrvImg, 'callback', @(h,e) previousImg());
        set(pCp.hBtShowImg, 'callback', @(h,e) showImg());
        set(pCp.hBtShowMask, 'callback', @(h,e) showMask());
        set(pCp.hBtShowSkel, 'callback', @(h,e) showSkel());
        set(pCp.hBtAnnSave, 'callback', @(h,e) annSave());
        
        set(pMp.hBtPrvObj, 'callback', @(h,e) previousObj());
        set(pMp.hBtNxtObj, 'callback', @(h,e) nextObj());
        set(pMp.hBtOriMask, 'callback', @(h,e) oriMask());
        set(pMp.hBtExdDisc, 'callback', @(h,e) exdMaskDisc());
        set(pMp.hBtExdPoly, 'callback', @(h,e) exdMaskPoly());
        set(pMp.hBtAnn, 'callback', @(h,e) annotation());
        
        % create api
        api=struct('imgSet',@imgSet, ...
          'imgOpen',@imgOpen, 'closeVid', @closeVid);

        function imgShow()
            curSeg = 0;
            set(pSet.IndLbl, 'String', num2str(curInd));
            set(pSet.hImageName, 'String', [imgLst{curInd} '.jpg']);
            set(pCp.hBtShowSkel, 'Enable','off');
            set(pCp.hBtAnnSave, 'Enable','off');
            
            cla(pMp.hAx); set(pMp.hAx,'XTick',[],'YTick',[]);
            set( hFig, 'CurrentAxes', pMp.hAx );
            imgROI = imread([imgPath '\' imgLst{curInd} '.jpg']);
            [h,w,~] =size(imgROI);
            set( pMp.hAx, 'Position', [5 40 980 804]);
            img = uint8(50*ones(804,980,3)); 
            img(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w,1) = imgROI(:,:,1);
            img(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w,2) = imgROI(:,:,2);
            img(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w,3) = imgROI(:,:,3);
            image(img); axis off;
            seg = imread([segPath '\' imgLst{curInd} '.png']);
            segIdx = unique(seg);
            skeGt = false(h,w);
            extMask = cell(50,1);
            skeInst = cell(length(segIdx)-2,1);
            skelFlag= false(length(segIdx)-2,1);
            segMask = false(804,980);
        end
        
        function segShow(segmask)
            tmp = uint8(50*ones(804,980,3)); 
            tmp(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w,1) = imgROI(:,:,1);
            tmp(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w,2) = imgROI(:,:,2);
            tmp(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w,3) = imgROI(:,:,3);
            tmp(:,:,1) = tmp(:,:,1).*uint8(~segmask);
            tmp(:,:,2) = tmp(:,:,2).*uint8(~segmask);
            tmp(:,:,3) = tmp(:,:,3).*uint8(~segmask);
            image(tmp);
            axis off;
        end
                
        function imgOpen()
            num = get(pSet.IndLbl, 'String');
            if(isempty(num))
                curInd = 1;
            else
                curInd = uint16(str2num(num));
            end
            imgShow();
        end
        
        function nextImg()
            if(curInd < 1112)
                curInd = curInd+1;
            end
            imgShow();
        end
        
        function previousImg()
            if(curInd>1)
                curInd = curInd-1;
            end
            imgShow();
        end
        
        function showImg()
            imgROI = imread([imgPath '\' imgLst{curInd} '.jpg']);
            [h,w,~] =size(imgROI);
            set( pMp.hAx, 'Position', [5 40 980 804]);
            img = uint8(50*ones(804,980,3));  
            img(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w,1) = imgROI(:,:,1);
            img(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w,2) = imgROI(:,:,2);
            img(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w,3) = imgROI(:,:,3);
            image(img); axis off;
        end
        
        function showMask()
            segMaskROI = seg == segIdx(length(segIdx));
            segMask(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w) = segMaskROI;
            segShow(segMask);
        end
        
        function showSkel()
            for i= 1:length(segIdx)-2
                skeGt = skeGt|skeInst{i};
            end

            tmp = uint8(50*ones(804,980,3)); 
            tmp(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w,1) = imgROI(:,:,1);
            tmp(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w,2) = imgROI(:,:,2);
            tmp(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w,3) = imgROI(:,:,3);
            tmpMask = false(804,980);
            tmpMask(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w)= seg>0;
            tmpGt = false(804,980);
            tmpGt(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w) = skeGt;
            tmpMask = uint8(~tmpMask);
            tmpMask(tmpGt) = 255;

            tmp(:,:,1) = tmp(:,:,1).*tmpMask;
            tmp(:,:,2) = tmp(:,:,2).*tmpMask;
            tmp(:,:,3) = tmp(:,:,3).*tmpMask;
            image(tmp);axis off;
            
            set(pCp.hBtAnnSave, 'Enable','on');
        end
        
        function annSave()
            sym = skeGt;
            save(['skeGt/' imgLst{curInd} '.mat'], 'sym');
            msgbox('save sucessed.');
        end
        
        function previousObj()
            if(curSeg>1)
                curSeg = curSeg-1;
            else
               curSeg = 1;
            end
            annFlag = true;
            segMaskROI = seg == segIdx(curSeg+1);
            segMask(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w) = segMaskROI;
            segShow(segMask);
            extIdx = 1;
        end
        
        function nextObj()
            if(curSeg<length(segIdx)-2)
                curSeg = curSeg+1;
            end
            annFlag = true;
            segMaskROI = seg == segIdx(curSeg+1);
            segMask(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w) = segMaskROI;
            segShow(segMask);
            extIdx = 1;
        end
        
        function oriMask()
            extIdx = 1;
            annFlag = true;
            segShow(segMask);
        end
        
        function exdMaskDisc()
            if curSeg >0 
                [x,y] = ginput(2);
                if(length(x)<2) 
                    return;
                end
               
                tmpMask = false(size(segMask));
                % extend by disc
                dot1 = [x(1) y(1)];
                dot2 = [x(2) y(2)];
                tmpMask = extendDisc(tmpMask, dot1, dot2);

                tmpMask = imfill(tmpMask, 'holes');
                
                if extIdx==1
                    extMask{extIdx} = tmpMask;
                else
                    extMask{extIdx} = extMask{extIdx-1}|tmpMask;
                end
                tmpMask = segMask|extMask{extIdx};
                segShow(tmpMask);
                if (extIdx<51)
                    extIdx = extIdx+1;
                end
            end
        end
        
        function exdMaskPoly()
            if curSeg >0 
                [x,y] = ginput(4);
                if(length(x)<2) 
                    return;
                end
                tmpMask = false(size(segMask));
                % extend by polygon
                x = [x(1) x(2) x(3) x(4)];
                y = [y(1) y(2) y(3) y(4)];
                tmpMask = extendPolygon(tmpMask, x, y);
                tmpMask = imfill(tmpMask, 'holes');
                if extIdx==1
                    extMask{extIdx} = tmpMask;
                else
                    extMask{extIdx} = extMask{extIdx-1}|tmpMask;
                end
                tmpMask = segMask|extMask{extIdx};
                segShow(tmpMask);
                if (extIdx<51)
                    extIdx = extIdx+1;
                end
            end
        end

        function annotation()
            if curSeg >0 
                if(extIdx>1)
                    tmpMask = extMask{extIdx-1};
                    tmpMask = segMask|tmpMask;
                else
                    tmpMask = segMask;
                end
                
                try
                    
                    epsilon = 0.8;
                    skel = skel_pruning_bpr(tmpMask, epsilon, 9);
                    skel = skel>0;             
                    
                    tmp = uint8(50*ones(804,980,3)); 
                    tmp(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w,1) = imgROI(:,:,1);
                    tmp(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w,2) = imgROI(:,:,2);
                    tmp(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w,3) = imgROI(:,:,3);
                    
                    if annFlag
                        tmpMask = uint8(~tmpMask);
                    else
                        skel = skel & segMask;
                        tmpMask = uint8(~segMask);
                    end
                    
                    tmpMask(skel) = 255;

                    tmp(:,:,1) = tmp(:,:,1).*tmpMask;
                    tmp(:,:,2) = tmp(:,:,2).*tmpMask;
                    tmp(:,:,3) = tmp(:,:,3).*tmpMask;
                    image(tmp);axis off;
                    annFlag = ~annFlag;

                    skelFlag(curSeg) = true;
                    skeInst{curSeg} = skel(420-floor(h/2):419-floor(h/2)+h,485-floor(w/2):484-floor(w/2)+w);

                    if all(skelFlag==true)
                        set(pCp.hBtShowSkel, 'Enable','on');
                    end
                end
            end
        end
        
        function mask = extendDisc(extMask, dot1, dot2)
            dot1 = double(dot1);
            dot2 = double(dot2);
            mask = extMask;
            x0 = (dot1(1)+dot2(1))/2;
            y0 = (dot1(2)+dot2(2))/2;
            R0 = sqrt((dot1(1)-dot2(1))^2+(dot1(2)-dot2(2))^2)/2;
            dy = dot2(2)-dot1(2);
            dx = dot2(1)-dot1(1);
            theta0 = atan((dot2(2)-dot1(2))/(dot2(1)-dot1(1)));
            if dot2(2)-dot1(2)>=0 && dot2(1)-dot1(1)<0
                theta0 = atan((dot2(2)-dot1(2))/(dot2(1)-dot1(1)))-pi;
            elseif dot2(2)-dot1(2)>=0 && dot2(1)-dot1(1)>0
                theta0 = atan((dot2(2)-dot1(2))/(dot2(1)-dot1(1)));
            elseif dot2(2)-dot1(2)<0 && dot2(1)-dot1(1)<0
                theta0 = atan((dot2(2)-dot1(2))/(dot2(1)-dot1(1)))-pi;
            elseif dot2(2)-dot1(2)<0 && dot2(1)-dot1(1)>0
                theta0 = atan((dot2(2)-dot1(2))/(dot2(1)-dot1(1)));
            elseif dot2(2)-dot1(2)<0 && dot2(1)-dot1(1)==0
                theta0 = -pi/2;
            elseif dot2(2)-dot1(2)>0 && dot2(1)-dot1(1)==0
                theta0 = pi/2;
            end
            
            Theta=linspace(theta0,theta0+pi,1000);
            x = x0+ cos(Theta)*R0;
            y = y0 + sin(Theta)*R0;
            for ii=1:1000
                mask(round(y(ii)),round(x(ii)))=true;
            end
            x = linspace(dot1(1),dot2(1),500);
            y = linspace(dot1(2),dot2(2),500);
            for ii=1:500
                mask(round(y(ii)),round(x(ii)))=true;
            end
            
        end
        
        function mask = extendPolygon(extMask, x, y)
            mask = extMask;
            a = [linspace(x(1),x(2),500) linspace(x(2),x(3),500) linspace(x(3),x(4),500) linspace(x(4),x(1),500)];
            b = [linspace(y(1),y(2),500) linspace(y(2),y(3),500) linspace(y(3),y(4),500) linspace(y(4),y(1),500)];
            for ii=1:2000
                mask(round(b(ii)),round(a(ii)))=true;
            end
        end
        
        
        function closeVid()
%             dispApi.init([]); 
        end
    end

    function api = dispMakeApi()
        api=struct( 'showImage',@showImage, 'imgSet',@imgSet, ...
          'imgOpen',@imgOpen);
      
    end

end




