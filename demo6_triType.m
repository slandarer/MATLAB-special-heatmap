%% Set heatmap to upper triangular or lower triangular type

% Set to upper triangle or lower triangle (设置为上三角或下三角)

% Made up some data casually (随便捏造了点数据)
X = randn(20,15) + [(linspace(-1,2.5,20)').*ones(1, 6), (linspace(.5,-.7,20)').*ones(1, 5), (linspace(.9,-.2,20)').*ones(1, 4)];
% Get the correlation matrix (求相关系数矩阵)
Data = corr(X);

figure()
SHM_s1 = SHeatmap(Data, 'Format','donut');
SHM_s1.draw();
SHM_s1.setType('triu0');
% SHM_s1.setText();


names = {'A1','A2','A3','A4','A5','B1','B2','B3','B4','B5','C1','C2','C3','C4','C5'};
SHM_s1.setVarName(names)


% + 'triu'   : upper triangle                  : 上三角部分
% + 'tril'   : lower triangle                  : 下三角部分
% + 'triu0'  : upper triangle without diagonal : 扣除对角线上三角部分
% + 'tril0'  : lower triangle without diagonal : 扣除对角线下三角部分

