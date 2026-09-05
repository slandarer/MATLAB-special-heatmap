% Colormap display
addpath('..\')

% Usage counts for each colormap (每个颜色图对应的使用次数统计)
names = { 'parula', 'turbo', 'hsv', 'hot', 'cool', ...
    'spring', 'summer', 'autumn', 'winter', ...
    'gray', 'bone', 'copper', 'pink'};
values = [134, 87, 120, 65, 78, 32, 67, 12, 8, 60, 120, 61, 12];

% Create figure and axes (图窗及坐标区域创建)
fig = figure('Units','normalized', 'Position',[.05,.2,.6,.5]);
ax = axes('Parent',fig, 'Position',[.1,.15,.8,.7], 'NextPlot','add');

% Loop over each colormap and draw corresponding colorbar (循环绘制颜色条柱状图)
for i = 1:length(names)
    colormap(ax, names{i})
    tscbar = SColorbar(ax, 'Location','east', 'Tick',[], 'CDir','reverse');
    tscbar.draw()
    tscbar.setXYTLim('YLim', [0, values(i)], 'XLim',[i - .25, i + .25])
    tscbar.freezeColors
end

set(ax, 'XLim',[0, length(names)] + .5, 'XTick',1:length(names), 'XTickLabel',names)
set(ax, 'FontSize',14, 'FontName','Times New Roman', 'TickLength',[.002,.002], 'TickDir','out', ...
    'LineWidth',1.5, 'YGrid','on', 'GridLineStyle','--', 'GridAlpha',.1, 'Box','on')
set(ax.YLabel, 'String','Counts', 'FontSize',17) 
set(ax.Title, 'String','Statistics of MATLAB Colorbar Usage Counts', 'FontSize',25) 