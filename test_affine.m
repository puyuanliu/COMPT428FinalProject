function error = test_affine(p, X, I_old, I_new)
old_w = [1 0 0; 0 1 0]; % covert to m*2
old_x = (old_w*X)';
W = get_affine_W(p);
temp_new_x = W*[X(2,:); X(1,:); X(3,:)];
new_x = ([temp_new_x(2,:); temp_new_x(1,:)])'; % W*A is a 2*m, we convert to m*2, new position of tracked pixels
[current_error,temp_success] = get_error(old_x, new_x, I_old, I_new); % get error
error = norm(double(current_error));
