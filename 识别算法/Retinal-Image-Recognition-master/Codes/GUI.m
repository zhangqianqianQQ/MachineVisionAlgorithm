function varargout = GUI(varargin)
gui_Singleton = 1;

gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
               
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
   gui_mainfcn(gui_State, varargin{:});
end

function GUI_OpeningFcn(hObject, eventdata, handles, varargin)

% 隐藏图片区域
set(handles.imageaxes,'visible','off')

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


function varargout = GUI_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

% --- Executes on selection change in popupmenuC.
function popupmenuC_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuC contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuC


% --- Executes during object creation, after setting all properties.
function popupmenuC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% 选择按钮
function choosebutton_Callback(hObject, eventdata, handles)
% 读文件
[filepath,filename] = uigetfile({'*.jpg';'*.bmp'},'Select the Image');

if isempty(filename)
    msgbox('Empty File !!','Warning','warn');
else
    currentfile = [filename,filepath];
    currentimage = imread(currentfile);
    % axes(handles.imageaxes);
    imshow(currentimage);
    title('原始图片');
    handles.currentimage = currentimage;
    % 将文件路径和文件名保存到handles里面
    handles.filepath = filepath;
    handles.filename = filename;
    
    guidata(hObject,handles);
end

% 截图按钮
function cutbutton_Callback(hObject, eventdata, handles)
h = imcrop();
axes(handles.imageaxes);
imshow(h);
title('截取后图片');
handles.cutimage = h;
guidata(hObject,handles);

% 取消按钮
function cancelbutton_Callback(hObject, eventdata, handles)
global  hh1 hh2 hh3;

h = 0;
if ishandle(hh1)
    delete(hh1);h=1;
end
if ishandle(hh2)
    delete(hh2);h=1;
end
if ishandle(hh3)
    delete(hh3);h=1;
end
if h
    handles.imageaxes = axes('parent',handles.imagepanel);
end

cla(handles.imageaxes,'reset');
set(handles.imageaxes,'visible','off')


% 计算按钮
function confirmbutton_Callback(hObject, eventdata, handles)

testimage = handles.cutimage;

cutimage = rgb2hsv(testimage);

img = cutimage(:,:,1);
cluster_num = 2;    % 设置分类数
maxiter = 60;       % 最大迭代次数

% kmeans最为初始化预分割
label = kmeans(img(:),cluster_num);
label = reshape(label,size(img));
iter = 0;

while iter < maxiter
    %-------计算先验概率---------------
    %这里我采用的是像素点和3*3领域的标签相同与否来作为计算概率
    %------收集上下左右斜等八个方向的标签--------
    label_u = imfilter(label,[0,1,0;0,0,0;0,0,0],'replicate');
    label_d = imfilter(label,[0,0,0;0,0,0;0,1,0],'replicate');
    label_l = imfilter(label,[0,0,0;1,0,0;0,0,0],'replicate');
    label_r = imfilter(label,[0,0,0;0,0,1;0,0,0],'replicate');
    label_ul = imfilter(label,[1,0,0;0,0,0;0,0,0],'replicate');
    label_ur = imfilter(label,[0,0,1;0,0,0;0,0,0],'replicate');
    label_dl = imfilter(label,[0,0,0;0,0,0;1,0,0],'replicate');
    label_dr = imfilter(label,[0,0,0;0,0,0;0,0,1],'replicate');
    p_c = zeros(cluster_num,size(label,1)*size(label,2));
    
    % 计算像素点8领域标签相对于每一类的相同个数
    for i = 1:cluster_num
        label_i = i * ones(size(label));
        temp = ~(label_i - label_u) + ~(label_i - label_d) + ...
            ~(label_i - label_l) + ~(label_i - label_r) + ...
            ~(label_i - label_ul) + ~(label_i - label_ur) + ...
            ~(label_i - label_dl) +~(label_i - label_dr);
        p_c(i,:) = temp(:)/8;% 计算概率
    end
    p_c(p_c == 0) = 0.001;% 防止出现0
    %---------------计算似然函数----------------
    mu = zeros(1,cluster_num);
    sigma = zeros(1,cluster_num);
    %求出每一类的的高斯参数--均值方差
    for i = 1:cluster_num
        index = label == i;%找到每一类的点
        data_c = double(img(index));
        mu(i) = mean(data_c);%均值
        sigma(i) = var(data_c);%方差
    end
    p_sc = zeros(cluster_num,size(label,1)*size(label,2));
    %------计算每个像素点属于每一类的似然概率--------
    %------为了加速运算，将循环改为矩阵一起操作--------
    for j = 1:cluster_num
        MU = repmat(mu(j),size(img,1)*size(img,2),1);
        p_sc(j,:) = 1/sqrt(2*pi*sigma(j))*...
            exp(-(double(img(:))-MU).^2/2/sigma(j));
    end 
    %找到联合一起的最大概率最为标签，取对数防止值太小
    [~,label] = max(log(p_c) + log(p_sc));
    %改大小便于显示
    label = reshape(label,size(img));
    iter = iter + 1;
end

m = numel(label);
x = length(find(label==1));
y = min(x,m-x);

% 读取
val = get(handles.popupmenuC,'value');
switch val
    case 1
        % Roberts
        BW = edge(label,'Roberts',0.04);
        g = length(find(BW==1))/2;
        h = y/g;
    case 2
        % Sobel
        BW = edge(label,'Sobel',0.04);
        g = length(find(BW==1))/2;
        h = y/g;
    case 3
        % Prewitt
        BW = edge(label,'Prewitt',0.04);
        g = length(find(BW==1))/2;
        h = y/g;
    case 4
        % LOG
        BW = edge(label,'LOG',0.004);
        g = length(find(BW==1))/2;
        h = y/g;
    case 5
        % Canny
        BW = edge(label,'Canny',0.04);
        g = length(find(BW==1))/2;
        h = y/g;
    otherwise
        % Sobel
        BW = edge(label,'Sobel',0.04);
        g = length(find(BW==1))/2;
        h = y/g;
end

% 显示
global hh1 hh2 hh3;

str = ['测量血管宽度：',num2str(h),'像素'];

hh1 = subplot(2,2,[1,2]);
imshow(testimage)
title({str;'截取后图片'})

hh2 = subplot(2,2,3);
imshow(label,[])
title('分割后图像')

hh3 = subplot(2,2,4);
imshow(BW)
title(' 边缘检测 ')
