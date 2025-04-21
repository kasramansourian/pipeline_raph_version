parent_dir = 'Z:\OCD_Data\preprocessed-data\';
subjects_all_temp = dir(parent_dir);
subjects_all_temp(1:2) = [];
not_folders = find([subjects_all_temp.bytes]>0);
subjects_all_temp(not_folders) = [];
subjects_all = {subjects_all_temp.name};

for i = 1:length(subjects_all)
    subject = subjects_all{i};
    dates_all_temp = dir([parent_dir,subject]);
    dates_all_temp(1:2) = [];
    dates_all = {dates_all_temp.name};
    for j = 1:length(dates_all)
        date = dates_all{j};
        if isempty(str2num(date(1)))
        else
            old_savedir_AV = [parent_dir,subject,'\',date,'\AV_preprocessing\'];
            new_savedir_AV = ['Z:\OCD_Data\AV_preprocessing\',subject,'\',date,'\'];
            
            if exist(old_savedir_AV)
                if ~exist(new_savedir_AV)
                    mkdir(new_savedir_AV)
                end
                movefile(old_savedir_AV, new_savedir_AV)
            end
        end
    end
end

