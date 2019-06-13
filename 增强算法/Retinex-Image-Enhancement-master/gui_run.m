function varargout = gui_run(varargin)
% GUI_RUN MATLAB code for gui_run.fig
%      GUI_RUN, by itself, creates a new GUI_RUN or raises the existing
%      singleton*.
%
%      H = GUI_RUN returns the handle to a new GUI_RUN or the handle to
%      the existing singleton*.
%
%      GUI_RUN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_RUN.M with the given input arguments.
%
%      GUI_RUN('Property','Value',...) creates a new GUI_RUN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_run_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_run_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_run

% Last Modified by GUIDE v2.5 07-Aug-2016 17:51:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_run_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_run_OutputFcn, ...
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


% --- Executes just before gui_run is made visible.
function gui_run_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_run (see VARARGIN)

% Choose default command line output for gui_run
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_run wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_run_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%[filename,pathname]=uigetfile({'*.jpg';'*.bmp','*.png'},'Choose File');
%[FileName,PathName] = uigetfile({'*.m';'*.slx';'*.mat';'*.png';'*.jpg'},'Select the MATLAB code file'); 
[filename, pathname, filterindex] = uigetfile({'*.png';'*.jpg'},'Pick a  image')
%
handles.myImage = strcat(pathname, filename);
 gg=strcat(pathname, filename);
 axes(handles.axes1);
 imshow(handles.myImage);
 Code(gg);


% --- Executes during object creation, after setting all properties.
function pushbutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
