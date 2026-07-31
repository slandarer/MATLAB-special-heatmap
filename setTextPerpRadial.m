function setTextPerpRadial(txtHdl, RPos)
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
