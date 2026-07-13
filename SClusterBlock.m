function [X, Y] = SClusterBlock(Class, varargin)
% SClusterBlock - Draw colored blocks for cluster/group visualization
%   [X, Y] = SClusterBlock(Class) draws colored blocks for each group in Class
%   along the top orientation (default) and returns center positions X,Y.
%
% Parameters:
%   'Orientation'   - 'top' (default) or 'left'
%   'BasePos'       - Base position for block placement (default: 0)
%   'Parent'        - Axes handle (default: gca)
%   'ColorList'     - Custom color matrix for groups
%   'BlockProp'     - Cell array of patch properties
%   'Height'        - Height of blocks

% =========================================================================
% Zhaoxu Liu / slandarer (2023). special heatmap
% (https://www.mathworks.com/matlabcentral/fileexchange/125520-special-heatmap),
% MATLAB Central File Exchange. Retrieved March 1, 2023.
% =========================================================================

% Parameter definition (参数定义)
obj.arginList = {'Orientation', 'BasePos', 'Parent', 'ColorList', 'BlockProp','Height'};
obj.Orientation = 'top';
obj.BasePos     = 0;
obj.Height      = 1;
obj.Parent      = gca;
obj.BlockProp   = {'LineWidth', 0.8};
obj.ColorList   = [0.55, 0.83, 0.78; 1.00, 1.00, 0.70; 0.75, 0.73, 0.85;
    0.98, 0.50, 0.45; 0.50, 0.69, 0.83; 0.99, 0.71, 0.38;
    0.70, 0.87, 0.41; 0.99, 0.80, 0.90; 0.85, 0.85, 0.85;
    0.74, 0.50, 0.74; 0.80, 0.92, 0.77; 1.00, 0.93, 0.44];
obj.ColorList = [obj.ColorList; rand(max(Class), 3) ./ 5 + 0.5];

% Parse input arguments (解析输入参数)
for i = 1:2:(length(varargin) - 1)
    tid = ismember(obj.arginList, varargin{i});
    if any(tid)
        obj.(obj.arginList{tid}) = varargin{i + 1};
    end
end

% Configure axes (配置坐标轴)
obj.Parent.XColor      = 'none';
obj.Parent.YColor      = 'none';
obj.Parent.XTick       = [];
obj.Parent.YTick       = [];
obj.Parent.NextPlot    = 'add';

% Find group boundaries (查找分组边界)
Class   = Class(:).';
CCList  = [0, find([diff(Class), 1] ~= 0)];

% Preallocate center coordinates (预分配中心坐标)
if isequal(obj.Orientation, 'top')
    X = zeros(1, length(CCList) - 1);
    Y = ones(1, length(CCList) - 1) .* (obj.BasePos - obj.Height/2);
else
    X = ones(1, length(CCList) - 1) .* (obj.BasePos - obj.Height/2);
    Y = zeros(1, length(CCList) - 1);
end

% Draw blocks (绘制方块)
for i = 1:length(CCList) - 1
    CL = [CCList(i) + 1, CCList(i + 1)];
    colorIdx = Class(CCList(i) + 1);

    if isequal(obj.Orientation, 'top')
        fill(obj.Parent, ...
            CL([1, 2, 2, 1]) + [-0.5, 0.5, 0.5, -0.5], ...
            [obj.BasePos, obj.BasePos, obj.BasePos - obj.Height, obj.BasePos - obj.Height], ...
            obj.ColorList(colorIdx, :), obj.BlockProp{:});
        X(i) = (CL(1) + CL(2)) / 2;
    else
        fill(obj.Parent, ...
            [obj.BasePos, obj.BasePos, obj.BasePos - obj.Height, obj.BasePos - obj.Height], ...
            CL([1, 2, 2, 1]) + [-0.5, 0.5, 0.5, -0.5], ...
            obj.ColorList(colorIdx, :), obj.BlockProp{:});
        obj.Parent.YDir = 'reverse';
        Y(i) = (CL(1) + CL(2)) / 2;
    end
end

axis(obj.Parent, 'tight')
end