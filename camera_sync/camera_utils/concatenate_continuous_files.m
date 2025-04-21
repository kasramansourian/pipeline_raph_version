% concatenate all continuous files
function video = concatenate_continuous_files(continuous_files_all,cam_num,video_load_dir,date,camera_folder_names,subject_id,savedir_AV)
for i = 1:cam_num
      files = continuous_files_all{1,i};
      for j = 1:size(files,2)
          files_to_cat = files{j};
           input = {};
           output = [subject_id,'_',date,'_',camera_folder_names{i},'_',num2str(j),'.mp4'];
           file_list = [savedir_AV,subject_id,'_',date,'_',camera_folder_names{i},'_',num2str(j),'.txt'];
          for k = 1:size(files_to_cat,2)
              input{k} = strcat("file ","'",video_load_dir{i},files_to_cat{k},"'");      
                if k ==1
                    fid = fopen(file_list,'wt');
                    fprintf(fid, '%s', input{k});                 
                    fclose(fid);
                else
                    fid = fopen(file_list,'at');
                    fprintf(fid, '\n%s', input{k});
                    fclose(fid);
                end                
          end
          
          merge_list_of_videos(savedir_AV, output, file_list)
          video(i).cams(j).file = [savedir_AV,output];
          
          % get video timecodes
          vid_path = [savedir_AV,output];
          [start_tc, start_frame, end_tc, end_frame] = get_video_timecodes(vid_path);
          
          video(i).cams(j).start_tc = start_tc;
          video(i).cams(j).end_tc = end_tc;
          video(i).cams(j).start_frame = start_frame;
          video(i).cams(j).end_frame = end_frame;


      end
end
        

end

    

