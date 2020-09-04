function extract_FC(sub_ii)

connectome_folder             = '~/HCP_Connectomes/FC/';
cd(connectome_folder)
subjects            =   load('~/HCP_Connectomes/SC/subject_list.txt');


%%%%%%%%%%%%%%%%%%%%%%%
% Mapping between atlases
%%%%%%%%%%%%%%%%%%%%%%%
% 
% fc_2_sc_aparc(1:34)     = 1:34;     % from aparc
% fc_2_sc_aparc(35:39)    = 1:5;      % From subcortical
% fc_2_sc_aparc(40:42)    = 7:9;      % From subcortical
% fc_2_sc_aparc(43:49)    = 12:18;    % From subcortical
% fc_2_sc_aparc(50:83)    = 50:83;    % from aparc
% fc_2_sc_aparc(84)       = 11;       % from subcortical
% 
% 
% fc_2_sc_a2009(1:74)     = 1:74;     % from a2009
% fc_2_sc_a2009(75:79)    = 1:5;      % From subcortical
% fc_2_sc_a2009(80:82)    = 7:9;      % From subcortical
% fc_2_sc_a2009(83:89)    = 12:18;    % From subcortical
% fc_2_sc_a2009(90:163)   = 90:163;   % from a2009
% fc_2_sc_a2009(164)      = 11;       % from subcortical

%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%


for ii = sub_ii
    try
        cd(connectome_folder)  
        cd(num2str(subjects(ii)))
        
        FC.id = subjects(ii);
        fMRI.id = subjects(ii);
        
        ts_aparc_REST1_LR          = load([num2str(subjects(ii)) '_FC_REST1_LR_aparc.ptseries.txt']); 
        ts_a2009_REST1_LR          = load([num2str(subjects(ii)) '_FC_REST1_LR_a2009.ptseries.txt']);  
        ts_subco_REST1_LR          = load([num2str(subjects(ii)) '_FC_REST1_LR_subcort.ptseries.txt']); 
        ts_aparc_REST1_RL          = load([num2str(subjects(ii)) '_FC_REST1_RL_aparc.ptseries.txt']); 
        ts_a2009_REST1_RL          = load([num2str(subjects(ii)) '_FC_REST1_RL_a2009.ptseries.txt']);  
        ts_subco_REST1_RL          = load([num2str(subjects(ii)) '_FC_REST1_RL_subcort.ptseries.txt']);        
        ts_aparc_REST2_LR          = load([num2str(subjects(ii)) '_FC_REST2_LR_aparc.ptseries.txt']); 
        ts_a2009_REST2_LR          = load([num2str(subjects(ii)) '_FC_REST2_LR_a2009.ptseries.txt']);  
        ts_subco_REST2_LR          = load([num2str(subjects(ii)) '_FC_REST2_LR_subcort.ptseries.txt']); 
        ts_aparc_REST2_RL          = load([num2str(subjects(ii)) '_FC_REST2_RL_aparc.ptseries.txt']); 
        ts_a2009_REST2_RL          = load([num2str(subjects(ii)) '_FC_REST2_RL_a2009.ptseries.txt']);  
        ts_subco_REST2_RL          = load([num2str(subjects(ii)) '_FC_REST2_RL_subcort.ptseries.txt']);   
        

        fMRI.a2009_REST1_LR       = rearrange_matrix(ts_a2009_REST1_LR, ts_subco_REST1_LR,subjects(ii));
        fMRI.a2009_REST1_RL       = rearrange_matrix(ts_a2009_REST1_RL, ts_subco_REST1_RL,subjects(ii));
        fMRI.a2009_REST2_LR       = rearrange_matrix(ts_a2009_REST2_LR, ts_subco_REST2_LR,subjects(ii));
        fMRI.a2009_REST2_RL       = rearrange_matrix(ts_a2009_REST2_RL, ts_subco_REST2_RL,subjects(ii));
        fMRI.aparc_REST1_LR       = rearrange_matrix(ts_aparc_REST1_LR, ts_subco_REST1_LR,subjects(ii));
        fMRI.aparc_REST1_RL       = rearrange_matrix(ts_aparc_REST1_RL, ts_subco_REST1_RL,subjects(ii));
        fMRI.aparc_REST2_LR       = rearrange_matrix(ts_aparc_REST2_LR, ts_subco_REST2_LR,subjects(ii));
        fMRI.aparc_REST2_RL       = rearrange_matrix(ts_aparc_REST2_RL, ts_subco_REST2_RL,subjects(ii));

        FC.a2009_REST1_LR        = corr(fMRI.a2009_REST1_LR);
        FC.a2009_REST1_RL        = corr(fMRI.a2009_REST1_RL);
        FC.a2009_REST2_LR        = corr(fMRI.a2009_REST2_LR);
        FC.a2009_REST2_RL        = corr(fMRI.a2009_REST2_RL);        
        FC.aparc_REST1_LR        = corr(fMRI.aparc_REST1_LR);
        FC.aparc_REST1_RL        = corr(fMRI.aparc_REST1_RL);
        FC.aparc_REST2_LR        = corr(fMRI.aparc_REST2_LR);
        FC.aparc_REST2_RL        = corr(fMRI.aparc_REST2_RL);
        
        FC.a2009_REST1_LR_fisherz    = atanh(FC.a2009_REST1_LR);
        FC.a2009_REST1_RL_fisherz    = atanh(FC.a2009_REST1_RL);
        FC.a2009_REST2_LR_fisherz    = atanh(FC.a2009_REST2_LR);
        FC.a2009_REST2_RL_fisherz    = atanh(FC.a2009_REST2_RL);        
        FC.aparc_REST1_LR_fisherz    = atanh(FC.aparc_REST1_LR);
        FC.aparc_REST1_RL_fisherz    = atanh(FC.aparc_REST1_RL);
        FC.aparc_REST2_LR_fisherz    = atanh(FC.aparc_REST2_LR);
        FC.aparc_REST2_RL_fisherz    = atanh(FC.aparc_REST2_RL);
        
        tmp = (FC.a2009_REST1_LR_fisherz + FC.a2009_REST1_RL_fisherz + FC.a2009_REST2_LR_fisherz + FC.a2009_REST2_RL_fisherz) / 4;
        n=size(tmp,1);
        tmp(1:n+1:n*n)=0;
        FC.a2009_fisherz_avg = tmp;
        
        tmp = (FC.aparc_REST1_LR_fisherz + FC.aparc_REST1_RL_fisherz + FC.aparc_REST2_LR_fisherz + FC.aparc_REST2_RL_fisherz) / 4;
        n=size(tmp,1);
        tmp(1:n+1:n*n)=0;
        FC.aparc_fisherz_avg = tmp;
        
        tmp = (FC.a2009_REST1_LR + FC.a2009_REST1_RL + FC.a2009_REST2_LR + FC.a2009_REST2_RL) / 4;
        n=size(tmp,1);
        tmp(1:n+1:n*n)=0;
        FC.a2009_avg = tmp;
        
        tmp = (FC.aparc_REST1_LR + FC.aparc_REST1_RL + FC.aparc_REST2_LR + FC.aparc_REST2_RL) / 4;
        n=size(tmp,1);
        tmp(1:n+1:n*n)=0;
        FC.aparc_avg = tmp;
        
    catch me
        display([num2str(subjects(ii)) ': ' me.identifier])
        cd(connectome_folder)
        save('-7',['~/HCP_Connectomes/FC/fMRIfc/' num2str(subjects(ii)) '_ERROR.mat'])
    end
end

save('-7',['~/HCP_Connectomes/FC/fMRIfc/' num2str(subjects(ii)) '_fMRI.mat'],'FC','fMRI')
save('-7',['~/HCP_Connectomes/FC/fMRIfc/' num2str(subjects(ii)) '_FC.mat'],'FC')


end



function result = rearrange_matrix(cortical, subcortical, subid)
    if size(cortical,1) == 148 &&  size(subcortical,1) == 19
        result = zeros(1200,164);
        result(:,1:74)     =    cortical(1:74,:)';     % from a2009
        result(:,75:79)    = subcortical(1:5,:)';      % From subcortical
        result(:,80:82)    = subcortical(7:9,:)';      % From subcortical
        result(:,83:89)    = subcortical(12:18,:)';    % From subcortical
        result(:,90:163)   =    cortical(75:148,:)';   % from a2009
        result(:,164)      = subcortical(11,:)';       % from subcortical
    elseif size(cortical,1) == 68 &&  size(subcortical,1) == 19
        result = zeros(1200,84);
        result(:,1:34)     = cortical(1:34,:)';         % from aparc
        result(:,35:39)    = subcortical(1:5,:)';      % From subcortical
        result(:,40:42)    = subcortical(7:9,:)';      % From subcortical
        result(:,43:49)    = subcortical(12:18,:)';    % From subcortical
        result(:,50:83)    = cortical(35:68,:)';        % from aparc
        result(:,84)       = subcortical(11,:)';       % from subcortical
    else        
        display(['ERROR: wrong matrix dimensions: ' num2str(subid) '  ' num2str(size(cortical,1)) '  ' num2str(size(subcortical,1))])
        exit()
    end
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
