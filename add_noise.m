function phase_map = add_noise(phase_map, std_dev)

Nrows = size(phase_map, 1);
Ncols = size(phase_map, 2);
phase_map = phase_map + normrnd(0, std_dev, [Nrows, Ncols]);

end