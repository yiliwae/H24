function dataClean= removeZerosFromStruct(data)
% this function check the total zeros in each fields, if cell temperature
% or voltage singals has unusal zero values, the total count of them is
% quite high and therefore we can find the outliers 

dataTable= struct2table(data);
dataArray = table2array(dataTable);  % Convert table to array

% Count zeros in each row
zeroCount = sum(dataArray == 0, 2);  % The '2' specifies that summing should be done row-wise
idxOutliers= isoutlier(zeroCount,"mean"); 
 % remove the outlier]
% Remove outlier rows from dataTable
dataTableClean = dataTable(~idxOutliers, :);

% Initialize an empty struct
dataClean = struct();

% Loop through each column and add it to the struct
columnNames = dataTableClean.Properties.VariableNames;
for i = 1:length(columnNames)
    dataClean.(columnNames{i}) = dataTableClean.(columnNames{i});
end


end