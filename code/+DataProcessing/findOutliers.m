function logicalOutliersTotal= findOutliers(CellVoltage, CellTemperature)



%% Find voltage outliers
idx_outliers_Total=[];
for iCell =1:size(CellVoltage,2)
    cellV= CellVoltage(:,iCell);

    [~, idx_outliers] =  rmoutliers(cellV,"mean") ;
    % plot(packData.sec_time_abs(~idx_outliers), cellV(~idx_outliers),'-')
    % hold on

    idx_outliers= double(idx_outliers);
    idx_outliers_Total= [idx_outliers_Total, idx_outliers];

end

idx_outliers_Voltage= sum(idx_outliers_Total,2);



%% Find temperature outliers
idx_outliers_Total=[];
for iCell =1:size(CellTemperature,2)
    cellT= CellTemperature(:,iCell);

    [~, idx_outliers] =  rmoutliers(cellT,"mean") ;
    % plot(packData.sec_time_abs(~idx_outliers), cellV(~idx_outliers),'-')
    % hold on

    idx_outliers= double(idx_outliers);
    idx_outliers_Total= [idx_outliers_Total, idx_outliers];

end

idx_outliers_Temperature= sum(idx_outliers_Total,2);

idx_outliers_Total= idx_outliers_Temperature+idx_outliers_Voltage;

logicalOutliersTotal = idx_outliers_Total>1; 
end