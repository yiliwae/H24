function [TimeEnd, dTime,CurrentInput]=InputProfileToTimeseries(inputTime, inputSignal, timeStep)

diffTime=diff(inputTime);


newTime= [min(inputTime):timeStep:max(inputTime)]';

% Find finite indices
finiteIndices = isfinite(inputTime) & isfinite(inputSignal);

% Extract only finite values
finiteTime = inputTime(finiteIndices);
finiteInputSignal = inputSignal(finiteIndices);

InputSignal= interp1(finiteTime,finiteInputSignal, newTime);

% create timeseries for the input data
CurrentInput= timeseries(InputSignal,newTime);

TimeEnd = max(newTime);

% TimeEnd=30;
dTime   = timeStep; % unit: [s]

end