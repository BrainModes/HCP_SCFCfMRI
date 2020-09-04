clear
close all
clc

cd('/Users/michael/Desktop/HCP_project/Connectome_pipeline/FC')

fid=fopen('region_sorting_a2009.txt');
a2009_txt=textscan(fid,'%s');
fclose(fid);

inds = 2:6:884;
for ii = 1:length(inds)
    tmp = a2009_txt{1,1}{inds(ii),1};
    reg_inds_a2009(ii) = str2num(tmp(1:end-1));
end

inds = 3:6:885;
for ii = 1:length(inds)
    reg_ids_a2009{ii,1} = a2009_txt{1,1}{inds(ii),1};
end


fid=fopen('region_sorting_aparc.txt');
aparc_txt=textscan(fid,'%s');
fclose(fid);

inds = 2:6:404;
for ii = 1:length(inds)
    tmp = aparc_txt{1,1}{inds(ii),1};
    reg_inds_aparc(ii) = str2num(tmp(1:end-1));
end

inds = 3:6:405;
for ii = 1:length(inds)
    reg_ids_aparc{ii,1} = aparc_txt{1,1}{inds(ii),1};
end


fid=fopen('region_sorting_subcortical.txt');
subcort_txt=textscan(fid,'%s');
fclose(fid);

inds = 2:5:92;
for ii = 1:length(inds)
    tmp = subcort_txt{1,1}{inds(ii),1};
    reg_inds_subcort(ii) = str2num(tmp(1:end-1));
end

inds = 3:5:93;
for ii = 1:length(inds)
    reg_ids_subcort{ii,1} = subcort_txt{1,1}{inds(ii),1};
end



[a mrtrix_a2009_regid c d e f]=textread('mrtrix_a2009.txt','%d %s %d %d %d %d');
[a b mrtrix_aparc_regid c d e f]=textread('mrtrix_aparc.txt','%d %s %s %d %d %d %d');

%

fc_2_sc_a2009(1:74)     = 1:74;     % from a2009
fc_2_sc_a2009(75:79)    = 1:5;      % From subcortical
fc_2_sc_a2009(80:82)    = 7:9;      % From subcortical
fc_2_sc_a2009(83:89)    = 12:18;    % From subcortical
fc_2_sc_a2009(90:163)   = 90:163;   % from a2009
fc_2_sc_a2009(164)      = 11;       % from subcortical

for ii = 1:163
    
    if ii <= 74
        new_FC_a2009{ii}    = mrtrix_a2009_regid{ii} ;
    elseif ii == 75
        new_FC_a2009{ii}    = reg_ids_subcort{1} ;    
    elseif ii == 76
        new_FC_a2009{ii}    = reg_ids_subcort{2} ; 
    elseif ii == 77
        new_FC_a2009{ii}    = reg_ids_subcort{3} ; 
    elseif ii == 78
        new_FC_a2009{ii}    = reg_ids_subcort{4} ; 
    elseif ii == 79
        new_FC_a2009{ii}    = reg_ids_subcort{5} ;
    elseif ii == 80
        new_FC_a2009{ii}    = reg_ids_subcort{7} ;
    elseif ii == 81
        new_FC_a2009{ii}    = reg_ids_subcort{8} ;
    elseif ii == 82
        new_FC_a2009{ii}    = reg_ids_subcort{9} ;
    elseif ii == 83
        new_FC_a2009{ii}    = reg_ids_subcort{12} ;
    elseif ii == 84
        new_FC_a2009{ii}    = reg_ids_subcort{13} ;
    elseif ii == 85
        new_FC_a2009{ii}    = reg_ids_subcort{14} ;
    elseif ii == 86
        new_FC_a2009{ii}    = reg_ids_subcort{15} ;
    elseif ii == 87
        new_FC_a2009{ii}    = reg_ids_subcort{16} ;
    elseif ii == 88
        new_FC_a2009{ii}    = reg_ids_subcort{17} ;
    elseif ii == 89
        new_FC_a2009{ii}    = reg_ids_subcort{18} ;
    elseif ii >= 90
        new_FC_a2009{ii}    = mrtrix_a2009_regid{ii} ;
    end
end

%%
clc

for ii = 1:74
    
   display([num2str(ii) ':  '  mrtrix_a2009_regid{ii}  '            '  reg_ids_a2009{ii}]) 
   tmp1=mrtrix_a2009_regid{ii};
   tmp1=tmp1(8:end);
   tmp2=reg_ids_a2009{ii};
   tmp2=tmp2(3:end);
   if ~strcmp(tmp1,tmp2) 
       break
       display('ERROR')
   end
end

for ii = 90:163
   i2 = ii - 15;
   display([num2str(ii) ':  '  mrtrix_a2009_regid{ii}  '            '  reg_ids_a2009{i2}]) 
   tmp1=mrtrix_a2009_regid{ii};
   tmp1=tmp1(8:end);
   tmp2=reg_ids_a2009{i2};
   tmp2=tmp2(3:end);
   if ~strcmp(tmp1,tmp2) 
       break
       display('ERROR')
   end
end



%%
clc

for ii = 1:163
   
   display([num2str(ii) ':  '  mrtrix_a2009_regid{ii}  '            '  new_FC_a2009{ii}]) 

end











%%





%%








clear
close all
clc

cd('/Users/michael/Desktop/HCP_project/Connectome_pipeline/FC')

fid=fopen('region_sorting_a2009.txt');
a2009_txt=textscan(fid,'%s');
fclose(fid);

inds = 2:6:884;
for ii = 1:length(inds)
    tmp = a2009_txt{1,1}{inds(ii),1};
    reg_inds_a2009(ii) = str2num(tmp(1:end-1));
end

inds = 3:6:885;
for ii = 1:length(inds)
    reg_ids_a2009{ii,1} = a2009_txt{1,1}{inds(ii),1};
end


fid=fopen('region_sorting_aparc.txt');
aparc_txt=textscan(fid,'%s');
fclose(fid);

inds = 2:6:404;
for ii = 1:length(inds)
    tmp = aparc_txt{1,1}{inds(ii),1};
    reg_inds_aparc(ii) = str2num(tmp(1:end-1));
end

inds = 3:6:405;
for ii = 1:length(inds)
    reg_ids_aparc{ii,1} = aparc_txt{1,1}{inds(ii),1};
end


fid=fopen('region_sorting_subcortical.txt');
subcort_txt=textscan(fid,'%s');
fclose(fid);

inds = 2:5:92;
for ii = 1:length(inds)
    tmp = subcort_txt{1,1}{inds(ii),1};
    reg_inds_subcort(ii) = str2num(tmp(1:end-1));
end

inds = 3:5:93;
for ii = 1:length(inds)
    reg_ids_subcort{ii,1} = subcort_txt{1,1}{inds(ii),1};
end



[a mrtrix_a2009_regid c d e f]=textread('mrtrix_a2009.txt','%d %s %d %d %d %d');
[a b mrtrix_aparc_regid c d e f]=textread('mrtrix_aparc.txt','%d %s %s %d %d %d %d');

%

fc_2_sc_aparc(1:34)     = 1:34;     % from aparc
fc_2_sc_aparc(35:39)    = 1:5;      % From subcortical
fc_2_sc_aparc(40:42)    = 7:9;      % From subcortical
fc_2_sc_aparc(43:49)    = 12:18;    % From subcortical
fc_2_sc_aparc(50:83)    = 50:83;    % from aparc
fc_2_sc_aparc(84)       = 11;       % from subcortical

for ii = 1:83
    
    if ii <= 34
        new_FC_aparc{ii}    = mrtrix_aparc_regid{ii} ;
    elseif ii == 35
        new_FC_aparc{ii}    = reg_ids_subcort{1} ;    
    elseif ii == 36
        new_FC_aparc{ii}    = reg_ids_subcort{2} ; 
    elseif ii == 37
        new_FC_aparc{ii}    = reg_ids_subcort{3} ; 
    elseif ii == 38
        new_FC_aparc{ii}    = reg_ids_subcort{4} ; 
    elseif ii == 39
        new_FC_aparc{ii}    = reg_ids_subcort{5} ;
    elseif ii == 40
        new_FC_aparc{ii}    = reg_ids_subcort{7} ;
    elseif ii == 41
        new_FC_aparc{ii}    = reg_ids_subcort{8} ;
    elseif ii == 42
        new_FC_aparc{ii}    = reg_ids_subcort{9} ;
    elseif ii == 43
        new_FC_aparc{ii}    = reg_ids_subcort{12} ;
    elseif ii == 44
        new_FC_aparc{ii}    = reg_ids_subcort{13} ;
    elseif ii == 45
        new_FC_aparc{ii}    = reg_ids_subcort{14} ;
    elseif ii == 46
        new_FC_aparc{ii}    = reg_ids_subcort{15} ;
    elseif ii == 47
        new_FC_aparc{ii}    = reg_ids_subcort{16} ;
    elseif ii == 48
        new_FC_aparc{ii}    = reg_ids_subcort{17} ;
    elseif ii == 49
        new_FC_aparc{ii}    = reg_ids_subcort{18} ;
    elseif ii >= 50
        new_FC_aparc{ii}    = mrtrix_aparc_regid{ii} ;
    end
end
new_FC_aparc{84}    = reg_ids_subcort{11} ;
%%
clc

for ii = 1:34
    
   display([num2str(ii) ':  '  mrtrix_aparc_regid{ii}  '            '  reg_ids_aparc{ii}]) 
   tmp1=mrtrix_aparc_regid{ii};
   tmp1=tmp1(8:end);
   tmp2=reg_ids_aparc{ii};
   tmp2=tmp2(3:end);
   if ~strcmp(tmp1,tmp2) 
       
       display('ERROR')
       break
   end
end

for ii = 50:83
   i2 = ii - 15;
   display([num2str(ii) ':  '  mrtrix_aparc_regid{ii}  '            '  reg_ids_aparc{i2}]) 
   tmp1=mrtrix_aparc_regid{ii};
   tmp1=tmp1(8:end);
   tmp2=reg_ids_aparc{i2};
   tmp2=tmp2(3:end);
   if ~strcmp(tmp1,tmp2) 
       
       display('ERROR')
       break
   end
end



%%
clc

for ii = 1:84
   
   display([num2str(ii) ':  '  mrtrix_aparc_regid{ii}  '            '  new_FC_aparc{ii}]) 

end




