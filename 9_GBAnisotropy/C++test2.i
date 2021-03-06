[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 60
  ny = 30
  nz = 0
  xmin = 0
  xmax = 1000
  ymin = 0
  ymax = 600
  zmin = 0
  zmax = 0
  elem_type = QUAD4
[]

[Variables] # produce smooth initial GB
  [./gr0]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = SpecifiedSmoothCircleIC
      x_positions = '250.0  750.0'
      y_positions = '300.0  300.0'
      z_positions = '  0.0    0.0'
      radii       = '200.0  200.0'
      invalue = 0.0
      outvalue = 1.0
      int_width = 50.0
    [../]
  [../]
  [./gr1]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = SmoothCircleIC
      x1 = 250.0
      y1 = 300.0
      radius = 200.0
      invalue = 1.0
      outvalue = 0.0
      int_width = 50.0
    [../]
  [../]
  [./gr2]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = SmoothCircleIC
      x1 = 750.0
      y1 = 300.0
      radius = 200.0
      invalue = 1.0
      outvalue = 0.0
      int_width = 50.0
    [../]
  [../]
[]

[AuxVariables]
  [./bnds]
    order = FIRST
    family = LAGRANGE
  [../]
  [./unique_grains]
    order = FIRST
    family = LAGRANGE
  [../]
  [./var_indices]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Kernels]
  [./PolycrystalKernel]
  var_name_base = gr
  op_num = 3
  [../]
[]

[AuxKernels]
  [./bnds_aux]
    type = BndsCalcAux
    variable = bnds
    execute_on = timestep_end
    var_name_base = gr
    op_num = 3
  [../]
[]

[BCs]
  [./Periodic]
    [./top_bottom]
      auto_direction = 'x y'
    [../]
  [../]
[]

[Materials]

  [./Anisotropy]
    type = myAnisoL
    f_name = L
    args = 'gr0 gr1 gr2'
    tignr = 0.005
    # L_coeff = '3.684e-1  3.684e-1  7.369e-1
    #            3.684e-1  3.684e-1  3.684e-1
    #            7.369e-1  3.684e-1  3.684e-1'
    L_coeff = '6.245e-2  6.245e-2  12.49e-2
               6.245e-2  6.245e-2  6.245e-2
               12.49e-2  6.245e-2  6.245e-2'
    outputs = exodus
    output_properties = 'L'

  [../]
  [./constant]
    type = GenericConstantMaterial
    prop_names = 'T    wGB GBenergy gamma_asymm'
    prop_values = '600 100  0.708     1.5     '
  [../]
  [./mu]   #0.0708
    type = ParsedMaterial
    f_name = mu
    function = '3.0 / 4.0 * 1.0 / f0s * GBenergy / wGB'
    constant_names = 'f0s wGB GBenergy'
    constant_expressions = '0.125 100  0.708'
  [../]
  [./kappa_op]  #31.86
    type = ParsedMaterial
    f_name = kappa_op
    function = '3.0 / 4.0 * GBenergy * wGB'
    constant_names = 'wGB GBenergy'
    constant_expressions = '100  0.708'
  [../]
[]

[Postprocessors]
  [./dt]
    # Outputs the current time step
    type = TimestepSize
  [../]

  [./gr1_area]
    type = ElementIntegralVariablePostprocessor
    variable = gr1
  [../]
  [./gr2_area]
    type = ElementIntegralVariablePostprocessor
    variable = gr2
  [../]
  [./walltime]
    type = PerformanceData
    event = ALIVE
    execute_on = TIMESTEP_END
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2

  #Preconditioned JFNK (default)
  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
  petsc_options_value = 'hypre boomeramg 31'

  l_max_its = 30
  l_tol = 1e-4
  nl_max_its = 40
  nl_rel_tol = 1e-9
  start_time = 0.0
  end_time = 20000
  dtmin = 1e-2
  dtmax = 1000

  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.8
    dt = 1.0
    growth_factor = 1.2
    optimal_iterations = 8
  [../]
[]

[Outputs]
  execute_on = 'timestep_end'
  exodus = true
  csv = true
[]
