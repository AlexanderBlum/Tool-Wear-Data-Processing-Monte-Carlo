function slope_vs_pixel_shift

pixel_shift = 50;
% pad_amount = 10;
% pad_val = 0;

f.add_noise = 0;

f.nose_wear = 0;
f.edge_wear = 0;
f.rotate_z  = 0;
f.tilt_map  = 0;

p.pixels        = 1024 ;  % number of pixels in SWLI sensor
p.fov           = 420  ;  % SWLI field of view with 20x objective (micrometers)
p.plunge_depth  = 10   ;  % plunge depth (micrometers)
p.tool_rad      = 500  ;  % tool radius (micrometers)
p.nose_wear     = .5   ;  % recession of the nose (micrometers)
p.S             = 1000 ;  % spindle speed (rev/min)
p.fr            = 2    ;  % spindle speed (mm/min)
p.cut_depth     = 5    ;  % depth of cut (micrometers)

res = p.fov/p.pixels;

z0 = nanmean(create_fake_plunge_data(f, p), 1);
x = linspace(0, length(z0)*res, length(z0));

res_fit_theta = nan(1, pixel_shift + 1);
for ii = 1:pixel_shift + 1
    % z1 = circshift(z0, pixel_shift);
    z1 = circshift(z0, ii-1);
    res = z1 - z0;
    res_fit = res(x > 150 & x < 250);
    x_res_fit = x(x > 150 & x < 250);
    res_fit_vals = polyfit(x_res_fit, res_fit, 2);
    res_fit_slope = res_fit_vals(1);   
    res_fit_theta(ii) = atand(res_fit_slope);
end

x_theta = 0:pixel_shift;
theta_fit = polyfit(x_theta, res_fit_theta, 2);
theta_fit_line = polyval(theta_fit, x_theta);
plot(x_theta, res_fit_theta, '*');
hold on
plot(x_theta, theta_fit_line);
xlabel('pixels');
ylabel('theta (deg)');

% use fsolve to find x, given a y
y = res_fit_theta(10);
f = @(x) theta_fit(1)*x.^2 + theta_fit(2)*x + theta_fit(3) - y;
init_guess = 1;
shift_back = fzero(f,init_guess);

end