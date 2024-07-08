function T= cellToNumberFromTable(T)

for col = 1:width(T)
    if iscell(T(:,col))  % Check if the column is a cell array
        % Initialize a numeric array to replace the cell array
        numericColumn = zeros(height(T), 1);

        % Convert each cell in the column to a numeric value
        for row = 1:height(T)
            cellContent = T{row, col}{1};  % Extract cell content
            if ischar(cellContent)  % If the content is a string
                numericColumn(row) = str2double(cellContent);  % Convert to double
            elseif isnumeric(cellContent)  % If the content is numeric
                numericColumn(row) = cellContent;  % Directly use the numeric value
            else
                error('Unsupported data type in cell.');
            end
        end

        % Replace the old cell column in the table with the numeric column
        T.(col) = numericColumn;
    end
end


end