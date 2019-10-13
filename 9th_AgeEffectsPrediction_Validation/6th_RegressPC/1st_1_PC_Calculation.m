
% Calculating participant coefficient

clear

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
Data_Folder = [ReplicationFolder '/data'];
Matrix_Folder = [Data_Folder '/matrices_withoutBrainStem'];
ResultantFolder = [Data_Folder '/PC'];
Lausanne125_Matrix_Cell = g_ls([Matrix_Folder '/*.mat']);
load([Data_Folder '/Yeo_7system.mat']);
Community = Yeo_7system([1:191 193:233]);
for i = 1:length(Lausanne125_Matrix_Cell)
    i
    [~, FileName, ~] = fileparts(Lausanne125_Matrix_Cell{i});
    scanID = str2num(FileName(1:4));
    tmp = load(Lausanne125_Matrix_Cell{i});
    A = tmp.connectivity;
    A = tmp.connectivity ./ svds(tmp.connectivity, 1);
    A = A - eye(size(A));
    % Calculating participant coefficient
    Job_Name = ['PC_' num2str(i)];
    pipeline.(Job_Name).command = 'PC_Function(opt.para1, opt.para2, opt.para3, opt.para4)';
    pipeline.(Job_Name).opt.para1 = A;
    pipeline.(Job_Name).opt.para2 = Community;
    pipeline.(Job_Name).opt.para3 = scanID;
    pipeline.(Job_Name).opt.para4 = ResultantFolder;
end

psom_gb_vars
Pipeline_opt.mode = 'qsub';
Pipeline_opt.qsub_options = '-q all.q,basic.q';
Pipeline_opt.mode_pipeline_manager = 'batch';
Pipeline_opt.max_queued = 1000;
Pipeline_opt.flag_verbose = 1;
Pipeline_opt.flag_pause = 0;
Pipeline_opt.path_logs = [ResultantFolder '/logs'];

psom_run_pipeline(pipeline, Pipeline_opt);


