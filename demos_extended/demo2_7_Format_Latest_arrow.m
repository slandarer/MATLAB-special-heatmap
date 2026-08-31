%% Latest format - arrow
addpath('..\')

figure()
Data = rand(12,12) - .5;
SHM = SHeatmap(Data, 'Format','arrow');
SHM.draw();
SHM.setFrame('Visible','off')

cmap = interp1([0,.5,1], [0,163,88; 255,255,255; 224,44,71]./255, linspace(0,1,32));
colormap(SHM.ax, cmap)

