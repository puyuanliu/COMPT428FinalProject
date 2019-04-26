function [lb, ub, vertical_f] = get_bound(p, intrin, points_1, points_2)
%% This function calculates the bound for certain p
%% Input variables
% p is the affine parameters
% points_1 is the points in first frame
% points_2 is the points in second frame
%% Output variable
% handle of the function
% upper and lower bound
%% Below is the calculation 

vertical_f = @(p)calculate_angle(p,intrin, points_1, points_2);
lb = zeros(size(p));
ub = zeros(size(p));
for i = (1:length(p))
    if p(i) <0
        lb(i) = 1.05*p(i);
        ub(i) = 0.95*p(i);
    else
        lb(i) = 0.95*p(i);
        ub(i) = 1.05*p(i);
    end
end