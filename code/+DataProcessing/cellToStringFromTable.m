function clean_table=cellToStringFromTable(T)
% remove the empty rows
nonEmptyRows = any(~ismissing(T), 2);
T = T(nonEmptyRows, :);
T=DataProcessing.clearEmptyInTable(T);

columnname = T.Properties.VariableNames;
for  i=1:length(columnname) %where yourcharcolumnnames is a cell array of the char column names
    col= T.(columnname{i});
    if iscell(col)
    T.(columnname{i}) = string(T.(columnname{i}));
    
    end
    % T.(columnname{i}) = strrep(T.(columnname{i}), '"', '');
    clean_table=T;
end


                
end