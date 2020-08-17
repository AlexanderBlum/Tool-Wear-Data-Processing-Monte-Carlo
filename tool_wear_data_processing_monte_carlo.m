% function tool_wear_data_processing_monte_carlo

close all

n_plunges = 10;

%% these are FLAGS. they turn features on and off
unworn_flag = 0;
use_real_data = 0;

f.nose_wear  = 0;
f.edge_wear  = 0;
f.rotate_z   = 1;
f.tilt_map   = 1;
f.add_noise  = 0;
f.tool_marks = 0;

f_ref.nose_wear = 0;
f_ref.edge_wear = 0;
f_ref.rotate_z  = 1;
f_ref.tilt_map  = 1;
f_ref.add_noise = 0;
f_ref.tool_marks = 0;

%% these are PARAMETERS
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

p.min_rot_deg = -1; % -1
p.max_rot_deg =  1; % 1

real_data_fname = 'ET_2020785_20x_A_quick_clean.mat';
real_data_params = 'params_for_str_data.txt';

plunges     = cell(1, n_plunges);

% for ii = 1:n
if use_real_data == 0
% create fake plunges
    for ii = 1:n_plunges
    % first, create fake data, thenget in the correct units
    % main program converts back to micrometers
        plunges{ii}     = create_fake_plunge_data(f, p);
        plunges{ii}     = plunges{ii};
    %     plunges{ii}     = flipud(plunges{ii});
    end

    % if unworn flag is set, use the ref_data settings to create a fake
    % phasemap, and set that fake phasemap as the first data set
    if unworn_flag == 1
        ref_plunge = create_fake_plunge_data(f_ref, p);
        ref_plunge = ref_plunge*10^-6;
        plunges{1} = ref_plunge;
    end

    plunges     = cell2struct(plunges, 'phaseMap', 1)';
    
    for ii = 1:n_plunges
        plunges(ii).name     = 'fake data';
    end
    [ phase_maps, r, x, z ] = data_processing_main_r7(plunges, 'fake data params_1.txt');
else
    real_data_path = which(real_data_fname);
    load(real_data_path, 'ET_2020785_20x_A_quick_clean');
    output = ET_2020785_20x_A_quick_clean;
%     load(real_data_path, 'output');    
    ref_plunge = output(1).phaseMap;
    x = linspace(-p.fov/2, p.fov/2, p.pixels); 
    for ii = 1:n_plunges
        % add errors to real plunge data
        plunges{ii} = ref_plunge;

        plunges{ii} = add_rotation(plunges{ii}, p.min_rot_deg, p.max_rot_deg, p.pixels);
%         plunges{ii} = add_tilt(x, p.min_tilt_deg, p.max_tilt_deg, plunges{ii});
        
    end
    
    plunges     = cell2struct(plunges    , 'phaseMap', 1)';
    
    for ii = 1:n_plunges
        plunges(ii).name     = output(1).name;
    end    
    [ phase_maps, r, x, z ] = data_processing_main_r7(plunges, real_data_params);
%     close all
end

% [ ref_phase_maps, ref_r, ref_x, ref_z ] = data_processing_main(ref_plunges);


% ls = {'-', '--', ':', '-.', '-', '--', '-', '--', ':', '-.', '-', '--', '-', '--', ':', '-.', '-', '--', '-', '--', ':', '-.', '-', '--'}';
% ls = ls(1:length(z));

% resid_ax = axes; 
% hold(resid_ax, 'on');
r.res = cellfun(@(A) A*10^3, r.res, 'UniformOutput', 0);
% cellfun(@plot, x, r.res, ls);
figure;
axes;
hold on;
cellfun(@plot, x(2:end), r.res(2:end));

xlabel('Position (\mum)')
ylabel('Deviation (nm)')

% calculate mean and standard deviation with respect to each position
rx_mean    = nan(1, length(x{1}));
rx_std_dev = nan(1, length(x{1}));
for jj = 1:length(processedData(1).ResidualData.X)
    for ii = 2:n_plunges
        zjj(ii) = r.res{ii}(jj);
    end
    rx_mean(jj)    = mean(zjj);
    rx_std_dev(jj) = std(zjj);
end

% add to this - make it plot as a distribution?
figure, plot(x{1}, rx_std_dev)
xlabel('Position (\mum)')
ylabel('Uncertainty (nm)')

% end