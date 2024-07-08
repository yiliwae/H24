function InputTimeseries=formTimeseriesData(time,InputValue, timeStep)

diffTime=diff(time);


newTime= [min(time):timeStep:max(time)]';

% Find finite indices
finiteIndices = isfinite(time) & isfinite(InputValue);

% Extract only finite values
finiteTime = time(finiteIndices);
finiteValue = InputValue(finiteIndices);

newValue= interp1(finiteTime,finiteValue, newTime);

% create timeseries for the input data
InputTimeseries= timeseries(newValue,newTime);


end