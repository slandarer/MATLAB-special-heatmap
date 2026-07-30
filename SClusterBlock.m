classdef SClusterBlock
% SClusterBlock - Create colored blocks for cluster/group visualization
%   SCB = SClusterBlock(Class) Creates colored blocks for each group
%   along the top orientation (default).
%   创建顶部方向聚类方块对象。
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
        BlockProp   = {'LineWidth', 0.8}; % Cell array of patch properties (用于设置方块属性的元胞数组)
        ColorList   = [0.55, 0.83, 0.78; 1.00, 1.00, 0.70; 0.75, 0.73, 0.85;
            0.98, 0.50, 0.45; 0.50, 0.69, 0.83; 0.99, 0.71, 0.38;
            0.70, 0.87, 0.41; 0.99, 0.80, 0.90; 0.85, 0.85, 0.85;
            0.74, 0.50, 0.74; 0.80, 0.92, 0.77; 1.00, 0.93, 0.44];
        Class
        Group = [];                       % Group assignments (分组)
        GroupSep = .5;                    % Group separation gap (组间分离间距)
        X, Y
    end

    properties (Hidden)
        CC; CP
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
            if isequal(obj.Orientation, 'top')
                obj.X = zeros(1, length(obj.CC) - 1);
                obj.Y = ones(1, length(obj.CC) - 1) .* (obj.BasePos - obj.Height/2);
            else
                obj.X = ones(1, length(obj.CC) - 1) .* (obj.BasePos - obj.Height/2);
                obj.Y = zeros(1, length(obj.CC) - 1);
            end

            % Draw blocks (绘制方块)
            for i = 1:length(obj.CC) - 1
                CL = [obj.CP(obj.CC(i) + 1), obj.CP(obj.CC(i + 1))];
                CInd = obj.Class(obj.CC(i) + 1);

                if isequal(obj.Orientation, 'top')
                    fill(obj.ax, ...
                        CL([1, 2, 2, 1]) + [-0.5, 0.5, 0.5, -0.5], ...
                        [obj.BasePos, obj.BasePos, obj.BasePos - obj.Height, obj.BasePos - obj.Height], ...
                        obj.ColorList(CInd, :), obj.BlockProp{:});
                    obj.X(i) = (CL(1) + CL(2)) / 2;
                else
                    fill(obj.ax, ...
                        [obj.BasePos, obj.BasePos, obj.BasePos - obj.Height, obj.BasePos - obj.Height], ...
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
    end
end