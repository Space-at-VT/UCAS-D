import win32com.client

# 1 -- launch or connect to existing STK
app = win32com.client.Dispatch('STK10.Application')
app.Visible = 1
app.UserControl = 1

root = app.Personality2
if root.CurrentScenario is None:
    root.NewScenario('PythonExample')
    scenario = root.CurrentScenario
else:
    root.CloseScenario()
    root.NewScenario('PythonExample')
    scenario = root.CurrentScenario

# 2 -- Create new scenario, facility, satellite and compute LOS(Access) animate to see events
startT = "5 Mar 2020 16:00:00.000"
stopT = "6 Mar 2020 16:00:00.000"
scenario.SetTimePeriod(startT, stopT)

fac = root.CurrentScenario.Children.New('8', 'Facility1')
fac.Position.AssignGeodetic(20, 50, 0)
sat = scenario.Children.New(18, 'Sat1')
root.ExecuteCommand('Propagate */Satellite/Sat1 UseScenarioInterval')

access = sat.GetAccessToObject(fac)
access.ComputeAccess()

root.ExecuteCommand('Animate * Reset')
root.ExecuteCommand('Animate * Start Loop')


# 3 -- Use Data Providers to write the access interval times
accessIntervalsCount = access.ComputedAccessIntervalTimes.Count
print(accessIntervalsCount)

dp = access.DataProviders["Access Data"]
if dp is not None:
    elems1 = ["Access Number","Start Time","Stop Time"]
    result = dp.ExecElements(startT, stopT, elems1)

    if result.DataSets.Count > 0:
        accnumList = []
        startTList = []
        stopTList = []

    for i in range(accessIntervalsCount):
                    accnumList.append(result.DataSets.GetDataSetByName('Access Number').GetValues()[i])
                    startTList.append(result.DataSets.GetDataSetByName('Start Time').GetValues()[i])
                    stopTList.append(result.DataSets.GetDataSetByName('Stop Time').GetValues()[i])

    for j in range(len(accnumList)):
        print(accnumList[j],"\t",startTList[j],"\t",stopTList[j])
