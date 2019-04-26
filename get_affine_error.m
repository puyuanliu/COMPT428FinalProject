function sum_error = get_affine_error(new_A, initial_A, initial_A2, initial_A3, initial_region_1,...
                    initial_region_2, initial_region_3, grey_I, X1, X2, X3, intrin, model_points)
%% Input Variables
% new_A is a 12*2 matrix which contains the current guess of the coordinate
% of corner points for all 3 planes
% initial_A is the coordinates of the corner points for the first plane 4*2
% initial_A2 is the coorinates of the corner points for the second plane 
% initial_A3 is the coorinates of the corner points for the third plane
% X1 is the coordinates of all pixels inside the initial n*2
% region of the first plane
% X2 is the coordinates of all pixels inside the initial n*2
% region of the second plane
% X3 is the coordinates of all pixels inside the initial n*2
% region of the third plane
% Gery_I is the grey version of the current frame 
% initial_region_1 is the intensity for X1 in the first frame n*1
% initial_region_2 is the intensity for X2 in the second frame n*1
% initial_region_3 is the intensity for X3 in the third frame n*1

%% Ouput variable
% sum_error is a 9*1 vector where the first 3 rows stands for the error
% from affine SSD, the next 3 rows stands for the error due to joint edge
% constraints, the last 3 rows stand for the error due to the homography
% decomposition (difference between the realtive angle determined by
% homography decomposition and their right angle,ie.90 since planes are
% orthognal
                
new_A = real(new_A); % Sometimes this could be a imaginary number for some reason
new_A1 = new_A(1:4,:) + double(initial_A); % Input coordinates was scaled accroding to the it's initial frame coordinate, thus we need to resacle
new_A2 = new_A(5:8,:) + double(initial_A2);
new_A3 = new_A(9:12,:) +double(initial_A3);
tform1 = estimateGeometricTransform(double(initial_A),new_A1,'affine'); % Estimate the affine transfomration between the initial tracked region and current suspected region
F1 = (tform1.T)'; % Get the transformation matrix
F1 = F1(1:2, :); 
tform2 = estimateGeometricTransform(double(initial_A2),new_A2,'affine');
F2 = (tform2.T)';
F2 = F2(1:2, :);
tform3 = estimateGeometricTransform(double(initial_A3),new_A3,'affine');
F3 = (tform3.T)';
F3 = F3(1:2, :);

new_x1 = (F1*X1)';  % Transform coordinates of pixels in the object region to coordinates of pixels in the suspected region in the new frame
new_x2 = (F2*X2)';
new_x3 = (F3*X3)';

current_error1= initial_region_1 - interp2(grey_I,new_x1(:,1), new_x1(:,2),'cubic'); % Get Affine SSD error
current_error2 = initial_region_2 - interp2(grey_I,new_x2(:,1), new_x2(:,2),'cubic'); 
current_error3 = initial_region_3 - interp2(grey_I,new_x3(:,1), new_x3(:,2),'cubic'); 

% Error due to the joint edge constraints, we sum the error up according to
% their dependence on the plane. ie. the frist plane has one edge in common
% with the second plane, it also has one edge in common with the third
% plane, thus it's point error will be the summation of the error of these
% 2 edge.
point_error1 = norm(new_A1(1,:) - new_A3(1,:)) + norm(new_A1(2,:) - new_A2(1,:)) + norm(new_A1(4,:) - new_A2(3,:)) +norm(new_A1(2,:) - new_A3(3,:));
point_error2 = norm(new_A1(2,:) - new_A2(1,:)) + norm(new_A1(4,:) - new_A2(3,:)) +  norm(new_A3(3,:) - new_A2(1,:)) +norm(new_A3(4,:) - new_A2(2,:));
point_error3 = norm(new_A1(1,:) - new_A3(1,:)) + norm(new_A1(2,:) - new_A3(3,:)) + norm(new_A3(3,:) - new_A2(1,:)) + norm(new_A3(4,:) - new_A2(2,:));


angle_error = calculate_angle_2(intrin, model_points, new_A1, new_A2, new_A3);

sum_error_1 = sum(abs(current_error1)); % Sum up the error for all pixels for each plane
sum_error_2 = sum(abs(current_error2));
sum_error_3 = sum(abs(current_error3));
ratio_point = 0.001; % Magnitude ration between Point constrain error and Affine SSD error
ratio_angle = 0.001;

current_error1 = sum_error_1/length(current_error1); % Take the averange error
current_error2 = sum_error_2/length(current_error2);
current_error3 = sum_error_3/length(current_error3);

sum_error = [current_error1; current_error2; current_error3; ratio_point*point_error1; ratio_point*point_error2;...
    ratio_point*point_error3; ratio_angle*(angle_error(1)+angle_error(2)); ratio_angle*(angle_error(2) + angle_error(3));... 
    ratio_angle*(angle_error(3) + angle_error(1))];
end