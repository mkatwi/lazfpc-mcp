unit mcputils.build.Tests;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, fpcunit, testregistry;

type
  TBuildTests = class(TTestCase)
  private
    FDir: string;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure RunLazBuild_ConsoleProject_BuildsExecutable;
    procedure RunLazBuild_BrokenProject_ReturnsFalseWithOutput;
    procedure CopyEnvironmentWithPath_Always_HasExactlyOneNewPath;
  end;

implementation

uses
  Classes, mcputils.pathconfig, mcputils.build, lazfpc.Tests.Support;

procedure TBuildTests.SetUp;
begin
  FDir := TTestProjects.NewTempDir;
end;

procedure TBuildTests.TearDown;
begin
  TTestProjects.RemoveDir(FDir);
end;

procedure TBuildTests.RunLazBuild_ConsoleProject_BuildsExecutable;
var
  Project, Output, StdErr: string;
  IsBuilt: Boolean;
begin
  Project := TTestProjects.CreateConsoleProject(FDir, 'Hello');

  IsBuilt := RunLazBuild(GetLazBuildPath, GetFPCPath, GetFPCBinDir, Project, '', '', Output, StdErr);

  AssertTrue('lazbuild failed: ' + Output + StdErr, IsBuilt);
  AssertTrue('Hello.exe missing', FileExists(IncludeTrailingPathDelimiter(FDir) + 'Hello.exe'));
end;

procedure TBuildTests.RunLazBuild_BrokenProject_ReturnsFalseWithOutput;
var
  Project, Output, StdErr: string;
  IsBuilt: Boolean;
  Source: TStringList;
begin
  Project := TTestProjects.CreateConsoleProject(FDir, 'Broken');
  Source := TStringList.Create;
  try
    Source.Text := 'program Broken; begin UnknownIdentifier; end.';
    Source.SaveToFile(IncludeTrailingPathDelimiter(FDir) + 'Broken.lpr');
  finally
    Source.Free;
  end;

  IsBuilt := RunLazBuild(GetLazBuildPath, GetFPCPath, GetFPCBinDir, Project, '', '', Output, StdErr);

  AssertFalse('a broken project must not build', IsBuilt);
  AssertTrue('compiler error expected in output', Pos('UnknownIdentifier', Output + StdErr) > 0);
end;

procedure TBuildTests.CopyEnvironmentWithPath_Always_HasExactlyOneNewPath;
const
  NewPath = 'C:\fpc;C:\Windows';
var
  Environment: TStringList;
  Entry: string;
  PathCount: Integer;
begin
  Environment := TStringList.Create;
  try
    CopyEnvironmentWithPath(Environment, NewPath);

    PathCount := 0;
    for Entry in Environment do
    begin
      if SameText(Copy(Entry, 1, 5), 'PATH=') then
        Inc(PathCount);
    end;
    AssertEquals('PATH entries', 1, PathCount);
    AssertEquals('PATH=' + NewPath, Environment[Environment.Count - 1]);
    AssertTrue('other variables are kept', Environment.Count > 1);
  finally
    Environment.Free;
  end;
end;

initialization
  RegisterTest(TBuildTests);

end.
