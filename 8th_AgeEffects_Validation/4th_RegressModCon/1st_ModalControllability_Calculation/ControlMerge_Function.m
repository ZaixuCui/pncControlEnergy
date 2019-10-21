
function ConMerge_Function(ConFile_Cell, ResultantFile)

SubjectsQuantity = length(ConFile_Cell);
tmp = load(ConFile_Cell{1});
NodesQuantity = length(tmp.mod_cont);
mod_cont = zeros(SubjectsQuantity, NodesQuantity);
for i = 1:length(ConFile_Cell)
    tmp = load(ConFile_Cell{i});
    mod_cont(i, :) = tmp.mod_cont;
    [~, FileName, ~] = fileparts(ConFile_Cell{i});
    scan_ID(i) = str2num(FileName);
end
save(ResultantFile, 'mod_cont', 'scan_ID');
