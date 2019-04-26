function parallel_result = get_parallel_line_error(p, points, points2)
W = get_affine_W(p);
parallel_result = 0;

%% For the first polygon
temp_points_result = W*[points(2,:);points(1,:); points(3,:)];
parallel11 = cross([temp_points_result(1,1),temp_points_result(2,1),1], [temp_points_result(1,2),temp_points_result(2,2),1]);
parallel12 = cross([temp_points_result(1,3),temp_points_result(2,3),1], [temp_points_result(1,4),temp_points_result(2,4),1]);

temp_result = cross(parallel11, parallel12);
parallel_result = parallel_result + temp_result(3);

parallel13 = cross([temp_points_result(1,1),temp_points_result(2,1),1], [temp_points_result(1,3),temp_points_result(2,3),1]);
parallel14 = cross([temp_points_result(1,2),temp_points_result(2,2),1], [temp_points_result(1,4),temp_points_result(2,4),1]);

temp_result = cross(parallel13, parallel14);
parallel_result = parallel_result + temp_result(3);

%% For the second polygon
temp_points_result = W*[points2(2,:);points2(1,:); points2(3,:)];
parallel11 = cross([temp_points_result(1,1),temp_points_result(2,1),1], [temp_points_result(1,2),temp_points_result(2,2),1]);
parallel12 = cross([temp_points_result(1,3),temp_points_result(2,3),1], [temp_points_result(1,4),temp_points_result(2,4),1]);

temp_result = cross(parallel11, parallel12);
parallel_result = parallel_result + temp_result(3);

parallel13 = cross([temp_points_result(1,1),temp_points_result(2,1),1], [temp_points_result(1,3),temp_points_result(2,3),1]);
parallel14 = cross([temp_points_result(1,2),temp_points_result(2,2),1], [temp_points_result(1,4),temp_points_result(2,4),1]);

temp_result = cross(parallel13, parallel14);
parallel_result = parallel_result + temp_result(3);

