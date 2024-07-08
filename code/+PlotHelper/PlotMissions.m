function T_error = PlotMissions(results,Data)
%QUICKPLOT Summary of this function goes here
%   Detailed explanation goes here


mdlTime = results.Voltage.Time;         % Model time [s]
mdlVol = squeeze(results.Voltage.Data);         % Model voltage [V]
mdlCurr = squeeze(results.Current_Sim.Data);    % Model current [A]
mdlSoC = squeeze(results.SoC.Data);          % Model SoC [-]
mdlTemp = squeeze(results.Temp.Data);         % Model Temperature [degC]


%%
% Plot simulation outputs against measured 

 subplot(3,2,1);
plot(mdlTime/3600,mdlVol,'--r','LineWidth',1.5)
hold on
plot(Data.TimeSeconds/3600,Data.Voltage_V,' .k','LineWidth',1.5)
xlabel('Time (h)'); ylabel('Voltage (V)'); 
grid on
legend('Simulation','Experiment',Location="northeast")
% ylim([2.5 4.5])

Time_new=mdlTime;
Vol_new=interp1(Data.TimeSeconds,Data.Voltage_V,Time_new,'linear',  'extrap');

Error_vol= (mdlVol- Vol_new)*1000; % unit: [mV]

RMSE_vol = sqrt(mean((Vol_new - mdlVol).^2))*1000;

deltaOCV_init=(mdlVol(1)- Vol_new(1))*1000;
deltaOCV_end=(mdlVol(end)- Vol_new(end))*1000;
%% only calculate the discharge voltage RMSE_vol

idxDCH= find(mdlCurr<0);

ErrorDCH_vol= (mdlVol(idxDCH)- Vol_new(idxDCH))*1000; % unit: [mV]
RMSE_DCH_vol= sqrt(mean((Vol_new(idxDCH) - mdlVol(idxDCH)).^2))*1000;

%%
 subplot(3,2,2);
yyaxis left
Data.Power=Data.Current_A.*Data.Voltage_V;
plot(Data.TimeSeconds/3600,Data.Power,'LineWidth',1.5)
xlabel('Time (h)'); ylabel('Power (W)'); 
grid on
yyaxis right
plot(Data.TimeSeconds/3600,Data.Current_A,'LineWidth',1.5)
 ylabel('Current (A)'); 


% ylim([-20, 20])
subplot(3,2,3);

plot(mdlTime/3600,Error_vol,'-.','LineWidth',1.5)
hold on
xlabel('Time (h)'); ylabel('V_{sim} - V_{test} (mV)'); 
grid on
[unique_time,ia] = unique(Data.TimeSeconds);
Data=Data(ia,:);
text(0.1,0.6,['RMSE: ',num2str(RMSE_vol) ,'mV'],'Units','normalized','EdgeColor','k');


%% Bin voltage error by SOC 
% Calculate the simulation error of voltage

% plot the voltage error by 5% SOC bin 
soc_sim=mdlSoC; 

if max(soc_sim)-min(soc_sim)>5;
edges = floor(min(soc_sim)) : 5 : ceil((max(soc_sim)+.001)*10/5)*5/10; % the bin edge is 5% SOC 
bins = discretize(soc_sim, edges);


meanVal = splitapply(@mean,abs(Error_vol), bins); % Split the estimated voltage errors into different bins and apply function
maxVal = splitapply(@max,abs(Error_vol), bins); % Split the estimated voltage errors into different bins and apply function


binCenters = edges(2:end) - (edges(2)-edges(1))/2; 


%%
subplot(3,2,4)
bar(binCenters,maxVal)
hold on
plot(binCenters, meanVal,'-*')
soc_plot=[1:110];
plot(soc_plot, repmat(10, length(soc_plot),1),'--b','LineWidth',1.5)

soc_plot=[1:110];
plot(soc_plot, repmat(20, length(soc_plot),1),'--r','LineWidth',1.5)
xlim([0 105])

grid on
xlabel('SOC (%)')
ylabel('Absolute Voltage difference (mV)')
legend('Max error', 'Mean error', '10 mV limit', '20mV limit',Location="best")

set(gca, 'XDir','reverse')
end

 subplot(3,2,5);
plot(mdlTime/3600,mdlSoC,'-.','LineWidth',1.5)
xlabel('Time (h)'); ylabel('SOC (%)'); 
grid on

 subplot(3,2,6);

plot(Data.TimeSeconds/3600,Data.Temperature,'-k','LineWidth',1.5,'DisplayName','Experiment')
hold on
plot(mdlTime/3600,mdlTemp,'--r','LineWidth',1.5,'DisplayName','T_{surf} - 0 node')


xlabel('Time (hrs)'); ylabel('Temperature (°C)');
legend show
legend(Location="best")
grid on
ylim([20 30])


Temp_new=interp1(Data.TimeSeconds,Data.Temperature,Time_new,'linear',  'extrap');

% 0node temperature difference
Error_temp= (mdlTemp- Temp_new); % unit: [degC]
RMSE_temp = sqrt(mean((Temp_new - mdlTemp).^2));
deltaMaxTemp= max(mdlTemp)- max(Temp_new); 

% ax6= subplot(4,2,8);
% plot(Time_new/3600,Error_temp,'-k','LineWidth',1.5,'DisplayName','1 node')
% hold on 
% grid on 
% xlabel('Time (h)'); ylabel('\DeltaT (°C):  Tsim-Texperiment');
% 
% 
% 
% text(0.1,0.8,['1 node max TempDifference (maxT_{sim}-maxT_{test}): ',num2str(deltaMaxTemp) ,'°C'],'Units','normalized','EdgeColor','k');
% 
% 
% ylim([-20, 20])


% linkaxes([ax1,ax2, ax3,ax4],'x')


if exist("T_surf","var")
    T_error=[RMSE_vol, max(abs(Error_vol)),RMSE_DCH_vol, ...
    max(abs(ErrorDCH_vol)),deltaOCV_init, deltaOCV_end, ...
    RMSE_temp, max(abs(Error_temp)),  deltaMaxTemp,...
    RMSE_temp_1node,  max(abs(Error_temp_1node)), deltaMaxTemp_1node];

    T_error= array2table(T_error); 
    T_error.Properties.VariableNames= {'VolRMSE', 'MaxAbsVolError','VolDCH_RMSE', ...
    'MaxAbsDCHVolError','deltaOCV_init', 'deltaOCV_end',...
    'TempRMSE_0node', 'MaxAbsTempError_0node', 'deltaMaxTemp_0node',...
    'TempRMSE_1node', 'MaxAbsTempError_1node', 'deltaMaxTemp_1node'}; 

else
    T_error=[RMSE_vol, max(abs(Error_vol)),RMSE_DCH_vol, ...
    max(abs(ErrorDCH_vol)),deltaOCV_init, deltaOCV_end, ...
    RMSE_temp, max(abs(Error_temp)),  deltaMaxTemp  ];

    T_error= array2table(T_error); 
    T_error.Properties.VariableNames= {'VolRMSE', 'MaxAbsVolError','VolDCH_RMSE', ...
    'MaxAbsDCHVolError','deltaOCV_init', 'deltaOCV_end',...
    'TempRMSE', 'MaxAbsTempError', 'deltaMaxTemp'}; 

end







end

