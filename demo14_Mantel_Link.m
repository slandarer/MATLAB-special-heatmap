
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
objHM.setType('tril0');
objHM.setRowLabelLocation('left')
objHM.setColLabelLocation('bottom')
objHM.setRowLabel('Visible','on')
objHM.setColLabel('Visible','on')
delete(objHM.Colorbar)

%% Draw mantel links
objML = SMantelLink(ax, Data1, Data2, 'Group',group);
objML.GroupName = groupName;
objML.LegendLocation = 'west';
objML.Layout = 'triu';
objML.draw()





