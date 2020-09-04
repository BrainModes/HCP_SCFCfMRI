clear
close all
clc

cd('/Users/michael/Desktop/HCP_project/Connectome_pipeline/FC/scripts/')
subjects            =   load('/Users/michael/Desktop/HCP_project/subject_list.txt');

delete('*')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 0: mkdir
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ii = 1:length(subjects)
     display(['mkdir ~/HCP_Connectomes/FC/' num2str(subjects(ii))])
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1: Export region-average time series for aparc and aparc.a2009
% wb_command -cifti-parcellate rfMRI_REST1_RL_Atlas_MSMAll_hp2000_clean.dtseries.nii 181232.aparc.32k_fs_LR.dlabel.nii COLUMN output_aparc.ptseries.nii
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:03:00\n#SBATCH --partition=batch\n'];

connectome_folder             = '~/HCP_Connectomes/FC/';
hcp_data_folder               = '~/_data/hcp_data/hcp/';

break_counter = 0;
preproc_patch = 0;
fileID_batch = fopen('step1_cifti_parcellate','w');
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 8;       

    input_file1     = [hcp_data_folder num2str(subjects(ii)) '/fMRI/rfMRI_REST1_LR_Atlas_MSMAll_hp2000_clean.dtseries.nii']; 
    input_file2     = [hcp_data_folder num2str(subjects(ii)) '/fMRI/rfMRI_REST1_RL_Atlas_MSMAll_hp2000_clean.dtseries.nii']; 
    input_file3     = [hcp_data_folder num2str(subjects(ii)) '/fMRI/rfMRI_REST2_LR_Atlas_MSMAll_hp2000_clean.dtseries.nii']; 
    input_file4     = [hcp_data_folder num2str(subjects(ii)) '/fMRI/rfMRI_REST2_RL_Atlas_MSMAll_hp2000_clean.dtseries.nii']; 
    label_aparc     = [hcp_data_folder num2str(subjects(ii)) '/fMRI/' num2str(subjects(ii)) '.aparc.32k_fs_LR.dlabel.nii']; 
    label_a2009     = [hcp_data_folder num2str(subjects(ii)) '/fMRI/' num2str(subjects(ii)) '.aparc.a2009s.32k_fs_LR.dlabel.nii']; 
    output_file1_aparc = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_LR_aparc.ptseries.nii']; 
    output_file1_2009  = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_LR_a2009.ptseries.nii']; 
    output_file2_aparc = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_RL_aparc.ptseries.nii']; 
    output_file2_2009  = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_RL_a2009.ptseries.nii']; 
    output_file3_aparc = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_LR_aparc.ptseries.nii']; 
    output_file3_2009  = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_LR_a2009.ptseries.nii']; 
    output_file4_aparc = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_RL_aparc.ptseries.nii']; 
    output_file4_2009  = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_RL_a2009.ptseries.nii']; 

    command         = [command 'srun -n 1 --exclusive wb_command -cifti-parcellate  ' input_file1 ' ' label_aparc ' COLUMN ' output_file1_aparc ' &\n'];
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-parcellate  ' input_file1 ' ' label_a2009 ' COLUMN ' output_file1_2009 ' &\n'];

    command         = [command 'srun -n 1 --exclusive wb_command -cifti-parcellate  ' input_file2 ' ' label_aparc ' COLUMN ' output_file2_aparc ' &\n'];
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-parcellate  ' input_file2 ' ' label_a2009 ' COLUMN ' output_file2_2009 ' &\n'];

    command         = [command 'srun -n 1 --exclusive wb_command -cifti-parcellate  ' input_file3 ' ' label_aparc ' COLUMN ' output_file3_aparc ' &\n'];
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-parcellate  ' input_file3 ' ' label_a2009 ' COLUMN ' output_file3_2009 ' &\n'];

    command         = [command 'srun -n 1 --exclusive wb_command -cifti-parcellate  ' input_file4 ' ' label_aparc ' COLUMN ' output_file4_aparc ' &\n'];
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-parcellate  ' input_file4 ' ' label_a2009 ' COLUMN ' output_file4_2009 ' &\n'];
    
    if break_counter == 24 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step1_cifti_parcellate_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);        
        fprintf(fileID_batch, ['sbatch step1_cifti_parcellate_' num2str(preproc_patch) '\n']);
        break_counter = 0;
    end
end
fclose(fileID_batch);

%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2: Convert to text file
% wb_command -cifti-convert -to-text output_aparc.ptseries.nii output_aparc.ptseries.txt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:02:00\n#SBATCH --partition=batch\n'];

connectome_folder             = '~/HCP_Connectomes/FC/';
hcp_data_folder               = '~/_data/hcp_data/hcp/';

break_counter = 0;
preproc_patch = 0;
fileID_batch = fopen('step2_to_txt','w');
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 8;       

    input_file1_aparc = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_LR_aparc.ptseries.nii']; 
    input_file1_2009  = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_LR_a2009.ptseries.nii']; 
    input_file2_aparc = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_RL_aparc.ptseries.nii']; 
    input_file2_2009  = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_RL_a2009.ptseries.nii']; 
    input_file3_aparc = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_LR_aparc.ptseries.nii']; 
    input_file3_2009  = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_LR_a2009.ptseries.nii']; 
    input_file4_aparc = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_RL_aparc.ptseries.nii']; 
    input_file4_2009  = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_RL_a2009.ptseries.nii']; 
    
    output_file1_aparc = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_LR_aparc.ptseries.txt']; 
    output_file1_2009  = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_LR_a2009.ptseries.txt']; 
    output_file2_aparc = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_RL_aparc.ptseries.txt']; 
    output_file2_2009  = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_RL_a2009.ptseries.txt']; 
    output_file3_aparc = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_LR_aparc.ptseries.txt']; 
    output_file3_2009  = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_LR_a2009.ptseries.txt']; 
    output_file4_aparc = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_RL_aparc.ptseries.txt']; 
    output_file4_2009  = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_RL_a2009.ptseries.txt']; 
    
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-convert -to-text ' input_file1_aparc ' ' output_file1_aparc ' &\n'];
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-convert -to-text ' input_file1_2009  ' ' output_file1_2009 ' &\n'];
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-convert -to-text ' input_file2_aparc ' ' output_file2_aparc ' &\n'];
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-convert -to-text ' input_file2_2009  ' ' output_file2_2009 ' &\n'];
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-convert -to-text ' input_file3_aparc ' ' output_file3_aparc ' &\n'];
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-convert -to-text ' input_file3_2009  ' ' output_file3_2009 ' &\n'];
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-convert -to-text ' input_file4_aparc ' ' output_file4_aparc ' &\n'];
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-convert -to-text ' input_file4_2009  ' ' output_file4_2009 ' &\n'];
    
    if break_counter == 24 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step2_to_txt_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);        
        fprintf(fileID_batch, ['sbatch step2_to_txt_' num2str(preproc_patch) '\n']);
        break_counter = 0;
    end
end
fclose(fileID_batch);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3: Export region-average time series for subcortical regions
% wb_command -cifti-parcellate rfMRI_REST1_LR_Atlas_hp2000_clean.dtseries.nii subcortical.dlabel.nii COLUMN 100307.subcortical.ptseries.nii
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:03:00\n#SBATCH --partition=batch\n'];

connectome_folder             = '~/HCP_Connectomes/FC/';
subcort_dlabel                = '~/HCP_Connectomes/FC_pipeline/Atlas_ROIs.2.dlabel.nii';
hcp_data_folder               = '~/_data/hcp_data/hcp/';

break_counter = 0;
preproc_patch = 0;
fileID_batch = fopen('step3_cifti_parcellate_subcort','w');
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 4;       

    input_file1     = [hcp_data_folder num2str(subjects(ii)) '/fMRI/rfMRI_REST1_LR_Atlas_MSMAll_hp2000_clean.dtseries.nii']; 
    input_file2     = [hcp_data_folder num2str(subjects(ii)) '/fMRI/rfMRI_REST1_RL_Atlas_MSMAll_hp2000_clean.dtseries.nii']; 
    input_file3     = [hcp_data_folder num2str(subjects(ii)) '/fMRI/rfMRI_REST2_LR_Atlas_MSMAll_hp2000_clean.dtseries.nii']; 
    input_file4     = [hcp_data_folder num2str(subjects(ii)) '/fMRI/rfMRI_REST2_RL_Atlas_MSMAll_hp2000_clean.dtseries.nii']; 
    output_file1_subcort = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_LR_subcort.ptseries.nii']; 
    output_file2_subcort = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_RL_subcort.ptseries.nii']; 
    output_file3_subcort = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_LR_subcort.ptseries.nii']; 
    output_file4_subcort = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_RL_subcort.ptseries.nii']; 

    command         = [command 'srun -n 1 --exclusive wb_command -cifti-parcellate  ' input_file1 ' ' subcort_dlabel ' COLUMN ' output_file1_subcort ' &\n'];
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-parcellate  ' input_file2 ' ' subcort_dlabel ' COLUMN ' output_file2_subcort ' &\n'];
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-parcellate  ' input_file3 ' ' subcort_dlabel ' COLUMN ' output_file3_subcort ' &\n'];
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-parcellate  ' input_file4 ' ' subcort_dlabel ' COLUMN ' output_file4_subcort ' &\n'];
    
    if break_counter == 24 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step3_cifti_parcellate_subcort_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);        
        fprintf(fileID_batch, ['sbatch step3_cifti_parcellate_subcort_' num2str(preproc_patch) '\n']);
        break_counter = 0;
    end
end
fclose(fileID_batch);

%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4: Convert subcort to text file
% wb_command -cifti-convert -to-text output_aparc.ptseries.nii output_aparc.ptseries.txt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:02:00\n#SBATCH --partition=batch\n'];

connectome_folder             = '~/HCP_Connectomes/FC/';
hcp_data_folder               = '~/_data/hcp_data/hcp/';

break_counter = 0;
preproc_patch = 0;
fileID_batch = fopen('step4_to_txt_subcort','w');
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 8;       

    input_file1_subcort = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_LR_subcort.ptseries.nii']; 
    input_file2_subcort = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_RL_subcort.ptseries.nii']; 
    input_file3_subcort = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_LR_subcort.ptseries.nii']; 
    input_file4_subcort = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_RL_subcort.ptseries.nii']; 

    output_file1_subcort = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_LR_subcort.ptseries.txt']; 
    output_file2_subcort = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST1_RL_subcort.ptseries.txt']; 
    output_file3_subcort = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_LR_subcort.ptseries.txt']; 
    output_file4_subcort = [connectome_folder num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FC_REST2_RL_subcort.ptseries.txt']; 
    
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-convert -to-text ' input_file1_subcort ' ' output_file1_subcort ' &\n'];
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-convert -to-text ' input_file2_subcort ' ' output_file2_subcort ' &\n'];
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-convert -to-text ' input_file3_subcort ' ' output_file3_subcort ' &\n'];
    command         = [command 'srun -n 1 --exclusive wb_command -cifti-convert -to-text ' input_file4_subcort ' ' output_file4_subcort ' &\n'];
    
    if break_counter == 24 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step4_to_txt_subcort_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);        
        fprintf(fileID_batch, ['sbatch step4_to_txt_subcort_' num2str(preproc_patch) '\n']);
        break_counter = 0;
    end
end
fclose(fileID_batch);


