function drawRectangle(rect, color)
%DRAWRECTANGLE Draws
%
    x = rect(1);
    y = rect(2);
    width = rect(3);
    height = rect(4);

    % Draw the top line.
    plot([x, (x+width)], [y, y], color);
    
    % Draw the bottom line.
    plot([x, (x+width)], [(y+height), (y+height)], color);
    
    % Draw the left line.
    plot([x, x], [y, (y+height)], color);
    
    % Draw the right line.
    plot([(x+width), (x+width)], [y, (y+height)], color);

end