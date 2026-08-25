%% Basic usage

addpath('..\')

% Draw heatmap (热图绘制)
Data = rand(12, 12) - .5;
SHM = SHeatmap(Data, 'Format','sqfull');
SHM.ColName = {'X-1','X-2','X-3','X-4','X-5','X-6','X-7','X-8','X-9','X-10','X-11','X-12'};
SHM.RowName = {'Y-1','Y-2','Y-3','Y-4','Y-5','Y-6','Y-7','Y-8','Y-9','Y-10','Y-11','Y-12'};
SHM.draw(); 
SHM.setText()

% Add colorbar1 (添加颜色条1)
scbar1 = SColorbar(gca, 'Location','east');
scbar1.draw()
% Add colorbar2 (添加颜色条2)
scbar2 = SColorbar(gca, 'Location','east');
scbar2.draw()
% Add colorbar3 (添加颜色条3)
scbar3 = SColorbar(gca, 'Location','east');
scbar3.draw()

SHM.setFrame()
