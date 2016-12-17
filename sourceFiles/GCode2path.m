function [path,theta] = GCode2path(input,ds,startPos)
%GCODE2PATH - convert G-Code to XYZ coordinates
%
% input     : string of G-code text file
% ds        : segmentation length of path
% startPos  : path starting position in XYZ
%%%%%

fileID = fopen(input);
gcode = textscan(fileID,'%s','Delimiter','\n');
gcode = gcode{1};
fclose(fileID);

path = [];
numCommands = numel(gcode);
for j = 1:numCommands
    % convert string into array of command values
    cmd(j,:) = readGCode(char(gcode(j)));
    
    % interpolate GCode to path with distance ds
    [array, startPos] = interpGCode(cmd(j,:), startPos, ds);
 
    % add set of points to existing path
    path = [path; array];
end

theta = [];
for j = 1:numCommands-1
    if cmd(j,1)==1 && cmd(j+1,1)==1 
        S1 = sqrt(cmd(j,2)^2 + cmd(j,3)^2 + cmd(j,4)^2);
        S2 = sqrt(cmd(j+1,2)^2+cmd(j+1,3)^2 + cmd(j+1,4)^2);
        S3 = sqrt((cmd(j,2)+cmd(j+1,2))^2 + ...
                (cmd(j,3)+cmd(j+1,3))^2+(cmd(j,4)+cmd(j+1,4))^2);
        theta(j) = acos( (S3^2-S1^2-S2^2)/(-2*S1*S2) )*180/pi;
    else
        % G3/G2 calculation
        theta(j) = 90;
end

end

