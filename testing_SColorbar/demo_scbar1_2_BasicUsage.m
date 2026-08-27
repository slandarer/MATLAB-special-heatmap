%% Basic usage

addpath('..\')

% Draw heatmap (热图绘制)
Data = rand(12, 12) - .5;
SHM = SHeatmap(Data, 'Format','sqfull');
SHM.ColName = {'X-1','X-2','X-3','X-4','X-5','X-6','X-7','X-8','X-9','X-10','X-11','X-12'};
SHM.RowName = {'Y-1','Y-2','Y-3','Y-4','Y-5','Y-6','Y-7','Y-8','Y-9','Y-10','Y-11','Y-12'};
SHM.draw(); 

colormap(slanCM(97, 16))
SHM.setText()

% Add colorbar1 (添加颜色条1)
scbar1 = SColorbar(gca, 'Location','northeast', 'BasePos', 13, 'TickDir','in');
scbar1.draw()
% Add colorbar2 (添加颜色条2)
scbar2 = SColorbar(gca, 'Location','southeast', 'BasePos', 13, 'TickDir','both', 'CDir','reverse');
scbar2.draw()
% Add colorbar3 (添加颜色条3)
scbar3 = SColorbar(gca, 'Location','east', 'Tick',-.6:.15:.6);
scbar3.draw()
% Add colorbar4 (添加颜色条4)
scbar4 = SColorbar(gca, 'Location','east', 'Tick',[]);
scbar4.draw()
% Add colorbar4 (添加颜色条5)
scbar5 = SColorbar(gca, 'Location','east', 'Width',.1);
scbar5.draw()

SHM.setFrame()