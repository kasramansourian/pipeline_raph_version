
ekg_mask = cell2mat(cellfun(@(x) any(strcmpi(x,{'Reference Contacts','Electrode'})),data.brainvision.label,'UniformOutput',false));
if sum(ekg_mask) == 0
    ekg_mask = cell2mat(cellfun(@(x) any(strcmpi(x,{'EKG','ECG'})),data.brainvision.label,'UniformOutput',false));
end
ekg = data.brainvision.trial{1,1}(ekg_mask,:);
ekg_time = data.brainvision.brainvision_start_timestamp_unix + data.brainvision.time{1, 1}*1e3;

lfp_time = data.neural(1).combined_data_table.Timestamp;
table_size = width(data.neural(1).combined_data_table);
col_names = data.neural(1).combined_data_table.Properties.VariableNames;
lfp = table2array(data.neural(1).combined_data_table(:,3:end));

events_time = data.Events.Timestamp;
events = data.Events.Event;

figure;
ax(1) = subplot(8,1,1);
plot(ekg_time,ekg)
title('Reference Contact')

for i = 1:width(lfp)
    ax(i+1) = subplot(8,1,i+1);
    nan_mask = ~isnan(lfp(:,i));
    t = lfp_time(nan_mask);
    x = lfp(nan_mask,i);
    plot(t,x)
    title(col_names(i+2),'Interpreter', 'none')
end
ax(i+2) = subplot(8,1,i+2);
plot(events_time,events*100)
title('Event Labels')
xlabel('Unix Timestamp (msec)')
linkaxes(ax,'x')