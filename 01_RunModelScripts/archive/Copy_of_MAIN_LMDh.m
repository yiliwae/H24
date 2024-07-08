clc
close all
clear all

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


% load('R03 - Drivecycle WAE D2R03 760-BET-023_CyclingData.mat')
% load('RLL_25_Daytona_24_Stint_CyclingData.mat')
time = [0:0.1:2]';
Batt_Current = 200.*ones(length(time),1);

NameSim = 'Pulse';
TimeEnd = max(time);
dTime   = time(2,1)-time(1,1);


% figure
% plot(Cell_Temperature)
% max(max(Cell_Temperature(:,1:180)))
% Load Bus 
load([pwd,'\Data\BusObjects.mat'])

% Pack Configuration
Ns = 180;
Np = 1;

% Coolant
TempAmbient         = (30);%
CoolTIn             = (55);
CoolFlowRate        = (1);
CoolCp              = (2000);
CoolDensity         = (770);
ThermalRes_CellEnv  = (8);
ThermalRes_CellCool = (4.8);%4.5

% Cell start condition
SOCstart      = (0.50);
TempCellStart = (55);
SOCImbalance  = (0.01);

AlphaVct = [1];  % 0-1
SOHQVct  = flip([1]);  % 0-1
for AlphaVct_Loop = 1:length(AlphaVct)

    for SOHQVct_Loop = 1:length(SOHQVct)
        Alpha = (AlphaVct(AlphaVct_Loop));
        SOHQ  = (SOHQVct(SOHQVct_Loop));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Out = sim('LMDh.slx');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        % Save Output
        tout = Out.tout;
        Sese_packCurrent_A_fd = Out.logsout{1}.Values.Sese_packCurrent_A_fd.Data;
        Sese_packVoltage_V_fd = Out.logsout{1}.Values.Sese_packVoltage_V_fd.Data;
        Sese_packPower_V_fd   = Sese_packCurrent_A_fd.*Sese_packVoltage_V_fd./1000;
        Sese_packQGen_kW_fd   = Out.logsout{1}.Values.Sese_packQGen_kW_fd.Data;

        Sese_minCellVoltage_V_fd        = Out.logsout{1}.Values.Sese_minCellVoltage_V_fd.Data;
        Sese_maxCellVoltage_V_fd        = Out.logsout{1}.Values.Sese_maxCellVoltage_V_fd.Data;
        Sese_AbsoluteSOCmin_fr_fd       = Out.logsout{1}.Values.Sese_AbsoluteSOCmin_fr_fd.Data;
        Sese_AbsoluteSOCmax_fr_fd       = Out.logsout{1}.Values.Sese_AbsoluteSOCmax_fr_fd.Data;
        Sese_minCellTemperature_degC_fd = Out.logsout{2}.Values.Sese_minCellTemperature_degC_fd.Data;
        Sese_maxCellTemperature_degC_fd = Out.logsout{2}.Values.Sese_maxCellTemperature_degC_fd.Data;


        Sese_packPower_V_fd_rms(SOHQVct_Loop,AlphaVct_Loop)             = rms(Sese_packPower_V_fd);
        Sese_packCurrent_A_fd_rms(SOHQVct_Loop,AlphaVct_Loop)           = rms(Sese_packCurrent_A_fd);
        Sese_maxCellTemperature_degC_fd_MAX(SOHQVct_Loop,AlphaVct_Loop) = max(Sese_maxCellTemperature_degC_fd);
        Sese_maxCellVoltage_V_fd_MAX(SOHQVct_Loop,AlphaVct_Loop)        = max(Sese_maxCellVoltage_V_fd);
        Sese_minCellVoltage_V_fd_MIN(SOHQVct_Loop,AlphaVct_Loop)        = min(Sese_minCellVoltage_V_fd);
        Sese_packQGen_kW_fd_RMS(SOHQVct_Loop,AlphaVct_Loop)             = rms(Sese_packQGen_kW_fd);
        Sese_packQGen_kW_fd_MAX(SOHQVct_Loop,AlphaVct_Loop)             = max(Sese_packQGen_kW_fd);


        figure('Color','White','Name',['Alpha=',num2str(Alpha),'- SOHQ',num2str(SOHQ)],'Position',[680,307,947,671])
        tiledlayout(2,2,"TileSpacing","compact","Padding","compact")

        n1=nexttile(1);
        grid on;box on;hold on
        plot(tout./60,Sese_packPower_V_fd)
        set(gca,'YLimitMethod','padded');set(gca,'XLimitMethod','tight');ylabel('kW')
        title('',['Power: P.rms= ', num2str(round(Sese_packPower_V_fd_rms(SOHQVct_Loop,AlphaVct_Loop))),' [kW]'])

        n2=nexttile(2);
        grid on;box on;hold on
        plot(tout./60,Sese_minCellVoltage_V_fd)
        plot(tout./60,Sese_maxCellVoltage_V_fd)
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

        print('-f',[pwd,'\ResultSim\',NameSim,'_Alpha',strrep(num2str(Alpha),'.','dot'),'_SOHQ',strrep(num2str(SOHQ.*100),'.','dot')],'-dpng')



    end
end

writematrix(Sese_maxCellTemperature_degC_fd_MAX,[NameSim,'ResultSim.xlsx'],'Sheet','Tmax')
writematrix(Sese_minCellVoltage_V_fd_MIN,[NameSim,'ResultSim.xlsx'],'Sheet','Vmin')
writematrix(Sese_maxCellVoltage_V_fd_MAX,[NameSim,'ResultSim.xlsx'],'Sheet','Vmax')
writematrix(Sese_packQGen_kW_fd_RMS,[NameSim,'ResultSim.xlsx'],'Sheet','Qgen_rms')
writematrix(Sese_packQGen_kW_fd_MAX,[NameSim,'ResultSim.xlsx'],'Sheet','Qgen_max')


% 
% figure
% plot(INPUTPOWER)