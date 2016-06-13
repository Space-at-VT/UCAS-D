function varargout = SurveillanceUAV(varargin)
% SURVEILLANCEUAV MATLAB code for SurveillanceUAV.fig
%      SURVEILLANCEUAV, by itself, creates a new SURVEILLANCEUAV or raises the existing
%      singleton*.
%
%      H = SURVEILLANCEUAV returns the handle to a new SURVEILLANCEUAV or the handle to
%      the existing singleton*.
%
%      SURVEILLANCEUAV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SURVEILLANCEUAV.M with the given input arguments.
%
%      SURVEILLANCEUAV('Property','Value',...) creates a new SURVEILLANCEUAV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SurveillanceUAV_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SurveillanceUAV_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SurveillanceUAV

% Last Modified by GUIDE v2.5 23-Jul-2015 23:14:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SurveillanceUAV_OpeningFcn, ...
                   'gui_OutputFcn',  @SurveillanceUAV_OutputFcn, ...
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


% --- Executes just before SurveillanceUAV is made visible.
function SurveillanceUAV_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SurveillanceUAV (see VARARGIN)

% Choose default command line output for SurveillanceUAV
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SurveillanceUAV wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SurveillanceUAV_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in NewScn.
function NewScn_Callback(hObject, eventdata, handles)
% hObject    handle to NewScn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc
% Initialize GUI
set(handles.text4,'String',0)
set(handles.text5,'String',0)
set(handles.DblClick,'Value',0)
set(handles.TrackV,'Value',0)
set(handles.LatBox,'String','37.3235')
set(handles.LonBox,'String','-80.0354')
list = char('Target 1','Target 2','Target 3');
set(handles.TargetMenu,'String',list)

% Create New Scenario - WITH STK X
root = actxserver('AgStkObjects10.AgStkObjectRoot');
root.ExecuteCommand('Units_SetConnect / Date "UTCG"');
try    
    scenario = root.Children.New('eScenario','UAVMission');
catch
    root.CloseScenario();
    scenario = root.Children.New('eScenario','UAVMission');
end
% --------------

% Create New Scenario - WITHOUT STK X
%app = actxserver('STK10.application');
%root = app.Personality2;
%scenario = root.Children.New('eScenario','UAVMission');
% --------------

% Scenario Parameters
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
root.ExecuteCommand('Units_Set * Connect Distance "meter"')


% Terrain Visuals and Calculations
root.ExecuteCommand('VO * EarthShapeModel MSL');
root.ExecuteCommand('Terrain * Add Type PDTT File "C:\Users\Ian\Documents\STK 10\Config\CentralBodies\Earth\GeoData\Bluefield.pdtt"');
root.ExecuteCommand('Terrain * Add Type PDTT File "C:\Users\Ian\Documents\STK 10\Config\CentralBodies\Earth\GeoData\WinstonSalem.pdtt"');
root.ExecuteCommand('Terrain * Add Type PDTT File "C:\Users\Ian\Documents\STK 10\Config\CentralBodies\Earth\GeoData\Roanoke.pdtt"');

root.ExecuteCommand('VO * TerrainAndImagery Add File "C:\Users\Ian\Documents\STK 10\Config\CentralBodies\Earth\GeoData\Bluefield.pdtt"');
root.ExecuteCommand('VO * TerrainAndImagery Add File "C:\Users\Ian\Documents\STK 10\Config\CentralBodies\Earth\GeoData\WinstonSalem.pdtt"');
root.ExecuteCommand('VO * TerrainAndImagery Add File "C:\Users\Ian\Documents\STK 10\Config\CentralBodies\Earth\GeoData\Roanoke.pdtt"');

% UAV
root.ExecuteCommand('New / */Aircraft RQ5A_Hunter');
root.ExecuteCommand('SetPropagator */Aircraft/RQ5A_Hunter MissionModeler');
root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Aircraft Choose "Basic UAV"');
root.ExecuteCommand('Graphics */Aircraft/RQ5A_Hunter SetColor yellow');
root.ExecuteCommand('UseTerrain */Aircraft/RQ5A_Hunter On');

% Ground Vehicles
root.ExecuteCommand('New / */GroundVehicle Target');
root.ExecuteCommand('AddWaypoint */GroundVehicle/Target DetTimeAccFromVel 37.12920 -80.37023 0 27');
root.ExecuteCommand(sprintf('AddWaypoint */GroundVehicle/Target DetTimeAccFromVel 37.25621 -80.17589 0 27'));
root.ExecuteCommand(sprintf('AddWaypoint */GroundVehicle/Target DetTimeAccFromVel 37.38811 -79.90430 0 27'));
root.ExecuteCommand(sprintf('AddWaypoint */GroundVehicle/Target DetTimeAccFromVel 37.52460 -79.70667 0 27'));
root.ExecuteCommand('Graphics */GroundVehicle/Target SetColor white');
root.ExecuteCommand('AltitudeRef */GroundVehicle/Target Ref Terrain');
root.ExecuteCommand('AltitudeRef */GroundVehicle/Target TerrainGran 10');

root.ExecuteCommand('New / */GroundVehicle Target2');
root.ExecuteCommand('VO */GroundVehicle/Target2 Model File "C:\Program Files (x86)\AGI\STK 10\STKData\VO\Models\Land\humvee.mdl"');
root.ExecuteCommand('AddWaypoint */GroundVehicle/Target2 DetTimeAccFromVel 37.57454 -80.31136 0 27');
root.ExecuteCommand('AddWaypoint */GroundVehicle/Target2 DetTimeAccFromVel 37.12204 -79.82533 0 27');
root.ExecuteCommand('Graphics */GroundVehicle/Target2 SetColor white');
root.ExecuteCommand('AltitudeRef */GroundVehicle/Target2 Ref Terrain');
root.ExecuteCommand('AltitudeRef */GroundVehicle/Target2 TerrainGran 10');

root.ExecuteCommand('New / */GroundVehicle Target3');
root.ExecuteCommand('VO */GroundVehicle/Target3 Model File "C:\Program Files (x86)\AGI\STK 10\STKData\VO\Models\Land\humvee.mdl"');
root.ExecuteCommand(sprintf('AddWaypoint */GroundVehicle/Target3 DetVelFromTime 37.227753 -80.422073 0 %s',datestr(start)));
root.ExecuteCommand(sprintf('AddWaypoint */GroundVehicle/Target3 DetVelFromTime 37.227753 -80.422073 0 %s',datestr(start+1)));
root.ExecuteCommand('Graphics */GroundVehicle/Target3 SetColor white');
root.ExecuteCommand('AltitudeRef */GroundVehicle/Target3 Ref Terrain');
root.ExecuteCommand('AltitudeRef */GroundVehicle/Target3 TerrainGran 10');

% AWACS
root.ExecuteCommand('New / */Aircraft E3A_Sentry');
root.ExecuteCommand('SetPropagator */Aircraft/E3A_Sentry MissionModeler');
root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry Procedure Add AsFirst SiteType Waypoint ProcedureType "Holding - Figure-8"');
root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry Procedure 1 SetValue Range 0 km');
root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry Procedure 1 SetValue Width 50 km');
root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry Procedure 1 SetValue RequestedAltitude false 30000 ft');
root.ExecuteCommand(sprintf('MissionModeler */Aircraft/E3A_Sentry Site 1 SetValue Latitude %f deg',37.3235));
root.ExecuteCommand(sprintf('MissionModeler */Aircraft/E3A_Sentry Site 1 SetValue Longitude %f deg',-80.0354));
root.ExecuteCommand(sprintf('MissionModeler */Aircraft/E3A_Sentry Procedure SetTime 1 "%s" UTCG',datestr(start)));
root.ExecuteCommand('VO */Aircraft/E3A_Sentry Pass3D GroundLead None GroundTrail None');
root.ExecuteCommand('Graphics */Aircraft/E3A_Sentry SetColor yellow');

root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry ConfigureAll');
root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry CalculateAll');
root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry SendNtfUpdate');
root.ExecuteCommand('VO */Aircraft/E3A_Sentry Model File "C:\Program Files (x86)\AGI\STK 10\STKData\VO\Models\Air\e-3a_sentry_awacs.mdl"');

% Access
% root.ExecuteCommand('Access */Aircraft/E3A_Sentry */Aircraft/RQ5A_Hunter TimePeriod Scenario');

% Airports
root.ExecuteCommand('New / */Facility Montgomery_Airport');
root.ExecuteCommand('SetPosition */Facility/Montgomery_Airport Geodetic 37.20828 -80.40689 0 MSL');
root.ExecuteCommand('VO */Facility/Montgomery_Airport Model File "C:\Program Files (x86)\AGI\STK 10\STKData\VO\Models\Land\omni_directional_antenna.mdl');
root.ExecuteCommand('VO */Facility/Montgomery_Airport ScaleLog 2');
root.ExecuteCommand('UseTerrain */Facility/Montgomery_Airport On');
root.ExecuteCommand('Graphics */Facility/Montgomery_Airport SetColor blue');

root.ExecuteCommand('New / */Facility Roanoke_Airport');
root.ExecuteCommand('SetPosition */Facility/Roanoke_Airport Geodetic 37.32614 -79.97344 0 MSL');
root.ExecuteCommand('VO */Facility/Roanoke_Airport Model File "C:\Program Files (x86)\AGI\STK 10\STKData\VO\Models\Land\omni_directional_antenna.mdl');
root.ExecuteCommand('VO */Facility/Roanoke_Airport ScaleLog 2');
root.ExecuteCommand('UseTerrain */Facility/Roanoke_Airport On');
root.ExecuteCommand('Graphics */Facility/Roanoke_Airport SetColor blue');

root.ExecuteCommand('New / */Facility Kentland_Farms');
root.ExecuteCommand('SetPosition */Facility/Kentland_Farms Geodetic 37.19750 -80.57916 0 MSL');
root.ExecuteCommand('VO */Facility/Kentland_Farms Model File "C:\Program Files (x86)\AGI\STK 10\STKData\VO\Models\Land\omni_directional_antenna.mdl');
root.ExecuteCommand('VO */Facility/Kentland_Farms ScaleLog 2');
root.ExecuteCommand('UseTerrain */Facility/Kentland_Farms On');
root.ExecuteCommand('Graphics */Facility/Kentland_Farms SetColor blue');

% Sensor
root.ExecuteCommand('New / */Aircraft/RQ5A_Hunter/Sensor Sensor1');
root.ExecuteCommand('Define */Aircraft/RQ5A_Hunter/Sensor/Sensor1 Conical 0.0 1.0 0.0 360.0');
root.ExecuteCommand('Location */Aircraft/RQ5A_Hunter/Sensor/Sensor1 Fixed Cartesian 0.45 0 0.8');

% Takeoff
Airport = get(handles.AirportMenu,'Value');
root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Procedure Add AsFirst SiteType Runway ProcedureType "Takeoff"');
root.ExecuteCommand(sprintf('MissionModeler */Aircraft/RQ5A_Hunter Procedure SetTime 1 "%s" UTCG',datestr(start)));
root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Procedure 1 SetValue RunwayAltitudeOffset 5 ft');
root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Procedure 1 SetValue UseRunwayTerrain true');

switch Airport
    case 1
        root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Site 1 SetValue Latitude 37.2078 deg');
        root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Site 1 SetValue Longitude -80.408053 deg');
        root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Site 1 SetValue Heading 117 deg false');
        root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Site 1 SetValue Length 51 ft');
    case 2
        root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Site 1 SetValue Latitude 37.19687 deg');
        root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Site 1 SetValue Longitude -80.57846 deg');
        root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Site 1 SetValue Heading 53 deg false');
        root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Site 1 SetValue Length 51 ft'); 
    case 3
        root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Site 1 SetValue Latitude 37.32397 deg');
        root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Site 1 SetValue Longitude -79.97719 deg');
        root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Site 1 SetValue Heading 147 deg false');
        root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Site 1 SetValue Length 51 ft');
end

root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter ConfigureAll');
root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter CalculateAll');
root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter SendNtfUpdate');

% Articulations
root.ExecuteCommand(sprintf('VO */Aircraft/E3A_Sentry Articulate "%s" 24 E3a_dome Yaw 360 -360',datestr(start)));
for prop = 1:1000
    t = datestr(start+1/24/3600*prop);
    t2 = datestr(start+24/24/3600*prop);
    root.ExecuteCommand(sprintf('VO */Aircraft/RQ5A_Hunter Articulate "%s" 1 prop_aft Spin 360 -360',t));
    root.ExecuteCommand(sprintf('VO */Aircraft/RQ5A_Hunter Articulate "%s" 1 prop_forward Spin -360 360',t));
    root.ExecuteCommand(sprintf('VO */Aircraft/E3A_Sentry Articulate "%s" 24 E3a_dome Yaw 360 -360',datestr(start)));
    root.ExecuteCommand(sprintf('VO */Aircraft/E3A_Sentry Articulate "%s" 24 E3a_dome Yaw 360 -360',t2));
end

% Start Animation
root.ExecuteCommand('VO * View FromTo FromRegName "STK Object" FromName "Aircraft/RQ5A_Hunter" ToRegName "STK Object" ToName "Aircraft/RQ5A_Hunter" WindowID 1')
root.ExecuteCommand('Animate * Reset');
root.ExecuteCommand('Animate * Start');

% Initialize while loop
stop = 0;
lat = 0;
lon = 0;
iter = 150;
targetsel = 0;
while stop ~=1;
    % Play
    if get(handles.PlayButton,'Value') == 1
        root.ExecuteCommand('Animate * Start');
        set(handles.PlayButton,'Value',0);
    end
    
    % Pause
    if get(handles.PauseButton,'Value') == 1
        root.ExecuteCommand('Animate * Pause');
        set(handles.PauseButton,'Value',0);
    end 
    
    % Get current time & UAV position
    timeitem = root.ExecuteCommand('GetAnimTime *');
    t = datestr(timeitem.Item(0));
    try
        uavpositem = root.ExecuteCommand(sprintf('Position */Aircraft/RQ5A_Hunter "%s"',t));
        uavposstr = uavpositem.Item(0);
        uavpos = str2num(uavposstr);
    catch
        set(handles.TrackV,'Value',1)
        display('catch1')
        iter = 150;
    end
    
    % Manual Control
    if get(handles.DblClick,'Value') == 1
        set(handles.TrackV,'Value',0)
        
        if str2double(get(handles.text4,'String')) ~= lat &&...
                str2double(get(handles.text5,'String')) ~= lon

            lat = str2double(get(handles.text4,'String'));
            lon = str2double(get(handles.text5,'String'));          
            
            try
                root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Procedure Remove 2');
            catch
                %First Iteration
            end
            root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Procedure Remove 1');
            
            uavlat = uavpos(1)+uavpos(4);
            uavlon = uavpos(2)+uavpos(5);
            b = atan2d(sind(uavlon-uavpos(2))*cosd(uavlat),cosd(uavpos(1))*sind(uavlat)-sind(uavpos(1))*cosd(uavlat)*cos(uavlon-uavpos(2)));
            
            root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Procedure Add AsFirst SiteType Waypoint ProcedureType "Enroute"');
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/RQ5A_Hunter Procedure 1 SetValue ArriveOnHeading true %.4f deg',b));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/RQ5A_Hunter Site %.0f SetValue Latitude %f deg',1,uavpos(1)));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/RQ5A_Hunter Site %.0f SetValue Longitude %f deg',1,uavpos(2)));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/RQ5A_Hunter Procedure 1 SetValue RequestedAltitude false %.2f m',uavpos(3)+31));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/RQ5A_Hunter Procedure SetTime 1 "%s" UTCG',t));
            
            root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Procedure Add AfterLast SiteType Waypoint ProcedureType "Enroute"');
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/RQ5A_Hunter Site %.0f SetValue Latitude %f deg',2,lat));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/RQ5A_Hunter Site %.0f SetValue Longitude %f deg',2,lon));
            
            root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter ConfigureAll');
            root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter CalculateAll');
            root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter SendNtfUpdate');
        end

    end  
    
    % Tracking
    if get(handles.TrackV,'Value') == 1
        set(handles.DblClick,'Value',0)

        if targetsel ~= get(handles.TargetMenu,'Value')
            iter = 150;
        end
        targetsel = get(handles.TargetMenu,'Value');
                
        if iter/150 == floor(iter/150)
            
            if targetsel == 1
                positem = root.ExecuteCommand(sprintf('Position */GroundVehicle/Target "%s"',t));
                root.ExecuteCommand('Point */Aircraft/RQ5A_Hunter/Sensor/Sensor1 Targeted Tracking GroundVehicle/Target Hold');
            elseif targetsel == 2
                positem = root.ExecuteCommand(sprintf('Position */GroundVehicle/Target2 "%s"',t));
                root.ExecuteCommand('Point */Aircraft/RQ5A_Hunter/Sensor/Sensor1 Targeted Tracking GroundVehicle/Target2 Hold');
            elseif targetsel == 3
                positem = root.ExecuteCommand(sprintf('Position */GroundVehicle/Target3 "%s"',t));
                root.ExecuteCommand('Point */Aircraft/RQ5A_Hunter/Sensor/Sensor1 Targeted Tracking GroundVehicle/Target3 Hold');
            end
            posstr = positem.Item(0);
            pos = str2num(posstr);
            
            % Intercept guess
            targetlat = pos(1)+pos(4)*250;
            targetlon = pos(2)+pos(5)*250;
            
            try
                root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Procedure Remove 2');
            catch
                display('catch2')
                %First Iteration
            end
            root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Procedure Remove 1');
            
            uavlat = uavpos(1)+uavpos(4);
            uavlon = uavpos(2)+uavpos(5);
            b = atan2d(sind(uavlon-uavpos(2))*cosd(uavlat),cosd(uavpos(1))*sind(uavlat)-sind(uavpos(1))*cosd(uavlat)*cos(uavlon-uavpos(2)));
            
            root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Procedure Add AsFirst SiteType Waypoint ProcedureType "Enroute"');
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/RQ5A_Hunter Procedure 1 SetValue ArriveOnHeading true %.4f deg',b));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/RQ5A_Hunter Site %.0f SetValue Latitude %f deg',1,uavpos(1)));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/RQ5A_Hunter Site %.0f SetValue Longitude %f deg',1,uavpos(2)));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/RQ5A_Hunter Procedure 1 SetValue RequestedAltitude false %.2f m',uavpos(3)+31));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/RQ5A_Hunter Procedure SetTime 1 "%s" UTCG',t));
            
            if pos(4) == 0 && pos(5) == 0
                root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Procedure Add AfterLast SiteType Waypoint ProcedureType "Holding - Circular"');
                root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Procedure 2 SetValue Range 0 km');
                root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Procedure 2 SetValue Diameter 1 km');
            else
                root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter Procedure Add AfterLast SiteType Waypoint ProcedureType "Enroute"');
            end
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/RQ5A_Hunter Site %.0f SetValue Latitude %f deg',2,targetlat));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/RQ5A_Hunter Site %.0f SetValue Longitude %f deg',2,targetlon));
            
            root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter ConfigureAll');
            root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter CalculateAll');
            root.ExecuteCommand('MissionModeler */Aircraft/RQ5A_Hunter SendNtfUpdate');
        end
        iter = iter+1;
    end
    
    if get(handles.ViewRoute,'Value') == 0
        root.ExecuteCommand('VO */Aircraft/RQ5A_Hunter Pass3D GroundLead None GroundTrail None');
    else
        root.ExecuteCommand('VO */Aircraft/RQ5A_Hunter Pass3D GroundLead All GroundTrail All');
    end   
    
    if get(handles.Origin,'Value') == 1
        set(handles.Origin,'Value',0)
        Olat = str2double(get(handles.LatBox,'String'));
        Olon = str2double(get(handles.LonBox,'String'));
        
        AWACSpositem = root.ExecuteCommand(sprintf('Position */Aircraft/E3A_Sentry "%s"',t));
        AWACSposstr = AWACSpositem.Item(0);
        AWACSpos = str2num(AWACSposstr);
        
        AWACSlat = AWACSpos(1)+AWACSpos(4);
        AWACSlon = AWACSpos(2)+AWACSpos(5);
        AWACSb = atan2d(sind(AWACSlon-AWACSpos(2))*cosd(AWACSlat),cosd(AWACSpos(1))*sind(AWACSlat)-sind(AWACSpos(1))*cosd(AWACSlat)*cos(AWACSlon-AWACSpos(2)));
        
        try
            root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry Procedure Remove 2');
        catch
            display('catch3') %First Iteration
        end
        root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry Procedure Remove 1');
        
        root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry Procedure Add AsFirst SiteType Waypoint ProcedureType "Enroute"');
        root.ExecuteCommand(sprintf('MissionModeler */Aircraft/E3A_Sentry Procedure 1 SetValue ArriveOnHeading true %.4f deg', AWACSb));
        root.ExecuteCommand(sprintf('MissionModeler */Aircraft/E3A_Sentry Site 1 SetValue Latitude %f deg', AWACSpos(1)));
        root.ExecuteCommand(sprintf('MissionModeler */Aircraft/E3A_Sentry Site 1 SetValue Longitude %f deg', AWACSpos(2)));
        root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry Procedure 1 SetValue RequestedAltitude false 30000 ft');
        root.ExecuteCommand(sprintf('MissionModeler */Aircraft/E3A_Sentry Procedure SetTime 1 "%s" UTCG', t));
        
        root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry Procedure Add AfterLast SiteType Waypoint ProcedureType "Holding - Figure-8"');
        root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry Procedure 2 SetValue Range 0 km');
        root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry Procedure 2 SetValue Width 50 km');
        root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry Procedure 2 SetValue Turns 10');
        root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry Procedure 2 SetValue RequestedAltitude false 30000 ft');
        root.ExecuteCommand(sprintf('MissionModeler */Aircraft/E3A_Sentry Site 2 SetValue Latitude %f deg' ,Olat));
        root.ExecuteCommand(sprintf('MissionModeler */Aircraft/E3A_Sentry Site 2 SetValue Longitude %f deg', Olon));
 
        root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry ConfigureAll');
        root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry CalculateAll');
        root.ExecuteCommand('MissionModeler */Aircraft/E3A_Sentry SendNtfUpdate');
        root.ExecuteCommand('VO */Aircraft/E3A_Sentry Model File "C:\Program Files (x86)\AGI\STK 10\STKData\VO\Models\Air\e-3a_sentry_awacs.mdl"');
    end
    
    
    % Record %%NEEDSWORK
    if get(handles.Record,'Value') == 1
        set(handles.Record,'Value',0)
        root.ExecuteCommand('SoftVTR3D * Record On FileFormat WMV OutputDir "C:\Users\Ian\Videos" Prefix Test')
        root.ExecuteCommand('SoftVTR3D * FrameRate 30');
    end
    if get(handles.StopRec,'Value') == 1
        set(handles.StopRec,'Value',0)
        root.ExecuteCommand('SoftVTR3D * Record Off')
    end
    
    pause(0.1) 
end

% --- Executes on selection change in AirportMenu.
function AirportMenu_Callback(hObject, eventdata, handles)
% hObject    handle to AirportMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AirportMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AirportMenu


% --- Executes during object creation, after setting all properties.
function AirportMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AirportMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PlayButton.
function PlayButton_Callback(hObject, eventdata, handles)
% hObject    handle to PlayButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PlayButton


% --- Executes on button press in PauseButton.
function PauseButton_Callback(hObject, eventdata, handles)
% hObject    handle to PauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PauseButton


% --------------------------------------------------------------------
function activex1_DblClick(hObject, eventdata, handles)
% hObject    handle to activex1 (see GCBO)
% eventdata  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)

display('click')
root.ExecuteCommand('Async3DPick * On')
info = handles.activex1.PickInfo(eventdata.X,eventdata.Y);
lat = info.lat
lon = info.lon
set(handles.text2,'String',lat)
set(handles.text3,'String',lon)


% lat = get(handles.text2,'String')
% lon = get(handles.text3,'String')
% set(handles.text4,'String',lat)
% set(handles.text5,'String',lon)

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
invoke(handles.activex1.Application,'ExecuteCommand','Unload / *');
delete(hObject);


% --------------------------------------------------------------------
function activex1_MouseMove(hObject, eventdata, handles)
% hObject    handle to activex1 (see GCBO)
% eventdata  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)
%info = handles.activex1.PickInfo(eventdata.X,eventdata.Y);
%lat = info.lat;
%lon = info.lon;
%set(handles.text2,'String',lat)
%set(handles.text3,'String',lon)


% --------------------------------------------------------------------
function activex1_Click(hObject, eventdata, handles)
% hObject    handle to activex1 (see GCBO)
% eventdata  structure with parameters passed to COM event listener
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in undo.
function undo_Callback(hObject, eventdata, handles)
% hObject    handle to undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in TargetMenu.
function TargetMenu_Callback(hObject, eventdata, handles)
% hObject    handle to TargetMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TargetMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TargetMenu


% --- Executes during object creation, after setting all properties.
function TargetMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TargetMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in DblClick.
function DblClick_Callback(hObject, eventdata, handles)
% hObject    handle to DblClick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DblClick


% --- Executes on button press in TrackV.
function TrackV_Callback(hObject, eventdata, handles)
% hObject    handle to TrackV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of TrackV


% --- Executes on button press in ViewRoute.
function ViewRoute_Callback(hObject, eventdata, handles)
% hObject    handle to ViewRoute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ViewRoute



function LatBox_Callback(hObject, eventdata, handles)
% hObject    handle to LatBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LatBox as text
%        str2double(get(hObject,'String')) returns contents of LatBox as a double


% --- Executes during object creation, after setting all properties.
function LatBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LatBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LonBox_Callback(hObject, eventdata, handles)
% hObject    handle to LonBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LonBox as text
%        str2double(get(hObject,'String')) returns contents of LonBox as a double


% --- Executes during object creation, after setting all properties.
function LonBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LonBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Origin.
function Origin_Callback(hObject, eventdata, handles)
% hObject    handle to Origin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Origin


% --- Executes on button press in Record.
function Record_Callback(hObject, eventdata, handles)
% hObject    handle to Record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Record


% --- Executes on button press in StopRec.
function StopRec_Callback(hObject, eventdata, handles)
% hObject    handle to StopRec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StopRec
