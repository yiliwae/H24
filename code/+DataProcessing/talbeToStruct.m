function OutputStruct= talbeToStruct(InputTable,InputColumn )


% Initialize an empty struct
OutputStruct = struct();

% Ensure FieldName is a cell array for dynamic field name access
fieldNames = cellstr(InputTable.FieldName);

% Loop through each row of the table
for i = 1:height(InputTable)
    % Use dynamic field names for struct. Convert string array to cell array if necessary.
    OutputStruct.(fieldNames{i}) = InputTable.(string(InputColumn))(i);
end


end