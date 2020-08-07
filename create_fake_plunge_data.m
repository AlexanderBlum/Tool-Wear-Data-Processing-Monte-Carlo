function z = create_fake_plunge_data(f, p)
%% Function to create fake plunge data for monte carlo analysis
%
% Alex Blum
% July 31, 2019
%
% function inputs:
% f - flags, each set to 0 (false) or 1 (true)
%   f.nose_wear: add nose wear to the fake data
%   f.edge_wear: add edge wear to the fake data
%   f.rotate_z : add rotation about z to the fake data
%   f.tilt_map : add tilt to the fake data
% 
% p - parameters, used to create the fake plunge data
% 
%   p.pixels      : number of pixels in SWLI sensor
%   p.fov         : SWLI field of view (micrometers)
%   p.plunge_depth: plunge depth (micrometers)
%   p.tool_rad    : tool radius (micrometers)
%   p.nose_wear   : recession of the nose (micrometers)
%   p.S           : spindle speed (rev/min)
%   p.fr          : spindle speed (mm/min)
%   p.cut_depth   : depth of cut (micrometers) 
%   p.min_tilt_deg: minimum bound on tilt error (degrees)
%   p.max_tilt_deg: maximum bound on tilt error (degrees) 
%   p.min_rot_deg : minimum bound on rotation error (degrees)
%   p.max_rot_deg : maximum bound on rotation error (degrees)
% 
%  STEPS USED BY THE FUNCTION TO CREATE FAKE DATA
%  1. create plunge in x-z plane
%  2. add tool wear to the 'perfect' plunge
%  3. use repmat to create a phasemap from that plunge
%  4. add tilt to the 'perfect' plunge
%  5. add rotation about Z to the 'perfect' plunge (need to make original
%     bigger to rotate . . .
%
%  STEPS TO BE ADDED TO FUNCTION
%  A. add noise, using the STR
%  B. shift the plunge left or right (instead of being centered)
%  C. change radius of plunge (when viewed from top, tighter radius closer
%     to center of witness sample)

%% preliminary calculations
fr_rev = p.fr*1000/p.S; % convert feedrate from (mm/min) to (micrometers/rev)
res = p.fov/p.pixels  ; % spatial resolution of the SWLI
% x-axis for fake plunge data, same length as SWLI field of view
x = linspace(-p.fov/2, p.fov/2, p.pixels); 

%% create fake plunge
[x, z] = unworn_fake_plunge_1d(x, p.tool_rad, p.plunge_depth);

%% add nose wear
if f.nose_wear == 1
    z = add_nose_wear(z, p.nose_wear);
end
    
%% add leading edge wear
if f.edge_wear == 1
    z = add_edge_wear(z, x, p.tool_rad, p.cut_depth, fr_rev, res);
end

% add tool marks
if f.tool_marks == 1
    z = add_cusps(x, z, p.fr, p.tool_rad, p.S);
end
%% use repmat to turn into array
z = repmat(z, p.pixels, 1);

%% rotate about Z axis
% pad with zeros to make rotation work and keep original dimensions
% this should work because the array is still 'perfect' at this point
% and therefore the flats on each side of the plunge are at z = 0
% then we can crop to 1024x1024 when finished.
% the above will work in x, but in y the plunge needs to be extended using
% repmat...
if f.rotate_z == 1
    z = add_rotation(z, p.min_rot_deg, p.max_rot_deg, p.pixels);
end

%% add tilt
if f.tilt_map == 1
    z = add_tilt(x, p.min_tilt_deg, p.max_tilt_deg, z);
end
if f.add_noise == 1
    z = add_noise(z, p.std_dev);
end

end