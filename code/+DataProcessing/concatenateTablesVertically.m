function resultTable = concatenateTablesVertically(table1, table2)
% CONCATENATETABLES Concatenates two tables with potentially mismatched columns
% It aligns columns by adding missing ones filled with default values.

    % List column names from both tables
    colsTable1 = table1.Properties.VariableNames;
    colsTable2 = table2.Properties.VariableNames;

    % Find columns that are not in each table
    missingInTable1 = setdiff(colsTable2, colsTable1);
    missingInTable2 = setdiff(colsTable1, colsTable2);

    % Add missing columns to table1 with default empty values
    if ~isempty(missingInTable1)
        for col = missingInTable1'
            % Determine a suitable default based on the data type in table2
            defaultVal = getDefaultForClass(class(table2.(col{1})));
            table1.(col{1}) = repmat(defaultVal, height(table1), 1);
        end
    end

    if ~isempty(missingInTable2)
        % Add missing columns to table2 with default empty values
        for col = missingInTable2'
            % Determine a suitable default based on the data type in table1
            defaultVal = getDefaultForClass(class(table1.(col{1})));
            table2.(col{1}) = repmat(defaultVal, height(table2), 1);
        end
    end

    % Concatenate the tables vertically
    resultTable = [table1; table2];
end

function defaultVal = getDefaultForClass(className)
    % Helper function to determine default values based on data type
    switch className
        case {'double', 'single', 'int8', 'int16', 'int32', 'int64', ...
              'uint8', 'uint16', 'uint32', 'uint64'}
            defaultVal = NaN;
        case 'cell'
            defaultVal = {''};
        case 'string'
            defaultVal = "";
        case 'logical'
            defaultVal = false;
        otherwise
            error(['No default value assigned for type ', className]);
    end
end
