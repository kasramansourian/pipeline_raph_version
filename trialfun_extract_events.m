
function [trl,event] = trialfun_extract_events(cfg)
%Extact task sessions and events
% trl: 
%   column 1: sample index of the task start 
%   column 2: sample index of the task end
%   column 3: "Offset of the trigger with respect to the trial" (#Always 0 for us)
%   column 4: event code = task ID (i.e. 11~17)
%   column 5: sample index of the first event in a task (e.g. first fixation in resting state)
% sample index is relative to EEG_all (all the data saved in .eeg file)

    initialize_common_variables
    hdr = ft_read_header(cfg.headerfile);
    event = ft_read_event(cfg.headerfile);

    % Load event codes and the samples at which they occur
    EVsample = [event.sample]';
    EVvalue = {event.value}';
    EVtype = {event.type}';
    
    empty = cellfun(@isempty,EVvalue);
    EVvalue=EVvalue(~empty);
    EVsample=EVsample(~empty);
    EVtype=EVtype(~empty);
    
    is_stimulus = contains(EVtype,'Stimulus');
    EVvalue=string(EVvalue(is_stimulus));
    EVsample=EVsample(is_stimulus);

    % Convert the string event codes to numbers
    all_codes=str2double(extractBetween(EVvalue,3,4));
    false_events=find(diff(EVsample)==1);
    all_codes(false_events)=[];
    EVsample(false_events)=[];
    
    % Find samples corresponding to task events
    start_code = data.constants.task_dictionary({cfg.task_name});
    start_bools=any(all_codes==start_code,2); 
    start_inds = find(start_bools); 
    start_values=all_codes(start_bools); 
    start_samples = EVsample(start_bools); 
    end_samples = [start_samples(2:end),hdr.nSamples];

    if isempty(start_samples)
        warning(['Task ID not found in events. ' cfg.task_name '(Task Code: ' num2str(start_code(1)) ')']);
        new_start_event = event(2);
        new_start_event.value = ['S ' num2str(start_code(1))];
        new_start_event.sample = max(2,new_start_event.sample - 5000);
        event = [event(1); new_start_event; event(2:end)'];
        EVsample = [EVsample(1);new_start_event.sample;EVsample(2:end)];
        start_values = start_code;
        start_inds = 2;
        start_samples = EVsample(start_inds);
    elseif length(start_samples) > 1
        % warning('Multiple Task IDs found in list of events (Only 1 per session)')
        start_inds = start_inds(1);
        start_values = start_values(1);
        start_samples = start_samples(1);
        end_samples = [start_samples(2:end),hdr.nSamples];

    end
    
    trl = zeros(length(start_samples),5);
    trl(:,1)= 1; %Start Sample of each Session
    trl(:,2)=hdr.nSamples; %End Sample of each session
    trl(:,4)=start_values*ones(length(start_samples),1); %Start Code of Task
    trl(:,5)=EVsample(start_inds+1); %Sample of First Event after Task Start
   

   
end









