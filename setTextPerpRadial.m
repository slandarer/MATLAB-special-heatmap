function setTextPerpRadial(txtHdl, RPos)
% SETTEXTPERPRADIAL Rotate text objects perpendicular to radial direction.
%   setTextPerpRadial(txtHdl) rotates the given text handles so that they are
%   perpendicular to the radial direction from the origin (0,0). 
%
%   setTextPerpRadial(txtHdl, RPos) specifies the radial placement:
%       'inner'  - text is shifted inward (towards origin)
%       'center' - text centered at the original position (default)
%       'outer'  - text is shifted outward (away from origin)

if nargin < 2
    RPos = 'center';
end
% RPos : 'inner'/'center'/'outer'
hdls = txtHdl(:);
for i = 1:length(hdls)
    X = hdls(i).Position(1);
    Y = hdls(i).Position(2);
    T = atan2(Y, X); T = T./pi.*180;
    T = T - 180*((T>0) - .5);
    set(hdls(i), 'HorizontalAlignment','center', 'Rotation',-T)
    switch RPos
        case {'center','centre'}
            set(hdls(i), 'VerticalAlignment','middle')
        case 'outer'
            if Y > 0
                set(hdls(i), 'VerticalAlignment','top')
            else
                set(hdls(i), 'VerticalAlignment','bottom')
            end
            if Y == 0 && X < 0
                set(hdls(i), 'VerticalAlignment','top')
            end
        case 'inner'
            if Y > 0
                set(hdls(i), 'VerticalAlignment','bottom')
            else
                set(hdls(i), 'VerticalAlignment','top')
            end
            if Y == 0 && X < 0
                set(hdls(i), 'VerticalAlignment','bottom')
            end
    end
end
