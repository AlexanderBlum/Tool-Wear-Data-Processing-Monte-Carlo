function z = add_tilt(x, min_deg, max_deg, z)

angles = min_deg + (max_deg-min_deg).*rand([1,3]);

% angles = normrnd(0, .1, [1 3]);

n_vec = rotate_vector(angles(1), angles(2), angles(3));

[~, ~, z_tilt] = plane_from_normal_vec(x, n_vec);

z = z + z_tilt;

end