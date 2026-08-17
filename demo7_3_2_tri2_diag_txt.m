%% Merge two triangular heatmaps with diagonal variable names
Data = [1.0,.24,.03,.05,.10,.09,.14,.05,.08; 
        .24,1.0,.25,.26,.25,.26,.28,.25,.27;
        .03,.25,1.0,.05,.10,.10,.15,.05,.09;
        .05,.26,.05,1.0,.13,.11,.17,.06,.12;
        .10,.25,.10,.13,1.0,.14,.19,.10,.13;
        .09,.26,.10,.11,.14,1.0,.14,.11,.10;
        .14,.28,.15,.17,.19,.14,1.0,.15,.16;
        .05,.25,.05,.06,.10,.11,.15,1.0,.10;
        .08,.27,.09,.12,.13,.10,.16,.10,1.0];

% 变量名及 colormap
varName = compose('X%d', 1:9);
CList = [46,18,4; 208,141,104; 255,203,166; 230,192,166; 252,225,214;
         132,17,20; 0,62,135; 117,147,156; 1,54,87; 43,49,30]./255;


figure('Units','normalized', 'Position',[.2,.1,.48,.7])
% 下三角热图，对角线显示变量名
SHM_m1 = SHeatmap(Data, 'Format','text', 'Type','varl', 'VarName',varName);
SHM_m1.draw()
SHM_m1.setFontName('Arial')
SHM_m1.setRowLabel('FontSize',17)
set(SHM_m1.Colorbar, 'Location','southoutside', 'Ticks',-1:.2:1, 'LineWidth',1)
% 上三角热图，隐藏变量名
SHM_m2 = SHeatmap(Data, 'Format','pie', 'Type','triu0', 'ShapeFlipX','on');
SHM_m2.draw()
SHM_m2.setColLabel('Visible','off')
SHM_m2.setRowLabel('Visible','off')
SHM_m2.setFontName('Arial')
set(SHM_m2.Colorbar, 'Ticks',-1:.2:1, 'LineWidth',1)

colormap(CList)
clim([-1, 1])
SHM_m1.setText('FontWeight','bold', 'FontSize',14)
title('Carbon storage', 'FontSize',25, 'FontWeight','bold')