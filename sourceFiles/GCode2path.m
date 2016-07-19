function [path] = GCode2path(input,ds,startPos)
%GCODE2PATH - convert G-Code to XYZ coordinates
%
% input     : string of G-code text file
% ds        : segmentation length of path
% startPos  : path starting position in XYZ
%%%%%

fileID = fopen(input);
gcode = textscan(fileID,'%s','Delimiter','\n');
gcode = gcode{1};

path = [];
numCommands = numel(gcode);
for j = 1:numCommands
    % convert string into array of command values
    command = readGCode(char(gcode(j)));
    
    % interpolate GCode to path with distance ds
    [array, startPos] = interpGCode(command, startPos, ds);
 
    % add set of points to existing path
    path = [path; array];
end

end

