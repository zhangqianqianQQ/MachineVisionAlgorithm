function dbBrowser
% Browse database annotations and detection results.
%
% Complementary to vbbPlayer. Cannot display video efficiently (use
% vbbPlayer for this), but can display detection/evaluation results. Set
% internal parameters appropriately (such as results to display, etc.)
%
% Uses two functions in vbb: 'vbbLoad' to load annotation associated
% with each video and 'frameAnn' to get the single frame annotation
% for a given frame. Uses 'bbGt('evalRes')' to evaluate results.
%
% To draw annotation to entire video (assuming have access to video), use
% the 'drawToVideo' function in vbb:
%  vName='set00/V000'; tName='set00-V000-ann';
%  A = vbb( 'vbbLoad', [dbInfo '/annotations/' vName] );
%  vbb('drawToVideo',A,[dbInfo '/videos/' vName],tName);
%
% USAGE
%  dbBrowser
%
% INPUTS
%
% OUTPUTS
%
% EXAMPLE
%  dbBrowser
%
% See also DBINFO, VBB, EVALFRAME, VBBPLAYER, VBB>FRAMEANN
%
% Caltech Pedestrian Dataset     Version 3.2.1
% Copyright 2014 Piotr Dollar.  [pdollar-at-gmail.com]
% Licensed under the Simplified BSD License [see external/bsd.txt]

% parameters for dataset and display
[pth,sIds,vIds,skip] = dbInfo;
rPth=[pth '/res/ChnFtrs'];    % directory containing results
thr=[];                       % detection threshold
resize={100/100, 0, .41};     % controls resizing of detected bbs

% global variables and initialization
[hFig,hAx,hCns,hCbs,cbOn] = deal([]);
[A,sr,nSet,s,nVid,v,nImg,img] = deal([]);
nSet=length(sIds); if(nSet==0); error('data not found'); end
makeLayout(); setStrs(hCns(1),nSet,sIds,'set',2); selectSet();
set(hFig, 'Visible', 'on');
%#ok<*INUSL,*INUSD>

  function makeLayout()
    % figure / axis layout
    posS='Position'; set(0,'Units','Pixels'); ss=get(0,'ScreenSize');
    pos=[(ss(3)-780)/2 (ss(4)-580)/2 810 580];
    hFig=figure( 'NumberTitle','off', 'Toolbar','auto', ...
      'MenuBar','none', 'Color','k',posS,pos,'Visible', 'off',...
      'Name','Caltech Pedestrian Dataset Browser','DeleteFcn',@exitProg,...
      'PaperPositionMode', 'auto', 'PaperOrientation', 'Landscape' );
    
    % axis / randomImg button / exportImg button
    cs=[120 230 340 450 600 680]; row=35;
    hAx=axes('Units','Pixels','Parent',hFig,posS,[80 80 640 480]);
    uicontrol(hFig,posS,[cs(5) row 70 20],'String','Random',...
      'callback',@randomImg);
    uicontrol(hFig,posS,[cs(6) row 70 20],'String','Export',...
      'callback',@exportImg);
    
    % set/video/image control and left/right arrows
    cbs={@selectSet,@selectVid,@selectImg}; hCns=[0 0 0];
    for i1=1:3
      hCns(i1)=uicontrol(hFig,'Style','popupmenu','String','00',...
        'Value',1, posS,[cs(i1) row 70 20], 'callback',cbs{i1} );
      uicontrol(hFig, posS,[cs(i1)-15 row-1 15 21], 'String','<', ...
        'callback',{@btnStep,hCns(i1),-1} );
      uicontrol(hFig, posS,[cs(i1)+70 row-1 15 21], 'String','>', ...
        'callback',{@btnStep,hCns(i1),+1} );
    end
    
    % check box controls
    cbOn=[1 0 0]; cbEn={'on','off','off'};
    strs={'ground truth','results','evaluation'};
    for i1=1:3
      hCbs(i1) = uicontrol( hFig, 'Style','checkbox', 'callback', ...
        {@cbFn,i1}, posS,[cs(4) row+15*(i1-2) 130 15], ...
        'String',['Show ' strs{i1}], 'Value', cbOn(i1),'Enable',cbEn{i1});
    end
    
    function exitProg( h, evnt )
      if(isstruct(sr)), sr=sr.close(); end
    end
  end

  function setStrs( h, n, vs, str, nDigit )
    strs=cell(1,n);
    for i=1:n; strs{i}=['  ' str int2str2(vs(i),nDigit)]; end
    set(h,'String',strs,'Value',1);
  end

  function selectSet( h, evnt, select )
    s=get(hCns(1),'Value'); nVid=length(vIds{s});
    setStrs(hCns(2), nVid, vIds{s}, 'V', 3);
    if(nargin<3||select); selectVid(); end
  end

  function selectVid( h, evnt, select )
    % open appropriate vbb and seq files
    v=get(hCns(2),'Value'); if(isstruct(sr)), sr=sr.close(); end
    nmVbb = sprintf('%s/annotations/set%02i/V%03i',pth,sIds(s),vIds{s}(v));
    nmSeq = sprintf('%s/videos/set%02i/V%03i',pth,sIds(s),vIds{s}(v));
    A = vbb( 'vbbLoad', nmVbb ); sr = seqIo( nmSeq, 'r' );
    nImg = floor(A.nFrame/skip);
    setStrs(hCns(3), nImg, (1:nImg)*skip-1, 'I', 5 );
    if(nargin<3||select); selectImg(); end;
  end

  function selectImg( h, evnt )
    img = get(hCns(3),'Value')*skip-1;
    plotImg( s, v, img );
  end

  function randomImg( h, evnt, s1, v1, img1 )
    if(nargin<3||isempty(s1)||s1>nSet),
      s1=randint2(1,1,[1 nSet]); end
    set(hCns(1),'Value',s1); selectSet([],[],0)
    if(nargin<4||isempty(v1)||v1>nVid),
      v1=randint2(1,1,[1 nVid]); end
    set(hCns(2),'Value',v1); selectVid([],[],0)
    if(nargin<5||isempty(img1)||img1>nImg),
      img1=randint2(1,1,[1 nImg]); end
    set(hCns(3),'Value',img1); selectImg();
  end

  function exportImg(h, evnt, imName)
    if( nargin<3 || isempty(imName) )
      imName = sprintf('%s/set%02i-V%03i-I%05i-R%i%i%i.png',...
        pth,sIds(s),vIds{s}(v),img,cbOn(1),cbOn(2),cbOn(3));
      [imName,dirName] = uiputfile('*.png','Save Image',imName);
      if(~imName), return; end; imName = [dirName imName];
    end
    I=getframe(hAx); imwrite(I.cdata, imName);
  end

  function btnStep(h, evnt, hCn, step)
    val = get(hCn, 'Value') + step;
    if( val>0 && val<=length(get(hCn,'String')) )
      set(hCn, 'value', val);
      fh=get(hCn, 'callback'); fh(hCn);
    end
  end

  function cbFn(h, evnt, which)
    cbOn(which)=~cbOn(which); selectImg();
  end

  function plotImg( s, v, img )
    set(hFig,'CurrentAxes',hAx);
    sr.seek( img ); I=sr.getframe(); imshow(I);
    
    % adjust checkBoxes appropriately (cbOn: [gt,rs,ev])
    fRes=sprintf('%s/set%02d/V%03d/I%05d.txt',rPth,sIds(s),vIds{s}(v),img);
    if(~exist(fRes,'file')), fRes=[fRes(1:end-11) '.txt']; end
    if(~exist(fRes,'file')); cbOn(2:3)=0; en='off'; else en='on'; end;
    for i=2:3, set(hCbs(i),'Value',cbOn(i),'Enable',en); end
    
    % load annotation and results
    lbls = {'person','people','person?'};
    test = @(lbl,pos,posv) any(strcmp(lbl,{'person'}));
    [gtBs,vsBs,lbls] = vbb('frameAnn', A, img+1, lbls, test);
    if(any(cbOn(2:3))), dtBs=load(fRes,'-ascii'); else dtBs=[]; end;
    if(size(dtBs,2)==6), dtBs=dtBs(dtBs(:,1)==img+1,2:6); end
    if(isempty(dtBs)), dtBs=zeros(0,5); end
    
    % manipulate dtBs appropriately
    if(~isempty(thr)), dtBs=dtBs(dtBs(:,5)>thr,:); end
    if(~isempty(resize)), dtBs=bbApply('resize',dtBs,resize{:}); end
    
    % display bbs with or w/o color coding based on output of evalRes
    hold on; vsBs=vsBs(sum(abs(vsBs),2)>0,:);
    if( cbOn(3) )
      [gt,dt]=bbGt('evalRes',gtBs,dtBs,.5); cs='krg';
      if(cbOn(1)), ng=size(gt,1);
        for i=1:ng, bbApply('draw',gt(i,1:4),cs(gt(i,5)+2),3,'-'); end
      end
      if(cbOn(2)), nd=size(dt,1);
        for i=1:nd, bbApply('draw',dt(i,1:5),cs(dt(i,6)+2),3,'--'); end
      end
    else
      if(cbOn(1)), bbApply('draw',gtBs(:,1:4),'g',3,'-'); end
      if(cbOn(1)), bbApply('draw',vsBs(:,1:4),'y',3,':'); end
      if(cbOn(2)), bbApply('draw',dtBs(:,1:5),'g',3,'--'); end
    end
    
    % display text labels for objects
    tp={ 'color','w', 'FontSize',10, 'FontWeight','bold' };
    if(cbOn(1) && ~isempty(lbls))
      for i=1:size(gtBs,1), text(gtBs(i,1),gtBs(i,2)-10,lbls{i},tp{:}); end
    end; hold off;
  end

end
