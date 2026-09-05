classdef SClusterBlock < handle
% SClusterBlock - Create colored blocks for cluster/group visualization
%   SCB = SClusterBlock(Class) Creates colored blocks for each group
%   along the top orientation (default).
%   创建顶部聚类方块对象。
%  
%   SCB = SClusterBlock(Class, 'Orientation', ori); specifies orientation 
%   指定方向 'top'/'left'。
%
%   SCB = SClusterBlock(Class, 'Parent', ax); 
%   SCB = SClusterBlock(ax, Class); Creates in specified axes.
%   在指定坐标区中创建。
%
%   SCB = SClusterBlock(___, propName, propVal); specifies property name-value
%   pairs when creating the object.
%   创建对象时指定属性名-属性值对。
%
%   SCB.propName = propVal; sets properties before calling draw().
%   在调用 draw() 前设置属性。
%
%   [X, Y] = SCB.draw(); renders the dendrogram.
%   渲染聚类方块。
%
% Parameters:
%   'Orientation'   - 'top' (default) or 'left'
%                     方块位置，'top' (默认) 或 'left'
%   'BasePos'       - Base position for block placement (default: 0)
%                     方块放置的基准位置 (默认: 0)
%   'Height'        - Height of blocks
%                     方块高度
%   'Group'         - Group assignments
%                     分组
%   'GroupSep'      - Group separation gap
%                     组间分离间距
%   'BlockProp'     - Cell array of patch properties
%                     用于设置方块属性的元胞数组
%   'ColorList'     - Custom color matrix for groups
%                     每组配色
%   'Format'        - Bracket/block shape style for each group (分组区块形状样式)
%      ├── 'block'  - (default) Filled square block (实心方块)
%      ├── 'sq'     - Square block (alias for 'block') (方块，同 'block')
%      ├── 'square' - Square block (alias for 'block') (方块，同 'block')
%      ├── 'paren'  - Left/right parentheses (圆括号) ()
%      ├── 'brack'  - Left/right square brackets (方括号) []
%      ├── 'brace'  - Left/right curly braces (花括号) {}
%      ├── 'chev'   - Left/right angle brackets (尖括号) <>
%      ├── 'span'   - span markers (跨度标记) I
%      └── 'bounds' - Vertical bound markers (边界标记) =


    properties
        ax
        Parent
        arginList = {'Orientation', 'BasePos', 'Parent', 'ColorList', ...
            'BlockProp', 'Height', 'Group', 'GroupSep','Format'};

        Orientation = 'top';              % 'top'/'left' (方块位置/方向)               
        BasePos     = 0;                  % Base position for block placement (方块放置的基准位置)
        Height      = 1;                  % Height of blocks (方块高度)
        Format      = 'block'             % Bracket/block shape style for each group (分组区块形状样式)
        BlockProp   = {'LineWidth', 1};   % Cell array of patch properties (用于设置方块属性的元胞数组)
        ColorList   = [0.55, 0.83, 0.78; 1.00, 1.00, 0.70; 0.75, 0.73, 0.85;
            0.98, 0.50, 0.45; 0.50, 0.69, 0.83; 0.99, 0.71, 0.38;
            0.70, 0.87, 0.41; 0.99, 0.80, 0.90; 0.85, 0.85, 0.85;
            0.74, 0.50, 0.74; 0.80, 0.92, 0.77; 1.00, 0.93, 0.44];
        Class
        ClassId
        ClassName
        Group = [];                       % Group assignments (分组)
        GroupSep = .5;                    % Group separation gap (组间分离间距)
        X; Y

        XLim
        YLim
        TLim = [0, 0];

        blockHdl
        boxHdl
    end

    properties (Hidden)
        CC; GC; CP; OXLim; OYLim; BoxX; BoxY; BlkX; BlkY
        baseV1; baseV2; OX; OY
    end

    methods
        function obj = SClusterBlock(varargin)
            % Parse axes handle if provided (解析坐标区句柄)
            if isa(varargin{1}, 'matlab.graphics.axis.Axes')
                obj.ax = varargin{1};
                obj.Parent = varargin{1};
                varargin(1) = [];
            else
                % No axes provided
            end

            % Store data (存储数据)
            obj.Class = varargin{1};
            varargin(1) = [];

            % Parse optional arguments (解析可选参数)
            for i = 1:2:(length(varargin) - 1)
                tid = ismember(lower(obj.arginList), lower(varargin{i}));
                if any(tid)
                    obj.(obj.arginList{tid}) = varargin{i + 1};
                end
            end

            if isempty(obj.Group)
                obj.Group = ones(1, length(obj.Class));
            end
            obj.Group = cumsum([1, diff(obj.Group(:).') ~= 0]);

            [obj.ClassName, ~, obj.ClassId] = unique(obj.Class(:).', 'stable');
            obj.ClassId = obj.ClassId(:).';
            obj.ColorList = [obj.ColorList; rand(length(obj.ClassName), 3)./5 + .5];
        end

        function varargout = draw(obj)
            % obj.draw() - Render the colored blocks object (渲染上色方块对象)

            % Set axes handle (设置坐标轴句柄)
            if isempty(obj.Parent) && isempty(obj.ax)
                obj.ax = gca;
            else
                obj.ax = obj.Parent;
            end

            obj.ax.XColor      = 'none';
            obj.ax.YColor      = 'none';
            obj.ax.XTick       = [];
            obj.ax.YTick       = [];
            obj.ax.NextPlot    = 'add';

            switch lower(obj.Format)
                case {'block', 'sq', 'square'}
                    obj.baseV1 = [0, 1, 1, 0];
                    obj.baseV2 = [0, 0, 1, 1];
                case 'paren'
                    baseT = linspace(pi/2 + pi/6, pi/2 - pi/6, 100);
                    obj.baseV1 = [cos(baseT) + .5, nan];
                    obj.baseV2 = [(sin(baseT) - sqrt(3)/2)./(1 - sqrt(3)/2), nan];
                case 'brack'
                    obj.baseV1 = [0, 0, 1, 1, nan];
                    obj.baseV2 = [0, 1, 1, 0, nan];
                case 'brace'
                    baseT1 = linspace(pi, pi/2, 25);
                    baseT2 = linspace(-pi/2, 0, 25);
                    baseT3 = linspace(-pi, -pi/2, 25);
                    baseT4 = linspace(pi/2, 0, 25);
                    obj.baseV1 = [(cos(baseT1) + 1)./8, ...
                                  linspace(1/8, 3/8, 50), ...
                                   cos(baseT2)./8 + 3/8, ...
                                  (cos(baseT3) + 1)./8 + 1/2, ...
                                  linspace(5/8, 7/8, 50), ...
                                  cos(baseT4)./8 + 7/8, nan];
                    obj.baseV2 = [sin(baseT1)./2, ...
                                  ones(1, 50)./2, ...
                                  sin(baseT2)./2 + 1, ...
                                  sin(baseT3)./2 + 1, ...
                                  ones(1, 50)./2, ...
                                  sin(baseT4)./2, nan];
                    obj.BlockProp = [{'LineJoin','chamfer'}, obj.BlockProp];
                case 'chev'
                    obj.baseV1 = [0, .5, 1, nan];
                    obj.baseV2 = [0,  1, 0, nan];
                case 'bounds'
                    obj.baseV1 = [0, 0, nan, 1, 1, nan];
                    obj.baseV2 = [0, 1, nan, 0, 1, nan];
                case 'span'
                    obj.baseV1 = [0, 0, nan, 1, 1, nan, 0, 1, nan];
                    obj.baseV2 = [0, 1, nan, 0, 1, nan, .5, .5, nan];
            end


            % Find group boundaries (查找分组边界)
            obj.CC = [0, find([diff(obj.ClassId), 1] ~= 0)];
            obj.GC = [0, find([diff(obj.Group(:).'), 1] ~= 0)];
            obj.CP = 1:length(obj.ClassId);
            obj.CC = unique([obj.CC, obj.GC]);

            for j = max(obj.Group):-1:2
                pos = find(obj.Group == j, 1);
                obj.CP(obj.CP >= pos) = obj.CP(obj.CP >= pos) + obj.GroupSep;
            end


            % Preallocate center coordinates (预分配中心坐标)
            switch obj.Orientation
                case 'top'
                    obj.OX = zeros(1, length(obj.CC) - 1);
                    obj.OY = ones(1, length(obj.CC) - 1) .* (obj.BasePos - obj.Height/2);
                    obj.OXLim = [min(obj.CP) - .5, max(obj.CP) + .5];
                    obj.OYLim = sort([obj.BasePos, obj.BasePos - obj.Height]);
                case 'bottom'
                    obj.OX = zeros(1, length(obj.CC) - 1);
                    obj.OY = ones(1, length(obj.CC) - 1) .* (obj.BasePos + obj.Height/2);
                    obj.OXLim = [min(obj.CP) - .5, max(obj.CP) + .5];
                    obj.OYLim = sort([obj.BasePos, obj.BasePos + obj.Height]);
                case 'left'
                    obj.OX = ones(1, length(obj.CC) - 1) .* (obj.BasePos - obj.Height/2);
                    obj.OY = zeros(1, length(obj.CC) - 1);
                    obj.OYLim = [min(obj.CP) - .5, max(obj.CP) + .5];
                    obj.OXLim = sort([obj.BasePos, obj.BasePos - obj.Height]);
                case 'right'
                    obj.OX = ones(1, length(obj.CC) - 1) .* (obj.BasePos + obj.Height/2);
                    obj.OY = zeros(1, length(obj.CC) - 1);
                    obj.OYLim = [min(obj.CP) - .5, max(obj.CP) + .5];
                    obj.OXLim = sort([obj.BasePos, obj.BasePos + obj.Height]);
            end
            obj.XLim = obj.OXLim;
            obj.YLim = obj.OYLim;

            % Draw blocks (绘制方块)
            obj.blockHdl = gobjects(1, length(obj.CC) - 1);
            obj.BlkX = cell(1, length(obj.CC) - 1);
            obj.BlkY = cell(1, length(obj.CC) - 1);
            for i = 1:(length(obj.CC) - 1)
                CL = [obj.CP(obj.CC(i) + 1), obj.CP(obj.CC(i + 1))];
                CFL = obj.CP((obj.CC(i) + 1) : obj.CC(i + 1));
                CInd = obj.ClassId(obj.CC(i) + 1);

                switch obj.Orientation
                    case 'top'
                        tX0 = [CL(1) - .5, CL(2) + .5];
                        tY0 = [obj.BasePos, obj.BasePos - obj.Height];
                        obj.BlkX{i} = tX0(1) + diff(tX0).*obj.baseV1;
                        obj.BlkY{i} = tY0(1) + diff(tY0).*obj.baseV2;
                        obj.blockHdl(i) = fill(obj.ax, obj.BlkX{i}, obj.BlkY{i}, obj.ColorList(CInd, :), obj.BlockProp{:});
                        obj.OX(i) = (CL(1) + CL(2)) / 2;
                        tX1 = [CFL(1) - .5, CFL(1:end) + .5; CFL(1) - .5, CFL(1:end) + .5; nan(1, length(CFL) + 1)];
                        tY1 = [obj.BasePos; obj.BasePos - obj.Height; nan]*ones(1, length(CFL) + 1);
                        tX2 = [CFL - .5; CFL + .5; nan(1, length(CFL)); CFL - .5; CFL + .5; nan(1, length(CFL))];
                        tY2 = [obj.BasePos; obj.BasePos; nan; obj.BasePos - obj.Height; obj.BasePos - obj.Height; nan]*ones(1, length(CFL));
                        obj.BoxX = [obj.BoxX, tX1(:).', tX2(:).'];
                        obj.BoxY = [obj.BoxY, tY1(:).', tY2(:).'];
                    case 'bottom'
                        tX0 = [CL(1) - .5, CL(2) + .5];
                        tY0 = [obj.BasePos, obj.BasePos + obj.Height];
                        obj.BlkX{i} = tX0(1) + diff(tX0).*obj.baseV1;
                        obj.BlkY{i} = tY0(1) + diff(tY0).*obj.baseV2;
                        obj.blockHdl(i) = fill(obj.ax, obj.BlkX{i}, obj.BlkY{i}, obj.ColorList(CInd, :), obj.BlockProp{:});
                        obj.OX(i) = (CL(1) + CL(2)) / 2;
                        tX1 = [CFL(1) - .5, CFL(1:end) + .5; CFL(1) - .5, CFL(1:end) + .5; nan(1, length(CFL) + 1)];
                        tY1 = [obj.BasePos; obj.BasePos + obj.Height; nan]*ones(1, length(CFL) + 1);
                        tX2 = [CFL - .5; CFL + .5; nan(1, length(CFL)); CFL - .5; CFL + .5; nan(1, length(CFL))];
                        tY2 = [obj.BasePos; obj.BasePos; nan; obj.BasePos + obj.Height; obj.BasePos + obj.Height; nan]*ones(1, length(CFL));
                        obj.BoxX = [obj.BoxX, tX1(:).', tX2(:).'];
                        obj.BoxY = [obj.BoxY, tY1(:).', tY2(:).'];
                    case 'left'
                        tX0 = [obj.BasePos, obj.BasePos - obj.Height];
                        tY0 = [CL(1) - .5, CL(2) + .5];
                        obj.BlkX{i} = tX0(1) + diff(tX0).*obj.baseV2;
                        obj.BlkY{i} = tY0(1) + diff(tY0).*obj.baseV1;
                        obj.blockHdl(i) = fill(obj.ax, obj.BlkX{i}, obj.BlkY{i}, obj.ColorList(CInd, :), obj.BlockProp{:});
                        obj.ax.YDir = 'reverse';
                        obj.OY(i) = (CL(1) + CL(2)) / 2;
                        tY1 = [CFL(1) - .5, CFL(1:end) + .5; CFL(1) - .5, CFL(1:end) + .5; nan(1, length(CFL) + 1)];
                        tX1 = [obj.BasePos; obj.BasePos - obj.Height; nan]*ones(1, length(CFL) + 1);
                        tY2 = [CFL - .5; CFL + .5; nan(1, length(CFL)); CFL - .5; CFL + .5; nan(1, length(CFL))];
                        tX2 = [obj.BasePos; obj.BasePos; nan; obj.BasePos - obj.Height; obj.BasePos - obj.Height; nan]*ones(1, length(CFL));
                        obj.BoxX = [obj.BoxX, tX1(:).', tX2(:).'];
                        obj.BoxY = [obj.BoxY, tY1(:).', tY2(:).'];
                    case 'right'
                        tX0 = [obj.BasePos, obj.BasePos + obj.Height];
                        tY0 = [CL(1) - .5, CL(2) + .5];
                        obj.BlkX{i} = tX0(1) + diff(tX0).*obj.baseV2;
                        obj.BlkY{i} = tY0(1) + diff(tY0).*obj.baseV1;
                        obj.blockHdl(i) = fill(obj.ax, obj.BlkX{i}, obj.BlkY{i}, obj.ColorList(CInd, :), obj.BlockProp{:});
                        obj.ax.YDir = 'reverse';
                        obj.OY(i) = (CL(1) + CL(2)) / 2;
                        tY1 = [CFL(1) - .5, CFL(1:end) + .5; CFL(1) - .5, CFL(1:end) + .5; nan(1, length(CFL) + 1)];
                        tX1 = [obj.BasePos; obj.BasePos + obj.Height; nan]*ones(1, length(CFL) + 1);
                        tY2 = [CFL - .5; CFL + .5; nan(1, length(CFL)); CFL - .5; CFL + .5; nan(1, length(CFL))];
                        tX2 = [obj.BasePos; obj.BasePos; nan; obj.BasePos + obj.Height; obj.BasePos + obj.Height; nan]*ones(1, length(CFL));
                        obj.BoxX = [obj.BoxX, tX1(:).', tX2(:).'];
                        obj.BoxY = [obj.BoxY, tY1(:).', tY2(:).'];
                end
            end

            obj.boxHdl = plot(obj.ax, obj.BoxX, obj.BoxY, 'LineWidth',1, 'Color','k', 'Visible','off');
            obj.X = obj.OX; obj.Y = obj.OY;
            try axis(obj.ax, 'tight'); catch, end

            if nargout == 1
                varargout = {obj.OX};
            elseif nargout == 2
                varargout = {obj.OX, obj.OY};
            end
        end


        function varargout = setBox(obj, varargin)
            set(obj.boxHdl, 'Visible','on', varargin{:})
            for i = 1:length(obj.blockHdl)
                set(obj.blockHdl(i), 'EdgeColor','none')
            end
            if nargout == 1
                varargout = {obj};
            end
        end
        function varargout = setXYTLim(obj, varargin)
            % obj.setXYTLim(varargin) - Set X, Y, and Theta limits for the group block (设置分组方块 X轴、 Y轴、角度范围)
            %   obj.setXYTLim('XLim', [xmin, xmax], 'YLim', [ymin, ymax], 'TLim', [tmin, tmax])

            tArginList = {'XLim', 'YLim', 'TLim'};
            for i = 1:2:(length(varargin) - 1)
                tid = ismember(lower(tArginList), lower(varargin{i}));
                if any(tid)
                    obj.(tArginList{tid}) = varargin{i + 1};
                end
            end

            obj.XLim = sort(obj.XLim);
            obj.YLim = sort(obj.YLim);

            if abs(diff(obj.TLim)) < eps
                for i = 1:length(obj.blockHdl)
                    tX = obj.blockHdl(i).XData;
                    tY = obj.blockHdl(i).YData;
                    [nX, nY] = getNewXY(tX, tY, obj.OXLim, obj.OYLim, obj.XLim, obj.YLim, obj.TLim);
                    set(obj.blockHdl(i), 'XData',nX, 'YData',nY);
                end
                tX = obj.BoxX;
                tY = obj.BoxY;
                [nX, nY] = getNewXY(tX, tY, obj.OXLim, obj.OYLim, obj.XLim, obj.YLim, obj.TLim);
                set(obj.boxHdl, 'XData',nX, 'YData',nY);
            else
                for i = 1:length(obj.blockHdl)
                    tX = obj.BlkX{i};
                    tY = obj.BlkY{i};
                    switch lower(obj.Format)
                        case {'block', 'sq', 'square'}
                            tXX = [linspace(tX(1), tX(2), 50), linspace(tX(2), tX(3), 50), linspace(tX(3), tX(4), 50), linspace(tX(4), tX(1), 50)];
                            tYY = [linspace(tY(1), tY(2), 50), linspace(tY(2), tY(3), 50), linspace(tY(3), tY(4), 50), linspace(tY(4), tY(1), 50)];
                        case 'paren'
                            tXX = tX;
                            tYY = tY;
                        case 'brack'
                            tXX = [linspace(tX(1), tX(2), 50), linspace(tX(2), tX(3), 50), linspace(tX(3), tX(4), 50), nan];
                            tYY = [linspace(tY(1), tY(2), 50), linspace(tY(2), tY(3), 50), linspace(tY(3), tY(4), 50), nan];
                        case 'brace'
                            tXX = tX;
                            tYY = tY;
                        case 'chev'
                            tXX = [linspace(tX(1), tX(2), 50), linspace(tX(2), tX(3), 50), nan];
                            tYY = [linspace(tY(1), tY(2), 50), linspace(tY(2), tY(3), 50), nan];
                        case 'bounds'
                            tXX = [linspace(tX(1), tX(2), 50), nan, linspace(tX(4), tX(5), 50), nan];
                            tYY = [linspace(tY(1), tY(2), 50), nan, linspace(tY(4), tY(5), 50), nan];
                        case 'span'
                            tXX = [linspace(tX(1), tX(2), 50), nan, linspace(tX(4), tX(5), 50), nan, linspace(tX(7), tX(8), 50), nan];
                            tYY = [linspace(tY(1), tY(2), 50), nan, linspace(tY(4), tY(5), 50), nan, linspace(tY(7), tY(8), 50), nan];
                    end
                    [nX, nY] = getNewXY(tXX, tYY, obj.OXLim, obj.OYLim, obj.XLim, obj.YLim, obj.TLim);
                    set(obj.blockHdl(i), 'XData',nX, 'YData',nY);
                end
                tX = interpDataNaN(obj.BoxX, 10);
                tY = interpDataNaN(obj.BoxY, 10);
                [nX, nY] = getNewXY(tX, tY, obj.OXLim, obj.OYLim, obj.XLim, obj.YLim, obj.TLim);
                set(obj.boxHdl, 'XData',nX, 'YData',nY);
            end
            
            [obj.X, obj.Y] = getNewXY(obj.OX, obj.OY, obj.OXLim, obj.OYLim, obj.XLim, obj.YLim, obj.TLim);

            try axis(obj.ax, 'tight'), catch, end
            % Helper function: coordinate transformation (辅助函数：坐标变换) 
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

            function nX = interpDataNaN(X, N)
                XX = [X(1:end-1), nan; X(2:end), nan];
                ind = any(isnan(XX), 1);
                XX(:, ind) = 1;
                nX = interp1([0,1], XX, linspace(0,1,N));
                nX(:, ind) = nan;
                nX = nX(:).';
            end

            if nargout == 1
                varargout = {obj};
            end

        end
    end
end