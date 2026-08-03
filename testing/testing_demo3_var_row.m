% Variable row chart

% Inspired by : https://www.mathworks.com/matlabcentral/fileexchange/71922-hcp-heatmapcovariateplot
%               https://bitbucket.org/manuela_s/hcp/src/master/


% Load random statistical data (sex, age, blood type, height, weight, etc.)
% 加载随机统计数据 (包含性别、年龄、血型、身高体重等变量)
T = load('randStatData.mat');
T = T.T;

% Create figure and axes (创建图窗及坐标区域)
fig = figure('Units','normalized', 'Position',[.1,.1,.75,.8]);
ax = axes('Parent',fig, 'Position',[.1,.1,.8,.8]);

% Create SVarRowChart object (创建变量行图表对象)
SVR = SVarRowChart(ax, 'LeftWidth',20, 'RightWidth',20, 'ColSep',3, 'RowHeight',.6);
SVR.FontProp = {'FontSize',14, 'FontName','Arial'};

SVR.addRow(T.Age, 'Title','Age')
SVR.addRow(T.Sex, 'Title','Sex', 'ColorList',[107,174,214; 250,159,181]./255, 'IconColNum',4)

% If a categorical row does not specify 'ColorList', it inherits the last custom ColorList.
% 若新增行未设置 'ColorList', 则会自动使用最近一次自定义的 ColorList 配色。
SVR.addRow(T.BloodType, 'Title','Blood Type', 'Label',{'A','B','AB','O'}, ...
    'ColorList',[204, 61, 36; 243,197, 88; 109,174,144;  48,180,204]./255)
SVR.addRow(T.Education, 'Title','Education', 'Label',{'High School', 'Bachelor', 'Master', 'PhD'})

SVR.addRow(T.Height_Inch, 'Title','Height', 'Unit','Inch', 'CLim',[55, 75], 'ColorList',slanCM(24, 32))
SVR.addRow(T.Weight_Lbs, 'Title','Weight', 'Unit','Lbs', 'CLim',[105, 275])
SVR.addRow(T.BMI, 'Title','BMI')

SVR.addRow(T.Waist, 'Title','Waist', 'Unit','Inch', 'CLim',[26, 52], 'ColorList',slanCM(9, 32)) 
SVR.addRow(T.Hip, 'Title','Hip', 'Unit','Inch', 'CLim',[32, 54])
SVR.addRow(T.BodyFat, 'Title','Body Fat', 'Unit','%', 'CLim',[12, 45])

SVR.addRow(T.Test_A, 'Title','Test-A', 'Label',{'-','0','+'}, ...
    'ColorList',[244,109, 67; 254,224,144; 116,173,209]./255, 'IconColNum',4)
SVR.addRow(T.Test_B, 'Title','Test-B', 'Label',{'-','0','+'}, 'IconColNum',4)
SVR.addRow(T.Test_C, 'Title','Test-C', 'Label',{'-','0','+'}, 'IconColNum',4)
SVR.addRow(T.Test_D, 'Title','Test-D', 'Label',{'-','0','+'}, 'IconColNum',4)
SVR.addRow(T.Test_E, 'Title','Test-E', 'Label',{'-','0','+'}, 'IconColNum',4)


addpath('..')
rng(1)
X1 = randn(20, 20) + [(linspace(-1,2.5,20)').*ones(1, 4), (linspace(.5,-.7,20)').*ones(1, 4), (linspace(.9,-.2,20)').*ones(1, 12)];
X2 = randn(20, 60) + [(linspace(-1,2.5,20)').*ones(1, 20), (linspace(.5,-.7,20)').*ones(1, 20), (linspace(.9,-.2,20)').*ones(1, 20)];

N = 3;
% Get the correlation matrix (求相关系数矩阵)
Data = corr(X1, X2);
rowName = compose('Var-%d', 1:20);

% Draw the right dendrogram (绘制右侧树状图)
SD_R = SDendrogram(ax, Data, 'Orientation','right', 'MaxClust',3, 'GroupSep',5/6);  
[orderR, groupR] = SD_R.draw();
SD_R.setXYTLim('XLim',21.6 + [0,4], 'YLim',17.5 + [0,size(Data,1).*.6 + (N - 1)*.5])
% Exchange data order (交换数据顺序)
Data = Data(orderR, :);
% Draw the left Block (绘制右侧分组方块)
CList = [244,109, 67; 254,224,144; 116,173,209]./255;
SCB_R = SClusterBlock(ax, groupR, 'ColorList',CList ,'Orientation','right', 'Group',groupR);
SCB_R.draw();
SCB_R.setXYTLim('XLim',20.5 + [0,.6], 'YLim',17.5 + [0,size(Data,1).*.6 + (N - 1)*.5])
% Draw heatmap (绘制热图)
SHM = SHeatmap(Data, 'RowName',rowName(orderR), 'TickLength',0, 'RowGroup',groupR, 'GroupSep',5/6).draw();
SHM.setType('row').setFrame()
SHM.setXYTLim('XLim',[0,20], 'YLim',17.5 + [0,size(Data,1).*.6 + (N - 1)*.5])

set(SHM.rowLabelHdl, 'FontName','Arial', 'FontSize',13)
colormap(slanCM(97, 32))

xl = ax.XLim; xp = [.1,.8];
yl = ax.YLim; yp = [.1,.8];
SHM.Colorbar.Position(1) = xp(1) + (26.1 - xl(1)).*xp(2)./(xl(2) - xl(1));
SHM.Colorbar.Position(2) = yp(1);
SHM.Colorbar.Position(3) = .6.*xp(2)./(xl(2) - xl(1));
SHM.Colorbar.Position(4) = (size(Data,1).*.6 + (N - 1)*.5).*yp(2)./(yl(2) - yl(1));
SHM.Colorbar.FontName = 'Arial';
SHM.Colorbar.TickLength = .02;
SHM.Colorbar.FontSize = 13;

