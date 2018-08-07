function varargout = RHEOL_GUI(varargin)
% RHEOL_GUI MATLAB code for RHEOL_GUI.fig
%      RHEOL_GUI, by itself, creates a new RHEOL_GUI or raises the existing
%      singleton*.
%
%      H = RHEOL_GUI returns the handle to a new RHEOL_GUI or the handle to
%      the existing singleton*.
%
%      RHEOL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RHEOL_GUI.M with the given input arguments.
%
%      RHEOL_GUI('Property','Value',...) creates a new RHEOL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RHEOL_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RHEOL_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RHEOL_GUI

% Last Modified by GUIDE v2.5 07-Aug-2018 15:02:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @RHEOL_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @RHEOL_GUI_OutputFcn, ...
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


% --- Executes just before RHEOL_GUI is made visible.
function RHEOL_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% Initialize available planets
load ./planet;  handles.planet=planet; handles.nplanets=nplanets;
set(handles.popupmenuPlanet,'String',{planet.name,'Custom'});
set(handles.popupmenuTemperature,'String',["Linear","Error function","Custom file"]);
set(handles.popupmenuDID,'String',["Compression","Extension","Strike-slip"]);
% initialize available rock types
load ./rock; handles.rock=rock; handles.nrock=nrock;
set(handles.popupmenuRockType,'String',{rock.name});
pushbuttonUpdateList_Callback(handles.pushbuttonUpdateList, eventdata, handles);
% load default input file
indef = 'Default.rhl';
defix = find(strcmp(handles.popupmenuInput.String,indef)); %ID of default among current files
if isempty(defix); defix=1; end; %Default to file #1 is default not found
indef=handles.popupmenuInput.String{defix};
[Fpath,Froot,Fext] = fileparts(indef);
% handles.flNames = fileNames;
handles = readfile(indef, handles);
populateGlobal(hObject,handles);
set(handles.listboxLayers,'Value',1);
listboxLayers_Callback(handles.listboxLayers, eventdata, handles);

set(handles.popupmenuInput,'Value',defix); %highligh default file
set(handles.editGraphic,'String',Froot); %highligh default file

% set default output file
outdef = handles.editOutput.String;        % default output file

pushbuttonDrawStructure_Callback(handles.pushbuttonDrawStructure, eventdata, handles);
pushbuttonDrawTemperature_Callback(handles.pushbuttonDrawTemperature, eventdata, handles);
pushbuttonDrawStrength_Callback(handles.pushbuttonDrawStrength, eventdata, handles);

set(handles.pushbuttonExportTable,'Enable','off');
set(handles.pushbuttonExportRheology,'Enable','off');
set(handles.pushbuttonExportProfile,'Enable','on');

% Choose default command line output for RHEOL_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RHEOL_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = RHEOL_GUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function editOutput_Callback(hObject, eventdata, handles)
% no action; text in Output box will be read when needed
function editOutput_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbuttonWrite_Callback(hObject, eventdata, handles)
% Read text in Output text box
fileName = handles.editOutput.String;
%create file if necessary
if (exist('fileName')==0)
    fileName = 'out_file.txt';
end
% save information
save_script(fileName,handles.model,handles.modelglobal)
guidata(hObject, handles);
function popupmenuInput_Callback(hObject, eventdata, handles)
% no action; value read when necessary
function popupmenuInput_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbuttonRead_Callback(hObject, eventdata, handles)
% Read information from popup menu Input
fsb_ix = get(handles.popupmenuInput,'Value');
fsb_fls = string(get(handles.popupmenuInput,'String'));
% get filename, parse root, and assigne to Graphic text edit box
fileName = fsb_fls(fsb_ix);
[Fpath,Froot,Fext] = fileparts(fileName);
set(handles.editGraphic,'String',Froot);
% Read information
handles = readfile(char(fileName), handles);
populateGlobal(hObject,handles);
set(handles.listboxLayers,'Value',1);
pushbuttonUpdateList_Callback(handles.pushbuttonUpdateList, eventdata, handles);
% Run model
pushbuttonDrawStructure_Callback(handles.pushbuttonDrawStructure, eventdata, handles);
pushbuttonDrawTemperature_Callback(handles.pushbuttonDrawTemperature, eventdata, handles);
pushbuttonDrawStrength_Callback(handles.pushbuttonDrawStrength, eventdata, handles);
guidata(hObject, handles);

function pushbuttonUpdateList_Callback(hObject, eventdata, handles)
% find all input files and display them in input menu
xfiles = struct2cell(dir('*.rhl'));
fileNames = xfiles(1,:)';
handles.flNames = fileNames;
set(handles.popupmenuInput,'String',fileNames);

guidata(hObject, handles);


function editStrainRate_Callback(hObject, eventdata, handles)
setGlobalDiscrepant(hObject,handles);
function editStrainRate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editTs_Callback(hObject, eventdata, handles)
setGlobalDiscrepant(hObject,handles);
function editTs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editGs_Callback(hObject, eventdata, handles)
setGlobalDiscrepant(hObject,handles);
function editGs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editTm_Callback(hObject, eventdata, handles)
setGlobalDiscrepant(hObject,handles);
function editTm_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenuPlanet_Callback(hObject, eventdata, handles)
pushbuttonPlanetDefault_Callback(handles.pushbuttonPlanetDefault, eventdata, handles);
setGlobalDiscrepant(hObject,handles);
function popupmenuPlanet_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbuttonPlanetDefault_Callback(hObject, eventdata, handles)
setGlobalDiscrepant(hObject,handles);
planet=handles.planet;
ip = handles.popupmenuPlanet.Value;
if ip<numel(handles.popupmenuPlanet.String)
    Ts=planet(ip).env.Ts;
    Ti=planet(ip).env.Ti;
    G=planet(ip).env.G;
    P0=planet(ip).env.P0;
    g=planet(ip).global.gravity;
    
    set(handles.editGs,'String',G);
    set(handles.editTm,'String',Ti);
    set(handles.editTs,'String',Ts);
    set(handles.editP0,'String',P0);
    set(handles.editGravity,'String',g);
end
set(handles.pushbuttonPlanetDefault,'Enable','off');

function popupmenuTemperature_Callback(hObject, eventdata, handles)
if hObject.Value==3;
    set(handles.popupmenuTemperatureFile,'enable','on');
    xfiles = struct2cell(dir('*.thm'));
    fileNames = xfiles(1,:)';
    handles.flNames = fileNames;
    set(handles.popupmenuTemperatureFile,'String',fileNames);
    indef = 'Default.thm';
    defix = find(strcmp(handles.popupmenuTemperatureFile.String,indef)); %ID of default among current files
    if isempty(defix); defix=1; end; %Default to file #1 is default not found
%     indef=handles.popupmenuTemperatureFile.String{defix};
    handles.popupmenuTemperatureFile.Value=defix;
    set(handles.editTs,'Enable','off');
    set(handles.editTm,'Enable','off');
    set(handles.editGs,'Enable','off');
else
    set(handles.popupmenuTemperatureFile,'enable','off');
    set(handles.editTs,'Enable','on');
    set(handles.editTm,'Enable','on');
    set(handles.editGs,'Enable','on');
end
setGlobalDiscrepant(hObject,handles);
handles.globalDiscrepant = 1;
guidata(hObject,handles);

function popupmenuTemperature_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenuTemperatureFile.
function popupmenuTemperatureFile_Callback(hObject, eventdata, handles);
setGlobalDiscrepant(hObject,handles);
guidata(hObject,handles);
% hObject    handle to popupmenuTemperatureFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenuTemperatureFile contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuTemperatureFile


% --- Executes during object creation, after setting all properties.
function popupmenuTemperatureFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTemperatureFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editP0_Callback(hObject, eventdata, handles)
setGlobalDiscrepant(hObject,handles);
set(handles.popupmenuPlanet,'Value',numel(get(handles.popupmenuPlanet,'String')));
function editP0_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editGravity_Callback(hObject, eventdata, handles)
setGlobalDiscrepant(hObject,handles);
function editGravity_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit8_Callback(hObject, eventdata, handles)
setGlobalDiscrepant(hObject,handles);
function edit8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenuDID_Callback(hObject, eventdata, handles)
setGlobalDiscrepant(hObject,handles);
function popupmenuDID_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',["Compression","Extension","Strike-slip"]);

function editTemperatureFile_Callback(hObject, eventdata, handles)
setGlobalDiscrepant(hObject,handles);
function editTemperatureFile_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% unknown objects. Previously deleted? 
function listbox1_Callback(hObject, eventdata, handles)
setGlobalDiscrepant(hObject,handles);
function listbox1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pushbutton6_Callback(hObject, eventdata, handles)
function pushbutton7_Callback(hObject, eventdata, handles)
function edit11_Callback(hObject, eventdata, handles)
function edit11_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu6_Callback(hObject, eventdata, handles)
function popupmenu6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','red');
end
function edit12_Callback(hObject, eventdata, handles)
function edit12_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function checkbox1_Callback(hObject, eventdata, handles)

function pushbuttonChange_Callback(hObject, eventdata, handles)
set(handles.pushbuttonExportTable,'Enable','off');
% Update global, if needed
if handles.globalDiscrepant
    mglobal=queryGlobal(handles);
    handles.modelglobal = mglobal;
    setGlobalNonDiscrepant(hObject,handles);
else
    mglobal=handles.modelglobal;
end   
% Read info about current layer
model=queryLayer(handles);
handles.model = model;
% Rework all layers
model=recalc_model(mglobal,model,handles.rock);
handles.model = model;
% Update graphs
pushbuttonDrawStructure_Callback(handles.pushbuttonDrawStructure, eventdata, handles);
pushbuttonDrawTemperature_Callback(handles.pushbuttonDrawTemperature, eventdata, handles);
pushbuttonDrawStrength_Callback(handles.pushbuttonDrawStrength, eventdata, handles);
% Adapt buttons
set(handles.pushbuttonExportProfile,'Enable','on');
set(handles.pushbuttonChange,'String','Change');
set(handles.pushbuttonChange,'Enable','off');

guidata(hObject, handles);

% --- Executes on selection change in listboxLayers.
function listboxLayers_Callback(hObject, eventdata, handles)
populateLayer(hObject,handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listboxLayers_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonAddLayer.
function pushbuttonAddLayer_Callback(hObject, eventdata, handles)
ix = handles.listboxLayers.Value;
lst = handles.listboxLayers.String;
n = size(lst,1);
model = handles.model;
if ix==n;
    in=n+1;
    model(in)=model(n);
else
    for in=n:-1:ix+1;
        model(in+1)=model(in);
        lst{in+1}="Layer "+(in+1);
    end
end
lst{in}="Layer "+(in);
set(handles.listboxLayers,'String',lst);
set(handles.listboxLayers,'Value',in);
% update layers in model
populateLayer(hObject,handles);
model=recalc_model(handles.modelglobal,model,handles.rock);
handles.model = model;
pushbuttonDrawStructure_Callback(handles.pushbuttonDrawStructure, eventdata, handles);
pushbuttonDrawTemperature_Callback(handles.pushbuttonDrawTemperature, eventdata, handles);
cla(handles.axesStrength);cla(handles.axesGrainSize);
%pushbuttonDrawStrength_Callback(handles.pushbuttonDrawStrength, eventdata, handles);
set(handles.pushbuttonChange,'String','Select rock and rheology or Save');
set(handles.pushbuttonChange,'Enable','on');
guidata(hObject, handles);

% --- Executes on button press in pushbuttonDeleteLayer.
function pushbuttonDeleteLayer_Callback(hObject, eventdata, handles)
ix = handles.listboxLayers.Value;
lst = handles.listboxLayers.String;
n = size(lst,1);
for in=ix:n-1;
    lst{in}="Layer"+(in);
end
set(handles.listboxLayers,'String',[lst(1:n-1)]);
set(handles.listboxLayers,'Value',max(ix-1,1));
% remove model(ix) from model
model = handles.model;
model = model([1:ix-1,ix+1:end]);
% update layers in model
model=recalc_model(handles.modelglobal,model,handles.rock);
handles.model = model;
populateLayer(hObject,handles);
%update structure and temperature
listboxLayers_Callback(handles.listboxLayers, eventdata, handles);
pushbuttonDrawStructure_Callback(handles.pushbuttonDrawStructure, eventdata, handles);
pushbuttonDrawTemperature_Callback(handles.pushbuttonDrawTemperature, eventdata, handles)
cla(handles.axesStrength);cla(handles.axesGrainsize);
set(handles.pushbuttonChange,'String','Changes UNSAVED');
set(handles.pushbuttonChange,'Enable','on');
set(handles.pushbuttonExportProfile,'Enable','off');
handles.globalDiscrepant = 1;
guidata(hObject, handles);

function editThickness_Callback(hObject, eventdata, handles);
set(handles.pushbuttonExportTable,'Enable','off');
% Read info about current layer
model=queryLayer(handles);
handles.model = model;
model=recalc_model(handles.modelglobal,handles.model,handles.rock);
handles.model = model;
pushbuttonDrawStructure_Callback(handles.pushbuttonDrawStructure, eventdata, handles);
pushbuttonDrawTemperature_Callback(handles.pushbuttonDrawTemperature, eventdata, handles)
cla(handles.axesStrength);cla(handles.axesGrainsize);
set(handles.pushbuttonChange,'String','Changes UNSAVED');
set(handles.pushbuttonChange,'Enable','on');
set(handles.pushbuttonExportProfile,'Enable','off');
handles.globalDiscrepant = 1;
guidata(hObject, handles)
% --- Executes during object creation, after setting all properties.
function editThickness_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);

function editPf_Callback(hObject, eventdata, handles)
set(handles.pushbuttonChange,'String','Changes UNSAVED');
set(handles.pushbuttonChange,'Enable','on');
set(handles.pushbuttonExportProfile,'Enable','off');
handles.globalDiscrepant = 1;
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function editPf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkboxHydrostatic.
function checkboxHydrostatic_Callback(hObject, eventdata, handles)
if( handles.checkboxHydrostatic.Value == 1 )
    set(handles.editPf,'Enable','off');
else
    set(handles.editPf,'Enable','on');
end
set(handles.pushbuttonChange,'String','Changes UNSAVED');
set(handles.pushbuttonChange,'Enable','on');
set(handles.pushbuttonExportProfile,'Enable','off');
handles.globalDiscrepant = 1;

% --- Executes on selection change in popupmenuRockType.
function popupmenuRockType_Callback(hObject, eventdata, handles)
rock=handles.rock;
irk = handles.popupmenuRockType.Value;
nrhl = size(rock(irk).rheol,2);
% rheologies
rhlnom = string([]);
for i = 1:nrhl
    rhlnom(i) = sprintf('%-10s-%s',rock(irk).rheol(i).name,rock(irk).rheol(i).ref);%i+"- "+rock(irk).rheol(i).ref;
end
set(handles.listboxRheology,'Max',nrhl);
set(handles.listboxRheology,'String',rhlnom);
val = handles.listboxRheology.Value;
if (val > nrhl)
    set(handles.listboxRheology,'Value',1);
end
set(handles.listboxRheology,'ListboxTop',1);

% piezometers / grain dependences
if (size(rock(irk).piezo) == 0); %no piezometers
    set(handles.popupmenuGrainSize,'String',"input");
else
    set(handles.popupmenuGrainSize,'String',["input",{rock(irk).piezo.ref}]);
end
set(handles.popupmenuGrainSize,'Value',1);
set(handles.editGrainSize,'String','1e-2');
set(handles.editGrainSize,'Enable','on');

set(handles.pushbuttonChange,'String','Change (changes unsaved)');
set(handles.pushbuttonChange,'Enable','on');

guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function popupmenuRockType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in listboxRocks.
function listboxRocks_Callback(hObject, eventdata, handles)
set(handles.pushbuttonChange,'String','Changes UNSAVED');
set(handles.pushbuttonChange,'Enable','on');
set(handles.pushbuttonExportProfile,'Enable','off');

% --- Executes during object creation, after setting all properties.
function listboxRocks_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbuttonAddRock.
function pushbuttonAddRock_Callback(hObject, eventdata, handles)
set(handles.pushbuttonChange,'String','Changes UNSAVED');
set(handles.pushbuttonChange,'Enable','on');
set(handles.pushbuttonExportProfile,'Enable','off');
% --- Executes on button press in pushbuttonDeleteRock.
function pushbuttonDeleteRock_Callback(hObject, eventdata, handles)
set(handles.pushbuttonChange,'String','Changes UNSAVED');
set(handles.pushbuttonChange,'Enable','on');
set(handles.pushbuttonExportProfile,'Enable','off');

% % --- Executes on selection change in listboxXO.
% function listboxXO_Callback(hObject, eventdata, handles)
% % hObject    handle to listboxXO (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: contents = cellstr(get(hObject,'String')) returns listboxXO contents as cell array
% %        contents{get(hObject,'Value')} returns selected item from listboxXO
% ix = handles.listboxXO.Value;
% set(handles.listboxRheology,'Value',ix);
% set(handles.listboxRheology,'ListboxTop',handles.listboxXO.ListboxTop);
% rhlchk = handles.rheolX;
% set(handles.togglebuttonEnable,'Value',1*(rhlchk(ix)=="X"));
% 
% 
% set(handles.pushbuttonChange,'String','Changes UNSAVED');
% set(handles.pushbuttonChange,'Enable','on');
% set(handles.pushbuttonExportProfile,'Enable','off');
% handles.globalDiscrepant = 1;
% 
% 
% % --- Executes during object creation, after setting all properties.
% function listboxXO_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to listboxXO (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: listbox controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end

% --- Executes on button press in checkboxNoDuctile.
function checkboxNoDuctile_Callback(hObject, eventdata, handles)
if( handles.checkboxNoDuctile.Value == 1 )
    set(handles.listboxRheology,'Enable','off');
else
    set(handles.listboxRheology,'Enable','on');
end
set(handles.pushbuttonChange,'String','Changes UNSAVED');
set(handles.pushbuttonChange,'Enable','on');
set(handles.pushbuttonExportProfile,'Enable','off');

% --- Executes on selection change in listboxRheology.
function listboxRheology_Callback(hObject, eventdata, handles)
set(handles.pushbuttonChange,'String','Changes UNSAVED');
set(handles.pushbuttonChange,'Enable','on');
set(handles.pushbuttonExportProfile,'Enable','off');
% --- Executes during object creation, after setting all properties.
function listboxRheology_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% % --- Executes on button press in togglebuttonEnable.
% function togglebuttonEnable_Callback(hObject, eventdata, handles)
% ix = handles.listboxRheology.Value;
% rhlchk = handles.rheolX;
% if(rhlchk(ix)=="X")
%     rhlchk(ix) = "O";
% else
%     rhlchk(ix) = "X";
% end
% set(handles.listboxXO,'String',rhlchk);
% handles.rheolX = rhlchk;
% 
% set(handles.pushbuttonChange,'String','Change (changes unsaved)');
% set(handles.pushbuttonChange,'Enable','on');
% handles.globalDiscrepant = 1;
% 
% guidata(hObject, handles);
% 
% % Hint: get(hObject,'Value') returns toggle state of togglebuttonEnable

% --- Executes on selection change in popupmenuGrainSize.
function popupmenuGrainSize_Callback(hObject, eventdata, handles)
if( handles.popupmenuGrainSize.Value == 1 )
    set(handles.editGrainSize,'Enable','on');
    set(handles.editGrainSize,'String','1e-2');
else
    set(handles.editGrainSize,'Enable','off');
end
set(handles.pushbuttonChange,'String','Change (changes unsaved)');
set(handles.pushbuttonChange,'Enable','on');
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function popupmenuGrainSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editGrainSize_Callback(hObject, eventdata, handles)
set(handles.pushbuttonChange,'String','Changes UNSAVED');
set(handles.pushbuttonChange,'Enable','on');
set(handles.pushbuttonExportProfile,'Enable','off');
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function editGrainSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbuttonDrawStructure.
function pushbuttonDrawStructure_Callback(hObject, eventdata, handles)
% represents schematically the current structure
axes(handles.axesStructure);
model = handles.model;
cla;
% rectangle('Position',[0,-model(length(model)).zbot/1000,1,model(length(model)).zbot/1000]);
colmap = colorcube(handles.nrock);
for j = 1:length(model)
    rectangle('Position',[0.1,model(j).ztop/1000,0.8,model(j).thick/1000],...
        'FaceColor',colmap(model(j).irock,:),'Curvature',[0.1,0.2]);
end
set(gca,'xlim',[0,1],'box','on','xtick','','ydir','reverse','color','white');
ylabel('Depth (km)');

% --- Executes on button press in pushbuttonDrawTemperature.
function pushbuttonDrawTemperature_Callback(hObject, eventdata, handles)
% Draws temperature profile
axes(handles.axesTemperature);
model = handles.model;
cla;hold on;
colmap =  colorcube(handles.nrock);
for il = 1:length(model);
    z=linspace(model(il).ztop,model(il).zbot,100);
    T=model(il).Temperature(z)-handles.modelglobal.Celsius;
    plot(T,z/1000,'linewidth',2,'parent',handles.axesTemperature,...
        'Color',colmap(model(il).irock,:));
end
set(gca,'box','on','ydir','reverse','color','white','xaxislocation','top');
xlabel('Temperature (°C)');

% --- Executes on button press in pushbuttonDrawStrength.
function pushbuttonDrawStrength_Callback(hObject, eventdata, handles)
% Draw strength profile and grain size profile
handles.model=calc_profile(handles.model,handles.modelglobal.did,handles.modelglobal.e,handles.rock);
viz_strength(handles.model,handles.modelglobal.did,handles.modelglobal.e,...
    handles.axesStrength,handles.axesGrainsize,handles.axesTemperature,handles.rock);
set(handles.axesTemperature,'color','none');
set(handles.axesGrainsize,'color','white');
set(handles.pushbuttonExportProfile,'Enable','on');
guidata(hObject,handles);

% --- Executes on button press in pushbuttonEffectiveRheology.
function pushbuttonEffectiveRheology_Callback(hObject, eventdata, handles)
set(handles.pushbuttonEffectiveRheology,'Enable','off');
set(handles.pushbuttonExportTable,'Enable','off','String','Working !!!');
% Strain rates to consider
Eall=10.^[-20:0.5:-8];
nE=numel(Eall);
Sall=NaN(size(Eall));
hw=waitbar(0,'Effective rheology calculation in progress');
for iE=1:nE;
    e=Eall(iE);
    %disp(sprintf('Working E=%s 1/s',e));
    waitbar((iE-1)/nE,hw);
    handles.model=calc_profile(handles.model,handles.modelglobal.did,e,handles.rock);
    Sall(iE)=integrate_profile(handles.model,e);
end
close(hw);
set(0,'DefaultAxesLineWidth',1,...
    'DefaultAxesFontSize',12,...
    'DefaultAxesColor','none');
axes(handles.axesStrength);  cla; hold on;
loglog(Eall,Sall/1e6/1e3,'linewidth',2);
xlabel('Strain Rate (1/s)','fontsize',18);
ylabel('Integrated stress (MPa*km)','fontsize',18);
axis(10.^[-20,-8,2,5]);
set(gca,'xscale','log','yscale','log','color','white','box','on',...
    'ydir','normal');
set(handles.pushbuttonEffectiveRheology,'Enable','on');
set(handles.pushbuttonExportTable,'Enable','on','String','Export rheology table');
set(handles.pushbuttonExportRheology,'Enable','on');

% --- Executes on button press in pushbuttonExportTable.
function pushbuttonExportTable_Callback(hObject, eventdata, handles)
Rt=get(handles.editGraphic,'String');
Mall=[get(get(handles.axesStrength,'children'),'xdata');...
    get(get(handles.axesStrength,'children'),'ydata')]';
% Mall=[get(get(get(2,'children'),'children'),'xdata');...
%     get(get(get(2,'children'),'children'),'ydata')]';
save(sprintf('%s_rheology.rht',Rt),'Mall','-ascii');


% --- Executes on button press in pushbuttonExportModel.
function pushbuttonExportModel_Callback(hObject, eventdata, handles)
Rt=get(handles.editGraphic,'String');
model=handles.model
save(sprintf('%s.mat',Rt),"model");

% --- Executes on button press in pushbuttonReduceGrainSize.
function pushbuttonReduceGrainSize_Callback(hObject, eventdata, handles)

% --- Executes on button press in pushbuttonReduceBrittle.
function pushbuttonReduceBrittle_Callback(hObject, eventdata, handles)

function editGraphic_Callback(hObject, eventdata, handles)
% hObject    handle to editGraphic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editGraphic as text
%        str2double(get(hObject,'String')) returns contents of editGraphic as a double


% --- Executes during object creation, after setting all properties.
function editGraphic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGraphic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonExportProfile.
function pushbuttonExportProfile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExportProfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Rt=get(handles.editGraphic,'String');

ProfileFigureExport(1,sprintf('%s_profile.pdf',Rt),...
    handles.axesStrength,handles.axesTemperature,handles.axesGrainsize);

% --- Executes on button press in pushbuttonExportRheology.
function pushbuttonExportRheology_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExportRheology (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Rt=get(handles.editGraphic,'String');

RheologyFigureExport(2,sprintf('%s_rheology.pdf',Rt),...
    handles.axesStrength);


% --- Executes on button press in checkboxStrength.
function checkboxStrength_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxStrength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxStrength



function editStrengthLimit_Callback(hObject, eventdata, handles)
% hObject    handle to editStrengthLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStrengthLimit as text
%        str2double(get(hObject,'String')) returns contents of editStrengthLimit as a double


% --- Executes during object creation, after setting all properties.
function editStrengthLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStrengthLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listboxBrittle.
function listboxBrittle_Callback(hObject, eventdata, handles)
% hObject    handle to listboxBrittle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxBrittle contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxBrittle
set(handles.pushbuttonChange,'String','Changes UNSAVED');
set(handles.pushbuttonChange,'Enable','on');
set(handles.pushbuttonExportProfile,'Enable','off');
handles.globalDiscrepant = 1;

% --- Executes during object creation, after setting all properties.
function listboxBrittle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxBrittle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFriction_Callback(hObject, eventdata, handles)
% hObject    handle to editFriction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFriction as text
%        str2double(get(hObject,'String')) returns contents of editFriction as a double


% --- Executes during object creation, after setting all properties.
function editFriction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFriction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%% Ancillary functions
function setGlobalDiscrepant(hObject, handles);
% setup warning to highlight discrepancy GUI and model
set(handles.pushbuttonChange,'String','Changes UNSAVED');
set(handles.pushbuttonChange,'Enable','on');
set(handles.pushbuttonExportProfile,'Enable','off');
set(handles.pushbuttonPlanetDefault,'Enable','on');
set(handles.pushbuttonDrawStructure,'Enable','on');
handles.globalDiscrepant = 1;
guidata(hObject, handles);

function setGlobalNonDiscrepant(hObject, handles);
% setup warning to highlight discrepancy GUI and model
set(handles.pushbuttonChange,'String','Changes Saved ? Strength profile discrepant');
set(handles.pushbuttonChange,'Enable','off');
set(handles.pushbuttonExportProfile,'Enable','off');
% axes(handles.axesStrength); 
set(handles.axesStrength,'color',[1,1,1]*.75)
set(handles.axesTemperature,'color',[1,1,1]*.75)
set(handles.axesGrainsize,'color',[1,1,1]*.75)
% set(handles.pushbuttonAxesStructure,'Enable','off');
handles.globalDiscrepant = 0;

guidata(hObject, handles);

function mglobal=queryGlobal(handles);
% Read information on GUI related to global parameters
mglobal = handles.modelglobal;
mglobal.e = str2double(handles.editStrainRate.String);
mglobal.G = str2double(handles.editGs.String)/1000; %convert to K/m)
mglobal.Ti = str2double(handles.editTm.String);
mglobal.Ts = str2double(handles.editTs.String);
mglobal.P0 = str2double(handles.editP0.String);
mglobal.g = str2double(handles.editGravity.String);
mglobal.thid = handles.popupmenuTemperature.Value;
mglobal.ip = handles.popupmenuPlanet.Value;
mglobal.did = handles.popupmenuDID.Value;

if mglobal.thid==3; 
    mglobal.Tfile=handles.popupmenuTemperatureFile.String{handles.popupmenuTemperatureFile.Value};
end

function model=queryLayer(handles);
rock = handles.rock; % Need to access rock information
ilay = handles.listboxLayers.Value; %Layer to change
% disp(sprintf('Changing values Layer %g',ilay));

model = handles.model;
% rock type,  thickness
model(ilay).irock = handles.popupmenuRockType.Value;
model(ilay).thick = str2num(handles.editThickness.String);
% Query ductile rheologies (>0) if included
if( handles.checkboxNoDuctile.Value == 0 )
    iduct=get(handles.listboxRheology,'Value');
else
    iduct=[];
end
% Query brittle rheologies (?0)
ibrit=get(handles.listboxBrittle,'Value');
% Assumble rheologies
model(ilay).rock(1).irheol=[iduct,(-1)*ibrit];
% pressure
if (handles.checkboxHydrostatic.Value)
    model(ilay).pf = 'p';
else
    model(ilay).pf = str2double(handles.editPf.String);
end
% grain dependence
if (handles.popupmenuGrainSize.Value == 1)
    % Custom grain size
    model(ilay).rock(1).gc = 0;
    model(ilay).rock(1).gs = str2double(handles.editGrainSize.String);
else
    % piezometer
    model(ilay).rock(1).gc = handles.popupmenuGrainSize.Value - 1;
    model(ilay).rock(1).gs = 0;
end

function populateLayer(hObject,handles)
ilay = handles.listboxLayers.Value;
model = handles.model;
set(handles.popupmenuRockType,'Value',model(ilay).irock);
set(handles.editThickness,'String',model(ilay).thick);
% set(handles.checkboxHydrostatic,'Value',1*(model(ilay).pf=='p'));
if model(ilay).pf=='p';%(handles.checkboxHydrostatic.Value)
    set(handles.checkboxHydrostatic,'Value',1);
    set(handles.editPf,'String',' ');
    set(handles.editPf,'Enable','off');
else
    set(handles.checkboxHydrostatic,'Value',0);
    set(handles.editPf,'String',model(ilay).pf);
    set(handles.editPf,'Enable','on');
end
% rock type specific
irk = model(ilay).irock(1);
rock=handles.rock;
% Populate rheology
nrhl = size(rock(irk).rheol,2);
rhlnom = string([]);
for i = 1:nrhl
    rhlnom(i) = sprintf('%-10s-%s',rock(irk).rheol(i).name,rock(irk).rheol(i).ref);%i+"- "+rock(irk).rheol(i).ref;
%     contained = ~isempty(find(model(ilay).rock(1).irheol==i));
end
set(handles.listboxRheology,'String',rhlnom);
set(handles.listboxRheology,'Max',nrhl);
set(handles.listboxRheology,'Max',numel(handles.listboxBrittle,'String'));
% Populate grain size
if (size(rock(irk).piezo) == 0)
    set(handles.popupmenuGrainSize,'String',"input");
else
    set(handles.popupmenuGrainSize,'String',["input",{rock(irk).piezo.ref}]);
end
set(handles.popupmenuGrainSize,'Value',model(ilay).rock(1).gc+1);
if( model(ilay).rock(1).gc == 0 )
    set(handles.editGrainSize,'String',model(ilay).rock(1).gs);
    set(handles.editGrainSize,'Enable','on');
else
    set(handles.editGrainSize,'String',0);
    set(handles.editGrainSize,'Enable','off');
end
% select rheology
rh=model(ilay).rock(1).irheol;
iduct=rh(find(rh>0));
ibrit=rh(find(rh<0));
set(handles.listboxBrittle,'Value',-ibrit);
set(handles.listboxRheology,'Value',iduct);

guidata(hObject, handles);

function populateGlobal(hObject, handles)
mglobal = handles.modelglobal;
% set(handles.popupmenuPlanet,'String',{planet.name});
set(handles.popupmenuPlanet,'Value',mglobal.ip);
% set(handles.popupmenuTemperature,'String',["linear","error fn"]);
set(handles.popupmenuTemperature,'Value',mglobal.thid);% thermal id
% set(handles.popupmenuDID,'String',["Compression","Extension","Strike-slip"]);
set(handles.popupmenuDID,'Value',mglobal.did);% deformation id
% display global vars
set(handles.editStrainRate,'String',mglobal.e);% strain rate
set(handles.editGs,'String',mglobal.G*1000);% thermal gradient
set(handles.editTm,'String',mglobal.Ti);% adiabatic temp
set(handles.editTs,'String',mglobal.Ts);% surface temp
set(handles.editP0,'String',mglobal.P0);% surface pressure
set(handles.editGravity,'String',mglobal.g);% gravity
guidata(hObject, handles);

function newhandles = readfile(fname, handles)
% objective: READS INPUT FILE and display on GUI
% fname = filename;
[handles.model,handles.modelglobal]=parse_script(fname);
% model = handles.model;
nlay = size(handles.model,2);
for i = 1:nlay
    lyrnom(i) = "Layer " + i;
end
set(handles.listboxLayers,'String',lyrnom);

set(handles.pushbuttonChange,'String','Save Change');
set(handles.pushbuttonChange,'Enable','off');
handles.globalDiscrepant = 0;
newhandles = handles;


% % --- Executes on button press in pushbuttonSingleProfile.
% function pushbuttonSingleProfile_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbuttonSingleProfile (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
%
% handles.model=calc_profile(handles.model,handles.modelglobal.did,handles.modelglobal.e,handles.rock);
% % axes(handles.axesTemperature);
% viz_strength(handles.model,handles.modelglobal.did,handles.modelglobal.e,...
%     handles.axesStrength,handles.axesGrainsize,handles.axesTemperature,handles.rock);
%
%
% %             calc_strength; plot_strength_integrate;

