function vbbLabeler( objTypes, vidNm, annNm )
% Video bound box (vbb) Labeler.
%
% Used to annotated a video (seq file) with (tracked) bounding boxes. An
% online demo describing usage is available. The code below is fairly
% complex and poorly documented. Please do not email me with question about
% how it works (unless you discover a bug).
%
% USAGE
%  vbbLabeler( [objTypes], [vidNm], [annNm] )
%
% INPUTS
%  objTypes - [{'object'}] list of object types to annotate
%  imgDir   - [] initial video to load
%  resDir   - [] initial annotation to load
%
% OUTPUTS
%
% EXAMPLE
%  vbbLabeler
%
% See also vbb, vbbPlayer
%
% Caltech Pedestrian Dataset     Version 3.2.1
% Copyright 2014 Piotr Dollar.  [pdollar-at-gmail.com]
% Licensed under the Simplified BSD License [see external/bsd.txt]

% defaults
if(nargin<1 || isempty(objTypes)), objTypes={'object'}; end
if(nargin<2 || isempty(vidNm)), vidNm=''; end
if(nargin<3 || isempty(annNm)), annNm=''; end

% settable constants
maxSkip   = 250;  % max value for skip
nStep     = 16;   % number of objects to display in lower panel
repLen    = 1;    % number of seconds to replay on left replay
maxCache  = 500;  % max cache length (set as high as memory allows)
fps       = 150;  % initial fps for playback (if 0 uses actual fps)
skip0     = 20;   % initial skip (zoom)
seqPad    = 4;    % amount of padding around object in seq view
siz0      = 20;   % minimum rect width/height
sizLk     = 0;    % if true rects cannot be resized
colType=0; rectCols=uniqueColors(3,8); % color rects according to id
%colType=1; rectCols=uniqueColors(3,3); % color rects according to type

% handles to gui objects / other globals
enStr = {'off','on'};
[hFig, pLf, pRt, pMenu, pObj, pSeq ] = deal([]);
[A,skip,offset,curInd,seqH,objApi,dispApi,filesApi] = deal([]);

% initialize all
makeLayout();
filesApi = filesMakeApi();
objApi   = objMakeApi();
dispApi  = dispMakeApi();
filesApi.closeVid();
set(hFig,'Visible','on');
drawnow;

% optionally load default data
if(~isempty(vidNm)), filesApi.openVid(vidNm); end
if(~isempty(annNm)), filesApi.openAnn(annNm); end

  function makeLayout()
    % properties for gui objects
    bg='BackgroundColor'; fg='ForegroundColor'; ha='HorizontalAlignment';
    units={'Units','pixels'}; st='String'; ps='Position'; fs='FontSize';
    axsPr=[units {'Parent'}]; o4=[1 1 1 1]; clr=[.1 .1 .1];
    pnlPr=[units {bg,clr,'BorderType','none','Parent'}];
    btnPr={bg,[.7 .7 .7],fs,10,ps};
    chbPr={'Style','checkbox',fs,8,'Interruptible','off',bg,clr,fg,'w',ps};
    txtPr={'Style','text',fs,8,bg,clr,fg,'w',ps};
    edtPr={'Style','edit',fs,8,bg,clr,fg,'w',ps};
    uic = @(varargin) uicontrol(varargin{:});
    icn=load('vbbIcons'); icn=icn.icons;
    
    % hFig: main figure
    set(0,units{:}); ss=get(0,'ScreenSize');
    if( ss(3)<800 || ss(4)<600 ), error('screen too small'); end
    pos = [(ss(3)-780)/2 (ss(4)-580)/2 780 580];
    hFig = figure( 'Name','VBB Labeler', 'NumberTitle','off', ...
      'Toolbar','auto', 'MenuBar','none', 'ResizeFcn',@figResized, ...
      'Color','k', 'Visible','off', 'DeleteFcn',@exitLb, ps,pos, ...
      'keyPressFcn',@keyPress );
    
    % pMenu: video/annotation menus
    pMenu.hVid    = uimenu(hFig,'Label','Video');
    pMenu.hVidOpn = uimenu(pMenu.hVid,'Label','Open');
    pMenu.hVidCls = uimenu(pMenu.hVid,'Label','Close');
    pMenu.hAnn    = uimenu(hFig,'Label','Annotation');
    pMenu.hAnnNew = uimenu(pMenu.hAnn,'Label','New');
    pMenu.hAnnOpn = uimenu(pMenu.hAnn,'Label','Open');
    pMenu.hAnnSav = uimenu(pMenu.hAnn,'Label','Save');
    pMenu.hAnnCls = uimenu(pMenu.hAnn,'Label','Close');
    pMenu.hCn = [pMenu.hVid pMenu.hAnn];
    
    % pObj: top panel containing object controls
    pObj.h=uipanel(pnlPr{:},hFig);
    pObj.hObjTp = uic( pObj.h,'Style','popupmenu',fs,8,units{:},...
      ps,[31 2 100 25],st,objTypes,'Value',1);
    pObj.hBtPrv = uic(pObj.h,btnPr{:},[5   3 25 25],'CData',icn.rNext{1});
    pObj.hBtNxt = uic(pObj.h,btnPr{:},[132 3 25 25],'CData',icn.rNext{2});
    pObj.hBtNew = uic(pObj.h,btnPr{:},[169 3 25 25],'CData',icn.rNew);
    pObj.hBtDel = uic(pObj.h,btnPr{:},[196 3 25 25],'CData',icn.rDel);
    pObj.hCbFix = uic(pObj.h,chbPr{:},[230 9 50 13],st,'Lock');
    pObj.hStSiz = uic(pObj.h,txtPr{:},[280 9 80 13],ha,'Center');
    pObj.hCn = [pObj.hObjTp pObj.hBtNew pObj.hBtDel ...
      pObj.hBtPrv pObj.hBtNxt pObj.hCbFix];
    
    % pSeq: bottom panel containing object sequence
    pSeq.h=uipanel(pnlPr{:},hFig);
    pSeq.hAx = axes(axsPr{:},pSeq.h,ps,o4);
    pSeq.apiRng = selectorRange(pSeq.h,o4,nStep,[],[.1 .5 1]);
    pSeq.apiOcc = selectorRange(pSeq.h,o4,nStep,[],[.9 .9 .7]);
    pSeq.apiLck = selectorRange(pSeq.h,o4,nStep,[],[.5 1 .5]);
    pSeq.lblRng = uic(pSeq.h,txtPr{:},o4,st,'vs',fs,7,ha,'Center');
    pSeq.lblOcc = uic(pSeq.h,txtPr{:},o4,st,'oc',fs,7,ha,'Center');
    pSeq.lblLck = uic(pSeq.h,txtPr{:},o4,st,'lk',fs,7,ha,'Center');
    
    % pLf: left main panel
    pLf.h=uipanel(pnlPr{:},hFig); pLf.hAx=axes(axsPr{:},hFig);
    icn5={icn.pPlay{1},icn.pStep{1},icn.pPause,icn.pStep{2},icn.pPlay{2}};
    for i=1:5, pLf.btn(i)=uic(pLf.h,btnPr{:},o4,'CData',icn5{i}); end
    pLf.btnRep = uic(pLf.h,btnPr{:},[10 5 25 20],'CData',icn.pRepeat);
    pLf.fpsLbl = uic(pLf.h,txtPr{:},o4,ha,'Left',st,'fps:');
    pLf.fpsInd = uic(pLf.h,edtPr{:},o4,ha,'Center');
    pLf.hFrInd = uic(pLf.h,edtPr{:},o4,ha,'Right');
    pLf.hFrNum = uic(pLf.h,txtPr{:},o4,ha,'Left');
    pLf.hCn = [pLf.btn pLf.btnRep];
    
    % pRt: right main panel
    pRt.h=uipanel(pnlPr{:},hFig); pRt.hAx=axes(axsPr{:},hFig);
    pRt.btnRep = uic(pRt.h,btnPr{:},[10 5 25 20],'CData',icn.pRepeat);
    pRt.btnGo  = uic(pRt.h,btnPr{:},[350 5 25 20],'CData',icn.fJump);
    pRt.hFrInd = uic(pRt.h,txtPr{:},o4,ha,'Right');
    pRt.hFrNum = uic(pRt.h,txtPr{:},o4,ha,'Left');
    pRt.stSkip = uic(pRt.h,txtPr{:},[55 8 45 14],ha,'Right');
    pRt.edSkip = uic(pRt.h,edtPr{:},[100 7 28 16],ha,'Center');
    pRt.stOffst = uic(pRt.h,txtPr{:},[140 7 30 14],ha,'Center');
    pRt.slOffst = uic(pRt.h,'Style','slider',bg,clr,ps,[175 5 70 20]);
    setIntSlider( pRt.slOffst, [1 nStep-1] );
    pRt.hCn = [pRt.btnRep pRt.btnGo pRt.slOffst];
    
    function figResized( h, e ) %#ok<INUSD>
      % overall size of drawable area (fWxfH)
      pos = get(hFig,ps); pad=8; pTopH=30;
      fW=pos(3)-2*pad; fH=pos(4)-2*pad-pTopH-75;
      fW0=1290; fH0=(480+fW0/nStep);
      fW=max(fW,700); fH=max(fH,700*fH0/fW0);
      fW=min(fW,fH*fW0/fH0); fH=min(fH,fW*fH0/fW0);
      % where to draw
      r = fW/fW0; fW=round(fW); fH=round(fH);
      seqH=floor((fW0-pad)/nStep*r); seqW=seqH*nStep; seqH=seqH+29;
      x = max(pad,(pos(3)-fW)/2);
      y = max(pad,(pos(4)-fH-pTopH-70)/2);
      % set panel positions (resized from canonical positions)
      set( pObj.h,  ps, [x        y+fH+70 640*r pTopH] );
      set( pLf.hAx, ps, [x        y+seqH+32 640*r 480*r] );
      set( pRt.hAx, ps, [x+650*r  y+seqH+32 640*r 480*r] );
      set( pLf.h,   ps, [x        y+seqH+2  640*r 30] );
      set( pRt.h,   ps, [x+650*r  y+seqH+2  640*r 30] );
      set( pSeq.h,  ps, [x+(fW-seqW)/2+2 y seqW seqH] );
      % postion pSeq contents
      set(pSeq.hAx,ps,[0 11 seqW seqH-29]); y=1;
      pSeq.apiLck.setPos([0 y seqW 10]);
      set(pSeq.lblLck,ps,[-13 y 12 10]); y=seqH-18;
      pSeq.apiOcc.setPos([0 y seqW 10]);
      set(pSeq.lblOcc,ps,[-13 y 12 10]); y=seqH-9;
      pSeq.apiRng.setPos([0 y seqW 10]);
      set(pSeq.lblRng,ps,[-13 y 12 10]);
      % postion pLf and pRt contents
      x=640*r-90; set(pRt.btnGo,ps,[x+60 5 25 20]); x1=640/3*r-75;
      set(pLf.hFrInd,ps,[x 7 40 16]); set(pLf.hFrNum,ps,[x+40 8 40 14]);
      set(pRt.hFrInd,ps,[x-30 8 40 14]); set(pRt.hFrNum,ps,[x+10 8 40 14]);
      for i2=1:5, set(pLf.btn(i2),ps,[640/2*r+(i2-3.5)*26+10 5 25 20]); end
      set(pLf.fpsLbl,ps,[x1 8 23 14]); set(pLf.fpsInd,ps,[x1+23 7 38 16]);
      % request display update
      if(~isempty(dispApi)); dispApi.requestUpdate(true); end;
    end
    
    function exitLb( h, e ) %#ok<INUSD>
      filesApi.closeVid();
    end
    
    function keyPress( h, evnt ) %#ok<INUSL>
      char=int8(evnt.Character); if(isempty(char)), char=0; end;
      if( char==28 ), dispApi.setPlay(-inf); end
      if( char==29 ), dispApi.setPlay(+inf); end
      if( char==31 ), dispApi.setPlay(0); end
    end
    
    function setIntSlider( hSlider, rng )
      set(hSlider,'Min',rng(1),'Value',rng(1),'Max',rng(2));
      minSt=1/(rng(2)-rng(1)); maxSt=ceil(.25/minSt)*minSt;
      set(hSlider,'SliderStep',[minSt maxSt]);
    end
    
  end

  function api = objMakeApi()
    % variables
    [objId,objS,objE,objInd,seqObjs,lims] = deal([]);
    apiRng=pSeq.apiRng; apiOcc=pSeq.apiOcc; apiLck=pSeq.apiLck;
    
    % callbacks
    set(pObj.hBtNew, 'callback', @(h,e) objNew());
    set(pObj.hBtDel, 'callback', @(h,e) objDel());
    set(pObj.hBtPrv, 'callback', @(h,e) objToggle(-1));
    set(pObj.hBtNxt, 'callback', @(h,e) objToggle(+1));
    set(pObj.hObjTp, 'callback', @(h,e) objSetType());
    set(pObj.hCbFix, 'callback', @(h,e) objSetFixed());
    apiRng.setRngChnCb(@objSetRng); apiRng.setLockCen(1);
    apiOcc.setRngChnCb(@objSetOcc); apiLck.setRngChnCb(@objSetLck);
    
    % create api
    api=struct( 'init',@init, 'drawRects',@drawRects, ...
      'prepSeq',@prepSeq, 'prepPlay',@prepPlay, ...
      'annForSave',@annForSave, 'annSaved',@annSaved );
    
    function init()
      [objId,objS,objE,objInd,seqObjs,lims] = deal([]);
      objId=-1; objSelect(-1); isAnn=~isempty(A); prepPlay();
      if( ~isAnn ), return; end
      lims=[0 0 dispApi.width() dispApi.height()]+.5;
      objTypes = unique([A.objLbl(A.objInit==1) objTypes]);
      t='*new-type*'; objTypes=[setdiff(objTypes,t) t];
      set( pObj.hObjTp, 'String', objTypes, 'Value',1 );
    end
    
    function prepPlay()
      if(objId>0), A=vbb('setRng',A,objId,objS+1,objE+1); end
      set(pObj.hStSiz,'String',''); set(pObj.hCn,'Enable','off');
      apiRng.enable(0); apiOcc.enable(0); apiLck.enable(0);
    end
    
    function seqI = prepSeq()
      seqI=100*ones(seqH,seqH*nStep,3,'uint8'); seqObjs=[];
      if(isempty(A)), return; end; n=nStepVis();
      % see if objId still visible, adjust controls accordingly
      lstInd = curInd + min(dispApi.nFrameRt(),skip*n-1);
      isVis = objId>0 && objS<=lstInd && objE>=curInd;
      set(pObj.hStSiz,'String',''); set(pObj.hCn,'Enable','on');
      apiRng.enable(isVis); apiOcc.enable(isVis); apiLck.enable(isVis);
      if(~isVis), objSelect(-1); return; end
      % extrapolate obj to current range for display only
      objSe=min(objS,curInd); objEe=max(objE,lstInd);
      A = vbb( 'setRng', A, objId, objSe+1, objEe+1 );
      % bound objInd to be in a visible axes
      s=max(objSe,curInd); e=min(objEe,lstInd);
      objInd = min(max(objInd,s),e);
      objInd = curInd + skip*floor((objInd-curInd)/skip);
      % update apiRng/apiOcc/apiLck
      s = max(floor((objS-curInd)/skip)+1,1);
      e = min(floor((objE-curInd)/skip)+1,n);
      rng=zeros(1,nStep); occ=rng; lck=rng; rng(s:e)=1;
      for i=1:n
        ind0=curInd+(i-1)*skip; ind1=objGrpInd(ind0,1);
        occ(i) = max(vbb('getVal',A,objId,'occl',ind0+1,ind1+1));
        lck(i) = max(vbb('getVal',A,objId,'lock',ind0+1,ind1+1));
      end;
      apiRng.setRng(rng); apiOcc.setRng(occ); apiLck.setRng(lck);
      apiRng.enable([1 n]); apiOcc.enable([s e]); apiLck.enable([s e]);
      if(objS<curInd), lk=0; else lk=[]; end; apiRng.setLockLf(lk);
      if(objE>lstInd), lk=0; else lk=[]; end; apiRng.setLockRt(lk);
      % update other gui controls
      objType=vbb('getVal',A,objId,'lbl');
      set(pObj.hObjTp,'Value',find(strcmp(objType,objTypes)));
      p=ceil(vbb('getVal',A,objId,'pos',objInd+1));
      set(pObj.hStSiz,'String',[num2str(p(3)) ' x ' num2str(p(4))]);
      % create seqObjs and seqI for display
      seqObjs = repmat(struct(),1,n);
      for i=0:n-1, ind=curInd+i*skip;
        % absolute object location
        pos0 = vbb('getVal', A, objId, 'pos', ind+1 );
        posv = vbb('getVal', A, objId, 'posv', ind+1 );
        % crop / resize sequence image
        posSq = bbApply( 'resize', pos0, seqPad, seqPad );
        posSq = bbApply( 'squarify', posSq, 0 );
        [Ii,posSq] = bbApply('crop',dispApi.getImg(ind),posSq); Ii=Ii{1};
        rows = round(linspace(1,size(Ii,1),seqH-2));
        cols = round(linspace(1,size(Ii,2),seqH-2));
        seqI(2:seqH-1,(2:seqH-1)+i*seqH,:) = Ii(rows,cols,:);
        % oLim~=intersect(posSq,lims); pos~=centered(pos0*res)
        res = (seqH-2)/size(Ii,1);
        xDel=-i*seqH-1+posSq(1)*res; yDel=-1+posSq(2)*res;
        oLim = bbApply('intersect',lims-.5,posSq);
        oLim = bbApply('shift',oLim*res,xDel,yDel);
        pos = bbApply('shift',pos0*res,xDel,yDel);
        if(any(posv)), posv=bbApply('shift',posv*res,xDel,yDel); end
        % seqObjs info
        lks=vbb('getVal',A,objId,'lock',ind+1,objGrpInd(ind,1)+1);
        seqObjs(i+1).pos0=pos0; seqObjs(i+1).pos=pos;
        seqObjs(i+1).posv=posv; seqObjs(i+1).res=res;
        seqObjs(i+1).lims=oLim; seqObjs(i+1).lock=max(lks);
      end
    end
    
    function hs = drawRects( flag, ind )
      hs=[]; if(isempty(A)), return; end
      switch flag
        case {'panelLf','panelRt'}
          os=A.objLists{ind+1}; n=length(os);
          if(n>0), [~,ord]=sort([os.id]==objId); os=os(ord); end
          lockSet = get(pObj.hCbFix,'Value');
          playMode = strcmp(get(pObj.hObjTp,'enable'),'off');
          for i=1:n, o=os(i); id=o.id; lbl=A.objLbl(id);
            if(A.objHide(id)), continue; end
            if(lockSet && id~=objId && ~playMode), continue; end
            static=(lockSet && id~=objId) || playMode;
            hs1=drawRect(o.pos,o.posv,lims,lbl,static,id,ind,-1);
            hs=[hs hs1]; %#ok<AGROW>
          end
        case 'objSeq'
          if(objInd==-1), return; end
          n=nStepVis(); id=objId; lbl=A.objLbl(id);
          for i=1:n, o=seqObjs(i); ind=curInd+skip*(i-1);
            hs1=drawRect(o.pos,o.posv,o.lims,lbl,0,id,ind,i-1);
            hs=[hs hs1]; %#ok<AGROW>
          end
      end
      
      function hs = drawRect(pos,posv,lims,lbl,static,id,ind,sid)
        if(colType), t=find(strcmp(lbl,objTypes)); else t=id; end
        col=rectCols(mod(t-1,size(rectCols,1))+1,:);
        if(id~=objId), ls='-'; else
          if(ind==objInd), ls='--'; else ls=':'; end; end
        rp = {'lw',2,'color',col,'ls',ls,'rotate',0,'ellipse',0};
        [hs,api]=imRectRot('pos',pos,'lims',lims,rp{:});
        api.setSizLock( sizLk );
        if( static )
          api.setPosLock(1);
          ht=text(pos(1),pos(2)-10, lbl); hs=[hs ht];
          set(ht,'color','w','FontSize',10,'FontWeight','bold');
        else
          api.setPosSetCb( @(pos) objSetPos(pos(1:4),id,ind,sid) );
        end
        if( any(posv) )
          rp={'LineWidth',2,'EdgeColor','y','LineStyle',':'};
          hs = [hs rectangle('Position',posv,rp{:})];
        end
      end
      
      function objSetPos( pos, id, ind, sid )
        if(sid>=0), o=seqObjs(sid+1); pos=o.pos0-(o.pos-pos)/o.res; end
        if(sid>0), dispApi.setOffset(sid); end
        pos=constrainPos(pos); A=vbb('setVal',A,id,'pos',pos,ind+1);
        if(objId==id), objS=min(objS,ind); objE=max(objE,ind); end
        objSelect(id,ind); ind0=curInd+floor((ind-curInd)/skip)*skip;
        ind1=objGrpInd(ind0,0); lks=zeros(ind1-ind0+1,1);
        A = vbb('setVal',A,id,'lock',lks,ind0+1,ind1+1);
        dispApi.requestUpdate();
      end
    end
    
    function objNew()
      [A,o]=vbb('emptyObj',A,curInd+1); t=get(pObj.hObjTp,'Value');
      o.lbl=objTypes{t}; if(colType==0), t=o.id; end
      col=rectCols(mod(t-1,size(rectCols,1))+1,:);
      rp={'lw',2,'color',col,'ls','--','rotate',0,'ellipse',0};
      pos=dispApi.newRect(lims,rp); o.pos=constrainPos(pos);
      A=vbb('add',A,o); objSelect(o.id,curInd); dispApi.requestUpdate();
    end
    
    function objDel()
      if(objId<=0), return; end; A=vbb('del',A,objId);
      objId=-1; objSelect(-1); dispApi.requestUpdate();
    end
    
    function objSetLck( rng0, rng1 )
      assert(objId>0); [lf,rt]=apiRng.getBnds(rng0~=rng1);
      % set object locks accordingly
      for i=lf:rt
        ind0=curInd+(i-1)*skip; ind1=objGrpInd(ind0,0);
        lks = [rng1(i); zeros(ind1-ind0,1)];
        A=vbb('setVal',A,objId,'lock',lks,ind0+1,ind1+1);
      end
      s=max(objS,curInd); e=min(objE,curInd+skip*(nStepVis()-1));
      if(~rng1(lf) || s==e), dispApi.requestUpdate(); return; end
      % interpolate intermediate positions
      o=vbb('get',A,objId,s+1,e+1); pos=[o.pos]; [n,k]=size(pos);
      lks=[o.lock]; lks([1 end])=1; lks=find(lks);
      for i=1:k, pos(:,i)=interp1(lks,pos(lks,i),1:n,'cubic'); end
      pos=constrainPos(pos); A=vbb('setVal',A,objId,'pos',pos,s+1,e+1);
      dispApi.requestUpdate();
    end
    
    function objSetRng( rng0, rng1 )
      [lf0,rt0]=apiRng.getBnds( rng0 );
      [lf1,rt1]=apiRng.getBnds( rng1 );
      rt1=min(rt1,nStepVis()); assert(objId>0);
      if(lf1~=lf0), objS=curInd+(lf1-1)*skip; end
      if(rt1~=rt0), objE=curInd+(rt1-1)*skip; end
      if(lf1~=lf0 || rt1~=rt0), objSelect(objId,objInd); end
      dispApi.requestUpdate();
    end
    
    function objSetOcc( rng0, rng1 )
      assert(objId>0); [lf,rt]=apiRng.getBnds(rng0~=rng1); assert(lf>0);
      if(lf>1 && rng0(lf-1)==1), lf=lf-1; rng1(lf)=1; end %extend lf
      if(rt<nStep && rng0(rt+1)==1), rt=rt+1; rng1(rt)=1; end %extend rt
      for i=lf:rt
        ind0=curInd+(i-1)*skip; ind1=objGrpInd(ind0,0);
        occl = ones(ind1-ind0+1,1)*rng1(i);
        A=vbb('setVal',A,objId,'occl',occl,ind0+1,ind1+1);
      end; dispApi.requestUpdate();
    end
    
    function objSetFixed(), dispApi.requestUpdate(); end
    
    function objSetType()
      type = get(pObj.hObjTp,'Value');
      if( strcmp(objTypes{type},'*new-type*') )
        typeStr = inputdlg('Define new object type:');
        if(isempty(typeStr) || any(strcmp(typeStr,objTypes)))
          set(pObj.hObjTp,'Value',1); return; end
        objTypes = [objTypes(1:end-1) typeStr objTypes(end)];
        set(pObj.hObjTp,'String',objTypes,'Value',length(objTypes)-1);
      end
      if( objId>0 )
        A = vbb('setVal',A,objId,'lbl',objTypes{type});
        dispApi.requestUpdate();
      end
    end
    
    function objToggle( d )
      li=curInd; ri=curInd+skip*offset;
      os=A.objLists{li+1}; if(isempty(os)), L=[]; else L=[os.id]; end
      os=A.objLists{ri+1}; if(isempty(os)), R=[]; else R=[os.id]; end
      [ids,R,L]=union(R,L); inds=[ones(1,numel(L))*li ones(1,numel(R))*ri];
      keep=A.objHide(ids)==0; ids=ids(keep); inds=inds(keep);
      n=length(ids); if(n==0), return; end
      if(objId==-1), if(d==1), j=1; else j=n; end; else
        j=find(ids==objId)+d; end
      if(j<1 || j>n), objSelect(-1); else objSelect(ids(j),inds(j)); end
      dispApi.requestUpdate();
    end
    
    function objSelect( id, ind )
      if(objId>0), A=vbb('setRng',A,objId,objS+1,objE+1); end
      if(id==-1), [objId,objS,objE,objInd]=deal(-1); return; end
      objS=vbb('getVal',A,id,'str')-1; objE=vbb('getVal',A,id,'end')-1;
      objId=id; objInd=ind;
    end
    
    function ind1 = objGrpInd( ind0, useExtended )
      ind1 = min(ind0+skip-1,curInd+dispApi.nFrameRt());
      if(~useExtended); ind1=min(ind1,objE); end
    end
    
    function n = nStepVis()
      n = min(nStep,floor(dispApi.nFrameRt()/skip+1));
    end
    
    function pos = constrainPos( pos )
      p=pos; p(:,3:4)=max(1,p(:,3:4)); r=max(1,siz0./p(:,3:4));
      dy=(r(:,2)-1).*p(:,4); p(:,2)=p(:,2)-dy/2; p(:,4)=p(:,4)+dy;
      dx=(r(:,1)-1).*p(:,3); p(:,1)=p(:,1)-dx/2; p(:,3)=p(:,3)+dx;
      s=p(:,1:2); e=s+p(:,3:4);
      for j=1:2, s(:,j)=min(max(s(:,j),lims(j)),lims(j+2)-siz0); end
      for j=1:2, e(:,j)=max(min(e(:,j),lims(j+2)),s(:,j)+siz0); end
      pos = [s e-s];
    end
    
    function A1 = annForSave()
      if(objId==-1), A1=A; else A1=vbb('setRng',A,objId,objS+1,objE+1); end
    end
    
    function annSaved(), assert(~isempty(A)); A.altered=false; end
  end

  function api = dispMakeApi()
    % variables
    [sr, info, looping, nPlay, replay, needUpdate, dispMode, ...
      timeDisp, hImLf, hImRt, hImSeq, hObjCur] = deal([]);
    
    % callbacks
    set( pRt.slOffst, 'Callback', @(h,e) setOffset() );
    set( pRt.edSkip,  'Callback', @(h,e) setSkip() );
    set( pLf.fpsInd,  'Callback', @(h,e) setFps() );
    set( pLf.btnRep,  'Callback', @(h,e) setPlay('replayLf') );
    set( pRt.btnRep,  'Callback', @(h,e) setPlay('replayRt') );
    set( pRt.btnGo,   'Callback', @(h,e) setFrame('go') );
    set( pLf.hFrInd,  'Callback', @(h,e) setFrame() );
    set( pLf.btn(1),  'Callback', @(h,e) setPlay(-inf) );
    set( pLf.btn(2),  'Callback', @(h,e) setFrame('-') );
    set( pLf.btn(3),  'Callback', @(h,e) setPlay(0) );
    set( pLf.btn(4),  'Callback', @(h,e) setFrame('+') );
    set( pLf.btn(5),  'Callback', @(h,e) setPlay(+inf) );
    
    % create api
    api = struct( 'requestUpdate',@requestUpdate, 'init',@init, ...
      'newRect',@newRect, 'setOffset',@setOffset, ...
      'nFrame',@nFrame, 'nFrameRt', @nFrameRt, 'getImg',@getImg, ...
      'width',@width, 'height',@height, 'setPlay', @setPlay );
    
    function init( sr1 )
      if(isstruct(sr)), sr=sr.close(); end; delete(hObjCur);
      [sr, info, looping, nPlay, replay, needUpdate, dispMode, ...
        timeDisp, hImLf, hImRt, hImSeq, hObjCur] = deal([]);
      nPlay=0; replay=0; dispMode=0; looping=1; curInd=0;
      needUpdate=1; sr=sr1; skip=1;
      if(isstruct(sr)), info=sr.getinfo(); else
        info=struct('numFrames',0,'width',0,'height',0,'fps',25); end
      if(fps), info.fps=fps; end
      setOffset(nStep-1); setSkip(skip0); setFps(info.fps);
      hs = [pLf.hAx pRt.hAx pSeq.hAx];
      for h=hs; cla(h); set(h,'XTick',[],'YTick',[]); end
      set([pLf.hCn pRt.hCn],'Enable',enStr{(nFrame>0)+1});
      set([pLf.hFrInd pRt.hFrInd],'String','0');
      set([pLf.hFrNum pRt.hFrNum],'String',[' / ' int2str(nFrame)]);
      looping=0; requestUpdate();
    end
    
    function dispLoop()
      if( looping ), return; end; looping=1; k=0;
      while( 1 )
        % if vid not loaded nothing to display
        if( nFrame==0 ), looping=0; return; end
        
        % increment/decrement curInd/nPlay appropriately
        if( nPlay~=0 )
          needUpdate=1; fps=info.fps; t=clock(); t=t(6)+60*t(5);
          del=round(fps*(t-timeDisp)); timeDisp=timeDisp+del/fps;
          if(nPlay>0), del=min(del,nPlay); else del=max(-del,nPlay); end
          nPlay=nPlay-del; if(~replay), curInd=curInd+del; end
          if(del==0), drawnow(); continue; end
        end
        
        % update display if necessary
        k=k+1; if(0 && ~needUpdate), fprintf('%i draw events.\n',k); end
        if( ~needUpdate ), looping=0; return; end
        updateDisp(); filesApi.backupAnn(); drawnow();
      end
    end
    
    function updateDisp()
      % delete old objects
      delete(hObjCur); hObjCur=[];
      % possibly switch display modes
      if( dispMode~=0 && nPlay==0 )
        needUpdate=1; dispMode=0; replay=0;
      elseif( abs(dispMode)==1 )
        needUpdate=1; dispMode=dispMode*2;
        if(dispMode<0), hImMsk=hImRt; else hImMsk=hImLf; end
        I=get(hImMsk,'CData'); I(:)=100; set(hImMsk,'CData',I);
        I=get(hImSeq,'CData'); I(:)=100; set(hImSeq,'CData',I);
        objApi.prepPlay();
      else
        needUpdate=0;
      end
      if(dispMode==0), seqI = objApi.prepSeq(); end
      % display left panel
      if( dispMode<=0 )
        set( hFig, 'CurrentAxes', pLf.hAx );
        ind=curInd; if(replay), ind=ind-nPlay; end
        hImLf = imageFast( hImLf, getImg(ind) );
        set( pLf.hFrInd, 'String', int2str(ind+1) );
        hObjCur=[hObjCur objApi.drawRects('panelLf',ind)];
      end
      % display right panel
      if( dispMode>=0 )
        set( hFig, 'CurrentAxes', pRt.hAx );
        ind=curInd+offset*skip; if(replay), ind=ind-nPlay; end
        hImRt = imageFast( hImRt, getImg(ind) );
        set( pRt.hFrInd, 'String', int2str(ind+1) );
        hObjCur=[hObjCur objApi.drawRects('panelRt',ind)];
      end
      % display seq panel
      if( dispMode==0 )
        set( hFig, 'CurrentAxes', pSeq.hAx );
        hImSeq = imageFast( hImSeq, seqI );
        hObjCur=[hObjCur objApi.drawRects('objSeq',[])];
      end
      % adjust play controls
      set( pLf.btnRep,   'Enable', enStr{(curInd>0)+1} );
      set( pLf.btn(1:2), 'Enable', enStr{(curInd>0)+1} );
      set( pLf.btn(4:5), 'Enable', enStr{(offset*skip<nFrameRt())+1});
      
      function hImg = imageFast( hImg, I )
        if(isempty(hImg)), hImg=image(I); axis off; else
          set(hImg,'CData',I); end
      end
    end
    
    function pos = newRect( lims, rp )
      % get new rectangle, extract pos (disable controls temporarily)
      hs=[pObj.hCn pLf.hCn pRt.hCn pMenu.hCn];
      en=get(hs,'Enable'); set(hs,'Enable','off');
      [hR,api]=imRectRot('hParent',pLf.hAx,'lims',lims,rp{:});
      hObjCur=[hObjCur hR]; pos=api.getPos(); pos=pos(1:4);
      for i=1:length(hs); set(hs(i),'Enable',en{i}); end
      requestUpdate();
    end
    
    function requestUpdate( clearHs )
      if(nargin==0 || isempty(clearHs)), clearHs=0; end
      if(clearHs), [hImLf, hImRt, hImSeq]=deal([]); end
      needUpdate=true; dispLoop();
    end
    
    function setSkip( skip1 )
      if(nargin==0), skip1=round(str2double(get(pRt.edSkip,'String'))); end
      if(~isnan(skip1)), skip=max(1,min(skip1,maxSkip)); end
      if(nFrame>0), skip=min(skip,floor(nFrameRt()/offset)); end
      set( pRt.stSkip, 'String', 'zoom: 1 / ');
      set( pRt.edSkip, 'String', int2str(skip) );
      set( pRt.stOffst,'String', ['+' int2str(offset*skip)] );
      setPlay(0);
    end
    
    function setOffset( offset1 )
      if( nargin==1 ), offset=offset1; else
        offset=round(get(pRt.slOffst,'Value')); end
      if(nFrame>0), offset=min(offset,floor(nFrameRt()/skip)); end
      set( pRt.slOffst, 'Value', offset );
      set( pRt.stOffst, 'String', ['+' int2str(offset*skip)] );
      setPlay(0);
    end
    
    function setFrame( f )
      if(nargin==0), f=round(str2double(get(pLf.hFrInd,'String'))); end
      if(strcmp(f,'-')), f=curInd-skip+1; end
      if(strcmp(f,'+')), f=curInd+skip+1; end
      if(strcmp(f,'go')), f=curInd+skip*offset+1; end
      if(~isnan(f)), curInd=max(0,min(f-1,nFrame-skip*offset-1)); end
      set(pLf.hFrInd,'String',int2str(curInd+1)); setPlay(0);
    end
    
    function setPlay( type )
      switch type
        case 'replayLf'
          nPlay=min(curInd,repLen*info.fps);
          dispMode=-1; replay=1;
        case 'replayRt'
          nPlay=min(skip*offset,nFrameRt());
          dispMode=1; replay=1;
        otherwise
          nPlay=type; dispMode=-1; replay=0;
          if(nPlay<0), nPlay=max(nPlay,-curInd); end
          if(nPlay>0), nPlay=min(nPlay,nFrameRt-offset*skip); end
      end
      t=clock(); t=t(6)+60*t(5); timeDisp=t; requestUpdate();
    end
    
    function setFps( fps )
      if(nargin==0), fps=round(str2double(get(pLf.fpsInd,'String'))); end
      if(isnan(fps)), fps=info.fps; else fps=max(1,min(fps,99999)); end
      set(pLf.fpsInd,'String',int2str(fps)); info.fps=fps; setPlay(0);
    end
    
    function I=getImg(f)
      sr.seek(f); I=sr.getframe(); if(ismatrix(I)), I=I(:,:,[1 1 1]); end
    end
    
    function w=width(), w=info.width; end
    
    function h=height(), h=info.height; end
    
    function n=nFrame(), n=info.numFrames; end
    
    function n=nFrameRt(), n=nFrame-1-curInd; end
  end

  function api = filesMakeApi()
    % variables
    [fVid, fAnn, tSave, tSave1] = deal([]);
    
    % callbacks
    set( pMenu.hVidOpn, 'Callback', @(h,e) openVid() );
    set( pMenu.hVidCls, 'Callback', @(h,e) closeVid() );
    set( pMenu.hAnnNew, 'Callback', @(h,e) newAnn() );
    set( pMenu.hAnnOpn, 'Callback', @(h,e) openAnn() );
    set( pMenu.hAnnSav, 'Callback', @(h,e) saveAnn() );
    set( pMenu.hAnnCls, 'Callback', @(h,e) closeAnn() );
    
    % create api
    api = struct('closeVid',@closeVid, 'backupAnn',@backupAnn, ...
      'openVid',@openVid, 'openAnn',@openAnn );
    
    function updateMenus()
      m=pMenu; en=enStr{~isempty(fVid)+1}; nm='VBB Labeler';
      set([m.hVidCls m.hAnnNew m.hAnnOpn],'Enable',en);
      en=enStr{~isempty(fAnn)+1}; set([m.hAnnSav m.hAnnCls],'Enable',en);
      if(~isempty(fVid)), [~,nm1]=fileparts(fVid); nm=[nm ' - ' nm1]; end
      set(hFig,'Name',nm); objApi.init(); dispApi.requestUpdate();
    end
    
    function closeVid()
      fVid=[]; if(~isempty(fAnn)), closeAnn(); end
      dispApi.init([]); updateMenus();
    end
    
    function openVid( f )
      if( nargin>0 )
        [d,f]=fileparts(f); if(isempty(d)), d='.'; end;
        d=[d '/']; f=[f '.seq'];
      else
        if(isempty(fVid)), d='.'; else d=fileparts(fVid); end
        [f,d]=uigetfile('*.seq','Select video',[d '/*.seq']);
      end
      if( f==0 ), return; end; closeVid(); fVid=[d f];
      try
        s=0; sr=seqIo(fVid,'r',maxCache); s=1;
        dispApi.init(sr); updateMenus();
      catch er
        errordlg(['Failed to load: ' fVid '. ' er.message],'Error');
        if(s); closeVid(); end; return;
      end
    end
    
    function closeAnn()
      assert(~isempty(fAnn)); A1=objApi.annForSave();
      if( ~isempty(A1) && A1.altered )
        qstr = 'Save Current Annotation?';
        button = questdlg(qstr,'Exiting','yes','no','yes');
        if(strcmp(button,'yes')); saveAnn(); end
      end
      A=[]; [fAnn,tSave,tSave1]=deal([]); updateMenus();
    end
    
    function openAnn( f )
      assert(~isempty(fVid)); if(~isempty(fAnn)), closeAnn(); end
      if( nargin>0 )
        [d,f,e]=fileparts(f); if(isempty(d)), d='.'; end; d=[d '/'];
        if(isempty(e) && exist([d f '.txt'],'file')), e='.txt'; end
        if(isempty(e) && exist([d f '.vbb'],'file')), e='.vbb'; end
        f=[f e];
      else
        [f,d]=uigetfile('*.vbb;*.txt','Select Annotation',fVid(1:end-4));
      end
      if( f==0 ), return; end; fAnn=[d f];
      try
        if(~exist(fAnn,'file'))
          A=vbb('init',dispApi.nFrame()); vbb('vbbSave',A,fAnn);
        else
          A=vbb( 'vbbLoad', fAnn ); eMsg='Annotation/video mismatch.';
          if(A.nFrame~=dispApi.nFrame()), error(eMsg); end
        end
      catch er
        errordlg(['Failed to load: ' fAnn '. ' er.message],'Error');
        A=[]; fAnn=[]; return;
      end
      tSave=clock(); tSave1=tSave; updateMenus();
    end
    
    function saveAnn()
      A1=objApi.annForSave(); if(isempty(A1)), return; end
      [f,d]=uiputfile('*.vbb;*.txt','Select Annotation',fAnn);
      if( f==0 ), return; end; fAnn=[d f]; tSave=clock; tSave1=tSave;
      if(exist(fAnn,'file')), copyfile(fAnn,vbb('vbbName',fAnn,1)); end
      vbb('vbbSave',A1,fAnn); objApi.annSaved();
    end
    
    function newAnn()
      if(~isempty(fAnn)), closeAnn(); end; fAnn=[fVid(1:end-3) 'vbb'];
      assert(~isempty(fVid)); A=vbb('init',dispApi.nFrame());
      updateMenus();
    end
    
    function backupAnn()
      if(isempty(tSave) || etime(clock,tSave)<30), return; end
      A1=objApi.annForSave(); if(isempty(A1)), return; end
      tSave=clock(); timeStmp=etime(tSave,tSave1)>60*5;
      if(timeStmp), tSave1=tSave; fAnn1=fAnn; else
        fAnn1=[fAnn(1:end-4) '-autobackup' fAnn(end-3:end)]; end
      vbb( 'vbbSave', A1, fAnn1, timeStmp );
    end
  end
end

function api = selectorRange( hParent, pos, n, col0, col1 )
% Graphical way of selecting ranges from the sequence {1,2,...,n}.
%
% The result of the selection is an n element vector rng in {0,1}^n that
% indicates whether each element is selected (or in the terminology below
% ON/OFF). Particularly efficient if the ON cells in the resulting rng can
% be grouped into a few continguous blocks.
%
% Creates n individual cells, 1 per element. Each cell is either OFF/ON,
% denoted by colors col0/col1. Each cell can be clicked in three discrete
% locations: LEFT/MID/RIGHT: (1) Clicking a cell in the MID location
% toggles it ON/OFF. (2) Clicking an ON cell i turns a number of cells OFF,
% determined in the following manner. Let [lf,rt] denote the contiguous
% block of ON cells containing i. Clicking on the LEFT of cell i shrinks
% the contiguous block of ON cells to [i,rt] (ie cells [lf,i-1] are truned
% OFF). Clicking on the RIGHT of cell i shrinks the contiguous block to
% [lf,i] (ie cells [i+1,rt] are truned OFF). (3) In a similar manner
% clicking an OFF cell i turns a number of cells ON. Clicking on the LEFT
% extends the closest contiguous block to the right of i, [lf,rt], to
% [i,rt]. Clicking on the RIGHT extends the closest contiguous block the
% the left of i, [lf,rt], to [lf,i]. To better understand the interface
% simply run the example below.
%
% Locks can be set to limit how the range can change. If setLockCen(1) is
% set, the user cannot toggle individual element by clicking the MIDDLE
% location (this prevents contiguous blocks from being split). setLockLf/Rt
% can be used to ensure the overall range [lf*,rt*], where lf*=min(rng) and
% rt*=max(rng) cannot change in certain ways (see below). Also use enable()
% to enable only portion of cells for interaction.
%
% USAGE
%  api = selectorRange( hParent, pos, n, [col0], [col1] )
%
% INPUTS
%  hParent    - object parent, either a figure or a uipanel
%  pos        - guis pos vector [xMin yMin width height]
%  n          - sequence size
%  col0       - [.7 .7 .7] 1x3 array: color for OFF cells
%  col1       - [.7 .9 1] 1x3 array: color for ON cells
%
% OUTPUTS
%  api        - interface allowing access to created gui object
%  .delete()       - use to delete obj, syntax is 'api.delete()'
%  .enable(en)     - enable given range (or 0/1 to enable/disable all)
%  .setPos(pos)    - set position of range selector in the figure
%  .getRng()       - get range: returns n elt range vector in {0,1}^n
%  .setRng(rng)    - set range to specified rng (n elmt vector)
%  .getBnds([rng]) - get left-most/right-most (lf,rt) bounds of range
%  .setRngChnCb(f) - whenever range changes, calls f(rngOld,rngNew)
%  .setLockCen(v)  - 0/1 enables toggling individual elements
%  .setLockLf(v)   - []:none; 0:locked; -1: only shrink; +1: only ext
%  .setLockRt(v)   - []:none; 0:locked; -1: only shrink; +1: only ext
%
% EXAMPLE
%  h=figure(1); clf; pos=[10 20 500 15]; n=10;
%  api = selectorRange( h, pos, n );
%  rng=zeros(1,n); rng(3:7)=1; api.setRng( rng );
%  f = @(rO,rN) disp(['new range= ' int2str(rN)]);
%  api.setRngChnCb( f );
%
% See also imRectRot, uicontrol

narginchk(3,5);
if(nargin<4 || isempty(col0)), col0=[.7 .7 .7]; end
if(nargin<5 || isempty(col1)), col1=[.7 .9 1]; end

% globals (n, col0, col1 are implicit globals)
lockLf=-2; lockRt=-2; lockCen=0; en=1;
[Is,hAx,hImg,rangeChnCb,rng]=deal([]);

% set initial position
rng=ones(1,n); setPos( pos );

% create api
api = struct('delete',@delete1, 'enable',@enable, 'setPos',@setPos, ...
  'getRng',@getRng, 'setRng',@setRng, 'getBnds',@getBnds, ...
  'setRngChnCb',@setRngChnCb, 'setLockCen',@(v) setLock(v,0), ...
  'setLockLf',@(v) setLock(v,-1), 'setLockRt',@(v) setLock(v,1) );

  function setPos( pos )
    % create images for virtual buttons (Is = h x w x rgb x enable)
    w=max(3,round(pos(3)/n)); wSid=floor(w/3); wMid=w-wSid*2;
    h=max(4,round(pos(4))); cols=permute([col0; col1],[1 3 2]);
    IsSid=zeros(h-2,wSid,3,2); IsMid=zeros(h-2,wMid,3,2);
    for i=1:2, IsSid(:,:,:,i)=repmat(cols(i,:,:),[h-2 wSid 1]); end
    for i=1:2, IsMid(:,:,:,i)=repmat(cols(i,:,:),[h-2 wMid 1]); end
    IsSid(:,1,:,:)=0; Is=[IsSid IsMid IsSid(:,end:-1:1,:,:)];
    Is=padarray(Is,[1 0 0 0],mean(col0)*.8,'both'); pos(3)=w*n;
    % create new axes and image objects
    delete1(); units=get(hParent,'units'); set(hParent,'Units','pixels');
    hAx=axes('Parent',hParent,'Units','pixels','Position',pos);
    hImg=image(zeros(h,w*n)); axis off; set(hParent,'Units',units);
    set(hImg,'ButtonDownFcn',@(h,e) btnPressed()); draw();
  end

  function btnPressed()
    if(length(en)==1 && en==0), return; end
    x=get(hAx,'CurrentPoint'); w=size(Is,2);
    x=ceil(min(1,max(eps,x(1)/w/n))*3*n);
    btnId=ceil(x/3); btnPos=x-btnId*3+1;
    assert( btnId>=1 && btnId<=n && btnPos>=-1 && btnPos<=1 );
    if(length(en)==2 && (btnId<en(1) || btnId>en(2))), return; end
    % compute what contiguous block of cells to alter
    if( btnPos==0 ) % toggle center
      if( lockCen ), return; end
      s=btnId; e=btnId; v=~rng(btnId);
    elseif( btnPos==-1 && ~rng(btnId) )
      rt = find(rng(btnId+1:end)) + btnId;
      if(isempty(rt)), return; else rt=rt(1); end
      s=btnId; e=rt-1; v=1; %extend to left
    elseif( btnPos==1 && ~rng(btnId) )
      lf = btnId - find(fliplr(rng(1:btnId-1)));
      if(isempty(lf)), return; else lf=lf(1); end
      s=lf+1; e=btnId; v=1; %extend to right
    elseif( btnPos==-1 && rng(btnId) )
      if(btnId==1 || ~rng(btnId-1)), return; end
      lf=btnId-find([fliplr(rng(1:btnId-1)==0) 1])+1; lf=lf(1);
      s=lf; e=btnId-1; v=0; %shrink to right
    elseif( btnPos==1 && rng(btnId) )
      if(btnId==n || ~rng(btnId+1)), return; end
      rt = find([rng(btnId+1:end)==0 1]) + btnId - 1; rt=rt(1);
      s=btnId+1; e=rt; v=0; %shrink to left
    end
    assert( all(rng(s:e)~=v) );
    % apply locks preventing extension/shrinking beyond endpoints
    [lf,rt] = getBnds();
    if( lf==-1 && (any(lockLf==[0 -1])||any(lockRt==[0 -1]))), return; end
    if( v==1 && e<lf && any(lockLf==[0 -1]) ), return; end
    if( v==1 && s>rt && any(lockRt==[0 -1]) ), return; end
    if( v==0 && s==lf && any(lockLf==[0 1]) ), return; end
    if( v==0 && e==rt && any(lockRt==[0 1]) ), return; end
    % update rng, redraw and callback
    rng0=rng; rng(s:e)=v; draw();
    if(~isempty(rangeChnCb)), rangeChnCb(rng0,rng); end
  end

  function draw()
    % construct I based on hRng and set image
    h=size(Is,1); w=size(Is,2); I=zeros(h,w*n,3);
    if(length(en)>1 || en==1), rng1=rng; else rng1=zeros(1,n); end
    for i=1:n, I(:,(1:w)+(i-1)*w,:)=Is(:,:,:,rng1(i)+1); end
    if(ishandle(hImg)), set(hImg,'CData',I); end
  end

  function setRng( rng1 )
    assert( length(rng1)==n && all(rng1==0 | rng1==1) );
    if(any(rng~=rng1)), rng=rng1; draw(); end
  end

  function [lf,rt] = getBnds( rng1 )
    if(nargin==0 || isempty(rng1)); rng1=rng; end
    [~,lf]=max(rng1); [v,rt]=max(fliplr(rng1)); rt=n-rt+1;
    if(v==0); lf=-1; rt=-1; end;
  end

  function setLock( v, flag )
    if( flag==0 ), lockCen = v; else
      if(isempty(v)), v=-2; end
      assert( any(v==[-2 -1 0 1]) );
      if(flag==1), lockRt=v; else lockLf=v; end
    end
  end

  function delete1()
    if(ishandle(hAx)), delete(hAx); end; hAx=[];
    if(ishandle(hImg)), delete(hImg); end; hImg=[];
  end

  function enable( en1 ), en=en1; draw(); end

  function setRngChnCb( f ), rangeChnCb = f; end

end
