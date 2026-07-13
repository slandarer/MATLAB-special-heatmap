%% Text Format
% 数值文本格式

% Made up some data casually (随便捏造了点数据)
X = randn(20, 15) + [(linspace(-1, 2.5, 20)').*ones(1, 6), ...
                     (linspace(.5, -.7, 20)').*ones(1, 5), ...
                     (linspace(.9, -.2, 20)').*ones(1, 4)];
% Get the correlation matrix (求相关系数矩阵)
Data = corr(X);

% create figure (图窗创建)
figure('Units','normalized', 'Position',[.1,.05,.45,.72])

% Draw heat map with texts (绘制有文本热图)
SHM12 = SHeatmap(Data, 'Format','circ').draw().setText();

% Set text format (调整数值文本格式)
SHM12.setTextFormat(@(x) sprintf('%0.1f', x))
% exportgraphics(gca, ['gallery\Text_Format_', '0.1f', '.png'])

% SHM12.setTextFormat(@(x)sprintf('%0.1fS', x))
% exportgraphics(gca, ['gallery\Text_Format_', '0.1fS', '.png'])
% SHM12.setTextFormat(@(x)sprintf('%0.1e', x))
% exportgraphics(gca, ['gallery\Text_Format_', '0.1e', '.png'])
