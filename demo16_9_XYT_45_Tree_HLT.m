%% Rotated triangular heatmap with dendrogram and highlight

rng(1)
% Made up some data casually (随便捏造了点数据)
X = randn(20, 20) + [(linspace(-1, 2.5, 20)').*ones(1, 8), ...
                     (linspace(.5, -.7, 20)').*ones(1, 5),...
                     (linspace(.9, -.2, 20)').*ones(1, 7)];
Data = corr(X);
labels = compose('Slan-%d', 1:20);


fig = figure('Units','normalized', 'Position',[.1,.05,.5,.7]);
ax = axes('Parent',fig, 'Position',[.1,.1,.8,.8]);
% Draw dendrogram (绘制树状图)
SD = SDendrogram(ax, Data, 'Orientation','top', 'BasePos',0, 'Height',5.5);
set(SD, 'BranchColor','on', 'BranchHighlight','on', 'GroupHighlight','on' ,'HeightRatio',[0, .15, .15, 1])
order = SD.draw();
SD.setXYTLim('TLim', [pi/4, pi/4]);
% Exchange data order (交换数据顺序)
Data = Data(order, order);
% Draw rotated triangular heatmap (绘制旋转三角热图)
SHM = SHeatmap(ax, Data, 'Format','sq', 'VarName',labels(order));
SHM.draw();
SHM.setType('triu');
SHM.setRowLabelLocation('right')
SHM.setColTickIndices([])
SHM.setXYTLim('TLim',[pi/4, pi/4]);

SHM.Colorbar.Location = 'southoutside';


