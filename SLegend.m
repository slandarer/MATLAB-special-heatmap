classdef SLegend < handle
% SLegend offers legends with greater flexibility in positioning,
% supports arbitrary rotation, and allows multiple legends to coexist within the same axes.
% SLegend 提供更灵活的位置控制、支持旋转，并允许在同一坐标区内共存多个图例。
%  
%   slgd = SLegend(target); creates a legend.
%   创建图例对象。
%
%   slgd = SLegend(target, 'Location',loc); creates a legend at the specified location.
%   通过指定位置创建颜色条。
%     'north' - top (上方)    | 'northeast' - top-right (右上)
%     'south' - bottom (下方) | 'southeast' - bottom-right (右下)
%     'east'  - right (右侧)  | 'northwest' - top-left (左上)
%     'west'  - left (左侧)   | 'southwest' - bottom-left (左下)
%
%   slgd = SLegend(target, propName, propVal); specifies property name-value
%   pairs when creating the object.
%   创建对象时指定属性名-属性值对。
%
%   slgd.propName = propVal; sets properties before calling draw().
%   在调用 draw() 前设置属性。
%
%   slgd = scbar.draw(); renders the legend.
%   渲染图例。
%
% Basic usage:
%   Data = rand(10, 10) - .5;
%   SHM = SHeatmap(Data);
%   SHM.draw()
%   SHM.setFrame()
% 
%   delete(SHM.Colorbar)
%   slgd = SLegend(SHM);
%   slgd.draw()
%
% Methods (try: help SLegend.setXYTLim)
% draw      - Render the legend object (渲染颜色条对象)
% setPatch  - Set properties for all patch objects (为所有填充图形设置属性)
% setBox    - Set properties for box (框属性设置)
% setLabel  - Set properties for labels (标签属性设置)
% setTitle  - Set properties for title (标题属性设置)
% setXYTLim - Set X, Y, and Theta limits for the legend (设置图例 X轴、 Y轴、角度范围)

    properties
        % Parameter name list for parsing (参数名称列表，用于解析输入)
        arginList = {'Location', 'Tick', 'Label', 'IconSize', ...
            'RowSep','ColSep','ColNum','RowGroup','GroupSep', ...
            'TickLength', 'LabelOffset', 'BasePos', 'TitleString', ...
            'TitleAlignment'}

        % Target should be SHeatmap/SClusterBlock object. 
        % The legend retrieves color and cell style from this object for the specified Tick values.
        % 目标为 SHeatmap/SClusterBlock 对象。图例从该对象中获取指定 Tick 值对应的颜色和单元格样式。
        Target
        Tick
        Label                     % Legend item labels (图例条目标签)
        
        IconSize = [1, 1]         % Size of the legend icon [width, height] (图例图标大小 [宽度, 高度])
        Location = 'northeast'    % Colorbar location (颜色条位置)
                                  % 'north'/'south'/'east'/'west'/
                                  % 'northeast'/'northwest'/
                                  % 'southeast'/'southwest'/
        RowSep = 0                % Vertical gap between legend rows (图例行之间的垂直间距)
        ColSep = 2                % Horizontal gap between legend columns (图例列之间的水平间距)
        ColNum                    % Number of columns to display (显示的列数)

        TickLength = 0            % Length of tick marks (刻度线长度)
        LabelOffset = .15         % Offset between tick and label (刻度与标签之间的偏移量)
        BasePos                   % Base position for legend placement (图例放置的基准位置)
        TitleString = '';         % Title string of the legend (图例标题字符串)
        TitleAlignment = 'left';  % Title horizontal alignment: 'left' | 'center' (标题水平对齐方式: 'left' | 'center')

        XLim = []                 % X-axis limits (X轴范围)
        YLim = []                 % Y-axis limits (Y轴范围)
        TLim = [0, 0]             % Theta limits (角度范围)

        pieHdl                    % Handles to pie objects for icons (图标饼图对象句柄)
        patchHdl                  % Handles to patch objects for icons (图标面片对象句柄)
        boxHdl                    % Handles to box objects (边框对象句柄)
        tickHdl                   % Handles to tick lines (刻度线句柄)
        labelHdl                  % Handles to label texts (标签文本句柄)
        titleHdl                  % Handle to title text (标题文本句柄)
    end

    properties (Hidden)
        ax, fig, targetClass, maxV
        iconMat, LT, RN, CN; RP; CP
        OXLim; OYLim; BX; BY; SX; SY
        PatchX; PatchY; PieX; PieY;
        LX; LY; TickX; TickY; TitleX; TitleY
    end

    methods
        function obj = SLegend(target, varargin)
            obj.Target = target;

            for i = 1:2:(length(varargin) - 1)
                tid = ismember(lower(obj.arginList), lower(varargin{i}));
                if any(tid)
                    obj.(obj.arginList{tid}) = varargin{i + 1};
                end
            end

            obj.ax = obj.Target.ax;
            obj.targetClass = class(obj.Target);
            if strcmpi(obj.targetClass, 'sheatmap')
                obj.fig = obj.Target.fig;
                obj.maxV = obj.Target.maxV;
                obj.SX = obj.Target.SX;
                obj.SY = obj.Target.SY;
            end
        end

        function varargout = draw(obj)
            % obj.draw() - Render the legend object (渲染颜色条对象)

            obj.IconSize = abs(obj.IconSize);
            obj.RowSep = abs(obj.RowSep);
            obj.ColSep = abs(obj.ColSep);

            obj.TickLength(obj.TickLength < 0) = 0;
            obj.TickLength(obj.TickLength > obj.ColSep/2) = obj.ColSep/2;
            obj.LabelOffset(obj.LabelOffset <= 1e-4) = 1e-4;
            obj.LabelOffset(obj.LabelOffset > .5) = .5;

            if isempty(obj.Tick)
                if strcmpi(obj.targetClass, 'sheatmap')
                    ts = obj.getTick(diff(obj.ax.CLim), 5);
                    if obj.ax.CLim(1).*obj.ax.CLim(2) <= 0
                        obj.Tick = unique([0:(-ts):obj.ax.CLim(1), 0:ts:obj.ax.CLim(2)]);
                    elseif all(obj.ax.CLim > 0)
                        obj.Tick = 0:ts:obj.ax.CLim(2);
                    else
                        obj.Tick = sort(0:(-ts):obj.ax.CLim(1));
                    end
                    obj.Tick(obj.Tick < obj.ax.CLim(1)) = [];
                    obj.Tick(obj.Tick > obj.ax.CLim(2)) = [];
                    obj.Tick(obj.Tick == 0) = [];
                    if strcmpi(obj.Location, 'north') || strcmpi(obj.Location, 'south')
                        obj.Tick = sort(obj.Tick);
                    else
                        obj.Tick = sort(obj.Tick, 'descend');
                    end
                else
                    obj.Tick = 1:max(obj.Target.ClassId);
                end
            end
            obj.LT = length(obj.Tick);

            if isempty(obj.ColNum)
                if strcmpi(obj.Location, 'north') || strcmpi(obj.Location, 'south')
                    obj.ColNum = obj.LT;
                else
                    obj.ColNum = 1;
                end
            end

            obj.iconMat = nan(ceil(obj.LT/obj.ColNum), obj.ColNum);
            obj.iconMat(1:obj.LT) = obj.Tick;
            obj.iconMat = obj.iconMat(:, any(~isnan(obj.iconMat), 1));
            [obj.RN, obj.CN] = size(obj.iconMat);
            [obj.RP, obj.CP] = find(~isnan(obj.iconMat));
            
            obj.RP = (obj.RP - 1).*(obj.RowSep + obj.IconSize(2)) + obj.IconSize(2)./2;
            obj.CP = (obj.CP - 1).*(obj.ColSep + obj.IconSize(1)) + obj.IconSize(1)./2;
            obj.RP = obj.RP(:).'; obj.CP = obj.CP(:).';
            tXLim = [min(obj.CP) - obj.IconSize(1)./2, max(obj.CP) + obj.IconSize(1)./2 + obj.ColSep];
            tYLim = [min(obj.RP) - obj.IconSize(2)./2, max(obj.RP) + obj.IconSize(2)./2];

            thdl = findobj(gca, 'Type', 'text');
            if isempty(thdl)
                tpos = [];
            else
                tpos = reshape([thdl(:).Position], 3, []);
            end
            axis(obj.ax, 'tight');
            xl = obj.ax.XLim;
            yl = obj.ax.YLim;


            if isempty(obj.BasePos) || length(obj.BasePos) < 2
                switch lower(obj.Location)
                    case 'north'
                        if (~isempty(tpos)) && any(tpos(2, :) < yl(1))
                            obj.BasePos = [mean(xl) - diff(tXLim)/2, yl(1) - 1 - diff(tYLim)];
                        else
                            obj.BasePos = [mean(xl) - diff(tXLim)/2, yl(1) - .5 - diff(tYLim)];
                        end
                    case 'south'
                        if (~isempty(tpos)) && any(tpos(2, :) > yl(2))
                            obj.BasePos = [mean(xl) - diff(tXLim)/2, yl(2) + 1];
                        else
                            obj.BasePos = [mean(xl) - diff(tXLim)/2,  yl(2) + .5];
                        end
                    case 'east'
                        if (~isempty(tpos)) && any(tpos(1, :) > xl(2))
                            obj.BasePos = [xl(2) + 1, mean(yl) - diff(tYLim)/2]; 
                        else
                            obj.BasePos = [xl(2) + .5, mean(yl) - diff(tYLim)/2]; 
                        end
                    case 'west'
                        if (~isempty(tpos)) && any(tpos(1, :) < xl(1))
                            obj.BasePos = [xl(1) - 1 - diff(tXLim), mean(yl) - diff(tYLim)/2]; 
                        else
                            obj.BasePos = [xl(1) - .5 - diff(tXLim), mean(yl) - diff(tYLim)/2]; 
                        end
                    case 'northeast'
                        if (~isempty(tpos)) && any(tpos(1, :) > xl(2))
                            obj.BasePos = [xl(2) + 1, yl(1)]; 
                        else
                            obj.BasePos = [xl(2) + .5, yl(1)]; 
                        end
                    case 'northwest'
                        if (~isempty(tpos)) && any(tpos(1, :) < xl(1))
                            obj.BasePos = [xl(1) - 1 - diff(tXLim), yl(1)]; 
                        else
                            obj.BasePos = [xl(1) - .5 - diff(tXLim), yl(1)]; 
                        end
                    case 'southeast'
                        if (~isempty(tpos)) && any(tpos(1, :) > xl(2))
                            obj.BasePos = [xl(2) + 1, yl(2) - diff(tYLim)]; 
                        else
                            obj.BasePos = [xl(2) + .5, yl(2) - diff(tYLim)]; 
                        end
                    case 'southwest'
                        if (~isempty(tpos)) && any(tpos(1, :) < xl(1))
                            obj.BasePos = [xl(1) - 1 - diff(tXLim), yl(2) - diff(tYLim)]; 
                        else
                            obj.BasePos = [xl(1) - .5 - diff(tXLim), yl(2) - diff(tYLim)]; 
                        end
                end
            end

            obj.RP = obj.RP + obj.BasePos(2);
            obj.CP = obj.CP + obj.BasePos(1);
            obj.OXLim = tXLim + obj.BasePos(1);
            obj.OYLim = tYLim + obj.BasePos(2);

            % =============================================================
            rows = obj.RP;
            cols = obj.CP;
            mn = obj.LT;
            datas = obj.Tick(:).';
            if strcmpi(obj.targetClass, 'sheatmap')
                % Define base shape coordinates (定义基本形状坐标)
                baseT = linspace(0, 2*pi, 100).';
                hexT  = linspace(0, 2*pi, 7).';
                starT = linspace(0, 2*pi, 11).' + pi/10;
                thetaMat = [1, 1; -1, 1].*sqrt(2)./2;
                T4 = [linspace(0, pi/2, 20), linspace(pi/2, pi, 20), linspace(pi, 3*pi/2, 20), linspace(3*pi/2, 2*pi, 20)].';
                X4 = [ones(1, 20), - ones(1, 20), - ones(1, 20), ones(1, 20)].';
                Y4 = [ones(1, 20), ones(1, 20), - ones(1, 20), - ones(1, 20)].';
                XA = [0; .5; .2; .2; -.2; -.2; -.5];
                YA = [.5; 0; 0; -.5; -.5; 0; 0];
                TM = [linspace(-pi/2, pi/2, 40), linspace(pi/2, 3*pi/2, 40)].';
                XM = cos(TM).*.5.*.92;
                YM = - sin(TM).*.5.*.92;
                TT = linspace(0, 2*pi, 80).';
                XT = sin(TT).*(sin(TT./2)).^.9;
                XT_max = 2 * (1/sqrt(2.9)) * (sqrt(1.9)/sqrt(2.9))^1.9;
                XT = XT.*.5.*.75./XT_max;
                YT = - cos(TT).*.5.*.94;

                datas(datas > obj.maxV) = obj.maxV;
                datas(datas < - obj.maxV) = - obj.maxV;
                tRatio = abs(datas)./obj.maxV;

                switch lower(obj.Target.Format)
                    case 'sq'
                        obj.PatchX = obj.SX.*repmat([-.5; .5; .5; -.5].*.98.*obj.IconSize(1), [1, mn]) + repmat(cols, [4, 1]);
                        obj.PatchY = obj.SY.*repmat([-.5; -.5; .5; .5].*.98.*obj.IconSize(2), [1, mn]) + repmat(rows, [4, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none');
                    case '3d'
                        obj.PatchX = obj.SX.*repmat([-1/2; 1/6; 1/2; 1/2; -1/6; -1/2; -1/2; -1/6; -1/6; -1/6; 1/2; -1/6].*.98.*obj.IconSize(1), [1, mn]) + repmat(cols, [12, 1]);
                        obj.PatchY = obj.SY.*repmat(-[-1/2; -1/2; -1/6; 1/2; 1/2; 1/6; -1/2; -1/6; 1/2; -1/6; -1/6; -1/6].*.98.*obj.IconSize(2), [1, mn]) + repmat(rows, [12, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[0,0,0], 'LineWidth',.8, 'LineJoin','chamfer');
                    case 'sqfull'
                        obj.PatchX = obj.SX.*repmat([-.5; .5; .5; -.5].*obj.IconSize(1), [1, mn]) + repmat(cols, [4, 1]);
                        obj.PatchY = obj.SY.*repmat([-.5; -.5; .5; .5].*obj.IconSize(2), [1, mn]) + repmat(rows, [4, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none');
                    case 'asq'
                        obj.PatchX = obj.SX.*repmat([-.5; .5; .5; -.5].*.98.*obj.IconSize(1), [1, mn]).*repmat(tRatio, [4, 1]) + repmat(cols, [4, 1]);
                        obj.PatchY = obj.SY.*repmat([-.5; -.5; .5; .5].*.98.*obj.IconSize(2), [1, mn]).*repmat(tRatio, [4, 1]) + repmat(rows, [4, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none');
                    case 'rrect'
                        obj.PatchX = obj.SX.*repmat((X4.*.7 + cos(T4).*.3).*.46.*obj.IconSize(1), [1, mn]) + repmat(cols, [80, 1]);
                        obj.PatchY = obj.SY.*repmat((Y4.*.7 + sin(T4).*.3).*.46.*obj.IconSize(2), [1, mn]) + repmat(rows, [80, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none');
                    case 'c2rect'
                        obj.PatchX = obj.SX.*(repmat(X4.*.46.*obj.IconSize(1), [1, mn]).*repmat(tRatio, [80, 1]) + repmat(cos(T4).*.46.*obj.IconSize(1), [1, mn]).*repmat(1 - tRatio, [80, 1])) + repmat(cols, [80, 1]);
                        obj.PatchY = obj.SY.*(repmat(Y4.*.46.*obj.IconSize(2), [1, mn]).*repmat(tRatio, [80, 1]) + repmat(sin(T4).*.46.*obj.IconSize(2), [1, mn]).*repmat(1 - tRatio, [80, 1])) + repmat(rows, [80, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    case 'shade'
                        obj.PatchX = obj.SX.*repmat([-.5; .5; .5; -.5].*.98.*obj.IconSize(1), [1, mn]) + repmat(cols, [4, 1]);
                        obj.PatchY = obj.SY.*repmat([-.5; -.5; .5; .5].*.98.*obj.IconSize(2), [1, mn]) + repmat(rows, [4, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none');
                        obj.PieX = obj.SX.*repmat([.49; .01; nan; .49; -.49; nan; -.01; -.49; nan].*obj.IconSize(1), [1, mn]) + repmat(cols, [9, 1]);
                        obj.PieY = obj.SY.*repmat([-.01; -.49; nan; .49; -.49; nan; .49; .01; nan].*obj.IconSize(2), [1, mn]) + repmat(rows, [9, 1]);
                        obj.pieHdl = fill(obj.ax, obj.PieX, obj.PieY, datas(:), 'EdgeColor',[1,1,1], 'LineWidth',1, 'EdgeAlpha',.7, 'LineJoin','chamfer');
                    case 'pie'
                        obj.PieX = obj.SX.*repmat(cos(baseT).*.92.*.5.*obj.IconSize(1), [1, mn]) + repmat(cols, [length(baseT), 1]);
                        obj.PieY = obj.SY.*repmat(sin(baseT).*.92.*.5.*obj.IconSize(2), [1, mn]) + repmat(rows, [length(baseT), 1]);
                        obj.pieHdl = fill(obj.ax, obj.PieX, obj.PieY, [1,1,1], 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                        tMesh = repmat(linspace(0, 1, 100).', 1, mn);
                        tTheta = pi/2 + tMesh.*repmat(datas./obj.maxV.*2.*pi, 100, 1);
                        obj.PatchX = obj.SX.*[zeros(1, mn); cos(tTheta).*.92.*.5].*obj.IconSize(1) + repmat(cols, [101, 1]);
                        obj.PatchY = obj.SY.*[zeros(1, mn);-sin(tTheta).*.92.*.5].*obj.IconSize(2) + repmat(rows, [101, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8, 'LineJoin','chamfer');
                    case 'circ'
                        obj.PatchX = obj.SX.*repmat(cos(baseT).*.92.*.5.*obj.IconSize(1), [1, mn]) + repmat(cols, [length(baseT), 1]);
                        obj.PatchY = obj.SY.*repmat(sin(baseT).*.92.*.5.*obj.IconSize(2), [1, mn]) + repmat(rows, [length(baseT), 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none', 'LineWidth',.8);
                    case 'acirc'
                        obj.PatchX = obj.SX.*repmat(cos(baseT).*.92.*.5.*obj.IconSize(1), [1, mn]).*repmat(tRatio, [length(baseT), 1]) + repmat(cols, [length(baseT), 1]);
                        obj.PatchY = obj.SY.*repmat(sin(baseT).*.92.*.5.*obj.IconSize(2), [1, mn]).*repmat(tRatio, [length(baseT), 1]) + repmat(rows, [length(baseT), 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none', 'LineWidth',.8);
                    case 'arrect'
                        tRatio2 = max(0, 4*(tRatio - 0.75));
                        obj.PatchX = obj.SX.*(repmat(X4.*.46.*obj.IconSize(1), [1, mn]).*repmat(tRatio2, [80, 1]) + repmat(cos(T4).*.46.*obj.IconSize(1), [1, mn]).*repmat(1 - tRatio2, [80, 1])).*repmat(tRatio, [80, 1]) + repmat(cols, [80, 1]);
                        obj.PatchY = obj.SY.*(repmat(Y4.*.46.*obj.IconSize(2), [1, mn]).*repmat(tRatio2, [80, 1]) + repmat(sin(T4).*.46.*obj.IconSize(2), [1, mn]).*repmat(1 - tRatio2, [80, 1])).*repmat(tRatio, [80, 1]) + repmat(rows, [80, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    case 'oval'
                        tValue = datas./obj.maxV;
                        baseA = 1 + (tValue <= 0).*tValue;
                        baseB = 1 - (tValue >= 0).*tValue;
                        baseOvalX = repmat(cos(baseT).*.98.*.5, [1, mn]).*repmat(baseA, [length(baseT), 1]);
                        baseOvalY = repmat(sin(baseT).*.98.*.5, [1, mn]).*repmat(baseB, [length(baseT), 1]);
                        baseOvalXY = [baseOvalX(:), baseOvalY(:)]*thetaMat;
                        obj.PatchX = obj.SX.*reshape(baseOvalXY(:,1).*obj.IconSize(1), [length(baseT), mn]) + repmat(cols, [length(baseT), 1]);
                        obj.PatchY = -obj.SY.*reshape(baseOvalXY(:,2).*obj.IconSize(2), [length(baseT), mn]) + repmat(rows, [length(baseT), 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    case 'hex'
                        obj.PatchX = obj.SX.*repmat(cos(hexT).*.92.*.5.*obj.IconSize(1), [1, mn]).*repmat(tRatio, [length(hexT), 1]) + repmat(cols, [length(hexT), 1]);
                        obj.PatchY = obj.SY.*repmat(sin(hexT).*.92.*.5.*obj.IconSize(2), [1, mn]).*repmat(tRatio, [length(hexT), 1]) + repmat(rows, [length(hexT), 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    case 'star'
                        tValue = datas./obj.maxV;
                        tR = [1;.5;1;.5;1;.5;1;.5;1;.5;1];
                        obj.PatchX = obj.SX.*repmat(cos(starT).*.92.*.5.*tR.*obj.IconSize(1), [1, mn]).*repmat(tValue, [length(starT), 1]) + repmat(cols, [length(starT), 1]);
                        obj.PatchY = -obj.SY.*repmat(sin(starT).*.92.*.5.*tR.*obj.IconSize(2), [1, mn]).*repmat(tValue, [length(starT), 1]) + repmat(rows, [length(starT), 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    case 'moon'
                        obj.PieX = obj.SX.*repmat(XM.*obj.IconSize(1), [1, mn]) + repmat(cols, [80, 1]);
                        obj.PieY = obj.SY.*repmat(YM.*obj.IconSize(2), [1, mn]) + repmat(rows, [80, 1]);
                        obj.pieHdl = fill(obj.ax, obj.PieX, obj.PieY, [1,1,1], 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                        tValue = 2.*((datas < 0) - .5);
                        obj.PatchX = obj.SX.*repmat(XM.*obj.IconSize(1), [1,mn]).*[ones([40, mn]); repmat(tRatio.*2 - 1, [40, 1])].*repmat(tValue, [80, 1]) + repmat(cols, [80, 1]);
                        obj.PatchY = obj.SY.*repmat(YM.*obj.IconSize(2), [1,mn]) + repmat(rows, [80, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8, 'LineJoin','chamfer');
                    case 'teardrop'
                        obj.PieX = obj.SX.*repmat(XT.*obj.IconSize(1), [1, mn]) + repmat(cols, [80, 1]);
                        obj.PieY = obj.SY.*repmat(YT.*obj.IconSize(2), [1, mn]) + repmat(rows, [80, 1]);
                        obj.pieHdl = fill(obj.ax, obj.PieX, obj.PieY, [1,1,1], 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                        tX1 = obj.SX.*repmat(XT, [1, mn]);
                        tY1 = obj.SY.*repmat(YT, [1, mn]);
                        tY2 = repmat((1 - tRatio).*.94 - .47, [80, 1]);
                        tX1(tY1 < tY2) = sign(tX1(tY1 < tY2)).*abs(sin(acos(tY2(tY1 < tY2)./(-.5.*.94))).*(sin(acos(tY2(tY1 < tY2)./(-.5.*.94))./2)).^.9).*.5.*.75./XT_max;
                        tY1(tY1 < tY2) = tY2(tY1 < tY2);
                        obj.PatchX = tX1.*obj.IconSize(1) + repmat(cols, [80, 1]);
                        obj.PatchY = tY1.*obj.IconSize(2) + repmat(rows, [80, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8, 'LineJoin','chamfer');
                    case 'arrow'
                        tValue = 2.*((datas < 0) - .5);
                        obj.PatchX = obj.SX.*repmat(XA.*.8.*obj.IconSize(1), [1, mn]) + repmat(cols, [7, 1]);
                        obj.PatchY = obj.SY.*repmat(YA.*.8.*obj.IconSize(2), [1, mn]).*repmat(tValue, [7, 1]) + repmat(rows, [7, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    case {'tril', 'trill'}
                        obj.PatchX = obj.SX.*repmat([-.5; .5; -.5].*.98.*obj.IconSize(1), [1, mn]) + repmat(cols, [3, 1]);
                        obj.PatchY = obj.SY.*repmat([.5; .5; -.5].*.98.*obj.IconSize(2), [1, mn]) + repmat(rows, [3, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none', 'LineWidth',.8);
                    case {'triu', 'triur'}
                        obj.PatchX = obj.SX.*repmat([-.5; .5; .5].*.98.*obj.IconSize(1), [1, mn]) + repmat(cols, [3, 1]);
                        obj.PatchY = obj.SY.*repmat([-.5; .5; -.5].*.98.*obj.IconSize(2), [1, mn]) + repmat(rows, [3, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none', 'LineWidth',.8);
                    case 'triul'
                        obj.PatchX = obj.SX.*repmat([.5; -.5; -.5].*.98.*obj.IconSize(1), [1, mn]) + repmat(cols, [3, 1]);
                        obj.PatchY = obj.SY.*repmat([-.5; -.5; .5].*.98.*obj.IconSize(2), [1, mn]) + repmat(rows, [3, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none', 'LineWidth',.8);
                    case 'trilr'
                        obj.PatchX = obj.SX.*repmat([-.5; .5; .5].*.98.*obj.IconSize(1), [1, mn]) + repmat(cols, [3, 1]);
                        obj.PatchY = obj.SY.*repmat([.5; .5; -.5].*.98.*obj.IconSize(2), [1, mn]) + repmat(rows, [3, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none', 'LineWidth',.8);
                    case 'donut'
                        obj.PieX = obj.SX.*repmat([cos(baseT - pi/2).*.92.*.5.*obj.IconSize(1); cos(baseT(end:-1:1, :) - pi/2).*.92.*.25.*obj.IconSize(1)], [1, mn]) + repmat(cols, [2*length(baseT), 1]);
                        obj.PieY = obj.SY.*repmat([sin(baseT - pi/2).*.92.*.5.*obj.IconSize(2); sin(baseT(end:-1:1, :) - pi/2).*.92.*.25.*obj.IconSize(2)], [1, mn]) + repmat(rows, [2*length(baseT), 1]);
                        obj.pieHdl = fill(obj.ax, obj.PieX, obj.PieY, [1,1,1], 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                        tMesh = repmat(linspace(0, 1, 50).', 1, mn);
                        tTheta = pi/2 + tMesh.*repmat(datas./obj.maxV.*2.*pi, 50, 1);
                        obj.PatchX = obj.SX.*[cos(tTheta).*.92.*.5.*obj.IconSize(1); cos(tTheta(end:-1:1, :)).*.92.*.25.*obj.IconSize(1)] + repmat(cols, [100, 1]);
                        obj.PatchY = -obj.SY.*[sin(tTheta).*.92.*.5.*obj.IconSize(2); sin(tTheta(end:-1:1, :)).*.92.*.25.*obj.IconSize(2)] + repmat(rows, [100, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8, 'LineJoin','chamfer');
                    case 'cust'
                        obj.PatchX = obj.SX.*repmat(obj.Target.SData(1,:).'.*obj.IconSize(1), [1, mn]) + repmat(cols, [length(obj.Target.SData(1,:)), 1]);
                        obj.PatchY = obj.SY.*repmat(-obj.Target.SData(2,:).'.*obj.IconSize(2), [1, mn]) + repmat(rows, [length(obj.Target.SData(2,:)), 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8, 'LineJoin','chamfer');
                    case 'acust'
                        obj.PatchX = obj.SX.*repmat(obj.Target.SData(1,:).'.*obj.IconSize(1), [1, mn]).*repmat(tRatio, [length(obj.Target.SData(1,:)), 1]) + repmat(cols, [length(obj.Target.SData(1,:)), 1]);
                        obj.PatchY = obj.SY.*repmat(-obj.Target.SData(2,:).'.*obj.IconSize(2), [1, mn]).*repmat(tRatio, [length(obj.Target.SData(2,:)), 1]) + repmat(rows, [length(obj.Target.SData(2,:)), 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8, 'LineJoin','chamfer');
                    case 'bcirc'
                        obj.PieX = obj.SX.*repmat(cos(baseT).*.92.*.5.*obj.IconSize(1), [1, mn]) + repmat(cols, [length(baseT), 1]);
                        obj.PieY = obj.SY.*repmat(sin(baseT).*.92.*.5.*obj.IconSize(2), [1, mn]) + repmat(rows, [length(baseT), 1]);
                        obj.pieHdl = fill(obj.ax, obj.PieX, obj.PieY, [1,1,1], 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                        obj.PatchX = obj.SX.*repmat(cos(baseT).*.92.*.5.*obj.IconSize(1), [1, mn]).*repmat(tRatio, [length(baseT), 1]) + repmat(cols, [length(baseT), 1]);
                        obj.PatchY = obj.SY.*repmat(sin(baseT).*.92.*.5.*obj.IconSize(2), [1, mn]).*repmat(tRatio, [length(baseT), 1]) + repmat(rows, [length(baseT), 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    case 'barh'
                        obj.PatchX = obj.SX.*(repmat([-.5; -.5; -.5; -.5].*obj.IconSize(1), [1, mn]) + repmat([0; 1; 1; 0].*.95.*obj.IconSize(1), [1, mn]).*repmat(tRatio, [4, 1])) + repmat(cols, [4, 1]);
                        obj.PatchY = obj.SY.*repmat([-.5; -.5; .5; .5].*.75.*obj.IconSize(2), [1, mn]) + repmat(rows, [4, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8, 'LineJoin','chamfer');
                    case 'bar'
                        obj.PatchX = obj.SX.*repmat([-.5; .5; .5; -.5].*.75.*obj.IconSize(1), [1, mn]) + repmat(cols, [4, 1]);
                        obj.PatchY = obj.SY.*(repmat([.5; .5; .5; .5].*obj.IconSize(2), [1, mn]) - repmat([1; 1; 0; 0].*.95.*obj.IconSize(2), [1, mn]).*repmat(tRatio, [4, 1])) + repmat(rows, [4, 1]);
                        obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8, 'LineJoin','chamfer');
                end

                if strcmpi(obj.Target.Format, 'shade')
                    set(obj.pieHdl(datas >= 0), 'XData',nan(9,1), 'YData',nan(9,1), 'Visible','off')
                end
                
                if obj.Target.isFrozen
                    obj.freezeColors()
                else
                    addlistener(obj.Target, 'isFrozen', 'PostSet', @(src, evt) obj.freezeColors(src, evt));
                end
            else
                obj.PatchX = repmat([-.5; .5; .5; -.5].*obj.IconSize(1), [1, mn]) + repmat(cols, [4, 1]);
                obj.PatchY = repmat([-.5; -.5; .5; .5].*obj.IconSize(2), [1, mn]) + repmat(rows, [4, 1]);
                obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, [0,0,0], 'EdgeColor','none');
                set(obj.patchHdl, {'FaceColor'}, num2cell(obj.Target.ColorList(obj.Tick, :), 2))
            end

            % =============================================================

            obj.BX = [];
            obj.BY = [];
            for i = 1:length(obj.Tick)
                obj.BX = [obj.BX, [-.5, .5, .5, -.5, -.5].*obj.IconSize(1) + obj.CP(i), nan];
                obj.BY = [obj.BY, [-.5, -.5, .5, .5, -.5].*obj.IconSize(2) + obj.RP(i), nan];
            end
            obj.boxHdl = plot(obj.ax, obj.BX, obj.BY, 'Color','k', 'LineWidth',1);


            obj.TickX = [obj.CP + obj.IconSize(1)/2; obj.CP + obj.IconSize(1)/2 + obj.TickLength; obj.CP.*nan];
            obj.TickY = [obj.RP; obj.RP; obj.RP.*nan];
            obj.tickHdl = plot(obj.ax, obj.TickX(:), obj.TickY(:), 'Color','k', 'LineWidth',1);


            obj.LX = obj.CP + obj.IconSize(1)/2 + obj.TickLength + obj.LabelOffset;
            obj.LY = obj.RP;
            if isempty(obj.Label)
                obj.Label = cell(1, obj.LT);
                if strcmpi(obj.targetClass, 'sheatmap')
                    for i = 1:obj.LT
                        obj.Label{i} = num2str(obj.Tick(i));
                    end
                else
                    obj.Label = obj.Target.ClassName;
                end
            end
            tind = 1:obj.LT; tind = mod(tind - 1, length(obj.Label)) + 1;
            obj.Label = obj.Label(tind);
            obj.labelHdl = text(obj.ax, obj.LX, obj.LY, obj.Label, 'FontSize',15, 'FontName','Times New Roman');

            obj.TitleX = obj.OXLim(1);
            obj.TitleY = obj.OYLim(1) - obj.RowSep - obj.IconSize(2)/2;
            if strcmpi(obj.TitleAlignment, 'left')      
                obj.titleHdl = text(obj.ax, obj.TitleX, obj.TitleY, obj.TitleString, 'FontSize',17, 'FontName','Times New Roman', 'HorizontalAlignment','left');
            else
                obj.TitleX = mean(obj.OXLim);
                obj.titleHdl = text(obj.ax, obj.TitleX, obj.TitleY, obj.TitleString, 'FontSize',17, 'FontName','Times New Roman', 'HorizontalAlignment','center');
            end

            obj.XLim = obj.OXLim;
            obj.YLim = obj.OYLim;

            axis(obj.ax, 'tight');
            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setPatch(obj, varargin)
            % obj.setPath(varargin) - Set properties for all patch objects (为所有填充图形设置属性)
            set(obj.patchHdl, varargin{:})
            if ~isempty(obj.pieHdl)
                set(obj.pieHdl, varargin{:})
            end
            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setBox(obj, varargin)
            % obj.setBox(varargin) - Set properties for box (框属性设置)
            set(obj.boxHdl, varargin{:})
            set(obj.tickHdl, varargin{:})

            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setTitle(obj, varargin)
            % obj.setTitle(varargin) - Set properties for title (标题属性设置)
            set(obj.titleHdl, varargin{:})

            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setLabel(obj, varargin)
            % obj.setLabel(varargin) - Set properties for labels (标签属性设置)
            set(obj.labelHdl, varargin{:})

            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setXYTLim(obj, varargin)
            % obj.setXYTLim(varargin) - Set X, Y, and Theta limits for the legend (设置图例 X轴、 Y轴、角度范围)
            %   obj.setXYTLim('XLim', [xmin, xmax], 'YLim', [ymin, ymax], 'TLim', [t, t])
            %
            %   The variable is named TLim for consistency with other functions. 
            %   However, in its current implementation, 
            %   only the case where TLim(1) == TLim(2) is supported.
            tArginList = {'XLim', 'YLim', 'TLim'};
            for i = 1:2:(length(varargin) - 1)
                tid = ismember(lower(tArginList), lower(varargin{i}));
                if any(tid)
                    obj.(tArginList{tid}) = varargin{i + 1};
                end
            end

            obj.XLim = sort(obj.XLim);
            obj.YLim = sort(obj.YLim);

            if isempty(obj.TLim)
                obj.TLim = [0, 0];
            end
            obj.TLim = obj.TLim([1, 1]);

            if ~isempty(obj.patchHdl)
                tX = obj.PatchX; tY = obj.PatchY;
                [nX, nY] = getNewXY(tX, tY, obj.OXLim, obj.OYLim, obj.XLim, obj.YLim, obj.TLim);
                nXYC = [num2cell(nX.', 2), num2cell(nY.', 2)];
                set(obj.patchHdl, {'XData','YData'}, nXYC)
            end
            if ~isempty(obj.pieHdl)
                tX = obj.PieX; tY = obj.PieY;
                [nX, nY] = getNewXY(tX, tY, obj.OXLim, obj.OYLim, obj.XLim, obj.YLim, obj.TLim);
                nXYC = [num2cell(nX.', 2), num2cell(nY.', 2)];
                set(obj.pieHdl, {'XData','YData'}, nXYC)
            end

            tX = obj.BX; tY = obj.BY;
            [nX, nY] = getNewXY(tX, tY, obj.OXLim, obj.OYLim, obj.XLim, obj.YLim, obj.TLim);
            set(obj.boxHdl, 'XData',nX, 'YData',nY);

            tX = obj.TickX; tY = obj.TickY;
            [nX, nY] = getNewXY(tX, tY, obj.OXLim, obj.OYLim, obj.XLim, obj.YLim, obj.TLim);
            set(obj.tickHdl, 'XData',nX(:), 'YData',nY(:));

            tX = obj.LX; tY = obj.LY;
            [nX, nY] = getNewXY(tX, tY, obj.OXLim, obj.OYLim, obj.XLim, obj.YLim, obj.TLim);
            for i = 1:length(obj.labelHdl)
                set(obj.labelHdl(i), 'Position',[nX(i), nY(i), 0]);
            end

            tX = obj.TitleX; tY = obj.TitleY;
            [nX, nY] = getNewXY(tX, tY, obj.OXLim, obj.OYLim, obj.XLim, obj.YLim, obj.TLim);
            set(obj.titleHdl, 'Position',[nX, nY, 0]);

            nV = [obj.labelHdl(1).Position(1) - obj.tickHdl.XData(1), obj.labelHdl(1).Position(2) - obj.tickHdl.YData(1)];
            nL = sqrt(nV(1).^2 + nV(2).^2);
            nV = nV./[nL, nL];
            nT = atan2(nV(2), nV(1)); 
            nT = nT/pi*180;
            nT = nT + 180.*((nT >= 90) | (nT < -90)).*sign(nT);
            if abs(nT) >= 270
                set(obj.labelHdl, 'Rotation',-nT, 'HorizontalAlignment','right')
                set(obj.titleHdl, 'Rotation',-nT, 'HorizontalAlignment','right');
            else
                set(obj.labelHdl, 'Rotation',-nT, 'HorizontalAlignment','left')
                set(obj.titleHdl, 'Rotation',-nT, 'HorizontalAlignment','left');
            end

            if strcmpi(obj.TitleAlignment, 'centre') || strcmpi(obj.TitleAlignment, 'center')
                set(obj.titleHdl, 'HorizontalAlignment','center');
            end

            function [nX, nY] = getNewXY(X, Y, OXLim, OYLim, XLim, YLim, TLim)
                TLim = [-TLim(1), -TLim(2)];
                X = (X - OXLim(1))./diff(OXLim).*diff(XLim) + XLim(1);
                Y = (Y - OYLim(1))./diff(OYLim).*diff(YLim) + YLim(1);

                if abs(diff(TLim)) < eps
                    RMat = [cos(TLim(1)), sin(TLim(1));
                        -sin(TLim(1)), cos(TLim(1))];
                    XY = [X(:), Y(:)]*RMat;
                    nX = reshape(XY(:, 1), size(X, 1), []);
                    nY = reshape(XY(:, 2), size(Y, 1), []);
                else
                    TArr = (Y - YLim(1))./diff(YLim).*diff(TLim) + TLim(1);
                    RArr = X;
                    nX = cos(TArr).*RArr;
                    nY = sin(TArr).*RArr;
                end
            end

            if nargout == 1
                varargout = {obj};
            end
        end

        function tXS = getTick(~, Len, N)
            % Calculate optimal tick spacing (计算最优刻度间隔)
            tXS = Len / N;
            tXN = ceil(log(tXS) / log(10));
            tXS = round(round(tXS / 10^(tXN-2)) / 5) * 5 * 10^(tXN-2);
        end

        function freezeColors(obj, ~, ~)
            % obj.freezeColors() - Permanently assign the current colormap colors to each patch 
            % based on its value, decoupling them from both the colormap axis limits (CLim) and the colormap itself.
            % (根据当前数值将颜色映射固定到每个填充图形，使其不再随颜色轴范围或颜色映射表的变化而改变)

            climit = get(obj.ax, 'CLim');
            cmap   = get(obj.ax, 'Colormap');

            dataVec = obj.Tick(:);
            counts = floor((dataVec - climit(1))./diff(climit).*size(cmap, 1)) + 1;
            counts(counts > size(cmap, 1)) = size(cmap, 1); 
            counts(counts < 1) = 1;
            colors = cmap(counts, :);

            set(obj.patchHdl, {'FaceColor'}, num2cell(colors, 2))
        end
    end
end