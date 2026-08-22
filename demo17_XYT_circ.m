%% Circular heatmap

% Circular heatmap is currently supported only for 
% SHeatmap with 'sq'/'sqfull'/'barh' Format and 'full' Type.

rng(1)
Data = randn(50, 10);
rowName = compose('row-%d', 1:50);
colName = compose('col-%d', 1:10);

figure()
SHM = SHeatmap(Data, 'Format','sq');
SHM.TickLength = .3;
SHM.draw();
SHM.setRowName(rowName)
SHM.setColName(colName)
SHM.setRowLabelLocation('right')
SHM.setColLabelLocation('top')

% YLim(1) -> TLim(1), YLim(2) -> TLim(2)
SHM.setXYTLim('XLim',[1,2.5], 'YLim',[0, 1], 'TLim',[-3*pi/2, 0]);
SHM.Colorbar.Position(1) = SHM.Colorbar.Position(1) + .1;

