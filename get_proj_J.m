function result = get_proj_J(I,x)
% This function doesn't calculate the Jacobian
% It calculats the product of gradient and Jacobian
%% Input variables
% I is a m*2 vector that stands for the gradient
% x is the input position vector of all pixels that we are tracking
%% Output variables
% A 1*m row vector where m is the number of parameters (p) 

%% Calculation
% J = [a1 a2 a3 a4 a5 a6]   [x 0 y 0 1 0]
%     [b1 b2 b3 b4 b5 b6]   [0 x 0 y 0 1]
% ans =
%  
% [ conj(x), conj(y), 1,       0,       0, 0,       0,       0]
% [       0,       0, 0, conj(x), conj(y), 1,       0,       0]
% [       0,       0, 0,       0,       0, 0, conj(x), conj(y)]
Ix = I(:,1);
Iy = I(:,2);
result =  [Ix.*x(:,1), Ix.*x(:,2), Ix, Iy.*x(:,1), Iy.*x(:,2), Iy, x(:,1), x(:,2)];
end