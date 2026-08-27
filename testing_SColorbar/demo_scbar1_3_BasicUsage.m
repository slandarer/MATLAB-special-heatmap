%% Basic usage

addpath('..\')

Data = [1.0,.24,.03,.05,.10,.09,.14,.05,.08; 
        .24,1.0,.25,.26,.25,.26,.28,.25,.27;
        .03,.25,1.0,.05,.10,.10,.15,.05,.09;
        .05,.26,.05,1.0,.13,.11,.17,.06,.12;
        .10,.25,.10,.13,1.0,.14,.19,.10,.13;
        .09,.26,.10,.11,.14,1.0,.14,.11,.10;
        .14,.28,.15,.17,.19,.14,1.0,.15,.16;
        .05,.25,.05,.06,.10,.11,.15,1.0,.10;
        .08,.27,.09,.12,.13,.10,.16,.10,1.0];

% Variable names and colormap (变量名及 colormap)
varName = compose('X%d', 1:9);
CList = [46,18,4; 208,141,104; 255,203,166; 230,192,166; 252,225,214;
    132,17,20; 0,62,135; 117,147,156; 1,54,87; 43,49,30]./255;


figure('Units','normalized', 'Position',[.2,.1,.48,.7])
% Lower-triangular heatmap with variable names on diagonal (下三角热图对角线显示变量名)
SHM1 = SHeatmap(Data, 'Format','text', 'Type','varl', 'VarName',varName);
SHM1.draw()
SHM1.setFontName('Arial')
SHM1.setRowLabel('FontSize',17)
% Upper-triangular heatmap with variable names hidden (上三角热图隐藏变量名)
SHM2 = SHeatmap(Data, 'Format','pie', 'Type','triu0', 'ShapeFlipX','on');
SHM2.draw()
SHM2.setColLabel('Visible','off')
SHM2.setRowLabel('Visible','off')
SHM2.setFontName('Arial')

colormap(CList)
clim([-1, 1])
SHM1.setText('FontWeight','bold', 'FontSize',14)
title('Carbon storage', 'FontSize',25, 'FontWeight','bold')

N = size(Data, 1);
% Add colorbar1 (添加颜色条1)
scbar1 = SColorbar(gca, 'Location','east', 'TickLength',.4, 'TickDir','in');
scbar1.draw()
scbar1.setXYTLim('XLim', N + .75 + [0, .4], 'YLim', [0, N] + .5)
scbar1.setTickLabel('FontSize',12, 'FontName','Arial')

% Add colorbar2 (添加颜色条2)
scbar2 = SColorbar(gca, 'Location','south', 'TickLength',.4, 'TickDir','in');
scbar2.draw()
scbar2.setXYTLim('YLim', N + .75 + [0, .4], 'XLim', [0, N] + .5)
scbar2.setTickLabel('FontSize',12, 'FontName','Arial')