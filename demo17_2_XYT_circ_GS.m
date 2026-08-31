%% Circular heatmap with GroupSep

% Circular heatmap is currently supported only for 
% SHeatmap with 'sq'/'sqfull'/'barh' Format and 'full' Type.

rng(1)
Data = randn(50, 10);
rowName = compose('row-%d', 1:50);
colName = compose('col-%d', 1:10);

figure()
SHM = SHeatmap(Data, 'Format','sqfull');
SHM.TickLength = .3;
SHM.RowGroup = [ones(1, 5), 2.*ones(1, 30), 3.*ones(1, 15)];
SHM.ColGroup = [1,1,1,1,1,1,1,2,2,2];
SHM.draw();

SHM.setRowName(rowName)
SHM.setColName(colName)
SHM.setRowLabelLocation('right')
SHM.setColLabelLocation('top')

% YLim(1) -> TLim(1), YLim(2) -> TLim(2)
SHM.setXYTLim('XLim',[1,2.5], 'YLim',[0, 1], 'TLim',[-3*pi/2, 0]);
SHM.Colorbar.Position(1) = SHM.Colorbar.Position(1) + .1;

