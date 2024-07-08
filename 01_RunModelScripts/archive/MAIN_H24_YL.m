% Modified by YL on 0.24.04.22
clc
close all
clear all
% Input of the power cycle profile
%%
PowerQualification= readtable("InputDriveCycleProfiles\Battery-H24EVO-SPA.xlsx", Range='A:B');
PowerRace= readtable("InputDriveCycleProfiles\Battery-H24EVO-SPA.xlsx", Range='G:H');

PowerQualification.PowerKW=-1*PowerQualification.PowerKW;
PowerRace.PowerKW=-1*PowerRace.PowerKW;

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

[TimeEnd, dTime,PowerInput]=MissionHelper.InputProfileProcessing(PowerRace);

%%  Load Bus
load([pwd,'\Data\BusObjects.mat'])

% Pack Configuration
Ns = 216;
Np =2;

%% Thermal parameters
CellPar.ThermalProperties.CoolTIn             = 20 ;     % unit: [°C] set based on Fred email
CellPar.ThermalProperties.CoolFlowRate        = (40);   % unit: [L/min]. set based on Fred email
CellPar.ThermalProperties.CoolCp= 2000; % [J/kg/K]Specific thermal capacity ??it is 1808.6976 J/kg/K: https://thermalprops.paratherm.com/HTFrange.asp#
CellPar.ThermalProperties.CoolDensity = (770);   % [kg/m3] ??  based on the website, it is 988kg/m3
CellPar.ThermalProperties.ThermalRes_CellEnv= (10); % [K/W] thermal resistance cell to environment
CellPar.ThermalProperties.ThermalRes_CellCool= (4.2); % [K/W] thermal resistance cell to coolant
CellPar.ThermalProperties.ThermalRes_CellCool_Cold = (3);%4.5 [K/W] the cold cell thermal resistance


% Cell start condition
CellPar.InitialCon.TempAmbient         = 50;      % unit: [°C] set based on Fred email that the inlet temperature is 50degC
CellPar.InitialCon.TempCellStart      = CellPar.InitialCon.TempAmbient +3; % assumption by YL, the temperature variance is 6degC
CellPar.InitialCon.TempCellStart_Cold = CellPar.InitialCon.TempAmbient -3;
CellPar.InitialCon.SOCImbalance  = (0.01);
SOCstart           = (0.80);

% Stop state
stopState.HighVoltage_B = true;
stopState.LowVoltage_B = true;
stopState.HighSoc_B = true;
stopState.LowSoc_B = true;

stopState.HighSoc_Pc = 1.10;
stopState.LowSoc_Pc = 0;
stopState.HighVoltage_U = 4.3;
stopState.LowVoltage_U = 2.5;


% StopTime_s = 12*3600; %unit:s
%%
AlphaVct = [1];  % 0-1  this is the SOH of DCIR
SOHQVct  = flip([1]);  % 0-1

% AlphaVct = [1];  % 0-1
% SOHQVct  = flip([1]);  % 0-1
% set_param(gcs,'SimulationCommand','Update')
%
for AlphaVct_Loop = 1:length(AlphaVct)

    for SOHQVct_Loop = 1:length(SOHQVct )
        Alpha = (AlphaVct(AlphaVct_Loop));
        SOHQ  = (SOHQVct(SOHQVct_Loop));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        out = sim('H24_2.slx');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%
        % Save Output
        tout = out.tout;
        Sese_packCurrent_A_fd = out.logsout{1}.Values.Sese_packCurrent_A_fd.Data;
        Sese_packVoltage_V_fd = out.logsout{1}.Values.Sese_packVoltage_V_fd.Data;
        Sese_packPower_V_fd   = Sese_packCurrent_A_fd.*Sese_packVoltage_V_fd./1000;
        Sese_packQGen_kW_fd   = out.logsout{1}.Values.Sese_packQGen_kW_fd.Data; % heat generation 

        Sese_minCellVoltage_V_fd        = out.logsout{5}.Values.Sese_minCellVoltage_V_fd.Data;
        Sese_maxCellVoltage_V_fd        = out.logsout{5}.Values.Sese_maxCellVoltage_V_fd.Data;
        Sese_AbsoluteSOCmin_fr_fd       = out.logsout{5}.Values.Sese_AbsoluteSOCmin_fr_fd.Data;
        Sese_AbsoluteSOCmax_fr_fd       = out.logsout{5}.Values.Sese_AbsoluteSOCmax_fr_fd.Data;
        Sese_maxCellTemperature_degC_fd = out.logsout{2}.Values.Sese_maxCellTemperature_degC_fd.Data;

        Sese_minCellTemperature_degC_fd = out.logsout{6}.Values.Sese_minCellTemperature_degC_fd.Data;

        Sese_packPower_V_fd_rms(SOHQVct_Loop,AlphaVct_Loop)             = rms(Sese_packPower_V_fd);
        Sese_packCurrent_A_fd_rms(SOHQVct_Loop,AlphaVct_Loop)           = rms(Sese_packCurrent_A_fd);
        Sese_maxCellTemperature_degC_fd_MAX(SOHQVct_Loop,AlphaVct_Loop) = max(Sese_maxCellTemperature_degC_fd);
        Sese_maxCellVoltage_V_fd_MAX(SOHQVct_Loop,AlphaVct_Loop)        = max(Sese_maxCellVoltage_V_fd);
        Sese_minCellVoltage_V_fd_MIN(SOHQVct_Loop,AlphaVct_Loop)        = min(Sese_minCellVoltage_V_fd);
        Sese_packQGen_kW_fd_RMS(SOHQVct_Loop,AlphaVct_Loop)             = rms(Sese_packQGen_kW_fd);
        Sese_packQGen_kW_fd_MAX(SOHQVct_Loop,AlphaVct_Loop)             = max(Sese_packQGen_kW_fd);
        %% Find stop reasons

        StopReason = MissionHelper.findStopReason(out.StopSignals_CellHot)

        %%
        % figure('Color','White','Name',['Alpha=',num2str(Alpha),'- SOHQ',num2str(SOHQ)],'Position',[680,307,947,671])
        % tiledlayout(2,1,"TileSpacing","compact","Padding","compact")
        % nexttile
        % 
        % grid on;box on;hold on
        % plot(tout ,Sese_packPower_V_fd,'DisplayName','Simulation')
        % hold on
        % plot(newTime/60,PowerKW/2,'DisplayName','Input')
        % legend show
        % ylabel('Power [kW]')
        % xlim([0 TimeEnd/60])
        % 
        % nexttile
        % plot(tout,out.logsout{1}.Values.Sese_packCurrent_A_fd.Data)
        % grid on
        % ylabel('Current [A]')
        % xlim([0 TimeEnd/60])
        % xlabel('Time [s]')
        %%
        figure('Color','White','Name',['Alpha=',num2str(Alpha),'- SOHQ',num2str(SOHQ)],'Position',[680,307,947,671])
        tiledlayout(2,2,"TileSpacing","compact","Padding","compact")

        n1=nexttile(1);
        grid on;box on;hold on
        plot(tout,Sese_packPower_V_fd)
        hold on
        % plot(newTime/60,PowerKW/2)
        set(gca,'YLimitMethod','padded');set(gca,'XLimitMethod','tight');ylabel('kW')
        title('',['Power: P.rms= ', num2str(round(Sese_packPower_V_fd_rms(SOHQVct_Loop,AlphaVct_Loop))),' [kW]'])

        ylim([-800, 800])
        n2=nexttile(2);
        grid on;box on;hold on
        plot(tout,Sese_minCellVoltage_V_fd,'DisplayName','Vcell_{cold}')
        plot(tout,Sese_maxCellVoltage_V_fd,'DisplayName','Vcell_{hot}')
        set(gca,'YLimitMethod','padded');set(gca,'XLimitMethod','tight');ylabel('V')
        title('',['Cell Voltage: Vmax= ', num2str(round(Sese_maxCellVoltage_V_fd_MAX(SOHQVct_Loop,AlphaVct_Loop),3)),...
                  ' [V]  /  Vmin= ', num2str(round(Sese_minCellVoltage_V_fd_MIN(SOHQVct_Loop,AlphaVct_Loop),3)),' [V]'])
        legend show

          if ~isempty(StopReason)
        stopStr = sprintf('Lap Unfinished: Reach %s after %.2f s', StopReason, max(tout));
        % Use text to place the title manually
        text(50, 2.5, stopStr, 'HorizontalAlignment', 'center' ,'Color','r','BackgroundColor','w');
        else
         stopStr = sprintf('Finished the lap');
            text(50, 2.5, stopStr, 'HorizontalAlignment', 'center' ,'Color','k');
          end

        n3=nexttile(3);
        grid on;box on;hold on
        plot(tout,Sese_minCellTemperature_degC_fd)
        plot(tout,Sese_maxCellTemperature_degC_fd)
          xlabel('Time [s]')
        hline=yline(80, 'r-', 'LineWidth', 2); % 'r-' makes the line red, and 'LineWidth', 2 makes it thicker
        set(hline, 'DisplayName', 'Critical Temp = 80°C'); % Optional: Adds a label for legend
        % Add text near the yline
        text(tout(end)*0.95, 80, 'Max Cell Temperature: 80°C', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'red');

        set(gca, 'YLimitMethod', 'padded');
        set(gca, 'XLimitMethod', 'tight');
        ylabel('\circ{C}')
        title(['Cell Temperature: Tmax= ', num2str(round(Sese_maxCellTemperature_degC_fd_MAX(SOHQVct_Loop,AlphaVct_Loop),3)),' [\circ{C}]'])
        xlabel('Time [s]')
        

        n4=nexttile(4);
        yyaxis left
        grid on;box on;hold on
        plot(tout,Sese_packQGen_kW_fd)
        set(gca,'YLimitMethod','padded');
        set(gca,'XLimitMethod','tight');
        ylabel('kW')
        title('',['Qgen. Pack  & SoC'])
        ylabel('Generated Heat [kW]')

        yyaxis right
        grid on;box on;hold on
        plot(tout,Sese_AbsoluteSOCmax_fr_fd.*100)
        set(gca,'YLimitMethod','padded');set(gca,'XLimitMethod','tight');ylabel('%')
        title('',['Qgen. Pack (rms= ',num2str(rms(round(Sese_packQGen_kW_fd_RMS(SOHQVct_Loop,AlphaVct_Loop),2))),') & SoC'])
        xlabel('Time [s]')
        ylabel('SoC [%]')
        ylim([0 100])

      

    % Using sgtitle to create a super title across all subplots
      titleStr = sprintf([ 'SOC_{start}= %.2f [%%]  \n'...
            'CoolIn= %.1f[\\circ{C}] -', ...
            'FlowRate= %d[L/min]    \n', ...
            'SOH_R= %.0f,  ', ...
            'SOH_Q= %.0f '], ...
            round(SOCstart*100,1),...
            round(median(CellPar.ThermalProperties.CoolTIn),1), ...
            round(median(CellPar.ThermalProperties.CoolFlowRate)), ...
            round(Alpha), ...
            round(SOHQ ));

        sgtitle(titleStr);

    end
end


% writematrix(Sese_maxCellTemperature_degC_fd_MAX,[NameSim,'ResultSim.xlsx'],'Sheet','Tmax')
% writematrix(Sese_minCellVoltage_V_fd_MIN,[NameSim,'ResultSim.xlsx'],'Sheet','Vmin')
% writematrix(Sese_maxCellVoltage_V_fd_MAX,[NameSim,'ResultSim.xlsx'],'Sheet','Vmax')
% writematrix(Sese_packQGen_kW_fd_RMS,[NameSim,'ResultSim.xlsx'],'Sheet','Qgen_rms')
% writematrix(Sese_packQGen_kW_fd_MAX,[NameSim,'ResultSim.xlsx'],'Sheet','Qgen_max')




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


% figure
% hold on
% plot(out.logsout{1}.Values.Sese_minCellVoltage_V_fd.Data)
% plot(out.logsout{5}.Values.Sese_minCellVoltage_V_fd.Data)