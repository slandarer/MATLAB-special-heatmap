%% Circular heatmap



Data = randn(100, 10);


figure()
SHM = SHeatmap(Data, 'Format','sq');
SHM.draw();
SHM.setRowName(compose('row-%d', 1:100))
SHM.setColName(compose(' col-%d', 1:10))
SHM.setRowLabelLocation('right')


SHM.setXYTLim('XLim',[1,2], 'YLim',[0,1], 'TLim',[0, -3*pi/2]);

SHM.setColLabel('Rotation',0, 'HorizontalAlignment','left')
SHM.Colorbar.Position(1) = SHM.Colorbar.Position(1) + .1;
