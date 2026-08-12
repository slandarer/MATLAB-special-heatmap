%% Text Format (alphabet)

rng(1)
% Made up some data casually (随便捏造了点数据)
X = randn(20, 9) + [(linspace(-1, 2.5, 20)').*ones(1, 5), ...
    (linspace(.5, -.7, 20)').*ones(1, 4)];
% Get the correlation matrix (求相关系数矩阵)
Data = corr(X);

% create figure (图窗创建)
figure('Units','normalized', 'Position',[.1,.05,.45,.72])

% Draw heat map with texts (绘制有文本热图)
SHM = SHeatmap(Data, 'Format','rrect');
SHM.draw()
SHM.setFrame();


clim(SHM.ax, [-1, 1])
colormap(SHM.ax, slanCM(98, 12))

cmp = get(gca, 'Colormap');
climit  = get(gca, 'CLim');
values = linspace(climit(1), climit(2), size(cmp, 1) + 1);
SHM.Colorbar.Ticks = values(2:end)./2 + values(1:end-1)./2;
SHM.Colorbar.TickLabels = compose('%c', (65 + size(cmp, 1) - 1):-1:65);

SHM.setText('FontSize',13)
% Set text format (调整数值文本格式)
SHM.setTextFormat(@(x) txtFunc(x))


function s = txtFunc(x)
cmp = get(gca, 'Colormap');
climit  = get(gca, 'CLim');
values = linspace(climit(1), climit(2), size(cmp, 1) + 1);
names = compose('%c', (65 + size(cmp, 1) - 1):-1:65);
tind = sum(x >= values);
tind(tind <= 0) = 1;
tind(tind > size(cmp, 1)) = size(cmp, 1);
s = names{tind};
end
