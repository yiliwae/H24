function  [TimeEnd, dTime,PowerInput, SOCstart,TimeThermalStable]=compileInputH24_NewProfiles(PowerProfile, InputProfile,InputPar)
% this script will process all the power profiles 
% check the profile is race or Quali

InputProfileName= InputProfile{:};

PowerInput= PowerProfile.(InputProfileName);

%% Manipulate the power profile to make it charge nutral
% find the end idx, 

% Check if the 'cutTime' field exists in the structure 'InputPar'
if isfield(InputPar, 'cutTime')
    % Find indices where Time_Seconds is greater than cutTime
    idxCut = PowerInput.Time_Seconds > InputPar.cutTime;
    
    % Remove the rows from PowerInput where the condition is met
    PowerInput(idxCut, :) = [];
end
%%
timeStep= InputPar.timeStep;

PowerInput.Power_kW=PowerInput.Power_kW*InputPar.Racelaps_PowerFudgeFactor;

% remove nan value
rowsWithNaN  = any(ismissing(PowerInput), 2);
PowerInput(rowsWithNaN, :) = [];


%%
if contains(InputProfileName, 'Quali')
    SimResults.folderName = InputProfileName;
    % [TimeEnd, dTime,PowerInput]=MissionHelper.InputProfileProcessingNewName(PowerInput,timeStep);

    SOCstart           = (0.93);
    InputPar.Racelaps=1;

    [TimeEnd, dTime,PowerInput,TimeThermalStable]=MissionHelper.CreateMultipleLapsNewName(PowerInput,InputPar,InputProfileName ); 


else contains(InputProfile, 'Race')
    SimResults.folderName = InputProfileName;
    
    SOCstart           = (0.4);
     InputPar.Racelaps=10;

     [TimeEnd, dTime,PowerInput,TimeThermalStable]=MissionHelper.CreateMultipleLapsNewName(PowerInput,InputPar,InputProfileName); 


%     PowerRaceTotal= [];
%     TimeEnd=0;
% 
%     figure('Color','w')
% plot(PowerRace.Time,-PowerRace.Power_kW,'-','DisplayName','Given profile')
% hold on 
% plot(PowerRace.Time(idxCut),-PowerRace.Power_kW(idxCut),'*','DisplayName','Removed')
% xlabel('Time [s]')
% ylabel('Power [kW]')
% grid on 
% legend show
% title('Power Race')
% 
% 
% 
%     figure()
%     for idxlaps= 1:InputPar.Racelaps
%         idxlaps;
%         patchedOneLap=[]; 
%         driveCyle=[];
%         restProfile=[];
%         raceTime=[];
% 
%         PowerRace= rmmissing(PowerRace);
%         raceTime= PowerRace.Time+TimeEnd;
%         Power= PowerRace.Power_kW;
%         % add the rest period between laps 
%         driveCyle= [raceTime, Power];
% 
%         restAfterLap = InputPar.Racelaps_RestBetweenLaps_s;
%         restTime = [raceTime(end)+1: raceTime(end)+restAfterLap]';
%         restPower= repmat(0, length(restTime),1);
%         restProfile=[restTime, restPower];
% 
%         patchedOneLap=[driveCyle; restProfile ];
% 
%         PowerRaceTotal=[PowerRaceTotal; patchedOneLap];
% 
%         TimeStart= patchedOneLap(1,1);
%         TimeEnd=  patchedOneLap(end,1)+0.01;
% 
%         plot(patchedOneLap(:,1), patchedOneLap(:,2))
%         hold on
%     end %    for idxlaps= 1:InputPar.Racelaps
%      title('Power Race')
%     PowerRaceTotal=array2table(PowerRaceTotal,"VariableNames",{'Time','Power_kW'} );
% 
%     [TimeEnd, dTime,PowerInput]=MissionHelper.InputProfileProcessing(PowerRaceTotal,timeStep);
% 
%     % get the time period of the thermal stablized period 
%     TimeThermalStable= max(PowerRace.Time)*(InputPar.Racelaps-InputPar.ThermalStableLaps);
% 
% 
% end



end