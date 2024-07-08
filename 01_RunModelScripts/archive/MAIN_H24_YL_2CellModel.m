
clc
close all
clear all

%% Load the data 
PowerQualification= readtable("InputDriveCycleProfiles\Battery-H24EVO-SPA.xlsx", Range='A:B');
PowerRace= readtable("InputDriveCycleProfiles\Battery-H24EVO-SPA.xlsx", Range='G:H');

PowerQualification.PowerKW=-1*PowerQualification.PowerKW;
PowerRace.PowerKW=-1*PowerRace.PowerKW;

SOCstart           = (0.60);
timeStep= 0.1; % unit: s
figure('Color','w')
% nexttile
plot(PowerQualification.Time, PowerQualification.PowerKW,'DisplayName','Qualification lap')
hold on
plot(PowerRace.Time, PowerRace.PowerKW,'DisplayName','Race lap')
grid on
legend show
xlabel('Time [s]')
ylabel('Power [kW]')
title('H24')
legend('Location','best')

[TimeEnd, dTime,PowerInput]=MissionHelper.InputProfileProcessing(PowerRace, timeStep);


%%  Load Bus
load([pwd,'\Data\BusObjects.mat'])

% Pack Configuration
Ns = 216;
Np =2;


%% Thermal parameters
CellPar.ThermalProperties.CoolCp= 2000; % [J/kg/K]Specific thermal capacity ??it is 1808.6976 J/kg/K: https://thermalprops.paratherm.com/HTFrange.asp#
CellPar.ThermalProperties.CoolDensity = (770);   % [kg/m3] ??  based on the website, it is 988kg/m3
CellPar.ThermalProperties.ThermalRes_CellEnv= (10); % [K/W] thermal resistance cell to environment
CellPar.ThermalProperties.ThermalRes_CellCool_Cold = (3);%4.5 [K/W] the cold cell thermal resistance
CellPar.ThermalProperties.CoolFlowRate        = [20];   % unit: [L/min]. set based on Fred email
% CellPar.ThermalProperties.CoolTIn             =15 ;     % unit: [°C] set based on Fred email
% CellPar.ThermalProperties.CoolTOut            = 50 ;     % unit: [°C] set based on Fred email
CellPar.ThermalProperties.ThermalRes_CellCool_hotcell= [3]; % [K/W] thermal resistance cell to coolant
CellPar.ThermalProperties.ThermalRes_CellCool_coldcell= [2]; % [K/W] thermal resistance cell to coolant

CellPar.ThermalProperties.CoolTIn     =  46;     % unit: [°C] set based on Fred email

% Cell start condition
CellPar.InitialCon.TempAmbient         = 30;      % unit: [°C] set based on Fred email that the inlet temperature is 50degC
CellPar.InitialCon.TempCellStart       = 50; % assumption by YL, the temperature variance is 6degC
% CellPar.InitialCon.TempCellStart_Cold  = 50;
CellPar.InitialCon.SOCImbalance        = (0.01);
CellPar.InitialCon.TempCellImbalance   = 7;  % unit[°C] temperature imbalance

% Stop state
stopState.HighVoltage_B = true;
stopState.LowVoltage_B = true;
stopState.HighSoc_B = false;
stopState.LowSoc_B = true;

stopState.HighSoc_Pc = 20;
stopState.LowSoc_Pc = 0;
stopState.HighVoltage_U = 4.35;
stopState.LowVoltage_U = 2.5;


% StopTime_s = 12*3600; %unit:s
%%
Alpha = 1;  % 0-1  this is the SOH of DCIR
SOHQ  = flip(1);  % 0-1

% AlphaVct = [1];  % 0-1
% SOHQVct  = flip([1]);  % 0-1
% set_param(gcs,'SimulationCommand','Update')
resultTable=[];
for idxCoolR = 1:length(CellPar.ThermalProperties.CoolTIn)

    for idxCoolFlowRate = 1:length(CellPar.ThermalProperties.CoolFlowRate)

        
        InputPar.CoolFlowRate  = (CellPar.ThermalProperties.CoolFlowRate(idxCoolFlowRate));
        InputPar.CoolTIn = 46;  
        
        InputPar.Ns= Ns; 
        InputPar.Np= Np;
        InputPar.ThermalRes_CellCool_hotcell = CellPar.ThermalProperties.ThermalRes_CellCool_hotcell;
        InputPar.ThermalRes_CellCool_coldcell = CellPar.ThermalProperties.ThermalRes_CellCool_coldcell;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        out = sim('H24_outletEstModel_2cells.slx');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%
        % Save Output
        
        [SimResults,resultSummaryPre]= MissionHelper.getSimout(out, InputPar);
        
        resultTable=[resultTable;resultSummaryPre];

        %%
        % close all; clc

        fig=figure('Color','White','Name',['Alpha=',num2str(Alpha),'- SOHQ',num2str(SOHQ)],'Position',[680,7,1500,1000]);
        tiledlayout(4,2,"TileSpacing","compact","Padding","compact");

        fig=PlotHelper.PlotSimout(fig, SimResults,InputPar,...
                                   SOCstart);

        % save figures to the path
        figName= sprintf([ 'CoolInTemp%.1d', ...
                            'FlowRate%d.png'], ...
                            round(InputPar.CoolTIn,1), ...
                            round(InputPar.CoolFlowRate,1));
        
        subfolderDir= fullfile("SimOutput",OutputFolderName,strcat(num2str(Ns), 's',num2str(Np),'p'));
        
        if ~exist(subfolderDir, "dir")
            mkdir(subfolderDir)
        end
        saveFigDir= fullfile(subfolderDir, figName);
        
        saveas(fig,saveFigDir)


    end
end

  resultTable.Properties.VariableNames= {'CoolTempInlet_degC', ...
                                    'CoolFlowRate_LperMin', ...
                                    'CoolTempOutlet_degC', ...
                                    'ThermalResistance_CellToCoolant', ...
                                    'PackPower_RMS_kW', ...
                                    'PackHeatGeneration_RMS_kW', ...
                                    'PackHeatGeneration_Max_kW', ...
                                    'TotalHeatGeneration_Pack_kJ', ...
                                    'MaxCellTemperature_degC', ...
                                    'HottestCellHeatRejection_RMS_W', ...
                                    'ColdestCellHeatRejection_RMS_W', ...
                                    'HeatRejection_HottestCell_kJ', ...
                                    'HeatRejection_ColdestCell_kJ', ...
                                    'UnfinishedLap'};


