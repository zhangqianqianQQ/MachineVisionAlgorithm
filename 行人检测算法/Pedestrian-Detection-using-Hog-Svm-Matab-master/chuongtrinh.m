function varargout = chuongtrinh(varargin)
% CHUONGTRINH MATLAB code for chuongtrinh.fig
%      CHUONGTRINH, by itself, creates a new CHUONGTRINH or raises the existing
%      singleton*.
%
%      H = CHUONGTRINH returns the handle to a new CHUONGTRINH or the handle to
%      the existing singleton*.
%
%      CHUONGTRINH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHUONGTRINH.M with the given input arguments.
%
%      CHUONGTRINH('Property','Value',...) creates a new CHUONGTRINH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before chuongtrinh_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to chuongtrinh_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help chuongtrinh

% Last Modified by GUIDE v2.5 29-Aug-2017 10:44:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @chuongtrinh_OpeningFcn, ...
                   'gui_OutputFcn',  @chuongtrinh_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before chuongtrinh is made visible.
function chuongtrinh_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to chuongtrinh (see VARARGIN)

% Choose default command line output for chuongtrinh
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
addpath('./params/');
addpath('./libs/');
addpath('./libsvm-master/matlab');
start_i=imread('xinchonanh.png');
axes(handles.axes1);
imshow(start_i);

% UIWAIT makes chuongtrinh wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = chuongtrinh_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnChonanh.
function btnChonanh_Callback(hObject, eventdata, handles)
% hObject    handle to btnChonanh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('.\image','Xin vui long chon anh...');
I=imread([pathname,filename]);
imshow(I);
assignin('base','I',I)

% --- Executes on button press in btnNhandang.
function btnNhandang_Callback(hObject, eventdata, handles)
% hObject    handle to btnNhandang (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evalin('base','nhandien');

% --- Executes on button press in btnthoat.
function btnthoat_Callback(hObject, eventdata, handles)
% hObject    handle to btnthoat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all


% --- Executes on button press in btntrain.
function btntrain_Callback(hObject, eventdata, handles)
% hObject    handle to btntrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
eval('train');
