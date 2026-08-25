%% Heatmap with Mantel test links - tril layout

rng(7)
%% Load data
load('.\data_example\lichenData.mat')
Data1 = varechem.Variables;
Data2 = varespec.Variables;
labels = varechem.Properties.VariableNames;

groupName = {'Spec01', 'Spec02', 'Spec03', 'Spec04'};
group = zeros(1, size(Data2, 2));
group(1:7) = 1; 
group(8:18) = 2;
group(19:37) = 3;
group(38:44) = 4;

%% Figure and axes
fig = figure('Units','normalized', 'Position',[.05,.15,.72,.72]); 
ax = axes('Parent',fig, 'Position',[.06,.05,.88,.9]); 

%% Draw heatmap
[rho, pval] = corr(Data1);
objHM = SHeatmap(ax, rho, 'Format','sq').draw().setVarName(labels).setType('linku');
objHM.setText().showStars(pval, 'Levels',[0.05, 0.01, 0.001], 'CorrLabel','off')

% Apply a custom colormap with 25 colors (应用自定义 25 色 colormap)
colormap(slanCM(102, 25))
% Adjust font properties for labels (调整标签字体)
set([objHM.rowLabelHdl, objHM.colLabelHdl], 'FontSize',14, 'FontName','Helvetica')


%% Draw mantel links
objML = SMantelLink(ax, Data1, Data2, 'Group',group);
objML.GroupName = groupName;
objML.Layout = 'tril';
% Customize colors (自定义颜色)
objML.PColor = [0,64,115; 79,148,204; 224,224,224]./255;
objML.NodeColor1 = [184,207,248]./255;
objML.NodeColor2 = [184,207,248]./255;
objML.draw()

% Adjust legend and group label fonts (调整图例和组标签字体)
set(objML.legendTitleHdl, 'FontName','Helvetica')
set(objML.legendTickLabelHdl, 'FontSize',13, 'FontName','Helvetica')
set(objML.groupLabelHdl, 'FontSize',14, 'FontName','Helvetica')