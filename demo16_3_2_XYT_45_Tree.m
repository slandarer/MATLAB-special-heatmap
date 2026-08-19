%% Triangular heatmap with Rotated dendrogram

rng(2)
% Made up some data casually (随便捏造了点数据)
X = randn(20, 20) + [(linspace(-1, 2.5, 20)').*ones(1, 8), ...
    (linspace(.5, -.7, 20)').*ones(1, 5),...
    (linspace(.9, -.2, 20)').*ones(1, 7)];
Data = corr(X);
labels = compose('Slan-%d', 1:20);

fig = figure('Units','normalized', 'Position',[.1,.05,.5,.8]);
ax = axes('Parent',fig, 'Position',[.1,.1,.8,.8]);


% Draw dendrogram (绘制树状图)
SD = SDendrogram(ax, Data, 'Orientation','top', 'BasePos',.5, 'Height',5);
order = SD.draw();
SD.setXYTLim('XLim',sqrt(2)*[.5, size(Data, 2) + .5], 'YLim', [0, -size(Data, 2)/3], 'TLim', [pi/4, pi/4]);
% Exchange data order (交换数据顺序)
Data = Data(order, order);
SHM = SHeatmap(Data, 'Format','sq', 'VarName',labels(order));
SHM.draw()
SHM.setType('tril0')
SHM.setColLabelLocation('bottom')
SHM.setXYTLim('TLim', [pi/2, pi/2])
SHM.setRowLabel('Rotation',45, 'HorizontalAlignment','right')

SHM.ax.YLim(2) = 1;
SHM.Colorbar.Location = 'southoutside';