function points_result = get_points_result(p, points)
%% This function transfer the points by p
points= [points, ones(length(points),1)];
points = double(points');
W = get_affine_W(p);
temp_points_result = W*[points(2,:);points(1,:); points(3,:)];
points_result = int32(([temp_points_result(2,:); temp_points_result(1,:)])');