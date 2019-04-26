function [success, points_result, p, pixel_error] = get_affine_pos(A, p, I_old, I_new, the_max, tol)
%% input variables
% A is a 4*2 matrix that specifies the region of affine.
% The function also accept a alternative X stands for pixels (m*2)
% mes specify which we are using
% p is the initial guess of the parameter of Translation
% I1 is the initial frame, I2 is the new frame
% we are mapping the region in the initial frame to
% the region in the new frame by using p
% max is the max iteration times, tol is the tolearance of error
% points is the 4 points the rectangle if it's the first run
% points are 3*4 vector [x, y, 1]'

%% Output variable
% A is the point of a rectangle that contains our tracked object in new
% frame
% new_x is the set of pixels of the tracked object in new frame
% success tells if we lose track
% points_result is the rectangle points after transformation
% points_result is 4*2

%% Used variables
W = get_affine_W(p); % initial wrap matrix
sum_error = 10000000; % initialization of current error
current_iteration = 0; % initialization of current iteration number
success = true; % if we are losing track
%% Calculate the region matrix
X = get_X(A);
%X2 = get_X(A2);
%X = [X1,X2];
points= [A, ones(length(A),1)];
points = double(points');
% points2= [A2, ones(length(A2),1)];
% points2 = double(points2');
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

old_w = [1 0 0; 0 1 0]; % covert to m*2
old_x = (old_w*X)';
p = double(p);
while (current_iteration < the_max) && (sum_error/length(X) > tol)
    temp_new_x = W*[X(2,:); X(1,:); X(3,:)];
    new_x = ([temp_new_x(2,:); temp_new_x(1,:)])'; % W*A is a 2*m, we convert to m*2, new position of tracked pixels
    [current_error,temp_success] = get_error(old_x, new_x, I_old, I_new); % get error
    if temp_success == false
        p = initial_p;
    end
    sum_error = norm(double(current_error));
    [deltap, ~] = get_deltap(new_x, @get_I, @get_affine_J, I_old, I_new, current_error);
    p = p+deltap';
    W = get_affine_W(p);
    current_iteration = current_iteration+1;
    temp = (W*X)';
    if norm(deltap./p') <0.01
        break
    end
%     if max(temp(:,1)) >= temp_y -1 || max(temp(:,2)) >= temp_x -1
%         fprintf("Out of range\n");
%         break
%     elseif min(temp(:,1)) <=0 || min(temp(:,2)) <=0
%         fprintf("Out of range\n");
%         break
%     end
end

% affine_f = @(p)test_affine(p,X, I_old, I_new);
% [p,sum_error] = fmincon(affine_f,p)
% 
%W = get_affine_W(p);

% parallel_f = @(p)get_parallel_line_error(p,points, points2);
% A = [];
% b = [];
% Aeq = [];
% beq = [];
% lb = zeros(size(p));
% ub = zeros(size(p));
% for i = (1:length(p))
%     if p(i) <0
%         lb(i) = 1.05*p(i);
%         ub(i) = 0.95*p(i);
%     else
%         lb(i) = 0.95*p(i);
%         ub(i) = 1.05*p(i);
%     end
% end
% 
% options = optimoptions('fmincon', 'ConstraintTolerance', 10^-20, 'StepTolerance', 10^-20);
% result_parallel_p = fmincon(parallel_f,p, A,b,Aeq,beq,lb,ub,[], options);
% if p~= 0
%     p = result_parallel_p;
% end
temp_points_result = W*[points(2,:);points(1,:); points(3,:)];
points_result = int32(([temp_points_result(2,:); temp_points_result(1,:)])');

% temp_points_result2 = W*[points2(2,:);points2(1,:); points2(3,:)];
% points_result2 = int32(([temp_points_result2(2,:); temp_points_result2(1,:)])');


pixel_error = sum_error/length(X);
fprintf("\nError norm is %f, use %d iteration \n", pixel_error, current_iteration)

% if sum_error>15*tol
%     success = false;
% end
end

