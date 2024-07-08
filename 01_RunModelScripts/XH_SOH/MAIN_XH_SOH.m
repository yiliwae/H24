
clc
close all
clear all

% call elysia model for the BOL voltage estimation 
% use the cell temperature as input for the model , compare the result from
% EOLn drive cycle test and the real time drive cycle test
%3. use the matlab SOH estimation block for the simulation 
OutputFolderName = 'XH_SOH';
timeStep= 0.01 ; % unit: second
Ns = 204;
Np = 13; 

%% Load the data 

DataFolder= 'C:\Users\Yi.Li\OneDrive - WAE\General - Battery Performance Team\YL\Data Lake\RaceData\XH\MatFiles';
TestName= '240515141326_XH_Pack001_RacingTrack_Test01.mat';
TestName= '240516160948_XH_Pack001_RacingTrack_Test02.mat';
InputInfo.DataFactoryFolder = {'C:\Users\Yi.Li\OneDrive - WAE\General - Battery Performance Team\YL'};

InputInfo.cellModuleMapPngFile ="CatelogueVersionControl\CellModulePack_Tracker\XH_CellMapInPack.png";
InputInfo.cellModuleMapDir= string(fullfile(InputInfo.DataFactoryFolder,InputInfo.cellModuleMapPngFile));


AllTestDir = dir(fullfile(DataFolder, '*.mat'));
TableTestFiles= struct2table(AllTestDir);
TableTestFiles= DataProcessing.cellToStringFromTable(TableTestFiles);
% Filter the test restuls
idxFiles= contains(TableTestFiles.name,'Track');
TableTestFiles_Filtered= TableTestFiles(idxFiles,:);

MatDir = fullfile(TableTestFiles_Filtered.folder(1), TableTestFiles_Filtered.name(1));
load(MatDir);

TestName = strrep(TableTestFiles_Filtered.name(1), '.mat','');
TestName= strrep(TestName, '_','-')
packData= SaveData.ConvertedData.packData;
% remove outliers by specifying voltage and temperature sensor data of Super cell
logicalOutliersTotal= DataProcessing.findOutliers(packData.CellVoltage, packData.CellTemperature);

packData = DataProcessing.removeOutliers(packData, logicalOutliersTotal);


SOCstart_max           = double(packData.pc_SoC_BMS_max(1)/100);
SOCstart_min           = double(packData.pc_SoC_BMS_min(1)/100);


%% Prepare the load profile base on  current 
CellSig.TimeSeconds = packData.sec_time_abs;
CellSig.Current_A = packData.A_current_pack/Np;
CellSig.Temperature_degC_max = packData.A_current_pack/Np;

[TimeEnd, dTime,CurrentInput]=MissionHelper.InputProfileToTimeseries(CellSig.TimeSeconds,CellSig.Current_A , timeStep);
[~, ~,TemperatureInput]=MissionHelper.InputProfileToTimeseries(CellSig.TimeSeconds,CellSig.Temperature_degC_max ,timeStep);



TimeEnd= double(packData.sec_time_abs(end)+0.01);
%%  Load Bus
load([pwd,'\Data\BusObjects.mat'])




% StopTime_s = 12*3600; %unit:s
%%
SOH_R = 1;  % 0-1  this is the SOH of DCIR
SOH_Q  = flip(1);  % 0-1

% AlphaVct = [1];  % 0-1
% SOHQVct  = flip([1]);  % 0-1
% set_param(gcs,'SimulationCommand','Update')
resultTable=[];
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out = sim('MolicelP45b.slx');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


