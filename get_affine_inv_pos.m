function [A, new_x, success, points_result] = get_affine_inv_pos(A, X, p, I_old, I_new, the_max, tol, mes, points)
%% input variables
% A is a 2*2 matrix which stands for a rectangle that we are tracking
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

if mes == "A" % If we are given a rectangle region
    % region matrix contains all the vector of pixel we want to track
    num = (A(1,2) - A(1,1) +1 )*(A(2,2) - A(2,1) + 1); % number of pixels we are tracking
    X = zeros(3,num);
    counter = 1;
    for i = (A(1,1):A(1,2)) % x
        for j = (A(2,1): A(2,2)) %y
            X(:,counter) = [i,j,1]';
            counter = counter +1;
        end
    end
    points = [A(:,1), [A(1,1), A(2,2)]', [A(1,2), A(2,1)]' ,A(:,2)];
    points = [points;[1 1 1 1]];
else
    num = length(X);
    temp =  zeros(length(X),1) + 1;
    X = [X, temp]; % we add a column of 1 to the input X matrix to make it homogeneous
    X =X'; % X was oringinally a m*3, we change to 3*m to match our convension
    points = [points, [1 1 1 1]'];
    points = points';
end


%% Pre-computation of Jacobian, Hessian inverse, Gradient
old_w = [1 0 0; 0 1 0]; 
old_x = (old_w*X)'; % covert to m*2
T_gradient = get_I(old_x, I_old);
mul = get_affine_J(T_gradient, old_x); % get the multiplication of gradient and Jacobian matrix
mul = double(mul); % convert to double
H = mul'*mul; % calculate Hessian
H_inv = pinv(H);
[temp_y, temp_x] = size(I_old); % check if we are accesing some

%% Keep iterating until it meets the max iteration or satisfy our tolerance

while (current_iteration < the_max) && (sum_error > tol)
    new_x = (W*X)'; % W*A is a 2*m, we convert to m*2, new position of tracked pixels
    current_error = get_error(old_x, new_x, I_old, I_new); % get error
    current_error = double(current_error);
    sum_error = norm(double(current_error));
    mul_error = mul.*current_error; % store step value, it's not the error
    mul_error = (sum(mul_error))'; % it's the multiplication of gradient, J and error
    deltap = H_inv*mul_error; % get delta p
    p = p+deltap';
    W = get_affine_inv_W(p);
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
points_result = int32((W*double(points))');
fprintf("\nError norm is %f, use %d iteration \n", sum_error, current_iteration)

% if sum_error>3000
%     success = false;
% end
%% Return the new_x and A
% new_x now is a m*2 vector that stores the coordinates 
% of all the pixels, A is the matrix that store the info 
% for drawing rectangle

A = [new_x(1,:)', new_x(num,:)'];
end

