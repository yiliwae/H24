function TestFiles=listFiles(InputInfo)

InputFolder=fullfile(InputInfo.DataLake,InputInfo.ProjectName,InputInfo.PackName );
FileFormat=InputInfo.FileFormat;
ExcludeFolder=InputInfo.ExcludeFolder;
ProjectName=InputInfo.ProjectName;

[~,TopFolder] = fileparts(InputFolder);

%  Get directory file info ("**" -> include subfolders)
FileInfo = dir(fullfile(InputFolder,"**",FileFormat));  % list out all files match the naming pattern

if isempty(FileInfo)
    Message = "Warning: '" + TopFolder + ...
        "' folder did not contain any files of the format: " + FileFormat;
    TestFiles = [];
    LogEntry = [];
    return
end

%% Construct table of desired test files
% Note: ModifiedTime format below is set to be consistent with the provided
% catalogue file, which does not include seconds (change Format, if desired)
TestFiles=WP1.XH.FileInfoSummary_NewNaming(InputFolder,FileFormat,...
                                        ExcludeFolder,ProjectName);

end