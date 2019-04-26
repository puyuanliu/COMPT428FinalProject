function W = get_affine_W(p)
% Caulculate the wrap matrix for trans with given parameter
% [1 + p1, p3, p5]
% [p2, 1+p4, p6]
W = [1+p(1), p(3), p(5); p(2), 1+p(4), p(6)];
end