%% Latest format - c2rect

figure()
Data = rand(12,12) - .5;
SHM = SHeatmap(Data, 'Format','c2rect');
SHM.draw();
SHM.setFrame('Visible','off')


cmap = interp1([0,.5,1], [173,208,53; 255,255,255; 252,137,180]./255, linspace(0,1,32));
colormap(SHM.ax, cmap)