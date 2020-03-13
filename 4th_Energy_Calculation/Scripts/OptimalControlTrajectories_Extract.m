
clear
Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';
SubjectsID_Info = csvread([Data_Folder '/pncControlEnergy_n946_SubjectsIDs.csv'], 1);
scanID = SubjectsID_Info(:, 2);
EnergyData_Folder = [Data_Folder '/energyData/InitialAll0_TargetFP'];
% Extracting trajectories, distance, energy series for each subject
X_Trajectories = zeros(1001, 27);
for i = 1:946
  i
  DataPath = [EnergyData_Folder '/' num2str(scanID(i)) '.mat'];
  tmpData = load(DataPath);
  % Sum all subjects' trajectories
  X_Trajectories = X_Trajectories + tmpData.X_Opt_Trajectory;
  % Trajectory distance series for each subject
  Square_Sum = sum((repmat(ones(1, 27), 1001, 1) - tmpData.X_Opt_Trajectory).^2, 2);
  Norm_Distance = sqrt(Square_Sum);
  Distance_Series(i, :) = Norm_Distance';
  % Energy series for each subject
  U_Opt_Trajectory = tmpData.U_Opt_Trajectory;
  Energy_Series(i, :) = sum(U_Opt_Trajectory.^2 * 0.001, 2);
end
X_Trajectories_SubjectsAvg = X_Trajectories / 946;
Distance_Subjects = sum(Distance_Series, 2);
Energy_Subjects = sum(Energy_Series, 2);
save([Data_Folder '/energyData/InitialAll0_TargetFP_TrajectoryInfo.mat'], 'X_Trajectories_SubjectsAvg', 'Distance_Series', 'Energy_Series', 'Distance_Subjects', 'Energy_Subjects');

for i = 1:946
  plot(1:1001, Distance_Series(i, :));
  hold on;
end

for i = 1:946
  plot(1:1001, Energy_Series(i, :));
  hold on;
end
