%% Load data
load('lichenData.mat')
Data1 = varechem.Variables;
Data2 = varespec.Variables;
labels = varechem.Properties.VariableNames;

groupName = {'Spec01', 'Spec02', 'Spec03', 'Spec04'};
group = zeros(1, size(Data2, 2));
group(1:7) = 1; 
group(8:18) = 2;
group(19:37) = 3;
group(38:44) = 4;

%% Draw heatmap
fig = figure('Units','normalized', 'Position',[.05,.15,.72,.72]); 
ax = axes('Parent',fig, 'Position',[.06,.05,.88,.9]); 
[rho, pval] = corr(Data1);
objHM = SHeatmap(ax, rho, 'Format','sq');
objHM.draw();

objHM.setText()
objHM.showStars(pval, 'Levels', [0.05, 0.01, 0.001], 'CorrLabel','off')
objHM.setVarName(labels)
objHM.setType('triu0');
objHM.setRowLabelLocation('right')
objHM.setColLabelLocation('top')
objHM.setRowLabel('Visible','on')
objHM.setColLabel('Visible','on')
delete(objHM.Colorbar)


colormap(slanCM(102, 25))
set([objHM.rowLabelHdl, objHM.colLabelHdl], 'FontSize',14, 'FontName','Helvetica')


%% Draw mantel links
objML = SMantelLink(ax, Data1, Data2, 'Group',group);
objML.GroupName = groupName;
objML.Layout = 'tril';
objML.PColor = [0,64,115; 79,148,204; 224,224,224]./255;
objML.NodeColor1 = [184,207,248]./255;
objML.NodeColor2 = [184,207,248]./255;
objML.draw()


set(objML.legendTitleHdl, 'FontName','Helvetica')
set(objML.legendTickLabelHdl, 'FontSize',13, 'FontName','Helvetica')
set(objML.groupLabelHdl, 'FontSize',14, 'FontName','Helvetica')