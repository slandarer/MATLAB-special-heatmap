%% Latest format - moon


X = randn(20, 15) + [(linspace(-1,2.5,20)').*ones(1, 6), (linspace(.5,-.7,20)').*ones(1, 5), (linspace(.9,-.2,20)').*ones(1, 4)];
Data = corr(X);

figure()
SHM = SHeatmap(Data, 'Format','moon'); % also try 'teardrop'
SHM.RowGroup = [1,1,1,1,1,1, 2,2,2,2,2, 3,3,3,3];
SHM.ColGroup = [1,1,1,1,1,1, 2,2,2,2,2, 3,3,3,3];
SHM.draw();


SHM.setType('tril')
SHM.setFrame()

cmap = interp1([0,.5,1], [227,113,16; 255,255,255; 90,147,225]./255, linspace(0,1,32));
colormap(SHM.ax, cmap)