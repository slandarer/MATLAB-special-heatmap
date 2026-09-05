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

if length(hdls) >= 100
    XY = get(hdls, 'Position');
    if iscell(XY)
        XY = reshape([XY{:}], 3, []).';
    end
    X = XY(:, 1); Y = XY(:, 2);
    T = atan2(Y, X); T = T./pi.*180;
    T = T - 180*((T > 0) - .5);
    tCell = {'top'; 'bottom'};
    tBool = (Y > 0) | (Y == 0 & X < 0);
    switch RPos
        case {'center','centre'}
            set(hdls, {'Rotation'}, num2cell(-T, 2), 'VerticalAlignment','middle', 'HorizontalAlignment','center')
        case 'outer'
            set(hdls, {'Rotation', 'VerticalAlignment'},[num2cell(-T, 2), tCell(2 - tBool)], 'HorizontalAlignment','center')
        case 'inner'
            set(hdls, {'Rotation', 'VerticalAlignment'},[num2cell(-T, 2), tCell(1 + tBool)], 'HorizontalAlignment','center')
    end
else
    for i = 1:length(hdls)
        X = hdls(i).Position(1);
        Y = hdls(i).Position(2);
        T = atan2(Y, X); T = T./pi.*180;
        T = T - 180*((T > 0) - .5);
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
end
end
