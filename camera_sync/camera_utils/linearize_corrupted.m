chan=load_corrupted(strcat(loaddir, proc_num,"_ADC7.continuous"),true);
[ephys_ltc, TC] = ltc_decode(chan,true);
good_inds=ephys_ltc.time(:,2)<60&ephys_ltc.time(:,3)<60&ephys_ltc.frame_num<30;
total_frames=ephys_ltc.time(good_inds,1)*60*60*30+ephys_ltc.time(good_inds,2)*60*30+ephys_ltc.time(good_inds,3)*30+ephys_ltc.frame_num(good_inds);
ephys_inds=ephys_ltc.timecode_start_open_ephys(good_inds);
audio_start=[aud_ltc.time(1,:),aud_ltc.frame_num(1)];
audio_end=[aud_ltc.time(end,:),aud_ltc.frame_num(end)];
audio_start=audio_start(1)*60*60*30+audio_start(2)*60*30+audio_start(3)*30+audio_start(4);
audio_end=audio_end(1)*60*60*30+audio_end(2)*60*30+audio_end(3)*30+audio_end(4);
in_range=total_frames>=audio_start&total_frames<=audio_end;
total_frames=total_frames(in_range);
ephys_inds=ephys_inds(in_range);
median_adjusted=movmedian(total_frames,30);
mdl=fitlm(ephys_inds,median_adjusted);
timecode_inds=1:1000:length(chan);
interp_frames=mdl.Coefficients.Estimate(2)*timecode_inds+mdl.Coefficients.Estimate(1);
figure
hold on
plot(ephys_inds,total_frames)
plot(ephys_inds,median_adjusted)
plot(timecode_inds,interp_frames)

temp=interp_frames;
hours=floor(temp/(60*60*30));
temp=temp-hours*60*60*30;
mins=floor(temp/(60*30));
temp=temp-mins*60*30;
secs=floor(temp/(30));
temp=temp-secs*30;
ephys_ltc.frame_num=floor(temp)';
ephys_ltc.time=[hours',mins',secs'];
ephys_ltc.timecode_start_open_ephys=timecode_inds';