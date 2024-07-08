function [TimeEnd, dTime,PowerInput]=InputProfileProcessing(PowerInput, timeStep)

diffTime=diff(PowerInput.Time);


newTime= [min(PowerInput.Time):timeStep:max(PowerInput.Time)]';

% Find finite indices
finiteIndices = isfinite(PowerInput.Time) & isfinite(PowerInput.PowerKW);

% Extract only finite values
finiteTime = PowerInput.Time(finiteIndices);
finitePowerKW = PowerInput.PowerKW(finiteIndices);

PowerKW= interp1(finiteTime,finitePowerKW, newTime);

% create timeseries for the input data
PowerInput= timeseries(PowerKW,newTime);

TimeEnd = max(newTime);

% TimeEnd=30;
dTime   = timeStep; % unit: [s]

end