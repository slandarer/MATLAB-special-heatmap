% Sector heatmap with marker

Data = rand(16, 8);
rowName = {'SHMS','SHML','SHMA','SHMN','MATSL','MATPY','MATJA','MAR', ...
           'SHMS2','BMH','USUK','RST','SUNS','XINS','HDY','RY'};
colName = {'SHMC-A','SHMC-B','SHMC-C','SHMC-D','SHMC-E','SL-A1','SL-A2','MATSL'};
markers = {'o', 's', '^', 'v', '>', 'diamond', 'pentagram', 'hexagram'};

fig = figure('Units','normalized', 'Position',[.2,.1,.7,.7]);
ax = axes('Parent',fig, 'Position',[.05,.1,.8,.8]);

% Draw sector heatmap (绘制扇形热图)
SHM = SHeatmap(ax, Data, 'Format','sq', 'RowName',rowName, 'ColName',colName, 'TickLength',0).draw();
SHM.setRowLabelLocation('right')
SHM.setText()
SHM.setXYTLim('XLim',[1,2.5], 'YLim',[0,1], 'TLim',[pi/8, 7*pi/8]);

set(SHM.colLabelHdl, 'Visible','off')
setTextPerpRadial(SHM.rowLabelHdl, 'outer')
setTextPerpRadial(SHM.textHdl)

% Draw markers
N = size(Data, 2);
mHdl = gobjects(1, N);
for i = 1:N
    x = cos(7*pi/8).*(1 + (i - .5)/N.*1.5) - .04;
    y = - sin(7*pi/8).*(1 + (i - .5)/N.*1.5) + .08;
    mHdl(i) = scatter(ax, x, y, 150, [0,0,0], 'filled', 'Marker',markers{i});
end

% Draw colorbar and legend
SHM.Colorbar.Location = 'southoutside';
legend(mHdl, colName, 'FontSize',15, 'FontName','Times New Roman', 'Location','northeastoutside')