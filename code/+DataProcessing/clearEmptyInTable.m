function yourTable=clearEmptyInTable(yourTable)
% Convert table to a cell array for element-wise checking
tableAsCellArray = table2cell(yourTable);

% Initialize an array to keep track of non-empty row indices
nonEmptyRowIndices = false(size(tableAsCellArray, 1), 1);

% Loop through each row
for i = 1:size(tableAsCellArray, 1)
    % Check if all elements in the row are empty arrays
    isRowFullyEmpty = all(cellfun(@isempty, tableAsCellArray(i, :)));
    
    % If the row is not fully empty, mark its index
    if ~isRowFullyEmpty
        nonEmptyRowIndices(i) = true;
    end
end

% Use the indices to filter out fully empty rows from the original table
yourTable = yourTable(nonEmptyRowIndices, :);


end