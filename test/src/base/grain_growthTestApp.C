//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "grain_growthTestApp.h"
#include "grain_growthApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

InputParameters
grain_growthTestApp::validParams()
{
  InputParameters params = grain_growthApp::validParams();
  return params;
}

grain_growthTestApp::grain_growthTestApp(InputParameters parameters) : MooseApp(parameters)
{
  grain_growthTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

grain_growthTestApp::~grain_growthTestApp() {}

void
grain_growthTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  grain_growthApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"grain_growthTestApp"});
    Registry::registerActionsTo(af, {"grain_growthTestApp"});
  }
}

void
grain_growthTestApp::registerApps()
{
  registerApp(grain_growthApp);
  registerApp(grain_growthTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
grain_growthTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  grain_growthTestApp::registerAll(f, af, s);
}
extern "C" void
grain_growthTestApp__registerApps()
{
  grain_growthTestApp::registerApps();
}
