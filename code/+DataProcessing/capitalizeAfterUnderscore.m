function result = capitalizeAfterUnderscore(str)
    % capitalizeAfterUnderscore Capitalizes the first letter following each underscore in a string.
    %
    % Usage:
    %    result = capitalizeAfterUnderscore('your_string_here')
    %
    % Example:
    %    result = capitalizeAfterUnderscore('Charge_for_capacity_check_Test1')
    %    % result will be 'Charge_For_Capacity_Check_Test1'
    
    % Split the string at underscores
    parts = split(str, '_');

    % Capitalize the first letter of each part
    for k = 1:length(parts)
        if ~isempty(parts{k})  % Check if part is not empty
            parts{k}(1) = upper(parts{k}(1));
        end
    end

    % Join the parts back together with underscores
    result = strjoin(parts, '');
end
