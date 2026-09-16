% Spread Labels
addpath('..\')


% Made up some data casually (随便捏造了点数据)
X1 = randn(20, 100) + [(linspace(-1,2.5,20)').*ones(1, 30), (linspace(.5,-1,20)').*ones(1, 70)];
X2 = randn(20, 10) + [(linspace(-1,2.5,20)').*ones(1, 5), (linspace(.5,-.7,20)').*ones(1, 5)];
% Get the correlation matrix (求相关系数矩阵)
Data = corr(X1, X2);

% rowName and colName
rowName = compose('virExp-%d',1:100);
colName = compose('id-%d', 1:10);
rowGroup = [ones(1, 30), 2.*ones(1, 70)];
colGroup = [ones(1, 5), 2.*ones(1, 5)];
rgnames = {'Group-High','Group-Low'};
cgnames = {'Group-Left','Group-Right'};
colors = [.4,.4,.8; .8,.4,.4];

% create figure (图窗创建)
fig = figure('Units','normalized', 'Position',[.1,.05,.45,.72]);
ax = axes('Parent',fig, 'Position',[.1,.1,.8,.8]);

SCBL = SClusterBlock(rowGroup, 'Orientation','left', 'Parent',ax, 'Group',rowGroup, 'GroupSep',2.5,...
    'ColorList', colors, 'BlockProp', {'EdgeColor','none'}, 'Height',1.5, 'BasePos', 0);
SCBL.draw(); SCBL.setXYTLim('YLim',[.5, 100.5])
SCBT = SClusterBlock(colGroup, 'Orientation','top' , 'Parent',ax, 'Group',colGroup, 'GroupSep',.5, ...
    'ColorList', colors, 'BlockProp', {'EdgeColor','none'}, 'Height',1.5, 'BasePos', 0);
SCBT.draw(); SCBT.setXYTLim('XLim',[.5, 60.5])

SHM = SHeatmap(Data, 'Format','sqfull', 'RowGroup',rowGroup, 'ColGroup',colGroup, ...
    'GroupSep',[2.5, .5], 'GroupLabelOffset',1, 'TickLength',[0,.1], 'TickLabelOffset',[0,.25]);
SHM.draw()
SHM.setFrame()
SHM.setRowName(rowName)
SHM.setColName(colName)
SHM.setRowLabelLocation('right')
SHM.setRowGroupName(rgnames)
SHM.setColGroupName(cgnames)
SHM.setColGroupLabelLocation('top')
SHM.setXYTLim('XLim', [.5, 60.5], 'YLim',[.5, 100.5]);
colormap(slanCM(97, 32)); clim([-1, 1])

% %% Spread Labels
SHM.setRowTickIndices([1,2,3, 15,16,17,19, 25:30, 80:85,98,100])
spreadLabels(SHM.rowLabelHdl, [70, -20; 70, 100], 'LeaderStyle','segment3', 'UniformWeight',.7)