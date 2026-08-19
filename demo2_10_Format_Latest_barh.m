%% Latest format - barh

rng(1)
Data = randn(50, 3);
rowName = compose('row-%d', 1:50);
colName = compose('col-%d', 1:3);

figure()
SHM = SHeatmap(Data, 'Format','barh', 'TickLabelOffset',.01);
SHM.draw();
SHM.setRowName(rowName)
SHM.setColName(colName)
SHM.setRowLabelLocation('right')
SHM.setColLabelLocation('top')

% YLim(1) -> TLim(1), YLim(2) -> TLim(2)
SHM.setXYTLim('XLim',[1,2.5], 'YLim',[0, 1], 'TLim',[-3*pi/2, 0]);
SHM.Colorbar.Position(1) = SHM.Colorbar.Position(1) + .1;

cmap = interp1([0,.5,1], [227,113,16; 255,255,255; 90,147,225]./255, linspace(0,1,32));
colormap(SHM.ax, cmap)


%% Latest format - bar
figure()
Data = rand(9, 9);
Data(1,1) = 1;
SHM = SHeatmap(Data, 'Format','barh');
SHM.RowGroup = [1,1,2,2,2,2,3,3,3];
SHM.ColGroup = [1,1,2,2,2,2,3,3,3];
SHM.draw()
SHM.setType('tril').setFrame()