function  [TimeEnd, dTime,PowerInput, SOCstart,TimeThermalStable]=compileInputH24(InputProfile,InputPar)

PowerQualification= readtable("InputDriveCycleProfiles\Battery-H24EVO-SPA.xlsx", Range='A:B');
PowerRace= readtable("InputDriveCycleProfiles\Battery-H24EVO-SPA.xlsx", Range='G:H');
%% Manipulate the power profile to make it charge nutral
% find the end idx, 
cutTime= 130.1; 
idxCut= PowerRace.Time>cutTime;



PowerRace(idxCut,:)=[];
%%
timeStep= InputPar.timeStep;

PowerQualification.PowerKW=-1*PowerQualification.PowerKW*InputPar.Racelaps_PowerFudgeFactor;
PowerRace.PowerKW=-1*PowerRace.PowerKW*InputPar.Racelaps_PowerFudgeFactor;
% remove nan value
rowsWithNaN  = any(ismissing(PowerQualification), 2);
PowerQualification(rowsWithNaN, :) = [];

rowsWithNaN_Race  = any(ismissing(PowerRace), 2);

PowerRace= any(ismissing(rowsWithNaN_Race), 2);


%%
if contains(InputProfile, 'PowerQualification')
    SimResults.folderName = 'QualificationLap';
    [TimeEnd, dTime,PowerInput]=MissionHelper.InputProfileProcessing(PowerQualification,timeStep);
    SOCstart           = (0.93);
    InputPar.Racelaps=1;
    TimeThermalStable=TimeEnd;


figure('Color','w')
plot(PowerQualification.Time,-PowerQualification.PowerKW,'-','DisplayName','Given profile')
hold on 
xlabel('Time [s]')
ylabel('Power [kW]')
grid on 
legend show
title('Power Qualification')


else contains(InputProfile, 'PowerRace')
    SimResults.folderName = 'RaceLap';
    
    SOCstart           = (0.80);
    
    PowerRaceTotal= [];
    TimeEnd=0;

    figure('Color','w')
plot(PowerRace.Time,-PowerRace.PowerKW,'-','DisplayName','Given profile')
hold on 
plot(PowerRace.Time(idxCut),-PowerRace.PowerKW(idxCut),'*','DisplayName','Removed')
xlabel('Time [s]')
ylabel('Power [kW]')
grid on 
legend show
title('Power Race')



    figure()
    for idxlaps= 1:InputPar.Racelaps
        idxlaps;
        patchedOneLap=[]; 
        driveCyle=[];
        restProfile=[];
        raceTime=[];

        PowerRace= rmmissing(PowerRace);
        raceTime= PowerRace.Time+TimeEnd;
        Power= PowerRace.PowerKW;
        % add the rest period between laps 
        driveCyle= [raceTime, Power];

        restAfterLap = InputPar.Racelaps_RestBetweenLaps_s;
        restTime = [raceTime(end)+1: raceTime(end)+restAfterLap]';
        restPower= repmat(0, length(restTime),1);
        restProfile=[restTime, restPower];

        patchedOneLap=[driveCyle; restProfile ];

        PowerRaceTotal=[PowerRaceTotal; patchedOneLap];

        TimeStart= patchedOneLap(1,1);
        TimeEnd=  patchedOneLap(end,1)+0.01;

        plot(patchedOneLap(:,1), patchedOneLap(:,2))
        hold on
    end
     title('Power Race')
    PowerRaceTotal=array2table(PowerRaceTotal,"VariableNames",{'Time','PowerKW'} );
    
    [TimeEnd, dTime,PowerInput]=MissionHelper.InputProfileProcessing(PowerRaceTotal,timeStep);

    % get the time period of the thermal stablized period 
    TimeThermalStable= max(PowerRace.Time)*(InputPar.Racelaps-InputPar.ThermalStableLaps);


end



end