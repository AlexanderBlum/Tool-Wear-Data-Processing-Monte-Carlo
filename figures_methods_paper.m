
%% illustrate naive alignment/registration

close all
clear all

edge_tol = .002;
map_crop = 100;
slice_index = 120;
start_index = 120;

f_unworn.nose_wear = 0;
f_unworn.edge_wear = 0;
f_unworn.rotate_z  = 1;
f_unworn.tilt_map  = 1;

f_worn.nose_wear = 1;
f_worn.edge_wear = 1;
f_worn.rotate_z  = 1;
f_worn.tilt_map  = 1;

p.pixels        = 1024 ;  % number of pixels in SWLI sensor
p.fov           = 420  ;  % SWLI field of view with 20x objective (micrometers)
p.plunge_depth  = 10   ;  % plunge depth (micrometers)
p.tool_rad      = 500  ;  % tool radius (micrometers)
p.nose_wear     = .5   ;  % recession of the nose (micrometers)
p.S             = 1000 ;  % spindle speed (rev/min)
p.fr            = 2    ;  % spindle speed (mm/min)
p.cut_depth     = 5    ;  % depth of cut (micrometers)

p.min_tilt_deg  = -.10  ;  % minimum bound on tilt error (degrees) -.1
p.max_tilt_deg  =  .10  ;  % maximum bound on tilt error (degrees)  .1

p.min_rot_deg = -10; % -1
p.max_rot_deg =  10; % 1

dx = p.fov/p.pixels;

%% Figure a1 - unworn phasemap with piston, tilt, and rotation
z_unworn0 = create_fake_plunge_data(f_unworn, p);

x_unworn = linspace(0, 420, 1024);
[X, Y] = meshgrid(x_unworn, x_unworn);

plot_phasemap_figs(X, Y, z_unworn0)

%% Figure a2 - phasemap with rotation removed
z_unworn1 = rotate_phasemap( z_unworn0', edge_tol, 1, map_crop, slice_index,...
                             1, 7, p.fov/p.pixels, start_index, 0);
z_unworn1 = z_unworn1';
x_unworn = linspace(0, size(z_unworn1,1)*p.fov/p.pixels, size(z_unworn1,1));
[X, Y] = meshgrid(x_unworn, x_unworn);

plot_phasemap_figs(X, Y, z_unworn1)

%% Figure a3 - phasemap with piston and tilt removed
z_unworn2 = remove_plane( z_unworn1', edge_tol, 1, p.fov/p.pixels, start_index, 1, 7 ) ;
z_unworn2 = z_unworn2';

plot_phasemap_figs(X, Y, z_unworn2)

%% Figure a4 - column averaged data
z_unworn1d = nanmean(z_unworn2, 1);
figure
plot(x_unworn, z_unworn1d);
axis([0 x_unworn(end) -12 2]);
xlabel('X (\mum)');
ylabel('Z (\mum)');

%% illustrate eric method of final alignment

% use fake data
z_worn0 = create_fake_plunge_data(f_worn, p);

z_worn1 = rotate_phasemap( z_worn0', edge_tol, 1, map_crop, slice_index,...
                           1, 7, p.fov/p.pixels, start_index, 0);
z_worn1 = z_worn1';

x_worn = linspace(0, size(z_worn1,1)*p.fov/p.pixels, size(z_worn1,1));

z_worn2 = remove_plane( z_worn1', edge_tol, 1, p.fov/p.pixels, start_index, 1, 7 ) ;
z_worn2 = z_worn2';

z_worn1d = nanmean(z_worn2, 1);

%% Figure b1 - unworn plunge and worn plunge, poorly aligned
z_worn1d = circshift(z_worn1d, 10);

figure

plot(x_unworn, z_unworn1d);
hold on
plot(x_worn, z_worn1d);
axis([0 x_unworn(end) -12 2]);
xlabel('X (\mum)');
ylabel('Z (\mum)');

%% Figure b2 - unworn & worn plunge
% roughly aligned by trimming at plunge edge
% interpolate them first . . . 

int_spacing = 0.01;
dx = int_spacing;
% unworn plunge
x_unworn_int = x_unworn:int_spacing:x_unworn(end);
z_unworn1d = interp1(x_unworn, z_unworn1d, x_unworn_int', 'linear');

[ x1, ~ ] = edge_finder( z_unworn1d, 'l', 0, edge_tol, 1, dx, start_index);
[ x2, ~ ] = edge_finder( z_unworn1d, 'r', 0, edge_tol, 1, dx, start_index);
z_unworn1d = z_unworn1d(x1:x2);
x_unworn_int = x_unworn_int(1:length(z_unworn1d));

% worn plunge
x_worn_int = x_worn:int_spacing:x_worn(end);
z_worn1d = interp1(x_worn, z_worn1d, x_worn_int', 'linear');

[ x1, ~ ] = edge_finder( z_worn1d, 'l', 0, edge_tol, 1, dx, start_index);
[ x2, ~ ] = edge_finder( z_worn1d, 'r', 0, edge_tol, 1, dx, start_index);
z_worn1d = z_worn1d(x1:x2);
x_worn_int = x_worn_int(1:length(z_worn1d));

figure

plot(x_unworn_int, z_unworn1d);
hold on
plot(x_worn_int, z_worn1d);
% axis([0 x_unworn(end) -12 2]);
xlabel('X (\mum)');
ylabel('Z (\mum)');

%% Figure b3 - residual, with 'unworn' section highlighted
x_int = x_worn_int(1:20000);
z_unworn1d = z_unworn1d(1:20000);
z_worn1d = circshift(z_worn1d(1:20000), 2);

res = z_worn1d - z_unworn1d;
figure
plot(x_int, res);
xlabel('X (\mum)');
ylabel('Z (\mum)');

%% Figure b4 - residual, with fit line through unworn section



% three and four should come with math that explains why this works

%% Figure b5 - unworn and worn plunge, final alignment

%% Figure b6 - residual after final alignment

% final figures should be a monte carlo analysis for this method. what kind
% of error shows up? what are the biggest contributors?

%% illustrate alex method 1 of final alignment

% Figures should show one iteration of the circle shift convergence
% algorithm - or this can be an animation

%% illustrate alex method 2 of final alignment

% Figure 1 - unworn and worn plunge, roughly aligned

%% functions
function plot_phasemap_figs(X, Y, Z)
    figure 
    
    colormap(parula(1000));

    
    subplot(1, 2, 1);
    surf(X, Y, Z, 'EdgeColor', 'Interp');
    axis square
    xlabel('X (\mum)');
    ylabel('Y (\mum)');
    zlabel('Z (\mum)');

    grid off
    axis([0 X(end, end) 0 Y(end, end) -12 2]);
    view(0, 0);
    
    subplot(1, 2, 2);
    surf(X, Y, Z, 'EdgeColor', 'Interp');
    xlabel('X (\mum)');
    ylabel('Y (\mum)');
    zlabel('Z (\mum)');
    axis square
    grid off
    axis([0 X(end, end) 0 Y(end, end) -12 2]);
    view(0, 90);

end