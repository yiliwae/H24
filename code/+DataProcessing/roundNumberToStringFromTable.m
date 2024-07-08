function tbl=roundNumberToStringFromTable(tbl)

% Get the number of columns in the table
numColumns = width(tbl);

% Loop over each column
for i = 1:numColumns
    % Check if the column contains numeric data
    if isnumeric(tbl{:,i})
        % Round the numeric data to two decimal places, convert to string, and update the column
        tbl.(i)  = arrayfun(@(x) sprintf('%.1f', x), tbl{:,i}, 'UniformOutput', false);
  
    end

end


end


