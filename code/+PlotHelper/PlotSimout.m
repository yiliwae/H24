function fig=PlotSimout(fig, SimResults,InputPar,SOCstart)

idxDCH =  round(SimResults.Sese_packPower_kW_fd)<0;
idxCHA =  round(SimResults.Sese_packPower_kW_fd)>0;

PowerDCH_kW= SimResults.Sese_packPower_kW_fd(idxDCH);
PowerCHA_kW= SimResults.Sese_packPower_kW_fd(idxCHA);

n1=nexttile(1);
grid on;box on;hold on
plot(SimResults.tout,SimResults.Sese_packPower_kW_fd)
hold on
% plot(newTime/60,PowerKW/2)
set(gca,'YLimitMethod','padded');set(gca,'XLimitMethod','tight');
ylabel('kW')
titleStr = sprintf(['RMS P_{total}=%d [kW] \n', ...
                    'RMS P_{CHA}= %d;RMS P_{DCH}= %d '], ...
                    round(SimResults.packPower_rms_kW),...
                    round(rms(PowerCHA_kW)),round(rms(PowerDCH_kW)));
title(titleStr);
ylim([-800, 800])

n2=nexttile(2);
grid on;box on;hold on
plot(SimResults.tout,SimResults.Sese_minCellVoltage_V_fd,'DisplayName','Vcell_{cold}')
plot(SimResults.tout,SimResults.Sese_maxCellVoltage_V_fd,'DisplayName','Vcell_{hot}')
set(gca,'YLimitMethod','padded');set(gca,'XLimitMethod','tight');ylabel('V')
title('',['Cell Voltage: Vmax= ', num2str(round(SimResults.CellVolt_max_V,3)),...
    ' [V]  /  Vmin= ', num2str(round(SimResults.CellVolt_min_V,3)),' [V]'])
legend show
hline=yline(4.3, 'r--', 'LineWidth', 2,'HandleVisibility', 'off'); % 'r-' makes the line red, and 'LineWidth', 2 makes it thicker
% set(hline, 'DisplayName', 'Vcell_{max} =4.3V'); % Optional: Adds a label for legend
text(SimResults.tout(end)*0.8, 4.15, 'Vcell_{max} =4.3V', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'red');

ylim([2, 4.5])
if ~isempty(SimResults.StopReason)
    stopStr = sprintf('Lap Unfinished: Reach %s after %.2f s', SimResults.StopReason, max(SimResults.tout));
    % Use text to place the title manually
    text(SimResults.tout(end)*0.8, 3, stopStr, 'HorizontalAlignment', 'center' ,'Color','r','BackgroundColor','w');
else

    stopStr= "Finished lap";
    text(SimResults.tout(end)*0.8, 3, stopStr, 'HorizontalAlignment', 'center' ,'Color','k');
end

yyaxis right
grid on;box on;hold on
plot(SimResults.tout,SimResults.Sese_AbsoluteSOCmax_fr_fd.*100,'DisplayName','SoC')
set(gca,'YLimitMethod','padded');set(gca,'XLimitMethod','tight');ylabel('%')
title('',['Qgen. Pack (rms= ',num2str(rms(round(SimResults.packHeatGen_rms_kW,2))),') & SoC'])
xlabel('Time [s]')
ylabel('SoC [%]')
ylim([0 100])

legend(Location='bestoutside')


n3=nexttile(3);
grid on;box on;hold on
plot(SimResults.tout,SimResults.Sese_minCellTemperature_degC_fd)
plot(SimResults.tout,SimResults.Sese_maxCellTemperature_degC_fd)
xlabel('Time [s]')
hline=yline(80, 'r--', 'LineWidth', 2); % 'r-' makes the line red, and 'LineWidth', 2 makes it thicker
set(hline, 'DisplayName', 'Critical Temp = 80°C'); % Optional: Adds a label for legend
% Add text near the yline
text(SimResults.tout(end)*0.95, 80, 'Max Cell Temperature: 80°C', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'red');

set(gca, 'YLimitMethod', 'padded');
set(gca, 'XLimitMethod', 'tight');
ylabel('\circ{C}')
title(['Cell Temperature: Tmax= ', num2str(round(SimResults.CellTemp_max_degC,3)),' [\circ{C}]'])
xlabel('Time [s]')


n4=nexttile(4);
plot(SimResults.tout,SimResults.CellCurrent_A)
hold on
xlabel('Time [s]')
ylabel('Current [A]')
grid on
title('Cell current')
hline=yline(216, 'r--', 'LineWidth', 2,'HandleVisibility', 'off'); % 'r-' makes the line red, and 'LineWidth', 2 makes it thicker
text(SimResults.tout(end)*0.8, 350, 'Max pulse charge current = 216A', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'red');
hline=yline(-400, 'r--', 'LineWidth', 2,'HandleVisibility', 'off'); % 'r-' makes the line red, and 'LineWidth', 2 makes it thicker
text(SimResults.tout(end)*0.8, -420, 'Max pulse discharge current =-400A', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'red');
ylim([-450, 450])


n5=nexttile(5);
logicalIndexThermalStable= SimResults.tout>InputPar.TimeThermalStable_Start;
% logicalIndexThermalStable= SimResults.tout>2050.3 & SimResults.tout<2572.22;

rmsHeatRejection_hottest = rms(SimResults.Sese_hottestCellQreject_W_fd);
rmsHeatRejection_coldest = rms(SimResults.Sese_coldestCellQreject_W_fd);

plot(SimResults.tout,SimResults.Sese_hottestCellQreject_W_fd,'r','DisplayName','Hottest Cell')
hold on 
plot(SimResults.tout,SimResults.Sese_coldestCellQreject_W_fd,'b','DisplayName','Coldest Cell')

plot(SimResults.tout(logicalIndexThermalStable),SimResults.Sese_hottestCellQreject_W_fd(logicalIndexThermalStable),'r*','DisplayName','Hottest Cell')
xlabel('Time [s]')
ylabel('Rejected heat power [W]')
grid on
title('Cell heat rejection power [W]')
% Add text annotation for rmsHeatRejection_hottest
textPositionX = SimResults.tout(end) * 0.5; % Position text at 50% of the x-axis range
textPositionY = max(SimResults.Sese_hottestCellQreject_W_fd) * 0.9; % Position text at 90% of the maximum y value

textString_hot= sprintf('RMS Heat Rejection (Hottest): %.2f W', rmsHeatRejection_hottest);
textString_cold= sprintf('RMS Heat Rejection (Coldest): %.2f W', rmsHeatRejection_coldest);

text(textPositionX, textPositionY, textString_hot, 'FontSize', 10, 'Color', 'red');
text(textPositionX, textPositionY*0.9, textString_cold, 'FontSize', 10, 'Color', 'blue');
legend show
xlabel('Time [s]')
grid on
legend('Location','bestoutside')


n6=nexttile(6);
grid on;box on;hold on
CellHeatGen_W= SimResults.Sese_packQGen_kW_fd/(InputPar.Ns*InputPar.Np)*1000;
CellHeatGen_kJ= cumtrapz(SimResults.tout,CellHeatGen_W)/1000; %unit:kJ

rmsCellHeatGen_W= rms(CellHeatGen_W);

plot(SimResults.tout,CellHeatGen_W)

plot(SimResults.tout(logicalIndexThermalStable),CellHeatGen_W(logicalIndexThermalStable),'*')


title(sprintf('Cell heat gen: P.rms = %.2f [W]; Energy = %.2f [kJ]', ...
        rmsCellHeatGen_W, max(CellHeatGen_kJ)))
set(gca,'YLimitMethod','padded');
set(gca,'XLimitMethod','tight');
ylabel('Generated Heat Power [kW]')


n7=nexttile(7);

plot(SimResults.tout,SimResults.Sese_coolantInletTemperature_degC_fd,'DisplayName','Coolant Inlet')
hold on
plot(SimResults.tout,SimResults.Sese_coolantOutletTemperature_degC_fd,'DisplayName','Coolant Outlet')
hold on
xlabel('Time [s]')
ylabel('Coolant Temperature [°C]')
grid on
legend show


n8=nexttile(8);
% yyaxis left
% grid on;box on;hold on
% plot(SimResults.tout,SimResults.packHeatGen_kJ)
% set(gca,'YLimitMethod','padded');
% set(gca,'XLimitMethod','tight');
% ylabel('kJ')
% ylabel('Generated Heat Energy [kJ]')

% yyaxis right
plot(SimResults.tout,SimResults.Sese_packQGen_kW_fd)
set(gca,'YLimitMethod','padded');
set(gca,'XLimitMethod','tight');
ylabel('kW')
title('Pack heat generation')
ylabel('Generated Heat Power[kW]')
title(sprintf('Pack heat gen: P.rms = %.2f [kW]', rms(SimResults.Sese_packQGen_kW_fd)))




% Using sgtitle to create a super title across all subplots
titleStr = sprintf(['%s; \n  %dS%dp - SOC_{start}= %.2f [%%]; \n', ...
                    'R_{CellToCoolant-HotCell}= %.1f [K/W] -', ...
                    'R_{CellToCoolant-ColdCell}= %.1f [K/W] \n', ...
                    'Temp_{CoolantIn} = %.1f [°C]- ', ...
                    'FlowRate= %d [L/min] '], ...
                    InputPar.ProfileName,...
                    InputPar.Ns, InputPar.Np,...
                    round(SOCstart * 100, 1), ...
                    InputPar.ThermalRes_CellCool_hotcell, ...
                    InputPar.ThermalRes_CellCool_coldcell, ...
                    round(InputPar.CoolTIn, 1), ...
                    round(InputPar.CoolFlowRate, 1));

linkaxes([n1, n2, n3, n4, n5, n6, n7, n8], 'x');

sgtitle(titleStr);

end