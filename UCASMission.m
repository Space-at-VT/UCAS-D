function varargout = UCASMission(varargin)
% UCASMISSION MATLAB code for UCASMission.fig
%      UCASMISSION, by itself, creates a new UCASMISSION or raises the existing
%      singleton*.
%
%      H = UCASMISSION returns the handle to a new UCASMISSION or the handle to
%      the existing singleton*.
%
%      UCASMISSION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UCASMISSION.M with the given input arguments.
%
%      UCASMISSION('Property','Value',...) creates a new UCASMISSION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UCASMission_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UCASMission_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UCASMission

% Last Modified by GUIDE v2.5 04-Feb-2016 17:24:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UCASMission_OpeningFcn, ...
                   'gui_OutputFcn',  @UCASMission_OutputFcn, ...
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


% --- Executes just before UCASMission is made visible.
function UCASMission_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UCASMission (see VARARGIN)

% Choose default command line output for UCASMission
handles.output = hObject;
handles.Click = 0;
handles.ClickLL = 0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes UCASMission wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = UCASMission_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in New.
function New_Callback(hObject, eventdata, handles)
% hObject    handle to New (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Create New Scenario - WITH STK X
clc
root = actxserver('AgStkObjects10.AgStkObjectRoot');
root.ExecuteCommand('Units_SetConnect / Date "EpochSeconds"');

try  
    scenario = root.Children.New('eScenario','J-UCASMission');
catch
    root.CloseScenario();
    scenario = root.Children.New('eScenario','J-UCASMission');
end

%% Scenario Parameters
start = now;
starttime = datestr(start);
stoptime = datestr(start+1);
scenario.SetTimePeriod(starttime,stoptime);
scenario.StartTime = starttime;
scenario.StopTime = stoptime;

% Animation Set Real Time
root.AnimationOptions = 'eAniOptionStop';
root.Mode = 'eAniXRealtime';
scenario.Animation.AnimStepValue = 1;
scenario.Animation.RefreshDelta = 0.01;
root.ExecuteCommand('VO * EarthShapeModel MSL');
root.ExecuteCommand('Units_Set * All Distance "Feet"');

%% Vehicles
% Create UAV
root.ExecuteCommand('New / */Aircraft X47');
root.ExecuteCommand('SetPropagator */Aircraft/X47 MissionModeler');
root.ExecuteCommand('Graphics */Aircraft/X47 SetColor yellow');
root.ExecuteCommand('UseTerrain */Aircraft/X47 On');
root.ExecuteCommand('VO */Aircraft/X47 Pass3D GroundLead None GroundTrail None');
root.ExecuteCommand('VO */Aircraft/X47 DynDataText DataDisplay "LLA Velocity" Show On Color yellow');

% Create UAV Sensor
root.ExecuteCommand('New / */Aircraft/X47/Sensor Sensor1');
root.ExecuteCommand('Define */Aircraft/X47/Sensor/Sensor1 Conical 0.0 1.0 0.0 360.0');
root.ExecuteCommand('Graphics */Aircraft/X47/Sensor/Sensor1 Show Off');

% Create hellfire missle
root.ExecuteCommand('New / */Aircraft Hellfire');
root.ExecuteCommand('SetPropagator */Aircraft/Hellfire MissionModeler');
root.ExecuteCommand('Graphics */Aircraft/Hellfire SetColor white');
root.ExecuteCommand('UseTerrain */Aircraft/Hellfire On');
root.ExecuteCommand('VO */Aircraft/Hellfire Pass3D GroundTrail None');
root.ExecuteCommand('VO */Aircraft/Hellfire DynDataText DataDisplay "LLA Velocity" Show On Color white Pos BottomLeft 0 50');

% Vehicle specifications
try
    root.ExecuteCommand('MissionModeler */Aircraft/X47 Aircraft Remove "X-47b"');
    root.ExecuteCommand('MissionModeler */Aircraft/X47 Aircraft Remove "HellfireModel"');
catch
end

% X-47b
% root.ExecuteCommand('MissionModeler */Aircraft/X47 Aircraft New "X-47b');
% root.ExecuteCommand('MissionModeler */Aircraft/X47 Aircraft Choose "X-47b');
% root.ExecuteCommand('MissionModeler */Aircraft/X47 Aircraft SetValue Model3D "C:\Users\Ian\Documents\STK 10\x-47b\X47B_UCAV_Cert_v48.mdl"');
% root.ExecuteCommand('MissionModeler */Aircraft/X47 Aircraft SetValue TakeOffParameters 10 deg');
% root.ExecuteCommand('MissionModeler */Aircraft/X47 Aircraft SetValue Speeds 600 nm/hr 15000 ft/min 300 nm/hr 400 nm/hr');
% root.ExecuteCommand('MissionModeler */Aircraft/X47 Aircraft SetValue MaxThrustAccelG 4');
% root.ExecuteCommand('MissionModeler */Aircraft/X47 Aircraft SetValue MinThrustDecelG 4');
% root.ExecuteCommand('MissionModeler */Aircraft/X47 Aircraft SetValue LoadFactorG 5');
% root.ExecuteCommand('MissionModeler */Aircraft/X47 Aircraft SetValue DisplayPrefs 0');

root.ExecuteCommand('MissionModeler */Aircraft/X47 Aircraft Copy "Basic Fighter" X-47b');
root.ExecuteCommand('MissionModeler */Aircraft/X47 Aircraft Choose X-47b');
root.ExecuteCommand('MissionModeler */Aircraft/X47 Aircraft SetValue Model3D "C:\Users\Ian\Documents\STK 10\x-47b\X47B_UCAV_Cert_v48.mdl"');
%root.ExecuteCommand('MissionModeler */Aircraft/X47 Aircraft SetValue Model3D "C:\Program Files (x86)\AGI\STK 10\STKData\VO\Models\Air\f-35_jsf_cv.mdl"');

% root.ExecuteCommand('MissionModeler */Aircraft/X47 Configuration AddStation "Internal Fuel Tank"');
% root.ExecuteCommand('MissionModeler */Aircraft/X47 Configuration Station "Internal Fuel Tank 1" SetValue InitialFuelState 1500 lb');
% root.ExecuteCommand('MissionModeler */Aircraft/X47 Configuration Station "Internal Fuel Tank 1" SetValue Capacity 1500 lb');
% root.ExecuteCommand('MissionModeler */Aircraft/X47 Aircraft SetValue FuelFlow 300 lb/hr');

% Hellfire missile
root.ExecuteCommand('MissionModeler */Aircraft/Hellfire Aircraft New "HellfireModel');
root.ExecuteCommand('MissionModeler */Aircraft/Hellfire Aircraft Choose "HellfireModel');
root.ExecuteCommand('MissionModeler */Aircraft/Hellfire Aircraft SetValue Model3D "C:\Program Files (x86)\AGI\STK 10\STKData\VO\Models\Missiles\Hellfire.mdl"');
root.ExecuteCommand('MissionModeler */Aircraft/Hellfire Aircraft SetValue Speeds 865 nm/hr 50000 ft/min 865 nm/hr 865 nm/hr');
root.ExecuteCommand('MissionModeler */Aircraft/Hellfire Aircraft SetValue MaxThrustAccelG 20');
root.ExecuteCommand('MissionModeler */Aircraft/Hellfire Aircraft SetValue PullUpG 10');
root.ExecuteCommand('MissionModeler */Aircraft/Hellfire Aircraft SetValue PushOverG 0.001');
root.ExecuteCommand('MissionModeler */Aircraft/Hellfire Aircraft SetValue LoadFactorG 20');

%% Ships
NewShip(root,'Carrier',34.781,17.631,'Carrier','Green')
NewShip(root,'Destroyer1',34.7875,17.643,'Destroyer','Green')
NewShip(root,'Destroyer2',34.7783,17.667,'Destroyer','Green')
NewShip(root,'Target1',35.78,17.63,'ThreatShip','Red')
NewShip(root,'Target2',33.779,16.629,'RubberBoat','Red')
NewShip(root,'Target3',33.800,18.629,'RubberBoat','Red')

%% Takeoff Procedure
Takeoff(root,'X47',[34.781,17.631,85,90])

%% Articulations
RaiseGear(root)

%% New Animation
root.ExecuteCommand('VO * View FromTo FromRegName "STK Object" FromName "Aircraft/X47" ToRegName "STK Object" ToName "Aircraft/X47" WindowID 1');
root.ExecuteCommand('VO * ViewerPosition 30 0 100');
root.ExecuteCommand('Animate * Reset');
root.ExecuteCommand('Animate * Start');

%% Run
stop = 0;
CruiseAlt = 15000;
Target = 1;
LSwitch = 0;
ClickLL = [0 0];
Lat = 0;
Lon = 0;
tic
while stop == 0;
    % Scenarion buttons
    if get(handles.Play,'Value') == 1
        set(handles.Play,'Value',0)
        root.ExecuteCommand('Animate * Start');
    end
    if get(handles.Pause,'Value') == 1
        set(handles.Pause,'Value',0)
        root.ExecuteCommand('Animate * Pause');
    end
        
    % Scenario Time
    TimeStr = root.ExecuteCommand('GetAnimTime *');
    Time = TimeStr.Item(0);
    Tsplit = strsplit(Time,'"');
    set(handles.text23,'String',sprintf('Mission Time: %0.1f sec',str2double(Tsplit{2})))
    
    % UAV Fuel
    Fuel = 100-0.01*str2double(Tsplit{2});
    set(handles.text2,'String',sprintf('%0.1f%%',Fuel))
    
    % Manual control
    ClickLLold = ClickLL;
    ClickLL = str2num(get(handles.text24,'String'));
    if get(handles.Manual,'Value') == 1 && ClickLL(1) ~= ClickLLold(1)
        
        display('DblClick')
        NewRoute(root,'X47',Time,[UAVPos(1),UAVPos(2),UAVPos(3),Heading],[ClickLL(1),ClickLL(2),CruiseAlt])
        root.ExecuteCommand('Graphics */Aircraft/X47/Sensor/Sensor1 Show Off');
        
        % Nearby target check
        if abs(ClickLL(1)-35.78) < 0.1 && abs(ClickLL(2)-17.63) < 0.1
            Name = 'Target1';
            Target = 1;
            Lat = 35.78; Lon = 17.63;
            root.ExecuteCommand(sprintf('Point */Aircraft/X47/Sensor/Sensor1 Targeted Tracking Ship/%s Hold',Name));
            root.ExecuteCommand('Graphics */Aircraft/X47/Sensor/Sensor1 Show On');        
        elseif abs(ClickLL(1)-33.779) < 0.1 && abs(ClickLL(2)-16.629) < 0.1
            Name = 'Target2';
            Target = 2;
            Lat = 33.779; Lon = 16.629;
            root.ExecuteCommand(sprintf('Point */Aircraft/X47/Sensor/Sensor1 Targeted Tracking Ship/%s Hold',Name));
            root.ExecuteCommand('Graphics */Aircraft/X47/Sensor/Sensor1 Show On');
        elseif abs(ClickLL(1)-33.800) < 0.1 && abs(ClickLL(2)-18.629) < 0.1
            Name = 'Target3';
            Target = 3;
            Lat = 33.800; Lon = 18.629;
            root.ExecuteCommand(sprintf('Point */Aircraft/X47/Sensor/Sensor1 Targeted Tracking Ship/%s Hold',Name));
            root.ExecuteCommand('Graphics */Aircraft/X47/Sensor/Sensor1 Show On');
        end
    end
    
    % Automatic guidance 
    try
        UAVPosStr = root.ExecuteCommand(sprintf('Position */Aircraft/X47 %s',Time));
    catch
        display('Reroute')
                      
        Target = Target+1;
        if Target > 3,Target = 1;end
        
        switch Target
            case 1
                Lat = 35.78;
                Lon = 17.63;
                Name = 'Target1';
            case 2
                Lat = 33.779;
                Lon = 16.629;
                Name = 'Target2';
            case 3
                Lat = 33.800;
                Lon = 18.629;                
                Name = 'Target3';
        end

        NewRoute(root,'X47',Time,[UAVPos(1),UAVPos(2),UAVPos(3),Heading],[Lat,Lon,CruiseAlt]);
        UAVPosStr = root.ExecuteCommand(sprintf('Position */Aircraft/X47 %s',Time));
        root.ExecuteCommand(sprintf('Point */Aircraft/X47/Sensor/Sensor1 Targeted Tracking Ship/%s Hold',Name));
        root.ExecuteCommand('Graphics */Aircraft/X47/Sensor/Sensor1 Show On');
    end

    % Export UAV position
    UAVPos = str2num(UAVPosStr.Item(0));
    UAVLat2 = UAVPos(1)+UAVPos(4);
    UAVLon2 = UAVPos(2)+UAVPos(5);
    Heading = atan2d(sind(UAVLon2-UAVPos(2))*cosd(UAVLat2),cosd(UAVPos(1))*sind(UAVLat2)-sind(UAVPos(1))*cosd(UAVLat2)*cos(UAVLon2-UAVPos(2)));
    
    % Range to target
    try 
        AERStr = root.ExecuteCommand(sprintf('AER */Aircraft/X47 */Ship/%s TimePeriod %s %s',Name,Time,Time));
        AER = strsplit(AERStr.Item(0));
        Range = str2double(AER{9});
        set(handles.text13,'String',sprintf('%.0f',Range)); 
    catch
    end
    
    % Display target cooridinates
    set(handles.text17,'String',sprintf('%.2f %.2f',Lat,Lon));
    
    % Launch altitude
    if get(handles.Launch,'Value') == 1 && LSwitch == 0;
        CruiseAlt = 7500;
        NewRoute(root,'X47',Time,[UAVPos(1),UAVPos(2),UAVPos(3),Heading],[Lat,Lon,CruiseAlt]);
        LSwitch = 1;
    elseif get(handles.Launch,'Value') == 0 && LSwitch == 1;
        CruiseAlt = 15000;
        NewRoute(root,'X47',Time,[UAVPos(1),UAVPos(2),UAVPos(3),Heading],[Lat,Lon,CruiseAlt]);
        LSwitch = 0;
    end
    
    % Hellfire launch
    if get(handles.Launch,'Value') == 1 && Range < 26400
        set(handles.Launch,'Value',0)
        display('LAUNCH')
        MissileLaunch(root,'Hellfire',Time,[UAVPos(1),UAVPos(2),UAVPos(3),Heading],[Lat,Lon,0]);
    end
    
    % Land
    if get(handles.Return,'Value') == 1
        set(handles.Return,'Value',0)
        Land(root,'X47',Time,[UAVPos(1),UAVPos(2),UAVPos(3),Heading],[34.781,17.631,85,90]);
        LowerGear(root,Time)
        break
    end   
    pause(0.01)
end
toc

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
invoke(handles.activex1.Application,'ExecuteCommand','Unload / *');
delete(hObject);


% --- Executes on button press in Play.
function Play_Callback(hObject, eventdata, handles)
% hObject    handle to Play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Play


% --- Executes on button press in Pause.
function Pause_Callback(hObject, eventdata, handles)
% hObject    handle to Pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Pause


% --- Executes on button press in Launch.
function Launch_Callback(hObject, eventdata, handles)
% hObject    handle to Launch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Launch


% --- Executes on selection change in TargetList.
function TargetList_Callback(hObject, eventdata, handles)
% hObject    handle to TargetList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TargetList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TargetList


% --- Executes during object creation, after setting all properties.
function TargetList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TargetList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Visible.
function Visible_Callback(hObject, eventdata, handles)
% hObject    handle to Visible (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Visible


% --- Executes on button press in Manual.
function Manual_Callback(hObject, eventdata, handles)
% hObject    handle to Manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Manual


% --------------------------------------------------------------------
function activex1_DblClick(hObject, eventdata, handles)
% hObject    handle to activex1 (see GCBO)
% eventdata  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)
set(handles.ClickSignal,'Value',1)
% handles.Click = 1
% guidata(hObject,handles);

% --------------------------------------------------------------------
function activex1_MouseMove(hObject, eventdata, handles)
% hObject    handle to activex1 (see GCBO)
% eventdata  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)
if get(handles.ClickSignal,'Value') == 1
    set(handles.ClickSignal,'Value',0)
    Info = handles.activex1.PickInfo(eventdata.X,eventdata.Y);
    set(handles.text24,'String',sprintf('%f %f',Info.lat,Info.lon))
end
% if handles.Click == 0
%     handles.Click = 0;
%     Info = handles.activex1.PickInfo(eventdata.X,eventdata.Y);
%     LL = [Info.lat,Info.lon]
%     handles.ClickLL = LL;
%     guidata(hObject,handles);
% end


% --- Executes on button press in ClickSignal.
function ClickSignal_Callback(hObject, eventdata, handles)
% hObject    handle to ClickSignal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ClickSignal


% --- Executes on button press in Return.
function Return_Callback(hObject, eventdata, handles)
% hObject    handle to Return (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Return
