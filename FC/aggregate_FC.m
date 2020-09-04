function aggregate_FC()

connectome_folder             = '~/HCP_Connectomes/FC/fMRIfc';
cd(connectome_folder)
subjects            =   load('~/HCP_Connectomes/SC/subject_list.txt');
excl_subjects       =   load('~/HCP_Connectomes/FC/fMRIfc/fMRI_ERROR_subjects.txt');

tmp = setdiff(subjects,excl_subjects);
subjects = tmp;

avg_a2009_fisherz_avg   = zeros(164,164);
avg_aparc_fisherz_avg   = zeros(84,84);
avg_a2009_avg           = zeros(164,164);
avg_aparc_avg           = zeros(84,84);

counter = 0;
for ii = 1:length(subjects)
    try
        load([num2str(subjects(ii)) '_FC.mat']);
       
        avg_a2009_fisherz_avg   = avg_a2009_fisherz_avg + FC.a2009_fisherz_avg;
        avg_aparc_fisherz_avg   = avg_aparc_fisherz_avg + FC.aparc_fisherz_avg;
        avg_a2009_avg           = avg_a2009_avg         + FC.a2009_avg;
        avg_aparc_avg           = avg_aparc_avg         + FC.aparc_avg;
        
        counter = counter + 1;
    catch me
        display([num2str(subjects(ii)) ': ' me.message])
        cd(connectome_folder)
        save('-7',['~/HCP_Connectomes/FC/fMRIfc/ALL_avg_ERROR.mat'])
    end
end

avg_a2009_fisherz_avg   = avg_a2009_fisherz_avg / counter;
avg_aparc_fisherz_avg   = avg_aparc_fisherz_avg / counter;
avg_a2009_avg           = avg_a2009_avg         / counter;
avg_aparc_avg           = avg_aparc_avg         / counter;

clear FC

save('-7',['~/HCP_Connectomes/FC/fMRIfc/ALL_avg_FC.mat'])


end


%%
% 
% cd('/Users/michael/Desktop/HCP_project/Connectome_pipeline/FC/scripts/')
% subjects            =   load('/Users/michael/Desktop/HCP_project/subject_list.txt');
% 
% initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:10:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0  ParaStationMPI/5.1.5-1\nmodule load Octave/4.0.3\n\n'];
% batch_line = 'srun -n 1 octave --eval "extract_FC(';
% fileID_start = fopen(['batch_extractFC'],'w');
% 
% 
% break_counter = 0;
% preproc_patch = 0;
% for ii = 1:length(subjects)
%     if break_counter == 0
%         command     = initstring;        
%     end
%     break_counter = break_counter + 1;   
%    
%     command      = [command batch_line num2str(ii)  ')" &\n'];
% 
%     if break_counter == 24 || ii == length(subjects)
%         preproc_patch = preproc_patch + 1;
%         finalstring = [command '\nwait\n'];
%         fileID = fopen(['batch_extractFC_' num2str(preproc_patch)],'w');
%         fprintf(fileID,finalstring);
%         fclose(fileID);
%         fprintf(fileID_start, ['sbatch batch_extractFC_' num2str(preproc_patch) '\n']);
%         break_counter = 0;
%     end
% end
% 
% fclose(fileID_start)
% 
