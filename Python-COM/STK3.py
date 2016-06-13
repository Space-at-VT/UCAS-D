import win32com.client

# Launch STK
app = win32com.client.Dispatch('STK10.Application')
root = app.Personality2

if root.CurrentScenario is None:
    root.NewScenario('PythonExample')
    scenario = root.CurrentScenario
else:
    root.CloseScenario()
    root.NewScenario('PythonExample')
    scenario = root.CurrentScenario
app.Visible = 1
app.UserControl = 1

# Scenario
startT = "5 Mar 2020 16:00:00.000"
stopT = "6 Mar 2020 16:00:00.000"
scenario.SetTimePeriod(startT, stopT)
root.ExecuteCommand('Units_SetConnect / Date "EpochSeconds"')
root.ExecuteCommand('VO * EarthShapeModel MSL')
#root.ExecuteCommand('Terrain * Add Type PDTT File "C:\\Users\Ian\Documents\STK 10\Config\CentralBodies\Earth\GeoData\Bluefield.pdtt"')
#root.ExecuteCommand('VO * TerrainAndImagery Add File "C:\\Users\Ian\Documents\STK 10\Config\CentralBodies\Earth\GeoData\Bluefield.pdtt"')

# Create ground vehicle
vehicleName = 'Squad'
vehicle = scenario.Children.New(9, vehicleName)
root.ExecuteCommand('SetPropagator */GroundVehicle/%s GreatArc' % vehicleName)
root.ExecuteCommand('AltitudeRef */GroundVehicle/%s Ref MSL' % vehicleName)
root.ExecuteCommand('VO */GroundVehicle/%s Pass3D GroundLead None' % vehicleName)


# Import ground vehicle waypoint data
file = open('KentlandsVehicle.txt')
for line in file:
    Lat = line.split()[0]
    Lon = line.split()[1]
    root.ExecuteCommand('AddWaypoint */GroundVehicle/%s DetTimeAccFromVel %s %s 0.0 10' % (vehicleName, Lat, Lon))

# Create quadrotors
Name = 'Quad1'
RunwayLat = 37.19715
RunwayLon = -80.57808
RunwayHeading = 0

aircraft = scenario.Children.New(1, Name)
root.ExecuteCommand('SetPropagator */Aircraft/%s MissionModeler' % Name)
root.ExecuteCommand('MissionModeler */Aircraft/%s Aircraft Choose "CyberQuad"' % Name)
root.ExecuteCommand('UseTerrain */Aircraft/%s On' % Name)

root.ExecuteCommand('MissionModeler */Aircraft/%s Procedure Add AsFirst SiteType Waypoint ProcedureType \
                    "Holding - Racetrack"' % Name)
root.ExecuteCommand('MissionModeler */Aircraft/%s Procedure SetTime 1 "0" EpSec' % Name)
root.ExecuteCommand('MissionModeler */Aircraft/%s Procedure 1 SetValue Range 0 ft' % Name)
root.ExecuteCommand('MissionModeler */Aircraft/%s Procedure 1 SetValue Width 20 ft' % Name)
root.ExecuteCommand('MissionModeler */Aircraft/%s Procedure 1 SetValue Length 40 ft' % Name)
root.ExecuteCommand('MissionModeler */Aircraft/%s Procedure 1 SetValue Turns 10' % Name)
root.ExecuteCommand('MissionModeler */Aircraft/%s Procedure 1 SetValue RequestedAltitude False 50 ft' % Name)

root.ExecuteCommand('MissionModeler */Aircraft/%s Site 1 SetValue Latitude %f deg' % (Name, RunwayLat))
root.ExecuteCommand('MissionModeler */Aircraft/%s Site 1 SetValue Longitude %f deg' % (Name, RunwayLon))

root.ExecuteCommand('MissionModeler */Aircraft/%s ConfigureAll' % Name)
root.ExecuteCommand('MissionModeler */Aircraft/%s CalculateAll' % Name)
root.ExecuteCommand('MissionModeler */Aircraft/%s SendNtfUpdate' % Name)

# Compute AER
root.ExecuteCommand('AER */Aircraft/%s */GroundVehicle/%s TimePeriod UseScenarioInterval' % (Name, vehicleName))
access = aircraft.GetAccessToObject(vehicle)

# VO settings
root.ExecuteCommand('VO * View FromTo FromRegName "STK Object" FromName "Aircraft/%s" ToRegName "STK Object" ToName  \
                    "Aircraft/%s" WindowID 1' % (Name, Name))
root.ExecuteCommand('SetAnimation * AnimationMode xRealTime')
root.ExecuteCommand('Animate * Reset')

# Get data providers
elements = ["Range", "Azimuth", "Time"]
AERDP = access.DataProviders["AER Data"].Group.Item('BodyFixed').ExecElements(startT, stopT, 10, elements)
rangeSet = AERDP.DataSets.GetDataSetByName('Range')
azimuthSet = AERDP.DataSets.GetDataSetByName('Azimuth')
timeSet = AERDP.DataSets.GetDataSetByName('Time')

# Display AER data
for i in range(rangeSet.Count):
    print(timeSet.GetValues()[i], "\t", '%4.2f km' % rangeSet.GetValues()[i], "\t", '%6.2f deg' % azimuthSet.GetValues()[i])
