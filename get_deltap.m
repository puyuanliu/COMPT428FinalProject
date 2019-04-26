function [deltap, success] =get_deltap(X, I_func, J_func, I_old, I_new, error)
%% Input variables
% X is the set of pixels that we need to calculate
% I_func is the function handle that calcultes gradient vector
% J_func is the function handle that calculates the Jacobian matrix
% I_old the previous image, I_new is the new image
% error is the calculated error vector for these images

%% Output variables
% Output is the delta p


%% Initialization of variables
[I,success] = I_func(X, I_new); % get the gradient of pixels
if success == false
    deltap = 0;
    return
end

%% Calculation of the Hessian matrix and mul
mul = double(J_func(I, X)); % get a n*m matrix, which stands for the product 
                    % of gradient and Jacobian, m is the number of
                    % parameter, n is the length of X 
new_error = mul.*error; % store step value, it's not the error
new_error = (sum(new_error))'; % it's the multiplication of gradient, J and error
mul = double(mul);
H = mul'*mul; % Get H
H_inv = pinv(H);
deltap = H_inv * new_error; % Calculation of the delta p.

end