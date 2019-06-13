function[image] = imageInsertText(image, textCell, fontSize, fontColor)
% [image] = imageInsertText(image, textCell, [fontSize], [fontColor])
%
% Uses textInserter (from Vision Toolbox) to insert a cell of strings into
% the image. Each entry forms one row. The font size is chosen such that
% all text is visible.
%
% Copyright by Holger Caesar, 2014

% Settings
maxFontSize = 100;

if iscell(textCell),
    labelString = strjoin(textCell, '\n');
elseif ischar(textCell),
    labelString = textCell;
else
    error('Error: Invalid input type!');
end;

% Find the maximum font size so that the text fits on
% screen
if ~exist('fontSize', 'var') || isempty(fontSize),
    maxWidth = max(cellfun(@numel, textCell));
    fontSizeY = round(size(image, 1) / numel(textCell) * 0.8);
    fontSizeX = round(size(image, 2) / maxWidth * 1.7);
    fontSize = min([fontSizeY, fontSizeX, maxFontSize]);
end;

if ~exist('fontColor', 'var') || isempty(fontColor),
    fontColor = [255, 0, 0];
end;

% Do not change the font to anything other than Lucida*
textInserter = vision.TextInserter(labelString, 'Color', fontColor, ...
    'Location', [1, 5], 'FontSize', fontSize);
image = step(textInserter, image);