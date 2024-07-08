function [CellPar, stopState] = createCellPar

CellPar.ThermalProperties.CoolCp= 2000; % [J/kg/K]Specific thermal capacity ??it is 1808.6976 J/kg/K: https://thermalprops.paratherm.com/HTFrange.asp#
CellPar.ThermalProperties.CoolDensity = (770);   % [kg/m3] ??  based on the website, it is 988kg/m3
CellPar.ThermalProperties.ThermalRes_CellEnv= (10); % [K/W] thermal resistance cell to environment
CellPar.ThermalProperties.ThermalRes_CellCool_Cold = (3);%4.5 [K/W] the cold cell thermal resistance
CellPar.ThermalProperties.CoolFlowRate        = [20];   % unit: [L/min]. set based on Fred email
% CellPar.ThermalProperties.CoolTIn             =15 ;     % unit: [°C] set based on Fred email
% CellPar.ThermalProperties.CoolTOut            = 50 ;     % unit: [°C] set based on Fred email
CellPar.ThermalProperties.ThermalRes_CellCool_hotcell= [3]; % [K/W] thermal resistance cell to coolant
CellPar.ThermalProperties.ThermalRes_CellCool_coldcell= [2]; % [K/W] thermal resistance cell to coolant


% Cell start condition
CellPar.InitialCon.TempAmbient         = 50;      % unit: [°C] set based on Fred email that the inlet temperature is 50degC
CellPar.InitialCon.TempCellStart       = 50; % assumption by YL, the temperature variance is 6degC
% CellPar.InitialCon.TempCellStart_Cold  = 50;
CellPar.InitialCon.SOCImbalance        = (0.01);
CellPar.InitialCon.TempCellImbalance   = 7;  % unit[°C] temperature imbalance

% Stop state
stopState.HighVoltage_B = true;
stopState.LowVoltage_B = true;
stopState.HighSoc_B = false;
stopState.LowSoc_B = true;

stopState.HighSoc_Pc = 20;
stopState.LowSoc_Pc = 0;
stopState.HighVoltage_U = 4.35;
stopState.LowVoltage_U = 2.5;


end