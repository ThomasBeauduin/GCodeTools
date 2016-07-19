function [array, endPos] = interpGCode(command, startPos, ds)
% INTERPGCODE - Interpolate G-Code to fixed displacement path.
% -- Input --
% command   : vector gcode command: [G#, X#, Y#, Z#, I#, J#, K#]
% startPos  : [x,y,z] coordinate of starting point of array
% ds        : distance between interpolation points
% -- Output --
% array     : [x1, y1, z1; x2, y2, z2; ...] representation
% endPos    : [x,y,z] coordinate of ending point of command
% note      : It is assumed that K = 0 for all G2/G3 commands
%             helices are created by adding Z to the G2/G3 command
% Author    : Thomas Beauduin, University of Tokyo, 2016
%%%%%

%if G1 command
if command(1) == 1    
    %determine endpoint
    endPos = startPos + command(2:4);
    
    %increment vector for command
    magnitude = norm(command(2:4));
    dv = ds*command(2:4)/magnitude;

    %create array
    array(1,:) = startPos;
    length = magnitude/ds + 1;
    for i = 2:length
        array(i,:) = array(i-1,:) + dv;
    end
    
%if G2 command (CW arc)
elseif command(1) == 2 
    
    %determine endpoint
    endPos = startPos + command(2:4);
    
    %determine arc angle and radius
    v1 = [command(2), command(3)];
    v2 = [-command(6), command(5)];
    if norm(v1) == 0
        arcAngle = 2*pi;
    else
        arcAngle = 2*acos(v1*transpose(v2)/(norm(v1)*norm(v2)));
    end
    arcRadius = norm(v2);

    %determine initial phase of arc
    phase = acos(([-1,0]*[command(5); command(6)])/arcRadius);
    if command(6) > 0
        phase = 2*pi - phase;
    end

    %angle increment
    dtheta = ds*(arcRadius^2 + (command(4)/arcAngle)^2)^(-1/2);
    theta = 0:dtheta:arcAngle;
    
    %define x & y coordinates
    array(:,1) = arcRadius*cos(phase - theta) ...
                    + startPos(1) + command(5);
    array(:,2) = arcRadius*sin(phase - theta) ...
                    + startPos(2) + command(6);
    
    %define z values, ensure it has same number of points as x,y           
    size = numel(theta);
    dz = command(4)/(size-1);
    array(1,3) = startPos(3);
    for i = 2:size
        array(i,3) = array(i-1,3) + dz;
    end
    
%if G3 command (CCW arc)  
elseif command(1) == 3
    
    %determine endpoint
    endPos = startPos + command(2:4);
    
    %determine arc angle and radius
    v1 = [command(2), command(3)];
    v2 = [command(6), -command(5)];
    if norm(v1) == 0
        arcAngle = 2*pi;
    else
        arcAngle = 2*acos(v1*transpose(v2)/(norm(v1)*norm(v2)));
    end
    arcRadius = norm(v2);

    %determine initial phase of arc
    phase = acos(([-1,0]*[command(5); command(6)])/arcRadius);
    if command(6) > 0
        phase = 2*pi - phase;
    end

    %angle increment
    dtheta = ds*(arcRadius^2 + (command(4)/arcAngle)^2)^(-1/2);
    theta = 0:dtheta:arcAngle;
    
    %define x & y coordinates
    array(:,1) = arcRadius*cos(phase + theta) ...
                    + startPos(1) + command(5);
    array(:,2) = arcRadius*sin(phase + theta) ...
                    + startPos(2) + command(6);
    
    %define z values, ensure it has same number of points as x,y           
    size = numel(theta);
    dz = command(4)/(size-1);
    array(1,3) = startPos(3);
    for i = 2:size
        array(i,3) = array(i-1,3) + dz;
    end

else
    error('Not G1, G2, or G3 command');
end

end



