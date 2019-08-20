
function PC_Calculation(ConnMatrix, Community_Vector, scanID, ResultantFolder)

PC = participation_coef(ConnMatrix, Community_Vector);
save([ResultantFolder '/' num2str(scanID) '.mat'], 'PC', 'scanID');



