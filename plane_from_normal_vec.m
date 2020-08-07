function [x, y, z] = plane_from_normal_vec(xy, vn)

[x, y] = meshgrid(xy, xy);

z_fun = @(x, y, a, b, c) (-a/c).*x + (-b/c).*y;

z = z_fun(x, y, vn(1), vn(2), vn(3));

end