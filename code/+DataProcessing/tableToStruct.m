function S=tableToStruct(T)
S = struct();

T.Properties.VariableNames= {'name','value'}; 
% Loop through each row of the table
for i = 1:height(T)
    fn= strrep(T.name{i},' ','');
    S.(fn) = T.value(i);  % Dynamically create field and assign corresponding value
end
end