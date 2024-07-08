function  [TimeEnd, dTime,PowerInput,TimeThermalStable]= CreateMultipleLaps(InputPowerProfile,InputPar)

% figure('Color','w')
% plot(InputPowerProfile.Time,-InputPowerProfile.PowerKW,'-','DisplayName','Given profile')
% hold on 
% xlabel('Time [s]')
% ylabel('Power [kW]')
% grid on 
% legend show
% title('Power Qualification')

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
        raceTime= InputPowerProfile.Time+TimeEnd;
        Power= InputPowerProfile.PowerKW;
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

        plot(patchedOneLap(:,1), -patchedOneLap(:,2))
        hold on
        grid on 
        xlabel('Time (s)')
        ylabel('Poewr (kW)')
    end %    for idxlaps= 1:InputPar.Racelaps
     title('Qualification lap')
    InputPowerProfileTotal=array2table(InputPowerProfileTotal,"VariableNames",{'Time','PowerKW'} );
    
    [TimeEnd, dTime,PowerInput]=MissionHelper.InputProfileProcessing(InputPowerProfileTotal,timeStep);

    % get the time period of the thermal stablized period 
    TimeThermalStable= max(InputPowerProfile.Time)*(InputPar.Racelaps-InputPar.ThermalStableLaps);

% if contains(InputProfile, 'PowerQualification')
% FigName= "Quali"
% else
% end
%     saveFigDir= "02_SimOutput\PowerQualification\"
%     saveas(fig,saveFigDir)
  
end