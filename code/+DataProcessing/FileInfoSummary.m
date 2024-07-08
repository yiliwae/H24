function TestFiles=FileInfoSummary(DataFolder,FileFormat,ExcludeFolder,ProjectName)

arguments
    DataFolder (1,:) {mustBeText}
    FileFormat (1,:) {mustBeText}
    ExcludeFolder (1,:) string
    ProjectName (1,:) {mustBeText}
end


[~,TopFolder] = fileparts(DataFolder);

FileInfo = dir(fullfile(DataFolder,"**",FileFormat));

FileName = string({FileInfo.name})';
MainFolder = repmat(TopFolder,numel(FileInfo),1);
FileFolder = string({FileInfo.folder})';
ModifiedTime = datetime({FileInfo.date},Format="dd/MM/yyyy HH:mm")';
FileSize_Mb = [FileInfo.bytes]'*1e-6;
FileLocationOriginal = fullfile(FileFolder,FileName);
FileFolder = extractAfter(FileFolder,DataFolder+filesep);

%% parse the subfolder name to extract Unit number, test name 

% Regular expression to match "\Unit" followed by any characters until a backslash or end of string
pattern = '\\Unit \d+\\?';  % The pattern \Unit followed by a space, 
                            % one or more digits, and an optional backslash

unitNumbers = regexp(FileFolder, pattern, 'match');
unitNumbers = strrep(cellstr(unitNumbers), '\',''); % remove \
unitNumbers = strrep(cellstr(unitNumbers), ' ',''); % remove empty space

%% parse the first layer of subfolder information, e.g. First EOL, or Second EOL

% Extract the part of each string before the first backslash
% Extrat the main subfolders and show what kind of EOLn tes is this 
TestInfo = extractBefore(FileFolder, '\'); 

%% Combine all parsed information together to form a list of all test data
TestFiles = table(FileName,unitNumbers, TestInfo, MainFolder,FileFolder, ...
    ModifiedTime,FileSize_Mb,FileLocationOriginal);

%% Filter out the files which in the folder that we want to exclude
exclude_row = contains(TestFiles.FileFolder,ExcludeFolder,IgnoreCase=true);
TestFiles= TestFiles(~exclude_row, :); 

TestFiles.Warning = strings(length(TestFiles.FileName), 1);
%% Parse the EOLn test name from FileName

% 1. Get the Test Date, if dates in the file Name, then stay empty 

% Regular expression to match exactly 12 digits
pattern = '\d{12}';

% Extract numbers matching the pattern or return an empty string if no match is found
extractedDates = regexp(TestFiles.FileName, pattern, 'match', 'once');

% Replace empty cells with an empty string or a placeholder
% This ensures that you have a consistent output format
TestFiles.Warning(cellfun(@isempty, extractedDates)) ="Missing Test Dates; " + ...
    ""; 

extractedDates(cellfun(@isempty, extractedDates)) = {'xxxxxxxxxxxx'};

TestFiles.TestDates= extractedDates; 



%% Parse the subpack name
% find if there is SP in the FileName, if yes, get Subpack name, if no, get
% empty space


% Loop over the list of strings to extract the desired information
for i = 1:length(TestFiles.FileName)
    if contains(TestFiles.FileName(i), "SP")
        % Use regular expression to extract "SP" followed by any number of digits
        match = regexp(TestFiles.FileName(i), 'SP\d*', 'match');
        if ~isempty(match)
            TestFiles.SubPacks(i) = string(match{1});
        end

    else
        % If "SP" is not found, or there's no following number, leave it as an empty string
        TestFiles.SubPacks(i) = "SPx";

        TestFiles.Warning(i) = TestFiles.Warning(i)+"Missing Subpack ID; "; 

    end

end

%% Parse the test type name 

EOLnTestList= ["cap ",  "DCIR ",  "Drive cycle ",  "Performance"];
standardizedTestName= ["CapCheck","DCIR","DriveCycle","Performance"]; 

for tt= 1:length(EOLnTestList)
    % find if the FileName contains this type of test 
    TestType= EOLnTestList(tt);
    
    % Normalize EOLnTestList1 by removing spaces and converting to lowercase
    normalizedTestType = lower(replace(TestType, " ", ""));
    
    % Normalize TestFiles.FileName
    normalizedFileName = lower(replace(TestFiles.FileName, " ", ""));

     % Normalize FileFolder
    normalizedFolderName = lower(replace(TestFiles.FileFolder, " ", ""));


    testLogical= contains(normalizedFileName, normalizedTestType)|contains(normalizedFolderName, normalizedTestType); 
    
    
    TestFiles.NewTestName (testLogical)= standardizedTestName(tt);

end

%% find the empty column in NewTestName and replace it with xxxTest
idxEmpty= ismissing(TestFiles.NewTestName);
TestFiles.NewTestName(idxEmpty)= "xxxTest"; 

TestFiles.Warning(idxEmpty) =TestFiles.Warning(idxEmpty) + "Missing Test Name"; 

%% Create new matfile Name with format of BoostCharger_Capacity_Unit1_SP1_230907161739

TestFiles.FileNameNew= ProjectName +"_"+string(TestFiles.unitNumbers)...
                        +"_"+string(TestFiles.SubPacks)+"_" +string(TestFiles.NewTestName) ...
                        + "_"+string(TestFiles.TestDates) +".mat";

end