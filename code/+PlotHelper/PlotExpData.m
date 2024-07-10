function fig = PlotExpData(fig, TestData)

% Create a tiled layout
t = tiledlayout(2,3);

% First plot
ax1 = nexttile;
grid on; box on; hold on;
yyaxis left
plot(TestData.Time_Seconds, TestData.Pack.Power_kW);
yyaxis right
plot(TestData.Time_Seconds, TestData.Coolant.InletTemperature_degC, 'DisplayName', 'Inlet');
ylabel('Power [kW]');
xlabel('Time [s]');

title(sprintf('Power: P.rms= %.2fkW; |P.avg|= %.2fkW; ', ...
                    rms(TestData.Pack.Power_kW), mean(abs(TestData.Pack.Power_kW))));

% Second plot
ax2 = nexttile;
grid on; box on; hold on;
plot(TestData.Time_Seconds, TestData.Cell.MaxSoc);
plot(TestData.Time_Seconds, TestData.Cell.MinSoc);
title('Cell SOC');

% Third plot
ax3 = nexttile;
grid on; box on; hold on;
plot(TestData.Time_Seconds, TestData.Cell.MaxVoltage_V);
plot(TestData.Time_Seconds, TestData.Cell.MinVoltage_V);
title('Cell Voltage');

% Fourth plot
ax4 = nexttile;
grid on; box on; hold on;
plot(TestData.Time_Seconds, TestData.Cell.MinTemperature_degC, 'DisplayName', 'Temp_{min}');
plot(TestData.Time_Seconds, TestData.Cell.MaxTemperature_degC, 'DisplayName', 'Temp_{max}');

title('Cell Temperature');
legend(Location="best")
% Fifth plot
ax5 = nexttile;
grid on; box on; hold on;
plot(TestData.Time_Seconds, TestData.Coolant.InletTemperature_degC, 'DisplayName', 'Inlet');
plot(TestData.Time_Seconds, TestData.Coolant.OutletTemperature_degC, 'DisplayName', 'Outlet');
title('Coolant Temperature');
legend(Location="best")
% Link all x-axes
linkaxes([ax1, ax2, ax3, ax4, ax5], 'x');

% Adjust layout
t.TileSpacing = 'compact';
t.Padding = 'compact';

end
