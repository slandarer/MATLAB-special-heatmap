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


    properties
        ax
        Parent
        arginList = {'Orientation', 'BasePos', 'Parent', 'ColorList', 'BlockProp', 'Height', 'Group', 'GroupSep'};

        Orientation = 'top';              % 'top'/'left' (方块位置/方向)               
        BasePos     = 0;                  % Base position for block placement (方块放置的基准位置)
        Height      = 1;                  % Height of blocks (方块高度)
        BlockProp   = {'LineWidth', 1};   % Cell array of patch properties (用于设置方块属性的元胞数组)
        ColorList   = [0.55, 0.83, 0.78; 1.00, 1.00, 0.70; 0.75, 0.73, 0.85;
            0.98, 0.50, 0.45; 0.50, 0.69, 0.83; 0.99, 0.71, 0.38;
            0.70, 0.87, 0.41; 0.99, 0.80, 0.90; 0.85, 0.85, 0.85;
            0.74, 0.50, 0.74; 0.80, 0.92, 0.77; 1.00, 0.93, 0.44];
        Class
        Group = [];                       % Group assignments (分组)
        GroupSep = .5;                    % Group separation gap (组间分离间距)
        X, Y

        XLim
        YLim
        TLim = [0, 0];

        blockHdl
    end

    properties (Hidden)
        CC; CP; OXLim; OYLim
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

            obj.ColorList = [obj.ColorList; rand(max(obj.Class), 3)./5 + .5];
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

            % Find group boundaries (查找分组边界)

            % Find group boundaries (查找分组边界)
            [~, ~, obj.Class] = unique(obj.Class(:).', 'stable');
            obj.Class = obj.Class(:).';
            obj.CC = [0, find([diff(obj.Class), 1] ~= 0)];
            obj.CP = 1:length(obj.Class);

            for j = max(obj.Group):-1:2
                pos = find(obj.Group == j, 1);
                obj.CP(obj.CP >= pos) = obj.CP(obj.CP >= pos) + obj.GroupSep;
            end

            % Preallocate center coordinates (预分配中心坐标)
            switch obj.Orientation
                case 'top'
                    obj.X = zeros(1, length(obj.CC) - 1);
                    obj.Y = ones(1, length(obj.CC) - 1) .* (obj.BasePos - obj.Height/2);
                    obj.OXLim = [min(obj.CP) - .5, max(obj.CP) + .5];
                    obj.OYLim = sort([obj.BasePos, obj.BasePos - obj.Height]);
                case 'bottom'
                    obj.X = zeros(1, length(obj.CC) - 1);
                    obj.Y = ones(1, length(obj.CC) - 1) .* (obj.BasePos + obj.Height/2);
                    obj.OXLim = [min(obj.CP) - .5, max(obj.CP) + .5];
                    obj.OYLim = sort([obj.BasePos, obj.BasePos + obj.Height]);
                case 'left'
                    obj.X = ones(1, length(obj.CC) - 1) .* (obj.BasePos - obj.Height/2);
                    obj.Y = zeros(1, length(obj.CC) - 1);
                    obj.OYLim = [min(obj.CP) - .5, max(obj.CP) + .5];
                    obj.OXLim = sort([obj.BasePos, obj.BasePos - obj.Height]);
                case 'right'
                    obj.X = ones(1, length(obj.CC) - 1) .* (obj.BasePos + obj.Height/2);
                    obj.Y = zeros(1, length(obj.CC) - 1);
                    obj.OYLim = [min(obj.CP) - .5, max(obj.CP) + .5];
                    obj.OXLim = sort([obj.BasePos, obj.BasePos + obj.Height]);
            end
            obj.XLim = obj.OXLim;
            obj.YLim = obj.OYLim;

            % Draw blocks (绘制方块)
            obj.blockHdl = gobjects(1, length(obj.CC) - 1);
            for i = 1:length(obj.CC) - 1
                CL = [obj.CP(obj.CC(i) + 1), obj.CP(obj.CC(i + 1))];
                CInd = obj.Class(obj.CC(i) + 1);

                switch obj.Orientation
                    case 'top'
                        obj.blockHdl(i) = fill(obj.ax, ...
                            CL([1, 2, 2, 1]) + [-0.5, 0.5, 0.5, -0.5], ...
                            [obj.BasePos, obj.BasePos, obj.BasePos - obj.Height, obj.BasePos - obj.Height], ...
                            obj.ColorList(CInd, :), obj.BlockProp{:});
                        obj.X(i) = (CL(1) + CL(2)) / 2;
                    case 'bottom'
                        obj.blockHdl(i) = fill(obj.ax, ...
                            CL([1, 2, 2, 1]) + [-0.5, 0.5, 0.5, -0.5], ...
                            [obj.BasePos, obj.BasePos, obj.BasePos + obj.Height, obj.BasePos + obj.Height], ...
                            obj.ColorList(CInd, :), obj.BlockProp{:});
                        obj.X(i) = (CL(1) + CL(2)) / 2;
                    case 'left'
                        obj.blockHdl(i) = fill(obj.ax, ...
                            [obj.BasePos, obj.BasePos, obj.BasePos - obj.Height, obj.BasePos - obj.Height], ...
                            CL([1, 2, 2, 1]) + [-0.5, 0.5, 0.5, -0.5], ...
                            obj.ColorList(CInd, :), obj.BlockProp{:});
                        obj.ax.YDir = 'reverse';
                        obj.Y(i) = (CL(1) + CL(2)) / 2;
                    case 'right'
                        obj.blockHdl(i) = fill(obj.ax, ...
                            [obj.BasePos, obj.BasePos, obj.BasePos + obj.Height, obj.BasePos + obj.Height], ...
                            CL([1, 2, 2, 1]) + [-0.5, 0.5, 0.5, -0.5], ...
                            obj.ColorList(CInd, :), obj.BlockProp{:});
                        obj.ax.YDir = 'reverse';
                        obj.Y(i) = (CL(1) + CL(2)) / 2;
                end
            end
            try axis(obj.ax, 'tight'); catch, end

            if nargout == 1
                varargout = {obj.X};
            elseif nargout == 2
                varargout = {obj.X, obj.Y};
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
            else
                for i = 1:length(obj.blockHdl)
                    tX = obj.blockHdl(i).XData;
                    tY = obj.blockHdl(i).YData;
                    tXX = [linspace(tX(1), tX(2), 30), linspace(tX(2), tX(3), 30), linspace(tX(3), tX(4), 30), linspace(tX(4), tX(1), 30)];
                    tYY = [linspace(tY(1), tY(2), 30), linspace(tY(2), tY(3), 30), linspace(tY(3), tY(4), 30), linspace(tY(4), tY(1), 30)];
                    [nX, nY] = getNewXY(tXX, tYY, obj.OXLim, obj.OYLim, obj.XLim, obj.YLim, obj.TLim);
                    set(obj.blockHdl(i), 'XData',nX, 'YData',nY);
                end
            end
            
            [obj.X, obj.Y] = getNewXY(obj.X, obj.Y, obj.OXLim, obj.OYLim, obj.XLim, obj.YLim, obj.TLim);

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

            if nargout == 1
                varargout = {obj};
            end

        end
    end
end