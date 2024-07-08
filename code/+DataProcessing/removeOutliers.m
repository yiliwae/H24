function structOut = removeOutliers(structIn, idxOutliers)
    % Function to remove data from struct fields with length > 1 at specified indices
    
    % Initialize output struct
    structOut = structIn;

    % Get the field names of the struct
    fields = fieldnames(structIn);

    % Loop through each field
    for i = 1:length(fields)
        fieldName = fields{i};
        fieldValue = structIn.(fieldName);
        
        % Check if the field value is a vector with length greater than 1
        if  length(fieldValue) == length(idxOutliers)
            % Remove the elements at the indices specified by idxOutliers
            fieldValue(idxOutliers,:) = [];
        end
        
        % Assign the modified field value back to the output struct
        structOut.(fieldName) = fieldValue;
    end
end
