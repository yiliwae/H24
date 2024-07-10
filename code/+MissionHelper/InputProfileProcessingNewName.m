function [TimeEnd, dTime,PowerInput]=InputProfileProcessingNewName(PowerInput, timeStep)

diffTime=diff(PowerInput.Time_Seconds);


newTime= [min(PowerInput.Time_Seconds):timeStep:max(PowerInput.Time_Seconds)]';

% Find finite indices
finiteIndices = isfinite(PowerInput.Time_Seconds) & isfinite(PowerInput.Power_kW);

% Extract only finite values
finiteTime = PowerInput.Time_Seconds(finiteIndices);
finitePowerKW = PowerInput.Power_kW(finiteIndices);

Power_kW= interp1(finiteTime,finitePowerKW, newTime);

% create timeseries for the input data
PowerInput= timeseries(Power_kW,newTime);

TimeEnd = max(newTime);

% TimeEnd=30;
dTime   = timeStep; % unit: [s]

end