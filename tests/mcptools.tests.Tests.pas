unit mcptools.tests.Tests;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, fpcunit, testregistry;

type
  TRunTestsToolTests = class(TTestCase)
  private
    FDir: string;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure DoExecute_FpcUnitProject_BuildsAndRunsExe;
  end;

implementation

uses
  fpjson, mcptools.tests, lazfpc.Tests.Support;

procedure TRunTestsToolTests.SetUp;
begin
  FDir := TTestProjects.NewTempDir;
end;

procedure TRunTestsToolTests.TearDown;
begin
  TTestProjects.RemoveDir(FDir);
end;

procedure TRunTestsToolTests.DoExecute_FpcUnitProject_BuildsAndRunsExe;
var
  Tool: TRunTestsTool;
  Input, Output: TJSONObject;
  Project, ExePath: string;
begin
  Project := TTestProjects.CreateFpcUnitProject(FDir, 'Sample');
  Tool := TRunTestsTool.create('run_fpcunit_tests', 'test');
  Input := TJSONObject.Create(['test_project_path', Project]);
  Output := TJSONObject.Create;
  try
    Tool.DoExecute(Input, Output);

    AssertTrue('build failed: ' + Output.Get('output', ''), Output.Get('build_success', False));
    ExePath := Output.Get('executable_path', '');
    AssertEquals(ChangeFileExt(Project, '.exe'), ExePath);
    AssertTrue('test run reported failures: ' + Output.Get('output', ''), Output.Get('success', False));
  finally
    Output.Free;
    Input.Free;
    Tool.Free;
  end;
end;

initialization
  RegisterTest(TRunTestsToolTests);

end.
