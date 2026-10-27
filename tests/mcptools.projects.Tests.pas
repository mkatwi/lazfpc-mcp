unit mcptools.projects.Tests;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, fpcunit, testregistry;

type
  TListProjectsToolTests = class(TTestCase)
  private
    FDir: string;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure DoExecute_NestedProject_ReportsWindowsPathAndMainSource;
  end;

implementation

uses
  fpjson, mcptools.projects, lazfpc.Tests.Support;

procedure TListProjectsToolTests.SetUp;
begin
  FDir := TTestProjects.NewTempDir;
end;

procedure TListProjectsToolTests.TearDown;
begin
  TTestProjects.RemoveDir(FDir);
end;

procedure TListProjectsToolTests.DoExecute_NestedProject_ReportsWindowsPathAndMainSource;
var
  Tool: TListProjectsTool;
  Input, Output, Project: TJSONObject;
  Expected: string;
begin
  TTestProjects.CreateConsoleProject(IncludeTrailingPathDelimiter(FDir) + 'sub', 'Demo');
  Expected := IncludeTrailingPathDelimiter(FDir) + 'sub' + PathDelim + 'Demo.lpi';
  Tool := TListProjectsTool.create('list_projects', 'test');
  Input := TJSONObject.Create(['directory_path', FDir, 'recursive', True]);
  Output := TJSONObject.Create;
  try
    Tool.DoExecute(Input, Output);

    Project := nil;
    if Output.Arrays['projects'].Count > 0 then
      Project := Output.Arrays['projects'].Objects[0];
    AssertNotNull('no project found', Project);
    AssertEquals(Expected, Project.Get('path', ''));
    AssertEquals('Demo.lpr', Project.Get('main_source', ''));
  finally
    Output.Free;
    Input.Free;
    Tool.Free;
  end;
end;

initialization
  RegisterTest(TListProjectsToolTests);

end.
