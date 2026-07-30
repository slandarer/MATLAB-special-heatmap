classdef SHeatmap < handle
% SHeatmap Create and customize heatmaps with various cell shapes format
% and triangular type
%   SHM = SHeatmap(data); creates a heatmap from a numerical matrix with
%   default square cells.
%   从数值矩阵创建默认方形单元格热图。
%
%   SHM = SHeatmap(ax, ___); creates the heatmap in the specified axes.
%   在指定坐标区创建热图。
%
%   SHM = SHeatmap(___, propName, propVal); specifies property name-value
%   pairs when creating the object.
%   创建对象时指定属性名-属性值对。
%
%   SHM.propName = propVal; sets properties before calling draw().
%   在调用 draw() 前设置属性。
%
%   SHM = SHM.draw(); renders the heatmap.
%   渲染热图。
%
% Basic usage:
%   Data = rand(5, 15);
%   SHM = SHeatmap(Data);
%   SHM.draw();
%
% Format:
%   Data = rand(15, 15) - .5;
%   SHM = SHeatmap(Data, 'Format','donut');
%   SHM.draw();
% 
%     'sq'          : square (default)          : 方形(默认)
%     'pie'         : pie chart                 : 饼图
%     'donut'       ：donut chart               : 环形饼图(甜甜圈图)
%     'circ'        : circle                    : 圆形
%     'bcirc'       : circle with box           : 有边框的圆形
%     'oval'        : oval                      : 椭圆形
%     'hex'         : hexagon                   ：六边形
%     'star'        : star                      : 五角星
%     'trill'(tril) : lower left triangle       : 下三角
%     'triur'(triu) : upper right triangle      : 上三角
%     'trilr'       : lower right triangle      : 右下三角
%     'triul'       : upper left triangle       : 左上三角
%     'asq'         : auto-size square          ：自带调整大小的方形
%     'acirc'       : auto-size circular        ：自带调整大小的圆形
%     'txt'(text)   : colored text              : 带颜色的文本
%     'cust'        : custom shape              : 自定义形状
%     'acust'       : auto-size custom shape    : 自带调整大小的自定义形状
% 
% Type:
%   X = randn(20, 15) + [(linspace(-1, 2.5, 20)').*ones(1, 6), ...
%                        (linspace(.5, -.7, 20)').*ones(1, 5), ...
%                        (linspace(.9, -.2, 20)').*ones(1, 4)];
%   Data = corr(X);
%   SHM = SHeatmap(Data, 'Type','sq').draw();
%   SHM.setType('triu');
%
%     'triu'   : upper triangle                   : 上三角部分
%     'tril'   : lower triangle                   : 下三角部分
%     'triu0'  : upper triangle without diagonal  : 扣除对角线上三角部分
%                (strictly upper triangular part) : (严格上三角)
%     'tril0'  : lower triangle without diagonal  : 扣除对角线下三角部分
%                (strictly lower triangular part) : (严格下三角)
%     'linkl'  : lower triangle for mantel links  : 适配 mantel 链接的下三角
%     'linku'  : upper triangle for mantel links  : 适配 mantel 链接的上三角
%
% Methods: (try: help SHeatmap.setText)
%   draw                - Render the heatmap object (渲染热图对象)
%   setType             - Adjust display to show only triangular part of the matrix (仅展示矩阵的三角部分)
%   setVarName          - Assign variable names to rows and columns (为行和列分配变量名)
%   setRowName          - Assign variable names to rows (为行分配变量名)
%   setColName          - Assign variable names to cols (为列分配变量名)
%   setText             - Show value labels with auto-contrast color, and set properties (显示数值标签并自动调整颜色，设置标签属性)
%   setTextFormat       - Apply a custom formatting function to all value labels (对数值标签应用自定义格式化函数)
%   showStars           - Overlay significance stars on value labels based on p-values (根据 p 值在数值标签上叠加显著性星标)
%   setBox              - Set properties for box handle (设置框样式)
%   setFrame            - Set properties for frame and tick handle (设置外轮廓样式)
%   setPatch            - Set properties for all patch objects (为所有填充图形设置属性)
%   setRowLabel         - Set properties for all row label text objects (设置所有行标签的属性)
%   setColLabel         - Set properties for all col label text objects (设置所有列标签的属性)
%   setRowLabelLocation - Move row labels to specified location (设置行标签位置)
%   setColLabelLocation - Move col labels to specified location (设置列标签位置)
%   freezeColors        - Permanently assign the current colormap colors to each patch 
%                         based on its value, decoupling them from both the 
%                         colormap axis limits (CLim) and the colormap itself
%                         (根据当前数值将颜色映射固定到每个填充图形，使其不再随颜色轴范围或颜色映射表的变化而改变)
%   setXYTLim            - Set X, Y, and Theta limits for the heatmap (设置热图 X轴、 Y轴、角度范围)


% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔 
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2025). special heatmap 
% (https://www.mathworks.com/matlabcentral/fileexchange/125520-special-heatmap), 
% MATLAB Central File Exchange. 检索来源 2025/12/1.
% =========================================================================


% =========================================================================
% Update(2025-12-01):
% + 更多形状 (More shapes)
% + 使用不同 colormap (Draw heat maps with two colormaps)
% + 显示显著性 (Displaying significance)


    properties
        ax, 
        Parent = [];
        arginList = {'Parent', 'Format', 'SData', 'Type', ...
                     'VarName', 'RowName', 'ColName', ...
                     'GroupSep', 'RowGroup', 'ColGroup'}
        Data

        Format = 'sq'  
        % 'sq'          : square (default)          : 方形(默认)
        % 'pie'         : pie chart                 : 饼图
        % 'donut'       ：donut chart               : 环形饼图(甜甜圈图)
        % 'circ'        : circle                    : 圆形
        % 'bcirc'       : circle with box           : 有边框的圆形
        % 'oval'        : oval                      : 椭圆形
        % 'hex'         : hexagon                   ：六边形
        % 'star'        : star                      : 五角星
        % 'trill'(tril) : lower left triangle       : 下三角
        % 'triur'(triu) : upper right triangle      : 上三角
        % 'trilr'       : lower right triangle      : 右下三角
        % 'triul'       : upper left triangle       : 左上三角
        % 'asq'         : auto-size square          ：自带调整大小的方形
        % 'acirc'       : auto-size circular        ：自带调整大小的圆形
        % 'txt'(text)   : colored text              : 带颜色的文本
        % 'cust'        : custom shape              : 自定义形状
        % 'acust'       : auto-size custom shape    : 自带调整大小的自定义形状
        SData = [.45, .21, .22, .09, .00, -.09, -.22, -.21, -.45, -.21, -.22, -.09, -.00,  .09,  0.22,  .21,   .45
                 .00, .09, .22, .21, .45,  .21,  .22,  .09,  .00, -.09, -.22, -.21, -.45, -.21, -0.22, -.09, -.00];
        Type = 'full';
        %     'triu'   : upper triangle                   : 上三角部分
        %     'tril'   : lower triangle                   : 下三角部分
        %     'triu0'  : upper triangle without diagonal  : 扣除对角线上三角部分
        %                (strictly upper triangular part) : (严格上三角)
        %     'tril0'  : lower triangle without diagonal  : 扣除对角线下三角部分
        %                (strictly lower triangular part) : (严格下三角)
        %     'linkl'  : lower triangle for mantel links  : 适配 mantel 链接的下三角
        %     'linku'  : upper triangle for mantel links  : 适配 mantel 链接的上三角

        TickLength = .1;
        RowLabelLocation = 'left';    % 'left', 'right', 'diag'
        ColLabelLocation = 'bottom';  % 'top', 'bottom', 'diag'

        Colormap;       % Colormap (颜色映射表)
        Colorbar;       % Colorbar (颜色条) 

        % For a square matrix (e.g., corr(X) or correlation matrix of a single dataset):
        VarName;        % Variable names for the single dataset (变量名称)
        % For a rectangular matrix (e.g., corr(X, Y) or cross-correlation between two datasets):
        RowName;        % Names of variables in dataset X (行变量名称)
        ColName;        % Names of variables in dataset Y (列变量名称)
        RowGroup = [];
        ColGroup = [];
        GroupSep = .5;

        % For 
        XLim = [], 
        YLim = [], 
        TLim = [0, 0];

        textHdl;        % Text (data value) handle (文本句柄)
        boxHdl;         % Outline handle (边框句柄)
        patchHdl;       % Patch handle (填充图形句柄)
        pieHdl;         % Pie chart handle (饼图句柄)
        rowLabelHdl;    % Row label handle (行标签句柄)
        colLabelHdl;    % Column label handle (列标签句柄)
        frameHdl;       % Frame (outline) handle (外轮廓句柄)
        rowTickHdl;     % Row tick handle (行刻度句柄)
        colTickHdl;     % Col tick handle (列刻度句柄)
    end

    properties (Hidden)
        maxV
        defaultCmp1 = [.97, .99, .94; .95, .98, .92; .92, .97, .90;
                       .90, .96, .88; .88, .95, .86; .86, .94, .83; 
                       .84, .94, .81; .82, .93, .79; .79, .92, .77; 
                       .75, .90, .75; .72, .89, .74; .68, .88, .72; 
                       .64, .86, .72; .60, .84, .73; .55, .83, .75;
                       .51, .81, .76; .46, .79, .78; .41, .76, .79; 
                       .37, .74, .81; .32, .71, .82; .28, .68, .81; 
                       .25, .64, .79; .21, .60, .77; .18, .56, .75; 
                       .14, .52, .73; .11, .49, .71; .07, .45, .69; 
                       .04, .41, .68; .03, .37, .64; .03, .33, .59;
                       .03, .29, .55; .03, .25, .51];
        defaultCmp2 = [.62, .00, .26; .69, .08, .28; .76, .16, .29;
                       .83, .24, .31; .87, .30, .30; .91, .36, .28;
                       .95, .42, .27; .97, .49, .29; .98, .58, .33;
                       .99, .66, .37; .99, .73, .42; .99, .79, .47;
                       1.0, .85, .52; 1.0, .90, .58; 1.0, .94, .65;
                       1.0, .98, .72; .98, .99, .72; .95, .98, .68;
                       .92, .97, .63; .87, .95, .60; .80, .92, .62;
                       .72, .89, .63; .64, .86, .64; .56, .82, .64;
                       .47, .79, .65; .39, .75, .65; .32, .67, .68;
                       .26, .60, .71; .20, .53, .74; .26, .45, .70;
                       .31, .38, .67; .37, .31, .64];
        RP; CP; FX; FY; GX; GY; TxtShown = false; 
        PatchX; PatchY; PieX; PieY; nanTextHdl
    end

    methods

% =========================================================================
% Constructor: Create SHeatmap object (构造函数)
% =========================================================================
        function obj = SHeatmap(varargin)
            % Parse axes handle if provided (解析坐标区句柄)
            if isa(varargin{1}, 'matlab.graphics.axis.Axes')
                obj.ax = varargin{1};
                obj.Parent = varargin{1};
                varargin(1) = [];
            else
                % No axes provided
            end

            % Store data (存储数据)
            obj.Data = varargin{1};
            varargin(1) = [];
            obj.maxV = max(max(abs(obj.Data)));

            % Parse optional arguments (解析可选参数)
            for i = 1:2:(length(varargin) - 1)
                tid = ismember(lower(obj.arginList), lower(varargin{i}));
                if any(tid)
                    obj.(obj.arginList{tid}) = varargin{i + 1};
                end
            end

            % Choose colormap based on data sign (根据数据正负选择配色)
            if any(any(obj.Data < 0))
                obj.Colormap = obj.defaultCmp2;
            else
                obj.Colormap = obj.defaultCmp1(end:-1:1, :);
            end
        end

% =========================================================================
% Draw: Render the SHeatmap (渲染热图)
% =========================================================================
        function varargout = draw(obj)
            % obj.draw() - Render the heatmap object (渲染热图对象)


            % mustBeAllowedFormat(obj.Format)
            % mustBeAllowedColLabelLocation(obj.ColLabelLocation)
            % mustBeAllowedRowLabelLocation(obj.RowLabelLocation)
            % mustBeAllowedTriType(obj.Type)

            % Set axes handle (设置坐标轴句柄)
            if isempty(obj.Parent) && isempty(obj.ax)
                obj.ax = gca;
            else
                obj.ax = obj.Parent;
            end

            % Configure axes properties (配置坐标轴属性)
            obj.ax.NextPlot       = 'add';
            obj.ax.Box            = 'on';
            obj.ax.FontName       = 'Times New Roman';
            obj.ax.FontSize       = 12;
            obj.ax.LineWidth      = 0.8;
            obj.ax.YDir           = 'reverse';
            obj.ax.TickDir        = 'out';
            obj.ax.TickLength     = [0.002, 0.002];
            obj.ax.DataAspectRatio = [1, 1, 1];

            obj.ax.XLim           = [0.5, size(obj.Data, 2) + 0.5];
            obj.ax.YLim           = [0.5, size(obj.Data, 1) + 0.5];
            obj.ax.YTick          = 1:size(obj.Data, 1);
            obj.ax.XTick          = 1:size(obj.Data, 2);
           

            % Apply colormap and colorbar (应用颜色映射和颜色条)
            colormap(obj.ax, obj.Colormap);
            obj.Colorbar = colorbar(obj.ax);

            % Set color axis limits (设置颜色轴范围)
            if any(any(obj.Data < 0))
                try caxis(obj.ax, obj.maxV .* [-1, 1]), catch, end
                try clim(obj.ax,  obj.maxV .* [-1, 1]), catch, end
            else
                try caxis(obj.ax, obj.maxV .* [0, 1]),  catch, end
                try clim(obj.ax,  obj.maxV .* [0, 1]),  catch, end
            end
            

            obj.GroupSep(obj.GroupSep < 0) = 0;
            obj.GroupSep(obj.GroupSep > 3) = 3;

            if isempty(obj.RowGroup) || length(obj.RowGroup) < size(obj.Data, 1)
                obj.RowGroup = ones(1, size(obj.Data, 1));
            end
            if isempty(obj.ColGroup) || length(obj.ColGroup) < size(obj.Data, 2)
                obj.ColGroup = ones(1, size(obj.Data, 2));
            end
            obj.RowGroup = obj.RowGroup(1:size(obj.Data, 1));
            obj.ColGroup = obj.ColGroup(1:size(obj.Data, 2));
            obj.RowGroup = cumsum([1, diff(obj.RowGroup(:).') ~= 0]);
            obj.ColGroup = cumsum([1, diff(obj.ColGroup(:).') ~= 0]);
            obj.RP = (1:size(obj.Data, 1)) + (obj.RowGroup - 1).*obj.GroupSep;
            obj.CP = (1:size(obj.Data, 2)) + (obj.ColGroup - 1).*obj.GroupSep;

            obj.XLim = [obj.CP(1) - .5, obj.CP(end) + .5];
            obj.YLim = [obj.RP(1) - .5, obj.RP(end) + .5];


            obj.ax.XLim = [0.5, obj.CP(end) + 0.5];
            obj.ax.YLim = [0.5, obj.RP(end) + 0.5];
            obj.ax.XTick = obj.CP;
            obj.ax.YTick = obj.RP;
            obj.ax.XTickLabel = compose('%d', 1:size(obj.Data, 2));
            obj.ax.YTickLabel = compose('%d', 1:size(obj.Data, 1));

            % Adjust figure size if needed (调整初始界面大小)
            fig = obj.ax.Parent;
            if strcmp(get(fig, 'Type'), 'figure')
                fig.Color = [1, 1, 1];
                if max(fig.Position(3:4)) < 600 && strcmp(fig.Units, 'pixels')
                    fig.Position(3:4) = [1.6, 1.8] .* fig.Position(3:4);
                    fig.Position(1:2) = fig.Position(1:2) ./ 4;
                end
            end

            % Draw grid lines (绘制网格线)
            obj.GX = []; obj.GY = [];
            for gi = 1:max(obj.RowGroup)
                for gj = 1:max(obj.ColGroup)
                    posi = obj.RP(obj.RowGroup == gi);
                    posj = obj.CP(obj.ColGroup == gj);
                    rowY = unique([posi - .5, posi + .5]);
                    rowX = [posj(1) - .5; posj(end) + .5; nan]*ones(size(rowY));
                    rowY = [1; 1; nan]*rowY;
                    colX = unique([posj - .5, posj + .5]);  
                    colY = [posi(1) - .5; posi(end) + .5; nan]*ones(size(colX));
                    colX = [1; 1; nan]*colX;
                    obj.GX = [obj.GX; rowX(:); colX(:)];
                    obj.GY = [obj.GY; rowY(:); colY(:)];
                end
            end
            obj.boxHdl = plot(obj.ax, obj.GX, obj.GY, ...
                'LineWidth', 0.8, 'Color', [1, 1, 1] .* 0.85);
            if isequal(obj.Format, 'sq')
                set(obj.boxHdl, 'Color', [1, 1, 1, 0]);
            end

            % Define base shape coordinates (定义基本形状坐标)
            baseT = linspace(0, 2*pi, 100).';
            hexT  = linspace(0, 2*pi, 7).';
            starT = linspace(0, 2*pi, 11).' + pi/10;
            thetaMat = [1, 1; -1, 1].*sqrt(2)./2;
            [cols, rows] = meshgrid(1:size(obj.Data, 2), 1:size(obj.Data, 1));

            rows = reshape(obj.RP(rows), 1, []);
            cols = reshape(obj.CP(cols), 1, []);
            datas = reshape(obj.Data, 1, []);
            mn = numel(obj.Data); sz = size(obj.Data);
            tRatio = abs(datas)./obj.maxV;

            switch lower(obj.Format)
                case 'sq'
                    obj.PatchX = repmat([-.5; .5; .5; -.5].*.98, [1, mn]) + repmat(cols, [4, 1]);
                    obj.PatchY = repmat([-.5; -.5; .5; .5].*.98, [1, mn]) + repmat(rows, [4, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas, 'EdgeColor','none');
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'asq'
                    obj.PatchX = repmat([-.5; .5; .5; -.5].*.98, [1, mn]).*repmat(tRatio, [4, 1]) + repmat(cols, [4, 1]);
                    obj.PatchY = repmat([-.5; -.5; .5; .5].*.98, [1, mn]).*repmat(tRatio, [4, 1]) + repmat(rows, [4, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas, 'EdgeColor','none');
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'pie'
                    obj.PieX = repmat(cos(baseT).*.92.*.5, [1, mn]) + repmat(cols, [length(baseT), 1]);
                    obj.PieY = repmat(sin(baseT).*.92.*.5, [1, mn]) + repmat(rows, [length(baseT), 1]);
                    obj.pieHdl = fill(obj.ax, obj.PieX, obj.PieY, [1,1,1], 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.pieHdl = reshape(obj.pieHdl, sz);
                    tMesh = repmat(linspace(0, 1, 100).', 1, mn);
                    tTheta = pi/2 + tMesh.*repmat(datas./obj.maxV.*2.*pi, 100, 1);
                    obj.PatchX = [zeros(1, mn); cos(tTheta).*.92.*.5] + repmat(cols, [101, 1]);
                    obj.PatchY = [zeros(1, mn);-sin(tTheta).*.92.*.5] + repmat(rows, [101, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas, 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'circ'
                    obj.PatchX = repmat(cos(baseT).*.92.*.5, [1, mn]) + repmat(cols, [length(baseT), 1]);
                    obj.PatchY = repmat(sin(baseT).*.92.*.5, [1, mn]) + repmat(rows, [length(baseT), 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas, 'EdgeColor','none', 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'acirc'
                    obj.PatchX = repmat(cos(baseT).*.92.*.5, [1, mn]).*repmat(tRatio, [length(baseT), 1]) + repmat(cols, [length(baseT), 1]);
                    obj.PatchY = repmat(sin(baseT).*.92.*.5, [1, mn]).*repmat(tRatio, [length(baseT), 1]) + repmat(rows, [length(baseT), 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas, 'EdgeColor','none', 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'oval'
                    tValue = datas./obj.maxV;
                    baseA = 1 + (tValue <= 0).*tValue;
                    baseB = 1 - (tValue >= 0).*tValue;
                    baseOvalX = repmat(cos(baseT).*.98.*.5, [1, mn]).*repmat(baseA, [length(baseT), 1]);
                    baseOvalY = repmat(sin(baseT).*.98.*.5, [1, mn]).*repmat(baseB, [length(baseT), 1]);
                    baseOvalXY = [baseOvalX(:), baseOvalY(:)]*thetaMat;
                    obj.PatchX = reshape(baseOvalXY(:,1), [length(baseT), mn]) + repmat(cols, [length(baseT), 1]);
                    obj.PatchY = -reshape(baseOvalXY(:,2), [length(baseT), mn]) + repmat(rows, [length(baseT), 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas, 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'hex'
                    obj.PatchX = repmat(cos(hexT).*.92.*.5, [1, mn]).*repmat(tRatio, [length(hexT), 1]) + repmat(cols, [length(hexT), 1]);
                    obj.PatchY = repmat(sin(hexT).*.92.*.5, [1, mn]).*repmat(tRatio, [length(hexT), 1]) + repmat(rows, [length(hexT), 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas, 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'star'
                    tValue = datas./obj.maxV;
                    tR = [1;.5;1;.5;1;.5;1;.5;1;.5;1];
                    obj.PatchX = repmat(cos(starT).*.92.*.5.*tR, [1, mn]).*repmat(tValue, [length(starT), 1]) + repmat(cols, [length(starT), 1]);
                    obj.PatchY = -repmat(sin(starT).*.92.*.5.*tR, [1, mn]).*repmat(tValue, [length(starT), 1]) + repmat(rows, [length(starT), 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas, 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case {'tril', 'trill'}
                    obj.PatchX = repmat([-.5; .5; -.5].*.98, [1, mn]) + repmat(cols, [3, 1]);
                    obj.PatchY = repmat([.5; .5; -.5].*.98, [1, mn]) + repmat(rows, [3, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas, 'EdgeColor','none', 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case {'triu', 'triur'}
                    obj.PatchX = repmat([-.5; .5; .5].*.98, [1, mn]) + repmat(cols, [3, 1]);
                    obj.PatchY = repmat([-.5; .5; -.5].*.98, [1, mn]) + repmat(rows, [3, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas, 'EdgeColor','none', 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'triul'
                    obj.PatchX = repmat([.5; -.5; -.5].*.98, [1, mn]) + repmat(cols, [3, 1]);
                    obj.PatchY = repmat([-.5; -.5; .5].*.98, [1, mn]) + repmat(rows, [3, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas, 'EdgeColor','none', 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'trilr'
                    obj.PatchX = repmat([-.5; .5; .5].*.98, [1, mn]) + repmat(cols, [3, 1]);
                    obj.PatchY = repmat([.5; .5; -.5].*.98, [1, mn]) + repmat(rows, [3, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas, 'EdgeColor','none', 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'donut'
                    obj.PieX = repmat([cos(baseT - pi/2).*.92.*.5; cos(baseT(end:-1:1, :) - pi/2).*.92.*.25], [1, mn]) + repmat(cols, [2*length(baseT), 1]);
                    obj.PieY = repmat([sin(baseT - pi/2).*.92.*.5; sin(baseT(end:-1:1, :) - pi/2).*.92.*.25], [1, mn]) + repmat(rows, [2*length(baseT), 1]);
                    obj.pieHdl = fill(obj.ax, obj.PieX, obj.PieY, [1,1,1], 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.pieHdl = reshape(obj.pieHdl, sz);
                    tMesh = repmat(linspace(0, 1, 50).', 1, mn);
                    tTheta = pi/2 + tMesh.*repmat(datas./obj.maxV.*2.*pi, 50, 1);
                    obj.PatchX = [cos(tTheta).*.92.*.5; cos(tTheta(end:-1:1, :)).*.92.*.25] + repmat(cols, [100, 1]);
                    obj.PatchY = -[sin(tTheta).*.92.*.5; sin(tTheta(end:-1:1, :)).*.92.*.25] + repmat(rows, [100, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas, 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8, 'LineJoin','chamfer');
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'cust'
                    obj.PatchX = repmat(obj.SData(1,:).', [1, mn]) + repmat(cols, [length(obj.SData(1,:)), 1]);
                    obj.PatchY = repmat(-obj.SData(2,:).', [1, mn]) + repmat(rows, [length(obj.SData(2,:)), 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas, 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'acust'
                    obj.PatchX = repmat(obj.SData(1,:).', [1, mn]).*repmat(tRatio, [length(obj.SData(1,:)), 1]) + repmat(cols, [length(obj.SData(1,:)), 1]);
                    obj.PatchY = repmat(-obj.SData(2,:).', [1, mn]).*repmat(tRatio, [length(obj.SData(2,:)), 1]) + repmat(rows, [length(obj.SData(2,:)), 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas, 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'bcirc'
                    obj.PieX = repmat(cos(baseT).*.92.*.5, [1, mn]) + repmat(cols, [length(baseT), 1]);
                    obj.PieY = repmat(sin(baseT).*.92.*.5, [1, mn]) + repmat(rows, [length(baseT), 1]);
                    obj.pieHdl = fill(obj.ax, obj.PieX, obj.PieY, [1,1,1], 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.pieHdl = reshape(obj.pieHdl, sz);
                    obj.PatchX = repmat(cos(baseT).*.92.*.5, [1, mn]).*repmat(tRatio, [length(baseT), 1]) + repmat(cols, [length(baseT), 1]);
                    obj.PatchY = repmat(sin(baseT).*.92.*.5, [1, mn]).*repmat(tRatio, [length(baseT), 1]) + repmat(rows, [length(baseT), 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas, 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
            end

            % obj.textHdl = gobjects(size(obj.Data, 1), size(obj.Data, 2));

            [nanR, nanC] = find(isnan(obj.Data));
            if ~isempty(nanR)
                obj.nanTextHdl = text(obj.ax, obj.CP(nanC), obj.RP(nanR), ...
                    '×', 'FontName','Times New Roman', 'HorizontalAlignment','center', 'FontSize',20);

                tind = sub2ind(sz, nanR, nanC);
                if ~isempty(obj.PatchX)
                    if size(obj.PatchX, 1) < 4
                        obj.PatchX(4, :) = nan;
                        obj.PatchY(4, :) = nan;
                    end
                    obj.PatchX(:, tind) = nan;
                    obj.PatchY(:, tind) = nan;
                    for i = 1:length(nanR)
                        row = nanR(i); col = nanC(i);
                        set(obj.patchHdl(row, col), 'XData', [-.5;.5;.5;-.5].*.98 + obj.CP(col), ...
                                                    'YData', [-.5,-.5,.5,.5].*.98 + obj.RP(row), ...
                                                    'FaceColor', [.8,.8,.8], 'EdgeColor','none');
                        obj.PatchX(1:4, tind(i)) = [-.5;.5;.5;-.5].*.98 + obj.CP(col);
                        obj.PatchY(1:4, tind(i)) = [-.5,-.5,.5,.5].*.98 + obj.RP(row);
                    end
                    
                end
                if ~isempty(obj.PieX)
                    obj.PieX(:, tind) = nan;
                    obj.PieX(:, tind) = nan;
                    for i = 1:length(nanR)
                        row = nanR(i); col = nanC(i);
                        set(obj.pieHdl(row, col), 'XData', [0;0;0;0], ...
                                                  'YData', [0;0;0;0], ...
                                                  'FaceColor', [0,0,0]);
                    end
                end
            end

            if strcmpi(obj.Format, 'txt') || strcmpi(obj.Format, 'text')
                obj.setText()
            end

            obj.FX = []; obj.FY = [];
            for gi = 1:max(obj.RowGroup)
                for gj = 1:max(obj.ColGroup)
                    posi = obj.RP(obj.RowGroup == gi);
                    posj = obj.CP(obj.ColGroup == gj);
                    numY = max(posi) - min(posi) + 2;
                    obj.FX = [obj.FX, [0, ones(1, numY), zeros(1, numY), 1, nan].*(max(posj) - min(posj) + 1) + min(posj) - .5];
                    obj.FY = [obj.FY, [0, linspace(0, 1, numY), linspace(1, 0, numY), 0, nan].*(max(posi) - min(posi) + 1) + min(posi) - .5];
                end
            end
            obj.frameHdl = plot(obj.ax, obj.FX, obj.FY, 'Color','k', 'LineWidth',1, 'LineJoin','miter', 'Visible','off');
            obj.rowTickHdl = plot(obj.ax, nan, nan, 'Color','k', 'LineWidth',1, 'Visible','off');
            obj.colTickHdl = plot(obj.ax, nan, nan, 'Color','k', 'LineWidth',1, 'Visible','off');

            if isempty(obj.VarName)
                % Create default variable names (生成默认变量名)
                obj.VarName{length(obj.Data)} = '';
                for i = 1:length(obj.Data)
                    obj.VarName{i} = ['Var-', num2str(i)];
                end
                tflag = false;
            else
                tflag = true;
            end

            % Add row labels ('Visible', 'off') (添加行标签，默认隐藏)
            obj.rowLabelHdl = gobjects(1, size(obj.Data, 1));
            for row = 1:size(obj.Data, 1)
                obj.rowLabelHdl(row) = text(obj.ax, 0.5 - 0.25, obj.RP(row), ...
                    obj.VarName{row}, 'HorizontalAlignment','right', ...
                    'FontName','Times New Roman', 'FontSize',12, 'Visible','off');
            end

            % Add column labels ('Visible', 'off') (添加列标签，默认隐藏)
            obj.colLabelHdl = gobjects(1, size(obj.Data, 2));
            for col = 1:size(obj.Data, 2)
                obj.colLabelHdl(col) = text(obj.ax, obj.CP(col), obj.RP(end) + 0.75, ...
                    obj.VarName{col}, 'HorizontalAlignment','right', ...
                    'FontName','Times New Roman', 'FontSize',12, 'Rotation',30, 'Visible','off');
            end

            % Apply 'Type' if not full
            if ~strcmp(obj.Type, 'full')
                obj.setType(obj.Type);
            end

            if tflag
                obj.setVarName(obj.VarName);
            end

            if ~isempty(obj.RowName)
                obj.setRowName(obj.RowName);
            end
            if ~isempty(obj.ColName)
                obj.setColLabelLocation('bottom')
                obj.setColName(obj.ColName);
            end

            if nargout == 1
                varargout = {obj};
            end
        end

% =========================================================================
% Text decoration (修饰文本)
% =========================================================================
        function varargout = setText(obj, varargin)
            % obj.setText(varargin) - Show value labels with auto-contrast
            % color and hide based on matrix type, and set properties for labels 
            % (显示数值标签，自动调整对比色，并根据矩阵类型隐藏部分标签，设置标签属性)
            %
            %   obj.setText(___); Set properties for all value labels.
            %
            %   obj.setText(m, n, ___); Set properties for the m‑th row, n-th column value label.
            %
            %   obj.setText([m1, m2, ...], [n1, n2, ...], ___); Set
            %   properties for value labels by their indices.
            %
            %   obj.setText([m1; m2; ...], [n1, n2, ...], ___);
            %   obj.setText([m1, m2, ...], [n1; n2; ...], ___); 
            %   Set properties for all combinations when the row-index-vector 
            %   and col-index-vector have different sizes.
            %  
            %   obj.setText([m1, m2, ...], [], ___); Set properties for 
            %   the value labels for all columns in the specified rows.
            %
            %   obj.setText([], [n1, n2, ...], ___); Set properties for 
            %   the value labels for all rows in the specified columns.
            %
            %   obj.setText(Bool, ___); Set properties for value labels
            %   where the logical matrix Bool is true.

            if ~obj.TxtShown
                [cols, rows] = meshgrid(1:size(obj.Data, 2), 1:size(obj.Data, 1));
                rows = obj.RP(rows);
                cols = obj.CP(cols);
                dataVec = obj.Data(:);
                strCell = cell(size(dataVec));
                valid = ~isnan(dataVec);
                strCell(valid) = cellstr(num2str(dataVec(valid), '%.2f'));
                strCell(~valid) = {''};

                hAll = text(obj.ax, cols(:), rows(:), strCell, ...
                    'FontName', 'Times New Roman', ...
                    'HorizontalAlignment', 'center', ...
                    'Visible', 'off');
                hAll(~valid) = obj.nanTextHdl;
                obj.textHdl = reshape(hAll, size(obj.Data));
                obj.TxtShown = true;
            end

            if isempty(varargin)
                varargin = {'Visible','on'};
            end
            if islogical(varargin{1})
                [M, N] = find(varargin{1});
                for i = 1:length(M)
                    m = M(i); n = N(i);
                    set(obj.textHdl(m, n), varargin{2:end})
                end
            elseif isnumeric(varargin{1})
                M = varargin{1}; N = varargin{2};
                if all(size(M) == size(N))
                    for i = 1:length(M)
                        m = M(i); n = N(i);
                        set(obj.textHdl(m, n), varargin{3:end})
                    end
                else
                    if isempty(M); M = 1:size(obj.Data, 1); end
                    if isempty(N); N = 1:size(obj.Data, 2); end
                    for i = 1:length(M)
                        for j = 1:length(N)
                            m = M(i); n = N(j);
                            set(obj.textHdl(m, n), varargin{3:end})
                        end
                    end
                end
            else
            % Get grayscale of current colormap (获取当前颜色映射的灰度值)
            cmp = get(obj.ax, 'Colormap');
            graymap = mean(cmp, 2);
            climit  = get(obj.ax, 'CLim');
        
            % Loop over all cells (遍历所有单元格)
            for row = 1:size(obj.Data, 1)
                for col = 1:size(obj.Data, 2)
                    % Determine text color (black if background bright, white if dark)
                    % (根据背景亮度决定文字颜色：亮底黑字，暗底白字)
                    if strcmpi(obj.Format, 'txt') || strcmpi(obj.Format, 'text')
                        textColor = interp1(linspace(climit(1), climit(2), size(cmp, 1)), ...
                            cmp, obj.Data(row, col));
                    else
                        bgBrightness = interp1(linspace(climit(1), climit(2), size(graymap, 1)), ...
                            graymap, obj.Data(row, col));
                        if bgBrightness < 0.5
                            textColor = [1, 1, 1];   % white (白色)
                        else
                            textColor = [0, 0, 0];   % black (黑色)
                        end
                    end
                    set(obj.textHdl(row, col), 'Visible','on', 'Color',textColor, varargin{:});
                end
            end
            switch lower(obj.Type)
                case 'triu'      % upper triangle (including diagonal) (上三角，含对角线)
                    for row = 1:size(obj.Data, 1)
                        for col = 1:(row - 1)
                            set(obj.textHdl(row, col), 'Visible','off');
                        end
                    end
                case 'tril'      % lower triangle (including diagonal) (下三角，含对角线)
                    for col = 1:size(obj.Data, 2)
                        for row = 1:(col - 1)
                            set(obj.textHdl(row, col), 'Visible','off');
                        end
                    end
                case {'triu0', 'linku'}     % upper triangle without diagonal (扣除对角线，上三角不含对角线)
                    for row = 1:size(obj.Data, 1)
                        for col = 1:(row)
                            set(obj.textHdl(row, col), 'Visible','off');
                        end
                    end
                case {'tril0', 'linkl'}      % lower triangle without diagonal (扣除对角线，下三角不含对角线)
                    for col = 1:size(obj.Data, 2)
                        for row = 1:(col)
                            set(obj.textHdl(row, col), 'Visible','off');
                        end
                    end
            end
            end
            if nargout == 1
                varargout = {obj};
            end
        end

% =========================================================================
% Set properties for patch handles (设置图形样式)
% =========================================================================
        % 设置图形样式
        function varargout = setPatch(obj, varargin)
            % obj.setPatch(varargin) - Apply properties to all patch objects (and pie backgrounds if applicable)
            % (为所有填充图形设置属性，对饼图类型同时设置背景)
            %
            %   obj.setPatch(___); Set properties for all patch objects.
            %
            %   obj.setPatch(m, n, ___); Set properties for the m‑th row, n-th column patch object.
            %
            %   obj.setPatch([m1, m2, ...], [n1, n2, ...], ___); Set
            %   properties for patch objects by their indices.
            %
            %   obj.setPatch([m1; m2; ...], [n1, n2, ...], ___);
            %   obj.setPatch([m1, m2, ...], [n1; n2; ...], ___); 
            %   Set properties for all combinations when the row-index-vector 
            %   and col-index-vector have different sizes.
            %  
            %   obj.setPatch([m1, m2, ...], [], ___); Set properties for 
            %   the patch objects for all columns in the specified rows.
            %
            %   obj.setPatch([], [n1, n2, ...], ___); Set properties for 
            %   the patch objects for all rows in the specified columns.
            %
            %   obj.setPatch(Bool, ___); Set properties for patch objects
            %   where the logical matrix Bool is true.

            if islogical(varargin{1})
                [M, N] = find(varargin{1});
                for i = 1:length(M)
                    m = M(i); n = N(i);
                    set(obj.patchHdl(m, n), varargin{2:end});
                    if isequal(obj.Format, 'pie') || ...
                       isequal(obj.Format, 'donut') || ...
                       isequal(obj.Format, 'bcirc')
                        set(obj.pieHdl(m, n), varargin{2:end});
                    end
                end
            elseif isnumeric(varargin{1})
                M = varargin{1}; N = varargin{2};
                if all(size(M) == size(N))
                    for i = 1:length(M)
                        m = M(i); n = N(i);
                        set(obj.patchHdl(m, n), varargin{3:end});
                        if isequal(obj.Format, 'pie') || ...
                           isequal(obj.Format, 'donut') || ...
                           isequal(obj.Format, 'bcirc')
                            set(obj.pieHdl(m, n), varargin{3:end});
                        end
                    end
                else
                    if isempty(M); M = 1:size(obj.Data, 1); end
                    if isempty(N); N = 1:size(obj.Data, 2); end
                    for i = 1:length(M)
                        for j = 1:length(N)
                            m = M(i); n = N(j);
                            set(obj.patchHdl(m, n), varargin{3:end});
                            if isequal(obj.Format, 'pie') || ...
                               isequal(obj.Format, 'donut') || ...
                               isequal(obj.Format, 'bcirc')
                                set(obj.pieHdl(m, n), varargin{3:end});
                            end
                        end
                    end
                end
            else
            for row = 1:size(obj.Data, 1)
                for col = 1:size(obj.Data, 2)
                    if ~isnan(obj.Data(row, col))
                        set(obj.patchHdl(row, col), varargin{:});
                        % For pie/donut/bcirc formats, also set the pie background handle
                        % (对于 pie/donut/bcirc 格式，同时设置饼图背景句柄)
                        if isequal(obj.Format, 'pie') || ...
                           isequal(obj.Format, 'donut') || ...
                           isequal(obj.Format, 'bcirc')
                            set(obj.pieHdl(row, col), varargin{:});
                        end
                    end
                end
            end
            end
            if nargout == 1
                varargout = {obj};
            end
        end
        

% =========================================================================
% Set properties for box handle (设置框样式)
% =========================================================================
        function varargout = setBox(obj, varargin)
            % obj.setBox(varargin) - Set properties for box handle (设置框样式)
            set(obj.boxHdl,varargin{:})
            if nargout == 1
                varargout = {obj};
            end
        end
% =========================================================================
% Set properties for frame handle (设置外轮廓样式)
% =========================================================================
        function varargout = setFrame(obj, varargin)
            % obj.setFrame(varargin) - Set properties for frame and tick handle (设置外轮廓样式)
            obj.TickLength(obj.TickLength < 0) = 0;
            obj.TickLength(obj.TickLength > .5) = .5;

            if isempty(obj.RowName)
                obj.RowName = compose('%d', 1:size(obj.Data, 1));
            end
            if isempty(obj.ColName)
                obj.ColName = compose('%d', 1:size(obj.Data, 2));
            end
            obj.ax.XColor = 'none';
            obj.ax.YColor = 'none';
            obj.setRowName(obj.RowName);
            obj.setColName(obj.ColName);

            set(obj.frameHdl, 'Visible','on', varargin{:})
            [M, N] = size(obj.Data);
            switch obj.RowLabelLocation
                case 'left'
                    switch lower(obj.Type)
                        case 'triu'
                            X = nan; Y = nan;
                        case 'tril'
                            X = [.5; .5 - obj.TickLength; nan]*ones(1, M);
                            Y = [1; 1; nan]*obj.RP(1:M);
                        case {'triu0', 'linku'}
                            X = nan; Y = nan;
                        case {'tril0', 'linkl'}
                            X = [.5; .5 - obj.TickLength; nan]*ones(1, M - 1);
                            Y = [1; 1; nan]*obj.RP(2:M);
                        case 'full'
                            X = [.5; .5 - obj.TickLength; nan]*ones(1, M);
                            Y = [1; 1; nan]*obj.RP(1:M);
                    end
                    set(obj.rowTickHdl, 'XData',X(:), 'YData',Y(:), 'Visible','on', varargin{:})
                case 'right'
                    switch lower(obj.Type)
                        case 'triu'
                            X = [obj.CP(end) + .5; obj.CP(end) + .5 + obj.TickLength; nan]*ones(1, M);
                            Y = [1; 1; nan]*obj.RP(1:M);
                        case 'tril'
                            X = nan; Y = nan;
                        case {'triu0', 'linku'}
                            X = [obj.CP(end) + .5; obj.CP(end) + .5 + obj.TickLength; nan]*ones(1, M - 1);
                            Y = [1; 1; nan]*obj.RP(1:(M - 1));
                        case {'tril0', 'linkl'}
                            X = nan; Y = nan;
                        case 'full'
                            X = [obj.CP(end) + .5; obj.CP(end) + .5 + obj.TickLength; nan]*ones(1, M);
                            Y = [1; 1; nan]*obj.RP(1:M);
                    end
                    set(obj.rowTickHdl, 'XData',X(:), 'YData',Y(:), 'Visible','on', varargin{:})
                case 'diag'
                    switch lower(obj.Type)
                        case 'triu'
                            X = [obj.CP(1:M) - .5; obj.CP(1:M) - .5 - obj.TickLength; nan(1, M)];
                            Y = [1; 1; nan]*obj.RP(1:M);
                        case 'tril'
                            X = [obj.CP(1:M) + .5; obj.CP(1:M) + .5 + obj.TickLength; nan(1, M)];
                            Y = [1; 1; nan]*obj.RP(1:M);
                        case {'triu0', 'linku'}
                            X = [obj.CP(2:M) - .5; obj.CP(2:M) - .5 - obj.TickLength; nan(1, M - 1)];
                            Y = [1; 1; nan]*obj.RP(1:(M - 1));
                        case {'tril0', 'linkl'}
                            X = [obj.CP(1:(M - 1)) + .5; obj.CP(1:(M - 1)) + .5 + obj.TickLength; nan(1, M - 1)];
                            Y = [1; 1; nan]*obj.RP(2:M);
                    end
                    set(obj.rowTickHdl, 'XData',X(:), 'YData',Y(:), 'Visible','on', varargin{:})
            end
            switch obj.ColLabelLocation
                case 'top'
                    switch lower(obj.Type)
                        case 'triu'
                            Y = [.5; .5 - obj.TickLength; nan]*ones(1, N);
                            X = [1; 1; nan]*obj.CP(1:N);
                        case 'tril'
                            X = nan; Y = nan;
                        case {'triu0', 'linku'}
                            Y = [.5; .5 - obj.TickLength; nan]*ones(1, N - 1);
                            X = [1; 1; nan]*obj.CP(2:N);
                        case {'tril0', 'linkl'}
                            X = nan; Y = nan;
                        case 'full'
                            Y = [.5; .5 - obj.TickLength; nan]*ones(1, N);
                            X = [1; 1; nan]*obj.CP(1:N);
                    end
                    set(obj.colTickHdl, 'XData',X(:), 'YData',Y(:), 'Visible','on', varargin{:})
                case 'bottom'
                    switch lower(obj.Type)
                        case 'triu'
                            X = nan; Y = nan;
                        case 'tril'
                            Y = [obj.RP(end) + .5; obj.RP(end) + .5 + obj.TickLength; nan]*ones(1, N);
                            X = [1; 1; nan]*obj.CP(1:N);
                        case {'triu0', 'linku'}
                            X = nan; Y = nan;
                        case {'tril0', 'linkl'}
                            Y = [obj.RP(end) + .5; obj.RP(end) + .5 + obj.TickLength; nan]*ones(1, N - 1);
                            X = [1; 1; nan]*obj.CP(1:(N - 1));
                        case 'full'
                            Y = [obj.RP(end) + .5; obj.RP(end) + .5 + obj.TickLength; nan]*ones(1, N);
                            X = [1; 1; nan]*obj.CP(1:N);
                    end
                    set(obj.colTickHdl, 'XData',X(:), 'YData',Y(:), 'Visible','on', varargin{:})
                case 'diag'
                    switch lower(obj.Type)
                        case 'triu'
                            Y = [obj.RP(1:N) + .5; obj.RP(1:N) + .5 + obj.TickLength; nan(1, N)];
                            X = [1; 1; nan]*obj.CP(1:N);
                        case 'tril'
                            Y = [obj.RP(1:N) - .5; obj.RP(1:N) - .5 - obj.TickLength; nan(1, N)];
                            X = [1; 1; nan]*obj.CP(1:N);
                        case {'triu0', 'linku'}
                            Y = [obj.RP(1:(N - 1)) + .5; obj.RP(1:(N - 1)) + .5 + obj.TickLength; nan(1, N - 1)];
                            X = [1; 1; nan]*obj.CP(2:N);
                        case {'tril0', 'linkl'}
                            Y = [obj.RP(2:N) - .5; obj.RP(2:N) - .5 - obj.TickLength; nan(1, N - 1)];
                            X = [1; 1; nan]*obj.CP(1:(N - 1));
                    end
                    set(obj.colTickHdl, 'XData',X(:), 'YData',Y(:), 'Visible','on', varargin{:})
            end

            obj.setRowLabelLocation(obj.RowLabelLocation)
            obj.setColLabelLocation(obj.ColLabelLocation)
            try
                obj.Colorbar.TickLength = .005;
                obj.Colorbar.TickDirection = 'out';
                obj.Colorbar.LineWidth = obj.frameHdl.LineWidth;
            catch
            end

            if nargout == 1
                varargout = {obj};
            end
        end
% =========================================================================
% Set triangular type (设置三角样式)
% =========================================================================
        function varargout = setType(obj, Type)
            % obj.setType(Type) - Adjust display to show only triangular part of the matrix based on Type
            % (根据类型调整显示，仅展示矩阵的三角部分)
            %
            % Type:
            %   'triu'   : upper triangle (including diagonal) : 上三角部分 (含对角线)
            %   'tril'   : lower triangle (including diagonal) : 下三角部分 (含对角线)
            %   'triu0'  : upper triangle without diagonal     : 扣除对角线上三角部分 (不含对角线)
            %   'tril0'  : lower triangle without diagonal     : 扣除对角线下三角部分 (不含对角线)
            %   'linkl'  : lower triangle for mantel links     : 适配 mantel 链接的下三角
            %   'linku'  : upper triangle for mantel links     : 适配 mantel 链接的上三角
        
            % mustBeAllowedTriType(Type)

            % Only apply if matrix is square (仅当矩阵为方阵时生效)
            if size(obj.Data, 1) == size(obj.Data, 2) && isequal(obj.RowGroup, obj.ColGroup)
        
                obj.Type = Type;
                

                % Hide axes labels and adjust axis location (隐藏坐标轴标签，调整轴位置)
                obj.ax.XColor = 'none';
                obj.ax.YColor = 'none';
                obj.ax.YAxisLocation = 'right';

                obj.RowName = obj.VarName;
                obj.ColName = obj.VarName;
             
                % Show all row and column labels initially (初始显示所有行/列标签)
                for n = 1:size(obj.Data, 1)
                    set(obj.rowLabelHdl(n), 'Visible', 'on');
                    set(obj.colLabelHdl(n), 'Visible', 'on');
                end

                if strcmpi(obj.Type, 'triu') || strcmpi(obj.Type, 'triu0')
                    obj.RowLabelLocation = 'diag';
                    obj.ColLabelLocation = 'top';
                end
                if strcmpi(obj.Type, 'tril') || strcmpi(obj.Type, 'tril0')
                    obj.RowLabelLocation = 'left';
                    obj.ColLabelLocation = 'diag';
                end
                if strcmpi(obj.Type, 'linku')
                    obj.RowLabelLocation = 'right';
                    obj.ColLabelLocation = 'top';
                end
                if strcmpi(obj.Type, 'linkl') 
                    obj.RowLabelLocation = 'left';
                    obj.ColLabelLocation = 'bottom';
                end
        
                % Apply specific triangular type (应用特定三角类型)
                %   'triu'   : upper triangle (including diagonal) : 上三角部分 (含对角线)
                %   'tril'   : lower triangle (including diagonal) : 下三角部分 (含对角线)
                %   'triu0'  : upper triangle without diagonal     : 扣除对角线上三角部分 (不含对角线)
                %   'tril0'  : lower triangle without diagonal     : 扣除对角线下三角部分 (不含对角线)
                %   'linkl'  : lower triangle for mantel links     : 适配 mantel 链接的下三角
                %   'linku'  : upper triangle for mantel links     : 适配 mantel 链接的上三角
                switch lower(obj.Type)
                    case 'triu'   % upper triangle (including diagonal) (上三角含对角线)
                        % Hide lower-left patches/texts (隐藏左下部分图形和文本)
                        for row = 1:size(obj.Data, 1)
                            for col = 1:(row - 1)
                                if ~(strcmpi(obj.Format,'txt') || strcmpi(obj.Format,'text'))
                                    set(obj.patchHdl(row, col), 'Visible', 'off');
                                end
                                if ~isempty(obj.textHdl)
                                    set(obj.textHdl(row, col),  'Visible', 'off');
                                end
                                if strcmpi(obj.Format, 'pie') || ...
                                   strcmpi(obj.Format, 'donut') || ...
                                   strcmpi(obj.Format, 'bcirc')
                                    set(obj.pieHdl(row, col), 'Visible', 'off');
                                end
                            end
                        end
                    case 'tril'   % lower triangle (including diagonal) (下三角含对角线)
                        % Hide upper-right patches/texts (隐藏右上部分图形和文本)
                        for col = 1:size(obj.Data, 2)
                            for row = 1:(col - 1)
                                if ~(strcmpi(obj.Format,'txt') || strcmpi(obj.Format,'text'))
                                    set(obj.patchHdl(row, col), 'Visible', 'off');
                                end
                                if ~isempty(obj.textHdl)
                                    set(obj.textHdl(row, col),  'Visible', 'off');
                                end
                                if strcmpi(obj.Format, 'pie') || ...
                                   strcmpi(obj.Format, 'donut') || ...
                                   strcmpi(obj.Format, 'bcirc')
                                    set(obj.pieHdl(row, col), 'Visible', 'off');
                                end
                            end
                        end
                    case {'triu0', 'linku'}  % upper triangle without diagonal (扣除对角线，上三角不含对角线)
                        % Hide diagonal and lower-left patches/texts (隐藏对角线及左下部分)
                        for row = 1:size(obj.Data, 1)
                            for col = 1:(row)
                                if ~(strcmpi(obj.Format,'txt') || strcmpi(obj.Format,'text'))
                                    set(obj.patchHdl(row, col), 'Visible', 'off');
                                end
                                if ~isempty(obj.textHdl)
                                    set(obj.textHdl(row, col),  'Visible', 'off');
                                end
                                if strcmpi(obj.Format, 'pie') || ...
                                   strcmpi(obj.Format, 'donut') || ...
                                   strcmpi(obj.Format, 'bcirc')
                                    set(obj.pieHdl(row, col), 'Visible', 'off');
                                end
                            end
                        end
                        set(obj.colLabelHdl(1), 'Visible', 'off');
                        set(obj.rowLabelHdl(size(obj.Data, 1)), 'Visible', 'off');
                    case {'tril0', 'linkl'}  % lower triangle without diagonal (扣除对角线，下三角不含对角线)
                        % Hide diagonal and upper-right patches/texts (隐藏对角线及右上部分)
                        for col = 1:size(obj.Data, 2)
                            for row = 1:(col)
                                if ~(strcmpi(obj.Format,'txt') || strcmpi(obj.Format,'text'))
                                    set(obj.patchHdl(row, col), 'Visible', 'off');
                                end
                                if ~isempty(obj.textHdl)
                                    set(obj.textHdl(row, col),  'Visible', 'off');
                                end
                                if strcmpi(obj.Format, 'pie') || ...
                                   strcmpi(obj.Format, 'donut') || ...
                                   strcmpi(obj.Format, 'bcirc')
                                    set(obj.pieHdl(row, col), 'Visible', 'off');
                                end
                            end
                        end
                        set(obj.rowLabelHdl(1), 'Visible', 'off');
                        set(obj.colLabelHdl(size(obj.Data, 2)), 'Visible', 'off');
                end
            

            if strcmpi(obj.Type, 'linkl')
                for n = 1:size(obj.Data, 1)
                    set(obj.rowLabelHdl(n), 'Visible', 'on');
                    set(obj.colLabelHdl(n), 'Visible', 'on');
                end
                delete(obj.Colorbar)
            end

            if strcmpi(obj.Type, 'linku')
                for n = 1:size(obj.Data, 1)
                    set(obj.rowLabelHdl(n), 'Visible', 'on');
                    set(obj.colLabelHdl(n), 'Visible', 'on');
                end
                delete(obj.Colorbar)
            end
            obj.setRowLabelLocation(obj.RowLabelLocation);
            obj.setColLabelLocation(obj.ColLabelLocation);

            obj.GX = []; obj.GY = [];
            for gi = 1:max(obj.RowGroup)
                for gj = 1:max(obj.ColGroup)
                    posi = obj.RP(obj.RowGroup == gi);
                    posj = obj.CP(obj.ColGroup == gj); 
                    M = length(posi);
                    N = length(posj);
                    switch lower(obj.Type)
                        case 'triu'
                            if gi == gj
                                bX1 = [1; 1; nan]*[posj(1) - .5, posj + .5];
                                bY1 = [(posi(1) - .5).*ones(1, N + 1);
                                        posi + .5, posi(end) + .5;
                                        nan(1, N + 1)];
                                bX2 = [(posj(end) + .5).*ones(1, N + 1);
                                        posj(1) - .5, posj - .5;
                                        nan(1, N + 1)];
                                bY2 = [1; 1; nan]*[posi(1) - .5, posi + .5];
                                obj.GX = [obj.GX; bX1(:); bX2(:)];
                                obj.GY = [obj.GY; bY1(:); bY2(:)];
                            elseif gj > gi
                                bX1 = [1; 1; nan]*[posj(1) - .5, posj + .5];
                                bY1 = [posi(1) - .5; posi(end) + .5; nan]*ones(1, N + 1);
                                bX2 = [posj(1) - .5; posj(end) + .5; nan]*ones(1, M + 1);
                                bY2 = [1; 1; nan]*[posi(1) - .5, posi + .5];
                                obj.GX = [obj.GX; bX1(:); bX2(:)];
                                obj.GY = [obj.GY; bY1(:); bY2(:)];
                            end
                        case 'tril'
                            if gi == gj
                                bX1 = [1; 1; nan]*[posj(1) - .5, posj + .5];
                                bY1 = [(posi(end) + .5).*ones(1, N + 1);
                                        posi(1) - .5, posi - .5;
                                        nan(1, N + 1)];
                                bX2 = [(posj(1) - .5).*ones(1, N + 1);
                                        posj + .5, posj(end) + .5;
                                        nan(1, N + 1)];
                                bY2 = [1; 1; nan]*[posi(1) - .5, posi + .5];
                                obj.GX = [obj.GX; bX1(:); bX2(:)];
                                obj.GY = [obj.GY; bY1(:); bY2(:)];
                            elseif gj < gi
                                bX1 = [1; 1; nan]*[posj(1) - .5, posj + .5];
                                bY1 = [posi(1) - .5; posi(end) + .5; nan]*ones(1, N + 1);
                                bX2 = [posj(1) - .5; posj(end) + .5; nan]*ones(1, M + 1);
                                bY2 = [1; 1; nan]*[posi(1) - .5, posi + .5];
                                obj.GX = [obj.GX; bX1(:); bX2(:)];
                                obj.GY = [obj.GY; bY1(:); bY2(:)];
                            end
                        case {'triu0', 'linku'}
                            if gi == gj && length(posi) > 1
                                bX1 = [1; 1; nan]*(posj + .5);
                                bY1 = [(posi(1) - .5).*ones(1, N);
                                        posi(1:(end - 1)) + .5, posi(end) - .5;
                                        nan(1, N)];
                                bX2 = [(posj(end) + .5).*ones(1, N);
                                        posj(1) + .5, posj(2:end) - .5;
                                        nan(1, N)];
                                bY2 = [1; 1; nan]*(posj - .5);
                                obj.GX = [obj.GX; bX1(:); bX2(:)];
                                obj.GY = [obj.GY; bY1(:); bY2(:)];
                            elseif gj > gi
                                bX1 = [1; 1; nan]*[posj(1) - .5, posj + .5];
                                bY1 = [posi(1) - .5; posi(end) + .5; nan]*ones(1, N + 1);
                                bX2 = [posj(1) - .5; posj(end) + .5; nan]*ones(1, M + 1);
                                bY2 = [1; 1; nan]*[posi(1) - .5, posi + .5];
                                obj.GX = [obj.GX; bX1(:); bX2(:)];
                                obj.GY = [obj.GY; bY1(:); bY2(:)];
                            end
                        case {'tril0', 'linkl'}
                            if gi == gj && length(posi) > 1
                                bX1 = [1; 1; nan]*(posj - .5);
                                bY1 = [(posi(end) + .5).*ones(1, N);
                                        posi(1) + .5, posi(2:end) - .5;
                                        nan(1, N)];
                                bX2 = [(posj(1) - .5).*ones(1, N);
                                        posj(1:(end - 1)) + .5, posj(end) - .5;
                                        nan(1, N)];
                                bY2 = [1; 1; nan]*(posi + .5);
                                obj.GX = [obj.GX; bX1(:); bX2(:)];
                                obj.GY = [obj.GY; bY1(:); bY2(:)];
                            elseif gj < gi
                                bX1 = [1; 1; nan]*[posj(1) - .5, posj + .5];
                                bY1 = [posi(1) - .5; posi(end) + .5; nan]*ones(1, N + 1);
                                bX2 = [posj(1) - .5; posj(end) + .5; nan]*ones(1, M + 1);
                                bY2 = [1; 1; nan]*[posi(1) - .5, posi + .5];
                                obj.GX = [obj.GX; bX1(:); bX2(:)];
                                obj.GY = [obj.GY; bY1(:); bY2(:)];
                            end
                    end
                end
            end
            set(obj.boxHdl, 'XData',obj.GX, 'YData',obj.GY)

            obj.FX = []; obj.FY = [];
            for gi = 1:max(obj.RowGroup)
                for gj = 1:max(obj.ColGroup)
                    posi = obj.RP(obj.RowGroup == gi);
                    posj = obj.CP(obj.ColGroup == gj);
                    M = max(posi); m = min(posi) - 1;
                    N = max(posj); n = min(posj) - 1;
                    X2 = reshape([1; 1]*(posj - 1), 1, []);
                    Y2 = reshape([1; 1]*(posi - 1), 1, []);
                    switch lower(obj.Type)
                        case 'triu'
                            if gi == gj
                                X = [X2, N, N, n, n] + .5;
                                Y = [Y2(2:end), M, M, m, m, m + 1] +.5;
                                obj.FX = [obj.FX, X, nan]; obj.FY = [obj.FY, Y, nan];
                            elseif gj > gi
                                X = [n, N, N, n, n, N] + .5;
                                Y = [m, m, M, M, m, m] + .5;
                                obj.FX = [obj.FX, X, nan]; obj.FY = [obj.FY, Y, nan];
                            end
                        case 'tril'
                            if gi == gj
                                X = [X2(2:end), N, N, n, n, n + 1] + .5;
                                Y = [Y2, M, M, m, m] + .5;
                                obj.FX = [obj.FX, X, nan]; obj.FY = [obj.FY, Y, nan];
                            elseif gj < gi
                                X = [n, N, N, n, n, N] + .5;
                                Y = [m, m, M, M, m, m] + .5;
                                obj.FX = [obj.FX, X, nan]; obj.FY = [obj.FY, Y, nan];
                            end
                        case {'triu0', 'linku'}
                            if gi == gj && length(X2) > 2
                                X = [X2(3:end), N, N, n + 1, n + 1] + .5;
                                Y = [Y2(2:end-2), M - 1, M - 1, m, m, m + 1] +.5;
                                obj.FX = [obj.FX, X, nan];
                                obj.FY = [obj.FY, Y, nan];
                            elseif gj > gi
                                X = [n, N, N, n, n, N] + .5;
                                Y = [m, m, M, M, m, m] + .5;
                                obj.FX = [obj.FX, X, nan]; obj.FY = [obj.FY, Y, nan];
                            end
                        case {'tril0', 'linkl'}
                            if gi == gj && length(X2) > 2
                                X = [X2(2:end-2), N - 1, N - 1, n, n, n + 1] +.5;
                                Y = [Y2(3:end), M, M, m + 1, m + 1] + .5;
                                obj.FX = [obj.FX, X, nan]; obj.FY = [obj.FY, Y, nan];
                            elseif gj < gi
                                X = [n, N, N, n, n, N] + .5;
                                Y = [m, m, M, M, m, m] + .5;
                                obj.FX = [obj.FX, X, nan]; obj.FY = [obj.FY, Y, nan];
                            end
                    end
                end
            end
            set(obj.frameHdl, 'XData',obj.FX, 'YData',obj.FY)
            else
                obj.Type = 'full';
            end
            if nargout == 1
                varargout = {obj};
            end
        end

% =========================================================================
% 设置变量标签 (Set variable labels)
% =========================================================================
        function varargout = setVarName(obj, VarName)
            % obj.setVarName(VarName) - Assign variable names to rows and columns (cyclically if fewer names than size)
            % (为行和列分配变量名，若名称数量少于维度则循环使用)       
            obj.ax.XColor = 'none';
            obj.ax.YColor = 'none';
            obj.VarName = VarName;
            obj.RowName = VarName;
            obj.ColName = VarName;
            VarNameLen = length(obj.VarName);
            for n = 1:size(obj.Data, 1)
                % Apply names cyclically (循环应用名称)
                idx = mod(n - 1, VarNameLen) + 1;
                set(obj.rowLabelHdl(n), 'String', obj.VarName{idx});
                set(obj.colLabelHdl(n), 'String', obj.VarName{idx});
                if strcmpi(obj.Type, 'full')
                    set(obj.rowLabelHdl(n), 'Visible','on')
                    set(obj.colLabelHdl(n), 'Visible','on')
                end
            end
            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setRowName(obj, RowName)
            % obj.setRowName(RowName) - Assign variable names to rows (cyclically if fewer names than size)
            % (为列分配变量名，若名称数量少于维度则循环使用)
            obj.ax.YColor = 'none';
            obj.RowName = RowName;
            RowNameLen = length(obj.RowName);
            for i = 1:size(obj.Data, 1)
                % Apply names cyclically (循环应用名称)
                idx = mod(i - 1, RowNameLen) + 1;
                set(obj.rowLabelHdl(i), 'String', obj.RowName{idx});
                if strcmpi(obj.Type, 'full')
                    set(obj.rowLabelHdl(i), 'Visible','on')
                end
            end
            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setColName(obj, ColName)
            % obj.setColName(ColName) - Assign variable names to cols (cyclically if fewer names than size)
            % (为行分配变量名，若名称数量少于维度则循环使用)
            obj.ax.XColor = 'none';
            obj.ColName = ColName;
            ColNameLen = length(obj.ColName);
            for j = 1:size(obj.Data, 2)
                % Apply names cyclically (循环应用名称)
                idx = mod(j - 1, ColNameLen) + 1;
                set(obj.colLabelHdl(j), 'String', obj.ColName{idx});
                if strcmpi(obj.Type, 'full')
                    set(obj.colLabelHdl(j), 'Visible','on')
                end
            end
            if nargout == 1
                varargout = {obj};
            end
        end
        
        function varargout = setRowLabel(obj, varargin)
            % obj.setRowLabel(varargin) - Set properties for all row label text objects (设置所有行标签的属性)
            for n = 1:size(obj.Data, 1)
                set(obj.rowLabelHdl(n), varargin{:});
            end
            if nargout == 1
                varargout = {obj};
            end
        end
        
        function varargout = setColLabel(obj, varargin)
            % obj.setColLabel(varargin) - Set properties for all col label text objects (设置所有列标签的属性)
            for n = 1:size(obj.Data, 2)
                set(obj.colLabelHdl(n), varargin{:});
            end
            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setRowLabelLocation(obj, loc)
            % obj.setRowLabelLocation(loc) - Move row labels to 
            % specified location (设置行标签位置)
            %
            % loc can be:
            %   'left'  - aligned to the left side of the first column
            %   'right' - aligned to the right side of the last column
            %   'diag'  - placed along the diagonal

            % mustBeAllowedRowLabelLocation(obj.RowLabelLocation)

            if ~strcmpi(obj.RowLabelLocation, loc)
                obj.RowLabelLocation = loc;
            end
            obj.TickLength(obj.TickLength < 0) = 0;
            obj.TickLength(obj.TickLength > .5) = .5;

            % 'left'/'right'/'diag'
            for n = 1:size(obj.Data, 1)
                switch loc
                    case 'left'
                        set(obj.rowLabelHdl(n), 'Position',[.25, obj.RP(n), 0], 'HorizontalAlignment','right')
                        if strcmpi(obj.rowTickHdl.Visible, 'on')
                            set(obj.rowLabelHdl(n), 'Position',[.25 - obj.TickLength, obj.RP(n), 0])
                        end
                    case 'right'
                        set(obj.rowLabelHdl(n), 'Position',[obj.CP(end) + .75, obj.RP(n), 0], 'HorizontalAlignment','left')
                        if strcmpi(obj.rowTickHdl.Visible, 'on')
                            set(obj.rowLabelHdl(n), 'Position',[obj.CP(end) + .75 + obj.TickLength, obj.RP(n), 0])
                        end
                    case 'diag'
                        switch obj.Type
                            case 'tril'
                                set(obj.rowLabelHdl(n), 'Position',[.75 + obj.CP(n), obj.RP(n), 0], 'HorizontalAlignment','left')
                                if strcmpi(obj.rowTickHdl.Visible, 'on')
                                    set(obj.rowLabelHdl(n), 'Position',[.75 + obj.CP(n) + obj.TickLength, obj.RP(n), 0])
                                end
                            case {'tril0','linkl'}
                                set(obj.rowLabelHdl(n), 'Position',[.75 + obj.CP(max(1, n - 1)), obj.RP(n), 0], 'HorizontalAlignment','left')
                                if strcmpi(obj.rowTickHdl.Visible, 'on')
                                    set(obj.rowLabelHdl(n), 'Position',[.75 + obj.CP(max(1, n - 1)) + obj.TickLength, obj.RP(n), 0])
                                end
                            case 'triu'
                                set(obj.rowLabelHdl(n), 'Position',[.25 - 1 + obj.CP(n), obj.RP(n), 0], 'HorizontalAlignment','right')
                                if strcmpi(obj.rowTickHdl.Visible, 'on')
                                    set(obj.rowLabelHdl(n), 'Position',[.25 - 1 + obj.CP(n) - obj.TickLength, obj.RP(n), 0])
                                end
                            case {'triu0','linku'}
                                set(obj.rowLabelHdl(n), 'Position',[-.75 + obj.CP(min(n + 1, length(obj.CP))), obj.RP(n), 0], 'HorizontalAlignment','right')
                                if strcmpi(obj.rowTickHdl.Visible, 'on')
                                    set(obj.rowLabelHdl(n), 'Position',[-.75 + obj.CP(min(n + 1, length(obj.CP))) - obj.TickLength, obj.RP(n), 0])
                                end
                        end
                end
            end
            if strcmpi(obj.rowTickHdl.Visible, 'on')
                switch loc
                    case 'left'
                        obj.ax.XLim(1) = min(obj.ax.XLim(1), .5 - obj.TickLength);
                    case 'right'
                        obj.ax.XLim(2) = max(obj.ax.XLim(2), obj.CP(end) + .5 + obj.TickLength);
                    case 'diag'
                        switch lower(obj.Type)
                            case 'tril'
                                obj.ax.XLim(2) = max(obj.ax.XLim(2), obj.CP(end) + .5 + obj.TickLength);
                            case 'triu'
                                obj.ax.XLim(1) = min(obj.ax.XLim(1), .5 - obj.TickLength);
                        end
                end
            end
            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setColLabelLocation(obj, loc)
            % obj.setColLabelLocation(loc) - Move col labels to
            % specified location (设置列标签位置)
            %
            % loc can be:
            %   'top'    - aligned above the first row
            %   'bottom' - aligned below the last row
            %   'diag'   - placed along the diagonal

            % mustBeAllowedColLabelLocation(obj.ColLabelLocation)

            if ~strcmpi(obj.ColLabelLocation, loc)
                obj.ColLabelLocation = loc;
            end
            obj.TickLength(obj.TickLength < 0) = 0;
            obj.TickLength(obj.TickLength > .5) = .5;

            % 'top'/'bottom'/'diag
            for n = 1:size(obj.Data, 2)
            switch loc
                case 'top'
                    set(obj.colLabelHdl(n), 'Position',[obj.CP(n), .25, 0], 'HorizontalAlignment','left')
                    if strcmpi(obj.colTickHdl.Visible, 'on')
                        set(obj.colLabelHdl(n), 'Position',[obj.CP(n), .25 - obj.TickLength, 0])
                    end
                case 'bottom'
                    set(obj.colLabelHdl(n), 'Position',[obj.CP(n), obj.RP(end) + .75, 0], 'HorizontalAlignment','right')
                    if strcmpi(obj.colTickHdl.Visible, 'on')
                        set(obj.colLabelHdl(n), 'Position',[obj.CP(n), obj.RP(end) + .75 + obj.TickLength, 0])
                    end
                case 'diag'
                    switch lower(obj.Type)
                        case 'tril'
                            set(obj.colLabelHdl(n), 'Position',[obj.CP(n), .25 - 1 + obj.RP(n), 0], 'HorizontalAlignment','left')
                            if strcmpi(obj.colTickHdl.Visible, 'on')
                                set(obj.colLabelHdl(n), 'Position',[obj.CP(n), .25 - 1 + obj.RP(n) - obj.TickLength, 0])
                            end
                        case {'tril0','linkl'}
                            set(obj.colLabelHdl(n), 'Position',[obj.CP(n), obj.RP(min(n + 1, length(obj.RP))) - .75, 0], 'HorizontalAlignment','left')
                            if strcmpi(obj.colTickHdl.Visible, 'on')
                                set(obj.colLabelHdl(n), 'Position',[obj.CP(n), obj.RP(min(n + 1, length(obj.RP))) - .75 - obj.TickLength, 0])
                            end
                        case 'triu'
                            set(obj.colLabelHdl(n), 'Position',[obj.CP(n), obj.RP(n) - .25 + 1, 0], 'HorizontalAlignment','right')
                            if strcmpi(obj.colTickHdl.Visible, 'on')
                                set(obj.colLabelHdl(n), 'Position',[obj.CP(n), obj.RP(n) - .25 + 1 + obj.TickLength, 0])
                            end
                        case {'triu0','linku'}
                            set(obj.colLabelHdl(n), 'Position',[obj.CP(n), obj.RP(max(1, n - 1)) + .75, 0], 'HorizontalAlignment','right')
                            if strcmpi(obj.colTickHdl.Visible, 'on')
                                set(obj.colLabelHdl(n), 'Position',[obj.CP(n), obj.RP(max(1, n - 1)) + .75 + obj.TickLength, 0])
                            end
                    end
            end
            end
            if strcmpi(obj.colTickHdl.Visible, 'on')
                switch loc
                    case 'top'
                        obj.ax.YLim(1) = min(obj.ax.YLim(1), .5 - obj.TickLength);
                    case 'bottom'
                        obj.ax.YLim(2) = max(obj.ax.YLim(2), obj.RP(end) + .5 + obj.TickLength);
                    case 'diag'
                        switch lower(obj.Type)
                            case 'tril'
                                obj.ax.YLim(1) = min(obj.ax.YLim(1), .5 - obj.TickLength);
                            case 'triu'
                                obj.ax.YLim(2) = max(obj.ax.YLim(2), obj.RP(end) + .5 + obj.TickLength);
                        end

                end
            end
            if nargout == 1
                varargout = {obj};
            end
        end

% =========================================================================
% 自定义文本格式 (Custom text formatting)
% =========================================================================
% 2023-05-28 更新
        function varargout = setTextFormat(obj, func)
            % obj.setTextFormat(func) - Apply a custom formatting function to all value labels (对数值标签应用自定义格式化函数)
            %
            %   func : function handle that takes a numeric value and returns a string
            %          (函数句柄，接受数值并返回字符串)
        
            for row = 1:size(obj.Data, 1)
                for col = 1:size(obj.Data, 2)
                    if ~isnan(obj.Data(row, col))
                        tStr = func(obj.Data(row, col));
                        set(obj.textHdl(row, col), 'String', tStr);
                    end
                end
            end
            if nargout == 1
                varargout = {obj};
            end
        end

% =========================================================================
% Freeze colormap to data values (冻结颜色映射)
% =========================================================================
% 2025-12-01 更新
        function varargout = freezeColors(obj)
            % obj.freezeColors() - Permanently assign the current colormap colors to each patch 
            % based on its value, decoupling them from both the colormap axis limits (CLim) and the colormap itself.
            % (根据当前数值将颜色映射固定到每个填充图形，使其不再随颜色轴范围或颜色映射表的变化而改变)
        
            climit = get(obj.ax, 'CLim');
            cmap   = get(obj.ax, 'Colormap');
            % Create bin edges for quantizing data values to colormap indices
            % (创建分箱边界，将数据值量化到颜色映射索引)
            values = linspace(climit(1), climit(2), size(cmap, 1) + 1);
        
            for row = 1:size(obj.Data, 1)
                for col = 1:size(obj.Data, 2)
                    % Find which color bin the value falls into (确定数值落在哪个颜色分箱)
                    tind = sum(obj.Data(row, col) >= values);
                    tind(tind <= 0) = 1;
                    tind(tind > size(cmap, 1)) = size(cmap, 1);
                    % Apply the fixed color (应用固定颜色)
                    set(obj.patchHdl(row, col), 'FaceColor', cmap(tind, :));
                end
            end
        
            % Update colorbar to reflect the fixed colormap and limits
            % (更新颜色条以反映固定的颜色映射和范围)
            obj.Colorbar.Colormap = cmap;
            obj.Colorbar.Limits   = climit;
            % Slightly shift colorbar position to avoid overlap (微调颜色条位置避免重叠)
            obj.Colorbar.Position = obj.Colorbar.Position + [0.03, 0, 0, 0];

            if nargout == 1
                varargout = {obj};
            end
        end

% =========================================================================
% Display significance stars (显示显著性星标)
% =========================================================================
        function varargout = showStars(obj, pval, varargin)
            % obj.showStars(pval, varargin) - Overlay significance stars 
            % on value labels based on p-values (根据 p 值在数值标签上叠加显著性星标)
            %
            %   obj.showStars(pval);
            %       Overlays stars (*, **, ***, ****) onto each existing text label according
            %       to the p-value in the corresponding cell. The default significance levels
            %       are [0.05, 0.01, 0.001], producing '*', '**', '***', and '****' for
            %       p < 0.0001.
            %
            %   obj.showStars(pval, 'Levels', levels, ___);
            %       Specifies custom significance thresholds. levels must be a strictly
            %       increasing numeric vector (e.g., [0.05, 0.01]). The number of stars
            %       equals the number of thresholds that the p-value is below.
            %
            %   obj.showStars(pval, 'CorrLabel', 'off', ___);
            %       By default ('on'), the original label text is kept and stars are added
            %       as a superscript (or below, depending on implementation). When set to
            %       'off', the original text is completely replaced by the star string.
            %
            % Parameters:
            %    pval       : matrix of p-values corresponding to each data cell (p 值矩阵)
            %   'Levels'    : significance thresholds, default [0.05, 0.01, 0.001] (显著性阈值)
            %   'CorrLabel' : 'on' to keep original text below stars, 'off' to replace (是否保留原文本)
        
            % Default options (默认选项)
            starobj.Levels = [0.05, 0.01, 0.001];
            starobj.CorrLabel = 'on';
            vararginList2 = {'Levels', 'CorrLabel'};
        
            % Parse optional input arguments (解析可选输入参数)
            for i = 1:2:(length(varargin) - 1)
                tid = ismember(lower(vararginList2), lower(varargin{i}));
                if any(tid)
                    starobj.(vararginList2{tid}) = varargin{i + 1};
                end
            end
            for row = 1:size(obj.Data, 1)
                for col = 1:size(obj.Data, 2)
                    if ~isnan(obj.Data(row, col))
                        if strcmp(starobj.CorrLabel, 'on')
                            % Keep original text and prepend stars in a cell array (保留原文本，星标在上)
                            tStr = get(obj.textHdl(row, col), 'String');
                            set(obj.textHdl(row, col), 'String', ...
                                {obj.pval2stars(pval(row, col), starobj.Levels); tStr});
                        else
                            % Replace text with stars only (仅显示星标)
                            set(obj.textHdl(row, col), 'String', ...
                                obj.pval2stars(pval(row, col), starobj.Levels));
                        end
                    end
                end
            end
            if nargout == 1
                varargout = {obj};
            end
        end

        function stars = pval2stars(~, pval, levels)
            % pval2stars - Convert p-values to significance stars
            %   stars = obj.pval2stars(pval) returns significance stars:
            %       p < 0.05   -> '*'
            %       p < 0.01   -> '**'
            %       p < 0.001  -> '***'
            %
            %   stars = obj.pval2stars(pval, levels) custom significance thresholds
            %       levels = [0.05, 0.01, 0.001] (default)
            %
            % Examples:
            %   obj.pval2stars(0.03)   % returns '*'
            %   obj.pval2stars(0.003)  % returns '***'

            if nargin < 2
                levels = [0.05, 0.01, 0.001];
            end

            % Generate asterisk string based on significance level
            stars = repmat('*', 1, sum(pval < levels));
        end
    end
% =========================================================================
% Set XLim YLim and TLim (设置 X,Y,Theta 范围)
% =========================================================================
% When TLim(1) == TLim(2), the heatmap is rotated without shape distortion (仅旋转不形变)
% When TLim(1) ~= TLim(2), an annular heatmap is generated (形成环形热图)

% The setType function should not be called after this function.
% (请勿在此函数使用后调用 setType 函数)

    methods
        function varargout = setXYTLim(obj, varargin)
            % obj.setXYTLim(varargin) - Set X, Y, and Theta limits for the heatmap (设置热图 X轴、 Y轴、角度范围)
            %   obj.setXYTLim('XLim', [xmin, xmax], 'YLim', [ymin, ymax], 'TLim', [tmin, tmax])
            %       TLim(1) == TLim(2): rotation without deformation (rectangular shape preserved)
            %       TLim(1) ~= TLim(2): annular/sector heatmap generated
            %       Do NOT call setType after this function, as it may override the current XYT Lim.

            tArginList = {'XLim', 'YLim', 'TLim'};
            for i = 1:2:(length(varargin) - 1)
                tid = ismember(lower(tArginList), lower(varargin{i}));
                if any(tid)
                    obj.(tArginList{tid}) = varargin{i + 1};
                end
            end
            obj.setFrame()
            OXLim = [obj.CP(1) - .5, obj.CP(end) + .5];
            OYLim = [obj.RP(1) - .5, obj.RP(end) + .5];

            if (abs(diff(obj.TLim)) < eps && (strcmpi(obj.Format, 'sq') || ...
                    strcmpi(obj.Format, 'asq') || ...
                    strcmpi(obj.Format, 'circ') || ...
                    strcmpi(obj.Format, 'acirc') || ...
                    strcmpi(obj.Format, 'bcirc'))) || ...
                    (strcmpi(obj.Type, 'full') && strcmpi(obj.Format, 'sq'))

                if obj.TLim(1) ~= 0 || obj.TLim(2) ~= 0
                    obj.ax.DataAspectRatio = [1,1,1];
                end

                tLen = max(1./diff(OXLim).*diff(obj.XLim), 1./diff(OYLim).*diff(obj.YLim));

                obj.XLim = sort(obj.XLim);
                obj.YLim = sort(obj.YLim);
                % obj.TLim = sort(obj.TLim);

                if abs(diff(obj.XLim)) < eps
                    obj.XLim = [obj.CP(1) - .5, obj.CP(end) + .5];
                end
                if abs(diff(obj.YLim)) < eps
                    obj.YLim = [obj.RP(1) - .5, obj.RP(end) + .5];
                end

                X = obj.boxHdl.XData; Y = obj.boxHdl.YData;
                [nX, nY] = getNewXY(X, Y, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                obj.boxHdl.XData = nX; obj.boxHdl.YData = nY;

                X = obj.frameHdl.XData; Y = obj.frameHdl.YData;
                [nX, nY] = getNewXY(X, Y, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                obj.frameHdl.XData = nX; obj.frameHdl.YData = nY;

                X = obj.rowTickHdl.XData; Y = obj.rowTickHdl.YData;
                [nX, nY] = getNewXY(X, Y, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                nX = reshape(nX, 3, []); nY = reshape(nY, 3, []);
                tRowX = nX(1, :); tRowY = nY(1, :);
                if obj.TickLength > 0
                    nV = [nX(2, :) - nX(1, :); nY(2, :) - nY(1, :)];
                    nL = sqrt(nV(1, :).^2 + nV(2, :).^2);
                    nV = nV./[nL; nL];
                    nX(2, :) = nX(1, :) + nV(1, :).*obj.TickLength.*tLen;
                    nY(2, :) = nY(1, :) + nV(2, :).*obj.TickLength.*tLen;
                end
                obj.rowTickHdl.XData = nX(:); obj.rowTickHdl.YData = nY(:);

                X = obj.colTickHdl.XData; Y = obj.colTickHdl.YData;
                [nX, nY] = getNewXY(X, Y, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                nX = reshape(nX, 3, []); nY = reshape(nY, 3, []);
                tColX = nX(1, :); tColY = nY(1, :);
                if obj.TickLength > 0
                    nV = [nX(2, :) - nX(1, :); nY(2, :) - nY(1, :)];
                    nL = sqrt(nV(1, :).^2 + nV(2, :).^2);
                    nV = nV./[nL; nL];
                    nX(2, :) = nX(1, :) + nV(1, :).*obj.TickLength.*tLen;
                    nY(2, :) = nY(1, :) + nV(2, :).*obj.TickLength.*tLen;
                end
                obj.colTickHdl.XData = nX(:); obj.colTickHdl.YData = nY(:);

                if ~isempty(obj.PatchX)
                    [nX, nY] = getNewXY(obj.PatchX, obj.PatchY, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                    for i = 1:size(obj.patchHdl, 1)
                        for j = 1:size(obj.patchHdl, 2)
                            n = sub2ind(size(obj.Data), i, j);
                            if isnan(obj.Data(i, j))
                                set(obj.patchHdl(i, j), 'XData',nX(1:4, n), 'YData',nY(1:4, n))
                            else
                                set(obj.patchHdl(i, j), 'XData',nX(:, n), 'YData',nY(:, n))
                            end
                        end
                    end
                end

                if ~isempty(obj.PieX)
                    [nX, nY] = getNewXY(obj.PieX, obj.PieY, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                    for i = 1:size(obj.pieHdl, 1)
                        for j = 1:size(obj.pieHdl, 2)
                            n = sub2ind(size(obj.Data), i, j);
                            set(obj.pieHdl(i, j), 'XData',nX(:, n), 'YData',nY(:, n))
                        end
                    end
                end

                if ~isempty(obj.nanTextHdl)
                    for i = 1:length(obj.nanTextHdl)
                        X = obj.nanTextHdl(i).Position(1); Y = obj.nanTextHdl(i).Position(2);
                        [nX, nY] = getNewXY(X, Y, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                        set(obj.nanTextHdl(i), 'Position',[nX, nY, 0])
                    end
                end

                if ~isempty(obj.textHdl)
                    for i = 1:size(obj.textHdl, 1)
                        for j = 1:size(obj.textHdl, 2)
                            X = obj.textHdl(i, j).Position(1); Y = obj.textHdl(i, j).Position(2);
                            [nX, nY] = getNewXY(X, Y, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                            set(obj.textHdl(i, j), 'Position',[nX, nY, 0])
                        end
                    end
                end

                for i = 1:length(obj.rowLabelHdl)
                    X = obj.rowLabelHdl(i).Position(1); Y = obj.rowLabelHdl(i).Position(2);
                    [nX, nY] = getNewXY(X, Y, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                    if strcmpi(obj.Type, 'full')
                        nV = [nX - tRowX(i), nY - tRowY(i)];
                        nV = nV./norm(nV);
                        nX = tRowX(i) + nV(1).*(obj.TickLength + .25).*tLen;
                        nY = tRowY(i) + nV(2).*(obj.TickLength + .25).*tLen;
                    end
                    obj.rowLabelHdl(i).Position(1) = nX; obj.rowLabelHdl(i).Position(2) = nY;
                end

                for j = 1:length(obj.colLabelHdl)
                    X = obj.colLabelHdl(j).Position(1); Y = obj.colLabelHdl(j).Position(2);
                    [nX, nY] = getNewXY(X, Y, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                    if strcmpi(obj.Type, 'full')
                        nV = [nX - tColX(j), nY - tColY(j)];
                        nV = nV./norm(nV);
                        nX = tColX(j) + nV(1).*(obj.TickLength + .25).*tLen;
                        nY = tColY(j) + nV(2).*(obj.TickLength + .25).*tLen;
                    end
                    obj.colLabelHdl(j).Position(1) = nX; obj.colLabelHdl(j).Position(2) = nY;
                end

                if abs(diff(obj.TLim)) < eps
                    T = mod(obj.TLim(1)/pi*180 + 180, 360) - 180;
                    for i = 1:length(obj.colLabelHdl)
                        if strcmpi(obj.ColLabelLocation, 'top') || (strcmpi(obj.ColLabelLocation, 'diag') && (strcmpi(obj.Type, 'tril') || strcmpi(obj.Type, 'tril0')))
                            if T > 0
                                set(obj.colLabelHdl(i), 'Rotation',T - 90, 'HorizontalAlignment','right')
                            else
                                set(obj.colLabelHdl(i), 'Rotation',T + 90, 'HorizontalAlignment','left')
                            end
                        else
                            if T > 0
                                set(obj.colLabelHdl(i), 'Rotation',T - 90, 'HorizontalAlignment','left')
                            else
                                set(obj.colLabelHdl(i), 'Rotation',T + 90, 'HorizontalAlignment','right')
                            end
                        end
                    end
                    for i = 1:length(obj.rowLabelHdl)
                        if strcmpi(obj.RowLabelLocation, 'left') || (strcmpi(obj.RowLabelLocation, 'diag') && (strcmpi(obj.Type, 'triu') || strcmpi(obj.Type, 'triu0')))
                            if T < 90 && T > -90
                                set(obj.rowLabelHdl(i), 'Rotation',T, 'HorizontalAlignment','right')
                            else
                                set(obj.rowLabelHdl(i), 'Rotation',T + 180, 'HorizontalAlignment','left')
                            end
                        else
                            if T <= 90 && T >= -90
                                set(obj.rowLabelHdl(i), 'Rotation',T, 'HorizontalAlignment','left')
                            else
                                set(obj.rowLabelHdl(i), 'Rotation',T + 180, 'HorizontalAlignment','right')
                            end
                        end 
                    end
                else
                    if strcmpi(obj.ColLabelLocation, 'top')
                        T = mod(obj.TLim(1)/pi*180 + 180, 360) - 180;
                        for i = 1:length(obj.colLabelHdl)
                            if T > 0
                                if obj.TLim(1) < obj.TLim(2)
                                    set(obj.colLabelHdl(i), 'Rotation',T - 90, 'HorizontalAlignment','left')
                                else
                                    set(obj.colLabelHdl(i), 'Rotation',T - 90, 'HorizontalAlignment','right')
                                end
                            else
                                if obj.TLim(1) < obj.TLim(2)
                                    set(obj.colLabelHdl(i), 'Rotation',T + 90, 'HorizontalAlignment','right')
                                else
                                    set(obj.colLabelHdl(i), 'Rotation',T + 90, 'HorizontalAlignment','left')
                                end
                            end
                        end
                    else
                        T = mod(obj.TLim(2)/pi*180 + 180, 360) - 180;
                        for i = 1:length(obj.colLabelHdl)
                            if T > 0
                                if obj.TLim(1) < obj.TLim(2)
                                    set(obj.colLabelHdl(i), 'Rotation',T - 90, 'HorizontalAlignment','right')
                                else
                                    set(obj.colLabelHdl(i), 'Rotation',T - 90, 'HorizontalAlignment','left')
                                end
                            else
                                if obj.TLim(1) < obj.TLim(2)
                                    set(obj.colLabelHdl(i), 'Rotation',T + 90, 'HorizontalAlignment','left')
                                else
                                    set(obj.colLabelHdl(i), 'Rotation',T + 90, 'HorizontalAlignment','right')
                                end
                            end
                        end
                    end
                    for i = 1:length(obj.rowLabelHdl)
                        X = obj.rowLabelHdl(i).Position(1);
                        Y = obj.rowLabelHdl(i).Position(2);
                        T = atan2(Y, X)/pi*180;
                        if sqrt(X.^2 + Y.^2) < obj.XLim(1)
                            if T <= 90 && T >= -90
                                set(obj.rowLabelHdl(i), 'Rotation',- T, 'HorizontalAlignment','right')
                            else
                                set(obj.rowLabelHdl(i), 'Rotation',180 - T, 'HorizontalAlignment','left')
                            end
                        else
                            if T <= 90 && T >= -90
                                set(obj.rowLabelHdl(i), 'Rotation',-T, 'HorizontalAlignment','left')
                            else
                                set(obj.rowLabelHdl(i), 'Rotation',180-T, 'HorizontalAlignment','right')
                            end
                        end
                    end
                end

                try axis(obj.ax, 'tight'), catch, end
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
    
        
    end


% =========================================================================
% Hidden methods >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% =========================================================================
    methods (Hidden)
        function varargout = setTextMN(obj, m, n, varargin)
            % Set properties of the text label at cell (m,n)
            % (设置指定单元格 (m,n) 的文本属性)
            set(obj.textHdl(m, n), varargin{:})
            if nargout == 1
                varargout = {obj};
            end
        end
        function varargout = setPatchMN(obj, m, n, varargin)
            % Apply properties to the patch object at cell (m,n)
            % (设置指定单元格 (m,n) 的填充图形属性)
            set(obj.patchHdl(m, n), varargin{:});
            if isequal(obj.Format, 'pie') || ...
                    isequal(obj.Format, 'donut') || ...
                    isequal(obj.Format, 'bcirc')
                set(obj.pieHdl(m, n), varargin{:});
            end
            if nargout == 1
                varargout = {obj};
            end
        end
    end
end


% function mustBeAllowedFormat(x)
% allowed = {'sq', 'pie', 'donut', 'circ', 'bcirc', 'oval', 'hex', 'star', ...
%     'trill', 'tril', 'triur', 'triu', 'trilr', 'triul', ...
%     'asq', 'acirc', 'txt', 'text', 'cust', 'acust'};
% if ~(ischar(x) || isstring(x)) || ~ismember(x, allowed)
%     quoted = cellfun(@(c) ['''', c, ''''], allowed, 'UniformOutput', false);
%     invalid = quotedString(x);
%     error('''%s'' is not a valid value. Use one of these values: %s', ...
%         invalid, strjoin(quoted, ' | '));
% end
% end
% 
% function mustBeAllowedTriType(x)
% allowed = {'full', 'triu', 'tril', 'triu0', 'tril0', 'linku', 'linkl'};
% if ~(ischar(x) || isstring(x)) || ~ismember(x, allowed)
%     quoted = cellfun(@(c) ['''', c, ''''], allowed, 'UniformOutput', false);
%     invalid = quotedString(x);
%     error('''%s'' is not a valid value. Use one of these values: %s', ...
%         invalid, strjoin(quoted, ' | '));
% end
% end
% 
% function mustBeAllowedRowLabelLocation(x)
% allowed = {'left', 'right', 'diag'};
% if ~(ischar(x) || isstring(x)) || ~ismember(x, allowed)
%     quoted = cellfun(@(c) ['''', c, ''''], allowed, 'UniformOutput', false);
%     invalid = quotedString(x);
%     error('''%s'' is not a valid value. Use one of these values: %s', ...
%         invalid, strjoin(quoted, ' | '));
% end
% end
% 
% function mustBeAllowedColLabelLocation(x)
% allowed = {'top', 'bottom', 'diag'};
% if ~(ischar(x) || isstring(x)) || ~ismember(x, allowed)
%     quoted = cellfun(@(c) ['''', c, ''''], allowed, 'UniformOutput', false);
%     invalid = quotedString(x);
%     error('''%s'' is not a valid value. Use one of these values: %s', ...
%         invalid, strjoin(quoted, ' | '));
% end
% end
% 
% function str = quotedString(val)
% if ischar(val) || isstring(val)
%     str = char(val);
% else
%     str = num2str(val);
% end
% end

% =========================================================================
% Copyright (c) 2023-2026, Zhaoxu Liu / slandarer
% -------------------------------------------------------------------------
% @author : slandarer
% 公众号  : slandarer随笔 
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2025). special heatmap 
% (https://www.mathworks.com/matlabcentral/fileexchange/125520-special-heatmap), 
% MATLAB Central File Exchange. 检索来源 2025/12/1.
% =========================================================================