%% Rotated triangular heatmap with Group Block and GroupSep (2 groups)

rng(2)
% Made up some data casually (随便捏造了点数据)
X = randn(20, 12) + [(linspace(-1, 2.5, 20)').*ones(1, 5), ...
                     (linspace(.5, -.7, 20)').*ones(1, 7)];
[Data, pval] = corr(X);
group = [1,1,1,1,1,2,2,2,2,2,2,2];
colors = [.8,0,0; 0,0,.8];
labels = [compose('A-%d', 1:5), compose('B-%d', 1:7)];
gnames = {'A', 'B'};

fig = figure('Units','normalized', 'Position',[.1,.05,.5,.7]);
ax = axes('Parent',fig, 'Position',[.1,.1,.8,.8]);
% Draw group block (绘制分组方块)
SCB_T = SClusterBlock(ax, group, 'Orientation','top', 'Group',group, ...
    'ColorList', [colors(1,:); 1,1,1], 'BlockProp', {'EdgeColor','none'}, 'Height',.25, 'BasePos', .25);
SCB_T.draw(); SCB_T.setXYTLim('TLim', [pi/4, pi/4]);
SCB_R = SClusterBlock(ax, group, 'Orientation','right', 'Group',group, ...
    'ColorList', [1,1,1; colors(2,:)], 'BlockProp', {'EdgeColor','none'}, 'Height',.25, 'BasePos', size(Data, 2) + .75 + (max(group) - 1).*.5);
SCB_R.draw(); SCB_R.setXYTLim('TLim', [pi/4, pi/4]);
% Draw rotated triangular heatmap (绘制旋转三角热图)
SHM = SHeatmap(ax, Data, 'Format','sq', 'VarName',labels, 'RowGroup',group, 'ColGroup',group, ...
    'RowGroupName', gnames, 'ColGroupName',gnames, 'GroupLabelOffset',1.3);
SHM.draw();
SHM.setType('triu').setFrame('LineWidth',2)
SHM.setColTickIndices([]) % Set col-labels and col-ticks ('visible', 'off')
SHM.setRowGroupLabelLocation('right')
SHM.setColGroupLabelLocation('top')
SHM.setText().showStars(pval, 'Levels', [0.05, 0.01, 0.001], 'CorrLabel','off')
SHM.setXYTLim('TLim',[pi/4, pi/4]);
SHM.setRowGroupLabel('FontSize',25, 'Rotation',0)
SHM.setColGroupLabel('FontSize',25, 'Rotation',0)

SHM.Colorbar.Location = 'southoutside';
SHM.ax.YLim(2) = 1.5;

set(SHM.rowGroupLabelHdl(1), 'Visible','off')
set(SHM.colGroupLabelHdl(2), 'Visible','off')