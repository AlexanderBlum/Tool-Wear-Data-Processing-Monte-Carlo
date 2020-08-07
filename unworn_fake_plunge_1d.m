function [x, z_1d] = unworn_fake_plunge_1d(x, r, h)

% create x array across field of view, with zero at middle
% x = linspace(-fov/2, fov/2, pixels);

% anonymous function for circle formula
% k = y offset
% h = x offset
y = @(r, x, h, k) -sqrt(r.^2 - (x - h).^2) + k;

% create plunge
h_circ = 0; % circle has no shift in the x direction
k_circ = r; % shift the circle center up to y = tool radius
% this makes the bottom of circle always equal to y = 0
z_1d = real(y(r, x, h_circ, k_circ));
% create flat spots on either side of plunge
% this step also sets the DOC
z_1d( z_1d >= (h) ) = h;
% adjust y offset so that flats are at 0
z_1d = z_1d - h;

end