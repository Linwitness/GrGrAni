#include "grain_growthApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
grain_growthApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  // Do not use legacy DirichletBC, that is, set DirichletBC default for preset = true
  params.set<bool>("use_legacy_dirichlet_bc") = false;

  return params;
}

grain_growthApp::grain_growthApp(InputParameters parameters) : MooseApp(parameters)
{
  grain_growthApp::registerAll(_factory, _action_factory, _syntax);
}

grain_growthApp::~grain_growthApp() {}

void
grain_growthApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAll(f, af, s);
  Registry::registerObjectsTo(f, {"grain_growthApp"});
  Registry::registerActionsTo(af, {"grain_growthApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
grain_growthApp::registerApps()
{
  registerApp(grain_growthApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
grain_growthApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  grain_growthApp::registerAll(f, af, s);
}
extern "C" void
grain_growthApp__registerApps()
{
  grain_growthApp::registerApps();
}
