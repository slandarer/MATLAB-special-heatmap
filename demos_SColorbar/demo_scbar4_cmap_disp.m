% Colormap display
addpath('..\')


fig = figure('Units','normalized', 'Position',[.05,.2,.5,.6]);
ax = axes('Parent',fig, 'Position',[.15,.1,.8,.8], ...
    'YDir','reverse', 'NextPlot','add', 'DataAspectRatio',[1,1,1]);

names = {'viridis','plasma','inferno','magma', 'cividis', 'parula'};
cmaps = {slanCM('viridis', 32), ...
         slanCM('plasma', 32), ...
         slanCM('inferno', 32), ...
         slanCM('magma', 32), ...
         slanCM('cividis', 32), ...
         slanCM('parula', 32)};

N = length(names);
for i = 1:length(names)
    colormap(ax, cmaps{i})
    tscbar = SColorbar(ax, 'Location','south', 'Tick',[]);
    tscbar.draw()
    tscbar.setXYTLim('YLim', [0, .5] + i*1.5, 'XLim',[0,15])
    tscbar.freezeColors

    colormap(ax, rgb2gray(cmaps{i}))
    tscbar = SColorbar(ax, 'Location','south', 'Tick',[]);
    tscbar.draw()
    tscbar.setXYTLim('YLim', [.5, .75] + i*1.5, 'XLim',[0,15])
    tscbar.freezeColors
end
axis off

text(ax, -ones(1, N).*.25, (1:N).*1.5 + .5, names, 'HorizontalAlignment','right', ...
    'FontSize',17, 'FontName','Times New Roman')