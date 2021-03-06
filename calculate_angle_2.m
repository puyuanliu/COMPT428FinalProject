function difference =  calculate_angle_2(intrin, model_points, result_points1, result_points2, result_points3)
%% This function returns the angle for 3 given plane
%% Input variables 
% Intrinsic matrix of the camer
% points for the first plane (at least 4) m*2 array
% points for the second plane (at least 4) m*2 array
% points for the third plane
% model points is the 2D coordinates of the corners of the plane in real world
%% Output variable
% 3*1 Angle in degree
% In order of, angle between plane1 and plane2, between plane2 and plane3
% , between plane1 and plane3. All angles are in abs value.
model_points_1 = model_points(:,:,1); % Get the 2D coordinates for corners of each plane
model_points_2 = model_points(:,:,2);
model_points_3 = model_points(:,:,3);
Homography1 = cv.findHomography(model_points_1(:,1:2), result_points1); % Get homography between 2D coordinates of the corners of plane and image points
Homography2 = cv.findHomography(model_points_2(:,1:2), result_points2);
Homography3 = cv.findHomography(model_points_3(:,1:2), result_points3);
decomposed_H1 = cv.decomposeHomographyMat(Homography1, intrin); % decomposed homography
decomposed_H2 = cv.decomposeHomographyMat(Homography2, intrin);
decomposed_H3 = cv.decomposeHomographyMat(Homography3, intrin);
R1 = decomposed_H1.R; % get rotation matrix for each homography
R2 = decomposed_H2.R;
R3 = decomposed_H3.R;
R_angle_difference1 = zeros(4, 1); % Since we have 4 possible solution in total, we record each solution
R_angle_difference2 = zeros(4, 1);
R_angle_difference3 = zeros(4, 1);
for n_i = 1:length(R1)
    temp_R1 = R1{n_i};
    temp_R2 = R2{n_i};
    temp_R3 = R3{n_i};
    temp_R1_angle = rotm2axang(temp_R1); % deompose rotation matrix to pure angle
    temp_R2_angle = rotm2axang(temp_R2);
    temp_R3_angle = rotm2axang(temp_R3);
    R_angle_difference1(n_i) = abs(temp_R1_angle(end) - temp_R2_angle(end)); % and relative angle difference and record
    R_angle_difference2(n_i) = abs(temp_R2_angle(end) - temp_R3_angle(end));
    R_angle_difference3(n_i) = abs(temp_R1_angle(end) - temp_R3_angle(end));
end
[error_1,~] = min(abs(rad2deg(R_angle_difference1) - 90)); % return the minimum distance between 90
[error_2,~] = min(abs(rad2deg(R_angle_difference2) - 90));
[error_3,~] = min(abs(rad2deg(R_angle_difference3) - 90));
difference = [error_1; error_2; error_3];