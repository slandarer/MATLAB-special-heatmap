%% Full-annular grouped heatmap with marker

% Inspired by : 《Python绘制花瓣状多组相关性热图》
%                 yinzhiqiang11 【python+遥感学习日志】
%                 https://mp.weixin.qq.com/s/RkwGo-nswkVUJKm0XXG-qQ

rng(6)
X  = randn(20, 10).*1.7 + [(linspace(-1,2.5,20)').*ones(1, 3), ...
                           (linspace(1.5,.7,20)').*ones(1, 3), ...
                           (linspace(.5,-.7,20)').*ones(1, 4)];
Y1 = randn(20,  8).*1.2 + (linspace(-1,2.5,20)').*ones(1, 8);
Y2 = randn(20,  8).*1.2 + (linspace(-1.5,2,20)').*ones(1, 8);
Y3 = randn(20,  8).*1.2 + (linspace(2,.1,20)').*ones(1, 8);
Y4 = randn(20,  8).*1.2 + (linspace(3,-2.5,20)').*ones(1, 8);

[Data1, pval1] = corr(X, Y1);
[Data2, pval2] = corr(X, Y2);
[Data3, pval3] = corr(X, Y3);
[Data4, pval4] = corr(X, Y4);

markers = {'o', 's', '^', 'v', '>', 'diamond', 'pentagram', 'hexagram'};
YName1 = {'A_{SHM}S','A_{SHM}L','A_{SHM}A','A_{SHM}N','A_{SHM}D','A_{SHM}A_2','A_{SHM}R','A_{SHM}E'};
YName2 = {'B_{SHM}S','B_{SHM}L','B_{SHM}A','B_{SHM}N','B_{SHM}D','B_{SHM}A_2','B_{SHM}R','B_{SHM}E'};
YName3 = {'C_{SHM}S','C_{SHM}L','C_{SHM}A','C_{SHM}N','C_{SHM}D','C_{SHM}A_2','C_{SHM}R','C_{SHM}E'};
YName4 = {'D_{SHM}S','D_{SHM}L','D_{SHM}A','D_{SHM}N','D_{SHM}D','D_{SHM}A_2','D_{SHM}R','D_{SHM}E'};
XName  = {'SAAAS','SK2L','SNV','N-HMN','MATSL','MATPY','MATJA','MAR', 'SHMS2','BMH'};

CList = [204,  61,  36; 243, 197,  88; 109, 174, 144; 48, 180, 204]./255;
Data = {Data1, Data2, Data3, Data4};
pval = {pval1, pval2, pval3, pval4};
YName = [YName1, YName2, YName3, YName4];

fig = figure('Units','normalized', 'Position',[.1,.05,.6,.9]);
ax = axes('Parent',fig, 'Position',[.1,.02,.8,.95]);


%% Draw heatmaps
shdl = gobjects(length(markers), 4);
for i = 1:4
    SHM = SHeatmap(Data{i}, 'RowName',XName, 'TickLength',0, 'TickLabelOffset',.2).draw();
    SHM.setRowLabelLocation('right').setColLabelLocation('top')
    SHM.setText('FontSize',8)
    SHM.setXYTLim('XLim',[1.2,2.2], 'YLim',[0,1], 'TLim',[pi - pi/24, pi/2 + pi/24] - (i - 1)*pi/2)
    set(SHM.frameHdl, 'Visible','off')
    set(SHM.colLabelHdl, 'Visible','off')
    set(SHM.rowLabelHdl, 'FontSize',12)
    setTextPerpRadial(SHM.textHdl)

    for j = 1:length(markers)
        tt = pi - pi/48 - (i - 1)*pi/2;
        rr = 1.2 + (j - .5)./size(Data{i}, 2);
        shdl(j, i) = scatter(ax, cos(tt).*rr, - sin(tt).*rr, ...
            100, CList(i,:), 'filled', 'Marker',markers{j}, 'MarkerEdgeColor','k', 'LineWidth',1);
    end

    % Mark cells with p < 0.005 (black border)
    % 标记显著性 p < 0.005 的格子 (黑色边框)
    SHM.setPatch(pval{i} < .005, 'EdgeColor',[0,0,0], 'LineWidth',1)
end

ax.YLim = [-2.4, 2.4];
SHM.Colorbar.Location = 'southoutside';
lgdHdl = legend(ax, shdl(:), YName, 'NumColumns',4, 'FontSize',12);
lgdHdl.Position = [1/3,.45,1/3,.18];

% Set Colormap
% cmp = slanCM(97, 32);
cmp = interp1([-1, 0, 1], [ 13, 72,162; 255,255,255; 255,194,  7]./255, linspace(-1, 1, 32));
% cmp = interp1([-1, 0, 1], [ 74,174,174; 255,255,255; 217,103,103]./255, linspace(-1, 1, 32));
colormap(cmp)