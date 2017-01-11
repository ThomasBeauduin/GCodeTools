function [r,t] = GCode2path2(input,ds,startPos)
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
p(1,:) = startPos;
for j = 1:numel(gcode)
    cmd(j,:) = readGCode(char(gcode(j)));
    
    if cmd(j,1) == 90 || cmd(j,1) == 91, 
        coord = cmd(j,1);
    else 
        switch (coord)  
        case 90     % absolute coord
            p(j,:) = cmd(j,2:4);
        case 91     % relative coord
            p(j,:) = p(j-1,:) + cmd(j,2:4);
        end
    end
end
t = p(1,1):ds:p(end,1);
r = interp1(p(:,1),p(:,2),t)'./2;

end

