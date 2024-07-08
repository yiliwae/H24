function [packData,sec_time_abs]= testTimeConversion(headers, data,Test_Data)

usedatasecs = find(contains(headers,"SecondsIntoExport"));
if ~isempty(usedatasecs)
    name.time    = headers{usedatasecs};
    sec_time_abs = data.(name.time);%absolute time in secs
else
    time_id = find(max(cellfun(@width,struct2cell(data))),1,'first');
    if max(cellfun(@width,struct2cell(data))) == 2
        time_temp    = data.(headers{time_id});
        sec_time_abs = time_temp(:,1);
        clear time_temp
    else
        Hz = Test_Data.SampleRate;
        array_length = max(cellfun(@height,struct2cell(data)));
        sec_time_abs = [0:array_length-1].'.*1./Hz; %Arbitrary absolute time axis in secs
    end
end
% sec_time_rel %relative time in HH:MM:SS
sec_time_sample              = sec_time_abs(10)-sec_time_abs(9); %timebase calculated as sec_time_abs(2) - sec_time_abs(1)
packData.Hz_frequency_sample = 1./sec_time_sample; %sample frequency calculated as 1/sec_time_sample
packData.sec_duration_test   = sec_time_abs(end)-sec_time_abs(1);

end