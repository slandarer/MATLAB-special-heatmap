%% Basic usage - arrow colorbar
addpath('..\')

% Draw heatmap (热图绘制)
Data = rand(12, 12) - .5;
SHM = SHeatmap(Data, 'Format','sqfull');
SHM.ColName = {'X-1','X-2','X-3','X-4','X-5','X-6','X-7','X-8','X-9','X-10','X-11','X-12'};
SHM.RowName = {'Y-1','Y-2','Y-3','Y-4','Y-5','Y-6','Y-7','Y-8','Y-9','Y-10','Y-11','Y-12'};
SHM.draw(); 
SHM.setText()

% Add colorbar1 (添加颜色条1)
scbar1 = SColorbar(gca, 'Location','east', 'ArrowType','low');
scbar1.draw()
% Add colorbar2 (添加颜色条2)
scbar2 = SColorbar(gca, 'Location','east', 'ArrowType','high');
scbar2.draw()
% Add colorbar3 (添加颜色条3)
scbar3 = SColorbar(gca, 'Location','east', 'ArrowType','both');
scbar3.draw()


% % Add colorbar4 (添加颜色条4)
% scbar4 = SColorbar(gca, 'Location','north', 'ArrowType','low');
% scbar4.draw()
% scbar4.setXYTLim('XLim',[.5, 12.5])
% % Add colorbar5 (添加颜色条5)
% scbar5 = SColorbar(gca, 'Location','north', 'ArrowType','high');
% scbar5.draw()
% scbar5.setXYTLim('XLim',[.5, 12.5])
% % Add colorbar6 (添加颜色条6)
% scbar6 = SColorbar(gca, 'Location','north', 'ArrowType','both');
% scbar6.draw()
% scbar6.setXYTLim('XLim',[.5, 12.5])


SHM.setFrame()
