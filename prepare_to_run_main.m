function grp_proc_info_in = prepare_to_run_main

% set defaults and path, get user inputs
grp_proc_info_in = beapp_configure_settings;

%% check user inputs and adjust settings
grp_proc_info_in=orderfields(grp_proc_info_in);
if ~(islogical(grp_proc_info_in.beapp_toggle_mods.Module_On)&&islogical(grp_proc_info_in.beapp_toggle_mods.Module_Export_On)&&islogical(grp_proc_info_in.beapp_toggle_mods.Module_Xls_Out_On))
    err('User module inputs must be one or zero');
    exit('beapp_main');
end

grp_proc_info_in.bw_total_freqs = sort(grp_proc_info_in.bw_total_freqs);

if grp_proc_info_in.src_format_typ ==3
    grp_proc_info_in.beapp_toggle_mods{'format','Module_Output_Type'} = {'seg'};
end

%set the variables for multitaper window if selected by user
set_beapp_pmtm_vars;
%% prepping net library 
if ~isdir([grp_proc_info_in.ref_net_library_dir]);
    mkdir([grp_proc_info_in.ref_net_library_dir]);
end

cd (grp_proc_info_in.ref_net_library_dir)

% compare existing net library variables with those listed in table
net_variable_list = dir('*.mat');
net_variable_list = {net_variable_list.name};
net_variable_list = strrep(net_variable_list,'.mat','');
load(grp_proc_info_in.ref_net_library_options)
[nets_to_add,nets_to_add_indexes] = setdiff(net_library_options.Net_Variable_Name,net_variable_list);

if ~isempty(nets_to_add)
    net_list = net_library_options.Net_Full_Name(nets_to_add_indexes)';
    
    % clear extraneous nets from table, and add user to read them 
    net_library_options.Net_Full_Name(nets_to_add_indexes) ={''};
    net_library_options.Net_Variable_Name(nets_to_add_indexes) = {''};
    net_library_options.Number_of_Electrodes(nets_to_add_indexes) = 0;
    
    save(grp_proc_info_in.ref_net_library_options,'net_library_options');
    
    add_nets_to_library(net_list,grp_proc_info_in.ref_net_library_options,...
        grp_proc_info_in.ref_net_library_dir, grp_proc_info_in.ref_eeglab_loc_dir,grp_proc_info_in.name_10_20_elecs);  
end

%% set output directories, create temporary report
[grp_proc_info_in,modnames,first_mod_ind] = beapp_dir_prep(grp_proc_info_in);
diary off;
if ~strcmp(grp_proc_info_in.beapp_curr_run_tag,'NONE')
    if exist([grp_proc_info_in.beapp_genout_dir{1} filesep 'BEAPP_Run_Reporting_' grp_proc_info_in.beapp_curr_run_tag '.txt'])==2
        delete ([grp_proc_info_in.beapp_genout_dir{1} filesep 'BEAPP_Run_Reporting_' grp_proc_info_in.beapp_curr_run_tag '.txt'])
    end
    diary([grp_proc_info_in.beapp_genout_dir{1} filesep 'BEAPP_Run_Reporting_' grp_proc_info_in.beapp_curr_run_tag '.txt']);
else
    if exist([grp_proc_info_in.beapp_genout_dir{1} filesep 'BEAPP_Run_Reporting.txt'])==2
        delete([grp_proc_info_in.beapp_genout_dir{1} filesep 'BEAPP_Run_Reporting.txt'])
    end
    diary([grp_proc_info_in.beapp_genout_dir{1} filesep 'BEAPP_Run_Reporting.txt']);
end

%% collect needed info if rerun
if ~grp_proc_info_in.beapp_toggle_mods{'format','Module_On'}
    [grp_proc_info_in.beapp_fname_all,grp_proc_info_in.src_unique_srates,grp_proc_info_in.src_unique_net_vstructs,grp_proc_info_in.src_unique_nets,...
        grp_proc_info_in.src_unique_net_ref_rows, grp_proc_info_in.src_net_10_20_elecs,grp_proc_info_in.largest_nchan]=...
        beapp_rerun_set_up(grp_proc_info_in.beapp_toggle_mods,modnames{first_mod_ind},grp_proc_info_in.rerun_file_info_table,grp_proc_info_in.beapp_use_rerun_table,...
        grp_proc_info_in.src_unique_srates,grp_proc_info_in.src_unique_nets,grp_proc_info_in.ref_net_library_options,grp_proc_info_in.ref_net_library_dir);
end