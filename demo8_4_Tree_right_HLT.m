%% Heatmap with highlighted dendrogram (right)

rng(1)
% Made up some data casually (随便捏造了点数据)
X1 = randn(20, 20) + [(linspace(-1,2.5,20)').*ones(1,  8), (linspace(.5,-.7,20)').*ones(1, 5), (linspace(.9,-.2,20)').*ones(1, 7)];
X2 = randn(20, 25) + [(linspace(-1,2.5,20)').*ones(1, 10), (linspace(.5,-.7,20)').*ones(1, 8), (linspace(.9,-.2,20)').*ones(1, 7)];
% Get the correlation matrix (求相关系数矩阵)
Data = corr(X1, X2);
% rowName and colName
rowName = {'FREM2','ALDH9A1','RBL1','AP2A2','HNRNPK','ATP1A1','ARPC3','SMG5','RPS27A',...
    'RAB8A','SPARC','DDX3X','EEF1D','EEF1B2','RPS11','RPL13','RPL34','GCN1','FGG','CCT3'};
colName = {'A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','B11','B12','B13',...
    'B14','B15','B16','B17','B18','C19','C20','C21','C22','C23','C24','C25'};

fig = figure('Units','normalized', 'Position',[.1,.05,.5,.7]);
ax = axes('Parent',fig, 'Position',[.12,.08,.76,.9]);
% Draw the left dendrogram (绘制左侧树状图)
objL = SDendrogram(Data, 'Orientation','right', 'Parent',ax, 'BasePos',size(Data, 2) + .5, 'Height',6);  
set(objL, 'BranchColor','on', 'BranchHighlight','on', 'GroupHighlight','on' ,'HeightRatio',[0, .15, .15, 1])
orderL = objL.draw();
% Draw the top  dendrogram (绘制顶部树状图)
objT = SDendrogram(Data, 'Orientation','top' , 'Parent',ax, 'BasePos',.5, 'Height',5);  
set(objT, 'BranchColor','on', 'BranchHighlight','on', 'GroupHighlight','on', 'HeightRatio',[0, .15, .15, 1])
orderT = objT.draw();
% Exchange data order (交换数据顺序)
Data = Data(orderL, orderT);
% Draw heatmap (绘制热图)
SHM = SHeatmap(Data, 'Format','sq', 'Parent',ax).draw();
SHM.setRowLabelLocation('left').setColName(colName(orderT))
SHM.setColLabelLocation('bottom').setRowName(rowName(orderL))
SHM.setColLabel('Rotation',45).setFrame()
% Draw colorbar (绘制颜色条)
axis(ax, 'tight')
ax.DataAspectRatioMode = 'auto';
yn = size(Data, 1); yh = .9.*yn./(yn + 5) + .08;
SHM.Colorbar.Position = [.89, yh - .36, .025, .36];
