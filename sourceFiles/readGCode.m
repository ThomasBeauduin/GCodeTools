function [values] = readGCode(gcode)
%READGCODE - extracts relevant values from G-Code line.
% -- Inputs --
% gcode     : GCode string exrtacted from txt-file command
% -- Outputs --
% values    : data array with structure: G#,X#,Y#,Z# and then I#,J#,K# 
% note      : function only accepts G1, G2, or G3 commands
%             IJK-format used for G2/G3 commands (not R-format).
% author    : Thomas Beauduin, University of Tokyo, 2016
%%%%%

%return if not G1,G2 or G3 command
if  ~strncmp(gcode,'G00 ', 3) && ...
    ~strncmp(gcode,'G01 ', 3) && ...
    ~strncmp(gcode,'G02 ', 3) && ...
    ~strncmp(gcode,'G03 ', 3) && ...
    ~strncmp(gcode,'G90 ', 3) && ...
    ~strncmp(gcode,'G91 ', 3)
    values(1) = 0;
    return;
end

%get all the numbers from the string
input = sscanf(gcode,'%*c %f %*c %f %*c %f %*c %f %*c %f %*c %f %*c %f');

%define the array 'values'  
values = zeros(1,7);
values(1) = input(1);

%for loop that puts the values in the correct order. If Z# or K# is not
%specified it is set to 0;
k = 2;
for i = 3:length(gcode)
    char = gcode(i);
    if strcmp(char, 'X'),     values(2) = input(k); k = k+1;
    elseif strcmp(char, 'Y'), values(3) = input(k); k = k+1;
    elseif strcmp(char, 'Z'), values(4) = input(k); k = k+1;
    elseif strcmp(char, 'I'), values(5) = input(k); k = k+1;
    elseif strcmp(char, 'J'), values(6) = input(k); k = k+1;
    elseif strcmp(char, 'K'), values(7) = input(k); k = k+1;
    elseif strcmp(char, 'R'), error('Use IJK format for arcs')
    end
end

end

