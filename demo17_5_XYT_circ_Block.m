%% Circular heatmap with Group Block

% Circular heatmap is currently supported only for 
% SHeatmap with 'sq' Format and 'full' Type.

rng(1)
Data = randn(50, 10);
rowName = compose('row-%d', 1:50);
colName = compose('col-%d', 1:10);
rowGroup = [ones(1, 5), 2.*ones(1, 30), 3.*ones(1, 15)];
colGroup = [1,1,1,1,1,1,1,2,2,2];
rowColor = [.80,.24,.14; .95,.77,.35; .43,.68,.56];
colColor = [.07,.44,.75; .88,.37,.38];
rgnames = {'Group-R1','Group-R2','Group-R3'};
cgnames = {'Group-C1','Group-C2'};

% create figure (图窗创建)
fig = figure('Units','normalized', 'Position',[.1,.05,.5,.72]);
ax = axes('Parent',fig, 'Position',[.1,.1,.75,.75]);
% Draw group block (绘制分组方块)
SCB_L = SClusterBlock(ax, rowGroup, 'Orientation','left', 'ColorList',rowColor);
SCB_L.draw(); SCB_L.setXYTLim('XLim',[.85,.95], 'YLim',[0, 1], 'TLim',[-3*pi/2, 0]);

SCB_T = SClusterBlock(ax, colGroup, 'Orientation','top' , 'ColorList',colColor);
SCB_T.draw(); SCB_T.setXYTLim('XLim',[1,2], 'YLim',[-.05, -.15])

% Draw circular heatmap (绘制环形热图)
SHM = SHeatmap(ax, Data, 'Format','sq');
SHM.TickLength = .3;
SHM.draw();
SHM.setRowName(rowName)
SHM.setColName(colName)
SHM.setRowLabelLocation('right')
SHM.setColLabelLocation('top')

% YLim(1) -> TLim(1), YLim(2) -> TLim(2)
SHM.setXYTLim('XLim',[1,2], 'YLim',[0, 1], 'TLim',[-3*pi/2, 0]);
SHM.Colorbar.Position(1) = SHM.Colorbar.Position(1) + .1;

legend([SCB_L.blockHdl, SCB_T.blockHdl], [rgnames, cgnames], ...
    'FontSize',15, 'FontName','Times New Roman')
