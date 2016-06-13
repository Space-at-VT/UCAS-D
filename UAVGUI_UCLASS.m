function UAVGUI_UCLASS()
% UAVGUI_UCLASS is an interface designed to allow a user to easily load STK
% scenarios to simulate UAV performance within. A scenario must be created
% in the desktop application of STK with targets and other objects of
% interest. The scenario is then loaded within the GUI using STKX and the
% user inputs data regarding the UAV's desired targets and initial
% parameters. (6/9/2016)
% Objectives implemented:
%   -Simulation of cyber-attack degradation on UAV performance
%   -Rapid, iterative generation of scenarios with varying degradation
%   -Data export and post-processing ability
% Future objectives:
%   -More simulated cyber attacks. More specific and complex.
%   -Large scale monte carlo simulations of multiple cyber attacks
%   simulataneously
clear,close all

% Interface Colors
gray = [0.8 0.8 0.8];
light = [0.9 0.9 0.9];
dark = [0.1 0.1 0.1];
hurt = [0.8 0.2 0.2];
ready = [0.0 0.9 0.3];

% Initialize GUI object & handles
hObject = figure;
handles = guidata(hObject);

set(hObject,'Name','UAV Performance Modeler',...
    'Tag','Main',...
    'Position',[50 50 1250 600],... 
    'NumberTitle','off',...
    'Color',gray,...
    'Resize','off',...
    'Menubar','None');
STKX = actxcontrol('STKX10.VOControl.1');
STKX.move([250 0 1000 600]);

% Build GUI objects
uicontrol('Style','Text',...
    'String','UAV Performance Modeler',...
    'Position',[0 550 250 40],...
    'FontSize',14,...
    'BackgroundColor',gray,...
    'ForegroundColor',dark)

Spanel = uipanel('Title','Scenario',...
    'Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 450 230 100],...
    'BackgroundColor',gray);
uicontrol('Parent',Spanel,...
    'String','Open',...
    'Position',[10 40 75 30],...
    'Callback',{@OpenSTK},...
    'FontSize',12);
uicontrol('Parent',Spanel,...
    'String','Load',...
    'Position',[85 40 75 30],...
    'Callback',{@LoadSTK},...
    'FontSize',12);
handles.FileLocation = uicontrol('Parent',Spanel,...
    'Style','Edit',...
    'String','',...
    'Position',[10 10 200 30],...
    'FontSize',10);

Apanel = uipanel('Title','Aircraft',...
    'Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 350 230 100],...
    'BackgroundColor',gray);
uicontrol('Parent',Apanel,...
    'String','Load',...
    'Position',[10 40 75 30],...
    'FontSize',12);
uicontrol('Parent',Apanel,...
    'String','Save',...
    'Position',[10 10 75 30],...
    'FontSize',12);
uicontrol('Parent',Apanel,...
    'String','Accel.',...
    'Position',[100 55 60 25],...
    'FontSize',10,...
    'Callback',{@AccelInput});
uicontrol('Parent',Apanel,...
    'String','Climb',...
    'Position',[100 30 60 25],...
    'FontSize',10,...
    'Callback',{@ClimbInput});
uicontrol('Parent',Apanel,...
    'String','Cruise',...
    'Position',[100 5 60 25],...
    'FontSize',10,...
    'Callback',{@CruiseInput});
uicontrol('Parent',Apanel,...
    'String','Descent',...
    'Position',[160 55 60 25],...
    'FontSize',10,...
    'Callback',{@DescentInput});
uicontrol('Parent',Apanel,...
    'String','Landing',...
    'Position',[160 30 60 25],...
    'FontSize',10,...
    'Callback',{@LandingInput});
uicontrol('Parent',Apanel,...
    'String','Takeoff',...
    'Position',[160 5 60 25],...
    'FontSize',10,...
    'Callback',{@TakeoffInput});

Mpanel = uipanel('Title','Mission',...
    'Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 100 230 250],...
    'BackgroundColor',gray);
uicontrol('Parent',Mpanel,...
    'String','Choose Targets',...
    'Position',[10 190 150 30],...
    'FontSize',12,...
    'Callback',{@TargetCallback});
uicontrol('Parent',Mpanel,...
    'String','UAV Initialization',...
    'Position',[10 160 150 30],...
    'FontSize',12,...
    'Callback',{@UAV_Init});
uicontrol('Parent',Mpanel,...
    'Style','Text',...
    'String','Mission Capability',...
    'Position',[30 110 75 40],...
    'FontSize',10,...
    'BackgroundColor',gray,...
    'ForegroundColor',dark)
uicontrol('Parent',Mpanel,...
    'Style','Text',...
    'String','Fight Ready',...
    'Position',[30 90 75 20],...
    'FontSize',10,...
    'BackgroundColor',ready,...
    'ForegroundColor',dark)
uicontrol('Parent',Mpanel,...
    'Style','Text',...
    'String','Fight Hurt',...
    'Position',[30 65 75 20],...
    'FontSize',10,...
    'BackgroundColor',hurt,...
    'ForegroundColor',dark)
uicontrol('Parent',Mpanel,...
    'Style','Text',...
    'String','Fight Alone',...
    'Position',[30 40 75 20],...
    'FontSize',10,...
    'BackgroundColor',light,...
    'ForegroundColor',dark)
uicontrol('Parent',Mpanel,...
    'Style','Text',...
    'String','Get Home',...
    'Position',[30 15 75 20],...
    'FontSize',10,...
    'BackgroundColor',light,...
    'ForegroundColor',dark)

uicontrol('Parent',Mpanel,...
    'Style','Text',...
    'String','CYBERSAFE Grade',...
    'Position',[120 110 80 40],...
    'FontSize',10,...
    'BackgroundColor',gray,...
    'ForegroundColor',dark)
uicontrol('Parent',Mpanel,...
    'Style','Text',...
    'String','Mission Critical',...
    'Position',[120 70 75 40],...
    'FontSize',10,...
    'BackgroundColor',light,...
    'ForegroundColor',dark)
uicontrol('Parent',Mpanel,...
    'Style','Text',...
    'String','Mission Essential',...
    'Position',[120 20 75 40],...
    'FontSize',10,...
    'BackgroundColor',light,...
    'ForegroundColor',dark)

Rpanel = uipanel('Title','Analysis',...
    'Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 230 80],...
    'BackgroundColor',gray);
uicontrol('Parent',Rpanel,...
    'String','Run',...
    'Position',[10 20 75 30],...
    'Callback',{@RunSTK},...
    'FontSize',12);
handles.Save = uicontrol('Parent',Rpanel,...
    'String','Save',...
    'Position',[85 20 75 30],...
    'FontSize',12);

uicontrol('String','Reset',...
    'Position',[925 550 75 30],...
    'Callback',{@ResetSTK},...
    'FontSize',12);
uicontrol('String','Play',...
    'Position',[1000 550 75 30],...
    'Callback',{@PlaySTK},...
    'FontSize',12);
uicontrol('String','Pause',...
    'Position',[1075 550 75 30],...
    'Callback',{@PauseSTK},...
    'FontSize',12);
uicontrol('String','<<',...
    'Position',[1150 550 37.5 30],...
    'Callback',{@SlowerSTK},...
    'FontSize',12);
uicontrol('String','>>',...
    'Position',[1187.5 550 37.5 30],...
    'Callback',{@FasterSTK},...
    'FontSize',12);

guidata(hObject,handles)
end

% Mission Analysis
function RunSTK(hObject,callbackdata)
handles = guidata(hObject);
root = handles.root;
scenario = root.CurrentScenario;

% Aircraft name
Name = 'X47';

% Remove lingering data
try root.ExecuteCommand(sprintf('Unload / */Aircraft/%s',Name));end

% Pull position data for all target objects
NumObjs = length(handles.Targets);
ObjectStr = root.ExecuteCommand('AllInstanceNames /');
Objects = strsplit(ObjectStr.Item(0));
j = 0;
for i = 1:NumObjs
    if handles.Targets(i);
        j = j+1;
        TargetObj{j} = Objects{i+2};
        PosStr = root.ExecuteCommand(sprintf('Position */%s',TargetObj{j}));
        Pos = str2num(PosStr.Item(0));
        tLat(j) = Pos(1);
        tLon(j) = Pos(2);
        tAlt(j) = Pos(3);
    end
end
NumTargets = j;

% Initial user-defined position
Lat = handles.Initial.Lat;
Lon = handles.Initial.Lon;
Alt = handles.Initial.Alt;
Heading = handles.Initial.Head;

% Develop mission path (nearest neighbor)
for i = 1:NumTargets
    R = [];
    if i == 1
        for j = 1:length(tLat)
            [~,~,R(j)] = AER([Lat,Lon],[tLat(j),tLon(j)]);
        end
    else
        for j = 1:length(tLat)
           [~,~,R(j)] = AER([tLatnew(i-1),tLatnew(i-1)],[tLat(j),tLon(j)]);
        end
    end
    [~,Cut] = min(R);
    tLatnew(i) = tLat(Cut);
    tLonnew(i) = tLon(Cut);
    tLat(Cut) = [];
    tLon(Cut) = [];
end
tLat = tLatnew;
tLon = tLonnew;

% Simulate degradations and loop
DataDisplay = 1;
Degradation = {'Thrust','Maneuverability','Sensor Accuracy'};
for DegCase = 1:3

    D = linspace(0,1);
    iter = 1;
    while iter <= length(D)    
        
        % Create UAV
        try root.ExecuteCommand(sprintf('Unload / */Aircraft/%s',Name));end
        aircraft = scenario.Children.New('eAircraft',Name);
        root.ExecuteCommand(sprintf('SetPropagator */Aircraft/%s MissionModeler',Name));
        
        % Create performance model
        try root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Aircraft Remove "X-47b"',Name));end
        root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Aircraft Copy "Basic Fighter" X-47b',Name));
        root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Aircraft Choose X-47b',Name));
        modelPath = 'C:\Users\Ian\Documents\STK 10\x-47b\X47B_UCAV_Cert_v48.mdl';
        root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Aircraft SetValue Model3D "%s"',Name,modelPath));
        root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Aircraft SetValue Speeds %f nm/hr 50000 ft/min 865 nm/hr 865 nm/hr',Name,600));
        
        % Degrade performance
        if DegCase == 1
            try
                V = (1-D(iter))*600;
                root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Aircraft SetValue Speeds %f nm/hr 50000 ft/min 865 nm/hr 865 nm/hr',Name,V));
            catch
                D = D(1:iter-1);
                break
            end
        elseif DegCase == 2;
            try
                n = (1-D(iter))*3;
                root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Aircraft SetValue LoadFactorG %f',Name,n));
            catch
                D = D(1:iter-1);
                break
            end
        end
        
        % Mission Modeler waypoints
        if Alt == 0
            Type = 'Runway';
        else
            Type = 'Waypoint';
        end
        CruiseAlt = 10000;
        
        if strcmp(Type,'Runway') == 1
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure Add AsFirst SiteType Runway ProcedureType "Takeoff"',Name));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure SetTime 1 "0" EpSec',Name));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure 1 SetValue RunwayAltitudeOffset %f ft',Name,0));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure 1 SetValue UseRwyHighEnd True',Name));
            
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site 1 SetValue Latitude %f deg',Name,Lat));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site 1 SetValue Longitude %f deg',Name,Lon));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site 1 SetValue Heading %f deg False',Name,Heading));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site 1 SetValue Length 51 ft',Name));
        else
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure Add AsFirst SiteType Waypoint ProcedureType "Enroute"',Name));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure 1 SetValue ArriveOnHeading true %f deg',Name,Heading));
            
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site 1 SetValue Latitude %f deg',Name,Lat));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site 1 SetValue Longitude %f deg',Name,Lon));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure 1 SetValue RequestedAltitude false %f ft',Name,Alt));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure SetTime 1 "0" EpSec',Name));
        end

        if DegCase == 3;
            if iter == 1;
                for k = 1:NumTargets
                    root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure Add AfterLast SiteType Waypoint ProcedureType "Enroute"',Name));
                    root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site %d SetValue Latitude %f deg',Name,k+1,tLat(k)));
                    root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site %d SetValue Longitude %f deg',Name,k+1,tLon(k)));
                    root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure %d SetValue RequestedAltitude false %f ft',Name,k+1,CruiseAlt));
                end
                
            else
                Count = 2;
                for k = 1:NumTargets
                    root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure Add AfterLast SiteType Waypoint ProcedureType "Enroute"',Name));
                    root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site %d SetValue Latitude %f deg',Name,Count,D(iter)*(2*rand-1)+tLat(k)));
                    root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site %d SetValue Longitude %f deg',Name,Count,D(iter)*(2*rand-1)+tLon(k)));
                    root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure %d SetValue RequestedAltitude false %f ft',Name,Count,CruiseAlt));
                    
                    root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure Add AfterLast SiteType Waypoint ProcedureType "Enroute"',Name));
                    root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site %d SetValue Latitude %f deg',Name,Count+1,tLat(k)));
                    root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site %d SetValue Longitude %f deg',Name,Count+1,tLon(k)));
                    root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure %d SetValue RequestedAltitude false %f ft',Name,Count+1,CruiseAlt));
                    Count = Count+2;
                end
            end
        else
            for k = 1:NumTargets
                root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure Add AfterLast SiteType Waypoint ProcedureType "Enroute"',Name));
                root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site %d SetValue Latitude %f deg',Name,k+1,tLat(k)));
                root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site %d SetValue Longitude %f deg',Name,k+1,tLon(k)));
                root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure %d SetValue RequestedAltitude false %f ft',Name,k+1,CruiseAlt));
            end
        end
        
        % Final waypoint, return to start
        if strcmp(Type,'Runway') == 1
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure Add AfterLast SiteType Runway ProcedureType "Landing"',Name));
            Count = root.ExecuteCommand(sprintf('MissionModeler_RM */Aircraft/%s GetProcedureCount',Name));
            Count = str2double(Count.Item(0));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure %d SetValue RunwayAltitudeOffset %f ft',Name,Count,Alt));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure %d SetValue UseRwyHighEnd True',Name,Count)); 
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site %d SetValue Latitude %f deg',Name,Count,Lat));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site %d SetValue Longitude %f deg',Name,Count,Lon));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site %d SetValue Heading %f deg False',Name,Count,Heading));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site %d SetValue Length 51 ft',Name,Count));        
        else            
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure Add AfterLast SiteType Waypoint ProcedureType "Enroute"',Name));
            Count = root.ExecuteCommand(sprintf('MissionModeler_RM */Aircraft/%s GetProcedureCount',Name));
            Count = str2double(Count.Item(0));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site %d SetValue Latitude %f deg',Name,Count,Lat));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Site %d SetValue Longitude %f deg',Name,Count,Lon));
            root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s Procedure %d SetValue RequestedAltitude false %f ft',Name,Count,CruiseAlt));
        end
        
        % Configure and update Mission Modeler
        root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s ConfigureAll',Name));
        root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s CalculateAll',Name));
        root.ExecuteCommand(sprintf('MissionModeler */Aircraft/%s SendNtfUpdate',Name));
        
        % Export fuel data from data STK data provider
        ScenarioTime = scenario.StopTime;
        FuelDP = aircraft.DataProviders.Item('Flight Profile By Time').Exec(scenario.StartTime,scenario.StopTime,ScenarioTime);
        FuelCell = FuelDP.DataSets.GetDataSetByName('FuelConsumed').GetValues;
        Fuel(iter) = FuelCell{end};
        
        % Time data
        TimeDP = aircraft.DataProviders.Item('Flight Profile By Time').Exec(scenario.StartTime,scenario.StopTime,ScenarioTime);
        TimeCell = TimeDP.DataSets.GetDataSetByName('Time').GetValues;
        Time(iter) = TimeCell{end};
        
        % Fuel constraint
        if Fuel(iter) > 25000, break; end
            
        if DataDisplay
            figure(2)
            hold on
            plot(D(iter),Fuel(iter),'xb','linewidth',2)
            xlabel('Degradation')
            ylabel('Fuel Used, lb')
            grid on
            
            figure(3)
            hold on
            plot(D(iter),Time(iter),'xr','linewidth',2)
            xlabel('Degradation')
            ylabel('Mission Time, sec')
            grid on
            
        end
        
        pause(1e-6)
        iter = iter+1;
    end
    
    % Save option
    if get(handles.Save,'Value') == 1   
        Timestr = datestr(now,'mmdd_HHMMSS');
        Filestr = sprintf('Data%s.mat',Timestr);
        DegType = Degradation{iter};
        save(Filestr,'D','Fuel','DegType')
    end
end

% Zoom graphics to scenario and UAV
root.ExecuteCommand(sprintf('Graphics */Aircraft/%s SetColor yellow',Name));
root.ExecuteCommand(sprintf('UseTerrain */Aircraft/%s On',Name));
%root.ExecuteCommand(sprintf('VO */Aircraft/%s Pass3D GroundLead None GroundTrail None',name));
root.ExecuteCommand(sprintf('VO */Aircraft/%s DynDataText DataDisplay "Velocity Heading" Show On Color Yellow',Name));
root.ExecuteCommand(sprintf('VO */Aircraft/%s EphemDropLines Type Terrain Show On Interval 30 Color Yellow',Name));
root.ExecuteCommand(sprintf('VO * View FromTo FromRegName "STK Object" FromName "Aircraft/%s" ToRegName "STK Object" ToName "Aircraft/%s" WindowID 1',Name,Name));
root.ExecuteCommand('VO * ViewerPosition 30 0 100');
end

% Choose STK scenario file
function OpenSTK(hObject,callbackdata)
handles = guidata(hObject);
[file,path] = uigetfile('*.sc');
filepath = strcat(path,file);
set(handles.FileLocation,'String',filepath);
guidata(hObject,handles)
end

% Load STK scenario file into GUI and STKX
function LoadSTK(hObject,callbackdata)
handles = guidata(hObject);

try
    root = actxGetRunningServer('AgStkObjects10.AgStkObjectRoot');
catch
    root = actxserver('AgStkObjects10.AgStkObjectRoot');
end

filepath = get(handles.FileLocation,'String');
try
    root.ExecuteCommand(sprintf('Load / Scenario "%s"',filepath));
catch
    root.CloseScenario;
    root.ExecuteCommand(sprintf('Load / Scenario "%s"',filepath));
end

root.ExecuteCommand('Units_SetConnect / Date "EpochSeconds"');
root.ExecuteCommand('VO * EarthShapeModel MSL');
root.UnitPreferences.Item('DateFormat').SetCurrentUnit('EpSec');
root.AnimationOptions = 'eAniOptionStop';
root.Mode = 'eAniXRealtime';
root.ExecuteCommand('Animate * Reset');

handles.root = root;
guidata(hObject,handles)
end

% Azimuth,Elevation, & Range calculations
function [A,E,R] = AER(C1,C2)
% Azimuth
A = atan2d(sind(C2(2)-C1(2))*cosd(C2(1)),...
    cosd(C1(1))*sind(C2(1))-sind(C1(1))*cosd(C2(1))*cosd(C2(2)-C1(2)));
% Elevation
if length(C1) == 3
    E = C2(3)-C1(3);
else
    E = 0;
end
% Range
re = 6378e3;
a = sind((C2(1)-C1(1))/2)^2+cosd(C1(1))*cosd(C2(1))*sind((C2(2)-C1(2))/2)^2;
c = 2*atan2(sqrt(a),sqrt(1-a));
R = re*c;
end

% VO Controls - Play animation
function PlaySTK(hObject,callbackdata)
handles = guidata(hObject);
root = handles.root;
root.ExecuteCommand('Animate * Start');
end

% VO Controls - Pause animation
function PauseSTK(hObject,callbackdata)
handles = guidata(hObject);
root = handles.root;
root.ExecuteCommand('Animate * Pause');
end

% VO Controls - Reset animation
function ResetSTK(hObject,callbackdata)
handles = guidata(hObject);
root = handles.root;
root.ExecuteCommand('Animate * Reset');
end

% VO Controls - Speed up animation
function FasterSTK(hObject,callbackdata)
handles = guidata(hObject);
root = handles.root;
root.ExecuteCommand('Animate * Faster');
end

% VO Controls - Slow down  animation
function SlowerSTK(hObject,callbackdata)
handles = guidata(hObject);
root = handles.root;
root.ExecuteCommand('Animate * Slower');
end

% Mission Modeler aircraft specification inputs
function CruiseInput(hObject,callbackdata)
hfig_spec = figure;
set(hfig_spec,'Name','Cruise Configuration',...
    'Position',[50 50 500 400],... 
    'NumberTitle','off',...
    'Resize','off',...
    'Menubar','None');

Cruise = actxcontrol('AgUiFlight10.AgUiFlightCruise.1');
Cruise.move([0 0 500 400]);
end

function AccelInput(hObject,callbackdata)
hfig_spec = figure;
set(hfig_spec,'Name','Cruise Configuration',...
    'Position',[50 50 600 400],... 
    'NumberTitle','off',...
    'Resize','off',...
    'Menubar','None');
Cruise = actxcontrol('AgUiFlight10.AgUiFlightAcceleration.1');
Cruise.move([0 0 600 400]);
end

function ClimbInput(hObject,callbackdata)
hfig_spec = figure;
set(hfig_spec,'Name','Cruise Configuration',...
    'Position',[50 50 500 400],... 
    'NumberTitle','off',...
    'Resize','off',...
    'Menubar','None');

Cruise = actxcontrol('AgUiFlight10.AgUiFlightClimbBasic.1');
Cruise.move([0 0 500 400]);
end

function TakeoffInput(hObject,callbackdata)
hfig_spec = figure;
set(hfig_spec,'Name','Cruise Configuration',...
    'Position',[50 50 500 400],... 
    'NumberTitle','off',...
    'Resize','off',...
    'Menubar','None');

Cruise = actxcontrol('AgUiFlight10.AgUiFlightTakeoff.1');
Cruise.move([0 0 500 400]);
end

function LandingInput(hObject,callbackdata)
hfig_spec = figure;
set(hfig_spec,'Name','Cruise Configuration',...
    'Position',[50 50 600 400],... 
    'NumberTitle','off',...
    'Resize','off',...
    'Menubar','None');
Cruise = actxcontrol('AgUiFlight10.AgUiFlightLand.1');
Cruise.move([0 0 600 400]);
end

function DescentInput(hObject,callbackdata)
hfig_spec = figure;
set(hfig_spec,'Name','Cruise Configuration',...
    'Position',[50 50 500 400],... 
    'NumberTitle','off',...
    'Resize','off',...
    'Menubar','None');

Cruise = actxcontrol('AgUiFlight10.AgUiFlightDescentBasic.1');
Cruise.move([0 0 500 400]);
end

% Target objects pop-up window 
function TargetCallback(hObject,callbackdata)
handles = guidata(hObject);
root = handles.root;

d = dialog('Name','Objects');

try root.ExecuteCommand('Unload / */Aircraft/X47');end
ObjectStr = root.ExecuteCommand('AllInstanceNames /');
Objects = strsplit(ObjectStr.Item(0));

for i = 3:(length(Objects)-1)
    Path = strsplit(Objects{i},'/');
    Type{i-2} = Path{end-1};
    ObjName{i-2} = Path{end};
end
NumObj = length(ObjName);
Data = {0};
for j = 1:NumObj
    Data{j,1} = ObjName{j};
    Data{j,2} = Type{j};
    Data{j,3} = false;
end

columnname = {'Object','Type','Target'};
columnformat = {'char','char','logical'};
t = uitable('Parent',d,...
    'Data',Data,...
    'ColumnName',columnname,...
    'ColumnFormat',columnformat,...
    'ColumnEditable',[false false true],...
    'ColumnWidth',{100 75 50},...
    'RowName',[]);
tsize = get(t,'Extent');
w = tsize(3)+100;
h = tsize(4)+120;
set(t,'Position',[50 75 tsize(3) tsize(4)]);
set(d,'Position',[200 200 w h]);

uicontrol('Parent',d,...
    'Style','text',...
    'Position',[(w/2)-105 tsize(4)+80 210 20],...
    'String','Select target objects');
uicontrol('Parent',d,...
    'Position',[(w/2-35) 25 70 25],...
    'String','Save',...
    'Callback',@CloseCallback);

uiwait(d)

    function CloseCallback(popup,callbackdata)
        Input = get(t,'Data');
        for k = 1:size(Input,1)
            Targets(k) = Input{k,3};
        end
        delete(gcf)
    end

handles.Targets = Targets;
guidata(hObject,handles);
end

% Input dialog of intial UAV position
function UAV_Init (hObject,callbackdata)
handles = guidata(hObject);

title = 'UAV Initial Potiton';
prompt = {'Latitude (deg):','Longitude (deg):','Altitude (ft):','Heading (deg):'};
def = {'0','0','0','0'};
answer = inputdlg(prompt,title,1,def);

handles.Initial.Lat = str2double(answer{1});
handles.Initial.Lon = str2double(answer{2});
handles.Initial.Alt = str2double(answer{3});
handles.Initial.Head = str2double(answer{4});
guidata(hObject,handles)
end