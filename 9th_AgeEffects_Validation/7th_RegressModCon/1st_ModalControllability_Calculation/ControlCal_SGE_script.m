% Calculating average and modal controllability

clear

Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';
Matrix_Folder = [Data_Folder '/matrices_withoutBrainStem'];

ControlFolder = [Data_Folder '/Controllability'];
ResultantFolder = [ControlFolder '/AllSubFiles'];
mkdir(ResultantFolder);

Lausanne125_Matrix_Cell = g_ls([Matrix_Folder '/*.mat']);
for i = 1:length(Lausanne125_Matrix_Cell)
    i
    [~, FileName, ~] = fileparts(Lausanne125_Matrix_Cell{i});
    scanID_str = FileName(1:4);
    ResultantFile = [ResultantFolder '/' num2str(scanID_str) '.mat'];

    Job_Name = ['ConCal_' num2str(i)];
    pipeline.(Job_Name).command = 'ControlCal_Function(opt.para1, files_out{1})';
    pipeline.(Job_Name).opt.para1 = Lausanne125_Matrix_Cell{i};
    pipeline.(Job_Name).files_out{1} = ResultantFile;
end

ResultantFile = [ControlFolder '/Lausanne125_Control.mat'];
Job_Name = 'Merge';
for i = 1:length(Lausanne125_Matrix_Cell)
    ConCal_JobName = ['ConCal_' num2str(i)];
    pipeline.(Job_Name).files_in{i} = pipeline.(ConCal_JobName).files_out{1};
end
pipeline.(Job_Name).command = 'ControlMerge_Function(files_in, files_out{1})';
pipeline.(Job_Name).files_out{1} = ResultantFile;

psom_gb_vars
Pipeline_opt.mode = 'qsub';
Pipeline_opt.qsub_options = '-q all.q';
Pipeline_opt.mode_pipeline_manager = 'batch';
Pipeline_opt.max_queued = 1000;
Pipeline_opt.flag_verbose = 1;
Pipeline_opt.flag_pause = 0;
Pipeline_opt.path_logs = [ResultantFolder '/logs'];

psom_run_pipeline(pipeline, Pipeline_opt);

