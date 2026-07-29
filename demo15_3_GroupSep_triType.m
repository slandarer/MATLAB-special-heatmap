%% Group Sep with triangular heatmap

% Made up some data casually (随便捏造了点数据)
X = randn(20, 15) + [(linspace(-1,2.5,20)').*ones(1, 6), ...
    (linspace(.5,-.7,20)').*ones(1, 3), ...
    (linspace(.9,-.2,20)').*ones(1, 5), ...
    linspace(1.9,-.2,20)'];
% Get the correlation matrix (求相关系数矩阵)
Data = corr(X);


figure()
SHM = SHeatmap(Data, 'Format','donut');
SHM.RowGroup = [1,1,1,1,1,1, 2,2,2, 3,3,3,3,3, 4];
SHM.ColGroup = [1,1,1,1,1,1, 2,2,2, 3,3,3,3,3, 4];
SHM.VarName = {'A1','A2','A3','A4','A5','A6', 'B1','B2','B3', 'C1','C2','C3','C4','C5', 'D1'};
SHM.draw().setType('triu').setFrame()



