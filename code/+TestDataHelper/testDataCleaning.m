function TestData= testDataCleaning(data,removeRestSwitch)
% This function is used to standardize the signal name from the input data,
% and categorize the signals based on the components 

%% remove the initial resting period 
switch removeRestSwitch
    case 'On'
    psObj = Battery.PulseSequence;
    time=  data.SecondsIntoExport;
    voltage= data.Batt_Voltage;
    current=  data.Batt_Current;
    
    addData(psObj,time,voltage,current);
    createPulses(psObj,...
        'CurrentOnThreshold',5);
    
    idxLoadStart= psObj.idxLoad(1) - 5;
    idxLoadEnd= psObj.idxLoad(end) +10;
    case 'Off'
    idxLoadStart= 1;
    idxLoadEnd= length( data.Batt_Voltage);
end
%%

TestData.Time_Seconds= data.SecondsIntoExport(idxLoadStart:idxLoadEnd);
TestData.Time_Seconds= TestData.Time_Seconds-TestData.Time_Seconds(1);
TestData.Pack.Power_kW= data.BattHV_Power_kW(idxLoadStart:idxLoadEnd);
TestData.Pack.Voltage_V= data.Batt_Voltage(idxLoadStart:idxLoadEnd);

TestData.Cell.MaxTemperature_degC= data.Batt_MaxCellTemperature(idxLoadStart:idxLoadEnd);
TestData.Cell.MinTemperature_degC= data.Batt_MinCellTemperature(idxLoadStart:idxLoadEnd);
TestData.Cell.MaxSoc= data.BattHV_MaxSoC(idxLoadStart:idxLoadEnd);
TestData.Cell.MinSoc= data.BattHV_MinSoC(idxLoadStart:idxLoadEnd);
TestData.Cell.MinCellTemperature_degC= data.Batt_MinCellTemperature(idxLoadStart:idxLoadEnd);


TestData.Coolant.InletPressure_bar= data.Sip_PressureClntInlet_bar(idxLoadStart:idxLoadEnd);
TestData.Coolant.OutletPressure_bar= data.Sip_PressureClntOutlet_bar(idxLoadStart:idxLoadEnd);
TestData.Coolant.InletTemperature_degC= data.Shtcl_ClntTempInlet_Te(idxLoadStart:idxLoadEnd);
TestData.Coolant.OutletTemperature_degC= data.Shtcl_ClntTempOutlet_Te(idxLoadStart:idxLoadEnd);
TestData.Pack.Current_A = data.Batt_Current(idxLoadStart:idxLoadEnd);

%%
fn= fieldnames(data);
logicalIdx_volSig=  contains(fn,'Cell_Voltage');

VolSig_Cell= fn(logicalIdx_volSig);

for iCell =1:length(VolSig_Cell)
    cellVol= data.(VolSig_Cell{iCell}); 
  
TestData.Cell.Voltage_V(:,iCell)=  cellVol(idxLoadStart:idxLoadEnd);
end

TestData.Cell.MaxVoltage_V=max(TestData.Cell.Voltage_V,[],2);
TestData.Cell.MinVoltage_V=min(TestData.Cell.Voltage_V,[],2);
end