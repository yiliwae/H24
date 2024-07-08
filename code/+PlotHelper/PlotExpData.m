function fig=PlotExpData(fig, TestData)


nexttile
grid on;box on;hold on
plot(TestData.Time_Seconds, TestData.Pack.Power_kW)
ylabel('Power [kW]')
xlabel('Time [s]')
title('',['Power: P.rms= ', num2str(rms(TestData.Pack.Power_kW)),' [kW]'])


nexttile
grid on;box on;hold on
plot(TestData.Time_Seconds, TestData.Cell.MaxSoc)
hold on
plot(TestData.Time_Seconds, TestData.Cell.MinSoc)
title('Cell SOC')


nexttile
grid on;box on;hold on
plot(TestData.Time_Seconds,TestData.Cell.MaxVoltage_V)
hold on 
plot(TestData.Time_Seconds,TestData.Cell.MinVoltage_V)
title('Cell Voltage')


nexttile
grid on;box on;hold on
plot(TestData.Time_Seconds, TestData.Cell.MaxTemperature_degC)
plot(TestData.Time_Seconds, TestData.Cell.MinTemperature_degC)
title('Cell Temperature')


nexttile
grid on;box on;hold on
plot(TestData.Time_Seconds, TestData.Coolant.InletTemperature_degC,'DisplayName','Inlet')
plot(TestData.Time_Seconds, TestData.Coolant.OutletTemperature_degC,'DisplayName','Outlet')
title('Coolant Temperature ')


end