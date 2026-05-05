figure()

tiledlayout(2,2)

nexttile
Data=rand(5,5);
Data(randi([1,25], [2,1])) = nan;
SHM1=SHeatmap(Data,'Format','sq');
SHM1=SHM1.draw();


nexttile
Data=rand(5,5);
Data(randi([1,25], [2,1])) = nan;
SHM2=SHeatmap(Data,'Format','sq');
SHM2=SHM2.draw();


nexttile
Data=rand(5,5);
Data(randi([1,25], [2,1])) = nan;
SHM3=SHeatmap(Data,'Format','sq');
SHM3=SHM3.draw();


nexttile
Data=rand(5,5);
Data(randi([1,25], [2,1])) = nan;
SHM4=SHeatmap(Data,'Format','sq');
SHM4=SHM4.draw();