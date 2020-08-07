function z = add_nose_wear(z, w_nose)

z(z <= (min(z) + w_nose)) = (min(z) + w_nose);

end