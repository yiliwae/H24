
clc
close all
clear all

%% Load the data 
DataLakeFolder= {'C:\Users\Yi.Li\OneDrive - Fortescue Zero Ltd\General - Battery Performance Team\YL\Data Lake\PackEOLnData\Micheletto'};
% FileName= 'Monza 30C\230718164401.mat';
% FileName= '240426142416.mat'
FileName= '240508131147.mat';
FileDir= string(fullfile(DataLakeFolder,FileName));

load(FileDir)

% clean the value with zeros
data= MissionHelper.removeZerosFromStruct(data);

removeRestSwitch='On';

TestData= TestDataHelper.testDataCleaning(data,removeRestSwitch); 


fig=figure('Color','White','Position',[280,7,1500,1000]);
fig=PlotHelper.PlotExpData(fig, TestData)
sgtitle(FileName)
%%
PowerInput_Eoln=table();
PowerInput_Eoln.PowerKW=double(TestData.Pack.Power_kW);
PowerInput_Eoln.Time=double(TestData.Time_Seconds-TestData.Time_Seconds(1));
CoolantIn.Temperature= double(TestData.Coolant.InletTemperature_degC);

CoolantIn.Time= double(TestData.Time_Seconds-TestData.Time_Seconds(1));

SOCstart           = double(TestData.Cell.MaxSoc(1)/100);

OutputFolderName = 'EolnLap';
timeStep= 0.01 ; % unit: second

[TimeEnd, dTime,PowerInput]=MissionHelper.InputProfileProcessing(PowerInput_Eoln,timeStep);

CoolantInletTempInput=MissionHelper.formTimeseriesData(CoolantIn.Time, CoolantIn.Temperature,timeStep);

TimeEnd= double(TestData.Time_Seconds(end)+0.01);
%%  Load Bus
load('Data\BusObjects.mat')

% Pack Configuration
Ns = 216;
Np =1;


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

CellPar.ThermalProperties.CoolTIn             = min(CoolantInletTempInput);     % unit: [°C] set based on Fred email

% Cell start condition
CellPar.InitialCon.TempAmbient         = 30;      % unit: [°C] set based on Fred email that the inlet temperature is 50degC
CellPar.InitialCon.TempCellStart       = TestData.Cell.MaxTemperature_degC(1); % assumption by YL, the temperature variance is 6degC
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
        InputPar.CoolTIn =CellPar.ThermalProperties.CoolTIn  ;  
        
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

        fig=PlotHelper.PlotSimout_CompareTestData(fig, SimResults,InputPar,...
                                                    SOCstart,TestData);

        % save figures to the path
        figName= sprintf([ 'CoolInTemp%.1d', ...
                            'FlowRate%d.png'], ...
                            round(InputPar.CoolTIn,1), ...
                            round(InputPar.CoolFlowRate,1));
        
        figNameMat= strrep(figName,'png','fig');


        subfolderDir= fullfile("02_SimOutput",OutputFolderName,strcat(num2str(Ns), 's',num2str(Np),'p'));
        
        if ~exist(subfolderDir, "dir")
            mkdir(subfolderDir)
        end

        saveFigDir= fullfile(subfolderDir, figName);
        saveFigDir_mat= fullfile(subfolderDir, figNameMat);
        
        saveas(fig,saveFigDir)
        saveas(fig,saveFigDir_mat)


    end
end

  % resultTable.Properties.VariableNames= {'CoolTempInlet_degC', ...
  %                                   'CoolFlowRate_LperMin', ...
  %                                   'CoolTempOutlet_degC', ...
  %                                   'ThermalResistance_CellToCoolant', ...
  %                                   'PackPower_RMS_kW', ...
  %                                   'PackHeatGeneration_RMS_kW', ...
  %                                   'PackHeatGeneration_Max_kW', ...
  %                                   'TotalHeatGeneration_Pack_kJ', ...
  %                                   'MaxCellTemperature_degC', ...
  %                                   'HottestCellHeatRejection_RMS_W', ...
  %                                   'ColdestCellHeatRejection_RMS_W', ...
  %                                   'HeatRejection_HottestCell_kJ', ...
  %                                   'HeatRejection_ColdestCell_kJ', ...
  %                                   'UnfinishedLap'};
  % 

