function [TimeEnd, dTime,CurrentInput]=InputProfileProcessingCurrentBased(CurrentInput, timeStep)

diffTime=diff(CurrentInput.Time);


newTime= [min(CurrentInput.Time):timeStep:max(CurrentInput.Time)]';

% Find finite indices
finiteIndices = isfinite(CurrentInput.Time) & isfinite(CurrentInput.CurrentA);

% Extract only finite values
finiteTime = CurrentInput.Time(finiteIndices);
finiteCurrentA = CurrentInput.CurrentA(finiteIndices);

CurrentA= interp1(finiteTime,finiteCurrentA, newTime);

% create timeseries for the input data
CurrentInput= timeseries(CurrentA,newTime);

TimeEnd = max(newTime);

% TimeEnd=30;
dTime   = timeStep; % unit: [s]

end