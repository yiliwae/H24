function SimCaseTable= ComvecSimcase(combinations, InputProfile)


SimCaseTable = array2table(combinations, 'VariableNames', ...
                                          {'Ns', 'Np', 'CoolantInTemp_degC', ...
                                          'CoolantFlowRate', 'PowerFudgeFactor'});
SimCaseTable.InputProfile = repmat(InputProfile, size(SimCaseTable,1),1); 

% load the existing simulation cases from 
existingSimDir= fullfile(pwd, "02_SimOutput",InputProfile,strcat(InputProfile,"_SimulationResult.xlsx"));

if  exist(existingSimDir, 'file') == 2
     disp('Existed simulation results')
     existSimTable= readtable(existingSimDir);
     % check if the simulation scenario already existed 
     % Define the key columns
    keyColumns = {'Ns', 'Np', 'CoolantInTemp_degC', 'CoolantFlowRate', 'PowerFudgeFactor'};
    % Extract the key values as strings for comparison
    simCaseKeys = string(SimCaseTable{:, keyColumns});
    existSimKeys = string(existSimTable{:, keyColumns});
    % Find the indices of rows in SimCaseTable that are not in existSimTable
    [~, idxNotInExistSimTable] = setdiff(simCaseKeys, existSimKeys, 'rows');
    
    % only use the new case for simulation 
    SimCaseTable=SimCaseTable(idxNotInExistSimTable,:);

    SimCaseTable.SimNo= [max(existSimTable.SimNo)+1:max(existSimTable.SimNo)+length(idxNotInExistSimTable)]';

else % if not exist the file then just create case number 
    
    SimCaseTable.SimNo= [1:size(SimCaseTable,1)]';

end

% Reorder columns to place 'SimNo' as the first column
SimCaseTable = SimCaseTable(:, {'InputProfile','SimNo', 'Ns', 'Np', 'CoolantInTemp_degC', 'CoolantFlowRate', 'PowerFudgeFactor'});


end