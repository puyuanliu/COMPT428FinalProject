function [I,success] = get_I(X, I1)
%% input variables
% X is some pixels
% I1 is the current frame

%% Output variables
% Gradient vector for the current pixel between 2 image

%% Gradient calculation
success = true;
% index for x derivative
if max(X(:,1))>= size(I1,2) || min(X(:,1))<= 1 || max(X(:,2))>= size(I1,1) ||min(X(:,2))<= 1
    success =false;
    I = 0;
    return;
end
% new_index = sub2ind(size(I1), X(:,2), X(:,1)+1); % convert vectors to index of image
% old_index = sub2ind(size(I1), X(:,2), X(:,1));
Iy = interp2(I1,X(:,1)+1, X(:,2)) - interp2(I1,X(:,1), X(:,2)); % image matrix has inverse index
% index for y derivative
% new_index = sub2ind(size(I1), X(:,2)+1, X(:,1)); % convert vectors to index of image
% old_index = sub2ind(size(I1), X(:,2), X(:,1));
Ix = interp2(I1,X(:,1), X(:,2)+1) - interp2(I1,X(:,1), X(:,2));
I = [Ix, Iy];

end