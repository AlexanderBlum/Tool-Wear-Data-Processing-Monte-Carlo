% n_plunges = 1;

%% these are FLAGS. they turn features on and off
unworn_flag = 1;

f.nose_wear  = 1;
f.edge_wear  = 1;
f.rotate_z   = 0;
f.tilt_map   = 0;
f.add_noise  = 0;
f.tool_marks = 0;

p.pixels        = 1024 ;  % number of pixels in SWLI sensor
p.fov           = 420  ;  % SWLI field of view with 20x objective (micrometers)
p.plunge_depth  = 10   ;  % plunge depth (micrometers)
p.tool_rad      = 500  ;  % tool radius (micrometers)
p.nose_wear     = .5   ;  % recession of the nose (micrometers)
p.S             = 1000 ;  % spindle speed (rev/min)
p.std_dev       = .001 ;  % easuerement noise std dev (micrometers)
p.fr            = 2    ;  % spindle speed (mm/min)
p.cut_depth     = 5    ;  % depth of cut (micrometers)

p.min_tilt_deg  = -.10  ;  % minimum bound on tilt error (degrees) -.1
p.max_tilt_deg  =  .10  ;  % maximum bound on tilt error (degrees)  .1

p.min_rot_deg = -3; % -1
p.max_rot_deg =  3; % 1
% 
% ref_plunges = cell(1, n_plunges);
% plunges     = cell(1, n_plunges);

% phasemap    = create_fake_plunge_data(f    , p);
% int_spacing = .1;
% phasemap_interp = interp_phasemap(phasemap, int_spacing, p.fov, p.pixels);
ii = 1;
% for ii = 1:n
% create fake plunges
% for ii = 1:n_plunges
% first, create fake data, thenget in the correct units
% main program converts back to micrometers
    plunges{ii}     = create_fake_plunge_data(f    , p);
    plunges{ii}     = plunges{ii}*10^-6;
%     plunges{ii}     = flipud(plunges{ii});
% end

plunges{2} = imrotate(plunges{1}, 2, 'bilinear', 'crop');
plunges{3} = imrotate(plunges{2}, -2, 'bilinear', 'crop');
plunges{4} = imrotate(plunges{2}, -2.1, 'bilinear', 'crop');

resid{1} = plunges{1} - plunges{3};
resid{2} = plunges{1} - plunges{4};

plunge_slice{1} = resid{1}(500, :);
plunge_slice{2} = resid{2}(500, :);

figure;
plot(plunge_slice{1});
hold on
plot(plunge_slice{2});
