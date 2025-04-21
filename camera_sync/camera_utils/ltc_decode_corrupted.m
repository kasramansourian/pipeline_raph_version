function [ltc,data] = ltc_decode(fileName)
%[frame_num,time] = ltc_decode('time-code-systems-test.mat');

% ltc_decode filename takes a mat filename of a mat file containing data, timestamps, and
% info, and outputs frame number per second, and time. Time is formatted
% such that the first column is hours, the second column is minutes, and
% the 3rd column is seconds. 

% the "pull bits from data section" could probably be a lot faster - for long recordings this will have to 
% be done in chunks. 
% Also, I hard-coded that we are dropping the first bit if the number of bits is not even -- this might have
% to be changed... is there ever a situation where we'd need to drop the
% last bit instead? not sure... 

%% Load data
%[data, timestamps, info] = load_open_ephys_data(fileName);
%load('open_ephys_pulse_test.mat')
if ~isstring(fileName)
    data = fileName;
else
    if endsWith(fileName, ".continuous")
        data = load_open_ephys_data_faster(fileName);
    elseif endsWith(fileName, ".wav")
        [data, audio_fs] = audioread(fileName);
        data = data(:, 1);
        ltc.audio_fs = audio_fs;
        %data = data(10^6:end);
    else
        load(fileName)
    end
end
sync = [0 0 1 1 1 1 1 1 1 1 1 1 1 1 0 1]'; % sync word for LTC

data = data - mean(data); % correct DC offset (if there is no DC offset, comment out)
figure
plot(data)
prompt = 'Does this file contain Syncbac data?';
sync_bool = input(prompt);
if sync_bool
    prompt = 'Where does Syncbac begin?';
    start = input(prompt);
    close
    data = data(start:end);
    dataLength = size(data); %% length of data

    ltcBitSize = zeros(80,1); %set LTC bit size (80bit)

    % plot data & threshold
    figure;
    ax(1)=subplot(2,1,1);
    plot(data)
    ylim([-2 2])
    xlim([0 1000])
    ltc.thresh=zeros(size(data));
    % THRESH CHANGED FOR CORRUPTION (mean(data))
    ltc.thresh(data>=-1)=1;
    ax(2)=subplot(2,1,2);
    plot(ltc.thresh)
    ylim([-2 2])
    xlim([0 1000])

    linkaxes(ax,'x')
    edges=[1;find(diff(ltc.thresh)==1 | diff(ltc.thresh)==-1)]; % get transistions in data
    %% Pull bits from data
    figure
    plot(edges(1:end-1), diff(edges))

    bit_length = zeros(size(edges,1)-1,3);
    bit_length(:,1)= ltc.thresh(edges(2:end));
    bit_length(:,2) = diff(edges);
    prompt = 'Choose a cutoff value.';
    cutoff = input(prompt);
    close

    bits = [];
    bit_indices=[];
    for i = 1:size(bit_length,1)
        if bit_length(i,2)<=cutoff
            bits = [bits;1];
            bit_indices = [bit_indices;edges(i+1)];
        else
            bits = [bits;0;0];
            bit_indices = [bit_indices;edges(i+1);edges(i+1)];
        end
    end
    %{
    if not(mod(size(bits,1),2)==0)
        bits(1) = [];
    end
    %}
    %% SMPTE decoding
    nBits = length(bits); % length of inputData
    if mod(nBits,2)==0 && sum(bits(mod(1:nBits, 2)==0)) ~= sum(bits)/2% check if array is even
        bits = bits(2:end-1);
    elseif mod(nBits,2)~=0
        temp_bits = bits(2:end);
        if sum(temp_bits(mod(1:nBits, 2)==0)) ~= sum(temp_bits)/2
            bits = bits(1:end-1);
        else
            bits = bits(2:end);
        end
    end
    nBits = length(bits);

    % preallocate decodedData as array of doubles, for speed. Faster than
    % handling strings. Array is converted to string after decoding. 
    decodedData = nan(1,floor(nBits/2)); 
    decodedData_ind = nan(1,floor(nBits/2)); 

    for i = 2:2:nBits % count from max. size downwards with steps of 2
        decodedData(floor(i/2)) = bits(i); 
        decodedData_ind(floor(i/2)) = bit_indices(i);
    end
    decodedData = rmmissing(decodedData);
    decodedData_ind = rmmissing(decodedData_ind);
    decodedData= decodedData';
    decodedData_ind=decodedData_ind';

    %% Find index of first sync word in data
    sync_ind = [];
    sync_ind_open_ephys = [];
    for i = 1:(size(decodedData,1)-size(sync,1)-1)
        if decodedData(i:(i+size(sync,1)-1)) == sync
            sync_ind = [sync_ind;i];
            sync_ind_open_ephys = [sync_ind_open_ephys;decodedData_ind(i)];
        end
    end

    ltc.timecode_start_open_ephys = sync_ind_open_ephys;

    if ltc.timecode_start_open_ephys(1)<0
        ltc.timecode_start_open_ephys(1)=[];
    end
    %% Extract timestamps and frame numbers within the second
    % https://en.wikipedia.org/wiki/Linear_timecode
    C=mat2cell(ltc.thresh,1024*ones(length(ltc.thresh)/1024,1),1);
    max_runs=arrayfun(@(x) max(diff(find([1;diff(x{1});1]~=0))), C);
    bad_region_inds=find(max_runs>18);
    bad_regions=zeros(2,length(bad_region_inds));
    bad_regions(1,:)=bad_region_inds*1024-1024+1;
    bad_regions(2,:)=bad_region_inds*1024;
    length_uncorrupted=zeros(1,length(sync_ind));
    for i=1:length(sync_ind_open_ephys)
        if sync_ind_open_ephys(i)-1600>0 
            for j=1:length(bad_regions)
                if bad_regions(1,j) > sync_ind_open_ephys(i)
                    length_uncorrupted(i)=2000;
                    break
                end
                if (sync_ind_open_ephys(i)-1600>=bad_regions(1,j)&&sync_ind_open_ephys(i)-1600<=bad_regions(2,j)) ...
                    || (sync_ind_open_ephys(i)-1600<=bad_regions(1,j)&&sync_ind_open_ephys(i)>=bad_regions(2,j))
                    length_uncorrupted(i)=sync_ind_open_ephys(i)-bad_regions(2,j)+400;
                    break
                end
            end
        end
    end
    figure
    hold on
    plot(ltc.thresh)
    plot(decodedData_ind,decodedData,'o')
    plot(sync_ind_open_ephys(length_uncorrupted==2000),ltc.thresh(sync_ind_open_ephys(length_uncorrupted==2000)),'o')

    [ltc.frame_num,ltc.time] = bits2timecode(sync_ind(length_uncorrupted==2000),decodedData);
else
    close
    ltc.thresh = [];
    ltc.timecode_start_open_ephys = [];
    ltc.frame_num = [];
    ltc.time = [];
end
end