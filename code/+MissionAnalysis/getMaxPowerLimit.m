function  T_dataPowerLimit_Cell=getMaxPowerLimit(dataPowerLimitTable,Ns, Np)
SOC = arrayfun(@(x) num2str(x), 0:5:100, 'UniformOutput', false);
Temp =  {'-10', '0', '10', '20', '30', '40', '50', '60', '70', '75', '80', '90'};

% 
dataPowerLimit = table2array(dataPowerLimitTable);

% Find indices of columns that are all zero
colsToRemove = all(dataPowerLimit == 0, 1);

% Find indices of rows that are all zero
rowsToRemove = all(dataPowerLimit == 0, 2);

% Remove columns and rows that are all zero
dataPowerLimit(:, colsToRemove) = [];
dataPowerLimit(rowsToRemove, :) = [];
SOC(rowsToRemove)=[];
Temp(colsToRemove)=[];

dataPowerLimit_Cell = dataPowerLimit / Ns/Np * 1000;

% Convert array to table with row and column names
T_dataPowerLimit_Cell = array2table(dataPowerLimit_Cell, ...
                                                 'RowNames', SOC, 'VariableNames', Temp);

end