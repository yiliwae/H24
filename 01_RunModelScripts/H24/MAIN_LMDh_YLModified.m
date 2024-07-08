
% INPUTPOWER = timeseries(time,Batt_Current(:,1));
% figure
% plot(INPUTPOWER)
% Load Power Profile
% load('PowerProfile_LMDh.mat')
% INPUTPOWER      = double(INPUTPOWER);
% INPUTPOWER(:,1) = INPUTPOWER(:,1).*60;
% TimeEnd         = INPUTPOWER(end,1);
% dTime           = INPUTPOWER(2,1)-INPUTPOWER(1,1);
% INPUTPOWER = timeseries(INPUTPOWER(:,1),INPUTPOWER(:,2));
% figure
% plot(INPUTPOWER)
% figure
% plot(INPUTPOWER(:,1),INPUTPOWER(:,2))


%% Pulse
% time         = [[0:0.1:5]';[5+0.1:0.1:5+0.1+2]';[7+0.1:0.1:7+5]'];
% Batt_Current = [zeros(length([0:0.1:5]'),1);-200.*ones(length([5+0.1:0.1:5+0.1+2]'),1);zeros(length([7+0.1:0.1:7+5]'),1)];
% NameSim      = 'Pulse';

%% Daytona race 
% load('RLL_25_Daytona_24_Stint_CyclingData.mat')
% NameSim = 'RaceSim_updated_DualT';
% max(max(Cell_Temperature(:,1:180)))
% min(min(Cell_Temperature(:,1:180)))
% 
% figure
% plot(Cell_Temperature(:,1:180))
clc
close all
clear all

%% High Duty Cycle 
load('R03 - Drivecycle WAE D2R03 760-BET-023_CyclingData.mat')
NameSim = 'HighDuty';
max(max(Cell_Temperature(:,1:180)))

figure
plot(Cell_Temperature)

TimeEnd = max(time);
dTime   = time(2,1)-time(1,1);

%% 
PackPower= sum(Cell_Voltage,2).*Batt_Current(:,1)/1000;
minVcell= min(Cell_Voltage,[],2);
rms(PackPower)
%%  Load Bus 
load([pwd,'\Data\BusObjects.mat'])

% Pack Configuration
Ns = 180;
Np = 1;

% Coolant
TempAmbient         = TAmbient(1);%
CoolTIn             = TInlet(1);
CoolFlowRate        = (15);
CoolCp              = (2000);
CoolDensity         = (770);
ThermalRes_CellEnv  = (10);
ThermalRes_CellCool = (4.2);%4.5
ThermalRes_CellCool_Cold = (3);%4.5 the cold cell thermal resistance

% Cell start condition
SOCstart           = (0.5);
TempCellStart      = max(max(Cell_Temperature(1,1:180)));
TempCellStart_Cold = min(min(Cell_Temperature(1,1:180)));

SOCImbalance  = (0.01);

AlphaVct = [1];  % 0-1
SOHQVct  = flip([1]);  % 0-1

% AlphaVct = [1];  % 0-1
% SOHQVct  = flip([1]);  % 0-1
% set_param(gcs,'SimulationCommand','Update')
%% 
for AlphaVct_Loop = 1:length(AlphaVct)

    for SOHQVct_Loop = 1:length(SOHQVct)
        Alpha = (AlphaVct(AlphaVct_Loop));
        SOHQ  = (SOHQVct(SOHQVct_Loop));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        out = sim('LMDh.slx');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
        % Save Output
        tout = out.tout;
        Sese_packCurrent_A_fd = out.logsout{1}.Values.Sese_packCurrent_A_fd.Data;
        Sese_packVoltage_V_fd = out.logsout{1}.Values.Sese_packVoltage_V_fd.Data;
        Sese_packPower_V_fd   = Sese_packCurrent_A_fd.*Sese_packVoltage_V_fd./1000;
        Sese_packQGen_kW_fd   = out.logsout{1}.Values.Sese_packQGen_kW_fd.Data;

        Sese_minCellVoltage_V_fd        = out.logsout{5}.Values.Sese_minCellVoltage_V_fd.Data;
        Sese_maxCellVoltage_V_fd        = out.logsout{5}.Values.Sese_maxCellVoltage_V_fd.Data;
        Sese_AbsoluteSOCmin_fr_fd       = out.logsout{5}.Values.Sese_AbsoluteSOCmin_fr_fd.Data;
        Sese_AbsoluteSOCmax_fr_fd       = out.logsout{5}.Values.Sese_AbsoluteSOCmax_fr_fd.Data;
        Sese_maxCellTemperature_degC_fd = out.logsout{2}.Values.Sese_maxCellTemperature_degC_fd.Data;

        Sese_minCellTemperature_degC_fd = out.logsout{6}.Values.Sese_minCellTemperature_degC_fd.Data;


%         figure
%         plot(out.logsout{2}.Values.Sese_minCellTemperature_degC_fd.Data)


        Sese_packPower_V_fd_rms(SOHQVct_Loop,AlphaVct_Loop)             = rms(Sese_packPower_V_fd);
        Sese_packCurrent_A_fd_rms(SOHQVct_Loop,AlphaVct_Loop)           = rms(Sese_packCurrent_A_fd);
        Sese_maxCellTemperature_degC_fd_MAX(SOHQVct_Loop,AlphaVct_Loop) = max(Sese_maxCellTemperature_degC_fd);
        Sese_maxCellVoltage_V_fd_MAX(SOHQVct_Loop,AlphaVct_Loop)        = max(Sese_maxCellVoltage_V_fd);
        Sese_minCellVoltage_V_fd_MIN(SOHQVct_Loop,AlphaVct_Loop)        = min(Sese_minCellVoltage_V_fd);
        Sese_packQGen_kW_fd_RMS(SOHQVct_Loop,AlphaVct_Loop)             = rms(Sese_packQGen_kW_fd);
        Sese_packQGen_kW_fd_MAX(SOHQVct_Loop,AlphaVct_Loop)             = max(Sese_packQGen_kW_fd);


        %%
        figure('Color','White','Name',['Alpha=',num2str(Alpha),'- SOHQ',num2str(SOHQ)],'Position',[680,307,947,671])
        tiledlayout(2,2,"TileSpacing","compact","Padding","compact")

        n1=nexttile(1);
        grid on;box on;hold on
        plot(tout./60,Sese_packPower_V_fd)
        hold on 
        plot(time/60, PackPower)
        set(gca,'YLimitMethod','padded');set(gca,'XLimitMethod','tight');ylabel('kW')
        title('',['Power: P.rms= ', num2str(round(Sese_packPower_V_fd_rms(SOHQVct_Loop,AlphaVct_Loop))),' [kW]'])

        n2=nexttile(2);
        grid on;box on;hold on
        plot(tout./60,Sese_minCellVoltage_V_fd)
        hold on
        plot(time/60, minVcell)
        % plot(tout./60,Sese_maxCellVoltage_V_fd)
        set(gca,'YLimitMethod','padded');set(gca,'XLimitMethod','tight');ylabel('V')
        title('',['Cell Voltage: Vmax= ', num2str(round(Sese_maxCellVoltage_V_fd_MAX(SOHQVct_Loop,AlphaVct_Loop),3)),' [V]  /  Vmin= ', num2str(round(Sese_minCellVoltage_V_fd_MIN(SOHQVct_Loop,AlphaVct_Loop),3)),' [V]'])

        n3=nexttile(3);
        grid on;box on;hold on
        plot(tout./60,Sese_minCellTemperature_degC_fd)
        plot(tout./60,Sese_maxCellTemperature_degC_fd)
        set(gca,'YLimitMethod','padded');set(gca,'XLimitMethod','tight');ylabel('\circ{C}')
        title('',['Cell Temperature: Tmax= ', num2str(round(Sese_maxCellTemperature_degC_fd_MAX(SOHQVct_Loop,AlphaVct_Loop),3)),' [\circ{C}]'])
        xlabel('Time [min]')

        n4=nexttile(4);
        yyaxis left
        grid on;box on;hold on
        plot(tout./60,Sese_packQGen_kW_fd)
        set(gca,'YLimitMethod','padded');set(gca,'XLimitMethod','tight');ylabel('kW')
        title('',['Qgen. Pack  & SoC'])

        yyaxis right
        grid on;box on;hold on
        plot(tout./60,Sese_AbsoluteSOCmax_fr_fd.*100)
        set(gca,'YLimitMethod','padded');set(gca,'XLimitMethod','tight');ylabel('%')
        title('',['Qgen. Pack (rms= ',num2str(rms(round(Sese_packQGen_kW_fd_RMS(SOHQVct_Loop,AlphaVct_Loop),2))),') & SoC'])     
        xlabel('Time [min]')

        sgtitle(['CoolIn= ',num2str(round(median(CoolTIn),1)),'[\circ{C}] -',...
            'FlowRate= ',num2str(round(median(CoolFlowRate))),'[L/min]   /  ',...            
            'Alpha= ',num2str(round((Alpha),2)),'  -  ',...   
            'SOHQ= ',num2str(round((SOHQ.*100)))...
            ])

%         print('-f',[pwd,'\ResultSim\',NameSim,'_Alpha',strrep(num2str(Alpha),'.','dot'),'_SOHQ',strrep(num2str(SOHQ.*100),'.','dot')],'-dpng')


%         (3.68996-3.41003)./200*1000

    end
end



%%
Cell_Temperature = Cell_Temperature(:,1:180);
Cell_Temperature_max_vct = max(Cell_Temperature,[],2);
Cell_Temperature_min_vct = min(Cell_Temperature,[],2);

figure('Color','w')
subplot(2,1,1)
plot(time, Cell_Temperature_max_vct,'DisplayName','Test temperature') % from experiment
hold on 
plot(time,Sese_maxCellTemperature_degC_fd,'DisplayName','Simulation temperature') % from simulation 
legend show
ylabel('\circ{C}')
title('Max Cell temperature')
grid on 
legend('Location','best')
subplot(2,1,2)
plot(time,Cell_Temperature_min_vct,'DisplayName','Test temperature')
hold on
plot(time,Sese_minCellTemperature_degC_fd,'DisplayName','Simulation temperature')
legend show
ylabel('\circ{C}')
grid on 
title('Min Cell temperature')
legend('Location','best')
xlabel('Time [s]')
sgtitle('LMDh')
% figure
% hold on
% plot(out.logsout{1}.Values.Sese_minCellVoltage_V_fd.Data)
% plot(out.logsout{5}.Values.Sese_minCellVoltage_V_fd.Data)