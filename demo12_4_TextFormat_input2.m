%% Text Format (2 inputs)

rng(2)
% Made up some data casually (随便捏造了点数据)
X = randn(20, 8) + [(linspace(-1,2.5,20)').*ones(1, 4), (linspace(.5,-.7,20)').*ones(1, 2), (linspace(.9,-.2,20)').*ones(1, 2)];
% Get the correlation matrix (求相关系数矩阵)
[Data, pval] = corr(X);

% create figure (图窗创建)
figure('Units','normalized', 'Position',[.1,.05,.45,.72])

% Draw heat map with texts (绘制有文本热图)
SHM = SHeatmap(Data, 'Format','sq').draw();
SHM.setText().setType('tril');


SHM.PVal = pval;
SHM.setTextFormat(@(x, p) [sprintf('%0.2f', x), SPval2Stars(p)])



% % try:
% SHM.setTextFormat(@(x, p) {SPval2Plus(p); sprintf('%0.2f', x)})
% function stars = SPval2Plus(pval, levels)
% % SPval2Stars - Convert p-values to significance stars
% %   stars = SPval2Stars(pval) returns significance stars:
% %       p < 0.05   -> '+'
% %       p < 0.01   -> '++'
% %       p < 0.001  -> '+++'
% %
% %   stars = SPval2Stars(pval, levels) custom significance thresholds
% %       levels = [0.05, 0.01, 0.001] (default)
% %
% % Examples:
% %   SPval2Stars(0.03)   % returns '+'
% %   SPval2Stars(0.003)  % returns '+++'
% 
% if nargin < 2
%     levels = [0.05, 0.01, 0.001];
% end
% 
% % Generate asterisk string based on significance level
% stars = repmat('+', 1, sum(pval < levels));
% end