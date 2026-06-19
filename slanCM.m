function colorList = slanCM(type, num)
% slanCM - Get predefined colormap by name or ID
%   colorList = slanCM(type) returns a colormap with default number of colors (256)
%
%   colorList = slanCM(type, num) returns a colormap with specified number of colors
%
% Input:
%   type - colormap identifier (string name or numeric ID)
%   num  - number of colors (default: 256)
%
% Example:
%   contourf(peaks, 30)
%   colorbar
%
%   colormap(slanCM('romao'))      % Use 'romao' colormap by name
%   colormap(slanCM(134))          % Use colormap No. 134 by ID
%   colormap(slanCM(134, 20))      % Use colormap No. 134 with 20 colors


% =========================================================================
% # Citations & Acknowledgements
%   Colormap collection：This package includes colormaps from several sources:
% -------------------------------------------------------------------------
% From : matplotlab(Hunter, 2007) | https://matplotlib.org/
% + Perceptually Uniform Sequential：
%    viridis  plasma  inferno  magma  cividis
% + Sequential：
%    Greys  Purples  Blues  Greens  Oranges  Reds  YlOrBr  YlOrRd  
%    OrRd  PuRd  RdPu  BuPu  GnBu  PuBu  YlGnBu  PuBuGn  BuGn  YlGn
%    binary  gist_yarg  gist_gray  gray  bone  pink  spring  summer
%    autumn  winter  cool  Wistia  hot  afmhot  gist_heat  copper
% + Diverging：
%    PiYG  PRGn  BrBG  PuOr  RdGy  RdBu  RdYlBu  RdYlGn  Spectral  coolwarm  bwr  seismic
% + Cyclic：
%    twilight  twilight_shifted  hsv
% + Qualitative：
%    Pastel1  Pastel2  Paired  Accent  Dark2  Set1  Set2  Set3  tab10  tab20  tab20b  tab20c
% + Miscellaneous：
%    flag  prism  ocean  gist_earth  terrain  gist_stern  gnuplot  gnuplot2   CMRmap  
%    cubehelix  brg  gist_rainbow  rainbow  jet  turbo  nipy_spectral  gist_ncar
% -------------------------------------------------------------------------
% From : scicomap(Bury, 2023) | https://github.com/ThomasBury/scicomap
% + diverging:
%    berlin  bjy  bky  BrBG  broc  bwr  coolwarm  curl  delta  fusion  guppy  iceburn  lisbon
%    PRGn  PiYG  pride  PuOr  RdBu  RdGy  RdYlBu  RdYlGn  redshift  roma  seismic  spectral
%    turbo  vanimo  vik  viola  waterlily  watermelon  wildfire
% + sequential:
%    afmhot  amber  amp  apple  autumn  batlow  bilbao  binary  Blues  bone  BuGn  BuPu
%    chroma  cividis  cool  copper  cosmic  deep  dense  dusk  eclipse  ember  fall  gem
%    gist_gray  gist_heat  gist_yarg  GnBu  Greens  gray  Greys  haline  hawaii  heat  hot
%    ice  inferno  imola  lapaz  magma  matter  neon  neutral  nuuk  ocean  OrRd  Oranges
%    pink  plasma  PuBu  PuBuGn  PuRd  Purples  rain  rainbow  rainbow-sc  rainforest  RdPu
%    Reds  savanna  sepia  speed  solar  spring  summer  tempo  thermal  thermal-2  tokyo
%    tropical  turbid  turku  viridis  winter  Wistia  YlGn  YlGnBu  YlOrBr  YlOrRd
% + circular:
%    bukavu  fes  infinity  infinity_s  oleron  rainbow-iso  romao  seasons  seasons_s
%    twilight  twilight_s
% + miscellaneous:
%    oxy  rainbow-kov  turbo
% + qualitative:
%    538  bold  brewer  colorblind  glasbey  glasbey_bw  glasbey_category10
%    glasbey_dark  glasbey_hv  glasbey_light  pastel  prism  vivid
% -------------------------------------------------------------------------
% From : cmasher(van der Velden, 2020) | https://cmasher.readthedocs.io/
% + sequential:
%    amber  amethyst  apple  arctic  bubblegum  chroma  cosmic  dusk  eclipse  ember  emerald
%    fall  flamingo  freeze  gem  ghostlight  gothic  horizon  jungle  lavender  lilac  neon
%    neutral  nuclear  ocean  pepper  rainforest  sapphire  savanna  sepia  sunburst  swamp
%    torch  toxic  tree  tropical  voltage
% + diverging:
%   copper  emergency  fusion  guppy  holly  iceburn  infinity  pride  prinsenvlag  redshift
%   seasons  seaweed  viola  waterlily  watermelon  wildfire
% =========================================================================
% ** Some of the colormaps in the above-mentioned repositories are **
% ** collected and integrated from other sources, such as:         **
% -------------------------------------------------------------------------
% From : Scientific colour maps(Crameri, 2018) | https://www.fabiocrameri.ch/colourmaps/
%   berlin  broc  bam  bamO  batlow  cork  devon  grayC  hawaii  imola  lajolla
%   lapaz  navia  nuuk  oleron  oslo  roma  tofino  tokyo  turku  vik  acton
% -------------------------------------------------------------------------
% From : cmocean(Thyng et al., 2016) | https://matplotlib.org/cmocean/
%   algae  amp  deep  dense  haline  ice  matter  solar  speed  tempo  thermal  turbid  balance  curl  delta
% -------------------------------------------------------------------------
% From : palettable(Davis, 2023) | https://jiffyclub.github.io/palettable/
%   YlGn  YlGnBu  GnBu  BuGn  PuBuGn  PuBu  BuPu  RdPu  PuRd  OrRd  YlOrRd  YlOrBr  Purples  Blues  Greens  Oranges  Reds  Greys
% -------------------------------------------------------------------------
% From : colorcet(PyViz contributors), based on Kovesi (2015) | https://colorcet.holoviz.org/
%   fire rainbow bmy kbc kgy  glasbey  glasbey_bw  glasbey_dark  glasbey_light  glasbey_category10  glasbey_hv
% =========================================================================
% Reference
% [1] Hunter, J. D. (2007). Matplotlib: A 2D graphics environment. Computing in Science & Engineering, 9(3), 90–95.
% [2] Bury, T. (2023). scicomap: Scientific colormaps for Python. https://github.com/ThomasBury/scicomap
% [3] van der Velden, E. (2020). CMasher: Scientific colormaps for Python. https://cmasher.readthedocs.io/
% [4] Crameri, F. (2018). Scientific colour maps. Zenodo. https://doi.org/10.5281/zenodo.1243862
% [5] Thyng, K. M., Greene, C. A., Hetland, R. D., Zimmerle, H. M., & DiMarco, S. F. (2016). 
%       True colors of oceanography. Oceanography, 29(3), 10-11. https://doi.org/10.5670/oceanog.2016.66
% [6] Kovesi, P. (2015). *Good Colour Maps: How to Design Them*. arXiv:1509.03700
% [7] Glasbey, C. A., van der Heijden, G. W. A. M., Toh, V. F. K., & Gray, A. (2007). 
%       Colour displays for categorical images. *Color Research & Application*, 32(4), 
%       304–309. https://doi.org/10.1002/col.20327
% [8] Davis, M. (2023). palettable: Color Palettes for Python [Computer software]. 
%       Retrieved from https://jiffyclub.github.io/palettable/

if nargin < 2
    num = 256;
end
if nargin < 1
    type = '';
end

slanCM_Data = load('slanCM_Data.mat');
CList_Data = [slanCM_Data.slandarerCM(:).Colors];

if isnumeric(type)
    Cmap = CList_Data{type};
else
    Cpos = strcmpi(type, slanCM_Data.fullNames);
    Cmap = CList_Data{Cpos};
end

Ci = 1:256; Cq = linspace(1, 256, num);
colorList = [interp1(Ci, Cmap(:, 1), Cq, 'linear')',...
             interp1(Ci, Cmap(:, 2), Cq, 'linear')',...
             interp1(Ci, Cmap(:, 3), Cq, 'linear')'];
end


% =========================================================================
% Zhaoxu Liu / slandarer (2023). 200 colormaps 
% (https://www.mathworks.com/matlabcentral/fileexchange/120088-200-colormap), 
% MATLAB Central File Exchange. 检索来源 2023/3/15.
% =========================================================================