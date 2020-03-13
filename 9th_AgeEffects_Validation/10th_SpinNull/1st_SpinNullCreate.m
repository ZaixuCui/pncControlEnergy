
clear
ProjectsFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
Lausanne125_Folder = [ProjectsFolder '/data/Lausanne125'];
path_sphere_lh = [Lausanne125_Folder '/surf/lh.sphere']; 
path_sphere_rh = [Lausanne125_Folder '/surf/rh.sphere'];
path_annot_lh = [Lausanne125_Folder '/label/lh.myaparc_125.annot'];
path_annot_rh = [Lausanne125_Folder '/label/rh.myaparc_125.annot'];
[centroid_lh, names_lh] = centroid_extraction_sphere(path_sphere_lh, path_annot_lh);
[centroid_rh, names_rh] = centroid_extraction_sphere(path_sphere_rh, path_annot_rh);
for i = 1:length(names_lh)
  names_lh{i} = [names_lh{i} '_L'];
end
for i = 1:length(names_rh)
  names_rh{i} = [names_rh{i} '_R'];
end
names = [names_lh names_rh];
ResultantFolder = [ProjectsFolder '/data/energyData/SpinNullFPTarget/FPRotateIndex'];
mkdir(ResultantFolder);

AtlasName_Mat = load('/data/jux/BBL/projects/pncControlEnergy/data/atlas/Lausanne125Regions.mat');
for i = 1:length(AtlasName_Mat.Lausanne125Regions)
  AtlasName_Mat.Lausanne125Regions{i} = strrep(AtlasName_Mat.Lausanne125Regions{i}, ' ', '');
end
YeoSystem_Mat = load([ProjectsFolder '/data/Yeo_7system.mat']);
FPNames = AtlasName_Mat.Lausanne125Regions(find(YeoSystem_Mat.Yeo_7system == 6));

for i = 1:length(FPNames)
  for j = 1:length(names)
    if strcmp(names{j}, FPNames{i})
      FPRawIndex(i) = j;
      break;
    end
  end
end

for m = 18:100
  m 
  while 1
    Rotate_parcellation_index = rotate_parcellation(centroid_lh, centroid_rh, 1);
    FPIndex_CorticalRotate = Rotate_parcellation_index(FPRawIndex);
    FPRegionName_CorticalRotate = names(FPIndex_CorticalRotate);

    for i = 1:length(FPRegionName_CorticalRotate)
      for j = 1:length(AtlasName_Mat.Lausanne125Regions)
        if strcmp(AtlasName_Mat.Lausanne125Regions{j}, FPRegionName_CorticalRotate{i})
          FPRotateIndex_InAtlas(i) = j;
          break;
        end
      end
    end

    if isempty(find(FPRotateIndex_InAtlas == 192))
      break;
    end
  end

  save([ResultantFolder '/FPRotateIndex_InAtlas_' num2str(m) '.mat'], 'FPRotateIndex_InAtlas');
end

