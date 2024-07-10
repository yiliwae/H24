function TestData= selectData(data,idxSelectData)
% This function is used to standardize the signal name from the input data,
% and categorize the signals based on the components 

%%

TestData.Time_Seconds= data.SecondsIntoExport(idxSelectData);
TestData.Time_Seconds= TestData.Time_Seconds-TestData.Time_Seconds(1);
TestData.Pack.Power_kW= data.BattHV_Power_kW(idxSelectData);
TestData.Pack.Voltage_V= data.Batt_Voltage(idxSelectData);

TestData.Cell.MaxTemperature_degC= data.Batt_MaxCellTemperature(idxSelectData);
TestData.Cell.MinTemperature_degC= data.Batt_MinCellTemperature(idxSelectData);
TestData.Cell.MaxSoc= data.BattHV_MaxSoC(idxSelectData);
TestData.Cell.MinSoc= data.BattHV_MinSoC(idxSelectData);
TestData.Cell.MinCellTemperature_degC= data.Batt_MinCellTemperature(idxSelectData);


TestData.Coolant.InletPressure_bar= data.Sip_PressureClntInlet_bar(idxSelectData);
TestData.Coolant.OutletPressure_bar= data.Sip_PressureClntOutlet_bar(idxSelectData);
TestData.Coolant.InletTemperature_degC= data.Shtcl_ClntTempInlet_Te(idxSelectData);
TestData.Coolant.OutletTemperature_degC= data.Shtcl_ClntTempOutlet_Te(idxSelectData);
TestData.Pack.Current_A = data.Batt_Current(idxSelectData);

%%
fn= fieldnames(data);
logicalIdx_volSig=  contains(fn,'Cell_Voltage');

VolSig_Cell= fn(logicalIdx_volSig);

for iCell =1:length(VolSig_Cell)
    cellVol= data.(VolSig_Cell{iCell}); 
  
TestData.Cell.Voltage_V(:,iCell)=  cellVol(idxSelectData);
end

TestData.Cell.MaxVoltage_V=max(TestData.Cell.Voltage_V,[],2);
TestData.Cell.MinVoltage_V=min(TestData.Cell.Voltage_V,[],2);
end