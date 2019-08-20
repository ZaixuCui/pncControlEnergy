
% Calculating modularity metric Q

clear

Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';
Matrix_Folder = [Data_Folder '/matrices_withoutBrainStem'];
ResultantFile = [Data_Folder '/Modularity_Yeo_Q_Prob.mat'];
Lausanne125_Matrix_Cell = g_ls([Matrix_Folder '/*.mat']);
load([Data_Folder '/Yeo_7system.mat']);
S = Yeo_7system([1:191 193:233]);
gamma = 1;
for i = 1:length(Lausanne125_Matrix_Cell)
    i
    [~, FileName, ~] = fileparts(Lausanne125_Matrix_Cell{i});
    scanID(i) = str2num(FileName(1:4));
    load(Lausanne125_Matrix_Cell{i});
    A = connectivity / svds(connectivity, 1);
    % Calculating modularity index Q
    N = size(A,1);
    twomu = 0;
    for s=1
        k=sum(A(:,:,s));
    	twom=sum(k);
    	twomu=twomu+twom;
    	indx=[1:N]+(s-1)*N;
    	B(indx,indx)=A(:,:,s)-gamma*k'*k/twom;
    end
    Modularity_Yeo_Q(i) = sum(B(bsxfun(@eq,S,S.'))) ./ twomu;
end
scanID = scanID';
Modularity_Yeo_Q = Modularity_Yeo_Q';
save(ResultantFile, 'scanID', 'Modularity_Yeo_Q');

