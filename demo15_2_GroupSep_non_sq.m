%% Group Sep with non-square matrix

figure()
Data = rand(3, 12);
SHM = SHeatmap(Data, 'Format','sq');
SHM.RowName = {'Off-peak', 'Peak', 'Regular'};
SHM.ColName = {'Beijing', 'Shanghai', 'Guangzhou', 'Shenzhen'};
SHM.ColGroup = [1,1,1,1, 2,2,2,2, 3,3,3,3];
SHM.draw().setFrame()

