function zmaps = create_fake_phasemaps(n_plunges, varargin)
% outputs a collection of fake plunge phasemaps to be used in developing,
% troubleshooting, or analyzing my data processing algorithms

% Aug 29, 2019
% Alex Blum

%%
% CAN CALL THIS FUNCTION THREE WAYS
% 1. zmaps = create_fake_phasemaps(n_plunges)
%    this will create n_plunges number of phasemaps, using the reference
%    settings defined in the case structure below
% 2. zmaps = create_fake_phasemaps(n_plunges, p, f)
%    this creates plunges using p parameters and f flags. used mostly for
%    monte carlo analysis of the data processing algorithm
% 3. zmaps = create_fake_phasemaps(n_plunges, p, f, fref)
%    creates a worn and unworn plunge set, so the data is similar to actual
%    experimental data. future version might iterate tool wear over number
%    of plunges
%
%% FUNCTION INPUTS:
%
% n_plunges - number of plunges to create
%
% f - these are FLAGS. they turn features on and off
% 
% f.add_noise - add noise to the fake data
% f.nose_wear - add nose wear to the fake data
% f.edge_wear - add edge wear to the fake data
% f.rotate_z  - rotate the fake data about z axis
% f.tilt_map  - use random normal vector to tilt fake data
% 
% fref - same parameters as above
% 
% p - these are PARAMETERS. 
% p.pixels       - number of pixels in SWLI sensor
% p.fov          - SWLI field of view with 20x objective (micrometers)
% p.plunge_depth - plunge depth (micrometers)
% p.tool_rad     - tool radius (micrometers)
% p.nose_wear    - recession of the nose (micrometers)
% p.S            - spindle speed (rev/min)
% p.fr           - spindle speed (mm/min)
% p.cut_depth    - depth of cut (micrometers)
% 
% p.min_tilt_deg  - minimum bound on tilt error (degrees) -.1
% p.max_tilt_deg  - maximum bound on tilt error (degrees)  .1
% 
% p.min_rot_deg - minimum bound on rotation about z
% p.max_rot_deg - maximum bound on rotation about z


%% parse function inputs
if nargin == 1
        % if no parameters or flags set, use standard inputs
        unworn_flag = 0;
        f.add_noise = 0;

        f.nose_wear = 1;
        f.edge_wear = 1;
        f.rotate_z  = 1;
        f.tilt_map  = 1;

        f_ref.nose_wear = 0;
        f_ref.edge_wear = 0;
        f_ref.rotate_z  = 1;
        f_ref.tilt_map  = 1;
        f_ref.add_noise = 0;

        %% these are PARAMETERS
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

        p.min_rot_deg = -5;
        p.max_rot_deg =  5;
elseif nargin == 3
    f = varargin{2};
    p = varargin{1};
    unworn_flag = 0;
elseif nargin == 4
    p = varargin{1};
    f = varargin{2};
    f_ref = varargin{3};
    unworn_flag = 1;
else
    error('Invalid number of function arguments');
end

%%
ref_zmaps = cell(1, n_plunges);
zmaps     = cell(1, n_plunges);

% create fake plung
for ii = 1:n_plunges
% first, create fake data, thenget in the correct units
% main program converts back to micrometers
    zmaps{ii}     = create_fake_plunge_data(f    , p);
    zmaps{ii}     = zmaps{ii}*10^-6;
%     plunges{ii}     = flipud(plunges{ii});
end

if unworn_flag == 1
    ref_plunge = create_fake_plunge_data(f_ref, p);
    ref_plunge = ref_plunge*10^-6;
    zmaps{1} = ref_plunge;
end

zmaps     = cell2struct(zmaps    , 'phaseMap', 1)';
ref_zmaps = cell2struct(ref_zmaps, 'phaseMap', 1)';

for ii = 1:n_plunges
    ref_zmaps(ii).name = 'fake data';
    zmaps(ii).name     = 'fake data';
end
end