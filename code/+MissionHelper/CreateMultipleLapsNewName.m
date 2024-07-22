function  [TimeEnd, dTime,PowerInput,TimeThermalStable]= CreateMultipleLapsNewName(InputPowerProfile,InputPar,InputProfileName)

InputProfileName= strrep(InputProfileName, '_','-');
figure('Color','w')
plot(InputPowerProfile.Time_Seconds,InputPowerProfile.Power_kW,'-','DisplayName','Given profile')
hold on 
xlabel('Time (s)')
ylabel('Power (kW)')
grid on 
legend show
title(InputProfileName)

%%
TimeEnd=0;
InputPowerProfileTotal=[]; 

timeStep= InputPar.timeStep;
fig= figure('Color','w')
    for idxlaps= 1:InputPar.Racelaps
        idxlaps;
        patchedOneLap=[]; 
        driveCyle=[];
        restProfile=[];
        raceTime=[];

        InputPowerProfile= rmmissing(InputPowerProfile);
        raceTime= InputPowerProfile.Time_Seconds+TimeEnd;
        Power= InputPowerProfile.Power_kW;
        % add the rest period between laps 
        driveCyle= [raceTime, Power];

        restAfterLap = InputPar.Racelaps_RestBetweenLaps_s;
        restTime = [raceTime(end)+1: raceTime(end)+restAfterLap]';
        restPower= repmat(0, length(restTime),1);
        restProfile=[restTime, restPower];

        patchedOneLap=[driveCyle; restProfile ];

        InputPowerProfileTotal=[InputPowerProfileTotal; patchedOneLap];

        TimeStart= patchedOneLap(1,1);
        TimeEnd=  patchedOneLap(end,1)+0.01;

        plot(patchedOneLap(:,1), patchedOneLap(:,2))
        hold on
        grid on 
        xlabel('Time (s)')
        ylabel('Poewr (kW)')
    end %    for idxlaps= 1:InputPar.Racelaps
     title(InputProfileName)
    InputPowerProfileTotal=array2table(InputPowerProfileTotal,"VariableNames",{'Time_Seconds','Power_kW'} );
    
    [TimeEnd, dTime,PowerInput]=MissionHelper.InputProfileProcessingNewName(InputPowerProfileTotal,timeStep);

    % get the Time_Seconds period of the thermal stablized period 
      if  InputPar.Racelaps-InputPar.ThermalStableLaps>0 
         TimeThermalStable= max(InputPowerProfile.Time_Seconds)*(InputPar.Racelaps-InputPar.ThermalStableLaps);
 
    else
         TimeThermalStable= []; 
 
    end

% if contains(InputProfile, 'PowerQualification')
% FigName= "Quali"
% else
% end
%     saveFigDir= "02_SimOutput\PowerQualification\"
%     saveas(fig,saveFigDir)
  
end