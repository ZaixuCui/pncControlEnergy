
function EnergyCal_SGE_Function(ConnPathCell, T, xc, x0, xf, S, rho, ResultantFolder)

psom_gb_vars
Pipeline_opt.mode = 'qsub';
Pipeline_opt.qsub_options = '-q all.q,basic.q';
Pipeline_opt.mode_pipeline_manager = 'batch';
Pipeline_opt.max_queued = 1000;
Pipeline_opt.flag_verbose = 1;
Pipeline_opt.flag_pause = 0;
Pipeline_opt.path_logs = [ResultantFolder '/logs'];

for i = 1:length(ConnPathCell)
  [~, FileName, ~] = fileparts(ConnPathCell{i});
  scanID_str = FileName(1:4);
  ResultantFile = [ResultantFolder '/' num2str(scanID_str) '.mat'];

  Job_Name = ['EnergyCal_' num2str(i)];
  pipeline.(Job_Name).command = 'EnergyCal_Function(opt.para1, opt.para2, opt.para3, opt.para4, opt.para5, opt.para6, opt.para7, opt.para8)';
  pipeline.(Job_Name).opt.para1 = ConnPathCell{i};
  pipeline.(Job_Name).opt.para2 = T;
  pipeline.(Job_Name).opt.para3 = xc;
  pipeline.(Job_Name).opt.para4 = x0;
  pipeline.(Job_Name).opt.para5 = xf;
  pipeline.(Job_Name).opt.para6 = S;
  pipeline.(Job_Name).opt.para7 = rho;
  pipeline.(Job_Name).opt.para8 = ResultantFile;
  pipeline.(Job_Name).files_out{1} = ResultantFile;
end

[ParentFolder, FolderName, ~] = fileparts(ResultantFolder);
ResultantFile = [ParentFolder '/' FolderName '.mat'];
Job_Name = 'Merge';
for i = 1:length(ConnPathCell)
  EnergyCal_JobName = ['EnergyCal_' num2str(i)];
  pipeline.(Job_Name).files_in{i} = pipeline.(EnergyCal_JobName).files_out{1};
end
pipeline.(Job_Name).command = 'EnergyMerge_Function(files_in, files_out{1})';
pipeline.(Job_Name).files_out{1} = ResultantFile;

psom_run_pipeline(pipeline, Pipeline_opt);
