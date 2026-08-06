%% Merge two triangular heatmaps with diagonal variable names

% Made up some data casually (随便捏造了点数据)
X = randn(20,12) + [(linspace(-1,2.5,20)').*ones(1, 5), (linspace(.5,-.7,20)').*ones(1, 4), (linspace(.9,-.2,20)').*ones(1, 3)];
% Get the correlation matrix (求相关系数矩阵)
[Data, pval] = corr(X);

figure()
SHM_m1 = SHeatmap(Data, 'Format','sq').draw().setType('tril0');
SHM_m1.setRowLabel('Visible','off').setColLabel('Visible','off')
SHM_m1.setText()
% SHM_m1.showStars(pval, 'Levels', [0.05, 0.01, 0.001], 'CorrLabel','off')

SHM_m2 = SHeatmap(Data, 'Format','hex').draw().setType('triu');
SHM_m2.setColLabel('Visible','off')


SHM_m2.setPatch(eye(size(Data)) == 1, 'Visible','off')

for i = 1:length(SHM_m2.rowLabelHdl)
    SHM_m2.rowLabelHdl(i).Position(1) = ...
        SHM_m2.rowLabelHdl(i).Position(1) + .75;
    set(SHM_m2.rowLabelHdl(i), 'HorizontalAlignment','center', 'FontSize',12)
end
