[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 25
  ny = 25
  nz = 0
  xmax = 1000
  ymax = 1000
  zmax = 0
  elem_type = QUAD4
  uniform_refine = 2
[]

[GlobalParams]
  op_num = 4
  var_name_base = 'gr'
[]

[Variables]
  [./PolycrystalVariables]
  [../]
[]

[UserObjects]
  [./voronoi]
    type = PolycrystalVoronoi
    rand_seed = 6
    grain_num = 4
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

# [Materials]
#   [./CuGrGranisotropic]
#     type = GBAnisotropy
#     time_scale = 1.0e-2 #10ms
#     T = 600 # K
#     wGB = 60    # nm
#
#     # Assuming the L is same(1.88e-14) between same eta GBMobility 2.02e-15
#     Anisotropic_GB_file_name = anisotropy_mobility.txt   # anisotropy_energy.txt
#     inclination_anisotropy = false # true
#     outputs = exodus
#   [../]
# []

[Materials]
  [./L_equation]
    type = DerivativeParsedMaterial
    f_name = L
    derivative_order = 2
    args = 'gr0 gr1 gr2 gr3'
    function = '(L01*gr0^2*gr1^2 + L02*gr0^2*gr2^2 + L03*gr0^2*gr3^2 +
                 L12*gr1^2*gr2^2 + L13*gr1^2*gr3^2 + L23*gr2^2*gr3^2)/
               (gr0^2*gr1^2 + gr0^2*gr2^2 + gr0^2*gr3^2 + gr1^2*gr2^2 +
                 gr1^2*gr3^2 + gr2^2*gr3^2 + 1e-5)'
    constant_names =       'L01 L02 L03 L12 L13 L23'
    constant_expressions = '0.1 0.2 0.13 0.09 0.1 0.18'
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
  [./gr3_area]
    type = ElementIntegralVariablePostprocessor
    variable = gr3
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
  solve_type = 'NEWTON'

  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
  petsc_options_value = 'hypre boomeramg 31'

  l_tol = 1.0e-4
  l_max_its = 30
  nl_max_its = 20
  nl_rel_tol = 1.0e-9
  start_time = 0.0
  end_time = 1000
  dt = 10
  dtmin = 0.005
  dtmax = 1000
  [./Adaptivity]
    coarsen_fraction = 0.1
    max_h_level = 2
    refine_fraction = 0.7
  [../]
  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.8
    dt = 0.1
    growth_factor = 1.5
    optimal_iterations = 7
  [../]
[]

[Outputs]
  execute_on = 'timestep_end'
  exodus = true
  csv = true
[]
