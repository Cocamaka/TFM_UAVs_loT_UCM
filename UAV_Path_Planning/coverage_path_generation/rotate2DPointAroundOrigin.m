function rotated_point = rotate2DPointAroundOrigin(point, angle_deg)
    angle_rad = angle_deg * pi / 180;
    rot_matrix = [cos(angle_rad), -sin(angle_rad); 
                  sin(angle_rad), cos(angle_rad)];
    rotated_point = (rot_matrix * point')';
end