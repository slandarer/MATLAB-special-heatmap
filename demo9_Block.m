%% Group block 

% Made up some data casually (随便捏造了点数据)
rowGroup = [1,1,1,1,1,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4];
colGroup = [1,1,1,1,2,1,2,2,2,2,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5];
rowName = compose('row-%d', 1:20);
colName = compose('col-%d', 1:25);
Data = rand(20, 25);

% create figure (图窗创建)
fig = figure('Units','normalized', 'Position',[.1,.05,.45,.72]);
ax = axes('Parent',fig, 'Position',[.1,.15,.75,.75]);

SClusterBlock(rowGroup, 'Orientation','left', 'Parent',ax).draw(); % Draw the left Block (绘制左侧分组方块)
SClusterBlock(colGroup, 'Orientation','top' , 'Parent',ax).draw(); % Draw the top  Block (绘制顶部分组方块)
% Draw heatmap (绘制热图)
SHM_b1 = SHeatmap(Data, 'Format','sq', 'Parent',ax).draw();
SHM_b1.setRowLabelLocation('right').setColName(colName)
SHM_b1.setColLabelLocation('bottom').setRowName(rowName)
SHM_b1.setColLabel('Rotation',45).setFrame()

colorbar(ax, 'off');
clim(ax, [-.2, 1])
axis(ax, 'tight')
ax.DataAspectRatioMode = 'auto';


