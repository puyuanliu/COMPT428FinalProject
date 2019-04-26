function X = get_X(A)
%% This function returns all integer coordinates inside the polygen 
%% speficied by A

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