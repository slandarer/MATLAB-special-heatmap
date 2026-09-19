function varargout = spreadLabels(txtHdls, endPoints, varargin)
% SPREADLABELS Spread text labels evenly along a line segment.
%   SPREADLABELS(txtHdls, endPoints) rearranges visible text labels specified
%   by handles in txtHdls so that they are evenly distributed along the line
%   segment defined by endPoints. Leader lines connect the original text
%   positions to the new positions.
%   将可见文本标签沿指定线段均匀分布，并用引导线连接原始位置与新位置。
%
%   spreadLabels(txtHdls, endPoints); specifies the text handle array and
%     the two endpoints of the line segment.
%     基本调用：指定文本句柄数组和线段两端点。
%
%       txtHdls   - Array of text object handles (文本对象句柄数组)
%
%       endPoints - 2×2 numeric matrix defining the line segment endpoints,
%                   where the first row is the start point [x1, y1] and the
%                   second row is the end point [x2, y2].
%                   2×2 数值矩阵，定义线段两端点；
%                   第一行为起点 [x1, y1]，第二行为终点 [x2, y2]。
%
%   spreadLabels(___, 'Name', Value, ...); specifies optional parameters:
%     指定可选参数：
%
%       'UniformWeight' - Weight for uniform distribution (均匀分布权重)
%                         1 = uniform (完全均匀)
%                         0 = original projected positions (保持原投影位置)
%
%       'LabelOffset'   - Offset distance for labels from leader line ends.
%                         标签从引导线末端的偏移距离。
%
%       'LeaderStyle'   - Leader line style (引导线样式)
%                         'straight' (直线)
%                         'segment2' (两段折线)
%                         'segment3' (三段折线)
%
%   h = spreadLabels(___); returns the handle(s) to the plotted leader lines.
%                          返回绘制的引导线句柄。
%
% Basic usage:
%   txt = text(zeros(10,1), rand(10,1) - .5, string(1:10));
%   spreadLabels(txt, [1,-2; 1,2], 'UniformWeight',0.8, 'LeaderStyle','segment3', 'LabelOffset',.01);

    % Parse inputs (解析输入)
    p = inputParser;
    p.addRequired('txtHdls', @(x) isa(x,'matlab.graphics.primitive.Text') || ishandle(x));
    p.addRequired('endPoints', @(x) isnumeric(x) && isequal(size(x),[2,2]));
    p.addParameter('UniformWeight', 1, @(x) isnumeric(x) && isscalar(x) && x>=0 && x<=1);
    p.addParameter('LabelOffset', .25, @(x) isnumeric(x) && isscalar(x) && x>=0)
    p.addParameter('LeaderStyle', 'segment3', @(x) ischar(x) && ismember(x, {'straight','segment2','segment3'}));
    p.parse(txtHdls, endPoints, varargin{:});

    obj = p.Results;
    obj.ax = txtHdls(1).Parent;
    obj.ax.NextPlot = 'add';
    % Keep only visible labels (仅保留可见标签)
    txtHdls = txtHdls(strcmpi(get(txtHdls, 'Visible'), 'on'));
    N = length(txtHdls);

    % Line segment endpoints and direction (线段端点与方向)
    P1 = endPoints(1, :); P2 = endPoints(2, :);
    dir  = P2 - P1; len = dot(dir, dir);
    % Project text positions onto the line segment (将文本位置投影到线段)
    pos = reshape([txtHdls.Position], 3, []).';
    posXY = pos(:, 1:2);
    tt = ((posXY - repmat(P1, [N, 1])) * dir') / len;
    % Sort by projection parameter (按投影参数排序)
    [tt, order] = sort(tt);
    txtHdls = txtHdls(order);
    % Original projected positions (原始投影位置)
    TPos1 = repmat(tt, [1, 2]).*repmat(dir, [N, 1]) + repmat(P1, [N, 1]);
    % Uniformly distributed positions along the line (沿线的均匀分布位置)
    TPos2 = repmat(linspace(0, 1, N).', [1, 2]).*repmat(dir, [N, 1]) + repmat(P1, [N, 1]);
    % Original sorted text positions (排序后的原始文本位置)
    SPos = posXY(order, :);
    % Interpolate between original and uniform positions (在原始与均匀位置间插值)
    TPos = TPos1.*(1 - obj.UniformWeight) + TPos2.*obj.UniformWeight;
    % Direction and length of leader lines (引导线方向与长度)
    LDir = TPos1 - SPos;
    LLen = sqrt(LDir(:, 1).^2 + LDir(:, 2).^2);
    TDir = LDir./[LLen, LLen];
    TDir(isnan(TDir)) = 0;
    TDir = TDir.*obj.LabelOffset;

    % Construct leader line vertices based on style (根据样式构建引导线顶点)
    switch lower(obj.LeaderStyle)
        case 'straight'
            XX = [SPos(:, 1).'; TPos(:, 1).'; nan(1, N)];
            YY = [SPos(:, 2).'; TPos(:, 2).'; nan(1, N)];
        case 'segment2'
            XX = [SPos(:, 1).'; SPos(:, 1).' + LDir(:,1).'./3; TPos(:, 1).'; nan(1, N)];
            YY = [SPos(:, 2).'; SPos(:, 2).' + LDir(:,2).'./3; TPos(:, 2).'; nan(1, N)];
        case 'segment3'
            XX = [SPos(:, 1).'; SPos(:, 1).' + LDir(:,1).'./3; TPos(:, 1).' - LDir(:,1).'./3; TPos(:, 1).'; nan(1, N)];
            YY = [SPos(:, 2).'; SPos(:, 2).' + LDir(:,2).'./3; TPos(:, 2).' - LDir(:,2).'./3; TPos(:, 2).'; nan(1, N)];
    end
    % Plot leader lines (绘制引导线)
    plotHdl = plot(obj.ax, XX(:), YY(:), 'Color','k', 'LineWidth',1);
    % Update text positions with offset (更新文本位置，加入偏移)
    set(txtHdls, {'Position'}, num2cell([TPos + TDir, zeros(N, 1)], 2))
    if nargout == 1
        varargout = {plotHdl};
    end
end