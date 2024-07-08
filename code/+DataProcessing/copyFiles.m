function TestFiles= copyFiles(TestFiles,ProjectName, DataFacFolder)

for k = 1:height(TestFiles)
            source = TestFiles.FileLocationOriginal(k);

           
                destination_folder = fullfile(DataFacFolder,ProjectName);

                if ~exist("destination_folder","dir")
                    mkdir(destination_folder)
                end
                


                destination= fullfile(destination_folder, TestFiles.FileNameNew(k));
                if ~exist(destination,"dir")

                [status,msg] = copyfile(source,destination);
                
                TestFiles.DataFactoryDir(k)= destination; 
                end

end

end