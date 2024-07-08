function [responsibleSignal] = findStopReason(stopSignals)
%FINDSTOPREASON Find signal(s) responsible for the simulation stop
%   Input = Struct of StopSignals_Ms;
%   Output = Responsible signal name

% get name of signals being output
signals = fieldnames(stopSignals);

responsibleSignal = [];

for i = 1:length(signals)
    % sum all the data in the output signal
    
    if sum(stopSignals.(signals{i}).Data)
        responsibleSignal = [responsibleSignal string(signals{i})]; %#ok<AGROW> 
    end
    
end


if isempty(responsibleSignal) == 1
    responsibleSignal = [];
    warning("no responsible stop signal was found, did the simulation end prematurely?")
end
