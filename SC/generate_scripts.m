clear
close all
clc

cd('/Users/michael/Desktop/HCP_project/Connectome_pipeline/SC/scripts/')
subjects            =   load('/Users/michael/Desktop/HCP_project/subject_list.txt');

delete('*')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 0: mkdir
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for ii = 1:length(subjects)
%     display(['mkdir ~/HCP_Connectomes/SC/' num2str(subjects(ii))])
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1: Labelconvert
% labelconvert aparc+aseg.nii.gz ~/Software/FreeSurfer/5.3.0-centos6_x86_64/FreeSurferColorLUT.txt ~/Tractography/mrtrix3/mrtrix3/src/connectome/tables/fs_default.txt nodes_aparc.mif
% labelconvert aparc.a2009s+aseg.nii.gz ~/Software/FreeSurfer/5.3.0-centos6_x86_64/FreeSurferColorLUT.txt  ~/Tractography/mrtrix3/mrtrix3/src/connectome/tables/fs_a2009s.txt nodes_a2009.mif
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:02:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nmodule load MRtrix/0.3.15-Python-2.7.12\n\n'];



hcp_data_folder = '~/_data/hcp_data/hcp/';
freesurfer_LUT  = '~/Software/FreeSurfer/5.3.0-centos6_x86_64/FreeSurferColorLUT.txt';
mrtrix_LUT1     = '~/Tractography/mrtrix3/mrtrix3/src/connectome/tables/fs_default.txt';
mrtrix_LUT2     = '~/Tractography/mrtrix3/mrtrix3/src/connectome/tables/fs_a2009s.txt';
output_folder   = '~/HCP_Connectomes/SC/';

break_counter = 0;
preproc_patch = 0;
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;   
    
    input_file1  = [hcp_data_folder num2str(subjects(ii)) '/T1w/aparc+aseg.nii.gz'];
    input_file2  = [hcp_data_folder num2str(subjects(ii)) '/T1w/aparc.a2009s+aseg.nii.gz'];
    output_file1 = [output_folder   num2str(subjects(ii)) '/aparc+aseg_mrtrix.mif'];
    output_file2 = [output_folder   num2str(subjects(ii)) '/aparc.a2009s+aseg_mrtrix.mif'];   
    
    command      = [command 'labelconvert ' input_file1 ' ' freesurfer_LUT ' ' mrtrix_LUT1 ' ' output_file1 ' &\n'];
    command      = [command 'labelconvert ' input_file2 ' ' freesurfer_LUT ' ' mrtrix_LUT2 ' ' output_file2 ' &\n'];

    if break_counter == 24 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step1_labelconv_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);
        display(['sbatch step1_labelconv_' num2str(preproc_patch)]);
        break_counter = 0;
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2: Convert nii to mif (store in a single folder)
% Command: mrconvert data.nii.gz DWI.mif -fslgrad bvecs bvals -datatype float32 -stride 0,0,0,1
% CAUTION: due to huge memory pressure first unzip and then perform
% mrconvert on tiny parts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:30:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nmodule load MRtrix/0.3.15-Python-2.7.12\n\n'];
% 
% hcp_data_folder = '~/_data/hcp_data/hcp/';
% output_folder   = '~/HCP_Connectomes/SC/DWI/';
% 
% break_counter = 0;
% preproc_patch = 0;
% for ii = 1:length(subjects)
%     if break_counter == 0
%         command     = initstring;        
%     end
%     break_counter = break_counter + 1;   
%     
%     input_file  = [hcp_data_folder num2str(subjects(ii)) '/T1w/Diffusion/data.nii.gz'];
%     bvecs_file  = [hcp_data_folder num2str(subjects(ii)) '/T1w/Diffusion/bvecs'];
%     bvals_file  = [hcp_data_folder num2str(subjects(ii)) '/T1w/Diffusion/bvals'];
%     output_file = [output_folder   num2str(subjects(ii)) '_dwi.mif'];  
%     
%     command      = [command 'mrconvert ' input_file ' ' output_file ' -fslgrad ' bvecs_file ' ' bvals_file ' -datatype float32 -stride 0,0,0,1 &\n'];
%     
%     if break_counter == 8 || ii == length(subjects)
%         preproc_patch = preproc_patch + 1;
%         finalstring = [command '\nwait\n'];
%         fileID = fopen(['step2_mrconvert_' num2str(preproc_patch)],'w');
%         fprintf(fileID,finalstring);
%         fclose(fileID);
%         display(['sbatch step2_mrconvert_' num2str(preproc_patch)]);
%         break_counter = 0;
%     end
% end

% Step 2.1. unzip
% gunzip -c file.gz > /THERE/file

initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:10:00\n#SBATCH --partition=batch\n\n\n'];

hcp_data_folder = '~/_data/hcp_data/hcp/';
output_folder   = '$WORK/Tractography_tmp/HCP_DWI/';

break_counter = 0;
preproc_patch = 0;
fileID_batch = fopen('step2_1_unzip_start','w');
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;   
    
    input_file  = [hcp_data_folder num2str(subjects(ii)) '/T1w/Diffusion/data.nii.gz'];
    output_file = [output_folder   num2str(subjects(ii)) '_dwi.nii'];  
    
    command      = [command 'gunzip -c ' input_file ' > ' output_file ' &\n'];
    
    if break_counter == 4 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step2_1_unzip_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);
        fprintf(fileID_batch, ['sbatch step2_1_unzip_' num2str(preproc_patch) '\n']);
        break_counter = 0;
    end
end
fclose(fileID_batch);


% Step 2.2. mrconvert
initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:10:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nmodule load MRtrix/0.3.15-Python-2.7.12\n\n'];

hcp_data_folder = '~/_data/hcp_data/hcp/';
input_folder    = '$WORK/Tractography_tmp/HCP_DWI/';
output_folder   = '~/HCP_Connectomes/SC/DWI/';

break_counter = 0;
preproc_patch = 0;
fileID_batch = fopen('step2_2_mrconvert_start','w');
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;   
    
    input_file  = [input_folder    num2str(subjects(ii)) '_dwi.nii'];
    bvecs_file  = [hcp_data_folder num2str(subjects(ii)) '/T1w/Diffusion/bvecs'];
    bvals_file  = [hcp_data_folder num2str(subjects(ii)) '/T1w/Diffusion/bvals'];
    output_file = [output_folder   num2str(subjects(ii)) '_dwi.mif'];  
    
    command      = [command 'mrconvert ' input_file ' ' output_file ' -fslgrad ' bvecs_file ' ' bvals_file ' -datatype float32 -stride 0,0,0,1 -nthreads 0 &\n'];
    
    if break_counter == 1 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step2_2_mrconvert_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);      
        fprintf(fileID_batch, ['sbatch step2_2_mrconvert_' num2str(preproc_patch) '\n']);
        break_counter = 0;
    end
end
fclose(fileID_batch);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3: Generate brain masks (store in a single folder)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:10:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nmodule load MRtrix/0.3.15-Python-2.7.12\n\n'];

input_folder    = '~/HCP_Connectomes/SC/DWI/';
output_folder   = '~/HCP_Connectomes/SC/DWI_masks/';

break_counter = 0;
preproc_patch = 0;
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;   
    
    input_file  = [input_folder    num2str(subjects(ii)) '_dwi.mif'];
    output_file = [output_folder   num2str(subjects(ii)) '_dwi_mask.mif'];  
    
    command      = [command 'dwi2mask ' input_file ' ' output_file ' &\n'];
    
    if break_counter == 8 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step3_mask_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);
        display(['sbatch step3_mask_' num2str(preproc_patch)]);
        break_counter = 0;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3 ALTERNATIVE: Generate brain masks based on freesurfer aparc+aseg (store in a single folder)
% Might be better b/c here we can explicitly exclude CSF
% 1. generate 5tt image
%       5ttgen freesurfer aparc+aseg.nii.gz 5tt.mif -sgm_amyg_hipp -lut ~/Software/FreeSurfer/5.3.0-centos6_x86_64/FreeSurferColorLUT.txt 
% 2. collapse 4d image to 3d image and exclude CSF
%       5tt2vis -bg 0 -cgm 1 -sgm 1 -wm 1 -csf 0 -path 1 test.mif test2.mif
% 3. Regrid brain mask images to DWI dimensions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Sub-Step 1.
initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:10:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nmodule load MRtrix/0.3.15-Python-2.7.12\n\n'];

hcp_data_folder = '~/_data/hcp_data/hcp/';
fileID_batch = fopen('step3A_1_mask','w');
break_counter = 0;
preproc_patch = 0;
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;   
    
    input_file  = [hcp_data_folder num2str(subjects(ii)) '/T1w/aparc+aseg.nii.gz'];
    output_file = [hcp_data_folder num2str(subjects(ii)) '/T1w/5tt_nocrop.nii']; 
    
    % Do NOT crop 5TT Image! This will be important for later clustering
    % steps
    %command      = [command '5ttgen freesurfer ' input_file ' ' output_file ' -sgm_amyg_hipp -lut ~/Software/FreeSurfer/5.3.0-centos6_x86_64/FreeSurferColorLUT.txt &\n'];
    command      = [command '5ttgen freesurfer ' input_file ' ' output_file ' -sgm_amyg_hipp -nocrop -lut ~/Software/FreeSurfer/5.3.0-centos6_x86_64/FreeSurferColorLUT.txt &\n'];
    
    if break_counter == 16 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step3A_1_mask_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);
        display(['sbatch step3A_1_mask_' num2str(preproc_patch)]);
        fprintf(fileID_batch, ['sbatch step3A_1_mask_' num2str(preproc_patch) '\n']);
        break_counter = 0;
    end
end
fclose(fileID_batch);



% Sub-Step 2.
initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:10:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nmodule load MRtrix/0.3.15-Python-2.7.12\n\n'];

hcp_data_folder = '~/_data/hcp_data/hcp/';
output_folder   = '~/HCP_Connectomes/SC/DWI_masks/';

break_counter = 0;
preproc_patch = 0;
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;   
    
    input_file  = [hcp_data_folder num2str(subjects(ii)) '/T1w/5tt.mif']; 
    output_file = [output_folder   num2str(subjects(ii)) '_dwi_mask.mif'];  
    
    command      = [command '5tt2vis -bg 0 -cgm 1 -sgm 1 -wm 1 -csf 0 -path 1 ' input_file ' ' output_file ' &\n'];
    
    if break_counter == 16 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step3A_2_mask_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);
        display(['sbatch step3A_2_mask_' num2str(preproc_patch)]);
        break_counter = 0;
    end
end


% Sub-Step 3.
initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:05:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nmodule load MRtrix/0.3.15-Python-2.7.12\n\n'];

input_folder_mask   = '~/HCP_Connectomes/SC/DWI_masks/';
input_folder_dwi    = '~/HCP_Connectomes/SC/DWI/';
output_folder       = '~/HCP_Connectomes/SC/DWI_masks_regrid/';

break_counter = 0;
preproc_patch = 0;
fileID_batch = fopen('step3A_3_regrid_start','w');
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;   
    
    input_template  = [input_folder_dwi  num2str(subjects(ii)) '_dwi.mif']; 
    input_mask      = [input_folder_mask num2str(subjects(ii)) '_dwi_mask.mif']; 
    output_file     = [output_folder     num2str(subjects(ii)) '_dwi_mask_regrid.mif']; 
    
    command         = [command 'mrtransform -template ' input_template ' ' input_mask ' ' output_file ' -nthreads 0 &\n'];
    
    if break_counter == 16 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step3A_3_regrid_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);        
        fprintf(fileID_batch, ['sbatch step3A_3_regrid_' num2str(preproc_patch) '\n']);
        break_counter = 0;
    end
end
fclose(fileID_batch);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step XX: Test-zip DWI files to see whether there are small ones (where
% mrconvert failed)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:15:00\n#SBATCH --partition=batch\n\n\n'];

input_folder    = '~/HCP_Connectomes/SC/DWI/';
output_folder   = '~/HCP_Connectomes/SC/DWI_zip/';

break_counter = 0;
preproc_patch = 0;
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;   
    
    input_file  = [input_folder    num2str(subjects(ii)) '_dwi.mif']; 
    output_file = [output_folder   num2str(subjects(ii)) '_dwi.zip'];  
    
    command      = [command 'zip ' output_file ' ' input_file ' &\n'];
    
    if break_counter == 16 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['stepXX_zip_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);
        display(['sbatch stepXX_zip_' num2str(preproc_patch)]);
        break_counter = 0;
    end
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4: dwiintensitynorm
% dwiintensitynorm <input_dwi_folder> <input_brain_mask_folder> <output_normalised_dwi_folder> <output_fa_template> <output_template_wm_mask>
% Step 4.1.: select 50 subjects to create population template (~700 is too
% much)
% Step 4.2.: dwintensnorm for a subset of 50 subjects
% Steps 4.3. -- now all subjects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Step 4.1.Randomly select 50 subject

%rand_subs = randperm(length(subjects));
%rand_subs = rand_subs(1:50);
rand_subs = [745,680,678,626,702,35,768,266,536,601,217,510,379,614,134,434,195,95,774,172,448,697,210,341,723,123,23,227,370,270,291,189,405,396,350,732,598,303,403,611,612,778,28,162,531,146,552,215,694,411];

    
input_dwi_folder                = '/homec/hbu23/hbu231/HCP_Connectomes/SC/DWI/'; 
new_dwi_folder                  = '/homec/hbu23/hbu231/HCP_Connectomes/SC/DWI_subset/';
input_brain_mask_folder         = '/homec/hbu23/hbu231/HCP_Connectomes/SC/DWI_masks_regrid/'; 
new_brain_mask_folder           = '/homec/hbu23/hbu231/HCP_Connectomes/SC/DWI_masks_regrid_subset/'; 

fileID_batch = fopen('tmp_cpy_files','w');
for ii = rand_subs
    command1                    = ['cp ' input_dwi_folder num2str(subjects(ii)) '_dwi.mif ' new_dwi_folder ' &\n'];
    command2                    = ['cp ' input_brain_mask_folder num2str(subjects(ii)) '_dwi_mask_regrid.mif ' new_brain_mask_folder ' &\n'];
    
    fprintf(fileID_batch, command1);
    fprintf(fileID_batch, command2);
end


fclose(fileID_batch);



% Step 4.2.Intensnorm

initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=15:00:00\n#SBATCH --gres=mem1024\n#SBATCH --partition=mem1024\nmodule load GCC/5.4.0  MVAPICH2/2.2-GDR\nmodule load GCC/5.4.0  ParaStationMPI/5.1.5-1\nmodule load Intel/2016.4.258-GCC-5.4.0  MVAPICH2/2.2-GDR\nmodule load Intel/2017.0.098-GCC-5.4.0  IntelMPI/2017.0.098\nmodule load Intel/2017.0.098-GCC-5.4.0  ParaStationMPI/5.1.5-1\nmodule load SciPy-Stack/2016b-Python-2.7.12\nmodule load GCC/5.4.0\nmodule load MRtrix/0.3.15-Python-2.7.12\n\n\n'];

command                         = initstring;        
input_dwi_folder                = '/homec/hbu23/hbu231/HCP_Connectomes/SC/DWI_subset'; 
input_brain_mask_folder         = '/homec/hbu23/hbu231/HCP_Connectomes/SC/DWI_masks_regrid_subset'; 
output_normalised_dwi_folder    = '/work/hbu23/hbu231/Tractography_tmp/HCP_DWI_intensnorm';
output_fa_template              = '/homec/hbu23/hbu231/HCP_Connectomes/SC/allsubs_fa_template.mif';
output_template_wm_mask         = '/homec/hbu23/hbu231/HCP_Connectomes/SC/allsubs_wm_mask.mif';

command     = [command 'dwiintensitynorm ' input_dwi_folder ' ' input_brain_mask_folder ' ' output_normalised_dwi_folder ' ' output_fa_template ' ' output_template_wm_mask ' -force -tempdir /work/hbu23/hbu231/tmp -nthreads 0 &\n'];

finalstring = [command '\nwait\n'];
fileID = fopen('step4_intensnorm','w');
fprintf(fileID,finalstring);
fclose(fileID);




% Step 4.3.: now all subjects
%dwi2tensor <input_dwi> -mask <input_brain_mask> - | tensor2metric - -fa - | mrregister <fa_template> - -mask2 <input_brain_mask> -nl_scale 0.5,0.75,1.0 -nl_niter 5,5,15 -nl_warp - tmp.mif | mrtransform <input_template_wm_mask> -template <input_dwi> -warp - - | dwinormalise <input_dwi> - <output_normalised_dwi>; rm tmp.mif



initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=03:00:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nmodule load MRtrix/0.3.15-Python-2.7.12\n\n'];

input_folder_mask       = '~/HCP_Connectomes/SC/DWI_masks_regrid/';
input_folder_dwi        = '/work/hbu23/hbu231/HCP_pipeline_tmp/DWI/';
output_folder           = '/work/hbu23/hbu231/HCP_pipeline_tmp/DWI_normalized/';
fa_template             = '~/HCP_Connectomes/SC/allsubs_fa_template.mif';
input_template_wm_mask  = '~/HCP_Connectomes/SC/allsubs_wm_mask.mif';
tmp_folder              = '/work/hbu23/hbu231/tmp/';

break_counter = 0;
preproc_patch = 0;
fileID_batch = fopen('step4_3_allsubjectsnormalize_start','w');
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;   
    
    input_dwi               = [input_folder_dwi   num2str(subjects(ii)) '_dwi.mif']; 
    input_brain_mask        = [input_folder_mask  num2str(subjects(ii)) '_dwi_mask_regrid.mif']; 
    output_normalised_dwi   = [output_folder      num2str(subjects(ii)) '_dwi_normalized.mif'];  
    tmp_dwi                 = [tmp_folder         num2str(subjects(ii)) '_tmp.mif']; 
    
    command         = [command 'dwi2tensor ' input_dwi ' -mask ' input_brain_mask ' - | tensor2metric - -fa - | mrregister ' fa_template ' - -mask2 ' input_brain_mask ' -nl_scale 0.5,0.75,1.0 -nl_niter 5,5,15 -nl_warp - ' tmp_dwi ' | mrtransform ' input_template_wm_mask ' -template ' input_dwi ' -warp - - | dwinormalise ' input_dwi ' - ' output_normalised_dwi '; rm ' tmp_dwi ' &\n'];
    
    if break_counter == 20 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step4_3_allsubjectsnormalize_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);        
        fprintf(fileID_batch, ['sbatch step4_3_allsubjectsnormalize_' num2str(preproc_patch) '\n']);
        break_counter = 0;
    end
end
fclose(fileID_batch);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 5: Compute individual multi-shell multi-tissue response functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Substep 5.1: Regrid 5tt image to DWI space
initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:05:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nmodule load MRtrix/0.3.15-Python-2.7.12\n\n'];

input_folder_dwi    = '~/HCP_Connectomes/SC/DWI/';
hcp_data_folder     = '~/_data/hcp_data/hcp/';

break_counter = 0;
preproc_patch = 0;
fileID_batch = fopen('step5_1_regrid_start','w');
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;   
    
    file_5tt        = [hcp_data_folder num2str(subjects(ii)) '/T1w/5tt.mif']; 
    input_template  = [input_folder_dwi  num2str(subjects(ii)) '_dwi.mif']; 
    output_file     = [hcp_data_folder num2str(subjects(ii)) '/T1w/5tt_regrid.mif']; 
    
    command         = [command 'mrtransform -template ' input_template ' ' file_5tt ' ' output_file ' -nthreads 0 &\n'];
    
    if break_counter == 16 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step5_1_regrid_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);        
        fprintf(fileID_batch, ['sbatch step5_1_regrid_' num2str(preproc_patch) '\n']);
        break_counter = 0;
    end
end
fclose(fileID_batch);




% Step 5.2.: 
% dwi2response msmt_5tt DWI.mif 5TT.mif RF_WM.txt RF_GM.txt RF_CSF.txt
% Better: use d'hollander algorithm


initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=01:00:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nexport PATH=/homec/hbu23/hbu231/testmrtrix_DK/mrtrix3/release/bin:$PATH\nexport PATH=/homec/hbu23/hbu231/testmrtrix_DK/mrtrix3/scripts:$PATH\n\n'];


input_folder_dwi        = '/work/hbu23/hbu231/HCP_pipeline_tmp/DWI_normalized/';
hcp_data_folder         = '~/_data/hcp_data/hcp/';
output_folder           = '~/HCP_Connectomes/SC/DWI_response_functions/';


break_counter = 0;
preproc_patch = 0;
fileID_batch = fopen('step5_2_dwi2response_start','w');
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;   
    
    input_dwi               = [input_folder_dwi     num2str(subjects(ii)) '_dwi_normalized.mif'];  
    file_5tt                = [hcp_data_folder      num2str(subjects(ii)) '/T1w/5tt.mif']; 
    output_RF_WM            = [output_folder        num2str(subjects(ii)) '_RF_WM.txt']; 
    output_RF_GM            = [output_folder        num2str(subjects(ii)) '_RF_GM.txt']; 
    output_RF_CSF           = [output_folder        num2str(subjects(ii)) '_RF_CSF.txt']; 

    
   % command         = [command 'srun -n 1 --exclusive -c 48 dwi2response msmt_5tt ' input_dwi ' ' file_5tt ' ' output_RF_WM ' ' output_RF_GM ' ' output_RF_CSF ' -tempdir /work/hbu23/hbu231/tmp &\n'];
   %  command         = [command 'dwi2response msmt_5tt ' input_dwi ' ' file_5tt ' ' output_RF_WM ' ' output_RF_GM ' ' output_RF_CSF ' -tempdir /work/hbu23/hbu231/tmp &\n'];
   command         = [command 'dwi2response dhollander ' input_dwi ' ' output_RF_WM ' ' output_RF_GM ' ' output_RF_CSF ' -nthreads 0 -tempdir /work/hbu23/hbu231/tmp -force &\n'];
   
    if break_counter == 24 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step5_2_dwi2response_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);        
        fprintf(fileID_batch, ['sbatch step5_2_dwi2response_' num2str(preproc_patch) '\n']);
        break_counter = 0;
    end
end
fclose(fileID_batch);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 6: Average response functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:20:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nexport PATH=/homec/hbu23/hbu231/testmrtrix_DK/mrtrix3/release/bin:$PATH\nexport PATH=/homec/hbu23/hbu231/testmrtrix_DK/mrtrix3/scripts:$PATH\n\n'];


input_folder_dwi        = '/work/hbu23/hbu231/HCP_pipeline_tmp/DWI_normalized/';
hcp_data_folder         = '~/_data/hcp_data/hcp/';
output_folder           = '~/HCP_Connectomes/SC/DWI_response_functions/';


break_counter = 0;
preproc_patch = 0;
fileID_batch = fopen('step6_groupavg_responsefunct','w');
    
command         = ['average_response '];
   
for ii = 1:length(subjects)

    command         = [command num2str(subjects(ii)) '_RF_CSF.txt '];
end

command         = [command 'group_avg_RF_CSF.txt'];

if break_counter == 24 || ii == length(subjects)
    preproc_patch = preproc_patch + 1;
    finalstring = [command '\nwait\n'];
    fileID = fopen(['step6_groupavg_responsefunct_' num2str(preproc_patch)],'w');
    fprintf(fileID,finalstring);
    fclose(fileID);        
    fprintf(fileID_batch, ['sbatch step6_groupavg_responsefunct_' num2str(preproc_patch) '\n']);
    break_counter = 0;
end

fclose(fileID_batch);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 7: Perform Multi-Shell, Multi-Tissue Constrained Spherical Deconvolution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=05:00:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nmodule load MRtrix/0.3.15-Python-2.7.12\n\n'];


input_folder_dwi        = '/work/hbu23/hbu231/HCP_pipeline_tmp/DWI_normalized/';
hcp_data_folder         = '~/_data/hcp_data/hcp/';
output_folder           = '/work/hbu23/hbu231/HCP_pipeline_tmp/FODs/';

group_RF_WM             = '/homec/hbu23/hbu231/HCP_Connectomes/SC/DWI_response_functions/group_avg_RF_WM.txt';
group_RF_GM             = '/homec/hbu23/hbu231/HCP_Connectomes/SC/DWI_response_functions/group_avg_RF_GM.txt';
group_RF_CSF            = '/homec/hbu23/hbu231/HCP_Connectomes/SC/DWI_response_functions/group_avg_RF_CSF.txt';

break_counter = 0;
preproc_patch = 0;
fileID_batch = fopen('step7_CSD_start','w');
fileID_mkdir = fopen('step7_CSD_start_mkdir','w');
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;   
    
    input_dwi               = [input_folder_dwi     num2str(subjects(ii)) '_dwi_normalized.mif'];  
    nodiffmask              = [hcp_data_folder      num2str(subjects(ii)) '/T1w/Diffusion/nodif_brain_mask.nii.gz']; 
    output_WM_FOD           = [output_folder        num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FOD_WM.mif']; 
    output_GM_FOD           = [output_folder        num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FOD_GM.mif']; 
    output_CSF_FOD          = [output_folder        num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FOD_CSF.mif']; 

    mkdirstring             = ['mkdir ' output_folder num2str(subjects(ii)) ' & \n'];
    fprintf(fileID_mkdir,mkdirstring);
    command         = [command 'srun -n 1 --exclusive dwi2fod msmt_csd ' input_dwi ' ' group_RF_WM ' ' output_WM_FOD ' ' group_RF_GM ' ' output_GM_FOD ' ' group_RF_CSF ' ' output_CSF_FOD ' -mask ' nodiffmask ' -nthreads 0 -force &\n'];

   
    if break_counter == 22 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step7_CSD_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);        
        fprintf(fileID_batch, ['sbatch step7_CSD_' num2str(preproc_patch) '\n']);
        break_counter = 0;
    end
end
fclose(fileID_batch);
fclose(fileID_mkdir);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 8: Perform Tractography
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=23:59:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nmodule load MRtrix/0.3.15-Python-2.7.12\n\n'];

input_folder            = '/work/hbu23/hbu231/HCP_pipeline_tmp/FODs/';
output_folder           = '/work/hbu23/hbu231/HCP_tracks/';
hcp_data_folder         = '~/_data/hcp_data/hcp/';

break_counter = 0;
preproc_patch = 0;
fileID_batch = fopen('step8_tckgen_250','w');
fileID_mkdir = fopen('step8_mkdir','w');
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;   
    
    mkdirstring     = ['mkdir ' output_folder num2str(subjects(ii)) ' & \n'];
    fprintf(fileID_mkdir,mkdirstring);
    
    
    WM_FOD          = [input_folder        num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FOD_WM.mif']; 
    file_5tt        = [hcp_data_folder     num2str(subjects(ii)) '/T1w/5tt.mif']; 
    output_file     = [output_folder       num2str(subjects(ii)) '/' num2str(subjects(ii)) '_250M_tracks.tck']; 
    command         = [command 'srun -n 1 --exclusive -c 48 tckgen ' WM_FOD ' ' output_file ' -act ' file_5tt ' -backtrack -crop_at_gmwmi -seed_dynamic ' WM_FOD ' -maxlength 250 -number 250000000 -cutoff 0.06 -nthreads 48 -force &\n'];
    
    if break_counter == 1 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step8_tckgen_' num2str(preproc_patch) '_250'],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);        
        fprintf(fileID_batch, ['sbatch step8_tckgen_' num2str(preproc_patch) '_250\n']);
        break_counter = 0;
    end
end
fclose(fileID_batch);
fclose(fileID_mkdir);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 9: Perform SIFT2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=23:59:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nmodule load MRtrix/0.3.15-Python-2.7.12\n\n'];

input_folder            = '/work/hbu23/hbu231/HCP_tracks/';
output_folder           = '/work/hbu23/hbu231/HCP_tracks_sift2/';
hcp_data_folder         = '~/_data/hcp_data/hcp/';
FOD_folder              = '/work/hbu23/hbu231/HCP_pipeline_tmp/FODs/';

break_counter = 0;
preproc_patch = 0;
fileID_batch = fopen('step9_sift2_250','w');
fileID_mkdir = fopen('step9_mkdir','w');
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;   
    
    mkdirstring     = ['mkdir ' output_folder num2str(subjects(ii)) ' & \n'];
    fprintf(fileID_mkdir,mkdirstring);
    
    tck_file        = [input_folder       num2str(subjects(ii)) '/' num2str(subjects(ii)) '_250M_tracks.tck'];
    WM_FOD          = [FOD_folder         num2str(subjects(ii)) '/' num2str(subjects(ii)) '_FOD_WM.mif']; 
    file_5tt        = [hcp_data_folder    num2str(subjects(ii)) '/T1w/5tt.mif']; 
    output_file     = [output_folder      num2str(subjects(ii)) '/' num2str(subjects(ii)) '_250M_tracks_weights.txt']; 
    command         = [command 'srun -n 1 --exclusive -c 48 tcksift2' ' -act ' file_5tt ' ' tck_file ' ' WM_FOD ' ' output_file ' -nthreads 48 -force &\n'];
    
    if break_counter == 1 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step9_sift2_' num2str(preproc_patch) '_250'],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);        
        fprintf(fileID_batch, ['sbatch step9_sift2_' num2str(preproc_patch) '_250\n']);
        break_counter = 0;
    end
end
fclose(fileID_batch);
fclose(fileID_mkdir);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 10: Map streamlines to the parcellated image to produce a connectome
% tck2connectome 10M_SIFT.tck nodes_fixSGM.mif connectome.csv
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:10:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nmodule load MRtrix/0.3.15-Python-2.7.12\n\n'];

connectome_folder             = '~/HCP_Connectomes/SC/';
sift_weights_folder           = '/work/hbu23/hbu231/HCP_tracks_sift2/';
tracks_folder                 = '/work/hbu23/hbu231/HCP_tracks/';  


break_counter = 0;
preproc_patch = 0;
fileID_batch = fopen('step11_tck2connectome_len','w');
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;       

    tck_file             = [tracks_folder            num2str(subjects(ii)) '/' num2str(subjects(ii)) '_25M_tracks.tck'];
    siftweights_file     = [sift_weights_folder      num2str(subjects(ii)) '/' num2str(subjects(ii)) '_25M_tracks_weights.txt'];
    parc1                = [connectome_folder   num2str(subjects(ii)) '/aparc+aseg_mrtrix.mif'];
    parc2                = [connectome_folder   num2str(subjects(ii)) '/aparc.a2009s+aseg_mrtrix.mif'];  
    connectome1          = [connectome_folder   num2str(subjects(ii)) '/aparc+aseg_connectome.csv'];
    connectome2          = [connectome_folder   num2str(subjects(ii)) '/aparc.a2009s+aseg_connectome.csv'];     
    %connectome3          = [connectome_folder   num2str(subjects(ii)) '/aparc+aseg_connectome_scalelen.csv'];
    %connectome4          = [connectome_folder   num2str(subjects(ii)) '/aparc.a2009s+aseg_connectome_scalelen.mif']; 
    %connectome5          = [connectome_folder   num2str(subjects(ii)) '/aparc+aseg_connectome_scaleinlen.csv'];
    %connectome6          = [connectome_folder   num2str(subjects(ii)) '/aparc.a2009s+aseg_connectome_scaleinlen.mif']; 
    
    command         = [command 'srun -n 1 --exclusive -c 24 tck2connectome -tck_weights_in ' siftweights_file ' ' tck_file ' ' parc1 ' ' connectome1 ' -nthreads 24 -force &\n'];
    command         = [command 'srun -n 1 --exclusive -c 24 tck2connectome -tck_weights_in ' siftweights_file ' ' tck_file ' ' parc2 ' ' connectome2 ' -nthreads 24 -force &\n'];
    
    if break_counter == 1 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step11_tck2connectome_len_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);        
        fprintf(fileID_batch, ['sbatch step11_tck2connectome_len_' num2str(preproc_patch) '\n']);
        break_counter = 0;
    end
end
fclose(fileID_batch);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 11: Compute edge length
% tck2connectome 10M_SIFT.tck nodes_fixSGM.mif connectome.csv
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:10:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nmodule load MRtrix/0.3.15-Python-2.7.12\n\n'];

connectome_folder             = '~/HCP_Connectomes/SC/';
sift_weights_folder           = '/work/hbu23/hbu231/HCP_tracks_sift2/';
tracks_folder                 = '/work/hbu23/hbu231/HCP_tracks/';  


break_counter = 0;
preproc_patch = 0;
fileID_batch = fopen('step11_tck2connectome_len','w');
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;       

    tck_file             = [tracks_folder            num2str(subjects(ii)) '/' num2str(subjects(ii)) '_25M_tracks.tck'];
    siftweights_file     = [sift_weights_folder      num2str(subjects(ii)) '/' num2str(subjects(ii)) '_25M_tracks_weights.txt'];
    parc1                = [connectome_folder   num2str(subjects(ii)) '/aparc+aseg_mrtrix.mif'];
    parc2                = [connectome_folder   num2str(subjects(ii)) '/aparc.a2009s+aseg_mrtrix.mif'];  
    connectome1          = [connectome_folder   num2str(subjects(ii)) '/aparc+aseg_connectome_len.csv'];
    connectome2          = [connectome_folder   num2str(subjects(ii)) '/aparc.a2009s+aseg_connectome_len.csv'];     

    command         = [command 'srun -n 1 --exclusive -c 24 tck2connectome -scale_length -stat_edge mean -tck_weights_in ' siftweights_file ' ' tck_file ' ' parc1 ' ' connectome1 ' -nthreads 24 -force &\n'];
    command         = [command 'srun -n 1 --exclusive -c 24 tck2connectome -scale_length -stat_edge mean -tck_weights_in ' siftweights_file ' ' tck_file ' ' parc2 ' ' connectome2 ' -nthreads 24 -force &\n'];
    
    if break_counter == 1 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step11_tck2connectome_len_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);        
        fprintf(fileID_batch, ['sbatch step11_tck2connectome_len_' num2str(preproc_patch) '\n']);
        break_counter = 0;
    end
end
fclose(fileID_batch);




%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Additional step: find missing subjects from Step 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear
close all
clc
cd('/Users/michael/Desktop/HCP_project')
[a b c]=textread('tmp.txt','%s %s %s');
filesize = str2double(a);
ids = zeros(length(c),1);
for ii = 1:length(c)
    tt = c{ii};
    ids(ii) = str2double(tt(1:6));
end
[filesize_sort sort_inds]=sort(filesize);
cutoff = 4214431992.00000;
lastfile = max(find(filesize_sort < cutoff));
sorted_subs = ids(sort_inds);
redo_subs = sorted_subs(1:lastfile);
subject_list = load('subject_list.txt');
redo_subs2 = setdiff(subject_list,ids);
redo_subs = [redo_subs; redo_subs2];
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Additional step: find missing subjects from Step 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear
close all
clc
cd('/Users/michael/Desktop/HCP_project')
[a b c]=textread('tmp.txt','%s %s %s');
filesize = str2double(a);
ids = zeros(length(c),1);
for ii = 1:length(c)
    tt = c{ii};
    ids(ii) = str2double(tt);
end
subject_list = load('subject_list.txt');
C = intersect(ids,subject_list);

[filesize_sort sort_inds]=sort(filesize);
cutoff = 4214431992.00000;
lastfile = max(find(filesize_sort < cutoff));
sorted_subs = ids(sort_inds);
redo_subs = sorted_subs(1:lastfile);
subject_list = load('subject_list.txt');
redo_subs2 = setdiff(subject_list,ids);
redo_subs = [redo_subs; redo_subs2];

redo_subs = intersect(redo_subs,subject_list);
%% Generate starfiles

cd('/Users/michael/Desktop/HCP_project/Connectome_pipeline/SC/scripts/')
initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=00:50:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nmodule load MRtrix/0.3.15-Python-2.7.12\n\n'];

hcp_data_folder = '~/_data/hcp_data/hcp/';
output_folder   = '~/HCP_Connectomes/SC/DWI/';

break_counter = 0;
preproc_patch = 0;
for ii = 1:length(redo_subs)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;   
    
    input_file  = [hcp_data_folder num2str(redo_subs(ii)) '/T1w/Diffusion/data.nii.gz'];
    bvecs_file  = [hcp_data_folder num2str(redo_subs(ii)) '/T1w/Diffusion/bvecs'];
    bvals_file  = [hcp_data_folder num2str(redo_subs(ii)) '/T1w/Diffusion/bvals'];
    output_file = [output_folder   num2str(redo_subs(ii)) '_dwi.mif'];  
    
    command      = [command 'mrconvert ' input_file ' ' output_file ' -fslgrad ' bvecs_file ' ' bvals_file ' -datatype float32 -stride 0,0,0,1 &\n'];
    
    if break_counter == 8 || ii == length(redo_subs)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step2X_mrconvert_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);
        display(['sbatch step2X_mrconvert_' num2str(preproc_patch)]);
        break_counter = 0;
    end
end


%% generate missing response functions scripts

clear
close all
clc

cd('/Users/michael/Desktop/HCP_project/Connectome_pipeline/SC/scripts/')
subjects            =   load('/Users/michael/Desktop/HCP_project/subject_list.txt');

delete('*')

existent = [100206;127933;154431;178647;210617;361941;580044;788876;100307;128026;154532;178849;211114;365343;580650;789373;100408;128127;154734;178950;211215;366042;580751;792564;100610;128632;154835;179245;211316;366446;581349;792867;101006;128935;154936;179346;211417;371843;581450;800941;101107;129028;155231;179548;211720;377451;583858;802844;101309;129129;155635;179952;211922;379657;585256;803240;101410;129331;155938;180129;212015;380036;586460;810843;101915;129634;156031;180432;212116;381038;587664;812746;102311;129937;156233;180735;212217;381543;588565;816653;102513;130013;156334;180836;212318;385450;594156;818859;102816;130316;156435;180937;212419;386250;599065;820745;103111;130417;156536;181131;212823;387959;599469;825048;103414;130619;156637;181232;213421;389357;599671;826353;103515;130821;157336;181636;214019;390645;604537;826454;103818;130922;157437;182032;214221;391748;609143;833148;104012;131217;157942;182436;214423;393247;613538;833249;104416;131419;158035;182739;214524;393550;615744;835657;104820;131722;158136;182840;214625;395251;617748;837560;105014;131823;158338;183034;214726;395756;618952;837964;105115;131924;158540;183337;217126;395958;626648;841349;105216;132017;158843;185139;217429;397154;627549;843151;105620;133019;159138;185341;220721;397760;628248;844961;105923;133625;159239;185442;221319;397861;633847;845458;106016;133827;159340;185846;223929;406836;638049;849264;106319;133928;159441;185947;224022;412528;645450;849971;106521;134021;159744;186141;227432;414229;645551;852455;107018;134223;159946;186444;228434;415837;647858;856463;107321;134425;160123;187345;231928;422632;654350;856766;107422;134728;160830;187547;233326;424939;654754;856968;107725;134829;160931;187850;236130;429040;656253;857263;108121;135225;161327;188347;237334;432332;656657;859671;108222;135528;161630;188448;239944;433839;657659;861456;108323;135730;161731;188549;245333;436239;660951;865363;108525;135932;162026;188751;246133;436845;663755;867468;108828;136227;162228;189349;248339;441939;664757;870861;109123;136732;162329;189450;250427;445543;665254;871762;109830;136833;162733;190031;250932;448347;667056;871964;110007;137229;162935;191033;251833;449753;668361;872158;110411;137633;163129;191942;255639;453441;671855;872562;110613;138231;163331;192035;256540;456346;672756;873968;111009;138534;163836;192641;257542;459453;673455;877168;111312;138837;164030;193239;257845;465852;677766;877269;111413;139233;164131;193441;263436;467351;677968;880157;111514;139637;164636;195041;268749;473952;679568;882161;111716;139839;164939;195445;268850;479762;679770;885975;112112;140117;165032;195647;270332;480141;680957;887373;112314;140319;165638;195849;275645;481951;683256;889579;112516;140420;165840;195950;280739;485757;685058;891667;112920;140824;166438;196144;280941;486759;687163;894067;113215;140925;167036;196346;283543;492754;690152;894673;113619;141119;167238;196750;284646;495255;693764;894774;113922;141422;168139;198249;285345;497865;695768;896778;114217;141826;168240;198350;285446;499566;700634;896879;114419;143325;168341;198451;286650;500222;702133;898176;114621;144125;168745;198653;287248;506234;704238;899885;114823;144226;169343;198855;289555;510326;705341;901139;115017;144428;169444;199150;290136;512835;706040;901442;115320;144731;169747;199453;293748;513736;707749;904044;115825;144832;169949;199655;295146;517239;709551;907656;116221;145127;170631;199958;297655;519950;713239;910241;116524;145834;170934;200008;298051;520228;715647;910443;116726;146129;171330;200109;298455;522434;715950;912447;117122;146331;171532;200210;299154;523032;720337;917255;117324;146432;171633;200311;300618;524135;724446;917558;117930;146533;172029;200614;303119;525541;725751;919966;118124;146634;172130;200917;303624;529549;727654;922854;118225;146937;172332;201111;304020;529953;729254;923755;118528;147030;172433;201414;304727;530635;729557;927359;118730;147737;172534;201515;305830;531536;731140;930449;118932;148032;172938;201818;307127;536647;732243;932554;119126;148133;173334;202113;308129;540436;734045;937160;119732;148335;173435;202719;308331;541943;735148;942658;119833;148840;173536;203418;309636;545345;742549;947668;120111;148941;173637;203923;310621;547046;744553;952863;120212;149236;173738;204016;311320;548250;748258;955465;120515;149337;173839;204319;316633;553344;748662;957974;120717;149539;173940;204420;316835;555348;749058;958976;121416;149741;174437;204521;317332;555651;751348;959574;121618;149842;174841;204622;318637;557857;751550;965367;121921;150019;175035;205119;320826;559053;753150;965771;122317;150625;175237;205220;321323;561242;756055;966975;122620;150726;175338;205725;322224;561444;759869;972566;122822;150928;175439;205826;330324;562345;761957;978578;123117;151223;175540;206222;333330;562446;765056;983773;123420;151425;175742;207123;334635;565452;766563;984472;123521;151526;176037;207426;336841;566454;767464;987983;123925;151627;176239;208125;339847;567052;769064;990366;124220;151728;176441;208226;341834;567961;770352;991267;124422;151829;176542;208327;346137;568963;771354;992673;124624;152831;176744;209127;346945;571548;773257;992774;124826;153025;177241;209228;351938;572045;779370;993675;125525;153227;177645;209329;352132;573249;782561;994273;126325;153429;177746;209935;353740;573451;783462;996782;126628;153732;178142;210011;358144;576255;784565;127630;154229;178243;210415;361234;579867;786569];

subjects = setdiff(subjects,existent);

initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=01:00:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nexport PATH=/homec/hbu23/hbu231/testmrtrix_DK/mrtrix3/release/bin:$PATH\nexport PATH=/homec/hbu23/hbu231/testmrtrix_DK/mrtrix3/scripts:$PATH\n\n'];


input_folder_dwi        = '/work/hbu23/hbu231/HCP_pipeline_tmp/DWI_normalized/';
hcp_data_folder         = '~/_data/hcp_data/hcp/';
output_folder           = '~/HCP_Connectomes/SC/DWI_response_functions/';


break_counter = 0;
preproc_patch = 0;
fileID_batch = fopen('step5_2_dwi2response_start','w');
for ii = 1:length(subjects)
    if break_counter == 0
        command     = initstring;        
    end
    break_counter = break_counter + 1;   
    
    input_dwi               = [input_folder_dwi     num2str(subjects(ii)) '_dwi_normalized.mif'];  
    file_5tt                = [hcp_data_folder      num2str(subjects(ii)) '/T1w/5tt.mif']; 
    output_RF_WM            = [output_folder        num2str(subjects(ii)) '_RF_WM.txt']; 
    output_RF_GM            = [output_folder        num2str(subjects(ii)) '_RF_GM.txt']; 
    output_RF_CSF           = [output_folder        num2str(subjects(ii)) '_RF_CSF.txt']; 

    
   % command         = [command 'srun -n 1 --exclusive -c 48 dwi2response msmt_5tt ' input_dwi ' ' file_5tt ' ' output_RF_WM ' ' output_RF_GM ' ' output_RF_CSF ' -tempdir /work/hbu23/hbu231/tmp &\n'];
   %  command         = [command 'dwi2response msmt_5tt ' input_dwi ' ' file_5tt ' ' output_RF_WM ' ' output_RF_GM ' ' output_RF_CSF ' -tempdir /work/hbu23/hbu231/tmp &\n'];
  command         = [command 'dwi2response dhollander ' input_dwi ' ' output_RF_WM ' ' output_RF_GM ' ' output_RF_CSF ' -nthreads 0 -tempdir /work/hbu23/hbu231/tmp -force &\n'];
   
    if break_counter == 6 || ii == length(subjects)
        preproc_patch = preproc_patch + 1;
        finalstring = [command '\nwait\n'];
        fileID = fopen(['step5_2_dwi2response_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);        
        fprintf(fileID_batch, ['sbatch step5_2_dwi2response_' num2str(preproc_patch) '\n']);
        break_counter = 0;
    end
end
fclose(fileID_batch);


%% Test for JD Tournier


% mrconvert

initstring = ['#!/bin/bash -x\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n#SBATCH --time=01:00:00\n#SBATCH --partition=batch\nmodule load GCC/5.4.0\nmodule load MRtrix/0.3.15-Python-2.7.12\n\n'];

hcp_data_folder = '~/_data/hcp_data/hcp/';
output_folder   = '/work/hbu23/hbu231/jd_test/';

break_counter = 0;
preproc_patch = 0;
for ii = 1:32
    if break_counter == 0
        command     = [initstring ' time ( '];        
    end
    break_counter = break_counter + 1;   
    
    input_file  = [hcp_data_folder num2str(subjects(ii)) '/T1w/Diffusion/data.nii.gz'];
    bvecs_file  = [hcp_data_folder num2str(subjects(ii)) '/T1w/Diffusion/bvecs'];
    bvals_file  = [hcp_data_folder num2str(subjects(ii)) '/T1w/Diffusion/bvals'];
    output_file = [output_folder   num2str(subjects(ii)) '_dwi0.mif'];  
    
    command      = [command 'mrconvert ' input_file ' ' output_file ' -fslgrad ' bvecs_file ' ' bvals_file ' -datatype float32 -stride 0,0,0,1 -nthreads 0 & ;\n'];
    
    if break_counter == 32 
        preproc_patch = preproc_patch + 1;
        finalstring = [command ' ) \nwait\n'];
        fileID = fopen(['test_mrconvert_' num2str(preproc_patch)],'w');
        fprintf(fileID,finalstring);
        fclose(fileID);
        display(['sbatch test_mrconvert_' num2str(preproc_patch)]);
        break_counter = 0;
    end
end


