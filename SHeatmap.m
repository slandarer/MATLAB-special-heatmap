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
%     'sq'          : square (default)          : 方形 (默认)
%     'sqfull'      : square (full-size)        : 方形 (满格)
%     'shade'       : Square (neg-values shaded): 方形 (负数部分阴影填充)
%     'rrect'       : rounded rectangle         : 圆角矩形
%     'c2rect'      : circle to rectangle       : 圆形到矩形过度
%     'pie'         : pie chart                 : 饼图
%     'donut'       : donut chart               : 环形饼图 (甜甜圈图)
%     'circ'        : circle                    : 圆形
%     'bcirc'       : circle with box           : 有边框的圆形
%     'oval'        : oval                      : 椭圆形
%     'hex'         : hexagon                   ：六边形
%     'star'        : star                      : 五角星
%     'moon'        : moon                      : 月亮
%     'arrow'       : arrow                     : 箭头
%     'teardrop'    : teardrop                  : 水滴状
%     'bar'         : bar graph                 : 柱状图
%     'barh'        : Horizontal bar graph      : 水平柱状图
%     'trill'(tril) : lower left triangle       : 下三角
%     'triur'(triu) : upper right triangle      : 上三角
%     'trilr'       : lower right triangle      : 右下三角
%     'triul'       : upper left triangle       : 左上三角
%     'asq'         : auto-size square          ：自带调整大小的方形
%     'acirc'       : auto-size circular        ：自带调整大小的圆形
%     'arrect'      : auto-size rounded rect    : 自带调整大小的圆角矩形
%     'txt'(text)   : colored text              : 带颜色的文本
%     '3d'          : 3D bar                    : 三维柱状图
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
%     'row'    : show row labels & ticks only     : 仅显示行标签及行刻度
%     'col'    : show col labels & ticks only     : 仅显示列标签及列刻度
%     'varu'   : upper triangle with diagonal     : 上三角部分
%                cells replaced by variable names : 对角线使用变量名标签替换
%     'varl'   : lower triangle with diagonal     : 下三角部分
%                cells replaced by variable names : 对角线使用变量名标签替换
%
% Methods: (try: help SHeatmap.setText)
%   draw                     - Render the heatmap object (渲染热图对象)
%   setType                  - Adjust display to show only triangular part of the matrix (仅展示矩阵的三角部分)
%   setVarName               - Assign variable names to rows and columns (为行和列分配变量名)
%   setRowName               - Assign variable names to rows (为行分配变量名)
%   setColName               - Assign variable names to cols (为列分配变量名)
%   setRowGroupName          - Assign group names to row-groups (为行分组分配组名)
%   setColGroupName          - Assign group names to col-groups (为列分组分配组名)
%   setText                  - Show value labels with auto-contrast color, and set properties (显示数值标签并自动调整颜色，设置标签属性)
%   setTextFormat            - Apply a custom formatting function to all value labels (对数值标签应用自定义格式化函数)
%   setFontName              - Set the font name of all existing labels (设置所有已绘制标签的字体名称)
%   showStars                - Overlay significance stars on value labels based on p-values (根据 p 值在数值标签上叠加显著性星标)
%   setBox                   - Set properties for box handle (设置框样式)
%   setGrid                  - Set properties for grid handle (设置网格样式)
%   setFrame                 - Set properties for frame and tick handle (设置外轮廓样式)
%   setPatch                 - Set properties for all patch objects (为所有填充图形设置属性)
%   setRowLabel              - Set properties for all row label text objects (设置所有行标签的属性)
%   setColLabel              - Set properties for all col label text objects (设置所有列标签的属性)
%   setRowGroupLabel         - Set properties for all row-group label text objects (设置所有行分组标签的属性)
%   setColGroupLabel         - Set properties for all col-group label text objects (设置所有列分组标签的属性)
%   setRowLabelLocation      - Move row labels to specified location (设置行标签位置)
%   setColLabelLocation      - Move col labels to specified location (设置列标签位置)
%   setRowGroupLabelLocation - Move row-group labels to specified location (设置行分组标签位置)
%   setColGroupLabelLocation - Move col-group labels to specified location (设置行分组标签位置)
%   freezeColors             - Permanently assign the current colormap colors to each patch 
%                              based on its value, decoupling them from both the 
%                              colormap axis limits (CLim) and the colormap itself
%                              (根据当前数值将颜色映射固定到每个填充图形，使其不再随颜色轴范围或颜色映射表的变化而改变)
%   setXYTLim                - Set X, Y, and Theta limits for the heatmap (设置热图 X轴、 Y轴、角度范围)


% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔 
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2025). special heatmap 
% (https://www.mathworks.com/matlabcentral/fileexchange/125520-special-heatmap), 
% MATLAB Central File Exchange. 检索来源 2025/12/1.
% =========================================================================


    properties
        ax, fig
        Parent = [];
        arginList = {'Parent', 'Format', 'SData', 'Type', ...
                     'VarName', 'RowName', 'ColName', ...
                     'GroupSep', 'RowGroup', 'ColGroup', ...
                     'TickLength','TickLabelOffset','GroupLabelOffset', ...
                     'RowGroupName', 'ColGroupName', 'ShapeFlipX', 'ShapeFlipY', ...
                     'Format3DHeight', 'Format3DTheta','RowLabelLocation','ColLabelLocation'}
        Data
        PVal

        Format = 'sq'  
        % 'sq'          : square (default)          : 方形 (默认)
        % 'sqfull'      : square (full-size)        : 方形 (满格)
        % 'shade'       : Square (neg-values shaded): 方形 (负数部分阴影填充)
        % 'rrect'       : rounded rectangle         : 圆角矩形
        % 'c2rect'      : circle to rectangle       : 圆形到矩形过度
        % 'pie'         : pie chart                 : 饼图
        % 'donut'       : donut chart               : 环形饼图 (甜甜圈图)
        % 'circ'        : circle                    : 圆形
        % 'bcirc'       : circle with box           : 有边框的圆形
        % 'oval'        : oval                      : 椭圆形
        % 'hex'         : hexagon                   ：六边形
        % 'star'        : star                      : 五角星
        % 'moon'        : moon                      : 月亮
        % 'arrow'       : arrow                     : 箭头
        % 'teardrop'    : teardrop                  : 水滴状
        % 'bar'         : bar graph                 : 柱状图
        % 'barh'        : Horizontal bar graph      : 水平柱状图
        % 'trill'(tril) : lower left triangle       : 下三角
        % 'triur'(triu) : upper right triangle      : 上三角
        % 'trilr'       : lower right triangle      : 右下三角
        % 'triul'       : upper left triangle       : 左上三角
        % 'asq'         : auto-size square          ：自带调整大小的方形
        % 'acirc'       : auto-size circular        ：自带调整大小的圆形
        % 'arrect'      : auto-size rounded rect    : 自带调整大小的圆角矩形
        % 'txt'(text)   : colored text              : 带颜色的文本
        % '3d'          : 3D bar                    : 三维柱状图
        % 'cust'        : custom shape              : 自定义形状
        % 'acust'       : auto-size custom shape    : 自带调整大小的自定义形状
        SData = [.45, .21, .22, .09, .00, -.09, -.22, -.21, -.45, -.21, -.22, -.09, -.00,  .09,  0.22,  .21,   .45
                 .00, .09, .22, .21, .45,  .21,  .22,  .09,  .00, -.09, -.22, -.21, -.45, -.21, -0.22, -.09, -.00];
        ShapeFlipX = 'off';  % Horizontal flip of cell shapes (水平翻转单元格形状), 'on'/'off'
        ShapeFlipY = 'off';  % Vertical flip of cell shapes   (垂直翻转单元格形状), 'on'/'off'

        

        Type = 'full';
        % 'triu'  : upper triangle                   : 上三角部分
        % 'tril'  : lower triangle                   : 下三角部分
        % 'triu0' : upper triangle without diagonal  : 扣除对角线上三角部分
        %           (strictly upper triangular part) : (严格上三角)
        % 'tril0' : lower triangle without diagonal  : 扣除对角线下三角部分
        %           (strictly lower triangular part) : (严格下三角)
        % 'linkl' : lower triangle for mantel links  : 适配 mantel 链接的下三角
        % 'linku' : upper triangle for mantel links  : 适配 mantel 链接的上三角
        % 'row'   : show row labels & ticks only     : 仅显示行标签及行刻度
        % 'col'   : show col labels & ticks only     : 仅显示列标签及列刻度
        % 'varu'  : upper triangle with diagonal     : 上三角部分
        %           cells replaced by variable names : 对角线使用变量名标签替换
        % 'varl'  : lower triangle with diagonal     : 下三角部分
        %           cells replaced by variable names : 对角线使用变量名标签替换

        TickLength = .1;        % Length of tick marks (刻度线长度)
        TickLabelOffset = .25;  % Offset distance from tick end to tick label (刻度末端到刻度标签的偏移距离)
        GroupLabelOffset = 1.5; % Offset distance for group labels (分组标签的偏移距离)

        RowLabelLocation = 'left';        % 'left', 'right', 'diag'
        ColLabelLocation = 'bottom';      % 'top', 'bottom', 'diag'
        RowGroupLabelLocation = 'left';   % 'left', 'right', 'diag'
        ColGroupLabelLocation = 'bottom'; % 'top', 'bottom', 'diag'

        Colormap;         % Colormap (颜色映射表)
        Colorbar;         % Colorbar (颜色条) 

        % For a square matrix (e.g., corr(X) or correlation matrix of a single dataset):
        VarName;          % Variable names for the single dataset (变量名称)
        % For a rectangular matrix (e.g., corr(X, Y) or cross-correlation between two datasets):
        RowName;          % Names of variables in dataset X (行变量名称)
        ColName;          % Names of variables in dataset Y (列变量名称)
        RowGroup = [];    % Row group assignments (行分组标签)
        ColGroup = [];    % Column group assignments (列分组标签)
        GroupSep = .5;    % Separation gap between groups (组间分离间距)
        RowGroupName      % Names for row groups (行分组名称)
        ColGroupName      % Names for column groups (列分组名称)

        % X, Y, and Theta limits for the heatmap
        XLim = [], 
        YLim = [], 
        TLim = [0, 0];

        
        gridHdl           % Grid handle (网格线句柄)
        pieHdl;           % Pie chart handle (饼图句柄)
        patchHdl;         % Patch handle (填充图形句柄)
        textHdl;          % Text (data value) handle (文本句柄)
        boxHdl;           % Outline handle (边框句柄)
        frameHdl;         % Frame (outline) handle (外轮廓句柄)
        rowTickHdl;       % Row tick handle (行刻度句柄)
        colTickHdl;       % Col tick handle (列刻度句柄)
        rowLabelHdl;      % Row label handle (行标签句柄)
        colLabelHdl;      % Column label handle (列标签句柄)
        rowGroupLabelHdl  % Row-group label handle (行分组标签句柄)
        colGroupLabelHdl  % Col-group label handle (列分组标签句柄)
    end

    properties (Hidden)
        maxV; Mask
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
        RP; CP; FX; FY; BX; BY; 
        GX = nan; GY = nan; 
        SX = 1; SY = 1;
        
        RGP; CGP; RGLDir; CGLDir;
        PatchX; PatchY; PieX; PieY; 
        
        TxtXY; TxtNaNXY; newTxtXY; nanTextHdl
        
        RTX; RTY; CTX; CTY; RTLDir; CTLDir
        newRTX; newRTY; newCTX; newCTY
        
        RowTickIndices = [];   % Indices of row ticks to display (要显示的行刻度索引)
        ColTickIndices = [];   % Indices of column ticks to display (要显示的列刻度索引)

        Format3DHeight = 2
        Format3DTheta = pi/3.5
    end

    properties (Hidden, SetObservable)
        txtShown = false; 
        rowShown = false;
        colShown = false;
        XYTReset = false;
        isFrozen = false;
        txtFixed = false;
        tickConfigured = false;
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
            obj.Data = varargin{1}; varargin(1) = [];
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

            obj.Mask = zeros(size(obj.Data)) == 1;
            obj.RowTickIndices = 1:size(obj.Data, 1);
            obj.ColTickIndices = 1:size(obj.Data, 2);
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

            
            % Set color axis limits (设置颜色轴范围)
            if any(any(obj.Data < 0))
                try 
                    caxis(obj.ax, obj.maxV .* [-1, 1]) 
                catch
                    clim(obj.ax,  obj.maxV .* [-1, 1])
                end
            else
                try 
                    caxis(obj.ax, obj.maxV .* [0, 1])
                catch
                    clim(obj.ax,  obj.maxV .* [0, 1]),
                end
            end
            
            obj.GroupSep(obj.GroupSep < 0) = 0;
            obj.GroupSep(obj.GroupSep > 10) = 10;
            obj.TickLength(obj.TickLength < 0) = 0;
            obj.TickLength(obj.TickLength > .5) = .5;
            obj.TickLabelOffset(obj.TickLabelOffset <= 1e-4) = 1e-4;
            obj.TickLabelOffset(obj.TickLabelOffset > 1) = 1;
            obj.GroupLabelOffset(obj.GroupLabelOffset <= 1e-4) = 1e-4;
            obj.GroupLabelOffset(obj.GroupLabelOffset > 10) = 10;


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
            if isscalar(obj.GroupSep)
                obj.RP = (1:size(obj.Data, 1)) + (obj.RowGroup - 1).*obj.GroupSep;
                obj.CP = (1:size(obj.Data, 2)) + (obj.ColGroup - 1).*obj.GroupSep;
            else
                obj.RP = (1:size(obj.Data, 1)) + (obj.RowGroup - 1).*obj.GroupSep(1);
                obj.CP = (1:size(obj.Data, 2)) + (obj.ColGroup - 1).*obj.GroupSep(2);
            end
            
            obj.RGP = accumarray(obj.RowGroup(:), obj.RP(:), [], @mean);
            obj.CGP = accumarray(obj.ColGroup(:), obj.CP(:), [], @mean);

            obj.XLim = [obj.CP(1) - .5, obj.CP(end) + .5];
            obj.YLim = [obj.RP(1) - .5, obj.RP(end) + .5];
            obj.ax.XLim = obj.XLim;
            obj.ax.YLim = obj.YLim;
            obj.ax.XTick = obj.CP;
            obj.ax.YTick = obj.RP;
            obj.ax.XTickLabel = compose('%d', 1:size(obj.Data, 2));
            obj.ax.YTickLabel = compose('%d', 1:size(obj.Data, 1));

            % Apply colormap and colorbar (应用颜色映射和颜色条)
            colormap(obj.ax, obj.Colormap);
            obj.Colorbar = colorbar(obj.ax);

            % Adjust figure size if needed (调整初始界面大小)
            if isa(obj.ax.Parent, 'matlab.graphics.layout.TiledChartLayout')
                obj.fig = obj.ax.Parent.Parent;
            else
                obj.fig = obj.ax.Parent;
            end
            if strcmp(get(obj.fig, 'Type'), 'figure')
                obj.fig.Color = [1, 1, 1];
                if max(obj.fig.Position(3:4)) < 600 && strcmp(obj.fig.Units, 'pixels')
                    obj.fig.Position(3:4) = [1.6, 1.8] .* obj.fig.Position(3:4);
                    obj.fig.Position(1:2) = obj.fig.Position(1:2) ./ 4;
                end
            end

            % Draw grid lines (绘制网格线)
            obj.gridHdl = plot(obj.ax, nan, nan, 'LineWidth', 0.8, 'Color', [0,0,0], 'LineStyle','--');
            

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
            
            if strcmpi(obj.ShapeFlipX, 'on'); obj.SX = -1; end
            if strcmpi(obj.ShapeFlipY, 'on'); obj.SY = -1; end

            mn = numel(obj.Data); sz = size(obj.Data);
            [cols, rows] = meshgrid(1:sz(2), 1:sz(1));
            rows = reshape(obj.RP(rows), 1, []);
            cols = reshape(obj.CP(cols), 1, []);
            datas = reshape(obj.Data, 1, []);
            tRatio = abs(datas)./obj.maxV;

            switch lower(obj.Format)
                case 'sq'
                    obj.PatchX = obj.SX.*repmat([-.5; .5; .5; -.5].*.98, [1, mn]) + repmat(cols, [4, 1]);
                    obj.PatchY = obj.SY.*repmat([-.5; -.5; .5; .5].*.98, [1, mn]) + repmat(rows, [4, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none');
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'sqfull'
                    obj.PatchX = obj.SX.*repmat([-.5; .5; .5; -.5], [1, mn]) + repmat(cols, [4, 1]);
                    obj.PatchY = obj.SY.*repmat([-.5; -.5; .5; .5], [1, mn]) + repmat(rows, [4, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none');
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'asq'
                    obj.PatchX = obj.SX.*repmat([-.5; .5; .5; -.5].*.98, [1, mn]).*repmat(tRatio, [4, 1]) + repmat(cols, [4, 1]);
                    obj.PatchY = obj.SY.*repmat([-.5; -.5; .5; .5].*.98, [1, mn]).*repmat(tRatio, [4, 1]) + repmat(rows, [4, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none');
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'rrect'
                    obj.PatchX = obj.SX.*repmat((X4.*.7 + cos(T4).*.3).*.46, [1, mn]) + repmat(cols, [80, 1]);
                    obj.PatchY = obj.SY.*repmat((Y4.*.7 + sin(T4).*.3).*.46, [1, mn]) + repmat(rows, [80, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none');
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'c2rect'
                    obj.PatchX = obj.SX.*(repmat(X4.*.46, [1, mn]).*repmat(tRatio, [80, 1]) + repmat(cos(T4).*.46, [1, mn]).*repmat(1 - tRatio, [80, 1])) + repmat(cols, [80, 1]);
                    obj.PatchY = obj.SY.*(repmat(Y4.*.46, [1, mn]).*repmat(tRatio, [80, 1]) + repmat(sin(T4).*.46, [1, mn]).*repmat(1 - tRatio, [80, 1])) + repmat(rows, [80, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'shade'
                    obj.PatchX = obj.SX.*repmat([-.5; .5; .5; -.5].*.98, [1, mn]) + repmat(cols, [4, 1]);
                    obj.PatchY = obj.SY.*repmat([-.5; -.5; .5; .5].*.98, [1, mn]) + repmat(rows, [4, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none');
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                    obj.PieX = obj.SX.*repmat([.49; .01; nan; .49; -.49; nan; -.01; -.49; nan], [1, mn]) + repmat(cols, [9, 1]);
                    obj.PieY = obj.SY.*repmat([-.01; -.49; nan; .49; -.49; nan; .49; .01; nan], [1, mn]) + repmat(rows, [9, 1]);
                    obj.pieHdl = fill(obj.ax, obj.PieX, obj.PieY, datas(:), 'EdgeColor',[1,1,1], 'LineWidth',1, 'EdgeAlpha',.7, 'LineJoin','chamfer');
                    obj.pieHdl = reshape(obj.pieHdl, sz);
                case 'pie'
                    obj.PieX = obj.SX.*repmat(cos(baseT).*.92.*.5, [1, mn]) + repmat(cols, [length(baseT), 1]);
                    obj.PieY = obj.SY.*repmat(sin(baseT).*.92.*.5, [1, mn]) + repmat(rows, [length(baseT), 1]);
                    obj.pieHdl = fill(obj.ax, obj.PieX, obj.PieY, [1,1,1], 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.pieHdl = reshape(obj.pieHdl, sz);
                    tMesh = repmat(linspace(0, 1, 100).', 1, mn);
                    tTheta = pi/2 + tMesh.*repmat(datas./obj.maxV.*2.*pi, 100, 1);
                    obj.PatchX = obj.SX.*[zeros(1, mn); cos(tTheta).*.92.*.5] + repmat(cols, [101, 1]);
                    obj.PatchY = obj.SY.*[zeros(1, mn);-sin(tTheta).*.92.*.5] + repmat(rows, [101, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8, 'LineJoin','chamfer');
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'circ'
                    obj.PatchX = obj.SX.*repmat(cos(baseT).*.92.*.5, [1, mn]) + repmat(cols, [length(baseT), 1]);
                    obj.PatchY = obj.SY.*repmat(sin(baseT).*.92.*.5, [1, mn]) + repmat(rows, [length(baseT), 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none', 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'acirc'
                    obj.PatchX = obj.SX.*repmat(cos(baseT).*.92.*.5, [1, mn]).*repmat(tRatio, [length(baseT), 1]) + repmat(cols, [length(baseT), 1]);
                    obj.PatchY = obj.SY.*repmat(sin(baseT).*.92.*.5, [1, mn]).*repmat(tRatio, [length(baseT), 1]) + repmat(rows, [length(baseT), 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none', 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'arrect'
                    tRatio2 = max(0, 4*(tRatio - 0.75));
                    obj.PatchX = obj.SX.*(repmat(X4.*.46, [1, mn]).*repmat(tRatio2, [80, 1]) + repmat(cos(T4).*.46, [1, mn]).*repmat(1 - tRatio2, [80, 1])).*repmat(tRatio, [80, 1]) + repmat(cols, [80, 1]);
                    obj.PatchY = obj.SY.*(repmat(Y4.*.46, [1, mn]).*repmat(tRatio2, [80, 1]) + repmat(sin(T4).*.46, [1, mn]).*repmat(1 - tRatio2, [80, 1])).*repmat(tRatio, [80, 1]) + repmat(rows, [80, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'oval'
                    tValue = datas./obj.maxV;
                    baseA = 1 + (tValue <= 0).*tValue;
                    baseB = 1 - (tValue >= 0).*tValue;
                    baseOvalX = repmat(cos(baseT).*.98.*.5, [1, mn]).*repmat(baseA, [length(baseT), 1]);
                    baseOvalY = repmat(sin(baseT).*.98.*.5, [1, mn]).*repmat(baseB, [length(baseT), 1]);
                    baseOvalXY = [baseOvalX(:), baseOvalY(:)]*thetaMat;
                    obj.PatchX = obj.SX.*reshape(baseOvalXY(:,1), [length(baseT), mn]) + repmat(cols, [length(baseT), 1]);
                    obj.PatchY = -obj.SY.*reshape(baseOvalXY(:,2), [length(baseT), mn]) + repmat(rows, [length(baseT), 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'hex'
                    obj.PatchX = obj.SX.*repmat(cos(hexT).*.92.*.5, [1, mn]).*repmat(tRatio, [length(hexT), 1]) + repmat(cols, [length(hexT), 1]);
                    obj.PatchY = obj.SY.*repmat(sin(hexT).*.92.*.5, [1, mn]).*repmat(tRatio, [length(hexT), 1]) + repmat(rows, [length(hexT), 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'star'
                    tValue = datas./obj.maxV;
                    tR = [1;.5;1;.5;1;.5;1;.5;1;.5;1];
                    obj.PatchX = obj.SX.*repmat(cos(starT).*.92.*.5.*tR, [1, mn]).*repmat(tValue, [length(starT), 1]) + repmat(cols, [length(starT), 1]);
                    obj.PatchY = -obj.SY.*repmat(sin(starT).*.92.*.5.*tR, [1, mn]).*repmat(tValue, [length(starT), 1]) + repmat(rows, [length(starT), 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'moon'
                    obj.PieX = obj.SX.*repmat(XM, [1, mn]) + repmat(cols, [80, 1]);
                    obj.PieY = obj.SY.*repmat(YM, [1, mn]) + repmat(rows, [80, 1]);
                    obj.pieHdl = fill(obj.ax, obj.PieX, obj.PieY, [1,1,1], 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.pieHdl = reshape(obj.pieHdl, sz);
                    tValue = 2.*((datas < 0) - .5);
                    obj.PatchX = obj.SX.*repmat(XM, [1,mn]).*[ones([40, mn]); repmat(tRatio.*2 - 1, [40, 1])].*repmat(tValue, [80, 1]) + repmat(cols, [80, 1]);
                    obj.PatchY = obj.SY.*repmat(YM, [1,mn]) + repmat(rows, [80, 1]); 
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8, 'LineJoin','chamfer');
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'teardrop'
                    obj.PieX = obj.SX.*repmat(XT, [1, mn]) + repmat(cols, [80, 1]);
                    obj.PieY = obj.SY.*repmat(YT, [1, mn]) + repmat(rows, [80, 1]);
                    obj.pieHdl = fill(obj.ax, obj.PieX, obj.PieY, [1,1,1], 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.pieHdl = reshape(obj.pieHdl, sz);
                    tX1 = obj.SX.*repmat(XT, [1, mn]);
                    tY1 = obj.SY.*repmat(YT, [1, mn]);
                    tY2 = repmat((1 - tRatio).*.94 - .47, [80, 1]);
                    tX1(tY1 < tY2) = sign(tX1(tY1 < tY2)).*abs(sin(acos(tY2(tY1 < tY2)./(-.5.*.94))).*(sin(acos(tY2(tY1 < tY2)./(-.5.*.94))./2)).^.9).*.5.*.75./XT_max;
                    tY1(tY1 < tY2) = tY2(tY1 < tY2);
                    obj.PatchX = tX1 + repmat(cols, [80, 1]);
                    obj.PatchY = tY1 + repmat(rows, [80, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8, 'LineJoin','chamfer');
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'arrow'
                    tValue = 2.*((datas < 0) - .5);
                    obj.PatchX = obj.SX.*repmat(XA.*.8, [1, mn]) + repmat(cols, [7, 1]);
                    obj.PatchY = obj.SY.*repmat(YA.*.8, [1, mn]).*repmat(tValue, [7, 1]) + repmat(rows, [7, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case {'tril', 'trill'}
                    obj.PatchX = obj.SX.*repmat([-.5; .5; -.5].*.98, [1, mn]) + repmat(cols, [3, 1]);
                    obj.PatchY = obj.SY.*repmat([.5; .5; -.5].*.98, [1, mn]) + repmat(rows, [3, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none', 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case {'triu', 'triur'}
                    obj.PatchX = obj.SX.*repmat([-.5; .5; .5].*.98, [1, mn]) + repmat(cols, [3, 1]);
                    obj.PatchY = obj.SY.*repmat([-.5; .5; -.5].*.98, [1, mn]) + repmat(rows, [3, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none', 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'triul'
                    obj.PatchX = obj.SX.*repmat([.5; -.5; -.5].*.98, [1, mn]) + repmat(cols, [3, 1]);
                    obj.PatchY = obj.SY.*repmat([-.5; -.5; .5].*.98, [1, mn]) + repmat(rows, [3, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none', 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'trilr'
                    obj.PatchX = obj.SX.*repmat([-.5; .5; .5].*.98, [1, mn]) + repmat(cols, [3, 1]);
                    obj.PatchY = obj.SY.*repmat([.5; .5; -.5].*.98, [1, mn]) + repmat(rows, [3, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor','none', 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'donut'
                    obj.PieX = obj.SX.*repmat([cos(baseT - pi/2).*.92.*.5; cos(baseT(end:-1:1, :) - pi/2).*.92.*.25], [1, mn]) + repmat(cols, [2*length(baseT), 1]);
                    obj.PieY = obj.SY.*repmat([sin(baseT - pi/2).*.92.*.5; sin(baseT(end:-1:1, :) - pi/2).*.92.*.25], [1, mn]) + repmat(rows, [2*length(baseT), 1]);
                    obj.pieHdl = fill(obj.ax, obj.PieX, obj.PieY, [1,1,1], 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.pieHdl = reshape(obj.pieHdl, sz);
                    tMesh = repmat(linspace(0, 1, 50).', 1, mn);
                    tTheta = pi/2 + tMesh.*repmat(datas./obj.maxV.*2.*pi, 50, 1);
                    obj.PatchX = obj.SX.*[cos(tTheta).*.92.*.5; cos(tTheta(end:-1:1, :)).*.92.*.25] + repmat(cols, [100, 1]);
                    obj.PatchY = -obj.SY.*[sin(tTheta).*.92.*.5; sin(tTheta(end:-1:1, :)).*.92.*.25] + repmat(rows, [100, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8, 'LineJoin','chamfer');
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'cust'
                    obj.PatchX = obj.SX.*repmat(obj.SData(1,:).', [1, mn]) + repmat(cols, [length(obj.SData(1,:)), 1]);
                    obj.PatchY = obj.SY.*repmat(-obj.SData(2,:).', [1, mn]) + repmat(rows, [length(obj.SData(2,:)), 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8, 'LineJoin','chamfer');
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'acust'
                    obj.PatchX = obj.SX.*repmat(obj.SData(1,:).', [1, mn]).*repmat(tRatio, [length(obj.SData(1,:)), 1]) + repmat(cols, [length(obj.SData(1,:)), 1]);
                    obj.PatchY = obj.SY.*repmat(-obj.SData(2,:).', [1, mn]).*repmat(tRatio, [length(obj.SData(2,:)), 1]) + repmat(rows, [length(obj.SData(2,:)), 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8, 'LineJoin','chamfer');
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'bcirc'
                    obj.PieX = obj.SX.*repmat(cos(baseT).*.92.*.5, [1, mn]) + repmat(cols, [length(baseT), 1]);
                    obj.PieY = obj.SY.*repmat(sin(baseT).*.92.*.5, [1, mn]) + repmat(rows, [length(baseT), 1]);
                    obj.pieHdl = fill(obj.ax, obj.PieX, obj.PieY, [1,1,1], 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.pieHdl = reshape(obj.pieHdl, sz);
                    obj.PatchX = obj.SX.*repmat(cos(baseT).*.92.*.5, [1, mn]).*repmat(tRatio, [length(baseT), 1]) + repmat(cols, [length(baseT), 1]);
                    obj.PatchY = obj.SY.*repmat(sin(baseT).*.92.*.5, [1, mn]).*repmat(tRatio, [length(baseT), 1]) + repmat(rows, [length(baseT), 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8);
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case '3d'
                    obj.PieX = repmat([-.5; .5; .5; -.5].*.94, [1, mn]) + repmat(cols, [4, 1]);
                    obj.PieY = repmat([-.5; -.5; .5; .5].*.94, [1, mn]) + repmat(rows, [4, 1]);
                    obj.pieHdl = fill(obj.ax, obj.PieX, obj.PieY, [0,0,0], 'EdgeColor','none', 'FaceColor',[.9,.9,.9]);
                    obj.pieHdl = reshape(obj.pieHdl, sz);
                case 'barh'
                    obj.PatchX = obj.SX.*(repmat([-.5; -.5; -.5; -.5], [1, mn]) + repmat([0; 1; 1; 0].*.95, [1, mn]).*repmat(tRatio, [4, 1])) + repmat(cols, [4, 1]);
                    obj.PatchY = obj.SY.*repmat([-.5; -.5; .5; .5].*.75, [1, mn]) + repmat(rows, [4, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8, 'LineJoin','chamfer');
                    obj.patchHdl = reshape(obj.patchHdl, sz);
                case 'bar'
                    obj.PatchX = obj.SX.*repmat([-.5; .5; .5; -.5].*.75, [1, mn]) + repmat(cols, [4, 1]);
                    obj.PatchY = obj.SY.*(repmat([.5; .5; .5; .5], [1, mn]) - repmat([1; 1; 0; 0].*.95, [1, mn]).*repmat(tRatio, [4, 1])) + repmat(rows, [4, 1]);
                    obj.patchHdl = fill(obj.ax, obj.PatchX, obj.PatchY, datas(:), 'EdgeColor',[1,1,1].*.3, 'LineWidth',.8, 'LineJoin','chamfer');
                    obj.patchHdl = reshape(obj.patchHdl, sz);
            end

            % Creation of basic objects for box, frame, and tick (box, frame, tick 基础对象创建)
            obj.boxHdl = plot(obj.ax, nan, nan, 'LineWidth', 0.8, 'Color', [1, 1, 1] .* 0.85);
            obj.frameHdl = plot(obj.ax, nan, nan, 'Color','k', 'LineWidth',1, 'LineJoin','miter', 'Visible','off');
            obj.rowTickHdl = plot(obj.ax, nan(sz(1)*3, 1), nan(sz(1)*3, 1), 'Color','k', 'LineWidth',1, 'Visible','off');
            obj.colTickHdl = plot(obj.ax, nan(sz(2)*3, 1), nan(sz(2)*3, 1), 'Color','k', 'LineWidth',1, 'Visible','off');
            obj.RTX = nan(sz(1)*3, 1); obj.RTY = nan(sz(1)*3, 1);
            obj.CTX = nan(sz(2)*3, 1); obj.CTY = nan(sz(2)*3, 1);
            obj.newRTX = nan(sz(1)*3, 1); obj.newRTY = nan(sz(1)*3, 1);
            obj.newCTX = nan(sz(2)*3, 1); obj.newCTY = nan(sz(2)*3, 1);

            % If the Format is 3D, it is rendered separately (如果 Format 是 3d 则单独绘制)
            if obj.Format3DHeight < 1, obj.Format3DHeight = 1; end
            if obj.Format3DTheta < 0, obj.Format3DTheta = 0; end
            if obj.Format3DTheta > pi/2, obj.Format3DTheta = pi/2; end
            if strcmpi(obj.Format, '3d')
                X3 = (repmat([-.32; .32; -.32; .32], [1, mn]) + [0; 0; 1; 1]*tRatio.*obj.Format3DHeight.*cos(obj.Format3DTheta)) + repmat(cols, [4, 1]);
                Y3 = (repmat([-.32; .32; -.32; .32], [1, mn]) - [0; 0; 1; 1]*tRatio.*obj.Format3DHeight.*sin(obj.Format3DTheta)) + repmat(rows, [4, 1]);
                obj.PatchX = X3([1; 2; 4; 4; 3; 1; 1; 3; 3; 3; 4; 3], :);
                obj.PatchY = Y3([2; 2; 4; 3; 3; 1; 2; 4; 3; 4; 4; 4], :);
                indFlip = reshape(1:mn, sz); 
                indFlip = reshape(indFlip(:, end:-1:1), [1, mn]);
                obj.patchHdl = fill(obj.ax, obj.PatchX(:, indFlip), obj.PatchY(:, indFlip), datas(indFlip), 'EdgeColor',[0,0,0], 'LineWidth',.8, 'LineJoin','chamfer');
                obj.patchHdl = fliplr(reshape(obj.patchHdl, sz));
            end

            % Use different box colors for different Formats (为不同 Format 设置不同框颜色)
            switch lower(obj.Format)
                case {'sq', 'rrect', 'shade', 'c2rect', '3d', 'sqfull'}
                    set(obj.boxHdl, 'Visible','off');
                case {'bar', 'barh'}
                    set(obj.boxHdl, 'Color',[0,0,0]);
            end

            if strcmpi(obj.Format, 'shade')
                set(obj.pieHdl(obj.Data >= 0), 'XData',nan(9,1), 'YData',nan(9,1), 'Visible','off')
            end

            [nanR, nanC] = find(isnan(obj.Data));
            obj.TxtNaNXY = zeros(length(nanR), 2);
            obj.TxtNaNXY(:, 1) = obj.CP(nanC);
            obj.TxtNaNXY(:, 2) = obj.RP(nanR);
            if ~isempty(nanR)
                if strcmpi(obj.Format, '3d')
                    obj.nanTextHdl = text(obj.ax, obj.CP(nanC), obj.RP(nanR), ...
                        ' ', 'FontName','Times New Roman', 'HorizontalAlignment','center', 'FontSize',20);
                else
                    obj.nanTextHdl = text(obj.ax, obj.CP(nanC), obj.RP(nanR), ...
                        char(215), 'FontName','Times New Roman', 'HorizontalAlignment','center', 'FontSize',20);
                end

                tind = sub2ind(sz, nanR, nanC);
                if ~isempty(obj.PatchX)
                    obj.PatchX(:, tind) = nan; 
                    obj.PatchY(:, tind) = nan;
                    if size(obj.PatchX, 1) < 4
                        obj.PatchX(4, :) = obj.PatchX(3, :); 
                        obj.PatchY(4, :) = obj.PatchY(3, :);
                    end
                    if strcmpi(obj.Format, '3d')
                        nX = repmat([-.5,.5,.5,-.5].*.98, [length(tind), 1]) + repmat(obj.CP(nanC).', [1, 4]);
                        nY = repmat([-.5,-.5,.5,.5].*.98, [length(tind), 1]) + repmat(obj.RP(nanR).', [1, 4]);
                        set(obj.patchHdl(tind), 'FaceColor', [.9,.9,.9], 'EdgeColor','none');
                    elseif strcmpi(obj.Format, 'sqfull')
                        nX = repmat([-.5,.5,.5,-.5], [length(tind), 1]) + repmat(obj.CP(nanC).', [1, 4]);
                        nY = repmat([-.5,-.5,.5,.5], [length(tind), 1]) + repmat(obj.RP(nanR).', [1, 4]);
                        set(obj.patchHdl(tind), 'FaceColor', [.8,.8,.8], 'EdgeColor','none');
                    else
                        nX = repmat([-.5,.5,.5,-.5].*.98, [length(tind), 1]) + repmat(obj.CP(nanC).', [1, 4]);
                        nY = repmat([-.5,-.5,.5,.5].*.98, [length(tind), 1]) + repmat(obj.RP(nanR).', [1, 4]); 
                        set(obj.patchHdl(tind), 'FaceColor', [.8,.8,.8], 'EdgeColor','none');
                    end
                    nXYC = [num2cell(nX, 2), num2cell(nY, 2)];
                    set(obj.patchHdl(tind), {'XData', 'YData'}, nXYC)
                    obj.PatchX(1:4, tind) = repmat([-.5;.5;.5;-.5].*.98, [1, length(tind)]) + repmat(obj.CP(nanC), [4, 1]);
                    obj.PatchY(1:4, tind) = repmat([-.5;-.5;.5;.5].*.98, [1, length(tind)]) + repmat(obj.RP(nanR), [4, 1]);
                end
                if ~isempty(obj.PieX)
                    obj.PieX(:, tind) = nan; obj.PieX(:, tind) = nan;
                    set(obj.pieHdl(tind), 'XData', nan(4,1), 'YData', nan(4,1), 'FaceColor',[0,0,0]);
                end
            end

            if strcmpi(obj.Format, 'txt') || strcmpi(obj.Format, 'text')
                obj.setText()
            end

            % ## Add tick labels 
            tflag = true;
            if isempty(obj.VarName) % Create default variable names (生成默认变量名)
                obj.VarName = compose('Var-%d', 1:length(obj.Data));
                tflag = false;
            end
            % Add row labels ('Visible', 'off') (添加行标签，默认隐藏)
            rows = 1:sz(1); tind = mod(rows - 1, length(obj.VarName)) + 1;
            obj.RTLDir = zeros(sz(1), 4); 
            obj.RTLDir(:, 1) = .5; obj.RTLDir(:, 2) = obj.RP(rows); 
            obj.RTLDir(:, 3) = .5 - obj.TickLabelOffset; obj.RTLDir(:, 4) = obj.RP(rows);
            obj.rowLabelHdl = text(obj.ax, obj.RTLDir(:, 3), obj.RTLDir(:, 4), obj.VarName(tind), ...
                'HorizontalAlignment','right', 'FontName','Times New Roman', 'FontSize',12, 'Visible','off');
            % Add column labels ('Visible', 'off') (添加列标签，默认隐藏)
            cols = 1:sz(2); tind = mod(cols - 1, length(obj.VarName)) + 1;
            obj.CTLDir = zeros(sz(2), 4);
            obj.CTLDir(:, 1) = obj.CP(cols); obj.CTLDir(:, 2) = obj.RP(end) + .5;
            obj.CTLDir(:, 3) = obj.CP(cols); obj.CTLDir(:, 4) = obj.RP(end) + .5 + obj.TickLabelOffset;
            obj.colLabelHdl = text(obj.ax, obj.CTLDir(:, 3), obj.CTLDir(:, 4), obj.VarName(tind), ...
                'HorizontalAlignment','right', 'FontName','Times New Roman', 'FontSize',12, 'Rotation',30, 'Visible','off');

            % ## Add group labels 
            if isempty(obj.RowGroupName), obj.RowGroupName = compose('Group-%d', unique(obj.RowGroup)); end
            if isempty(obj.ColGroupName), obj.ColGroupName = compose('Group-%d', unique(obj.ColGroup)); end
            % Add row group labels ('Visible', 'off') (添加行分组标签，默认隐藏)
            obj.RGLDir = zeros(max(obj.RowGroup), 4); 
            obj.rowGroupLabelHdl = gobjects(1, max(obj.RowGroup));
            for row = 1:max(obj.RowGroup)
                tind = mod(row - 1, length(obj.RowGroupName)) + 1;
                obj.rowGroupLabelHdl(row) = text(obj.ax, 0.5 - obj.GroupLabelOffset, obj.RGP(row), ...
                    obj.RowGroupName{tind}, 'HorizontalAlignment','center', 'Rotation',90, ...
                    'FontName','Times New Roman', 'FontSize',15, 'Visible','off');
                obj.RGLDir(row, :) = [.5, obj.RGP(row), .5 - obj.GroupLabelOffset, obj.RGP(row)];
            end
            % Add col group labels ('Visible', 'off') (添加列分组标签，默认隐藏)
            obj.CGLDir = zeros(max(obj.ColGroup), 4); 
            obj.colGroupLabelHdl = gobjects(1, max(obj.ColGroup));
            for col = 1:max(obj.ColGroup)
                tind = mod(col - 1, length(obj.ColGroupName)) + 1;
                obj.colGroupLabelHdl(col) = text(obj.ax, obj.CGP(col), obj.RP(end) + .5 + obj.GroupLabelOffset, ...
                    obj.ColGroupName{tind}, 'HorizontalAlignment','center', 'Rotation',0, ...
                    'FontName','Times New Roman', 'FontSize',15, 'Visible','off');
                obj.CGLDir(col, :) = [obj.CGP(col), obj.RP(end) + .5, obj.CGP(col), obj.RP(end) + .5 + obj.GroupLabelOffset];
            end

            % Apply 'Type' if not full
            if strcmpi(obj.Type, 'full')
                obj.setBoxXY()
                obj.setFrameXY()
            else
                obj.setType(obj.Type);
            end

            if tflag, obj.setVarName(); end
            if ~isempty(obj.RowName), obj.setRowName(); end
            if ~isempty(obj.ColName), obj.setColName(); end

            if strcmpi(obj.Format, '3d')
                obj.setFrame(); axis(obj.ax, 'tight');
            end

            addlistener(obj.fig, 'Colormap', 'PostSet', @(src, evt) obj.refreshTxtColor(src, evt));
            addlistener(obj.ax , 'Colormap', 'PostSet', @(src, evt) obj.refreshTxtColor(src, evt));
            addlistener(obj.ax , 'CLim'    , 'PostSet', @(src, evt) obj.refreshTxtColor(src, evt));

            if nargout == 1
                varargout = {obj};
            end
        end

        function refreshTxtColor(obj, ~, ~)
            obj.Colormap = obj.ax.Colormap;
            if obj.txtShown && (~obj.isFrozen) && (~obj.txtFixed)
                obj.setText();
            end
        end

% =========================================================================
% Set indices of row/col ticks to display (设置要显示的行列刻度索引)
% =========================================================================
        function varargout = setRowTickIndices(obj, indices)

            if nargin < 2
                indices = obj.RowTickIndices;
            else
                obj.RowTickIndices = indices;
            end

            obj.ax.YTick = obj.RP(indices);
            if ismember(lower(obj.Type), {'varu', 'varl', 'col'})
                obj.ax.YTickLabel = '';
            else
                if ~isempty(obj.RowName)
                    tind = mod(indices - 1, length(obj.RowName)) + 1;
                    obj.ax.YTickLabel = strrep(strrep(obj.RowName(tind), '\', ' '), '_', ' ');
                else
                    trs = compose('%d', 1:size(obj.Data, 1));
                    obj.ax.YTickLabel = trs(indices);
                end
            end

            if obj.rowShown
                set(obj.rowLabelHdl, 'Visible', 'off')
                set(obj.rowLabelHdl(indices), 'Visible', 'on')

                tickmask = nan(3, size(obj.Data, 1));
                tickmask(:, indices) = 1;
                obj.rowTickHdl.XData = obj.newRTX.*tickmask(:);
                obj.rowTickHdl.YData = obj.newRTY.*tickmask(:);
            end

            obj.tickConfigured = true;
            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setColTickIndices(obj, indices)

            if nargin < 2
                indices = obj.ColTickIndices;
            else
                obj.ColTickIndices = indices;
            end

            obj.ax.XTick = obj.CP(indices);
            if ismember(lower(obj.Type), {'varu', 'varl', 'row'})
                obj.ax.XTickLabel = '';
            else
                if ~isempty(obj.ColName)
                    tind = mod(indices - 1, length(obj.ColName)) + 1;
                    obj.ax.XTickLabel = strrep(strrep(obj.ColName(tind), '\', ' '), '_', ' ');
                else
                    tcs = compose('%d', 1:size(obj.Data, 2));
                    obj.ax.XTickLabel = tcs(indices);
                end
            end

            if obj.colShown
                set(obj.colLabelHdl, 'Visible', 'off')
                set(obj.colLabelHdl(indices), 'Visible', 'on')

                tickmask = nan(3, size(obj.Data, 2));
                tickmask(:, indices) = 1;
                obj.colTickHdl.XData = obj.newCTX.*tickmask(:);
                obj.colTickHdl.YData = obj.newCTY.*tickmask(:);
            end

            obj.tickConfigured = true;
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

            dataVec = obj.Data(:); valid = ~isnan(dataVec); tRatio = abs(dataVec)./obj.maxV;
            if ~obj.txtShown
                [cols, rows] = meshgrid(1:size(obj.Data, 2), 1:size(obj.Data, 1));
                rows = obj.RP(rows); cols = obj.CP(cols); 
                strCell = cell(size(dataVec)); 
                strCell(valid) = cellstr(num2str(dataVec(valid), '%.2f'));
                strCell(~valid) = {''};

                tRatio = abs(dataVec)./obj.maxV;
                obj.TxtXY = zeros(length(dataVec), 2);
                if strcmpi(obj.Format, '3d')
                    hAll = text(obj.ax, cols(:) + cos(obj.Format3DTheta).*tRatio.*obj.Format3DHeight, ...
                         rows(:) - sin(obj.Format3DTheta).*tRatio.*obj.Format3DHeight, strCell, ...
                        'FontName', 'Times New Roman', ...
                        'HorizontalAlignment', 'center', ...
                        'Visible', 'off');
                    obj.TxtXY(:, 1) = cols(:) + cos(obj.Format3DTheta).*tRatio.*obj.Format3DHeight;
                    obj.TxtXY(:, 2) = rows(:) - sin(obj.Format3DTheta).*tRatio.*obj.Format3DHeight; 
                elseif strcmpi(obj.Format, 'tril') || strcmpi(obj.Format, 'trill')
                    hAll = text(obj.ax, cols(:) - 1/6, rows(:) + 1/6, strCell, ...
                        'FontName', 'Times New Roman', ...
                        'HorizontalAlignment', 'center', 'Rotation', -45, ...
                        'Visible', 'off');
                    obj.TxtXY(:, 1) = cols(:) - 1/6; 
                    obj.TxtXY(:, 2) = rows(:) + 1/6; 
                elseif strcmpi(obj.Format, 'triu') || strcmpi(obj.Format, 'triur')
                    hAll = text(obj.ax, cols(:) + 1/6, rows(:) - 1/6, strCell, ...
                        'FontName', 'Times New Roman', ...
                        'HorizontalAlignment', 'center', 'Rotation', -45, ...
                        'Visible', 'off');
                    obj.TxtXY(:, 1) = cols(:) + 1/6; 
                    obj.TxtXY(:, 2) = rows(:) - 1/6; 
                elseif strcmpi(obj.Format, 'trilr')
                    hAll = text(obj.ax, cols(:) + 1/6, rows(:) + 1/6, strCell, ...
                        'FontName', 'Times New Roman', ...
                        'HorizontalAlignment', 'center', 'Rotation', 45, ...
                        'Visible', 'off');
                    obj.TxtXY(:, 1) = cols(:) + 1/6; 
                    obj.TxtXY(:, 2) = rows(:) + 1/6;
                elseif strcmpi(obj.Format, 'triul')
                    hAll = text(obj.ax, cols(:) - 1/6, rows(:) - 1/6, strCell, ...
                        'FontName', 'Times New Roman', ...
                        'HorizontalAlignment', 'center', 'Rotation', 45, ...
                        'Visible', 'off');
                    obj.TxtXY(:, 1) = cols(:) - 1/6; 
                    obj.TxtXY(:, 2) = rows(:) - 1/6;
                elseif strcmpi(obj.Format, 'arrow')
                    tOffset = ((dataVec < 0) - .5)./5.*obj.SY;
                    hAll = text(obj.ax, cols(:), rows(:) + tOffset, strCell, ...
                        'FontName', 'Times New Roman', ...
                        'HorizontalAlignment', 'center', ...
                        'Visible', 'off');
                    obj.TxtXY(:, 1) = cols(:); 
                    obj.TxtXY(:, 2) = rows(:) + tOffset;
                else
                    if obj.XYTReset
                        hAll = text(obj.ax, obj.newTxtXY(:, 1), obj.newTxtXY(:, 2), strCell, ...
                            'FontName', 'Times New Roman', ...
                            'HorizontalAlignment', 'center', ...
                            'Visible', 'off');
                    else
                        hAll = text(obj.ax, cols(:), rows(:), strCell, ...
                            'FontName', 'Times New Roman', ...
                            'HorizontalAlignment', 'center', ...
                            'Visible', 'off');
                    end
                    obj.TxtXY(:, 1) = cols(:);
                    obj.TxtXY(:, 2) = rows(:);
                end
                if any(~valid)
                    hAll(~valid) = obj.nanTextHdl;
                end
                obj.textHdl = reshape(hAll, size(obj.Data));
                obj.txtShown = true;
            end

            if isempty(varargin)
                varargin = {'Visible','on'};
            end
            if islogical(varargin{1})
                set(obj.textHdl(varargin{1}), varargin{2:end})
            elseif isnumeric(varargin{1})
                M = varargin{1}; N = varargin{2};
                if all(size(M) == size(N))
                    tind = sub2ind(size(obj.Data), M, N);
                    set(obj.textHdl(tind), varargin{3:end})
                else
                    if isempty(M); M = 1:size(obj.Data, 1); end
                    if isempty(N); N = 1:size(obj.Data, 2); end
                    obj.textHdl(M, N)
                    set(obj.textHdl(M, N), varargin{3:end})
                end
            else
                % Get grayscale of current colormap (获取当前颜色映射的灰度值)
                cmp = get(obj.ax, 'Colormap');
                climit  = get(obj.ax, 'CLim');

                dataVec = obj.Data(:);
                valid = ~isnan(dataVec);
                counts = floor((dataVec - climit(1))./diff(climit).*size(cmp, 1)) + 1;
                counts(counts > size(cmp, 1)) = size(cmp, 1);
                counts(counts < 1) = 1;
                counts(~valid) = 1;

                % Set text color based on format; 根据格式设置文本颜色
                if strcmpi(obj.Format, 'txt') || strcmpi(obj.Format, 'text')
                    % Use actual color for 'text'/'txt' format; 对于 'text'/'txt' 格式使用实际颜色
                    colors = cmp(counts, :);
                    colors(~valid, :) = 0;
                    set(obj.textHdl, {'Color'}, num2cell(colors, 2))
                elseif ismember(lower(obj.Format), {'pie','bcirc','hex','star','asq','acirc','arrect','acust'})
                    graymap = mean(cmp, 2);
                    grays = repmat(graymap(counts, :) < .5, [1, 3]);
                    grays(~valid, :) = 0;
                    grays(tRatio < .3, :) = 0;
                    set(obj.textHdl, {'Color'}, num2cell(grays, 2))
                elseif ismember(lower(obj.Format), {'teardrop','bar','barh','moon'})
                    graymap = mean(cmp, 2);
                    grays = repmat(graymap(counts, :) < .5, [1, 3]);
                    grays(~valid, :) = 0;
                    grays(tRatio < .7, :) = 0;
                    set(obj.textHdl, {'Color'}, num2cell(grays, 2))
                elseif ismember(lower(obj.Format), {'oval'})
                    graymap = mean(cmp, 2);
                    grays = repmat(graymap(counts, :) < .5, [1, 3]);
                    grays(~valid, :) = 0;
                    grays(tRatio > .7, :) = 0;
                    set(obj.textHdl, {'Color'}, num2cell(grays, 2))
                elseif strcmpi(obj.Format, 'donut')
                    set(obj.textHdl, 'Color',[0,0,0])
                else
                    % Use black/white contrast for other formats; 其他格式使用黑白对比色
                    graymap = mean(cmp, 2);
                    grays = repmat(graymap(counts, :) < .5, [1, 3]);
                    grays(~valid, :) = 0;
                    set(obj.textHdl, {'Color'}, num2cell(grays, 2))
                end

                set(obj.textHdl, 'Visible','on', varargin{:});
                if ismember('color', lower(varargin(1:2:(length(varargin) - 1))))
                    obj.txtFixed = true;
                end

                set(obj.textHdl(obj.Mask), 'Visible','off');
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

            pieFlag = strcmpi(obj.Format, 'pie')   || strcmpi(obj.Format, 'donut') || ...
                      strcmpi(obj.Format, 'bcirc') || strcmpi(obj.Format, 'shade') || ...
                      strcmpi(obj.Format, 'moon')  || strcmpi(obj.Format, 'teardrop');
            if islogical(varargin{1})
                set(obj.patchHdl(varargin{1}), varargin{2:end});
                if pieFlag
                    set(obj.pieHdl(varargin{1}), varargin{2:end});
                end
            elseif isnumeric(varargin{1})
                M = varargin{1}; N = varargin{2};
                if all(size(M) == size(N))
                    tind = sub2ind(size(obj.Data), M, N);
                    set(obj.patchHdl(tind), varargin{3:end});
                    if pieFlag
                        set(obj.pieHdl(tind), varargin{3:end});
                    end
                else
                    if isempty(M); M = 1:size(obj.Data, 1); end
                    if isempty(N); N = 1:size(obj.Data, 2); end
                    set(obj.patchHdl(M, N), varargin{3:end});
                    if pieFlag
                        set(obj.pieHdl(M, N), varargin{3:end});
                    end
                end
            else
                set(obj.patchHdl(~isnan(obj.Data)), varargin{:});
                if pieFlag
                    set(obj.pieHdl(~isnan(obj.Data)), varargin{:});
                end
            end
            if nargout == 1
                varargout = {obj};
            end
        end
% =========================================================================
% Set properties for grid handle (设置网格样式)
% =========================================================================  
        function varargout = setGrid(obj, varargin)
            % obj.setGrid(varargin) - Set properties for grid handle (设置网格样式)
            obj.GX = []; obj.GY = [];
            for gi = 1:max(obj.RowGroup)
                for gj = 1:max(obj.ColGroup)
                    posi = obj.RP(obj.RowGroup == gi);
                    posj = obj.CP(obj.ColGroup == gj);
                    M = length(posi);
                    N = length(posj);
                    switch lower(obj.Type)
                        case {'full', 'row', 'col'}
                            posi = obj.RP(obj.RowGroup == gi);
                            posj = obj.CP(obj.ColGroup == gj);
                            rowY = posi;
                            rowX = [posj(1); posj(end); nan]*ones(size(rowY));
                            rowY = [1; 1; nan]*rowY;
                            colX = posj;
                            colY = [posi(1); posi(end); nan]*ones(size(colX));
                            colX = [1; 1; nan]*colX;
                            obj.GX = [obj.GX; rowX(:); colX(:)];
                            obj.GY = [obj.GY; rowY(:); colY(:)];
                        case {'triu0', 'linku', 'varu'}
                            if gi == gj && length(posi) > 1
                                gX1 = [1; 1; nan]*posj(2:end);
                                gY1 = [posi(1).*ones(1, N - 1);
                                    posi(1:(end - 1));
                                    nan(1, N - 1)];
                                gX2 = [posj(end).*ones(1, N - 1);
                                    posj(2:end);
                                    nan(1, N - 1)];
                                gY2 = [1; 1; nan]*posj(1:(end - 1));
                                obj.GX = [obj.GX; gX1(:); gX2(:)];
                                obj.GY = [obj.GY; gY1(:); gY2(:)];
                            elseif gj > gi
                                gX1 = [1; 1; nan]*posj;
                                gY1 = [posi(1); posi(end); nan]*ones(1, N);
                                gX2 = [posj(1); posj(end); nan]*ones(1, M);
                                gY2 = [1; 1; nan]*posi;
                                obj.GX = [obj.GX; gX1(:); gX2(:)];
                                obj.GY = [obj.GY; gY1(:); gY2(:)];
                            end
                        case {'tril0', 'linkl', 'varl'}
                            if gi == gj && length(posi) > 1
                                gX1 = [1; 1; nan]*posj(1:(end - 1));
                                gY1 = [posi(end).*ones(1, N - 1);
                                    posi(2:end);
                                    nan(1, N - 1)];
                                gX2 = [posj(1).*ones(1, N - 1);
                                    posj(1:(end - 1));
                                    nan(1, N - 1)];
                                gY2 = [1; 1; nan]*posj(2:end);
                                obj.GX = [obj.GX; gX1(:); gX2(:)];
                                obj.GY = [obj.GY; gY1(:); gY2(:)];
                            elseif gj < gi
                                gX1 = [1; 1; nan]*posj;
                                gY1 = [posi(1); posi(end); nan]*ones(1, N);
                                gX2 = [posj(1); posj(end); nan]*ones(1, M);
                                gY2 = [1; 1; nan]*posi;
                                obj.GX = [obj.GX; gX1(:); gX2(:)];
                                obj.GY = [obj.GY; gY1(:); gY2(:)];
                            end
                        case  'triu'
                            if gi == gj
                                gX1 = [1; 1; nan]*posj;
                                gY1 = [posi(1).*ones(1, N); posi; nan(1, N)];
                                gX2 = [posj(end).*ones(1, N); posj; nan(1, N)];
                                gY2 = [1; 1; nan]*posi;
                                obj.GX = [obj.GX; gX1(:); gX2(:)];
                                obj.GY = [obj.GY; gY1(:); gY2(:)];
                            elseif gj > gi
                                gX1 = [1; 1; nan]*posj;
                                gY1 = [posi(1); posi(end); nan]*ones(1, N);
                                gX2 = [posj(1); posj(end); nan]*ones(1, M);
                                gY2 = [1; 1; nan]*posi;
                                obj.GX = [obj.GX; gX1(:); gX2(:)];
                                obj.GY = [obj.GY; gY1(:); gY2(:)];
                            end
                        case  'tril'
                            if gi == gj
                                gX1 = [1; 1; nan]*posj;
                                gY1 = [posi; posi(end).*ones(1, N); nan(1, N)];
                                gX2 = [posj(1).*ones(1, N); posj; nan(1, N)];
                                gY2 = [1; 1; nan]*posi;
                                obj.GX = [obj.GX; gX1(:); gX2(:)];
                                obj.GY = [obj.GY; gY1(:); gY2(:)];
                            elseif gj < gi
                                gX1 = [1; 1; nan]*posj;
                                gY1 = [posi(1); posi(end); nan]*ones(1, N);
                                gX2 = [posj(1); posj(end); nan]*ones(1, M);
                                gY2 = [1; 1; nan]*posi;
                                obj.GX = [obj.GX; gX1(:); gX2(:)];
                                obj.GY = [obj.GY; gY1(:); gY2(:)];
                            end
                    end
                end
            end
            set(obj.gridHdl, 'XData',obj.GX, 'YData',obj.GY, varargin{:})
            if nargout == 1
                varargout = {obj};
            end
        end
% =========================================================================
% Set font name for all labels (设置全部标签字体)
% =========================================================================
        function varargout = setFontName(obj, fname)
            % obj.setFontName(fname) - Set the font name of all existing labels (设置所有已绘制标签的字体名称)
            set(obj.ax, 'FontName',fname)
            if ~isempty(obj.nanTextHdl)
                set(obj.nanTextHdl, 'FontName',fname)
            end
            if ~isempty(obj.textHdl)
                set(obj.textHdl, 'FontName',fname)
            end
            if ~isempty(obj.rowLabelHdl)
                set(obj.rowLabelHdl, 'FontName',fname)
            end
            if ~isempty(obj.colLabelHdl)
                set(obj.colLabelHdl, 'FontName',fname)
            end
            if ~isempty(obj.rowGroupLabelHdl)
                set(obj.rowGroupLabelHdl, 'FontName',fname)
            end
            if ~isempty(obj.colGroupLabelHdl)
                set(obj.colGroupLabelHdl, 'FontName',fname)
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
            set(obj.boxHdl,'Visible','on', varargin{:})
            if nargout == 1
                varargout = {obj};
            end
        end
% =========================================================================
% Set properties for frame handle (设置外轮廓样式)
% =========================================================================
        function varargout = setFrame(obj, varargin)
            % obj.setFrame(varargin) - Set properties for frame and tick handle (设置外轮廓样式)
            set(obj.frameHdl, 'Visible','on', varargin{:})
            if ~obj.XYTReset
                obj.TickLength(obj.TickLength < 0) = 0;
                obj.TickLength(obj.TickLength > .5) = .5;
        
                if isempty(obj.RowName)
                    obj.RowName = compose('%d', 1:size(obj.Data, 1));
                    obj.setRowName();
                end
                if isempty(obj.ColName)
                    obj.ColName = compose('%d', 1:size(obj.Data, 2));
                    obj.setColName();
                end
                obj.ax.XColor = 'none';
                obj.ax.YColor = 'none';
        
                set(obj.rowTickHdl, 'Visible','on')
                set(obj.colTickHdl, 'Visible','on')
                obj.setRowLabelLocation()
                obj.setColLabelLocation()
                
                try
                    obj.Colorbar.TickLength = .005;
                    obj.Colorbar.TickDirection = 'out';
                    obj.Colorbar.LineWidth = obj.frameHdl.LineWidth;
                catch
                end
        
                if strcmpi(obj.Type, 'row') || strcmpi(obj.Type, 'varu') || strcmpi(obj.Type, 'varl')
                    obj.ColTickIndices = [];
                end
                if strcmpi(obj.Type, 'col')
                    obj.RowTickIndices = [];
                end
            end

            obj.rowShown = true;
            obj.colShown = true;
            obj.setRowTickIndices()
            obj.setColTickIndices()
            if ~isempty(varargin)
                set(obj.rowTickHdl, varargin{:})
                set(obj.colTickHdl, varargin{:})
            end

            if nargout == 1
                varargout = {obj};
            end
        end

        function setRowTickXY(obj)
            % obj.setRowTickXY() - Compute the row tick coordinates (计算行刻度坐标)
            [M, ~] = size(obj.Data);
            switch obj.RowLabelLocation
                case 'left'
                    switch lower(obj.Type)
                        case {'triu', 'varu'}
                            X = nan(3*M, 1); Y = nan(3*M, 1);
                        case {'tril', 'varl'}
                            X = [.5; .5 - obj.TickLength; nan]*ones(1, M);
                            Y = [1; 1; nan]*obj.RP(1:M);
                        case {'triu0', 'linku'}
                            X = nan(3*M, 1); Y = nan(3*M, 1);
                        case {'tril0', 'linkl'}
                            X = [.5; .5 - obj.TickLength; nan]*ones(1, M);
                            Y = [1; 1; nan]*[nan, obj.RP(2:M)];
                        case {'full','row','col'}
                            X = [.5; .5 - obj.TickLength; nan]*ones(1, M);
                            Y = [1; 1; nan]*obj.RP(1:M);
                    end
                case 'right'
                    switch lower(obj.Type)
                        case {'triu', 'varu'}
                            X = [obj.CP(end) + .5; obj.CP(end) + .5 + obj.TickLength; nan]*ones(1, M);
                            Y = [1; 1; nan]*obj.RP(1:M);
                        case {'tril', 'varl'}
                            X = nan(3*M, 1); Y = nan(3*M, 1);
                        case {'triu0', 'linku'}
                            X = [obj.CP(end) + .5; obj.CP(end) + .5 + obj.TickLength; nan]*ones(1, M);
                            Y = [1; 1; nan]*[obj.RP(1:(M - 1)), nan];
                        case {'tril0', 'linkl'}
                            X = nan(3, 1); Y = nan(3, 1);
                        case {'full','row','col'}
                            X = [obj.CP(end) + .5; obj.CP(end) + .5 + obj.TickLength; nan]*ones(1, M);
                            Y = [1; 1; nan]*obj.RP(1:M);
                    end
                case 'diag'
                    switch lower(obj.Type)
                        case 'triu'
                            X = [obj.CP(1:M) - .5; obj.CP(1:M) - .5 - obj.TickLength; nan(1, M)];
                            Y = [1; 1; nan]*obj.RP(1:M);
                        case 'tril'
                            X = [obj.CP(1:M) + .5; obj.CP(1:M) + .5 + obj.TickLength; nan(1, M)];
                            Y = [1; 1; nan]*obj.RP(1:M);
                        case {'triu0', 'linku'}
                            X = [[obj.CP(2:M), nan] - .5; [obj.CP(2:M), nan] - .5 - obj.TickLength; nan(1, M)];
                            Y = [1; 1; nan]*[obj.RP(1:(M - 1)), nan];
                        case {'tril0', 'linkl'}
                            X = [[nan, obj.CP(1:(M - 1))] + .5; [nan, obj.CP(1:(M - 1))] + .5 + obj.TickLength; nan(1, M)];
                            Y = [1; 1; nan]*[nan, obj.RP(2:M)];
                        case {'varu', 'varl'}
                            X = nan(3*M, 1); Y = nan(3*M, 1);
                    end
            end
            obj.RTX = X(:); obj.RTY = Y(:);
            obj.newRTX = X(:); obj.newRTY = Y(:);
            set(obj.rowTickHdl, 'XData',obj.RTX, 'YData',obj.RTY)
        end

        function setColTickXY(obj)
            % obj.setColTickXY() - Compute the col tick coordinates (计算列刻度坐标)
            [~, N] = size(obj.Data);
            switch obj.ColLabelLocation
                case 'top'
                    switch lower(obj.Type)
                        case {'triu', 'varu'}
                            Y = [.5; .5 - obj.TickLength; nan]*ones(1, N);
                            X = [1; 1; nan]*obj.CP(1:N);
                        case {'tril', 'varl'}
                            X = nan(3*N, 1); Y = nan(3*N, 1);
                        case {'triu0', 'linku'}
                            Y = [.5; .5 - obj.TickLength; nan]*ones(1, N);
                            X = [1; 1; nan]*[nan, obj.CP(2:N)];
                        case {'tril0', 'linkl'}
                            X = nan(3*N, 1); Y = nan(3*N, 1);
                        case {'full','row','col'}
                            Y = [.5; .5 - obj.TickLength; nan]*ones(1, N);
                            X = [1; 1; nan]*obj.CP(1:N);
                    end
                case 'bottom'
                    switch lower(obj.Type)
                        case {'triu', 'varu'}
                            X = nan(3*N, 1); Y = nan(3*N, 1);
                        case {'tril', 'varl'}
                            Y = [obj.RP(end) + .5; obj.RP(end) + .5 + obj.TickLength; nan]*ones(1, N);
                            X = [1; 1; nan]*obj.CP(1:N);
                        case {'triu0', 'linku'}
                            X = nan(3*N, 1); Y = nan(3*N, 1);
                        case {'tril0', 'linkl'}
                            Y = [obj.RP(end) + .5; obj.RP(end) + .5 + obj.TickLength; nan]*ones(1, N);
                            X = [1; 1; nan]*[obj.CP(1:(N - 1)), nan];
                        case {'full','row','col'}
                            Y = [obj.RP(end) + .5; obj.RP(end) + .5 + obj.TickLength; nan]*ones(1, N);
                            X = [1; 1; nan]*obj.CP(1:N);
                    end
                case 'diag'
                    switch lower(obj.Type)
                        case 'triu'
                            Y = [obj.RP(1:N) + .5; obj.RP(1:N) + .5 + obj.TickLength; nan(1, N)];
                            X = [1; 1; nan]*obj.CP(1:N);
                        case 'tril'
                            Y = [obj.RP(1:N) - .5; obj.RP(1:N) - .5 - obj.TickLength; nan(1, N)];
                            X = [1; 1; nan]*obj.CP(1:N);
                        case {'triu0', 'linku'}
                            Y = [[nan, obj.RP(1:(N - 1))] + .5; [nan, obj.RP(1:(N - 1))] + .5 + obj.TickLength; nan(1, N)];
                            X = [1; 1; nan]*[nan, obj.CP(2:N)];
                        case {'tril0', 'linkl'}
                            Y = [[obj.RP(2:N), nan] - .5; [obj.RP(2:N), nan] - .5 - obj.TickLength; nan(1, N)];
                            X = [1; 1; nan]*[obj.CP(1:(N - 1)), nan];
                        case {'varu', 'varl'}
                            X = nan(3*N, 1); Y = nan(3*N, 1);
                    end
            end
            obj.CTX = X(:); obj.CTY = Y(:);
            obj.newCTX = X(:); obj.newCTY = Y(:);
            set(obj.colTickHdl, 'XData',obj.CTX, 'YData',obj.CTY)
        end

% =========================================================================
% Set triangular type (设置三角样式)
% =========================================================================
        function varargout = setType(obj, Type)
            % obj.setType(Type) - Adjust display to show only triangular part of the matrix based on Type
            % (根据类型调整显示，仅展示矩阵的三角部分)
            %
            % Type:
            %   'triu'   : upper triangle (including diagonal)  : 上三角部分 (含对角线)
            %   'tril'   : lower triangle (including diagonal)  : 下三角部分 (含对角线)
            %   'triu0'  : upper triangle without diagonal      : 扣除对角线上三角部分 (不含对角线)
            %   'tril0'  : lower triangle without diagonal      : 扣除对角线下三角部分 (不含对角线)
            %   'linkl'  : lower triangle for mantel links      : 适配 mantel 链接的下三角
            %   'linku'  : upper triangle for mantel links      : 适配 mantel 链接的上三角
            %   'row'    : show row labels & ticks only         : 仅显示行标签及行刻度
            %   'col'    : show col labels & ticks only         : 仅显示列标签及列刻度
            %   'varu'   : upper triangle (var-labels diagonal) : 上三角部分 (变量名对角线)
            %   'varl'   : lower triangle (var-labels diagonal) : 下三角部分 (变量名对角线)
        
            % mustBeAllowedTriType(Type)
            if (size(obj.Data, 1) == size(obj.Data, 2) && isequal(obj.RowGroup, obj.ColGroup)) ...
                    || (strcmpi(Type, 'row') || strcmpi(Type, 'col') || strcmpi(Type, 'full'))
                obj.Type = Type;
                if (strcmpi( obj.Type, 'row') || strcmpi(obj.Type, 'col') || strcmpi(Type, 'full'))
                    if isempty(obj.RowName); obj.RowName = compose('%d', 1:size(obj.Data, 1)); end
                    if isempty(obj.ColName); obj.ColName = compose('%d', 1:size(obj.Data, 1)); end
                else
                    obj.RowName = obj.VarName;
                    obj.ColName = obj.VarName;
                end
                obj.setRowName()
                obj.setColName()

                % Hide axes labels and adjust axis location (隐藏坐标轴标签，调整轴位置)
                obj.ax.XColor = 'none';
                obj.ax.YColor = 'none';
                
                switch lower(obj.Type)
                    case {'triu', 'triu0'}; obj.RowLabelLocation = 'diag'; obj.ColLabelLocation = 'top';
                    case {'tril', 'tril0'}; obj.RowLabelLocation = 'left'; obj.ColLabelLocation = 'diag';
                    case {'linku'}; obj.RowLabelLocation = 'right'; obj.ColLabelLocation = 'top';
                    case {'row', 'col'}; obj.RowLabelLocation = 'left'; obj.ColLabelLocation = 'top';
                    case {'varu', 'varl'}; obj.RowLabelLocation = 'diag'; obj.ColLabelLocation = 'diag';
                    otherwise; obj.RowLabelLocation = 'left'; obj.ColLabelLocation = 'bottom';
                end
        
                % Apply specific triangular type (应用特定三角类型)
                %   'triu'   : upper triangle (including diagonal)  : 上三角部分 (含对角线)
                %   'tril'   : lower triangle (including diagonal)  : 下三角部分 (含对角线)
                %   'triu0'  : upper triangle without diagonal      : 扣除对角线上三角部分 (不含对角线)
                %   'tril0'  : lower triangle without diagonal      : 扣除对角线下三角部分 (不含对角线)
                %   'linkl'  : lower triangle for mantel links      : 适配 mantel 链接的下三角
                %   'linku'  : upper triangle for mantel links      : 适配 mantel 链接的上三角
                %   'row'    : show row labels & ticks only         : 仅显示行标签及行刻度
                %   'col'    : show col labels & ticks only         : 仅显示列标签及列刻度
                %   'varu'   : upper triangle (var-labels diagonal) : 上三角部分 (变量名对角线)
                %   'varl'   : lower triangle (var-labels diagonal) : 下三角部分 (变量名对角线)
                switch lower(obj.Type)
                    case 'triu'   % upper triangle (including diagonal) (上三角含对角线)
                        % Hide lower-left patches/texts (隐藏左下部分图形和文本)
                        obj.Mask = triu(ones(size(obj.Data))) == 0;
                    case 'tril'   % lower triangle (including diagonal) (下三角含对角线)
                        % Hide upper-right patches/texts (隐藏右上部分图形和文本)
                        obj.Mask = tril(ones(size(obj.Data))) == 0;
                    case {'triu0', 'linku', 'varu'}  % upper triangle without diagonal (扣除对角线，上三角不含对角线)
                        % Hide diagonal and lower-left patches/texts (隐藏对角线及左下部分)
                        obj.Mask = tril(ones(size(obj.Data))) == 1;
                        set(obj.colLabelHdl(1), 'Visible', 'off');
                        set(obj.rowLabelHdl(size(obj.Data, 1)), 'Visible', 'off');
                    case {'tril0', 'linkl', 'varl'}  % lower triangle without diagonal (扣除对角线，下三角不含对角线)
                        % Hide diagonal and upper-right patches/texts (隐藏对角线及右上部分)
                        obj.Mask = triu(ones(size(obj.Data))) == 1;
                        set(obj.rowLabelHdl(1), 'Visible', 'off');
                        set(obj.colLabelHdl(size(obj.Data, 2)), 'Visible', 'off');
                end

                if ~(strcmpi(obj.Format,'txt') || strcmpi(obj.Format,'text'))
                    set(obj.patchHdl(obj.Mask), 'Visible', 'off');
                end
                if ~isempty(obj.textHdl)
                    set(obj.textHdl(obj.Mask),  'Visible', 'off');
                end
                if strcmpi(obj.Format, 'pie') || strcmpi(obj.Format, 'donut') || ...
                        strcmpi(obj.Format, 'bcirc') || strcmpi(obj.Format, 'shade') || ...
                        strcmpi(obj.Format, '3d') || strcmpi(obj.Format, 'moon') || ...
                        strcmpi(obj.Format, 'teardrop')
                    set(obj.pieHdl(obj.Mask), 'Visible', 'off');
                end

                obj.RowTickIndices = 1:size(obj.Data, 1);
                obj.ColTickIndices = 1:size(obj.Data, 2);
                switch lower(obj.Type)
                    case 'triu0' 
                        obj.RowTickIndices = 1:(size(obj.Data, 1) - 1);
                        obj.ColTickIndices = 2:size(obj.Data, 2);
                    case 'tril0' 
                        obj.RowTickIndices = 2:size(obj.Data, 1);
                        obj.ColTickIndices = 1:(size(obj.Data, 2) - 1);
                    case {'row', 'varu', 'varl'}
                        obj.ColTickIndices = [];
                    case 'col'
                        obj.RowTickIndices = [];
                    case {'linkl', 'linku'}
                        delete(obj.Colorbar)
                end
                obj.setRowLabelLocation();
                obj.setColLabelLocation();

                obj.setBoxXY()
                obj.setFrameXY()

                obj.rowShown = true;
                obj.colShown = true;
                obj.setRowTickIndices()
                obj.setColTickIndices()
            end

            if ~all(isnan(obj.GX))
                obj.setGrid();
            end
            if strcmpi(obj.Format, '3d') || strcmpi(obj.frameHdl.Visible, 'on')
                obj.setFrame();
            end

            if nargout == 1
                varargout = {obj};
            end
        end

        function setBoxXY(obj)
            obj.BX = []; obj.BY = [];
                for gi = 1:max(obj.RowGroup)
                    for gj = 1:max(obj.ColGroup)
                        posi = obj.RP(obj.RowGroup == gi);
                        posj = obj.CP(obj.ColGroup == gj);
                        M = length(posi);
                        N = length(posj);
                        switch lower(obj.Type)
                            case {'triu', 'varu'}
                                if gi == gj
                                    bX1 = [1; 1; nan]*[posj(1) - .5, posj + .5];
                                    bY1 = [(posi(1) - .5).*ones(1, N + 1);
                                        posi + .5, posi(end) + .5;
                                        nan(1, N + 1)];
                                    bX2 = [(posj(end) + .5).*ones(1, N + 1);
                                        posj(1) - .5, posj - .5;
                                        nan(1, N + 1)];
                                    bY2 = [1; 1; nan]*[posi(1) - .5, posi + .5];
                                    obj.BX = [obj.BX; bX1(:); bX2(:)];
                                    obj.BY = [obj.BY; bY1(:); bY2(:)];
                                elseif gj > gi
                                    bX1 = [1; 1; nan]*[posj(1) - .5, posj + .5];
                                    bY1 = [posi(1) - .5; posi(end) + .5; nan]*ones(1, N + 1);
                                    bX2 = [posj(1) - .5; posj(end) + .5; nan]*ones(1, M + 1);
                                    bY2 = [1; 1; nan]*[posi(1) - .5, posi + .5];
                                    obj.BX = [obj.BX; bX1(:); bX2(:)];
                                    obj.BY = [obj.BY; bY1(:); bY2(:)];
                                end
                            case {'tril', 'varl'}
                                if gi == gj
                                    bX1 = [1; 1; nan]*[posj(1) - .5, posj + .5];
                                    bY1 = [(posi(end) + .5).*ones(1, N + 1);
                                        posi(1) - .5, posi - .5;
                                        nan(1, N + 1)];
                                    bX2 = [(posj(1) - .5).*ones(1, N + 1);
                                        posj + .5, posj(end) + .5;
                                        nan(1, N + 1)];
                                    bY2 = [1; 1; nan]*[posi(1) - .5, posi + .5];
                                    obj.BX = [obj.BX; bX1(:); bX2(:)];
                                    obj.BY = [obj.BY; bY1(:); bY2(:)];
                                elseif gj < gi
                                    bX1 = [1; 1; nan]*[posj(1) - .5, posj + .5];
                                    bY1 = [posi(1) - .5; posi(end) + .5; nan]*ones(1, N + 1);
                                    bX2 = [posj(1) - .5; posj(end) + .5; nan]*ones(1, M + 1);
                                    bY2 = [1; 1; nan]*[posi(1) - .5, posi + .5];
                                    obj.BX = [obj.BX; bX1(:); bX2(:)];
                                    obj.BY = [obj.BY; bY1(:); bY2(:)];
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
                                    obj.BX = [obj.BX; bX1(:); bX2(:)];
                                    obj.BY = [obj.BY; bY1(:); bY2(:)];
                                elseif gj > gi
                                    bX1 = [1; 1; nan]*[posj(1) - .5, posj + .5];
                                    bY1 = [posi(1) - .5; posi(end) + .5; nan]*ones(1, N + 1);
                                    bX2 = [posj(1) - .5; posj(end) + .5; nan]*ones(1, M + 1);
                                    bY2 = [1; 1; nan]*[posi(1) - .5, posi + .5];
                                    obj.BX = [obj.BX; bX1(:); bX2(:)];
                                    obj.BY = [obj.BY; bY1(:); bY2(:)];
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
                                    obj.BX = [obj.BX; bX1(:); bX2(:)];
                                    obj.BY = [obj.BY; bY1(:); bY2(:)];
                                elseif gj < gi
                                    bX1 = [1; 1; nan]*[posj(1) - .5, posj + .5];
                                    bY1 = [posi(1) - .5; posi(end) + .5; nan]*ones(1, N + 1);
                                    bX2 = [posj(1) - .5; posj(end) + .5; nan]*ones(1, M + 1);
                                    bY2 = [1; 1; nan]*[posi(1) - .5, posi + .5];
                                    obj.BX = [obj.BX; bX1(:); bX2(:)];
                                    obj.BY = [obj.BY; bY1(:); bY2(:)];
                                end
                            case {'full', 'row', 'col'}
                                bY1 = unique([posi - .5, posi + .5]);
                                bX1 = [posj(1) - .5; posj(end) + .5; nan]*ones(size(bY1));
                                bY1 = [1; 1; nan]*bY1;
                                bX2 = unique([posj - .5, posj + .5]);
                                bY2 = [posi(1) - .5; posi(end) + .5; nan]*ones(size(bX2));
                                bX2 = [1; 1; nan]*bX2;
                                obj.BX = [obj.BX; bX1(:); bX2(:)];
                                obj.BY = [obj.BY; bY1(:); bY2(:)];
                        end
                    end
                end
                set(obj.boxHdl, 'XData',obj.BX, 'YData',obj.BY)
        end

        function setFrameXY(obj)
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
                        case {'triu', 'varu'}
                            if gi == gj
                                X = [X2, N, N, n, n] + .5;
                                Y = [Y2(2:end), M, M, m, m, m + 1] +.5;
                                obj.FX = [obj.FX, X, nan]; obj.FY = [obj.FY, Y, nan];
                            elseif gj > gi
                                X = [n, N, N, n, n, N] + .5;
                                Y = [m, m, M, M, m, m] + .5;
                                obj.FX = [obj.FX, X, nan]; obj.FY = [obj.FY, Y, nan];
                            end
                        case {'tril', 'varl'}
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
                        case {'full', 'row', 'col'}
                            numY = round(max(posi) - min(posi) + 2);
                            obj.FX = [obj.FX, [0, ones(1, numY), zeros(1, numY), 1, nan].*(max(posj) - min(posj) + 1) + min(posj) - .5];
                            obj.FY = [obj.FY, [0, linspace(0, 1, numY), linspace(1, 0, numY), 0, nan].*(max(posi) - min(posi) + 1) + min(posi) - .5];
                    end
                end
            end
            set(obj.frameHdl, 'XData',obj.FX, 'YData',obj.FY)
        end

% =========================================================================
% 设置变量标签 (Set variable labels)
% =========================================================================
        function varargout = setVarName(obj, VarName)
            % obj.setVarName(VarName) - Assign variable names to rows and columns (cyclically if fewer names than size)
            % (为行和列分配变量名，若名称数量少于维度则循环使用)       
            obj.ax.XColor = 'none';
            obj.ax.YColor = 'none';
            if nargin == 2, obj.VarName = VarName; end
            obj.RowName = obj.VarName;
            obj.ColName = obj.VarName;
            VarNameLen = length(obj.VarName);
            tVarName = obj.VarName(:);
            tVarName = [tVarName; tVarName{1}];
            idx = 1:size(obj.Data, 1);
            % Apply names cyclically (循环应用名称)
            idx = mod(idx - 1, VarNameLen) + 1;
            set(obj.rowLabelHdl, {'String'}, tVarName(idx));
            set(obj.colLabelHdl, {'String'}, tVarName(idx));

            obj.rowShown = true;
            obj.colShown = true;
            obj.setRowTickIndices()
            obj.setColTickIndices()
            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setRowName(obj, RowName)
            % obj.setRowName(RowName) - Assign variable names to rows (cyclically if fewer names than size)
            % (为列分配变量名，若名称数量少于维度则循环使用)
            obj.ax.YColor = 'none';
            if nargin == 2, obj.RowName = RowName; end
            RowNameLen = length(obj.RowName);
            tRowName = obj.RowName(:);
            tRowName = [tRowName; tRowName{1}];
            idx = 1:size(obj.Data, 1);
            % Apply names cyclically (循环应用名称)
            idx = mod(idx - 1, RowNameLen) + 1;
            set(obj.rowLabelHdl, {'String'}, tRowName(idx));

            obj.rowShown = true;
            obj.setRowTickIndices()
            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setColName(obj, ColName)
            % obj.setColName(ColName) - Assign variable names to cols (cyclically if fewer names than size)
            % (为行分配变量名，若名称数量少于维度则循环使用)
            obj.ax.XColor = 'none';
            if nargin == 2, obj.ColName = ColName; end
            ColNameLen = length(obj.ColName);
            tColName = obj.ColName(:);
            tColName = [tColName; tColName{1}];
            idx = 1:size(obj.Data, 2);
            % Apply names cyclically (循环应用名称)
            idx = mod(idx - 1, ColNameLen) + 1;
            set(obj.colLabelHdl, {'String'}, tColName(idx));
            
            obj.colShown = true;
            obj.setColTickIndices()
            if nargout == 1
                varargout = {obj};
            end
        end
        
        function varargout = setRowLabel(obj, varargin)
            % obj.setRowLabel(varargin) - Set properties for all row label text objects (设置所有行标签的属性)
            set(obj.rowLabelHdl, varargin{:});
            if nargout == 1
                varargout = {obj};
            end
        end
        
        function varargout = setColLabel(obj, varargin)
            % obj.setColLabel(varargin) - Set properties for all col label text objects (设置所有列标签的属性)
            set(obj.colLabelHdl, varargin{:});
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

            if nargin < 2
                loc = obj.RowLabelLocation;
            elseif ~strcmpi(obj.RowLabelLocation, loc)
                obj.RowLabelLocation = loc;
            end
            obj.TickLength(obj.TickLength < 0) = 0;
            obj.TickLength(obj.TickLength > .5) = .5;
            obj.TickLabelOffset(obj.TickLabelOffset <= 1e-4) = 1e-4;
            obj.TickLabelOffset(obj.TickLabelOffset > .5) = .5;

            % 'left'/'right'/'diag'
            inds = 1:size(obj.Data, 1);
            switch lower(loc)
                case 'left'
                    set(obj.rowLabelHdl, 'HorizontalAlignment','right')
                    obj.RTLDir(:, 1) = .5; 
                    obj.RTLDir(:, 2) = obj.RP(inds);
                    obj.RTLDir(:, 3) = .5 - obj.TickLabelOffset;
                    obj.RTLDir(:, 4) = obj.RP(inds);
                    if strcmpi(obj.rowTickHdl.Visible, 'on')
                        obj.RTLDir(:, 3) = obj.RTLDir(:, 3) - obj.TickLength;
                    end
                    obj.ax.YAxisLocation = 'left';
                case 'right'
                    set(obj.rowLabelHdl, 'HorizontalAlignment','left')
                    obj.RTLDir(:, 1) = obj.CP(end) + .5; 
                    obj.RTLDir(:, 2) = obj.RP(inds);
                    obj.RTLDir(:, 3) = obj.CP(end) + .5 + obj.TickLabelOffset;
                    obj.RTLDir(:, 4) = obj.RP(inds);
                    if strcmpi(obj.rowTickHdl.Visible, 'on')
                        obj.RTLDir(:, 3) = obj.RTLDir(:, 3) + obj.TickLength;
                    end
                    obj.ax.YAxisLocation = 'right';
                case 'diag'
                    switch lower(obj.Type)
                        case 'tril'
                            set(obj.rowLabelHdl, 'HorizontalAlignment','left')
                            obj.RTLDir(:, 1) = .5 + obj.CP(inds); 
                            obj.RTLDir(:, 2) = obj.RP(inds);
                            obj.RTLDir(:, 3) = .5 + obj.CP(inds) + obj.TickLabelOffset;
                            obj.RTLDir(:, 4) = obj.RP(inds);
                            if strcmpi(obj.rowTickHdl.Visible, 'on')
                                obj.RTLDir(:, 3) = obj.RTLDir(:, 3) + obj.TickLength;
                            end
                            obj.ax.YAxisLocation = 'right';
                        case {'tril0','linkl'}
                            set(obj.rowLabelHdl, 'HorizontalAlignment','left')
                            obj.RTLDir(:, 1) = .5 + obj.CP(max(1, inds - 1)); 
                            obj.RTLDir(:, 2) = obj.RP(inds);
                            obj.RTLDir(:, 3) = .5 + obj.CP(max(1, inds - 1)) + obj.TickLabelOffset;
                            obj.RTLDir(:, 4) = obj.RP(inds);
                            if strcmpi(obj.rowTickHdl.Visible, 'on')
                                obj.RTLDir(:, 3) = obj.RTLDir(:, 3) + obj.TickLength;
                            end
                            obj.ax.YAxisLocation = 'right';
                        case 'triu'
                            set(obj.rowLabelHdl, 'HorizontalAlignment','right')
                            obj.RTLDir(:, 1) = -.5 + obj.CP(inds); 
                            obj.RTLDir(:, 2) = obj.RP(inds);
                            obj.RTLDir(:, 3) = -.5 - obj.TickLabelOffset + obj.CP(inds);
                            obj.RTLDir(:, 4) = obj.RP(inds);
                            if strcmpi(obj.rowTickHdl.Visible, 'on')
                                obj.RTLDir(:, 3) = obj.RTLDir(:, 3) - obj.TickLength;
                            end
                            obj.ax.YAxisLocation = 'left';
                        case {'triu0','linku'}
                            set(obj.rowLabelHdl, 'HorizontalAlignment','right')
                            obj.RTLDir(:, 1) = -.5 + obj.CP(min(inds + 1, length(obj.CP))); 
                            obj.RTLDir(:, 2) = obj.RP(inds);
                            obj.RTLDir(:, 3) = -.5 - obj.TickLabelOffset + obj.CP(min(inds + 1, length(obj.CP)));
                            obj.RTLDir(:, 4) = obj.RP(inds);
                            if strcmpi(obj.rowTickHdl.Visible, 'on')
                                obj.RTLDir(:, 3) = obj.RTLDir(:, 3) - obj.TickLength;
                            end
                            obj.ax.YAxisLocation = 'left';
                        case {'varu', 'varl'}
                            set(obj.rowLabelHdl, 'HorizontalAlignment','center')
                            obj.RTLDir(:, 1) = obj.CP(inds); 
                            obj.RTLDir(:, 2) = obj.RP(inds);
                            obj.RTLDir(:, 3) = obj.CP(inds);
                            obj.RTLDir(:, 4) = obj.RP(inds);
                            obj.ax.YTick = [];
                    end
            end
            set(obj.rowLabelHdl, {'Position'}, mat2cell([obj.RTLDir(:, [3, 4]), obj.RTLDir(:, 4).*0], ones(1, size(obj.Data, 1)), 3))
            if strcmpi(obj.rowTickHdl.Visible, 'on')
                obj.setRowTickXY()
                switch lower(loc)
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

            if nargin < 2
                loc = obj.ColLabelLocation;
            elseif ~strcmpi(obj.ColLabelLocation, loc)
                obj.ColLabelLocation = loc;
            end
            obj.TickLength(obj.TickLength < 0) = 0;
            obj.TickLength(obj.TickLength > .5) = .5;
            obj.TickLabelOffset(obj.TickLabelOffset <= 1e-4) = 1e-4;
            obj.TickLabelOffset(obj.TickLabelOffset > .5) = .5;

            % 'top'/'bottom'/'diag
            inds = 1:size(obj.Data, 2);
            switch lower(loc)
                case 'top'
                    set(obj.colLabelHdl(inds), 'HorizontalAlignment','left')
                    obj.CTLDir(:, 1) = obj.CP(inds);
                    obj.CTLDir(:, 2) = .5;
                    obj.CTLDir(:, 3) = obj.CP(inds);
                    obj.CTLDir(:, 4) = .5 - obj.TickLabelOffset;
                    if strcmpi(obj.colTickHdl.Visible, 'on')
                        obj.CTLDir(:, 4) = obj.CTLDir(:, 4) - obj.TickLength;
                    end
                    obj.ax.XAxisLocation = 'top';
                case 'bottom'
                    set(obj.colLabelHdl(inds), 'HorizontalAlignment','right')
                    obj.CTLDir(:, 1) = obj.CP(inds);
                    obj.CTLDir(:, 2) = obj.RP(end) + .5;
                    obj.CTLDir(:, 3) = obj.CP(inds);
                    obj.CTLDir(:, 4) = obj.RP(end) + .5 + obj.TickLabelOffset;
                    if strcmpi(obj.colTickHdl.Visible, 'on')
                        obj.CTLDir(:, 4) = obj.CTLDir(:, 4) + obj.TickLength;
                    end
                    obj.ax.XAxisLocation = 'bottom';
                case 'diag'
                    switch lower(obj.Type)
                        case 'tril'
                            set(obj.colLabelHdl(inds), 'HorizontalAlignment','left')
                            obj.CTLDir(:, 1) = obj.CP(inds);
                            obj.CTLDir(:, 2) = -.5 + obj.RP(inds);
                            obj.CTLDir(:, 3) = obj.CP(inds);
                            obj.CTLDir(:, 4) = -.5 + obj.RP(inds) - obj.TickLabelOffset;
                            if strcmpi(obj.colTickHdl.Visible, 'on')
                                obj.CTLDir(:, 4) = obj.CTLDir(:, 4) - obj.TickLength;
                            end
                            obj.ax.XAxisLocation = 'top';
                        case {'tril0','linkl'}
                            set(obj.colLabelHdl(inds), 'HorizontalAlignment','left')
                            obj.CTLDir(:, 1) = obj.CP(inds);
                            obj.CTLDir(:, 2) = -.5 + obj.RP(min(inds + 1, length(obj.RP)));
                            obj.CTLDir(:, 3) = obj.CP(inds);
                            obj.CTLDir(:, 4) = -.5 + obj.RP(min(inds + 1, length(obj.RP))) - obj.TickLabelOffset;
                            if strcmpi(obj.colTickHdl.Visible, 'on')
                                obj.CTLDir(:, 4) = obj.CTLDir(:, 4) - obj.TickLength;
                            end
                            obj.ax.XAxisLocation = 'top';
                        case 'triu'
                            set(obj.colLabelHdl(inds), 'HorizontalAlignment','right')
                            obj.CTLDir(:, 1) = obj.CP(inds);
                            obj.CTLDir(:, 2) = obj.RP(inds) + .5;
                            obj.CTLDir(:, 3) = obj.CP(inds);
                            obj.CTLDir(:, 4) = obj.RP(inds) + .5 + obj.TickLabelOffset;
                            if strcmpi(obj.colTickHdl.Visible, 'on')
                                obj.CTLDir(:, 4) = obj.CTLDir(:, 4) + obj.TickLength;
                            end
                            obj.ax.XAxisLocation = 'bottom';
                        case {'triu0','linku'}
                            set(obj.colLabelHdl(inds), 'HorizontalAlignment','right')
                            obj.CTLDir(:, 1) = obj.CP(inds);
                            obj.CTLDir(:, 2) = obj.RP(max(1, inds - 1)) + .5;
                            obj.CTLDir(:, 3) = obj.CP(inds);
                            obj.CTLDir(:, 4) = obj.RP(max(1, inds - 1)) + .5 + obj.TickLabelOffset;
                            if strcmpi(obj.colTickHdl.Visible, 'on')
                                obj.CTLDir(:, 4) = obj.CTLDir(:, 4) + obj.TickLength;
                            end
                            obj.ax.XAxisLocation = 'bottom';
                        case {'varu', 'varl'}
                            set(obj.colLabelHdl(inds), 'HorizontalAlignment','center')
                            obj.CTLDir(:, 1) = obj.CP(inds);
                            obj.CTLDir(:, 2) = obj.CP(inds);
                            obj.CTLDir(:, 3) = obj.CP(inds);
                            obj.CTLDir(:, 4) = obj.CP(inds);
                            obj.ax.XTick = [];
                    end
            end
            set(obj.colLabelHdl, {'Position'}, mat2cell([obj.CTLDir(:, [3, 4]), obj.CTLDir(:, 4).*0], ones(1, size(obj.Data, 2)), 3))
            if strcmpi(obj.colTickHdl.Visible, 'on')
                obj.setColTickXY()
                switch lower(loc)
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
% 设置分组标签 (Set group labels)
% =========================================================================
        function varargout = setRowGroupName(obj, RowGroupName)
            % obj.setRowGroupName(RowGroupName) - Assign group names to row-groups (cyclically if fewer names than group number)
            % (为行分组分配组名，若名称数量少于组数则循环使用)
            obj.RowGroupName = RowGroupName;
            RowGroupNameLen = length(obj.RowGroupName);
            tRowGroupName = obj.RowGroupName(:);
            tRowGroupName = [tRowGroupName; tRowGroupName(1)];
            idx = 1:max(obj.RowGroup);
            % Apply names cyclically (循环应用名称)
            idx = mod(idx - 1, RowGroupNameLen) + 1;
            set(obj.rowGroupLabelHdl, 'Visible','on');
            set(obj.rowGroupLabelHdl, {'String'}, tRowGroupName(idx));

            if nargout == 1
                varargout = {obj};
            end
        end
        function varargout = setColGroupName(obj, ColGroupName)
            % obj.setColGroupName(ColGroupName) - Assign group names to col-groups (cyclically if fewer names than group number)
            % (为列分组分配组名，若名称数量少于组数则循环使用)
            obj.ColGroupName = ColGroupName;
            ColGroupNameLen = length(obj.ColGroupName);
            tColGroupName = obj.ColGroupName(:);
            tColGroupName = [tColGroupName; tColGroupName(1)];
            idx = 1:max(obj.ColGroup);
            % Apply names cyclically (循环应用名称)
            idx = mod(idx - 1, ColGroupNameLen) + 1;
            set(obj.colGroupLabelHdl, 'Visible','on');
            set(obj.colGroupLabelHdl, {'String'}, tColGroupName(idx));
             
            if nargout == 1
                varargout = {obj};
            end
        end
        function varargout = setRowGroupLabel(obj, varargin)
            % obj.setRowGroupLabel(varargin) - Set properties for all row-group label text objects (设置所有行分组标签的属性)
            set(obj.rowGroupLabelHdl, 'Visible','on', varargin{:});
            if nargout == 1
                varargout = {obj};
            end
        end
        
        function varargout = setColGroupLabel(obj, varargin)
            % obj.setColGroupLabel(varargin) - Set properties for all col-group label text objects (设置所有列分组标签的属性)
            set(obj.colGroupLabelHdl, 'Visible','on', varargin{:});
            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setRowGroupLabelLocation(obj, loc)
            % obj.setRowGroupLabelLocation(loc) - Move row-group labels to 
            % specified location (设置行分组标签位置)
            %
            % loc can be:
            %   'left'  - aligned to the left side of the first column
            %   'right' - aligned to the right side of the last column
            %   'diag'  - placed along the diagonal
            if ~strcmpi(obj.RowGroupLabelLocation, loc)
                obj.RowGroupLabelLocation = loc;
            end
            obj.GroupLabelOffset(obj.GroupLabelOffset <= 1e-4) = 1e-4;
            obj.GroupLabelOffset(obj.GroupLabelOffset > 10) = 10;

            for n = 1:max(obj.RowGroup)
                switch lower(loc)
                    case 'none'
                        set(obj.rowGroupLabelHdl(n), 'Visible','off')
                    case 'left'
                        set(obj.rowGroupLabelHdl(n), 'Visible','on', 'Position',[.5 - obj.GroupLabelOffset, obj.RGP(n), 0], 'Rotation',90)
                        obj.RGLDir(n, :) = [.5, obj.RGP(n), .5 - obj.GroupLabelOffset, obj.RGP(n)];
                    case 'right'
                        set(obj.rowGroupLabelHdl(n), 'Visible','on', 'Position',[obj.CP(end) + .5 + obj.GroupLabelOffset, obj.RGP(n), 0], 'Rotation',-90)
                        obj.RGLDir(n, :) = [obj.CP(end) + .5, obj.RGP(n), obj.CP(end) + .5 + obj.GroupLabelOffset, obj.RGP(n)];
                    case 'diag'
                        switch lower(obj.Type)
                            case 'tril'
                                set(obj.rowGroupLabelHdl(n), 'Visible','on', 'Position',...
                                    [obj.RGP(n) + .5 + obj.GroupLabelOffset/sqrt(2), ...
                                     obj.CGP(n) - .5 - obj.GroupLabelOffset/sqrt(2), 0], 'Rotation',-45)
                                obj.RGLDir(n, :) = [obj.RGP(n) + .5, obj.CGP(n) - .5, ...
                                     obj.RGP(n) + .5 + obj.GroupLabelOffset/sqrt(2), ...
                                     obj.CGP(n) - .5 - obj.GroupLabelOffset/sqrt(2)];
                            case {'tril0','linkl'}
                                set(obj.rowGroupLabelHdl(n), 'Visible','on', 'Position',...
                                    [obj.RGP(n) + obj.GroupLabelOffset/sqrt(2), ...
                                     obj.CGP(n) - obj.GroupLabelOffset/sqrt(2), 0], 'Rotation',-45)
                                obj.RGLDir(n, :) = [obj.RGP(n), obj.CGP(n), ...
                                    obj.RGP(n) + obj.GroupLabelOffset/sqrt(2), ...
                                    obj.CGP(n) - obj.GroupLabelOffset/sqrt(2)];
                            case 'triu'
                                set(obj.rowGroupLabelHdl(n), 'Visible','on', 'Position',...
                                    [obj.RGP(n) - .5 - obj.GroupLabelOffset/sqrt(2), ...
                                     obj.CGP(n) + .5 + obj.GroupLabelOffset/sqrt(2), 0], 'Rotation',-45)
                                obj.RGLDir(n, :) = [obj.RGP(n) - .5, obj.CGP(n) + .5, ...
                                    obj.RGP(n) - .5 - obj.GroupLabelOffset/sqrt(2), ...
                                    obj.CGP(n) + .5 + obj.GroupLabelOffset/sqrt(2)];
                            case {'triu0','linku'}
                                set(obj.rowGroupLabelHdl(n), 'Visible','on', 'Position',...
                                    [obj.RGP(n) - obj.GroupLabelOffset/sqrt(2), ...
                                     obj.CGP(n) + obj.GroupLabelOffset/sqrt(2), 0], 'Rotation',-45)
                                obj.RGLDir(n, :) = [obj.RGP(n), obj.CGP(n), ...
                                    obj.RGP(n) - obj.GroupLabelOffset/sqrt(2), ...
                                    obj.CGP(n) + obj.GroupLabelOffset/sqrt(2)];
                        end
                end
            end
            switch lower(loc)
                case 'left'
                    switch lower(obj.Type)
                        case {'tril0','linkl'}
                            obj.rowGroupLabelHdl(1).Position(2) = obj.rowGroupLabelHdl(1).Position(2) + .5;
                            obj.RGLDir(1, [2, 4]) = obj.RGLDir(1, [2, 4]) + .5;
                        case {'triu0','linku'}
                            obj.rowGroupLabelHdl(end).Position(2) = obj.rowGroupLabelHdl(end).Position(2) - .5;
                            obj.RGLDir(end, [2, 4]) = obj.RGLDir(end, [2, 4]) - .5;
                    end
                case 'right'
                    switch lower(obj.Type)
                        case {'tril0','linkl'}
                            obj.rowGroupLabelHdl(1).Position(2) = obj.rowGroupLabelHdl(1).Position(2) + .5;
                            obj.RGLDir(1, [2, 4]) = obj.RGLDir(1, [2, 4]) + .5;
                        case {'triu0','linku'}
                            obj.rowGroupLabelHdl(end).Position(2) = obj.rowGroupLabelHdl(end).Position(2) - .5;
                            obj.RGLDir(end, [2, 4]) = obj.RGLDir(end, [2, 4]) - .5;
                    end
            end
            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setColGroupLabelLocation(obj, loc)
            % obj.setColGroupLabelLocation(loc) - Move col-group labels to 
            % specified location (设置行分组标签位置)
            %
            % loc can be:
            %   'top'    - aligned above the first row
            %   'bottom' - aligned below the last row
            %   'diag'   - placed along the diagonal

            if ~strcmpi(obj.ColGroupLabelLocation, loc)
                obj.ColGroupLabelLocation = loc;
            end
            obj.GroupLabelOffset(obj.GroupLabelOffset <= 1e-4) = 1e-4;
            obj.GroupLabelOffset(obj.GroupLabelOffset > 10) = 10;

            for n = 1:max(obj.ColGroup)
                switch lower(loc)
                    case 'none'
                        set(obj.colGroupLabelHdl(n), 'Visible','off')
                    case 'top'
                        set(obj.colGroupLabelHdl(n), 'Visible','on', 'Position',[obj.CGP(n), .5 - obj.GroupLabelOffset, 0], 'Rotation',0)
                        obj.CGLDir(n, :) = [obj.CGP(n), .5, obj.CGP(n), .5 - obj.GroupLabelOffset];
                    case 'bottom'
                        set(obj.colGroupLabelHdl(n), 'Visible','on', 'Position',[obj.CGP(n), .5 + obj.RP(end) + obj.GroupLabelOffset, 0], 'Rotation',0)
                        obj.CGLDir(n, :) = [obj.CGP(n), .5 + obj.RP(end), obj.CGP(n), .5 + obj.RP(end) + obj.GroupLabelOffset];
                    case 'diag'
                        switch lower(obj.Type)
                            case 'tril'
                                set(obj.colGroupLabelHdl(n), 'Visible','on', 'Position',...
                                    [obj.RGP(n) + .5 + obj.GroupLabelOffset/sqrt(2), ...
                                     obj.CGP(n) - .5 - obj.GroupLabelOffset/sqrt(2), 0], 'Rotation',-45)
                                obj.CGLDir(n, :) = [obj.RGP(n) + .5, obj.CGP(n) - .5, ...
                                    obj.RGP(n) + .5 + obj.GroupLabelOffset/sqrt(2), ...
                                    obj.CGP(n) - .5 - obj.GroupLabelOffset/sqrt(2)];
                            case {'tril0','linkl'}
                                set(obj.colGroupLabelHdl(n), 'Visible','on', 'Position',...
                                    [obj.RGP(n) + obj.GroupLabelOffset/sqrt(2), ...
                                     obj.CGP(n) - obj.GroupLabelOffset/sqrt(2), 0], 'Rotation',-45)
                                obj.CGLDir(n, :) = [obj.RGP(n), obj.CGP(n), ...
                                    obj.RGP(n) + obj.GroupLabelOffset/sqrt(2), ...
                                    obj.CGP(n) - obj.GroupLabelOffset/sqrt(2)];
                            case 'triu'
                                set(obj.colGroupLabelHdl(n), 'Visible','on', 'Position',...
                                    [obj.RGP(n) - .5 - obj.GroupLabelOffset/sqrt(2), ...
                                     obj.CGP(n) + .5 + obj.GroupLabelOffset/sqrt(2), 0], 'Rotation',-45)
                                obj.CGLDir(n, :) = [obj.RGP(n) - .5, obj.CGP(n) + .5, ...
                                    obj.RGP(n) - .5 - obj.GroupLabelOffset/sqrt(2), ...
                                    obj.CGP(n) + .5 + obj.GroupLabelOffset/sqrt(2)];
                            case {'triu0','linku'}
                                set(obj.colGroupLabelHdl(n), 'Visible','on', 'Position',...
                                    [obj.RGP(n) - obj.GroupLabelOffset/sqrt(2), ...
                                     obj.CGP(n) + obj.GroupLabelOffset/sqrt(2), 0], 'Rotation',-45)
                                obj.CGLDir(n, :) = [obj.RGP(n), obj.CGP(n), ...
                                    obj.RGP(n) - obj.GroupLabelOffset/sqrt(2), ...
                                    obj.CGP(n) + obj.GroupLabelOffset/sqrt(2)];
                        end
                end
            end
            switch lower(loc)
                case 'top'
                    switch lower(obj.Type)
                        case {'tril0','linkl'}
                            obj.colGroupLabelHdl(end).Position(1) = obj.colGroupLabelHdl(end).Position(1) - .5;
                            obj.CGLDir(end, [1, 3]) = obj.CGLDir(end, [1, 3]) - .5;
                        case {'triu0','linku'}
                            obj.colGroupLabelHdl(1).Position(1) = obj.colGroupLabelHdl(1).Position(1) + .5;
                            obj.CGLDir(1, [1, 3]) = obj.CGLDir(1, [1, 3]) + .5;
                    end
                case 'bottom'
                    switch lower(obj.Type)
                        case {'tril0','linkl'}
                            obj.colGroupLabelHdl(end).Position(1) = obj.colGroupLabelHdl(end).Position(1) - .5;
                            obj.CGLDir(end, [1, 3]) = obj.CGLDir(end, [1, 3]) - .5;
                        case {'triu0','linku'}
                            obj.colGroupLabelHdl(1).Position(1) = obj.colGroupLabelHdl(1).Position(1) + .5;
                            obj.CGLDir(1, [1, 3]) = obj.CGLDir(1, [1, 3]) + .5;
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
        
            valid = ~isnan(obj.Data);
            
            if nargin(func) ~= 1
                tStr = arrayfun(func, obj.Data(valid), obj.PVal(valid), 'UniformOutput', false);
            else
                tStr = arrayfun(func, obj.Data(valid), 'UniformOutput', false);
            end
            set(obj.textHdl(valid), {'String'}, tStr);

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
            
            dataVec = obj.Data(:); valid = ~isnan(dataVec);
            counts = floor((dataVec - climit(1))./diff(climit).*size(cmap, 1)) + 1;
            counts(counts > size(cmap, 1)) = size(cmap, 1); 
            counts(counts < 1) = 1;
            counts(~valid) = 1;
            colors = cmap(counts, :);
            if strcmpi(obj.Format, '3d')
                colors(~valid, :) = .9;
            else
                colors(~valid, :) = .8;
            end
            set(obj.patchHdl, {'FaceColor'}, num2cell(colors, 2))
        
            if isvalid(obj.Colorbar)
                % Update colorbar to reflect the fixed colormap and limits
                % (更新颜色条以反映固定的颜色映射和范围)
                obj.Colorbar.Colormap = cmap;
                obj.Colorbar.Limits   = climit;
                % Slightly shift colorbar position to avoid overlap (微调颜色条位置避免重叠)
                obj.Colorbar.Position = obj.Colorbar.Position + [0.03, 0, 0, 0];
            end

            obj.isFrozen = true;
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
            
            nvalid = isnan(obj.Data);
            strs = get(obj.textHdl, 'String');
            stars = obj.matPval2stars(pval, starobj.Levels);
            stars = stars(:); 

            if strcmp(starobj.CorrLabel, 'on')
                stars = num2cell([stars, strs].', 1).';
            else
                stars(nvalid) = strs(nvalid);
            end
            set(obj.textHdl, {'String'}, stars)
           
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

        function stars = matPval2stars(~, matPval, levels)
            % matPval2stars - Convert matrix of p-values to significance stars
            %   stars = matPval2stars(matPval) returns a cell array of the same size as
            %   matPval, where each entry is a string of asterisks indicating the
            %   significance level:
            %       p < 0.05   -> '*'
            %       p < 0.01   -> '**'
            %       p < 0.001  -> '***'
            %
            %   stars = matPval2stars(matPval, levels) custom significance thresholds.
            %       levels = [0.05, 0.01, 0.001] (default)
            %
            %   The output cell array contains spaces for non-significant entries.
            %   (p >= the smallest threshold)
            %
            % Examples:
            %   matPval2stars([0.03, 0.002; 0.2, 0.0005])
            %       returns {'*', '**'; ' ', '***'}
            %
            %   matPval2stars([0.04, 0.009], [0.05, 0.01])
            %       returns {'*', '**'}   (since 0.009 < 0.01)
            %
            % See also: pval2stars

            if nargin < 2
                levels = [0.05, 0.01, 0.001];
            end
            levels = levels(:).';

            N = length(levels);
            mn = numel(matPval);
            starCell = cell(1, N + 1);
            starCell{1} = ' ';
            for n = 1:N
                starCell{n + 1} = repmat('*', 1, n);
            end

            counts = sum(repmat(matPval(:), [1, N]) < repmat(levels, [mn, 1]), 2);
            stars = reshape(starCell(counts + 1), size(matPval));
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
                    strcmpi(obj.Format, 'bcirc') || ...
                    strcmpi(obj.Format, 'cust') || ...
                    strcmpi(obj.Format, 'acust') || ...
                    strcmpi(obj.Format, 'c2rect') || ...
                    strcmpi(obj.Format, 'arrect') || ...
                    strcmpi(obj.Format, 'rrect'))) || ...
                    (strcmpi(obj.Type, 'full') && (strcmpi(obj.Format, 'sq') || ...
                    strcmpi(obj.Format, 'barh') || ...
                    strcmpi(obj.Format, 'sqfull'))) || ...
                    (obj.TLim(1) == 0 && obj.TLim(2) == 0)

                if obj.TLim(1) ~= 0 || obj.TLim(2) ~= 0
                    obj.ax.DataAspectRatio = [1,1,1];
                end
                obj.XYTReset = true;
                tLen = max(1./diff(OXLim).*diff(obj.XLim), 1./diff(OYLim).*diff(obj.YLim));
                obj.XLim = sort(obj.XLim); obj.YLim = sort(obj.YLim);
                if abs(diff(obj.XLim)) < eps, obj.XLim = [obj.CP(1) - .5, obj.CP(end) + .5]; end
                if abs(diff(obj.YLim)) < eps, obj.YLim = [obj.RP(1) - .5, obj.RP(end) + .5]; end

                if abs(diff(obj.TLim)) < eps
                    % Set X, Y, Theta Lim for boxHdl
                    [nX, nY] = getNewXY(obj.BX, obj.BY, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                    obj.boxHdl.XData = nX; obj.boxHdl.YData = nY;
                    % Set X, Y, Theta Lim for frameHdl
                    [nX, nY] = getNewXY(obj.FX, obj.FY, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                    obj.frameHdl.XData = nX; obj.frameHdl.YData = nY;
                    % Set X, Y, Theta Lim for gridHdl
                    if ~all(isnan(obj.GX))
                    [nX, nY] = getNewXY(obj.GX, obj.GY, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                    obj.gridHdl.XData = nX; obj.gridHdl.YData = nY;
                    end
                else
                    % Set X, Y, Theta Lim for boxHdl
                    NN = max(size(obj.Data));
                    X = interpDataNaN(obj.BX, NN*20); Y = interpDataNaN(obj.BY, NN*20);
                    [nX, nY] = getNewXY(X, Y, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                    obj.boxHdl.XData = nX; obj.boxHdl.YData = nY;
                    set(obj.boxHdl, 'Visible','off');
                    % Set X, Y, Theta Lim for frameHdl
                    X = interpDataNaN(obj.FX, 10); Y = interpDataNaN(obj.FY, 10);
                    [nX, nY] = getNewXY(X, Y, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                    obj.frameHdl.XData = nX; obj.frameHdl.YData = nY;
                    % Set X, Y, Theta Lim for gridHdl
                    if ~all(isnan(obj.GX))
                    X = interpDataNaN(obj.GX, 10); Y = interpDataNaN(obj.GY, 10);
                    [nX, nY] = getNewXY(X, Y, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                    obj.gridHdl.XData = nX; obj.gridHdl.YData = nY;
                    end
                end

                % Set X, Y, Theta Lim for rowTickHdl
                [nX, nY] = getNewXY(obj.RTX, obj.RTY, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                nX = reshape(nX, 3, []); nY = reshape(nY, 3, []);
                if obj.TickLength > 0
                    nV = [nX(2, :) - nX(1, :); nY(2, :) - nY(1, :)];
                    nL = sqrt(nV(1, :).^2 + nV(2, :).^2); nV = nV./[nL; nL];
                    nX(2, :) = nX(1, :) + nV(1, :).*obj.TickLength.*tLen;
                    nY(2, :) = nY(1, :) + nV(2, :).*obj.TickLength.*tLen;
                end; obj.newRTX = nX(:); obj.newRTY = nY(:); obj.setRowTickIndices();
                % Set X, Y, Theta Lim for colTickHdl
                [nX, nY] = getNewXY(obj.CTX, obj.CTY, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                nX = reshape(nX, 3, []); nY = reshape(nY, 3, []);
                if obj.TickLength > 0
                    nV = [nX(2, :) - nX(1, :); nY(2, :) - nY(1, :)];
                    nL = sqrt(nV(1, :).^2 + nV(2, :).^2); nV = nV./[nL; nL];
                    nX(2, :) = nX(1, :) + nV(1, :).*obj.TickLength.*tLen;
                    nY(2, :) = nY(1, :) + nV(2, :).*obj.TickLength.*tLen;
                end; obj.newCTX = nX(:); obj.newCTY = nY(:);  obj.setColTickIndices()

                % Set X, Y, Theta Lim for patchHdl
                if ~isempty(obj.PatchX)
                    if abs(diff(obj.TLim)) < eps
                        [nX, nY] = getNewXY(obj.PatchX, obj.PatchY, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                        nXYC = [num2cell(nX.', 2), num2cell(nY.', 2)];
                        set(obj.patchHdl, {'XData', 'YData'}, nXYC)
                        nanI = find(isnan(obj.Data));
                        if ~isempty(nanI)
                            nX = nX(1:4, nanI); nY = nY(1:4, nanI);
                            nXYC = [num2cell(nX.', 2), num2cell(nY.', 2)];
                            set(obj.patchHdl(nanI), {'XData', 'YData'}, nXYC)
                        end
                    else
                        tT1 = [1, 2, 3, 4, 5]; 
                        if size(obj.Data, 1) >= 100 
                            tT2 = [linspace(1, 2, 2), linspace(2, 3, 5), linspace(3, 4, 2), linspace(4, 5, 5)];
                        else
                            tT2 = [linspace(1, 2, 3), linspace(2, 3, 10), linspace(3, 4, 3), linspace(4, 5, 10)];
                        end
                        tX = [obj.PatchX; obj.PatchX(1, :)]; tY = [obj.PatchY; obj.PatchY(1, :)];
                        tX = interp1(tT1, tX, tT2); tY = interp1(tT1, tY, tT2);
                        [nX, nY] = getNewXY(tX, tY, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                        nXYC = [num2cell(nX.', 2), num2cell(nY.', 2)];
                        set(obj.patchHdl, {'XData', 'YData'}, nXYC)
                    end
                end
                % Set X, Y, Theta Lim for pieHdl
                if ~isempty(obj.PieX)
                    [nX, nY] = getNewXY(obj.PieX, obj.PieY, OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                    nXYC = [num2cell(nX.', 2), num2cell(nY.', 2)];
                    set(obj.pieHdl, {'XData', 'YData'}, nXYC)
                end
                % Set X, Y, Theta Lim for textHdl
                if (~isempty(obj.nanTextHdl)) && isempty(obj.textHdl)
                    [nX, nY] = getNewXY(obj.TxtNaNXY(:, 1), obj.TxtNaNXY(:, 2), OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                    nXYC = num2cell([nX, nY, nX.*0], 2);
                    set(obj.nanTextHdl, {'Position'}, nXYC)
                end
                if ~isempty(obj.textHdl)
                    [nX, nY] = getNewXY(obj.TxtXY(:,1), obj.TxtXY(:,2), OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                    nXYC = num2cell([nX, nY, nX.*0], 2);
                    set(obj.textHdl, {'Position'}, nXYC)
                else
                    [cols, rows] = meshgrid(1:size(obj.Data, 2), 1:size(obj.Data, 1));
                    rows = obj.RP(rows); cols = obj.CP(cols);
                    [nX, nY] = getNewXY(cols(:), rows(:), OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                    obj.newTxtXY = [nX, nY];
                end
                % Set X, Y, Theta Lim for rowLabelHdl
                [nX, nY] = getNewXY(obj.RTLDir(:, [1,3]), obj.RTLDir(:, [2,4]), OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                nV = [nX(:, 2) - nX(:, 1), nY(:, 2) - nY(:, 1)];
                nL = sqrt(nV(:, 1).^2 + nV(:, 2).^2);
                nV = nV./[nL, nL]; nV(isnan(nV)) = 0;
                nT = atan2(nV(:, 2), nV(:, 1)); nT = nT./pi.*180;
                nT = nT + 180.*((nT >= 90) | (nT < -90)).*sign(nT);
                nX = nX(:, 1) + nV(:, 1).*(obj.TickLength + obj.TickLabelOffset).*tLen;
                nY = nY(:, 1) + nV(:, 2).*(obj.TickLength + obj.TickLabelOffset).*tLen;
                nXYC = num2cell([nX, nY, nX.*0], 2);
                HA = {'left'; 'right'};
                nR = num2cell(-nT, 2);
                set(obj.rowLabelHdl, {'Position', 'HorizontalAlignment', 'Rotation'}, [nXYC, HA((abs(nT) >= 270) + 1), nR])
                % Set X, Y, Theta Lim for colLabelHdl
                [nX, nY] = getNewXY(obj.CTLDir(:, [1,3]), obj.CTLDir(:, [2,4]), OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                nV = [nX(:, 2) - nX(:, 1), nY(:, 2) - nY(:, 1)];
                nL = sqrt(nV(:, 1).^2 + nV(:, 2).^2);
                nV = nV./[nL, nL]; nV(isnan(nV)) = 0;
                nT = atan2(nV(:, 2), nV(:, 1)); nT = nT./pi.*180;
                nT = nT + 180.*((nT >= 90) | (nT < -90)).*sign(nT);
                nX = nX(:, 1) + nV(:, 1).*(obj.TickLength + obj.TickLabelOffset).*tLen;
                nY = nY(:, 1) + nV(:, 2).*(obj.TickLength + obj.TickLabelOffset).*tLen;
                nXYC = num2cell([nX, nY, nX.*0], 2);
                HA = {'left'; 'right'};
                nR = num2cell(-nT, 2);
                set(obj.colLabelHdl, {'Position', 'HorizontalAlignment', 'Rotation'}, [nXYC, HA((abs(nT) >= 270) + 1), nR])

                if strcmpi(obj.Type, 'varl') || strcmpi(obj.Type, 'varu')
                    set(obj.rowLabelHdl, 'HorizontalAlignment','center', 'Rotation',0)
                    set(obj.colLabelHdl, 'HorizontalAlignment','center', 'Rotation',0)
                end
    
                % Set X, Y, Theta Lim for rowGroupLabelHdl and colGroupLabelHdl
                [nX, nY] = getNewXY(obj.RGLDir(:, [1, 3]), obj.RGLDir(:, [2, 4]), OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                for n = 1:size(nX, 1)
                    nV = [nX(n, 2) - nX(n, 1); nY(n, 2) - nY(n, 1)];
                    nL = sqrt(nV(1).^2 + nV(2).^2); nV = nV./[nL; nL];
                    nT = atan2(nV(2), nV(1)); nT = nT./pi.*180;
                    nT = nT - 180*((nT > 0) - .5);
                    set(obj.rowGroupLabelHdl(n), 'Position', ...
                        [nX(n, 1) + nV(1).*obj.GroupLabelOffset.*tLen, ...
                         nY(n, 1) + nV(2).*obj.GroupLabelOffset.*tLen, 0], ...
                         'HorizontalAlignment','center', 'Rotation',-nT);
                end
                [nX, nY] = getNewXY(obj.CGLDir(:, [1, 3]), obj.CGLDir(:, [2, 4]), OXLim, OYLim, obj.XLim, obj.YLim, obj.TLim);
                for n = 1:size(nX, 1)
                    nV = [nX(n, 2) - nX(n, 1); nY(n, 2) - nY(n, 1)];
                    nL = sqrt(nV(1).^2 + nV(2).^2); nV = nV./[nL; nL];
                    nT = atan2(nV(2), nV(1)); nT = nT./pi.*180;
                    nT = nT - 180*((nT > 0) - .5);
                    set(obj.colGroupLabelHdl(n), 'Position', ...
                        [nX(n, 1) + nV(1).*obj.GroupLabelOffset.*tLen, ...
                         nY(n, 1) + nV(2).*obj.GroupLabelOffset.*tLen, 0], ...
                        'HorizontalAlignment','center', 'Rotation',-nT);
                end
                try axis(obj.ax, 'tight'), catch, end
            end

            function nX = interpDataNaN(X, N)
                % INTERPDATANAN Interpolate between consecutive data points, expanding to N points per interval.
                %   在相邻数据点之间插值，将每段扩展为 N 个均匀点 (NaN 位置保持为 NaN)
                if all(isnan(X))
                    nX = X;
                else
                    X = X(:).';
                    XX = [X(1:end-1), nan; X(2:end), nan];
                    ind = any(isnan(XX), 1);
                    XX(:, ind) = 1;
                    nX = interp1([0,1], XX, linspace(0,1,N));
                    nX(:, ind) = nan;
                    nX = nX(:).';
                end
            end

            function [nX, nY] = getNewXY(X, Y, OXLim, OYLim, XLim, YLim, TLim)
                % GETNEWXY Transform coordinates from original space to target space with optional rotation or annular mapping.
                %   将坐标从原始空间映射到目标空间，支持旋转或环形变换。
                %   - If TLim(1) == TLim(2): apply 2D rotation (仅旋转).
                %   - If TLim(1) ~= TLim(2): map Y to angle, X to radius (环形映射)
                TLim = [-TLim(1), -TLim(2)];
                % Linear mapping to target limits (线性映射到目标范围)
                X = (X - OXLim(1))./diff(OXLim).*diff(XLim) + XLim(1);
                Y = (Y - OYLim(1))./diff(OYLim).*diff(YLim) + YLim(1);
                if abs(diff(TLim)) < eps % Rotation only (仅旋转)
                    RMat = [cos(TLim(1)), sin(TLim(1));
                           -sin(TLim(1)), cos(TLim(1))];
                    XY = [X(:), Y(:)]*RMat;
                    nX = reshape(XY(:, 1), size(X, 1), []);
                    nY = reshape(XY(:, 2), size(Y, 1), []);
                else % Annular mapping (环形映射): Y -> angle, X -> radius
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