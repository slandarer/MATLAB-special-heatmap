%% Merge two triangular heatmaps with diagonal variable names

% Made up some data casually (随便捏造了点数据)
X = randn(20,12) + [(linspace(-1,2.5,20)').*ones(1, 5), (linspace(.5,-.7,20)').*ones(1, 4), (linspace(.9,-.2,20)').*ones(1, 3)];
% Get the correlation matrix (求相关系数矩阵)
Data = corr(X);

figure()
SHM_m1 = SHeatmap(Data, 'Format','sq').draw().setType('varl');
SHM_m1.setText()

SHM_m2 = SHeatmap(Data, 'Format','hex').draw().setType('triu0');
SHM_m2.setColLabel('Visible','off').setRowLabel('Visible','off')
