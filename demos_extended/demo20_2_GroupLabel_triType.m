% GroupLabel for triangular heatmap

addpath('..\')
% Made up some data casually (随便捏造了点数据)
X = randn(20, 15) + [(linspace(-1,2.5,20)').*ones(1, 6), ...
    (linspace(.5,-.7,20)').*ones(1, 3), ...
    (linspace(.9,-.2,20)').*ones(1, 6)];
% Get the correlation matrix (求相关系数矩阵)
Data = corr(X);


figure()
SHM = SHeatmap(Data, 'Format','sq', 'GroupLabelOffset',1);
SHM.RowGroup = [1,1,1,1,1,1, 2,2,2, 3,3,3,3,3,3];
SHM.ColGroup = [1,1,1,1,1,1, 2,2,2, 3,3,3,3,3,3];
SHM.VarName = {'A1','A2','A3','A4','A5','A6', 'B1','B2','B3', 'C1','C2','C3','C4','C5','C6'};
SHM.draw().setType('tril0').setFrame()

SHM.setColGroupName({'Group-A','Group-B','Group-C'})
SHM.setColGroupLabelLocation('bottom')
SHM.setRowGroupName({'Group-A','Group-B','Group-C'})
SHM.setRowGroupLabelLocation('diag')



