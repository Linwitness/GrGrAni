[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 50
  nz = 0
  xmax = 2500
  ymax = 2500
  zmax = 0
  elem_type = QUAD4
  uniform_refine = 3
[]

[GlobalParams]
  op_num = 14
  var_name_base = 'gr'

  #For Materials Block
  derivative_order = 2
  evalerror_behavior = error
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
    rand_seed = 10
    grain_num = 100      #num of grains
    # coloring_algorithm = jp
  [../]
  [./grain_tracker]
    type = GrainTracker
    threshold = 0.2
    connecting_threshold = 0.08
    compute_halo_maps = true
    compute_var_to_feature_map = true
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
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./var_indices]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./ghost_regions]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./halos]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

# [Kernels]
#   [./gr0dot]
#     type = TimeDerivative
#     variable = gr0
#   [../]
#   [./gr0bulk]
#     type = ACGrGrPoly
#     v = 'gr1 gr2 gr3'
#     variable = gr0
#     mob_name = L
#   [../]
#   [./gr0interface]
#     type = ACInterface
#     variable = gr0
#     args = 'gr1 gr2 gr3'
#     kappa_name = kappa_op
#     mob_name = L
#     variable_L = true
#   [../]
#   [./gr1dot]
#     type = TimeDerivative
#     variable = gr1
#   [../]
#   [./gr1bulk]
#     type = ACGrGrPoly
#     v = 'gr0 gr2 gr3'
#     variable = gr1
#     mob_name = L
#   [../]
#   [./gr1interface]
#     type = ACInterface
#     variable = gr1
#     args = 'gr0 gr2 gr3'
#     kappa_name = kappa_op
#     variable_L = true
#     mob_name = L
#   [../]
#   [./gr2dot]
#     type = TimeDerivative
#     variable = gr2
#   [../]
#   [./gr2bulk]
#     type = ACGrGrPoly
#     v = 'gr0 gr1 gr3'
#     variable = gr2
#     mob_name = L
#   [../]
#   [./gr2interface]
#     type = ACInterface
#     args = 'gr0 gr1 gr3'
#     variable = gr2
#     kappa_name = kappa_op
#     variable_L = true
#     mob_name = L
#   [../]
#   [./gr3dot]
#     type = TimeDerivative
#     variable = gr3
#   [../]
#   [./gr3bulk]
#     type = ACGrGrPoly
#     v = 'gr0 gr1 gr2'
#     variable = gr3
#     mob_name = L
#   [../]
#   [./gr3interface]
#     type = ACInterface
#     args = 'gr0 gr1 gr2'
#     variable = gr3
#     kappa_name = kappa_op
#     variable_L = true
#     mob_name = L
#   [../]
# []

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
  [./unique_grains]
    type = FeatureFloodCountAux
    variable = unique_grains
    flood_counter = grain_tracker
    field_display = UNIQUE_REGION
    execute_on = 'initial timestep_end'
  [../]
  [./var_indices]
    type = FeatureFloodCountAux
    variable = var_indices
    flood_counter = grain_tracker
    field_display = VARIABLE_COLORING
    execute_on = 'initial timestep_end'
  [../]
  [./ghosted_entities]
    type = FeatureFloodCountAux
    variable = ghost_regions
    flood_counter = grain_tracker
    field_display = GHOSTED_ENTITIES
    execute_on = 'initial timestep_end'
  [../]
  [./halos]
    type = FeatureFloodCountAux
    variable = halos
    flood_counter = grain_tracker
    field_display = HALOS
    execute_on = 'initial timestep_end'
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
    args = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9 gr10 gr11 gr12 gr13'
    function = 50
                # '(L01*(gr1 + t)^2*(gr0 + t)^2 + L12*(gr0 + t)^2*(gr2 + t)^2 + L02*(gr3 + t)^2*(gr0 + t)^2 +
                #  L03*(gr4 + t)^2*(gr0 + t)^2 + L13*(gr0 + t)^2*(gr5 + t)^2 + L23*(gr0 + t)^2*(gr6 + t)^2 +
                #  L01*(gr7 + t)^2*(gr0 + t)^2 + L12*(gr0 + t)^2*(gr8 + t)^2 + L02*(gr0 + t)^2*(gr9 + t)^2 +
                #  L03*(gr0 + t)^2*(gr10 + t)^2 + L13*(gr0 + t)^2*(gr11 + t)^2 + L23*(gr0 + t)^2*(gr12 + t)^2 +
                #  L01*(gr0 + t)^2*(gr13 + t)^2 +
                #  L12*(gr1 + t)^2*(gr2 + t)^2 + L02*(gr1 + t)^2*(gr3 + t)^2 + L03*(gr1 + t)^2*(gr4 + t)^2 +
                #  L13*(gr1 + t)^2*(gr5 + t)^2 + L23*(gr1 + t)^2*(gr6 + t)^2 + L01*(gr1 + t)^2*(gr7 + t)^2 +
                #  L12*(gr1 + t)^2*(gr8 + t)^2 + L02*(gr1 + t)^2*(gr9 + t)^2 + L03*(gr1 + t)^2*(gr10 + t)^2 +
                #  L13*(gr1 + t)^2*(gr11 + t)^2 + L23*(gr1 + t)^2*(gr12 + t)^2 + L01*(gr1 + t)^2*(gr13 + t)^2 +
                #
                #  L12*(gr2 + t)^2*(gr3 + t)^2 + L02*(gr2 + t)^2*(gr4 + t)^2 + L03*(gr2 + t)^2*(gr5 + t)^2 +
                #  L01*(gr2 + t)^2*(gr6 + t)^2 + L12*(gr2 + t)^2*(gr7 + t)^2 + L02*(gr2 + t)^2*(gr8 + t)^2 +
                #  L03*(gr2 + t)^2*(gr9 + t)^2 + L13*(gr2 + t)^2*(gr10 + t)^2 + L23*(gr2 + t)^2*(gr11 + t)^2 +
                #  L01*(gr2 + t)^2*(gr12 + t)^2 + L12*(gr2 + t)^2*(gr13 + t)^2 +
                #  L02*(gr3 + t)^2*(gr4 + t)^2 + L03*(gr3 + t)^2*(gr5 + t)^2 + L13*(gr3 + t)^2*(gr6 + t)^2 +
                #  L01*(gr3 + t)^2*(gr7 + t)^2 + L12*(gr3 + t)^2*(gr8 + t)^2 + L02*(gr3 + t)^2*(gr9 + t)^2 +
                #  L03*(gr3 + t)^2*(gr10 + t)^2 + L13*(gr3 + t)^2*(gr11 + t)^2 + L23*(gr3 + t)^2*(gr12 + t)^2 +
                #  L01*(gr3 + t)^2*(gr13 + t)^2 +
                #  L03*(gr4 + t)^2*(gr5 + t)^2 + L13*(gr4 + t)^2*(gr6 + t)^2 + L01*(gr4 + t)^2*(gr7 + t)^2 +
                #  L12*(gr4 + t)^2*(gr8 + t)^2 + L02*(gr4 + t)^2*(gr9 + t)^2 + L03*(gr4 + t)^2*(gr10 + t)^2 +
                #  L13*(gr4 + t)^2*(gr11 + t)^2 + L23*(gr4 + t)^2*(gr12 + t)^2 + L01*(gr4 + t)^2*(gr13 + t)^2 +
                #
                #  L13*(gr5 + t)^2*(gr6 + t)^2 + L01*(gr5 + t)^2*(gr7 + t)^2 + L12*(gr5 + t)^2*(gr8 + t)^2 +
                #  L02*(gr5 + t)^2*(gr9 + t)^2 + L03*(gr5 + t)^2*(gr10 + t)^2 + L13*(gr5 + t)^2*(gr11 + t)^2 +
                #  L23*(gr5 + t)^2*(gr12 + t)^2 + L01*(gr5 + t)^2*(gr13 + t)^2 +
                #  L01*(gr6 + t)^2*(gr7 + t)^2 + L12*(gr6 + t)^2*(gr8 + t)^2 + L02*(gr6 + t)^2*(gr9 + t)^2 +
                #  L03*(gr6 + t)^2*(gr10 + t)^2 + L13*(gr6 + t)^2*(gr11 + t)^2 + L23*(gr6 + t)^2*(gr12 + t)^2 +
                #  L01*(gr6 + t)^2*(gr13 + t)^2 +
                #  L12*(gr7 + t)^2*(gr8 + t)^2 + L02*(gr7 + t)^2*(gr9 + t)^2 + L03*(gr7 + t)^2*(gr10 + t)^2 +
                #  L13*(gr7 + t)^2*(gr11 + t)^2 + L23*(gr7 + t)^2*(gr12 + t)^2 + L01*(gr7 + t)^2*(gr13 + t)^2 +
                #
                #  L02*(gr8 + t)^2*(gr9 + t)^2 + L03*(gr8 + t)^2*(gr10 + t)^2 + L13*(gr8 + t)^2*(gr11 + t)^2 +
                #  L23*(gr8 + t)^2*(gr12 + t)^2 + L01*(gr8 + t)^2*(gr13 + t)^2 +
                #  L03*(gr9 + t)^2*(gr10 + t)^2 + L13*(gr9 + t)^2*(gr11 + t)^2 + L23*(gr9 + t)^2*(gr12 + t)^2 +
                #  L01*(gr9 + t)^2*(gr13 + t)^2 + L13*(gr10 + t)^2*(gr11 + t)^2 + L23*(gr10 + t)^2*(gr12 + t)^2 +
                #  L01*(gr10 + t)^2*(gr13 + t)^2 + L23*(gr11 + t)^2*(gr12 + t)^2 + L01*(gr11 + t)^2*(gr13 + t)^2 +
                #  L01*(gr12 + t)^2*(gr13 + t)^2 )
                #  /
                #  ((gr1 + t)^2*(gr0 + t)^2 + (gr0 + t)^2*(gr2 + t)^2 + (gr3 + t)^2*(gr0 + t)^2 +
                #   (gr4 + t)^2*(gr0 + t)^2 + (gr0 + t)^2*(gr5 + t)^2 + (gr0 + t)^2*(gr6 + t)^2 +
                #   (gr7 + t)^2*(gr0 + t)^2 + (gr0 + t)^2*(gr8 + t)^2 + (gr0 + t)^2*(gr9 + t)^2 +
                #   (gr0 + t)^2*(gr10 + t)^2 + (gr0 + t)^2*(gr11 + t)^2 + (gr0 + t)^2*(gr12 + t)^2 +
                #   (gr0 + t)^2*(gr13 + t)^2 +
                #   (gr1 + t)^2*(gr2 + t)^2 + (gr1 + t)^2*(gr3 + t)^2 + (gr1 + t)^2*(gr4 + t)^2 +
                #   (gr1 + t)^2*(gr5 + t)^2 + (gr1 + t)^2*(gr6 + t)^2 + (gr1 + t)^2*(gr7 + t)^2 +
                #   (gr1 + t)^2*(gr8 + t)^2 + (gr1 + t)^2*(gr9 + t)^2 + (gr1 + t)^2*(gr10 + t)^2 +
                #   (gr1 + t)^2*(gr11 + t)^2 + (gr1 + t)^2*(gr12 + t)^2 + (gr1 + t)^2*(gr13 + t)^2 +
                #
                #   (gr2 + t)^2*(gr3 + t)^2 + (gr2 + t)^2*(gr4 + t)^2 + (gr2 + t)^2*(gr5 + t)^2 +
                #   (gr2 + t)^2*(gr6 + t)^2 + (gr2 + t)^2*(gr7 + t)^2 + (gr2 + t)^2*(gr8 + t)^2 +
                #   (gr2 + t)^2*(gr9 + t)^2 + (gr2 + t)^2*(gr10 + t)^2 + (gr2 + t)^2*(gr11 + t)^2 +
                #   (gr2 + t)^2*(gr12 + t)^2 + (gr2 + t)^2*(gr13 + t)^2 +
                #   (gr3 + t)^2*(gr4 + t)^2 + (gr3 + t)^2*(gr5 + t)^2 + (gr3 + t)^2*(gr6 + t)^2 +
                #   (gr3 + t)^2*(gr7 + t)^2 + (gr3 + t)^2*(gr8 + t)^2 + (gr3 + t)^2*(gr9 + t)^2 +
                #   (gr3 + t)^2*(gr10 + t)^2 + (gr3 + t)^2*(gr11 + t)^2 + (gr3 + t)^2*(gr12 + t)^2 +
                #   (gr3 + t)^2*(gr13 + t)^2 +
                #   (gr4 + t)^2*(gr5 + t)^2 + (gr4 + t)^2*(gr6 + t)^2 + (gr4 + t)^2*(gr7 + t)^2 +
                #   (gr4 + t)^2*(gr8 + t)^2 + (gr4 + t)^2*(gr9 + t)^2 + (gr4 + t)^2*(gr10 + t)^2 +
                #   (gr4 + t)^2*(gr11 + t)^2 + (gr4 + t)^2*(gr12 + t)^2 + (gr4 + t)^2*(gr13 + t)^2 +
                #
                #   (gr5 + t)^2*(gr6 + t)^2 + (gr5 + t)^2*(gr7 + t)^2 + (gr5 + t)^2*(gr8 + t)^2 +
                #   (gr5 + t)^2*(gr9 + t)^2 + (gr5 + t)^2*(gr10 + t)^2 + (gr5 + t)^2*(gr11 + t)^2 +
                #   (gr5 + t)^2*(gr12 + t)^2 + (gr5 + t)^2*(gr13 + t)^2 +
                #   (gr6 + t)^2*(gr7 + t)^2 + (gr6 + t)^2*(gr8 + t)^2 + (gr6 + t)^2*(gr9 + t)^2 +
                #   (gr6 + t)^2*(gr10 + t)^2 + (gr6 + t)^2*(gr11 + t)^2 + (gr6 + t)^2*(gr12 + t)^2 +
                #   (gr6 + t)^2*(gr13 + t)^2 +
                #   (gr7 + t)^2*(gr8 + t)^2 + (gr7 + t)^2*(gr9 + t)^2 + (gr7 + t)^2*(gr10 + t)^2 +
                #   (gr7 + t)^2*(gr11 + t)^2 + (gr7 + t)^2*(gr12 + t)^2 + (gr7 + t)^2*(gr13 + t)^2 +
                #
                #   (gr8 + t)^2*(gr9 + t)^2 + (gr8 + t)^2*(gr10 + t)^2 + (gr8 + t)^2*(gr11 + t)^2 +
                #   (gr8 + t)^2*(gr12 + t)^2 + (gr8 + t)^2*(gr13 + t)^2 +
                #   (gr9 + t)^2*(gr10 + t)^2 + (gr9 + t)^2*(gr11 + t)^2 + (gr9 + t)^2*(gr12 + t)^2 +
                #   (gr9 + t)^2*(gr13 + t)^2 + (gr10 + t)^2*(gr11 + t)^2 + (gr10 + t)^2*(gr12 + t)^2 +
                #   (gr10 + t)^2*(gr13 + t)^2 + (gr11 + t)^2*(gr12 + t)^2 + (gr11 + t)^2*(gr13 + t)^2 +
                #   (gr12 + t)^2*(gr13 + t)^2 )'

    constant_names =       'L01   L02  L03  L12  L13  L23  t'
    constant_expressions = '100.0 20.0 80.0 60.5 5.0 35.5 5e-2'
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
  # [./gr0_area]
  #   type = ElementIntegralVariablePostprocessor
  #   variable = gr0
  # [../]
  # [./gr1_area]
  #   type = ElementIntegralVariablePostprocessor
  #   variable = gr1
  # [../]
  # [./gr2_area]
  #   type = ElementIntegralVariablePostprocessor
  #   variable = gr2
  # [../]
  # [./gr3_area]
  #   type = ElementIntegralVariablePostprocessor
  #   variable = gr3
  # [../]
  [./walltime]
    type = PerformanceData
    event = ALIVE
    execute_on = TIMESTEP_END
  [../]
[]

[VectorPostprocessors]
  [./grain_area]
    type = FeatureVolumeVectorPostprocessor
    flood_counter = grain_tracker
    execute_on = 'timestep_end'
    # single_feature_per_element = true
  [../]
[../]

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
    dt = 0.003
    growth_factor = 1.2
    optimal_iterations = 8
  [../]
[]

[Outputs]
  # [./pgraph]
  #   type = PerfGraphOutput
  #   level = 1
  #   execute_on = 'initial final'
  #   heaviest_branch = true
  #   heaviest_sections = 9
  # [../]

  execute_on = 'timestep_end'
  exodus = true
  csv = true
[]
