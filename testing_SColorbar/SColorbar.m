classdef SColorbar < handle
% SColorbar offers colorbars with greater flexibility in positioning, 
% supports arbitrary rotation, and allows multiple colorbars to coexist within the same axes.
% SColorbar 提供更灵活的位置控制、支持旋转，并允许在同一坐标区内共存多个颜色条。
%
%   scbar = SColorbar(); creates a colorbar.
%   创建颜色条对象。
%
%   scbar = SColorbar(ax, ___); creates a colorbar in the specified axes.
%   在指定坐标区创建颜色条。
%
%   scbar = SColorbar('Location',loc); creates a colorbar at the specified location.
%   通过指定位置创建颜色条。
%     'north' - top (上方)    | 'northeast' - top-right (右上)
%     'south' - bottom (下方) | 'southeast' - bottom-right (右下)
%     'east'  - right (右侧)  | 'northwest' - top-left (左上)
%     'west'  - left (左侧)   | 'southwest' - bottom-left (左下)
%
%   scbar = SColorbar(___, propName, propVal); specifies property name-value
%   pairs when creating the object.
%   创建对象时指定属性名-属性值对。
%
%   scbar.propName = propVal; sets properties before calling draw().
%   在调用 draw() 前设置属性。
%
%   scbar = scbar.draw(); renders the colorbar.
%   渲染颜色条。
%
% Basic usage:
%   image(peaks(15), 'CDataMapping','scaled')
%   axis off
% 
%   scbar = SColorbar('Location','east');
%   scbar.draw()
%
% Methods (try: help SColorbar.setXYTLim)
%   draw               - Render the colorbar object (渲染颜色条对象)
%   setFrame           - Set properties for frame (设置边框属性)
%   setTick            - Set tick positions (设置刻度)
%   setTickLabel       - Set properties for tick label (设置刻度标签属性)
%   setTickLabelString - Set properties for tick label (设置刻度标签文本)
%   freezeColors       - Permanently assign the current colormap colors to each patch 
%                        based on its value, decoupling them from both the 
%                        colormap axis limits (CLim) and the colormap itself
%                        (根据当前数值将颜色映射固定到每个填充图形，使其不再随颜色轴范围或颜色映射表的变化而改变)
%   setXYTLim          - Set X, Y, and Theta limits for the colorbar (设置颜色条 X轴、 Y轴、角度范围)

    properties
        ax, fig                   % Axes and figure handles (坐标区及图形窗口句柄)
        Parent = []               % Parent axes (父坐标区)

        % Parameter name list for parsing (参数名称列表，用于解析输入)
        arginList = {'TickDir', 'TickLength', 'Location', 'CDir', ...
            'Tick', 'TickLabel', 'TickLabelOffset', 'BasePos', 'Width', ...
            'Color', 'LineWidth', 'TitleLocation', 'TitleLabelOffset', ...
            'TickVisible'}

        CLim                      % Color limits (颜色范围)
        Colormap                  % Colormap (颜色映射表)

        Tick                      % Tick positions (刻度位置)
        TickDir = 'out'           % Tick direction (刻度方向): 'in','out','both'
        TickLength = .1;          % Tick length (刻度长度)
        TickLabel                 % Tick labels (刻度标签)
        TickLabelFormat = @(x) num2str(x)  % Tick label formatting function (刻度标签格式化函数)
        TickLabelOffset = .15;    % Offset from tick end to tick label (刻度末端到刻度标签的偏移)

        Location = 'east'         % Colorbar location (颜色条位置)
                                  % 'north'/'south'/'east'/'west'/
                                  % 'northeast'/'northwest'/
                                  % 'southeast'/'southwest'/
        BasePos                   % Base position for colorbar placement (颜色条放置的基准位置)
        Width = .5;               % Width of the colorbar (颜色条宽度)
        CDir = 'normal'           % Color direction (颜色方向): 'normal'/'reverse' (正常/反转)

        XLim = []                 % X-axis limits (X轴范围)
        YLim = []                 % Y-axis limits (Y轴范围)
        TLim = [0, 0]             % Theta limits (角度范围)

        Color = [0, 0, 0]         % Frame and tick color (边框及刻度颜色)
        LineWidth = 1             % Line width for frame and ticks (边框及刻度线宽)

        titleHdl                  % Handle to title text (标题文本句柄)
        tickHdl                   % Handles to tick lines (刻度线句柄)
        labelHdl                  % Handles to tick labels (刻度标签句柄)
        patchHdl                  % Handle to colorbar patch (颜色条面片句柄)
        frameHdl                  % Handle to colorbar frame (颜色条边框句柄)
    end

    properties (Hidden)
        OXLim                     % Original X limits before transformation (变换前原始X轴范围)
        OYLim                     % Original Y limits before transformation (变换前原始Y轴范围)
        Orientation = 'vertical'  % Colorbar orientation (颜色条方向): 'horizontal'/'vertical' (横向/竖向)
        isFrozen = false;         % Flag to freeze colors (冻结颜色标志)
        TX                        % Tick X positions (刻度 X 位置)
        TY                        % Tick Y positions (刻度 Y 位置)
        LX                        % Label X positions (标签 X 位置)
        LY                        % Label Y positions (标签 Y 位置)
        TickExist = true
        labelProp
    end



    methods
        function obj = SColorbar(varargin)
            % Parse axes handle if provided (解析坐标区句柄)
            if isa(varargin{1}, 'matlab.graphics.axis.Axes')
                obj.ax = varargin{1};
                obj.Parent = varargin{1};
                varargin(1) = [];
            else
                % No axes provided
            end

            % Parse optional arguments (解析可选参数)
            for i = 1:2:(length(varargin) - 1)
                tid = ismember(lower(obj.arginList), lower(varargin{i}));
                if any(tid)
                    obj.(obj.arginList{tid}) = varargin{i + 1};
                end
            end

            if ismember('tick', lower(varargin(1:2:(length(varargin) - 1)))) && isempty(obj.Tick)
                obj.TickExist = false;
            end
        end

        function varargout = draw(obj)
            % obj.draw() - Render the colorbar object (渲染颜色条对象)

            % Set axes handle (设置坐标轴句柄)
            if isempty(obj.Parent) && isempty(obj.ax)
                obj.ax = gca;
            else
                obj.ax = obj.Parent;
            end
            obj.ax.NextPlot = 'add';

            if isa(obj.ax.Parent, 'matlab.graphics.layout.TiledChartLayout')
                obj.fig = obj.ax.Parent.Parent;
            else
                obj.fig = obj.ax.Parent;
            end

            obj.TickLength(obj.TickLength < 0) = 0;
            obj.TickLength(obj.TickLength > .5) = .5;
            obj.TickLabelOffset(obj.TickLabelOffset <= 1e-4) = 1e-4;
            obj.TickLabelOffset(obj.TickLabelOffset > .5) = .5;

            colorbar(obj.ax, 'off');
            axis(obj.ax, 'tight');
            xl = obj.ax.XLim;
            yl = obj.ax.YLim;

            thdl = findobj(gca, 'Type', 'text');
            if isempty(thdl)
                tpos = [];
            else
                tpos = reshape([thdl(:).Position], 3, []);
            end

            switch lower(obj.Location)
                case 'north'
                    obj.Orientation = 'horizontal';
                    if isempty(obj.BasePos)
                        if (~isempty(tpos)) && any(tpos(2, :) < yl(1))
                            obj.BasePos = yl(1) - 1;
                        else
                            obj.BasePos = yl(1) - .5;
                        end
                    end
                    obj.OYLim = sort([obj.BasePos, obj.BasePos - obj.Width]);
                    obj.OXLim = xl;
                case 'south' 
                    obj.Orientation = 'horizontal';
                    if isempty(obj.BasePos)
                        if (~isempty(tpos)) && any(tpos(2, :) > yl(2))
                            obj.BasePos = yl(2) + 1;
                        else
                            obj.BasePos = yl(2) + .5;
                        end
                    end
                    obj.OYLim = sort([obj.BasePos, obj.BasePos + obj.Width]);
                    obj.OXLim = xl;
                case 'east'
                    if isempty(obj.BasePos)
                        if (~isempty(tpos)) && any(tpos(1, :) > xl(2))
                            obj.BasePos = xl(2) + 1; 
                        else
                            obj.BasePos = xl(2) + .5; 
                        end
                    end
                    obj.OXLim = sort([obj.BasePos, obj.BasePos + obj.Width]);
                    obj.OYLim = yl;
                case 'west'
                    if isempty(obj.BasePos)
                        if (~isempty(tpos)) && any(tpos(1, :) < xl(1))
                            obj.BasePos = xl(1) - 1; 
                        else
                            obj.BasePos = xl(1) - .5; 
                        end
                    end
                    obj.OXLim = sort([obj.BasePos, obj.BasePos - obj.Width]);
                    obj.OYLim = yl;
                case 'northeast'
                    if isempty(obj.BasePos)
                        if (~isempty(tpos)) && any(tpos(1, :) > xl(2))
                            obj.BasePos = xl(2) + 1; 
                        else
                            obj.BasePos = xl(2) + .5; 
                        end
                    end
                    obj.OXLim = sort([obj.BasePos, obj.BasePos + obj.Width]);
                    obj.OYLim = [yl(1), yl(2) - diff(yl).*.55];
                case 'northwest'
                    if isempty(obj.BasePos)
                        if (~isempty(tpos)) && any(tpos(1, :) < xl(1))
                            obj.BasePos = xl(1) - 1; 
                        else
                            obj.BasePos = xl(1) - .5; 
                        end
                    end
                    obj.OXLim = sort([obj.BasePos, obj.BasePos - obj.Width]);
                    obj.OYLim = [yl(1), yl(2) - diff(yl).*.55];
                case 'southeast'
                    if isempty(obj.BasePos)
                        if (~isempty(tpos)) && any(tpos(1, :) > xl(2))
                            obj.BasePos = xl(2) + 1; 
                        else
                            obj.BasePos = xl(2) + .5; 
                        end
                    end
                    obj.OXLim = sort([obj.BasePos, obj.BasePos + obj.Width]);
                    obj.OYLim = [yl(1) + diff(yl).*.55, yl(2)];
                case 'southwest'
                    if isempty(obj.BasePos)
                        if (~isempty(tpos)) && any(tpos(1, :) < xl(1))
                            obj.BasePos = xl(1) - 1; 
                        else
                            obj.BasePos = xl(1) - .5; 
                        end
                    end
                    obj.OXLim = sort([obj.BasePos, obj.BasePos - obj.Width]);
                    obj.OYLim = [yl(1) + diff(yl).*.55, yl(2)];
            end

            obj.CLim = obj.ax.CLim;
            obj.Colormap = obj.ax.Colormap;

            switch obj.Orientation
                case 'vertical'
                    [XMesh, YMesh] = meshgrid([0, 1], linspace(0, 1, size(obj.Colormap, 1) + 1));
                    CDList = linspace(obj.CLim(1), obj.CLim(2), size(obj.Colormap, 1) + 1);
                    CDList = CDList(1:(end-1))./2 + CDList(2:end)./2;
                    CDList = CDList(:);
                    CMesh = zeros(size(XMesh));
                    CMesh(1:end-1, :) = CDList(end:-1:1, [1, 1]);
                    if strcmpi(obj.CDir, 'reverse')
                        CMesh(1:end-1, :) = CDList(:, [1, 1]);
                    end
                    obj.patchHdl = surf(obj.ax, obj.OXLim(1) + XMesh.*diff(obj.OXLim), obj.OYLim(1) + YMesh.*diff(obj.OYLim), YMesh.*0, ...
                        'CData',CMesh, 'EdgeColor','none', 'FaceColor','flat');
                case 'horizontal'
                    [YMesh, XMesh] = meshgrid([0, 1], linspace(0, 1, size(obj.Colormap, 1) + 1));
                    CDList = linspace(obj.CLim(1), obj.CLim(2), size(obj.Colormap, 1) + 1);
                    CDList = CDList(1:(end-1))./2 + CDList(2:end)./2;
                    CDList = CDList(:);
                    CMesh = zeros(size(XMesh));
                    CMesh(1:end-1, :) = CDList(:, [1, 1]);
                    if strcmpi(obj.CDir, 'reverse')
                        CMesh(1:end-1, :) = CDList(end:-1:1, [1, 1]);
                    end
                    obj.patchHdl = surf(obj.ax, obj.OXLim(1) + XMesh.*diff(obj.OXLim), obj.OYLim(1) + YMesh.*diff(obj.OYLim), YMesh.*0, ...
                        'CData',CMesh, 'EdgeColor','none', 'FaceColor','flat');
            end

            obj.frameHdl = plot(obj.ax, obj.OXLim([1,2,2,1,1]), obj.OYLim([1,1,2,2,1]), ...
                'Color',obj.Color, 'LineWidth',obj.LineWidth, 'LineJoin','chamfer');

            obj.refreshLabelPos()
           

            obj.XLim = obj.OXLim;
            obj.YLim = obj.OYLim;

            addlistener(obj.fig, 'Colormap', 'PostSet', @(src, evt) obj.refreshColorbar(src, evt));
            addlistener(obj.ax, 'Colormap', 'PostSet', @(src, evt) obj.refreshColorbar(src, evt));
            addlistener(obj.ax, 'CLim', 'PostSet', @(src, evt) obj.refreshColorbar(src, evt));

            view(obj.ax, 2)
            axis(obj.ax, 'tight');
            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = freezeColors(obj)            
            % obj.freezeColors() - Permanently assign the current colormap colors to each patch
            % based on its value, decoupling them from both the colormap axis limits (CLim) and the colormap itself.
            % (根据当前数值将颜色映射固定到每个填充图形，使其不再随颜色轴范围或颜色映射表的变化而改变)

            [XMesh, ~] = meshgrid([0, 1], linspace(0, 1, size(obj.Colormap, 1) + 1));
            CMesh = zeros([size(XMesh), 3]);
            switch obj.Orientation
                case 'vertical'
                    CMesh(1:end-1, :, 1) = obj.Colormap(end:-1:1, [1, 1]);
                    CMesh(1:end-1, :, 2) = obj.Colormap(end:-1:1, [2, 2]);
                    CMesh(1:end-1, :, 3) = obj.Colormap(end:-1:1, [3, 3]);
                    if strcmpi(obj.CDir, 'reverse')
                        CMesh(1:end-1, :, 1) = obj.Colormap(:, [1, 1]);
                        CMesh(1:end-1, :, 2) = obj.Colormap(:, [2, 2]);
                        CMesh(1:end-1, :, 3) = obj.Colormap(:, [3, 3]);
                    end
                case 'horizontal'
                    CMesh(1:end-1, :, 1) = obj.Colormap(:, [1, 1]);
                    CMesh(1:end-1, :, 2) = obj.Colormap(:, [2, 2]);
                    CMesh(1:end-1, :, 3) = obj.Colormap(:, [3, 3]);
                    if strcmpi(obj.CDir, 'reverse')
                        CMesh(1:end-1, :, 1) = obj.Colormap(end:-1:1, [1, 1]);
                        CMesh(1:end-1, :, 2) = obj.Colormap(end:-1:1, [2, 2]);
                        CMesh(1:end-1, :, 3) = obj.Colormap(end:-1:1, [3, 3]);
                    end
            end

            set(obj.patchHdl, 'CData',CMesh)
            obj.isFrozen = true;
            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setXYTLim(obj, varargin)
            % obj.setXYTLim(varargin) - Set X, Y, and Theta limits for the colorbar (设置颜色条 X轴、 Y轴、角度范围)
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
            if diff(obj.XLim) > eps
                obj.OXLim = obj.XLim;
                obj.OYLim = obj.YLim;
            end
            if isempty(obj.TLim)
                obj.TLim = [0, 0];
            end
            obj.TLim = obj.TLim([1, 1]);

            set(obj.frameHdl, 'XData',obj.OXLim([1,2,2,1,1]), 'YData',obj.OYLim([1,1,2,2,1]))
            switch obj.Orientation
                case 'vertical'
                    [XMesh, YMesh] = meshgrid([0, 1], linspace(0, 1, size(obj.Colormap, 1) + 1));
                    set(obj.patchHdl, 'XData',obj.OXLim(1) + XMesh.*diff(obj.OXLim), 'YData',obj.OYLim(1) + YMesh.*diff(obj.OYLim));
                case 'horizontal'
                    [YMesh, XMesh] = meshgrid([0, 1], linspace(0, 1, size(obj.Colormap, 1) + 1));
                    set(obj.patchHdl, 'XData',obj.OXLim(1) + XMesh.*diff(obj.OXLim), 'YData',obj.OYLim(1) + YMesh.*diff(obj.OYLim));
            end
            obj.refreshLabelPos()

            if  abs(obj.TLim(1)) > eps

                tX = obj.patchHdl.XData;
                tY = obj.patchHdl.YData;
                [nX, nY] = getNewXY(tX, tY, obj.OXLim, obj.OYLim, obj.OXLim, obj.OYLim, obj.TLim);
                set(obj.patchHdl, 'XData',nX, 'YData',nY)
                
                tX = obj.frameHdl.XData;
                tY = obj.frameHdl.YData;
                [nX, nY] = getNewXY(tX, tY, obj.OXLim, obj.OYLim, obj.OXLim, obj.OYLim, obj.TLim);
                set(obj.frameHdl, 'XData',nX, 'YData',nY)

                if ~isempty(obj.tickHdl)
                tX = obj.tickHdl.XData;
                tY = obj.tickHdl.YData;
                [nX, nY] = getNewXY(tX, tY, obj.OXLim, obj.OYLim, obj.OXLim, obj.OYLim, obj.TLim);
                set(obj.tickHdl, 'XData',nX, 'YData',nY)
                end

                if ~isempty(obj.labelHdl)
                for i = 1:length(obj.labelHdl)
                    tX = obj.labelHdl(i).Position(1);
                    tY = obj.labelHdl(i).Position(2);
                    [nX, nY] = getNewXY(tX, tY, obj.OXLim, obj.OYLim, obj.OXLim, obj.OYLim, obj.TLim);
                    set(obj.labelHdl(i), 'Position',[nX,nY,0])
                    
                    nV = [nX - obj.tickHdl.XData(3*i - 2), nY - obj.tickHdl.YData(3*i - 2)];
                    nL = sqrt(nV(1).^2 + nV(2).^2);
                    nV = nV./[nL, nL];
                    nT = atan2(nV(2), nV(1)); 
                    nT = nT/pi*180;
                    if nT >= 90 || nT < -90
                        set(obj.labelHdl(i), 'Rotation',180 - nT, 'HorizontalAlignment','right')
                    else
                        set(obj.labelHdl(i), 'Rotation',-nT, 'HorizontalAlignment','left')
                        
                    end
                end
                end


            end

            axis(obj.ax, 'tight');
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

        function varargout = setTick(obj, ticks)
            % obj.setTick(ticks) - Set tick positions (设置刻度)
            obj.Tick = ticks;
            if isempty(obj.Tick)
                obj.TickExist = false;
            else
                obj.TickExist = true;
            end
            obj.refreshLabelPos()

            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setTickLabel(obj, varargin)
            % obj.setTickLabel(varargin) - Set properties for tick label (设置刻度标签属性)
            for i = 1:length(obj.labelHdl)
                set(obj.labelHdl(i), varargin{:})
            end

            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setTickLabelString(obj, labels)
            % obj.setTickLabelString(labels) - Set properties for tick label (设置刻度标签文本)
            L = length(labels);
            for i = 1:length(obj.labelHdl)
                tind = mod(i - 1, L) + 1;
                obj.labelHdl(i).String = labels{tind};
            end

            if nargout == 1
                varargout = {obj};
            end
        end

        function varargout = setFrame(obj, varargin)
            % obj.setFrame(varargin) - Set properties for frame (设置边框属性)
            set(obj.frameHdl, varargin{:})
            set(obj.tickHdl, varargin{:})

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
        

        function refreshColorbar(obj, ~, ~)
            if ~obj.isFrozen
                obj.CLim = obj.ax.CLim;
                obj.Colormap = obj.ax.Colormap;
                switch obj.Orientation
                    case 'vertical'
                        [XMesh, YMesh] = meshgrid([0, 1], linspace(0, 1, size(obj.Colormap, 1) + 1));
                        CDList = linspace(obj.CLim(1), obj.CLim(2), size(obj.Colormap, 1) + 1);
                        CDList = CDList(1:(end-1))./2 + CDList(2:end)./2;
                        CDList = CDList(:);
                        CMesh = zeros(size(XMesh));
                        CMesh(1:end-1, :) = CDList(end:-1:1, [1, 1]);
                        if strcmpi(obj.CDir, 'reverse')
                            CMesh(1:end-1, :) = CDList(:, [1, 1]);
                        end
                    case 'horizontal'
                        [YMesh, XMesh] = meshgrid([0, 1], linspace(0, 1, size(obj.Colormap, 1) + 1));
                        CDList = linspace(obj.CLim(1), obj.CLim(2), size(obj.Colormap, 1) + 1);
                        CDList = CDList(1:(end-1))./2 + CDList(2:end)./2;
                        CDList = CDList(:);
                        CMesh = zeros(size(XMesh));
                        CMesh(1:end-1, :) = CDList(:, [1, 1]);
                        if strcmpi(obj.CDir, 'reverse')
                            CMesh(1:end-1, :) = CDList(end:-1:1, [1, 1]);
                        end
                end
                set(obj.patchHdl, 'XData', obj.OXLim(1) + XMesh.*diff(obj.OXLim), ...
                    'YData', obj.OYLim(1) + YMesh.*diff(obj.OYLim), ...
                    'ZData', YMesh.*0, 'CData',CMesh)

                obj.Tick = [];
                obj.refreshLabelPos()
            end
        end

        function refreshLabelPos(obj)
            if length(obj.Location) > 5
                ts = obj.getTick(diff(obj.CLim), 5);
            else
                ts = obj.getTick(diff(obj.CLim), 10);
            end
            obj.Tick(obj.Tick < obj.CLim(1)) = [];
            obj.Tick(obj.Tick > obj.CLim(2)) = [];
            if isempty(obj.Tick) && obj.TickExist
                if obj.CLim(1).*obj.CLim(2) <= 0
                    obj.Tick = unique([0:(-ts):obj.CLim(1), 0:ts:obj.CLim(2)]);
                elseif all(obj.CLim > 0)
                    obj.Tick = 0:ts:obj.CLim(2);
                else
                    obj.Tick = sort(0:(-ts):obj.CLim(1));
                end
            end
            obj.Tick(obj.Tick < obj.CLim(1)) = [];
            obj.Tick(obj.Tick > obj.CLim(2)) = [];

            if ~isempty(obj.Tick)
            switch lower(obj.Location)
                case 'north'
                    obj.TX = obj.OXLim(1) + (obj.Tick - obj.CLim(1))./diff(obj.CLim).*diff(obj.OXLim);
                    if strcmpi(obj.CDir, 'reverse')
                        obj.TX = obj.OXLim(2) - (obj.Tick - obj.CLim(1))./diff(obj.CLim).*diff(obj.OXLim);
                    end
                    obj.LX = obj.TX;
                    obj.TX = [obj.TX; obj.TX; obj.TX.*nan];
                    switch obj.TickDir
                        case 'in'
                            obj.TY = [obj.OYLim(1); obj.OYLim(1) + obj.TickLength; nan]*ones(1, length(obj.Tick));
                            obj.LY = (obj.OYLim(1) - obj.TickLabelOffset)*ones(1, length(obj.Tick));
                        case 'out'
                            obj.TY = [obj.OYLim(1) - obj.TickLength; obj.OYLim(1); nan]*ones(1, length(obj.Tick));
                            obj.LY = (obj.OYLim(1) - obj.TickLabelOffset - obj.TickLength)*ones(1, length(obj.Tick));
                        case 'both'
                            obj.TY = [obj.OYLim(1) - obj.TickLength; obj.OYLim(1) + obj.TickLength; nan]*ones(1, length(obj.Tick));
                            obj.LY = (obj.OYLim(1) - obj.TickLabelOffset - obj.TickLength)*ones(1, length(obj.Tick));
                    end
                case 'south'
                    obj.TX = obj.OXLim(1) + (obj.Tick - obj.CLim(1))./diff(obj.CLim).*diff(obj.OXLim);
                    if strcmpi(obj.CDir, 'reverse')
                        obj.TX = obj.OXLim(2) - (obj.Tick - obj.CLim(1))./diff(obj.CLim).*diff(obj.OXLim);
                    end
                    obj.LX = obj.TX;
                    obj.TX = [obj.TX; obj.TX; obj.TX.*nan];
                    switch obj.TickDir
                        case 'in'
                            obj.TY = [obj.OYLim(2) - obj.TickLength; obj.OYLim(2); nan]*ones(1, length(obj.Tick));
                            obj.LY = (obj.OYLim(2) + obj.TickLabelOffset)*ones(1, length(obj.Tick));
                        case 'out'
                            obj.TY = [obj.OYLim(2); obj.OYLim(2) + obj.TickLength; nan]*ones(1, length(obj.Tick));
                            obj.LY = (obj.OYLim(2) + obj.TickLabelOffset + obj.TickLength)*ones(1, length(obj.Tick));
                        case 'both'
                            obj.TY = [obj.OYLim(2) - obj.TickLength; obj.OYLim(2) + obj.TickLength; nan]*ones(1, length(obj.Tick));
                            obj.LY = (obj.OYLim(2) + obj.TickLabelOffset + obj.TickLength)*ones(1, length(obj.Tick));
                    end
                case {'east', 'northeast', 'southeast'}
                    obj.TY = obj.OYLim(2) - (obj.Tick - obj.CLim(1))./diff(obj.CLim).*diff(obj.OYLim);
                    if strcmpi(obj.CDir, 'reverse')
                        obj.TY = obj.OYLim(1) + (obj.Tick - obj.CLim(1))./diff(obj.CLim).*diff(obj.OYLim);
                    end
                    obj.LY = obj.TY;
                    obj.TY = [obj.TY; obj.TY; obj.TY.*nan];
                    switch obj.TickDir
                        case 'in'
                            obj.TX = [obj.OXLim(2) - obj.TickLength; obj.OXLim(2); nan]*ones(1, length(obj.Tick));
                            obj.LX = (obj.OXLim(2) + obj.TickLabelOffset)*ones(1, length(obj.Tick));
                        case 'out'
                            obj.TX = [obj.OXLim(2); obj.OXLim(2) + obj.TickLength; nan]*ones(1, length(obj.Tick));
                            obj.LX = (obj.OXLim(2) + obj.TickLength + obj.TickLabelOffset)*ones(1, length(obj.Tick));
                        case 'both'
                            obj.TX = [obj.OXLim(2) - obj.TickLength; obj.OXLim(2) + obj.TickLength; nan]*ones(1, length(obj.Tick));
                            obj.LX = (obj.OXLim(2) + obj.TickLength + obj.TickLabelOffset)*ones(1, length(obj.Tick));
                    end
                case {'west', 'northwest', 'southwest'}
                    obj.TY = obj.OYLim(2) - (obj.Tick - obj.CLim(1))./diff(obj.CLim).*diff(obj.OYLim);
                    if strcmpi(obj.CDir, 'reverse')
                        obj.TY = obj.OYLim(1) + (obj.Tick - obj.CLim(1))./diff(obj.CLim).*diff(obj.OYLim);
                    end
                    obj.LY = obj.TY;
                    obj.TY = [obj.TY; obj.TY; obj.TY.*nan];
                    switch obj.TickDir
                        case 'in'
                            obj.TX = [obj.OXLim(1); obj.OXLim(1) + obj.TickLength; nan]*ones(1, length(obj.Tick));
                            obj.LX = (obj.OXLim(1) - obj.TickLabelOffset)*ones(1, length(obj.Tick));
                        case 'out'
                            obj.TX = [obj.OXLim(1) - obj.TickLength; obj.OXLim(1); nan]*ones(1, length(obj.Tick));
                            obj.LX = (obj.OXLim(1) - obj.TickLabelOffset - obj.TickLength)*ones(1, length(obj.Tick));
                        case 'both'
                            obj.TX = [obj.OXLim(1) - obj.TickLength; obj.OXLim(1) + obj.TickLength; nan]*ones(1, length(obj.Tick));
                            obj.LX = (obj.OXLim(1) - obj.TickLabelOffset - obj.TickLength)*ones(1, length(obj.Tick));
                    end
            end
            

            obj.TickLabel = {};
            for i = 1:length(obj.Tick)
                obj.TickLabel{i} = obj.TickLabelFormat(obj.Tick(i));
            end
            end

            delete(obj.tickHdl)
            if ~isempty(obj.Tick)
                obj.tickHdl = plot(obj.ax, obj.TX(:), obj.TY(:), 'Color',obj.Color, 'LineWidth',obj.LineWidth);
            end

            if ~isempty(obj.labelHdl)
                obj.labelProp = {'FontSize', obj.labelHdl(1).FontSize, ...
                             'FontName', obj.labelHdl(1).FontName, ...
                             'FontWeight', obj.labelHdl(1).FontWeight, ...
                             'Color', obj.labelHdl(1).Color};
            else
                obj.labelProp = {'FontSize',12, 'FontName','Times New Roman'};
            end

            delete(obj.labelHdl)
            if ~isempty(obj.Tick)
            switch lower(obj.Location)
                case 'north'
                    obj.labelHdl = text(obj.ax, obj.LX, obj.LY, obj.TickLabel, 'Rotation',30, 'HorizontalAlignment','left', obj.labelProp{:});
                case 'south'
                    obj.labelHdl = text(obj.ax, obj.LX, obj.LY, obj.TickLabel, 'Rotation',30, 'HorizontalAlignment','right', obj.labelProp{:});
                case {'east', 'northeast', 'southeast'}
                    obj.labelHdl = text(obj.ax, obj.LX, obj.LY, obj.TickLabel, 'HorizontalAlignment','left', obj.labelProp{:});
                case {'west', 'northwest', 'southwest'}
                    obj.labelHdl = text(obj.ax, obj.LX, obj.LY, obj.TickLabel, 'HorizontalAlignment','right', obj.labelProp{:});
            end
            end

        end
    end
end