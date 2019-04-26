function W = get_affine_inv_W(p)
% Caulculate the wrap matrix for trans with given parameter
% [1 + p1, p3, p5]
% [p2, 1+p4, p6]
factor = 1/((1+p(1))*(1+p(4)) - p(2)*p(3)); % P factor
new_p = zeros(6,1);
% each P for affine
new_p(1) = factor*(-p(1) - p(1)*p(4) + p(2)*p(3));
new_p(2) = factor*(-p(2));
new_p(3) = factor*(-p(3));
new_p(4) = factor*(-p(4) - p(1)*p(4) + p(2)*p(3));
new_p(5) = factor*(-p(5) - p(4)*p(5) + p(3)*p(6));
new_p(1) = factor*(-p(6) - p(1)*p(6) + p(2)*p(5));
p = new_p;
W = [1+p(1), p(3), p(5); p(2), 1+p(4) p(6)];
end