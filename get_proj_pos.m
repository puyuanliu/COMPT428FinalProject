function [success, points_result, p] = get_proj_pos(A, p, I_old, I_new, the_max, tol)


%% Used variables
W = get_proj_W(p); % initial wrap matrix
sum_error = 10000000; % initialization of current error
current_iteration = 0; % initialization of current iteration number
success = true; % if we are losing track
%% Calculate the region matrix
all_x = A(:,1); % generate all coordinates inside the region that we are tracking
all_y = A(:,2);
a = min(all_x):max(all_x);
b = min(all_y):max(all_y);
[temp_A,temp_B] = meshgrid(a,b);
c=cat(2,temp_A',temp_B');
d=reshape(c,[],2);
x_coordinates = d(:,1);
y_coordinates = d(:,2);
[in,on] = inpolygon(x_coordinates, y_coordinates, all_x, all_y);
sum_x_coordinates = [x_coordinates(in);x_coordinates(on)];
sum_y_coordinates = [y_coordinates(in);y_coordinates(on)];
X = [sum_x_coordinates, sum_y_coordinates];
X = [X, ones(length(sum_x_coordinates),1)];
X = X';
X = double(X);
points= [A, ones(length(A),1)];
points = double(points');
initial_p = p;
%% Substract RGB info
% red_I_old = I_old(:,:,1);
% green_I_old = I_old(:,:,2);
% blue_I_old = I_old(:,:,3);
% 
% red_I_new = I_new(:,:,1);
% green_I_new = I_new(:,:,2);
% blue_I_new = I_old(:,:,3);


%% Keep iterating until it meets the max iteration or satisfy our tolerance

old_w = [1 0 0; 0 1 0; 0 0 1]; % covert to m*2
old_x = (old_w*X)';
while (current_iteration < the_max) && (sum_error > tol)
    [temp_y, temp_x] = size(I_old); % check if we are accesing some
    new_x = (W*X); % W*A is a 2*m, we convert to m*2, new position of tracked pixels
    new_x = new_x(1:2,:)./new_x(3,:);
    new_x = new_x';
    current_error = get_error(old_x, new_x, I_old, I_new); % get error
    sum_error = norm(double(current_error));
    [deltap, temp_success] = get_deltap(new_x, @get_I, @get_proj_J, I_old, I_new, current_error);
    if temp_success == false
        p = initial_p;
    end
    p = p+deltap';
    W = get_proj_W(p);
    current_iteration = current_iteration+1;
    temp = (W*X)';
    if max(temp(:,1)) >= temp_x -1 || max(temp(:,2)) >= temp_y -1
        fprintf("Out of range\n");
        break
    elseif min(temp(:,1)) <=0 || min(temp(:,2)) <=0
        fprintf("Out of range\n");
        break
    end
end
temp_result = W*points;
points_result = int32((temp_result(1:2,:)./temp_result(3,:))');
fprintf("\nError norm is %f, use %d iteration \n", sum_error, current_iteration)

if sum_error>15*tol
    success = false;
end
end
