function z = add_edge_wear(z, x, r, h, fr_rev, res)
% adds edge wear to a fake plunge
% the amount of wear added is ties directly to the feed per rev
%
% Alex Blum
% July 31, 2019

% create an unworn plunge. we can't use the z input, because this could
% already have edge wear added. also, the DOC is much lower
[~, p1   ] = unworn_fake_plunge_1d(x, r, h);

% shift p1 by the amount of indices closest to the number of pixels
% equvalent to one feed per rev, rounding up.
p2 = circshift(p1, ceil(fr_rev/res));

% now we have two plunges, offset by the number of pixels equivalent to how
% far the tool moves in one revolution of the spindle. subtracting the
% shifted from the original makes a chip!
chip = p1 - p2;
chip(x <= 0) = 0;

% save the input as a reference for the filtering operation peformed below
z_ref = z;

% set all of the 'chip' on the unworn side equal to zero, since this
% doesn't represent physical reality
z(x > 0) = z(x > 0) + chip(x > 0);

z_flat = z - z_ref; % 'flatten' z, keeping only the chip

% smooth the chip using a gaussian filter
x_c = 30;
z_flat_filt = gauss_surf_filter_1d(z_flat, x, x_c);

% add the reference back to 'un-flatten' the plunge
z = z_flat_filt + z_ref;

end