%% Merge two triangle heatmaps 

% Made up some data casually (随便捏造了点数据)
X=randn(20,15)+[(linspace(-1,2.5,20)').*ones(1,6),(linspace(.5,-.7,20)').*ones(1,5),(linspace(.9,-.2,20)').*ones(1,4)];
% Get the correlation matrix (求相关系数矩阵)
Data=corr(X);


figure()
SHM_m1=SHeatmap(Data,'Format','sq');
SHM_m1=SHM_m1.draw();
SHM_m1=SHM_m1.setType('tril');
SHM_m1.setColLabel('Visible','off')

SHM_m2=SHeatmap(Data,'Format','hex');
SHM_m2=SHM_m2.draw();
SHM_m2.setType('triu0');
SHM_m2.setRowLabel('Visible','off')
SHM_m2.setColLabel('Visible','on') % Show the hidden Var-1 label (显示隐藏的Var-1标签)

% clim([-1.2,1.2])
% colormap(slanCM(141))

SHM_m1.setText();
% exportgraphics(gca,'gallery\Type_tri2_1.png')
