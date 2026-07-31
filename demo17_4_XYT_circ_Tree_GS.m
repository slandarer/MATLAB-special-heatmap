%% Circular heatmap with dendrogram and GroupSep

rng(5)
% Made up some data casually (随便捏造了点数据)
X = randn(100, 80) + [(linspace(-1,2.5,100)').*ones(1, 15), (linspace(.5,-.7,100)').*ones(1, 15),...
                      (linspace(.1,-.7,100)').*ones(1, 15), (linspace(.9,-.2,100)').*ones(1, 15),...
                      (linspace(-.1,.7,100)').*ones(1, 10), (linspace(-.9,-.2,100)').*ones(1, 10)];
Y = randn(100, 8) + [(linspace(-1,2.5,100)').*ones(1, 2), (linspace(.5,-.7,100)').*ones(1, 3), (linspace(-1,-2.5,100)').*ones(1, 3)];

Data = corr(X, Y);
rowName = compose('row-%d', 1:80);
colName = compose('col-%d', 1:8);


fig = figure('Units','normalized', 'Position',[.1,.05,.5,.7]);
ax = axes('Parent',fig, 'Position',[.1,.1,.8,.8]);
% Draw dendrogram (绘制树状图)
SD_L = SDendrogram(ax, Data, 'Orientation','left', 'GroupSep',.5, 'MaxClust',4);
[orderL, groupL] = SD_L.draw(); SD_L.setXYTLim('XLim',[0,1], 'TLim',[-3*pi/2,pi/4])
SD_T = SDendrogram(ax, Data, 'Orientation','top' , 'GroupSep',.5, 'MaxClust',2);
[orderT, groupT] = SD_T.draw(); SD_T.setXYTLim('XLim',[1,2], 'YLim',[0,-.3], 'TLim',[pi/4,pi/4])
% Exchange data order (交换数据顺序)
Data = Data(orderL, orderT);
% Draw heatmap (绘制热图)
SHM = SHeatmap(ax, Data, 'Format','sq', 'RowGroup',groupL, 'ColGroup',groupT);
SHM.TickLength = .3;
SHM.draw();
SHM.setRowName(rowName(orderL))
SHM.setColName(colName(orderT))
SHM.setRowLabelLocation('right')
SHM.setColLabelLocation('top')

SHM.setXYTLim('XLim',[1,2], 'YLim',[0, 1], 'TLim',[-3*pi/2,pi/4]);
SHM.Colorbar.Position(1) = SHM.Colorbar.Position(1) + .1;

colormap(slanCM(97, 32))
