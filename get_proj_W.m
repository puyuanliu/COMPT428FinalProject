function W = get_proj_W(p)
% Caulculate the wrap matrix for trans with given parameter
W = [1+p(1), p(3), p(5); p(2), 1+p(4), p(6); p(7), p(8), 1];
end