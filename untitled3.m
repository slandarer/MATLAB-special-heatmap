Data = rand(12, 12);
SHM8 = SHeatmap(Data, 'Format','sq');
SHM8.ColName = {'X-1','X-2','X-3','X-4','X-5','X-6','X-7','X-8','X-9','X-10','X-11','X-12'};
SHM8.RowName = {'Y-1','Y-2','Y-3','Y-4','Y-5','Y-6','Y-7','Y-8','Y-9','Y-10','Y-11','Y-12'};
SHM8.draw(); 
SHM8.setFrame()


