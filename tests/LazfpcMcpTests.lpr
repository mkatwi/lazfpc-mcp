program LazfpcMcpTests;

{$mode objfpc}{$H+}

// Regression runner (fpcunit, console) for the Windows support of lazfpc-mcp.
// Exit code: 0 = all passed, non-zero = failure and/or error.

uses
  Classes, consoletestrunner,
  lazfpc.Tests.Support,
  mcputils.pathconfig.Tests,
  mcputils.build.Tests,
  mcptools.projects.Tests,
  mcptools.docs.Tests,
  mcptools.tests.Tests;

var
  App: TTestRunner;
begin
  DefaultRunAllTests := True;
  DefaultFormat := fPlain;
  App := TTestRunner.Create(nil);
  try
    App.Initialize;
    App.Title := 'lazfpc-mcp regression tests';
    App.Run;
  finally
    App.Free;
  end;
end.
