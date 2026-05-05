% 合并两个三角热图(Merge two triangle heat maps)

% 随便捏造了点数据(Made up some data casually)
X=randn(20,15)+[(linspace(-1,2.5,20)').*ones(1,6),(linspace(.5,-.7,20)').*ones(1,5),(linspace(.9,-.2,20)').*ones(1,4)];
% 求相关系数矩阵(Get the correlation matrix)
Data=corr(X);


figure()
SHM_m1=SHeatmap(Data,'Format','sq');
SHM_m1=SHM_m1.draw();
SHM_m1=SHM_m1.setType('tril');  % 这个等号因为要增添文字很必要(This equal sign is necessary for adding text)
SHM_m1.setColLabel('Visible','off')

SHM_m2=SHeatmap(Data,'Format','hex');
SHM_m2=SHM_m2.draw();
SHM_m2.setType('triu0');
SHM_m2.setRowLabel('Visible','off')
SHM_m2.setColLabel('Visible','on') % 显示隐藏的Var-1标签(Show the hidden Var-1 label)

% clim([-1.2,1.2])
% colormap(slanCM(141))

SHM_m1.setText();
% exportgraphics(gca,'gallery\Type_tri2_1.png')
