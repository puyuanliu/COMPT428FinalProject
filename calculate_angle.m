function angle = calculate_angle(intrin, points_1, points_2)
%% This function returns the angle for 2 given planes
%% Input variables 
% Intrinsic matrix of the camer
% points for the first plane (at least 4) m*2 array
% points for the second plane (at least 4) m*2 array
%% Output variable
% Angle in degree

Homography = cv.findHomography(points_1, points_2);
decomposed_H = cv.decomposeHomographyMat(Homography, intrin);
R = decomposed_H.R;
max_angle = 0;
diff = 1000;
for R_i = 1:length(R)
    temp_R = R{R_i};
    temp_angle = rotm2axang(temp_R);
    test = rad2deg(temp_angle);
    if abs(rad2deg(temp_angle(end)) - 90) <diff
        max_angle = temp_angle(end);
        diff = abs(rad2deg(temp_angle(end)) - 90);
    end
end
angle = rad2deg(max_angle);
angle = (angle-90).^2; % return the abs difference with 90 degrees.
