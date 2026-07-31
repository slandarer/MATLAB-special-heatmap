%% Circular heatmap with dendrogram and Group Block

rng(5)
% Made up some data casually (随便捏造了点数据)
X = randn(100, 80) + [(linspace(-1,2.5,100)').*ones(1, 15), (linspace(.5,-.7,100)').*ones(1, 15),...
                      (linspace(.1,-.7,100)').*ones(1, 15), (linspace(.9,-.2,100)').*ones(1, 15),...
                      (linspace(-.1,.7,100)').*ones(1, 10), (linspace(-.9,-.2,100)').*ones(1, 10)];
Y = randn(100, 8) + [(linspace(-1,2.5,100)').*ones(1, 2), (linspace(.5,-.7,100)').*ones(1, 3), (linspace(-1,-2.5,100)').*ones(1, 3)];

Data = corr(X, Y);
rowName = compose('row-%d', 1:80);
colName = compose('col-%d', 1:8);
rowColor = [.80,.24,.14; .95,.77,.35; .43,.68,.56; .19,.71,.80];
colColor = [.07,.44,.75; .88,.37,.38];
rgnames = {'Group-R1','Group-R2','Group-R3','Group-R4'};
cgnames = {'Group-C1','Group-C2'};

fig = figure('Units','normalized', 'Position',[.1,.05,.5,.7]);
ax = axes('Parent',fig, 'Position',[.1,.1,.8,.8]);
% Draw dendrogram (绘制树状图)
SD_L = SDendrogram(ax, Data, 'Orientation','left', 'MaxClust',4);
[orderL, groupL] = SD_L.draw(); SD_L.setXYTLim('XLim',[0,.85], 'TLim',[-3*pi/2,0])
SD_T = SDendrogram(ax, Data, 'Orientation','top' , 'MaxClust',2);
[orderT, groupT] = SD_T.draw(); SD_T.setXYTLim('XLim',[1,2], 'YLim',[-.15, -.45], 'TLim',[0,0])
% Draw group block (绘制分组方块)
BlkProp = {'FaceAlpha',.7, 'LineWidth', 1};
SCB_L = SClusterBlock(ax, groupL, 'Orientation','left', 'ColorList',rowColor, 'BlockProp',BlkProp);
SCB_L.draw(); SCB_L.setXYTLim('XLim',[.85,.95], 'YLim',[0, 1], 'TLim',[-3*pi/2,0]);
SCB_T = SClusterBlock(ax, groupT, 'Orientation','top' , 'ColorList',colColor, 'BlockProp',BlkProp);
SCB_T.draw(); SCB_T.setXYTLim('XLim',[1,2], 'YLim',[-.05, -.15], 'TLim',[0,0])

% Exchange data order (交换数据顺序)
Data = Data(orderL, orderT);
% Draw heatmap (绘制热图)
SHM = SHeatmap(Data, 'Format','sq');
SHM.TickLength = .3;
SHM.draw();
SHM.setRowName(rowName(orderL))
SHM.setColName(colName(orderT))
SHM.setRowLabelLocation('right')
SHM.setColLabelLocation('top')

SHM.setXYTLim('XLim',[1,2], 'YLim',[0, 1], 'TLim',[-3*pi/2,0]);
SHM.Colorbar.Position(1) = SHM.Colorbar.Position(1) + .1;

legend([SCB_L.blockHdl, SCB_T.blockHdl], [rgnames, cgnames], ...
    'FontSize',15, 'FontName','Times New Roman')
colormap(slanCM(97, 32))