%% Group Sep with group block


% Made up some data casually (随便捏造了点数据)
X1 = randn(20, 25) + [(linspace(-1,2.5,20)').*ones(1, 10), (linspace(.5,-.7,20)').*ones(1, 15)];
X2 = randn(20, 25) + [(linspace(-1,2.5,20)').*ones(1, 15), (linspace(.5,-.7,20)').*ones(1, 10)];
% Get the correlation matrix (求相关系数矩阵)
Data = corr(X1, X2);

% rowName and colName
rowName = compose('exp-%d',1:20);
colName = compose('id-%d', 1:25);
rowGroup = [ones(1, 10), 2.*ones(1, 15)];
colGroup = [ones(1, 15), 2.*ones(1, 10)];
rgnames = {'Group-High','Group-Low'};
cgnames = {'Group-Left','Group-Right'};
colors = [.4,.4,.8; .8,.4,.4];

% create figure (图窗创建)
fig = figure('Units','normalized', 'Position',[.1,.05,.45,.72]);
ax = axes('Parent',fig, 'Position',[.1,.1,.8,.8]);

SClusterBlock(rowGroup, 'Orientation','left', 'Parent',ax, 'Group',rowGroup, ...
    'ColorList', colors, 'BlockProp', {'EdgeColor','none'}, 'Height',.5, 'BasePos', 0).draw(); % Draw the left Block (绘制左侧分组方块)
SClusterBlock(colGroup, 'Orientation','top' , 'Parent',ax, 'Group',colGroup, ...
    'ColorList', colors, 'BlockProp', {'EdgeColor','none'}, 'Height',.5, 'BasePos', 0).draw(); % Draw the top  Block (绘制顶部分组方块)

SHM = SHeatmap(Data, 'Format','sqfull', 'RowGroup',rowGroup, 'ColGroup',colGroup, 'GroupLabelOffset',2);
SHM.draw()
SHM.setFrame()
SHM.setRowName(rowName)
SHM.setColName(colName)
SHM.setColLabel('Rotation', 45)
SHM.setRowLabelLocation('right');
SHM.setRowGroupName(rgnames)
SHM.setColGroupName(cgnames)
SHM.setRowGroupLabelLocation('left')
SHM.setColGroupLabelLocation('top')

axis(ax, 'tight')
clim([-1, 1])
colormap(slanCM(97, 32))