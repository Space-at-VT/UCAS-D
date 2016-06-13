import win32com.client

# 1 -- launch or connect to existing STK
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

# 2 -- Create new scenario, facility, satellite and compute LOS(Access) animate to see events
startT = "5 Mar 2020 16:00:00.000"
stopT = "6 Mar 2020 16:00:00.000"
scenario.SetTimePeriod(startT, stopT)
root.ExecuteCommand('Units_SetConnect / Date "EpochSeconds"')
root.ExecuteCommand('VO * EarthShapeModel MSL')
root.ExecuteCommand('Terrain * Add Type PDTT File "C:\\Users\Ian\Documents\STK 10\Config\CentralBodies\Earth\GeoData\Bluefield.pdtt"')
root.ExecuteCommand('VO * TerrainAndImagery Add File "C:\\Users\Ian\Documents\STK 10\Config\CentralBodies\Earth\GeoData\Bluefield.pdtt"')


Name = 'PythonUAV'
RunwayLat = 37.207603
RunwayLon = -80.407722
RunwayHeading = 117.25


aircraft = scenario.Children.New(1, Name)
root.ExecuteCommand('SetPropagator */Aircraft/%s MissionModeler' % Name)
root.ExecuteCommand('MissionModeler */Aircraft/%s Aircraft Choose "Basic UAV"' % Name)

root.ExecuteCommand('MissionModeler */Aircraft/%s Procedure Add AsFirst SiteType Runway ProcedureType "Takeoff"' % Name)
root.ExecuteCommand('MissionModeler */Aircraft/%s Procedure SetTime 1 "0" EpSec' % Name)
root.ExecuteCommand('MissionModeler */Aircraft/%s Procedure 1 SetValue RunwayAltitudeOffset 5 ft' % Name)
root.ExecuteCommand('MissionModeler */Aircraft/%s Procedure 1 SetValue UseRwyHighEnd True' % Name)
root.ExecuteCommand('MissionModeler */Aircraft/%s Procedure 1 SetValue DeparturePointRange 2000 ft' % Name)
root.ExecuteCommand('MissionModeler */Aircraft/%s Procedure 1 SetValue UseRunwayTerrain True' % Name)

root.ExecuteCommand('MissionModeler */Aircraft/%s Site 1 SetValue Latitude %f deg' % (Name, RunwayLat))
root.ExecuteCommand('MissionModeler */Aircraft/%s Site 1 SetValue Longitude %f deg' % (Name, RunwayLon))
root.ExecuteCommand('MissionModeler */Aircraft/%s Site 1 SetValue Heading %f deg False' % (Name, RunwayHeading))
root.ExecuteCommand('MissionModeler */Aircraft/%s Site 1 SetValue Length 4000 ft' % Name)

root.ExecuteCommand('MissionModeler */Aircraft/%s ConfigureAll' % Name)
root.ExecuteCommand('MissionModeler */Aircraft/%s CalculateAll' % Name)
root.ExecuteCommand('MissionModeler */Aircraft/%s SendNtfUpdate' % Name)

root.ExecuteCommand('VO * View FromTo FromRegName "STK Object" FromName "Aircraft/%s" ToRegName "STK Object" ToName "Aircraft/%s" WindowID 1' % (Name, Name))

root.ExecuteCommand('SetAnimation * AnimationMode xRealTime')
root.ExecuteCommand('Animate * Reset')

flightDP = aircraft.DataProviders["Flight Profile By Time"].Exec(startT,stopT,1)
fuelSet = flightDP.DataSets.GetDataSetByName('FuelConsumed')
timeSet = flightDP.DataSets.GetDataSetByName('Time')

for i in range(fuelSet.Count):
    print(timeSet.GetValues()[i], "\t", '%.2f lbs' % fuelSet.GetValues()[i])

