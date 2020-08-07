function tool_wear_data_processing_monte_carlo

close all

n_plunges = 1;

%% these are FLAGS. they turn features on and off
% unworn_flag = 1;
f.add_noise = 0;

f.nose_wear = 1;
f.edge_wear = 1;
f.rotate_z  = 0;
f.tilt_map  = 1;
% 
% f_ref.nose_wear = 0;
% f_ref.edge_wear = 0;
% f_ref.rotate_z  = 1;
% f_ref.tilt_map  = 1;
% f_ref.add_noise = 0;
% 
% %% these are PARAMETERS
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

p.min_rot_deg = -5; % -1
p.max_rot_deg =  5; % 1
% 

%%
% plunges = create_fake_phasemaps(n_plunges);
plunges = create_fake_phasemaps(n_plunges, p, f);

% [ ref_phase_maps, ref_r, ref_x, ref_z ] = data_processing_main(ref_plunges);
[ phase_maps, r, x, z ] = data_processing_main_r7(plunges, 'fake data params_1.txt');

% ls = {'-', '--', ':', '-.', '-', '--', '-', '--', ':', '-.', '-', '--', '-', '--', ':', '-.', '-', '--', '-', '--', ':', '-.', '-', '--'}';
% ls = ls(1:length(z));

% resid_ax = axes; 
% hold(resid_ax, 'on');
r.res = cellfun(@(A) A*10^3, r.res, 'UniformOutput', 0);
% cellfun(@plot, x, r.res, ls);
figure;
axes;
hold on;
cellfun(@plot, x, r.res);

xlabel('Position (\mum)')
ylabel('Deviation (nm)')

end