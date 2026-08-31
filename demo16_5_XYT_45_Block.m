%% Rotated triangular heatmap with Group Block

rng(2)
% Made up some data casually (随便捏造了点数据)
X = randn(20, 12) + [(linspace(-1, 2.5, 20)').*ones(1, 5), ...
                     (linspace(.5, -.7, 20)').*ones(1, 3),...
                     (linspace(.9, -.2, 20)').*ones(1, 4)];
[Data, pval] = corr(X);
group = [1,1,1,1,1,2,2,2,3,3,3,3];
labels = compose('Slan-%d', 1:12);
gnames = {'Group-A', 'Group-B', 'Group-C'};

fig = figure('Units','normalized', 'Position',[.1,.05,.5,.7]);
ax = axes('Parent',fig, 'Position',[.1,.1,.8,.8]);
% Draw group block (绘制分组方块)
SCB = SClusterBlock(ax, group, 'Orientation','top');
SCB.draw();
SCB.setXYTLim('TLim', [pi/4, pi/4]);
% Draw rotated triangular heatmap (绘制旋转三角热图)
SHM = SHeatmap(ax, Data, 'Format','sq', 'VarName',labels);
SHM.draw();
SHM.setType('triu');
SHM.setText().showStars(pval, 'Levels', [0.05, 0.01, 0.001], 'CorrLabel','off')
SHM.setRowLabelLocation('right')
SHM.setColTickIndices([])
SHM.setXYTLim('TLim',[pi/4, pi/4]);

SHM.Colorbar.Location = 'southoutside';
legend(SCB.blockHdl, gnames, 'FontSize',15, 'FontName','Times New Roman')

