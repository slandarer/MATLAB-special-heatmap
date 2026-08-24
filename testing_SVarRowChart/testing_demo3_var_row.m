% Variable row chart

% Inspired by : https://www.mathworks.com/matlabcentral/fileexchange/71922-hcp-heatmapcovariateplot
%               https://bitbucket.org/manuela_s/hcp/src/master/

% Since clustering modifies the ordering of columns, the heatmap is permitted to be added only once. 
% After the heatmap is drawn, the previously added variable rows are reordered, 
% and any subsequent rows will likewise be reordered.

% Load random statistical data (sex, age, blood type, height, weight, etc.)
% 加载随机统计数据 (包含性别、年龄、血型、身高体重等变量)
T = load('randStatData.mat');
T = T.T;

% Create figure and axes (创建图窗及坐标区域)
fig = figure('Units','normalized', 'Position',[.1,.1,.8,.8]);
ax = axes('Parent',fig, 'Position',[.1,.1,.8,.8]);

% Create SVarRowChart object (创建变量行图表对象)
SVR = SVarRowChart(ax, 'LeftWidth',35, 'RightWidth',20, 'ColSep',3, 'RowHeight',.6);
SVR.TitleFontProp = {'FontSize',14, 'FontName','Arial'};
SVR.VarFontProp = {'FontSize',10, 'FontName','Arial'};

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


% Add heatmap
SVR.addHeatmap(T{:, 16:35}.', 'ColName',T.Properties.RowNames, 'RowName',T.Properties.VariableNames(16:35), ...
    'Colormap',slanCM(97,32), 'Title', 'Correlation Coefficients', 'RowGap','on', ...
    'TopBlock','on', 'TopTree','on', 'RightBlock','on', 'RightTree','on', ...
    'RowClust',3, 'ColClust',3)


SVR.addRow(T.Test_C, 'Title','Test-C', 'Label',{'-','0','+'}, 'IconColNum',4)
SVR.addRow(T.Test_D, 'Title','Test-D', 'Label',{'-','0','+'}, 'IconColNum',4)
SVR.addRow(T.Test_E, 'Title','Test-E', 'Label',{'-','0','+'}, 'IconColNum',4)

