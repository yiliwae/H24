% Modified by YL on 0.24.04.22
clc
close all
clear all
% Input of the power cycle profile
%%

timeStep= 0.01 ; % unit: second

InputProfile= {'PowerRace'};

[TimeEnd, dTime,PowerInput]=MissionHelper.compileInputH24(InputProfile,PowerQualification,timeStep)


%%  Load Bus
load([pwd,'\Data\BusObjects.mat'])


% Pack Configuration
Ns = 228;
Np =2;

%% Thermal parameters
CellPar.ThermalProperties.CoolCp= 2000; % [J/kg/K]Specific thermal capacity ??it is 1808.6976 J/kg/K: https://thermalprops.paratherm.com/HTFrange.asp#
CellPar.ThermalProperties.CoolDensity = (770);   % [kg/m3] ??  based on the website, it is 988kg/m3
CellPar.ThermalProperties.ThermalRes_CellEnv= (10); % [K/W] thermal resistance cell to environment
CellPar.ThermalProperties.ThermalRes_CellCool_Cold = (3);%4.5 [K/W] the cold cell thermal resistance
CellPar.ThermalProperties.CoolFlowRate        = [20, 30, 40, 80];   % unit: [L/min]. set based on Fred email
% CellPar.ThermalProperties.CoolTIn             =15 ;     % unit: [°C] set based on Fred email
% CellPar.ThermalProperties.CoolTOut            = 50 ;     % unit: [°C] set based on Fred email
CellPar.ThermalProperties.ThermalRes_CellCool= [3]; % [K/W] thermal resistance cell to coolant
CellPar.ThermalProperties.CoolTIn             =[15, 30] ;     % unit: [°C] set based on Fred email

% Cell start condition
CellPar.InitialCon.TempAmbient         = 30;      % unit: [°C] set based on Fred email that the inlet temperature is 50degC
CellPar.InitialCon.TempCellStart       = 50; % assumption by YL, the temperature variance is 6degC
% CellPar.InitialCon.TempCellStart_Cold  = 50;
CellPar.InitialCon.SOCImbalance        = (0.01);
CellPar.InitialCon.TempCellImbalance   = 5;  % unit[°C] temperature imbalance

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
        InputPar.CoolTIn = CellPar.ThermalProperties.CoolTIn(idxCoolR) ;  
        
        InputPar.Ns= Ns; 
        InputPar.Np= Np;
        InputPar.ThermalRes_CellCool = CellPar.ThermalProperties.ThermalRes_CellCool;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        out = sim('H24_outletEstModel.slx');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%
        % Save Output
        SimResults.tout = out.tout;
        SimResults.Sese_packCurrent_A_fd = out.Electrical.Sese_packCurrent_A_fd.Data;
        SimResults.Sese_packVoltage_V_fd = out.Electrical.Sese_packVoltage_V_fd.Data;
        SimResults.Sese_packPower_W_fd   = SimResults.Sese_packCurrent_A_fd.*SimResults.Sese_packVoltage_V_fd./1000;
        SimResults.Sese_packQGen_kW_fd   = out.Electrical.Sese_packQGen_kW_fd.Data; % heat generation
        SimResults.CellCurrent_A= out.Electrical.Sese_cellCurrent_A_fd.Data;

        SimResults.Sese_minCellVoltage_V_fd        = out.Electrical.Sese_minCellVoltage_V_fd.Data;
        SimResults.Sese_maxCellVoltage_V_fd        = out.Electrical.Sese_maxCellVoltage_V_fd.Data;
        SimResults.Sese_AbsoluteSOCmin_fr_fd       = out.Electrical.Sese_AbsoluteSOCmin_fr_fd.Data;
        SimResults.Sese_AbsoluteSOCmax_fr_fd       = out.Electrical.Sese_AbsoluteSOCmax_fr_fd.Data;

        % Thermal results
        SimResults.Sese_maxCellTemperature_degC_fd = out.Thermal.Sese_maxCellTemperature_degC_fd.Data;
        SimResults.Sese_minCellTemperature_degC_fd = out.Thermal.Sese_minCellTemperature_degC_fd.Data;
        SimResults.Sese_hottestCellQreject_W_fd = out.Thermal.Sese_hottestCellQreject_W_fd.Data;
        SimResults.Sese_coldestCellQreject_W_fd = out.Thermal.Sese_coldestCellQreject_W_fd.Data;
        SimResults.Sese_coolantInletTemperature_degC_fd= out.Thermal.Sese_coolantInletTemperature_degC_fd.Data;
        SimResults.Sese_coolantOutletTemperature_degC_fd= out.Thermal.Sese_coolantOutletTemperature_degC_fd.Data;
        %% Find stop reasons

        SimResults.StopReason = MissionHelper.findStopReason(out.StopSignals_CellHot);

        %% Summurize the results
        SimResults.packPower_rms_kW             = rms(SimResults.Sese_packPower_W_fd);
        SimResults.packCurrent_rms_A           = rms(SimResults.Sese_packCurrent_A_fd);
        SimResults.CellTemp_max_degC = max(SimResults.Sese_maxCellTemperature_degC_fd);
        SimResults.CellVolt_max_V       = max(SimResults.Sese_maxCellVoltage_V_fd);
        SimResults.CellVolt_min_V        = min(SimResults.Sese_minCellVoltage_V_fd);
        SimResults.packHeatGen_rms_kW             = rms(SimResults.Sese_packQGen_kW_fd);
        SimResults.packHeatGen_max_kW            = max(SimResults.Sese_packQGen_kW_fd);
        SimResults.packHeatGen_kJ   = cumtrapz(SimResults.tout,SimResults.Sese_packQGen_kW_fd); %unit:kJ
        SimResults.hottestCellHeatReject_kJ = cumtrapz(SimResults.tout,SimResults.Sese_hottestCellQreject_W_fd)/1000; %unit:kJ
        SimResults.coldestCellHeatReject_kJ = cumtrapz(SimResults.tout,SimResults.Sese_coldestCellQreject_W_fd)/1000; %unit:kJ
        SimResults.hottestCellHeatReject_rms_W = rms(SimResults.Sese_hottestCellQreject_W_fd); %unit:W
        SimResults.coldestCellHeatReject_rms_W = rms(SimResults.coldestCellHeatReject_kJ); %unit:W
        SimResults.coolantOutTemp_degC           = SimResults.Sese_coolantOutletTemperature_degC_fd(end);
        % calculate the rejected heat from cell to coolant and ambient
        % temperature
        % Q_packToair=


        if ~isempty( SimResults.StopReason)
            SimResults.UnfinishedLap= 1;
        else
            SimResults.UnfinishedLap=0;
        end

        SimResults.HeatGen_pack_kJ= SimResults.packHeatGen_kJ(end);
        SimResults.HeatReject_cell_hot_kJ= SimResults.hottestCellHeatReject_kJ(end);
        SimResults.HeatReject_cell_cold_kJ= SimResults.coldestCellHeatReject_kJ(end);
        resultPre = table(InputPar.CoolTIn, ...
                       InputPar.CoolFlowRate, ...
                       SimResults.coolantOutTemp_degC ,...
                      InputPar.ThermalRes_CellCool, ...
                      SimResults.packPower_rms_kW,...
                      SimResults.packHeatGen_rms_kW, ...
                      SimResults.packHeatGen_max_kW, ...
                      SimResults.HeatGen_pack_kJ,...
                      SimResults.CellTemp_max_degC,...
                      SimResults.hottestCellHeatReject_rms_W,...
                      SimResults.coldestCellHeatReject_rms_W, ...      
                      SimResults.HeatReject_cell_hot_kJ,...
                      SimResults.HeatReject_cell_cold_kJ, ...
                      SimResults.UnfinishedLap);

        resultTable=[resultTable;resultPre];

        %%
        % close all; clc

        fig=figure('Color','White','Name',['Alpha=',num2str(Alpha),'- SOHQ',num2str(SOHQ)],'Position',[680,7,1000,1000]);
        tiledlayout(4,2,"TileSpacing","compact","Padding","compact");

        fig=MissionHelper.PlotSimout(fig, SimResults,InputPar,SOCstart);
        % save figures to the path
        figName= sprintf([ 'CoolInTemp%.1d', ...
                            'FlowRate%d.png'], ...
                            round(InputPar.CoolTIn,1), ...
                            round(InputPar.CoolFlowRate,1));
        
        subfolderDir= fullfile("SimOutput",SimResults.folderName,strcat(num2str(Ns), 's',num2str(Np),'p'));
        
        if ~exist(subfolderDir, "dir")
            mkdir(subfolderDir)
        end
        saveFigDir= fullfile(subfolderDir, figName);
        
        saveas(fig,saveFigDir)


    end
end
%%
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


%% save the simulation output
resultTable=sortrows(resultTable,["CoolTempInlet_degC","CoolFlowRate_LperMin"]);


matDir=  fullfile(subfolderDir,"H24_CoolantImpact.mat");


save(matDir,"resultTable")
%%
% SimResults.folderName='RaceLap- 10laps'
% fig2=figure('Color','w')
% subplot(2,1,1)
% 
% plot(resultTable.HottestCellHeatRejection_RMS_W,resultTable.MaxCellTemperature_degC,'-*')
% xlabel('RMS Rejected heat [W]')
% ylabel('Max cell temperature [°C]')
% grid on
% title('RMS rejected heat of hottest cell vs. max cell temperature')
% subplot(2,1,2)
% plot(resultTable.ThermalResistance_CellToCoolant,resultTable.MaxCellTemperature_degC,'-*')
% xlabel('Cell to Coolant thermal resistance [K/W]')
% ylabel('Max cell temperature [°C]')
% grid on
% title('Thermal resistance vs. max cell temperature')
% sgtitle(SimResults.folderName)
% saveFigDir= fullfile(subfolderDir, "HeatRejectionVsTemp.png");
% saveas(fig2,saveFigDir)
%%
%{
figure()
plot3(resultTable.CoolFlowRate,resultTable.CoolInTemp,resultTable.CellTemp_max_degC,'o','Color','b','MarkerSize',10,...
    'MarkerFaceColor','#D9FFFF')
xlabel('Coolant flow rate')
ylabel('Coolant in temperature')
zlabel('Cell max temperature')
grid on

% writematrix(Sese_maxCellTemperature_degC_fd_MAX,[NameSim,'ResultSim.xlsx'],'Sheet','Tmax')
% writematrix(Sese_minCellVoltage_V_fd_MIN,[NameSim,'ResultSim.xlsx'],'Sheet','Vmin')
% writematrix(Sese_maxCellVoltage_V_fd_MAX,[NameSim,'ResultSim.xlsx'],'Sheet','Vmax')
% writematrix(Sese_packQGen_kW_fd_RMS,[NameSim,'ResultSim.xlsx'],'Sheet','Qgen_rms')
% writematrix(Sese_packQGen_kW_fd_MAX,[NameSim,'ResultSim.xlsx'],'Sheet','Qgen_max')

%%

figure('Color','White','Position',[142,59,1800,700]);

% Unique CoolFlowRates
uniqueRates = unique(resultTable.CoolFlowRate);
uniqueCoolantIn = unique(resultTable.CoolInTemp);

% Colors - generate a colormap
colorMap = lines(length(uniqueRates));

% First subplot
subplot(1, 2, 1);
hold on;
for i = 1:length(uniqueRates)
    % Get subset of data for each CoolFlowRate
    idx = resultTable.CoolFlowRate == uniqueRates(i);
    flowRate= uniqueRates(i); 
    plot(resultTable.CoolInTemp(idx), resultTable.CellTemp_max_degC(idx), '-*', ...
        'MarkerFaceColor', colorMap(i, :),'DisplayName',strcat('Coolant Flowrate:',num2str(uniqueRates(i)), ' L/min'));
    hline=yline(80, 'r-', 'LineWidth', 2,'HandleVisibility','off'); % 'r-' makes the line red, and 'LineWidth', 2 makes it thicker
    
end
grid on 
xlabel('Temperature of Coolant In (°C)');
ylabel('Max Cell temperature (°C)');
title('CoolInTemp vs MaxCellTemp for each CoolFlowRate');
legend show
legend( 'Location', 'best');
hold off;

subplot(1, 2, 2);
colorMap = jet(length(uniqueCoolantIn));

for i = 1:length(uniqueCoolantIn)
    % Get subset of data for each CoolFlowRate
    idx = resultTable.CoolInTemp == uniqueCoolantIn(i);
    coolInTemp= uniqueCoolantIn(i); 
    plot(resultTable.CoolFlowRate(idx), resultTable.CellTemp_max_degC(idx), '-*', ...
        'MarkerFaceColor', colorMap(i, :),'DisplayName',strcat('Inlet Temp:',num2str(coolInTemp), ' °C'));
    hold on 
   hline=yline(80, 'r-', 'LineWidth', 2,'HandleVisibility','off'); % 'r-' makes the line red, and 'LineWidth', 2 makes it thicker
   
end
grid on 
xlabel('Coolant flow rate(L/min)');
ylabel('Max Cell temperature (°C)');
title('CoolFlowRate vs MaxCellTemp for each CoolInTemp');
legend show
legend( 'Location', 'best');
hold off;

% Cell_Temperature = Cell_Temperature(:,1:180);
% Cell_Temperature_max_vct = max(Cell_Temperature,[],2);
% Cell_Temperature_min_vct = min(Cell_Temperature,[],2);
%
% figure
% hold on
% plot(Cell_Temperature_max_vct) % from experiment
% plot(Sese_maxCellTemperature_degC_fd) % from simulation
%
% figure
% hold on
% plot(Cell_Temperature_min_vct)
% plot(Sese_minCellTemperature_degC_fd)
%
% figure
% scatter(1:180,Cell_Temperature(1,1:180))
%}

% figure
% hold on
% plot(out.logsout{1}.Values.Sese_minCellVoltage_V_fd.Data)
% plot(out.logsout{5}.Values.Sese_minCellVoltage_V_fd.Data)