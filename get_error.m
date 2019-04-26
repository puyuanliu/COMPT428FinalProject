function [error,success] = get_error(X_old, X_new, V_I_old, V_I_new)
% This function calculates the image error
% This function return a m*1 vector that contains the error for each pixel
% X_old is a m*2 vector that stands for all (x,y) pixels
% in the old image
% X_new is the m*2 vector that stands for all (x,y) pexels
% in the new image
% I_old is the old image, I_new is the new image
% It calculates the error between the region specifified 
% by X_old vector in old image and region specified by X_new
% vector in the I_new image
success = true;
% if max(X_new(:,1))>= size(I_old,2) || min(X_new(:,1))<= 1 || max(X_new(:,2))>= size(I_old,1) ||min(X_new(:,2))<= 1
%     success =false;
%     error = 100000;
%     return;
% end
% now we extract the index for these vectors so that we can
% access the cooresponding item in the image matrix
% index_old = sub2ind(size(I_old), X_old(:,2)',X_old(:,1)');
% index_new = sub2ind(size(I_new), X_new(:,2)',X_new(:,1)');
R_old = interp2(V_I_old,X_old(:,1), X_old(:,2),'cubic');
R_new = interp2(V_I_new,X_new(:,1), X_new(:,2),'cubic');
% R_old = double(I_old(index_old)'); % get a m*1 intensity vector for pixels in old image
% R_new = double(I_new(index_new)'); % get a m*1 intensity vector for pixels in new image
error = R_old - R_new;
end