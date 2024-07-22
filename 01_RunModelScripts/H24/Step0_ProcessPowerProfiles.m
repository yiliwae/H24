clear; close all; clc

% InputPar.PowerProfile.Folder= "\\wae-fs01\Department\WAE\Business Development\!Proposals\M1444B1 - Mission H24\Technical\240610_Drive Cycle";
InputPar.PowerProfile.Folder="InputDriveCycleProfiles";
InputPar.PowerProfile.Name = "P006-1040-019-A-------Battery_Load_WAE.xlsx";
InputPar.PowerProfile.Dir= fullfile(InputPar.PowerProfile.Folder,InputPar.PowerProfile.Name );

sheetName = sheetnames(InputPar.PowerProfile.Dir);
% read the table for each sheet
fig1= figure('Color','White','Position',[680,7,1500,1000]);
for isheet = 1: length(sheetName)
    data= readtable(InputPar.PowerProfile.Dir,Sheet=sheetName(isheet));
    data.Properties.VariableNames=["sRun_m","Time_Seconds","vCar_kph","Power_kW","Power_RMS_kW"];

    data.Power_kW = -data.Power_kW;
    PowerProfile.(sheetName(isheet))= data;

    nexttile()
    plot(data.Time_Seconds, data.Power_kW);
    grid on
    xlabel('Time (s)'); ylabel('Power (kW)');

    InputPowerProfileTotal= data(:,[2,4]);
    timeStep=0.001;
    [TimeEnd, dTime,PowerInput]=MissionHelper.InputProfileProcessingNewName(InputPowerProfileTotal,timeStep);

    RMS_interp= rms(PowerInput.Data);
    Avg_interp= mean(abs(PowerInput.Data));

    titleName= strrep(sheetName(isheet), "_","-");
    title(sprintf("File: %s \n Power_{RMS}= %.0f, |Power_{Avg}|= %.0f", titleName, RMS_interp, Avg_interp));

end

mainFolder= "C:\02_MatlabCode\07_BizDevp\H24\02_SimOutput";
FigNameMat= fullfile(mainFolder,"PowerProfile.fig");
FigNamePng= fullfile(mainFolder, "PowerProfile.png");
saveas(fig1, FigNameMat);
saveas(fig1, FigNamePng);