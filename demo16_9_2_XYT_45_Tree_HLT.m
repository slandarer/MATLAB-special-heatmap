% Rotated triangular heatmap (tril) with dendrogram and highlight

rng(2)
% Made up some data casually (随便捏造了点数据)
X = randn(20, 30) + [(linspace(-1, 2.5, 20)').*ones(1, 8), ...
                     (linspace(.5, -.7, 20)').*ones(1, 5),...
                     (linspace(.9, -.2, 20)').*ones(1, 7),...
                     (linspace(-3, 1, 20)').*ones(1, 10)];
Data = corr(X);
labels = compose('Slan-%d', 1:30);

fig = figure('Units','normalized', 'Position',[.1,.05,.5,.7]);
ax = axes('Parent',fig, 'Position',[.1,.1,.8,.8]);
% Draw dendrogram (绘制树状图)
SD = SDendrogram(ax, Data, 'Orientation','top', 'BasePos',0, 'Height',5.5);
set(SD, 'BranchColor','on', 'BranchHighlight','on', 'GroupHighlight','on' ,'HeightRatio',[0, .15, .15, 1])
order = SD.draw();
SD.setXYTLim('XLim', sqrt(2)*[.5, size(Data, 2) + .5]);
% Exchange data order (交换数据顺序)
Data = Data(order, order);
SHM = SHeatmap(Data, 'Format','sq', 'VarName',labels(order));
SHM.draw()
SHM.setType('tril')
SHM.setColLabelLocation('bottom')
SHM.setFrame('LineJoin','chamfer')
SHM.setXYTLim('TLim', [pi/4, pi/4])



SHM.frameHdl.YData(SHM.frameHdl.YData < 0) = 0;
for i = 1:size(Data, 2)
    SHM.patchHdl(i, i).YData(2) = 0;
end
SHM.Colorbar.Position(4) = SHM.Colorbar.Position(4)/3;