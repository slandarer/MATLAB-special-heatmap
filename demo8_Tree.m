%% Heatmap with dendrogram
% 带树状图热图

% Made up some data casually (随便捏造了点数据)
X1 = randn(20,20) + [(linspace(-1,2.5,20)').*ones(1,8),(linspace(.5,-.7,20)').*ones(1,5),(linspace(.9,-.2,20)').*ones(1,7)];
X2 = randn(20,25) + [(linspace(-1,2.5,20)').*ones(1,10),(linspace(.5,-.7,20)').*ones(1,8),(linspace(.9,-.2,20)').*ones(1,7)];
% Get the correlation matrix (求相关系数矩阵)
Data=corr(X1,X2);
% rowName and colName
rowName={'FREM2','ALDH9A1','RBL1','AP2A2','HNRNPK','ATP1A1','ARPC3','SMG5','RPS27A',...
          'RAB8A','SPARC','DDX3X','EEF1D','EEF1B2','RPS11','RPL13','RPL34','GCN1','FGG','CCT3'};
colName={'A1','A2','A3','A4','A5','A6','A7','A8','A9','A10','B11','B12','B13',...
         'B14','B15','B16','B17','B18','C19','C20','C21','C22','C23','C24','C25'};

% create figure (图窗创建)
fig=figure('Position',[100,100,870,720]);

% Adjust the position of the main coordinate area 
% and place the Y axis to the right (调整主坐标区域位置并将Y轴置于右侧)
axMain=axes('Parent',fig);
axMain.Position=[.18,.07,.62,.77];
P=axMain.Position;
axMain.YAxisLocation='right';

% Draw the left dendrogram (绘制左侧树状图)
axTreeL=axes('Parent',fig);
axTreeL.Position=[P(1)-P(3)/5,P(2),P(3)/5,P(4)];
orderL=SDendrogram(Data,'Orientation','left','Parent',axTreeL);

% Draw the top dendrogram (绘制顶部树状图)
axTreeT=axes('Parent',fig);
axTreeT.Position=[P(1),P(2)+P(4),P(3),P(4)/5];
orderT=SDendrogram(Data,'Orientation','top','Parent',axTreeT);

% Exchange data order (交换数据顺序)
Data=Data(orderL,:);
Data=Data(:,orderT);

% Draw Heatmap (绘制热图)
SHM_t1=SHeatmap(Data,'Format','sq','Parent',axMain);
SHM_t1=SHM_t1.draw();
axMain.DataAspectRatioMode='auto';
axMain.XTickLabel=colName(orderT);
axMain.YTickLabel=rowName(orderL);
CB=colorbar(axMain);
CB.Position=[P(1)+P(3)*1.15,P(2)+P(4)/2,P(3)/25,P(4)/2];
% exportgraphics(gcf,'gallery\Tree.png')
