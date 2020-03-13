
function EnergyMerge_Function(EnergyFile_Cell, ResultantFile)

SubjectsQuantity = length(EnergyFile_Cell);
tmp = load(EnergyFile_Cell{1});
[TimepointsQuantity, TargetsQuantity] = size(tmp.X_Opt_Trajectory);
NodesQuantity = length(tmp.Energy);
X_Opt_Final = zeros(SubjectsQuantity, TargetsQuantity);
Energy = zeros(SubjectsQuantity, NodesQuantity);
n_err = zeros(SubjectsQuantity, 1);
xf = zeros(SubjectsQuantity, NodesQuantity);

for i = 1:length(EnergyFile_Cell)
  tmp = load(EnergyFile_Cell{i});
  X_Opt_Final(i, :) = tmp.X_Opt_Final;
  Energy(i, :) = tmp.Energy;
  n_err(i) = tmp.n_err;
  xf(i, :) = tmp.xf;
  [~, FileName, ~] = fileparts(EnergyFile_Cell{i});
  scan_ID(i) = str2num(FileName);
end
save(ResultantFile, 'X_Opt_Final', 'Energy', 'n_err', 'xf', 'scan_ID');
