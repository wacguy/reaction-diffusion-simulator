function [a_sol, h_sol, t_mesh, x_mesh] = solve(settings)

  act_bound_open_end = @settings.act_bound_open_end;
  act_eq_diffu = @settings.act_eq_diffu;
  act_eq_rest = @settings.act_eq_rest;
  act_init = @settings.act_init;
  growth = @settings.growth;
  inh_bound_open_end = @settings.inh_bound_open_end;
  inh_eq_diffu = @settings.inh_eq_diffu;
  inh_eq_rest = @settings.inh_eq_rest;
  inh_init = @settings.inh_init;
  time_max = @settings.time_max;

  t_size_per_mesh = 5;
  t_mesh = 0 : t_size_per_mesh : time_max();

  y_size_per_mesh = 0.001;
  y_mesh = 0 : y_size_per_mesh : 1;

  growth_differentiated_fn = matlabFunction(diff(sym(@(x) growth(x))));

  function [c, f, s] = pdepe_eq_fn(y, t, col_of_tilde, col_of_tilde_first_deriv)

    % Popov transformation

    a_tilde = col_of_tilde(1);
    h_tilde = col_of_tilde(2);

    a_tilde_first_deriv = col_of_tilde_first_deriv(1);
    h_tilde_first_deriv = col_of_tilde_first_deriv(2);

    f_a = act_eq_diffu() * a_tilde_first_deriv / (growth(t) ^ 2);
    f_h = inh_eq_diffu() * h_tilde_first_deriv / (growth(t) ^ 2);

    s_a = ...
      act_eq_rest(a_tilde, h_tilde) ...
      + growth_differentiated_fn() * y * a_tilde_first_deriv / growth(t);
    s_h = ...
      inh_eq_rest(a_tilde, h_tilde) ...
      + growth_differentiated_fn() * y * h_tilde_first_deriv / growth(t);

    c = [1; 1];
    f = [f_a; f_h];
    s = [s_a; s_h];

  end

  function rtn = pdepe_init_fn(y)

    % Popov initial conditions

    rtn = [act_init(y * growth(0)); inh_init(y * growth(0))];

  end

  function [pl, ql, pr, qr] = pdepe_bound_fn(~, col_of_tilde_left, ~, ~, ~)

    % Popov bondary conditions

    % Reminder: "LEFT" IS THE OPEN END.

    % At the closed end, enforce "No flux" (da/dx = dh/dx = 0).
    pr = [0; 0];
    qr = [1; 1];

    % At the open end, do what the user wants.
    a_tilde = col_of_tilde_left(1);
    h_tilde = col_of_tilde_left(2);
    act_bound = act_bound_open_end();
    inh_bound = inh_bound_open_end();
    act_bound_type = act_bound(1);
    inh_bound_type = inh_bound(1);
    act_bound_value = act_bound(2);
    inh_bound_value = inh_bound(2);
    if strcmp(act_bound_type, 'Dirichlet')
      pl_a = a_tilde - act_bound_value;
      ql_a = 0;
    else
      pl_a = 0;
      ql_a = 1;
    end
    if strcmp(inh_bound_type, 'Dirichlet')
      pl_h = h_tilde - inh_bound_value;
      ql_h = 0;
    else
      pl_h = 0;
      ql_h = 1;
    end
    pl = [pl_a; pl_h];
    ql = [ql_a; ql_h];

  end

  tilde_sols = ...
    pdepe( ...
      0, ... % This means PDE type is slab (among slab, cylindrical, spherical).
      ...    % Basically, just don't worry about this.
      @pdepe_eq_fn, ...
      @pdepe_init_fn, ...
      @pdepe_bound_fn, ...
      y_mesh, ...
      t_mesh);

  a_tilde_sol = tilde_sols(:, :, 1);
  h_tilde_sol = tilde_sols(:, :, 2);

  t_mesh_count = size(t_mesh, 2);

  x_mesh_count = 1000;
  growth_max = growth(time_max());
  x_mesh_size_per_mesh = growth_max / x_mesh_count;
  x_mesh = linspace(0, growth_max, x_mesh_count);

  function sol = return_from_popov(tilde_sol)

    sol = zeros(t_mesh_count, x_mesh_count);
    sol(:) = NaN;
    for t_idx = 1:t_mesh_count
      t = t_idx * t_size_per_mesh;
      for x_idx = 1:(x_mesh_count - 1)
        x = x_idx * x_mesh_size_per_mesh;
        y = x / growth(t);
        y_idx = int32(y / y_size_per_mesh);
        if y_idx <= size(tilde_sol, 2)
          sol(t_idx, x_idx) = tilde_sol(t_idx, y_idx);
        end
      end
    end

  end

  a_sol = return_from_popov(a_tilde_sol);
  h_sol = return_from_popov(h_tilde_sol);

end