classdef SMantelLink < handle
% SMantelLink Create Mantel test link visualization
%   ML = SMantelLink(dataMat1, dataMat2) creates a Mantel link plot between
%   two data matrices. Rows are samples, columns are variables.
%   在两个数据矩阵之间创建Mantel链接图。行为样本，列为变量。
%
%   ML = SMantelLink(ax, ___) creates the plot in the specified axes.
%   在指定坐标区创建绘图。
%
%   ML = SMantelLink(___, propName, propVal) specifies property name-value pairs.
%   指定属性名-属性值对。
%
%   ML.propName = propVal; sets properties before calling draw().
%   调用 draw() 前设置属性。
%
%   ML.draw(); renders the Mantel link plot.
%   渲染 Mantel 链接图。


% =========================================================================
% @author : slandarer
% 公众号  : slandarer随笔 
% -------------------------------------------------------------------------
% Zhaoxu Liu / slandarer (2025). special heatmap 
% (https://www.mathworks.com/matlabcentral/fileexchange/125520-special-heatmap), 
% MATLAB Central File Exchange. 检索来源 2025/12/1.
% =========================================================================
% References
% [1] Mantel N. The detection of disease clustering and a generalized regression approach. 
%     Cancer Res. 1967 Feb;27(2):209-20. PMID: 6018555.
% [2] Borcard, D. & Legendre, P. (2012) Is the Mantel correlogram powerful enough to be 
%     useful in ecological analysis? A simulation study. Ecology 93: 1473-1481.
% [3] Legendre, P. and Legendre, L. (2012) Numerical Ecology. 3rd English Edition. Elsevier.
% [4] Houyun Huang(2021). linkET: Everything is Linkable. R package version 0.0.3.

    properties
        ax, 
        Parent = [];
        arginList = {'Parent', 'Group', 'GroupName', 'Layout', ...
                     'RBreak', 'PBreak', 'Method', 'NumPerm'}

        % Input data matrices: rows=samples, cols=variables (输入数据矩阵：行=样本，列=变量)
        dataMat1
        dataMat2

        % Distance method: string or function handle (距离方法：字符串或函数句柄)
        Distance1 = 'euclidean';
        Distance2 = @(ZI, ZJ) sum(abs(ZI - ZJ), 2) ./ sum(ZI + ZJ, 2);

        % Node colors (节点颜色)
        NodeColor1 = [150, 150, 150]./255
        NodeColor2 = [150, 150, 150]./255

        Group                         % Group assignments for columns of dataMat2 (dataMat2列的分组)
        GroupName                     % Group names (组名)                   
        Layout = 'triu'               % 'tril'/'triu'
        LegendLocation = 'east'       % 'west'/'east'
        LegendTitle = {"Mantel's p", "Mantel's r", "Pearson's r"}
        LegendPosition

        PBreak = [-inf, .01, .05, inf];                      % P-value breakpoints (P值断点)
        PLabel                                               % P-value labels (P值标签)
        PColor = [217,95,2; 27,158,119; 224,224,224]./255;   % P-value colors (P值颜色)
        PValue                                               % P-value matrix (P值矩阵)
        PLevel                                               % % P-value level indices (P值等级索引)

        RBreak = [-inf, .2, .4, inf];                        % R-value breakpoints for line width mapping (R值线宽映射的断点)
        RLabel                                               % R-value labels (R值标签)
        RWidth = [1, 4, 8]                                   % R-value line widths (R值对应的线宽)
        RValue                                               % R-value matrix (R值矩阵)
        RLevel                                               % R-value level indices (R值等级索引)

        % Colorbar breakpoints (颜色条断点)
        % Colorbar ticks
        CBreak = [-1, -.5, 0, .5, 1]                           

        FastMantel = 'on'
        Method = 'Pearson'          % 'Pearson'/'Kendall'/'Spearman', correlation method                   
        NumPerm = 999;              % Number of permutations (置换次数)

        % Node positions (节点位置)
        NodePositon1             
        NodePositon2

        LinkBendMode = 'mirror'      % 'mirror'/'simple'
        Curvature = 0.2;             % Curvature strength (弯曲强度)

        node1Hdl
        node2Hdl
        groupLabelHdl
        linkMatHdl
        legendTitleHdl
        legendTickLabelHdl
    end

    methods
        function obj = SMantelLink(varargin)
            % Parse axes handle if provided (解析坐标区句柄)
            if isa(varargin{1}, 'matlab.graphics.axis.Axes')
                obj.ax = varargin{1};
                varargin(1) = [];
            else
                % No axes provided
            end

            obj.dataMat1 = varargin{1};
            obj.dataMat2 = varargin{2};
            varargin(1:2) = [];

            % Parse optional arguments (解析可选参数)
            for i = 1:2:(length(varargin) - 1)
                tid = ismember(lower(obj.arginList), lower(varargin{i}));
                if any(tid)
                    obj.(obj.arginList{tid}) = varargin{i + 1};
                end
            end

            if isempty(obj.Group)
                obj.Group = ones([1, size(obj.dataMat2, 2)]);
            end
        end

        function varargout = draw(obj)
            % Set axes handle (设置坐标轴句柄)
            if isempty(obj.Parent)
                obj.ax = gca;
            else
                obj.ax = obj.Parent;
            end

            obj.RBreak = sort(obj.RBreak); obj.RBreak = obj.RBreak(:).';
            if ~isinf(obj.RBreak(1)), obj.RBreak = [-inf, obj.RBreak]; end
            if ~isinf(obj.RBreak(end)), obj.RBreak = [obj.RBreak, inf]; end

            obj.PBreak = sort(obj.PBreak); obj.PBreak = obj.PBreak(:).';
            if ~isinf(obj.PBreak(1)), obj.PBreak = [-inf, obj.PBreak]; end
            if ~isinf(obj.PBreak(end)), obj.PBreak = [obj.PBreak, inf]; end

            if isempty(obj.RLabel)
                obj.RLabel = obj.makeLabels(obj.RBreak);
            end
            if isempty(obj.PLabel)
                obj.PLabel = obj.makeLabels(obj.PBreak);
            end

            if isempty(obj.GroupName)
                obj.GroupName = compose('Group-%d', 1:max(obj.Group));
            end

            % Compute Mantel test for each variable-group pair (计算每对变量-组的 Mantel 检验)
            obj.PValue = zeros([size(obj.dataMat1, 2), max(obj.Group)]);
            obj.RValue = zeros([size(obj.dataMat1, 2), max(obj.Group)]);
            for i = 1:size(obj.dataMat1, 2)
                for j = 1:max(obj.Group)
                    M1 = obj.dataMat1(:, i);
                    M2 = obj.dataMat2(:, obj.Group == j);
                    D1 = squareform(pdist(M1, obj.Distance1));
                    D2 = squareform(pdist(M2, obj.Distance2));

                    % [rho, pval] = mantel(D1, D2, obj.NumPerm, obj.Method);
                    if size(obj.dataMat1, 1).^2*obj.NumPerm < 2e8 && strcmpi(obj.FastMantel, 'on')
                        [rho, pval] = mantelFast(D1, D2, obj.NumPerm, obj.Method);
                    else
                        [rho, pval] = mantel(D1, D2, obj.NumPerm, obj.Method);
                    end
                    
                    obj.RValue(i, j) = rho;
                    obj.PValue(i, j) = pval;
                end
            end

            % Compute level indices (计算等级索引)
            obj.PLevel = zeros([size(obj.dataMat1, 2), max(obj.Group)]);
            obj.RLevel = zeros([size(obj.dataMat1, 2), max(obj.Group)]);

            for i = 1:length(obj.PBreak)
                obj.PLevel = obj.PLevel + (obj.PValue > obj.PBreak(i));
            end
            for i = 1:length(obj.RBreak)
                obj.RLevel = obj.RLevel + (obj.RValue > obj.RBreak(i));
            end

            % Set default node positions if not provided (若未提供节点位置则设置默认位置)
            if isempty(obj.NodePositon1)
                obj.NodePositon1 = repmat((1: size(obj.dataMat1, 2)).', [1,2]);
            end
            if isempty(obj.NodePositon2)
                switch obj.Layout
                    case 'tril'
                        tPos2 = [size(obj.dataMat1, 2)./3, size(obj.dataMat1, 2) - 1];
                        tPos1 = tPos2 - size(obj.dataMat1, 2).*2./3;

                        if max(obj.Group) == 1
                            obj.NodePositon2 = (tPos1 + tPos2)./2;
                        else
                            obj.NodePositon2 = interp1([1, max(obj.Group)], [tPos1; tPos2], 1:max(obj.Group));
                        end

                    case 'triu'
                        tPos1 = [size(obj.dataMat1, 2).*2./3, 1];
                        tPos2 = size(obj.dataMat1, 2).*2./3 + tPos1;
                        if max(obj.Group) == 1
                            obj.NodePositon2 = (tPos1 + tPos2)./2;
                        else
                            obj.NodePositon2 = interp1([1, max(obj.Group)], [tPos1; tPos2], 1:max(obj.Group));
                        end
                end
            end

            % Draw curved links (绘制弯曲链接)
            tCur = obj.Curvature;
            if strcmpi(obj.Layout, 'tril')
                tCur = - tCur;
            end
            obj.linkMatHdl = gobjects(size(obj.dataMat1, 2), max(obj.Group));
            for j = 1:max(obj.Group)
                for i = 1:size(obj.dataMat1, 2)
                    posi = obj.NodePositon1(i, :);
                    posj = obj.NodePositon2(j, :);
                    baseV = posi - posj;
                    
                    if strcmpi(obj.LinkBendMode, 'mirror')
                        if i > size(obj.dataMat1, 2)/2
                            baseT = atan(tCur);
                        else
                            baseT = atan(- tCur);
                        end
                    else
                        baseT = atan(- tCur);
                    end

                    bezierV = [baseV(1)*cos(baseT) + baseV(2)*sin(baseT), baseV(2)*cos(baseT) - baseV(1)*sin(baseT)];
                    bezierV = bezierV./2./abs(cos(baseT));
                    posm = posj + bezierV;
                    XY = bezierCurve([posi; posm; posj], 100);
                    obj.linkMatHdl(i, j) = plot(obj.ax, XY(:,1), XY(:,2), 'Color',obj.PColor(obj.PLevel(i, j), :), ...
                        'LineWidth',obj.RWidth(obj.RLevel(i,j)));
                end
            end


            obj.node1Hdl = scatter(obj.ax, obj.NodePositon1(:, 1), obj.NodePositon1(:,1), 80, ...
                obj.NodeColor1, 'filled', 'LineWidth',1, 'MarkerEdgeColor','k');
            obj.node2Hdl = scatter(obj.ax, obj.NodePositon2(:, 1), obj.NodePositon2(:, 2), 80, ...
                obj.NodeColor2, 'filled', 'LineWidth',1, 'MarkerEdgeColor','k');

            if strcmpi(obj.Layout, 'tril')
                obj.groupLabelHdl = text(obj.ax, obj.NodePositon2(:, 1) - .5, obj.NodePositon2(:, 2), ...
                    obj.GroupName, 'FontName','Times New Roman', 'FontSize',12, 'HorizontalAlignment','right');
            else
                obj.groupLabelHdl = text(obj.ax, obj.NodePositon2(:, 1) + .5, obj.NodePositon2(:, 2), ...
                    obj.GroupName, 'FontName','Times New Roman', 'FontSize',12);
            end

            baseLen = size(obj.dataMat1, 2);
            if isempty(obj.LegendPosition)
                switch obj.LegendLocation
                    case 'east'
                        switch obj.Layout
                            case 'tril'
                                obj.LegendPosition = [.5 + 3.5*baseLen/3, 1, .6.*baseLen/3, baseLen - 1];
                            case 'triu'
                                obj.LegendPosition = [.5 + 4.5*baseLen/3, 1, .6.*baseLen/3, baseLen - 1];
                        end
                    case 'west'
                        switch obj.Layout
                            case 'tril'
                                obj.LegendPosition = [-.5 - 2.1*baseLen/3, 1, .6.*baseLen/3, baseLen - 1];
                            case 'triu'
                                obj.LegendPosition = [.5 - 1.1*baseLen/3, 1, .6.*baseLen/3, baseLen - 1];
                        end
                end
            end

            tPos = obj.LegendPosition;

            % Legend: P-value color mapping (图例：P值颜色映射)
            obj.legendTitleHdl = text(obj.ax, tPos([1,1,1]), tPos(2) + [0, 1/3, 2/3].*tPos(4), ...
                obj.LegendTitle, 'FontName','Times New Roman', 'FontSize',17, 'FontWeight','bold');
            obj.legendTickLabelHdl = gobjects(1, 0);
            tN = 1; 
            bY1 = tPos(2) + tPos(4)/30; 
            bL = 7*tPos(4)/30/(length(obj.PBreak) - 1);
            for i = 1:length(obj.PLabel)
                plot(obj.ax, [tPos(1), tPos(1) + 1.5.*tPos(3)/5], (bY1 + (i - .5)*bL).*[1, 1], ...
                    'Color', obj.PColor(i, :), 'LineWidth',2);
                obj.legendTickLabelHdl(tN) = text(obj.ax, tPos(1) + 1.5.*1.2.*tPos(3)/5, bY1 + (i - .5)*bL, ...
                    obj.PLabel{i}, 'FontName','Times New Roman', 'FontSize',12);
                tN = tN + 1;
            end

            % Legend: R-value width mapping (图例：R值宽度映射)
            bY1 = tPos(2) + tPos(4)/3 + tPos(4)/30; 
            bL = 7*tPos(4)/30/(length(obj.RBreak) - 1);
            for i = 1:length(obj.PLabel)
                plot(obj.ax, [tPos(1), tPos(1) + 1.5.*tPos(3)/5], (bY1 + (i - .5)*bL).*[1, 1], ...
                    'Color', [.4,.4,.4], 'LineWidth',obj.RWidth(i));
                obj.legendTickLabelHdl(tN) = text(obj.ax, tPos(1) + 1.5.*1.2.*tPos(3)/5, bY1 + (i - .5)*bL, ...
                    obj.RLabel{i}, 'FontName','Times New Roman', 'FontSize',12);
                tN = tN + 1;
            end

            % Legend: Colorbar for correlation values (图例：相关性颜色条)
            cl = obj.ax.CLim;
            tCbreak = obj.CBreak;
            tCbreak(tCbreak < cl(1)) = [];
            tCbreak(tCbreak > cl(2)) = [];
            cmp = obj.ax.Colormap;

            bY1 = tPos(2) + 2*tPos(4)/3 + 2*tPos(4)/30;
            bL = 8*tPos(4)/30;
            [Xmesh, YMesh] = meshgrid([0, 1], linspace(0, 1, size(cmp, 1) + 1));
            CMesh = zeros([size(Xmesh), 3]);
            CMesh(1:end-1, :, 1) = cmp(end:-1:1, [1, 1]);
            CMesh(1:end-1, :, 2) = cmp(end:-1:1, [2, 2]);
            CMesh(1:end-1, :, 3) = cmp(end:-1:1, [3, 3]);
            surf(obj.ax, tPos(1) + 1.5.*Xmesh.*tPos(3).*(1/5 - 1/32), bY1 + YMesh.*bL, YMesh.*0, ...
                'CData',CMesh, 'EdgeColor','none', 'FaceColor','flat');
            fill(obj.ax, [tPos(1), tPos(1) + 1.5.*tPos(3).*(1/5 - 1/32), tPos(1) + 1.5.*tPos(3).*(1/5 - 1/32), tPos(1)], ...
                         [bY1, bY1, bY1 + bL, bY1 + bL], [0,0,0], 'FaceColor','none', ...
                         'EdgeColor',[0,0,0], 'LineWidth',1)
            for i = 1:length(tCbreak)
                plot(obj.ax, [tPos(1) + 1.5.*tPos(3).*(1/5 - 1/32), tPos(1) + 1.5.*tPos(3)/5], ...
                    (bY1 + bL - bL*(tCbreak(i) - cl(1))./(cl(2) - cl(1))).*[1, 1], ...
                    'Color', [0,0,0], 'LineWidth',1);
                obj.legendTickLabelHdl(tN) = text(obj.ax, tPos(1) + 1.5.*1.2.*tPos(3)/5, ...
                    (bY1 + bL - bL*(tCbreak(i) - cl(1))./(cl(2) - cl(1))), ...
                    num2str(tCbreak(i)), 'FontName','Times New Roman', 'FontSize',12);
                tN = tN + 1;
            end


            % Set view and axis limits (设置视图和坐标轴范围)
            view(obj.ax, 2)
            axis(obj.ax, 'tight');
            switch obj.LegendLocation
                case 'east'
                    obj.ax.XLim(1) = obj.ax.XLim(1) - 1;
                    obj.ax.XLim(2) = obj.LegendPosition(1) + obj.LegendPosition(3);
                case 'west'
                    obj.ax.XLim(1) = obj.LegendPosition(1);
                    obj.ax.XLim(2) = obj.ax.XLim(2) + 1;
            end

            function pnts = bezierCurve(pnts, N)
                t = linspace(0, 1, N);
                p = size(pnts, 1) - 1;
                coe1 = factorial(p) ./ factorial(0:p) ./ factorial(p:-1:0);
                coe2 = ((t) .^ ((0:p)')) .* ((1 - t) .^ ((p:-1:0)'));
                pnts = (pnts' * (coe1' .* coe2))';
            end

            if nargout == 1
                varargout = {obj};
            end
        end

        function labels = makeLabels(~, edges)
            % makeLabels - Generate label strings from interval edges
            %   labels = makeLabels(edges) returns a cell array of interval labels
            %   for the intervals defined by edges.
            %
            % Input:
            %   edges - row vector of length N+1, defining N intervals.
            %           edges(1) can be -Inf, edges(end) can be Inf.
            % Output:
            %   labels - 1×N cell array of strings, e.g., {'< 0.2', '0.2 - 0.4', '>= 0.4'}
            %
            % Example:
            %   edges = [-Inf, 0.2, 0.4, Inf];
            %   labs = makeLabels(edges);
            %   disp(labs)
            %   % Output: {'< 0.2', '0.2 - 0.4', '>= 0.4'}

            if ~isrow(edges)
                edges = edges(:)';   % ensure row vector
            end
            n = length(edges) - 1;
            labels = cell(1, n);

            for i = 1:n
                left = edges(i);
                right = edges(i+1);
                if isinf(left) && left < 0
                    % First interval
                    labels{i} = sprintf('< %.2g', right);
                elseif isinf(right) && right > 0
                    % Last interval
                    labels{i} = sprintf('>= %.2g', left);
                else
                    % Middle interval
                    labels{i} = sprintf('%.2g - %.2g', left, right);
                end
            end
        end
    end
end