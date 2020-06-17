[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 20
  ny = 20
  nz = 0
  xmax = 1000
  ymax = 1000
  zmax = 0
  elem_type = QUAD4
  uniform_refine = 3
[]

[GlobalParams]
  op_num = 3
  var_name_base = 'gr'

  #For Materials Block
  enable_ad_cache = false
  enable_jit = false
[]

[Variables]
  [./PolycrystalVariables]
  [../]
[]

[UserObjects]
  [./voronoi]
    type = PolycrystalVoronoi
    rand_seed = 3
    grain_num = 3
    coloring_algorithm = bt
  [../]
[]

[ICs]
  [./PolycrystalICs]
    [./PolycrystalColoringIC]
      polycrystal_ic_uo = voronoi
    [../]
  [../]
[]

[AuxVariables]
  [./bnds]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Kernels]
  [./gr0dot]
    type = TimeDerivative
    variable = gr0
  [../]
  [./gr0bulk]
    type = ACGrGrPoly
    v = 'gr1 gr2'
    variable = gr0
    mob_name = L
  [../]
  [./gr0interface]
    type = ACInterface
    variable = gr0
    args = 'gr1 gr2'
    kappa_name = kappa_op
    mob_name = L
    variable_L = true
  [../]
  [./gr1dot]
    type = TimeDerivative
    variable = gr1
  [../]
  [./gr1bulk]
    type = ACGrGrPoly
    v = 'gr0 gr2'
    variable = gr1
    mob_name = L
  [../]
  [./gr1interface]
    type = ACInterface
    variable = gr1
    args = 'gr0 gr2'
    kappa_name = kappa_op
    variable_L = true
    mob_name = L
  [../]
  [./gr2dot]
    type = TimeDerivative
    variable = gr2
  [../]
  [./gr2bulk]
    type = ACGrGrPoly
    v = 'gr0 gr1'
    variable = gr2
    mob_name = L
  [../]
  [./gr2interface]
    type = ACInterface
    args = 'gr0 gr1'
    variable = gr2
    kappa_name = kappa_op
    variable_L = true
    mob_name = L
  [../]
[]

[AuxKernels]
  [./BndsCalc]
    type = BndsCalcAux
    variable = bnds
    execute_on = 'timestep_end'
  [../]
[]

[BCs]
  [./Periodic]
    [./All]
      auto_direction = 'x y'
    [../]
  [../]
[]

[Materials]
  [./L_equation]
    type = DerivativeParsedMaterial
    f_name = L
    derivative_order = 2
    args = 'gr0 gr1 gr2'
    function = '(L01*(gr1 + t)^2*(gr0 + t)^2 + L12*(gr1 + t)^2*(gr2 + t)^2 + L02*(gr2 + t)^2*(gr0 + t)^2)
                 /
                ((gr0 + t)^2*(gr1 + t)^2 + (gr1 + t)^2*(gr2 + t)^2 + (gr2 + t)^2*(gr0 + t)^2)'

    constant_names =       'L01   L02   L12    t'
    constant_expressions = '100.0 20.0  60.5   1e-2'
    outputs = exodus
    output_properties = 'L'
  [../]

  [./constant]
    type = GenericConstantMaterial
    prop_names = 'T    wGB GBenergy gamma_asymm'
    prop_values = '500 60  0.708     1.5     '
  [../]
  [./mu]   #0.0708
    type = ParsedMaterial
    f_name = mu
    function = '3.0 / 4.0 * 1.0 / f0s * GBenergy / wGB'
    constant_names = 'f0s wGB GBenergy'
    constant_expressions = '0.125 60  0.708'
  [../]
  [./kappa_op]  #31.86
    type = ParsedMaterial
    f_name = kappa_op
    function = '3.0 / 4.0 * GBenergy * wGB'
    constant_names = 'wGB GBenergy'
    constant_expressions = '60  0.708'
  [../]
[]

[Postprocessors]
  [./dt]
    # Outputs the current time step
    type = TimestepSize
  [../]
  [./gr0_area]
    type = ElementIntegralVariablePostprocessor
    variable = gr0
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
  [./physical]
    type = MemoryUsage
    mem_type = physical_memory
    value_type = total
    execute_on = TIMESTEP_END
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
  petsc_options_value = 'hypre boomeramg 31'

  automatic_scaling = true
  compute_scaling_once = false
  verbose = true

  l_tol = 1.0e-4
  l_max_its = 30
  nl_max_its = 20
  nl_rel_tol = 1.0e-9
  start_time = 0.0
  end_time = 1000
  dtmin = 1e-3
  dtmax = 1000
  [./Adaptivity]
    coarsen_fraction = 0.1
    max_h_level = 3
    refine_fraction = 0.7
  [../]
  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.8
    dt = 0.008
    growth_factor = 1.2
    optimal_iterations = 8
  [../]
[]

[Outputs]
  execute_on = 'timestep_end'
  exodus = true
  csv = true
[]
