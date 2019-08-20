
clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  1) Copying SC matrices and Removing brain stem  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
SubjectsIDs = csvread([ReplicationFolder '/data/pncControlEnergy_n946_SubjectsIDs.csv'], 1);
scanID = SubjectsIDs(:, 2);

% Probabilisitc network
% The main results of the paper were based on probabilistic network
Original_Folder = '/data/jux/BBL/projects/pncBaumDti/probtrackx_2017/Motion_Paper';
Resultant_Folder = [ReplicationFolder '/data/matrices_withoutBrainStem/'];
mkdir(Resultant_Folder);
%
% Copying and Removing the brain stem from the probabilistic matrices
%
% Note: the 192th region was isolated for 15 subjects in the sample of 946 subjects, remove this region for all subjects
%
for i = 1:length(scanID)
   i
   tmp_path_Cell = g_ls([Original_Folder '/*/*' num2str(scanID(i)) '/wmEdge_p1000_pialTerm/output/*.mat']);
   load(tmp_path_Cell{1});
   connectivity = A_prop_und([1:191 193:end], [1:191 193:end]); % Remove the 192th region
   save([Resultant_Folder '/' num2str(scanID(i)) '_Prob_LausanneScale125.mat'], 'connectivity');
end


