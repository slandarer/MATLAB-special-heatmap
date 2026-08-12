%% Block for txt

rowName = {'Cod','Flounder','Haddock','Sea Bass', ...
           'Mackerel','Swordfish','Yellowtail','Salmon','Tuna',...
           'Halibut','Flounder','Plaice', ...
           'Mahi-mahi','Marlin'};
rowGroup = [1,1,1,1, 2,2,2,2,2, 3,3,3, 4,4];
colName = {'SUNSSX','LUUZX','MZM','SMYFRY','YGTD'};

Data = randi([0, 100], [14, 5]);

figure(); ax = gca;

CList = [204,  61,  36; 243, 197,  88; 109, 174, 144; 48, 180, 204;   0,  79, 122]./255;

% 绘制左侧分组色块 (半透明背景，无边框)
% Draw left-side group block (semi-transparent, no edge)
SClusterBlock(ax, rowGroup, 'ColorList',CList , 'Orientation','left', 'BasePos',.5, ...
    'Height',4, 'BlockProp', {'EdgeColor','none', 'FaceAlpha',.2}).draw();

SHM = SHeatmap(Data, 'Format','sq', 'RowName',rowName, 'ColName',colName, 'TickLength',0);
SHM.draw();
SHM.setFrame()

% 将行标签颜色设为对应分组颜色并加粗
% Set row label colors to match group colors and make them bold
for i = 1:length(rowGroup)
    SHM.rowLabelHdl(i).Color = CList(rowGroup(i), :);
    SHM.rowLabelHdl(i).FontWeight = 'bold';
end

colormap(slanCM(21, 32))
axis(ax, 'tight')