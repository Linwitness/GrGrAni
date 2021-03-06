[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 40
  ny = 40
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
  [./gr0dot]
    type = TimeDerivative
    variable = gr0
  [../]
  [./gr0bulk]
    type = ACGrGrPoly
    v = 'gr1 gr2 gr3'
    variable = gr0
    mob_name = L
  [../]
  [./gr0interface]
    type = ACInterface
    variable = gr0
    args = 'gr1 gr2 gr3'
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
    v = 'gr0 gr2 gr3'
    variable = gr1
    mob_name = L
  [../]
  [./gr1interface]
    type = ACInterface
    variable = gr1
    args = 'gr0 gr2 gr3'
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
    v = 'gr0 gr1 gr3'
    variable = gr2
    mob_name = L
  [../]
  [./gr2interface]
    type = ACInterface
    args = 'gr0 gr1 gr3'
    variable = gr2
    kappa_name = kappa_op
    variable_L = true
    mob_name = L
  [../]
  [./gr3dot]
    type = TimeDerivative
    variable = gr3
  [../]
  [./gr3bulk]
    type = ACGrGrPoly
    v = 'gr0 gr1 gr2'
    variable = gr3
    mob_name = L
  [../]
  [./gr3interface]
    type = ACInterface
    args = 'gr0 gr1 gr2'
    variable = gr3
    kappa_name = kappa_op
    variable_L = true
    mob_name = L
  [../]
[]

# [Kernels]
#   [./PolycrystalKernel]
#   [../]
# []

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
    args = 'gr0 gr1 gr2 gr3'
    function = '(L01*(gr1 + t)^2*(gr0 + t)^2 + L12*(gr1 + t)^2*(gr2 + t)^2 + L02*(gr2 + t)^2*(gr0 + t)^2 +
                 L03*(gr3 + t)^2*(gr0 + t)^2 + L13*(gr1 + t)^2*(gr3 + t)^2 + L23*(gr2 + t)^2*(gr3 + t)^2)/
                ((gr0 + t)^2*(gr1 + t)^2 + (gr1 + t)^2*(gr2 + t)^2 + (gr2 + t)^2*(gr0 + t)^2 +
                 (gr3 + t)^2*(gr0 + t)^2 + (gr1 + t)^2*(gr3 + t)^2 + (gr2 + t)^2*(gr3 + t)^2)'

    # function = 'l:=(L01*gr1^2*gr0^2 + L02*gr1^2*gr2^2 + L03*gr2^2*gr3^2 + L12*gr3^2*gr0^2 + L13*gr2^2*gr0^2 + L23*gr1^2*gr3^2)/
    #                (gr1^2*gr0^2 + gr1^2*gr2^2 + gr2^2*gr3^2 + gr3^2*gr0^2 + gr2^2*gr0^2 + gr1^2*gr3^2);
    #             l0:=(L01*gr1^2*t^2 + L02*gr1^2*gr2^2 + L03*gr2^2*gr3^2 + L12*gr3^2*t^2 + L13*gr2^2*t^2 + L23*gr1^2*gr3^2)/
    #                 (gr1^2*t^2 + gr1^2*gr2^2 + gr2^2*gr3^2 + gr3^2*t^2 + gr2^2*t^2 + gr1^2*gr3^2);
    #             l1:=(L01*t^2*gr0^2 + L02*t^2*gr2^2 + L03*gr2^2*gr3^2 + L12*gr3^2*gr0^2 + L13*gr2^2*gr0^2 + L23*t^2*gr3^2)/
    #                 (t^2*gr0^2 + t^2*gr2^2 + gr2^2*gr3^2 + gr3^2*gr0^2 + gr2^2*gr0^2 + t^2*gr3^2);
    #             l2:=(L01*gr1^2*gr0^2 + L02*gr1^2*t^2 + L03*t^2*gr3^2 + L12*gr3^2*gr0^2 + L13*t^2*gr0^2 + L23*gr1^2*gr3^2)/
    #                 (gr1^2*gr0^2 + gr1^2*t^2 + t^2*gr3^2 + gr3^2*gr0^2 + t^2*gr0^2 + gr1^2*gr3^2);
    #             l3:=(L01*gr1^2*gr0^2 + L02*gr1^2*gr2^2 + L03*gr2^2*t^2 + L12*t^2*gr0^2 + L13*gr2^2*gr0^2 + L23*gr1^2*t^2)/
    #                 (gr1^2*gr0^2 + gr1^2*gr2^2 + gr2^2*t^2 + t^2*gr0^2 + gr2^2*gr0^2 + gr1^2*t^2);
    #             l01:=(L01*t^2*t^2 + L02*t^2*gr2^2 + L03*gr2^2*gr3^2 + L12*gr3^2*t^2 + L13*gr2^2*t^2 + L23*t^2*gr3^2)/
    #                  (t^2*t^2 + t^2*gr2^2 + gr2^2*gr3^2 + gr3^2*t^2 + gr2^2*t^2 + t^2*gr3^2);
    #             l02:=(L01*gr1^2*t^2 + L02*gr1^2*t^2 + L03*t^2*gr3^2 + L12*gr3^2*t^2 + L13*t^2*t^2 + L23*gr1^2*gr3^2)/
    #                  (gr1^2*t^2 + gr1^2*t^2 + t^2*gr3^2 + gr3^2*t^2 + t^2*t^2 + gr1^2*gr3^2);
    #             l03:=(L01*gr1^2*t^2 + L02*gr1^2*gr2^2 + L03*gr2^2*t^2 + L12*t^2*t^2 + L13*gr2^2*t^2 + L23*gr1^2*t^2)/
    #                  (gr1^2*t^2 + gr1^2*gr2^2 + gr2^2*t^2 + t^2*t^2 + gr2^2*t^2 + gr1^2*t^2);
    #             l12:=(L01*t^2*gr0^2 + L02*t^2*t^2 + L03*t^2*gr3^2 + L12*gr3^2*gr0^2 + L13*t^2*gr0^2 + L23*t^2*gr3^2)/
    #                  (t^2*gr0^2 + t^2*t^2 + t^2*gr3^2 + gr3^2*gr0^2 + t^2*gr0^2 + t^2*gr3^2);
    #             l23:=(L01*gr1^2*gr0^2 + L02*gr1^2*t^2 + L03*t^2*t^2 + L12*t^2*gr0^2 + L13*t^2*gr0^2 + L23*gr1^2*t^2)/
    #                  (gr1^2*gr0^2 + gr1^2*t^2 + t^2*t^2 + t^2*gr0^2 + t^2*gr0^2 + gr1^2*t^2);
    #             l13:=(L01*t^2*gr0^2 + L02*t^2*gr2^2 + L03*gr2^2*t^2 + L12*t^2*gr0^2 + L13*gr2^2*gr0^2 + L23*t^2*t^2)/
    #                  (t^2*gr0^2 + t^2*gr2^2 + gr2^2*t^2 + t^2*gr0^2 + gr2^2*gr0^2 + t^2*t^2);
    #             l123:=(L01*t^2*gr0^2 + L02*t^2*t^2 + L03*t^2*t^2 + L12*t^2*gr0^2 + L13*t^2*gr0^2 + L23*t^2*t^2)/
    #                   (t^2*gr0^2 + t^2*t^2 + t^2*t^2 + t^2*gr0^2 + t^2*gr0^2 + t^2*t^2);
    #             l023:=(L01*gr1^2*t^2 + L02*gr1^2*t^2 + L03*t^2*t^2 + L12*t^2*t^2 + L13*t^2*t^2 + L23*gr1^2*t^2)/
    #                   (gr1^2*t^2 + gr1^2*t^2 + t^2*t^2 + t^2*t^2 + t^2*t^2 + gr1^2*t^2);
    #             l013:=(L01*t^2*t^2 + L02*t^2*gr2^2 + L03*gr2^2*t^2 + L12*t^2*t^2 + L13*gr2^2*t^2 + L23*t^2*t^2)/
    #                   (t^2*t^2 + t^2*gr2^2 + gr2^2*t^2 + t^2*t^2 + gr2^2*t^2 + t^2*t^2);
    #             l012:=(L01*t^2*t^2 + L02*t^2*t^2 + L03*t^2*gr3^2 + L12*gr3^2*t^2 + L13*t^2*t^2 + L23*t^2*gr3^2)/
    #                   (t^2*t^2 + t^2*t^2 + t^2*gr3^2 + gr3^2*t^2 + t^2*t^2 + t^2*gr3^2);
    #             l0123:=(L01*t^2*t^2 + L02*t^2*t^2 + L03*t^2*t^2 + L12*t^2*t^2 + L13*t^2*t^2 + L23*t^2*t^2)/
    #                    (t^2*t^2 + t^2*t^2 + t^2*t^2 + t^2*t^2 + t^2*t^2 + t^2*t^2);
    #             if(gr0<t, if(gr1<t, if(gr2<t, if(gr3<t, l0123, l012),
    #                                           if(gr3<t, l013, l01)),
    #                                 if(gr2<t, if(gr3<t, l023, l02),
    #                                           if(gr3<t, l03, l0))),
    #                       if(gr1<t, if(gr2<t, if(gr3<t, l123, l12),
    #                                           if(gr3<t, l13, l1)),
    #                                 if(gr2<t, if(gr3<t, l23, l2),
    #                                           if(gr3<t, l3, l))) )'
    constant_names =       'L01  L02  L03  L12  L13  L23  t'
    constant_expressions = '28.0 20.0 41.0 60.5 18.0 35.5 1e-3'
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
    max_h_level = 2
    refine_fraction = 0.7
  [../]
  [./TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.8
    dt = 1
    growth_factor = 1.2
    optimal_iterations = 8
  [../]
[]

[Outputs]
  [./pgraph]
    type = PerfGraphOutput
    level = 1
    execute_on = 'initial final'
    heaviest_branch = true
    heaviest_sections = 9
  [../]
  execute_on = 'timestep_end'
  exodus = true
  csv = true
[]
