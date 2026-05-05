% 合并两个三角热图且使用不同colormap(Merge two triangle heat maps with two colormaps)

% 随便捏造了点数据(Made up some data casually)
X1=randn(20,15)+[(linspace(-1,2.5,20)').*ones(1,6),(linspace(.5,-.7,20)').*ones(1,5),(linspace(.9,-.2,20)').*ones(1,4)];
X2=randn(20,15)+[(linspace(-1,2.5,20)').*ones(1,6),(linspace(.5,-.7,20)').*ones(1,5),(linspace(.9,-.2,20)').*ones(1,4)];
% 求相关系数矩阵(Get the correlation matrix)
Data1=corr(X1);
Data2=corr(X2);


figure()
% 绘制第一个热图并冻结配色
% Draw the first heatmap and freeze colors.
SHM_m1=SHeatmap(Data1,'Format','triul');
SHM_m1=SHM_m1.draw();
SHM_m1=SHM_m1.setType('tril');
SHM_m1.freezeColors() 

SHM_m2=SHeatmap(Data2,'Format','trilr');
SHM_m2=SHM_m2.draw();
SHM_m2=SHM_m2.setType('tril');
colormap(cool(32));
SHM_m2.Colorbar.Position(1) = SHM_m2.Colorbar.Position(1) + .1;


% 为两个 colorbar 添加标签
% Draw label for colorbars
LB1 = SHM_m1.Colorbar.Label;
LB1.String = 'prop 1';
LB1.FontSize = 18;
LB1.Position = [-1.5, 0, 0];
LB2 = SHM_m2.Colorbar.Label;
LB2.String = 'prop 2';
LB2.FontSize = 18;
LB2.Position = [-1.5, 0, 0];

exportgraphics(gcf,'gallery\Type_tri2_colormap2.png')

