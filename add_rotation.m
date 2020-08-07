function z = add_rotation(z, theta_zmin, theta_zmax, pixels)

new_dim = 1400;

pad_size = [0 (new_dim-pixels)/2];
z = repmat(z(1,:), new_dim, 1);
z = padarray(z, pad_size, 0);

theta_z = theta_zmin + (theta_zmax - theta_zmin).*rand(1);


% theta_z = normrnd(0, 3);

z = imrotate(z, theta_z, 'bilinear', 'crop');
% 
rect = [pad_size(2)     pad_size(2)     pixels-1      pixels-1];

z = imcrop(z, rect);
% RECT is a 4-element vector with the form [XMIN YMIN WIDTH HEIGHT];

end