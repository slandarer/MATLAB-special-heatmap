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
%   setPatch            - Set properties for all patch objects (为所有填充图形设置属性)
%   setRowLabel         - Set properties for all row label text objects (设置所有行标签的属性)
%   setColLabel         - Set properties for all col label text objects (设置所有列标签的属性)
%   setRowLabelLocation - Move row labels to specified location (设置行标签位置)
%   setColLabelLocation - Move col labels to specified location (设置列标签位置)
%   freezeColors        - Permanently assign the current colormap colors to each patch 
%                         based on its value, decoupling them from both the 
%                         colormap axis limits (CLim) and the colormap itself.
%                         (根据当前数值将颜色映射固定到每个填充图形，使其不再随颜色轴范围或颜色映射表的变化而改变)


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
        arginList = {'Parent', 'Format', 'SData', 'Type', 'VarName', 'RowName', 'ColName'}
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

        Colormap;       % Colormap (颜色映射表)
        Colorbar;       % Colorbar (颜色条) 

        % For a square matrix (e.g., corr(X) or correlation matrix of a single dataset):
        VarName;        % Variable names for the single dataset (变量名称)
        % For a rectangular matrix (e.g., corr(X, Y) or cross-correlation between two datasets):
        RowName;        % Names of variables in dataset X (行变量名称)
        ColName;        % Names of variables in dataset Y (列变量名称)


        textHdl;        % Text (data value) handle (文本句柄)
        boxHdl;         % Outline handle (边框句柄)
        patchHdl;       % Patch handle (填充图形句柄)
        pieHdl;         % Pie chart handle (饼图句柄)
        rowLabelHdl;    % Row label handle (行标签句柄)
        colLabelHdl;    % Column label handle (列标签句柄)
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
    end

    methods

% =========================================================================
% Constructor: Create SHeatmap object (构造函数)
% =========================================================================
        function obj = SHeatmap(varargin)
            % Parse axes handle if provided (解析坐标区句柄)
            if isa(varargin{1}, 'matlab.graphics.axis.Axes')
                obj.ax = varargin{1};
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

            % Set axes handle (设置坐标轴句柄)
            if isempty(obj.Parent)
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
            obj.ax.XLim           = [0.5, size(obj.Data, 2) + 0.5];
            obj.ax.YLim           = [0.5, size(obj.Data, 1) + 0.5];
            obj.ax.YDir           = 'reverse';
            obj.ax.TickDir        = 'out';
            obj.ax.TickLength     = [0.002, 0.002];
            obj.ax.DataAspectRatio = [1, 1, 1];
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
            bX1 = repmat([0.5, size(obj.Data, 2) + 0.5, nan], [size(obj.Data, 1) + 1, 1])';
            bY1 = repmat((0.5:1:(size(obj.Data, 1) + 0.5))', [1, 3])';
            bX2 = repmat((0.5:1:(size(obj.Data, 2) + 0.5))', [1, 3])';
            bY2 = repmat([0.5, size(obj.Data, 1) + 0.5, nan], [size(obj.Data, 2) + 1, 1])';
            obj.boxHdl = plot(obj.ax, [bX1(:); bX2(:)], [bY1(:); bY2(:)], ...
                'LineWidth', 0.8, 'Color', [1, 1, 1] .* 0.85);
            if isequal(obj.Format, 'sq')
                set(obj.boxHdl, 'Color', [1, 1, 1, 0]);
            end

            % Define base shape coordinates (定义基本形状坐标)
            baseT   = linspace(0, 2*pi, 150);
            hexT    = linspace(0, 2*pi, 7);
            starT   = linspace(0, 2*pi, 11) + pi/10;
            thetaMat = [1, -1; 1, 1] .* sqrt(2) ./ 2;

            % Preallocate graphics handles (预分配图形句柄)
            if strcmpi(obj.Format, 'txt') || strcmpi(obj.Format, 'text')
            else
                obj.patchHdl = gobjects(size(obj.Data, 1), size(obj.Data, 2));
            end
            obj.textHdl  = gobjects(size(obj.Data, 1), size(obj.Data, 2));


            if strcmpi(obj.Format, 'pie')||strcmpi(obj.Format, 'donut')||strcmpi(obj.Format, 'bcirc')
                obj.pieHdl   = gobjects(size(obj.Data, 1), size(obj.Data, 2));
            end

            % Loop over each cell (遍历每个单元格)
            for row = 1:size(obj.Data, 1)
                for col = 1:size(obj.Data, 2)
                    if isnan(obj.Data(row, col))
                        % Handle NaN values (处理NaN值)
                        obj.patchHdl(row, col) = fill(obj.ax, ...
                            [-0.5, 0.5, 0.5, -0.5] .* 0.98 + col, ...
                            [-0.5, -0.5, 0.5, 0.5] .* 0.98 + row, ...
                            [0.8, 0.8, 0.8], 'EdgeColor', 'none');
                        obj.pieHdl(row, col)   = fill(obj.ax, [0,0,0,0], [0,0,0,0], [0,0,0]);
                        obj.textHdl(row, col)  = text(obj.ax, col, row, '×', ...
                            'FontName', 'Times New Roman', ...
                            'HorizontalAlignment', 'center', 'FontSize', 20);
                    else
                        tRatio = abs(obj.Data(row, col)) ./ obj.maxV;

                        % Draw based on format (根据格式绘制)
                        switch obj.Format
                            case 'sq'
                                obj.patchHdl(row, col) = fill(obj.ax, ...
                                    [-0.5, 0.5, 0.5, -0.5] .* 0.98 + col, ...
                                    [-0.5, -0.5, 0.5, 0.5] .* 0.98 + row, ...
                                    obj.Data(row, col), 'EdgeColor', 'none');
                            case 'asq'
                                obj.patchHdl(row, col) = fill(obj.ax, ...
                                    [-0.5, 0.5, 0.5, -0.5] .* 0.98 .* tRatio + col, ...
                                    [-0.5, -0.5, 0.5, 0.5] .* 0.98 .* tRatio + row, ...
                                    obj.Data(row, col), 'EdgeColor', 'none');
                            case 'pie'
                                baseCircX = cos(baseT) .* 0.92 .* 0.5;
                                baseCircY = sin(baseT) .* 0.92 .* 0.5;
                                obj.pieHdl(row, col) = fill(obj.ax, baseCircX + col, baseCircY + row, ...
                                    [1,1,1], 'EdgeColor', [1,1,1].*0.3, 'LineWidth', 0.8);
                                baseTheta = linspace(pi/2, pi/2 + obj.Data(row, col)./obj.maxV .* 2.*pi, 200);
                                basePieX  = [0, cos(baseTheta) .* 0.92 .* 0.5];
                                basePieY  = [0, sin(baseTheta) .* 0.92 .* 0.5];
                                obj.patchHdl(row, col) = fill(obj.ax, basePieX + col, -basePieY + row, ...
                                    obj.Data(row, col), 'EdgeColor', [1,1,1].*0.3, 'lineWidth', 0.8);
                            case 'circ'
                                baseCircX = cos(baseT) .* 0.92 .* 0.5;
                                baseCircY = sin(baseT) .* 0.92 .* 0.5;
                                obj.patchHdl(row, col) = fill(obj.ax, baseCircX + col, baseCircY + row, ...
                                    obj.Data(row, col), 'EdgeColor', 'none', 'lineWidth', 0.8);
                            case 'acirc'
                                baseCircX = cos(baseT) .* 0.92 .* 0.5;
                                baseCircY = sin(baseT) .* 0.92 .* 0.5;
                                obj.patchHdl(row, col) = fill(obj.ax, baseCircX .* tRatio + col, baseCircY .* tRatio + row, ...
                                    obj.Data(row, col), 'EdgeColor', 'none', 'lineWidth', 0.8);
                            case 'oval'
                                tValue = obj.Data(row, col) ./ obj.maxV;
                                baseA = 1 + (tValue <= 0) .* tValue;
                                baseB = 1 - (tValue >= 0) .* tValue;
                                baseOvalX = cos(baseT) .* 0.98 .* 0.5 .* baseA;
                                baseOvalY = sin(baseT) .* 0.98 .* 0.5 .* baseB;
                                baseOvalXY = thetaMat * [baseOvalX; baseOvalY];
                                obj.patchHdl(row, col) = fill(obj.ax, baseOvalXY(1,:) + col, -baseOvalXY(2,:) + row, ...
                                    obj.Data(row, col), 'EdgeColor', [1,1,1].*0.3, 'lineWidth', 0.8);
                            case 'hex'
                                obj.patchHdl(row, col) = fill(obj.ax, ...
                                    cos(hexT) .* 0.5 .* 0.98 .* tRatio + col, ...
                                    sin(hexT) .* 0.5 .* 0.98 .* tRatio + row, ...
                                    obj.Data(row, col), 'EdgeColor', [1,1,1].*0.3, 'lineWidth', 0.8);
                            case 'star'   % 2025-12-01 updated
                                tValue = obj.Data(row, col) ./ obj.maxV;
                                baseStarX = cos(starT) .* 0.92 .* 0.5 .* tValue;
                                baseStarY = sin(starT) .* 0.92 .* 0.5 .* tValue;
                                baseStarX(1:2:end) = baseStarX(1:2:end) .* 0.5;
                                baseStarY(1:2:end) = baseStarY(1:2:end) .* 0.5;
                                obj.patchHdl(row, col) = fill(obj.ax, baseStarX + col, baseStarY + row, ...
                                    obj.Data(row, col), 'EdgeColor', [1,1,1].*0.3, 'lineWidth', 0.8);
                            case {'tril', 'trill'}
                                obj.patchHdl(row, col) = fill(obj.ax, ...
                                    [-0.5, 0.5, -0.5] + col, [0.5, 0.5, -0.5] + row, ...
                                    obj.Data(row, col), 'EdgeColor', 'none', 'lineWidth', 0.8);
                            case {'triu', 'triur'}
                                obj.patchHdl(row, col) = fill(obj.ax, ...
                                    [-0.5, 0.5, 0.5] + col, [-0.5, 0.5, -0.5] + row, ...
                                    obj.Data(row, col), 'EdgeColor', 'none', 'lineWidth', 0.8);
                            case 'triul'
                                obj.patchHdl(row, col) = fill(obj.ax, ...
                                    [0.5, -0.5, -0.5] + col, [-0.5, -0.5, 0.5] + row, ...
                                    obj.Data(row, col), 'EdgeColor', 'none', 'lineWidth', 0.8);
                            case 'trilr'
                                obj.patchHdl(row, col) = fill(obj.ax, ...
                                    [-0.5, 0.5, 0.5] + col, [0.5, 0.5, -0.5] + row, ...
                                    obj.Data(row, col), 'EdgeColor', 'none', 'lineWidth', 0.8);
                            case 'donut'
                                baseCircX = cos(baseT - pi/2) .* 0.92 .* 0.5;
                                baseCircY = sin(baseT - pi/2) .* 0.92 .* 0.5;
                                obj.pieHdl(row, col) = fill(obj.ax, ...
                                    [baseCircX, baseCircX(end:-1:1).*0.5] + col, ...
                                    [baseCircY, baseCircY(end:-1:1).*0.5] + row, ...
                                    [1,1,1], 'EdgeColor', [1,1,1].*0.3, 'LineWidth', 0.8);
                                baseTheta = linspace(pi/2, pi/2 + obj.Data(row, col)./obj.maxV .* 2.*pi, 200);
                                basePieX  = cos(baseTheta) .* 0.92 .* 0.5;
                                basePieY  = sin(baseTheta) .* 0.92 .* 0.5;
                                obj.patchHdl(row, col) = fill(obj.ax, ...
                                    [basePieX, basePieX(end:-1:1).*0.5] + col, ...
                                    -[basePieY, basePieY(end:-1:1).*0.5] + row, ...
                                    obj.Data(row, col), 'EdgeColor', [1,1,1].*0.3, 'lineWidth', 0.8);
                            case 'cust'
                                obj.patchHdl(row, col) = fill(obj.ax, ...
                                    obj.SData(1,:) + col, -obj.SData(2,:) + row, ...
                                    obj.Data(row, col), 'EdgeColor', [1,1,1].*0.3, 'lineWidth', 0.8);
                            case 'acust'
                                obj.patchHdl(row, col) = fill(obj.ax, ...
                                    obj.SData(1,:) .* tRatio + col, -obj.SData(2,:) .* tRatio + row, ...
                                    obj.Data(row, col), 'EdgeColor', [1,1,1].*0.3, 'lineWidth', 0.8);
                            case 'bcirc'
                                baseCircX = cos(baseT) .* 0.92 .* 0.5;
                                baseCircY = sin(baseT) .* 0.92 .* 0.5;
                                obj.pieHdl(row, col) = fill(obj.ax, baseCircX + col, baseCircY + row, ...
                                    [1,1,1], 'EdgeColor', [1,1,1].*0.3, 'LineWidth', 0.8);
                                obj.patchHdl(row, col) = fill(obj.ax, baseCircX .* tRatio + col, baseCircY .* tRatio + row, ...
                                    obj.Data(row, col), 'EdgeColor', [1,1,1].*0.3, 'lineWidth', 0.8);
                        end

                        % Add numeric text (hidden) (添加数值文本，默认隐藏)
                        obj.textHdl(row, col) = text(obj.ax, col, row, ...
                            sprintf('%.2f', obj.Data(row, col)), ...
                            'FontName','Times New Roman', ...
                            'HorizontalAlignment','center', 'Visible','off'); 
                    end
                end
            end
            if strcmpi(obj.Format, 'txt') || strcmpi(obj.Format, 'text')
                obj.setText()
            end

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
                obj.rowLabelHdl(row) = text(obj.ax, 0.5 - 0.25, row, ...
                    obj.VarName{row}, 'HorizontalAlignment','right', ...
                    'FontName','Times New Roman', 'FontSize',12, 'Visible','off');
            end

            % Add column labels ('Visible', 'off') (添加列标签，默认隐藏)
            obj.colLabelHdl = gobjects(1, size(obj.Data, 2));
            for col = 1:size(obj.Data, 2)
                obj.colLabelHdl(col) = text(obj.ax, col, 0.5 - 0.25, ...
                    obj.VarName{col}, 'HorizontalAlignment','left', ...
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
        
            % Only apply if matrix is square (仅当矩阵为方阵时生效)
            if size(obj.Data, 1) == size(obj.Data, 2)
        
                obj.Type = Type;
                % Hide axes labels and adjust axis location (隐藏坐标轴标签，调整轴位置)
                obj.ax.XColor = 'none';
                obj.ax.YColor = 'none';
                obj.ax.YAxisLocation = 'right';
        
                % Recompute grid line coordinates (重新计算网格线坐标)
                bX1 = repmat([0.5, size(obj.Data, 2) + 0.5, nan], [size(obj.Data, 1) + 1, 1])';
                bY1 = repmat((0.5:1:(size(obj.Data, 1) + 0.5))', [1, 3])';
                bX2 = repmat((0.5:1:(size(obj.Data, 2) + 0.5))', [1, 3])';
                bY2 = repmat([0.5, size(obj.Data, 1) + 0.5, nan], [size(obj.Data, 2) + 1, 1])';
        
                % Show all row and column labels initially (初始显示所有行/列标签)
                for n = 1:size(obj.Data, 1)
                    set(obj.rowLabelHdl(n), 'Visible', 'on');
                    set(obj.colLabelHdl(n), 'Visible', 'on');
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
                                set(obj.textHdl(row, col),  'Visible', 'off');
                                if strcmpi(obj.Format, 'pie') || ...
                                   strcmpi(obj.Format, 'donut') || ...
                                   strcmpi(obj.Format, 'bcirc')
                                    set(obj.pieHdl(row, col), 'Visible', 'off');
                                end
                            end
                        end
                        % Adjust grid lines to form upper triangular outline (调整网格线形成上三角轮廓)
                        bX1(1, 2:end) = bX1(1, 2:end) + (0:size(obj.Data, 1)-1);
                        bY2(2, :) = [1.5:1:(size(obj.Data, 1)+0.5), (size(obj.Data, 1)+0.5)];
                        set(obj.boxHdl, 'XData', [bX1(:); bX2(:)], 'YData', [bY1(:); bY2(:)]);
                        % Reposition row/column labels (重定位行/列标签)
                        for n = 1:size(obj.Data, 1)
                            set(obj.rowLabelHdl(n), 'Position', [0.25 - 1 + n, n, 0]);
                            set(obj.colLabelHdl(n), 'Position', [n, 0.25, 0]);
                        end
        
                    case 'tril'   % lower triangle (including diagonal) (下三角含对角线)
                        % Hide upper-right patches/texts (隐藏右上部分图形和文本)
                        for col = 1:size(obj.Data, 2)
                            for row = 1:(col - 1)
                                if ~(strcmpi(obj.Format,'txt') || strcmpi(obj.Format,'text'))
                                    set(obj.patchHdl(row, col), 'Visible', 'off');
                                end
                                set(obj.textHdl(row, col),  'Visible', 'off');
                                if strcmpi(obj.Format, 'pie') || ...
                                   strcmpi(obj.Format, 'donut') || ...
                                   strcmpi(obj.Format, 'bcirc')
                                    set(obj.pieHdl(row, col), 'Visible', 'off');
                                end
                            end
                        end
                        % Adjust grid lines to form lower triangular outline (调整网格线形成下三角轮廓)
                        bX1(2, 1:end-1) = bX1(2, 1:end-1) - (size(obj.Data, 1)-1:-1:0);
                        bY2(1, :) = [0.5, 0.5:1:(size(obj.Data, 1)-0.5)];
                        set(obj.boxHdl, 'XData', [bX1(:); bX2(:)], 'YData', [bY1(:); bY2(:)]);
                        % Reposition row/column labels (重定位行/列标签)
                        for n = 1:size(obj.Data, 1)
                            set(obj.rowLabelHdl(n), 'Position', [0.25, n, 0]);
                            set(obj.colLabelHdl(n), 'Position', [n, 0.25 - 1 + n, 0]);
                        end
        
                    case {'triu0', 'linku'}  % upper triangle without diagonal (扣除对角线，上三角不含对角线)
                        % Hide diagonal and lower-left patches/texts (隐藏对角线及左下部分)
                        for row = 1:size(obj.Data, 1)
                            for col = 1:(row)
                                if ~(strcmpi(obj.Format,'txt') || strcmpi(obj.Format,'text'))
                                    set(obj.patchHdl(row, col), 'Visible', 'off');
                                end
                                set(obj.textHdl(row, col),  'Visible', 'off');
                                if strcmpi(obj.Format, 'pie') || ...
                                   strcmpi(obj.Format, 'donut') || ...
                                   strcmpi(obj.Format, 'bcirc')
                                    set(obj.pieHdl(row, col), 'Visible', 'off');
                                end
                            end
                        end
                        % Adjust grid lines (调整网格线)
                        bX1(1, :) = bX1(1, :) + 1;
                        bX1(1, 2:end) = bX1(1, 2:end) + (0:size(obj.Data, 1)-1);
                        bY2(2, :) = [1.5:1:(size(obj.Data, 1)+0.5), (size(obj.Data, 1)+0.5)] - 1;
                        set(obj.boxHdl, 'XData', [bX1(:); bX2(:)], 'YData', [bY1(:); bY2(:)]);
                        % Reposition labels and hide the first column and last row labels
                        % (重定位标签，并隐藏第一列和最后一行的标签)
                        for n = 1:size(obj.Data, 1)
                            set(obj.rowLabelHdl(n), 'Position', [0.25 + n, n, 0]);
                            set(obj.colLabelHdl(n), 'Position', [n, 0.25, 0]);
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
                                set(obj.textHdl(row, col),  'Visible', 'off');
                                if strcmpi(obj.Format, 'pie') || ...
                                   strcmpi(obj.Format, 'donut') || ...
                                   strcmpi(obj.Format, 'bcirc')
                                    set(obj.pieHdl(row, col), 'Visible', 'off');
                                end
                            end
                        end
                        % Adjust grid lines (调整网格线)
                        bX1(2, :) = bX1(2, :) - 1;
                        bX1(2, 1:end-1) = bX1(2, 1:end-1) - (size(obj.Data, 1)-1:-1:0);
                        bY2(1, :) = [0.5, 0.5:1:(size(obj.Data, 1)-0.5)] + 1;
                        set(obj.boxHdl, 'XData', [bX1(:); bX2(:)], 'YData', [bY1(:); bY2(:)]);
                        % Reposition labels and hide the first row and last column labels
                        % (重定位标签，并隐藏第一行和最后一列的标签)
                        for n = 1:size(obj.Data, 1)
                            set(obj.rowLabelHdl(n), 'Position', [0.25, n, 0]);
                            set(obj.colLabelHdl(n), 'Position', [n, 0.25 + n, 0]);
                        end
                        set(obj.rowLabelHdl(1), 'Visible', 'off');
                        set(obj.colLabelHdl(size(obj.Data, 2)), 'Visible', 'off');
                end
            end

            if strcmpi(obj.Type, 'linkl')
                for n = 1:size(obj.Data, 1)
                    set(obj.rowLabelHdl(n), 'Position',[0.25, n, 0], 'HorizontalAlignment','right', 'Visible','on')
                end
                for n = 1:size(obj.Data, 2)
                    set(obj.colLabelHdl(n), 'Position',[n, size(obj.Data, 1) + 0.75, 0], 'HorizontalAlignment','right', 'Visible','on')
                end
                delete(obj.Colorbar)
            end

            if strcmpi(obj.Type, 'linku')
                for n = 1:size(obj.Data, 1)
                    set(obj.rowLabelHdl(n), 'Position',[size(obj.Data, 2) + 0.75, n, 0], 'HorizontalAlignment','left', 'Visible','on')
                end
                for n = 1:size(obj.Data, 2)
                    set(obj.colLabelHdl(n), 'Position',[n, 0.25, 0], 'HorizontalAlignment','left', 'Visible','on')
                end
                delete(obj.Colorbar)
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
            VarNameLen = length(obj.VarName);
            for n = 1:size(obj.Data, 1)
                % Apply names cyclically (循环应用名称)
                idx = mod(n - 1, VarNameLen) + 1;
                set(obj.rowLabelHdl(n), 'String', obj.VarName{idx}, 'Visible','on');
                set(obj.colLabelHdl(n), 'String', obj.VarName{idx}, 'Visible','on');
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
                set(obj.rowLabelHdl(i), 'String', obj.RowName{idx}, 'Visible','on');
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
                set(obj.colLabelHdl(j), 'String', obj.ColName{idx}, 'Visible','on');
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


            % 'left'/'right'/'diag
            for n = 1:size(obj.Data, 1)
                switch loc
                    case 'left'
                        set(obj.rowLabelHdl(n), 'Position',[0.25, n, 0], 'HorizontalAlignment','right')
                    case 'right'
                        set(obj.rowLabelHdl(n), 'Position',[size(obj.Data, 2) + 0.75, n, 0], 'HorizontalAlignment','left')
                    case 'diag'
                        switch obj.Type
                            case 'tril'
                                set(obj.rowLabelHdl(n), 'Position',[0.75 + n, n, 0], 'HorizontalAlignment','left')
                            case 'tril0'
                                set(obj.rowLabelHdl(n), 'Position',[0.75 - 1 + n, n, 0], 'HorizontalAlignment','left')
                            case 'triu'
                                set(obj.rowLabelHdl(n), 'Position',[0.25 - 1 + n, n, 0], 'HorizontalAlignment','right')
                            case 'triu0'
                                set(obj.rowLabelHdl(n), 'Position',[0.25 + n, n, 0], 'HorizontalAlignment','right')
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


            % 'top'/'bottom'/'diag
            for n = 1:size(obj.Data, 2)
            switch loc
                case 'top'
                    set(obj.colLabelHdl(n), 'Position',[n, 0.25, 0], 'HorizontalAlignment','left')
                case 'bottom'
                    set(obj.colLabelHdl(n), 'Position',[n, size(obj.Data, 1) + 0.75, 0], 'HorizontalAlignment','right')
                case 'diag'
                    switch obj.Type
                        case 'tril'
                            set(obj.colLabelHdl(n), 'Position',[n, 0.25 - 1 + n, 0], 'HorizontalAlignment','left')
                        case 'tril0'
                            set(obj.colLabelHdl(n), 'Position',[n, 0.25 + n, 0], 'HorizontalAlignment','left')
                        case 'triu'
                            set(obj.colLabelHdl(n), 'Position',[n, n - .25 + 1, 0], 'HorizontalAlignment','right')
                        case 'triu0'
                            set(obj.colLabelHdl(n), 'Position',[n, n - .25, 0], 'HorizontalAlignment','right')
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