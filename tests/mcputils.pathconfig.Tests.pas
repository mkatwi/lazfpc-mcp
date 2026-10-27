unit mcputils.pathconfig.Tests;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, fpcunit, testregistry;

type
  { Expects the Windows layout of a standard Lazarus install in C:\lazarus,
    with none of the LAZFPC_* override variables set. }
  TPathConfigTests = class(TTestCase)
  published
    procedure GetLazBuildPath_NoOverride_IsLazarusInstall;
    procedure GetFPCPath_NoOverride_IsBundledCompiler;
    procedure GetFPCBinDir_Always_IsFolderOfCompiler;
    procedure GetEnvironmentPath_Always_StartsWithCompilerFolder;
    procedure DefaultPaths_OnThisMachine_Exist;
    procedure GetFPCSourceDir_NoOverride_IsBundledSources;
    procedure ChooseSetting_WithOverride_ReturnsTrimmedOverride;
    procedure ChooseSetting_BlankOverride_ReturnsDefault;
    procedure PrependToSearchPath_BothSet_JoinsWithSeparator;
    procedure PrependToSearchPath_EmptySearchPath_ReturnsDir;
    procedure PrependToSearchPath_EmptyDir_ReturnsSearchPathUnchanged;
  end;

implementation

uses
  mcputils.pathconfig;

const
  LazBuild = 'C:\lazarus\lazbuild.exe';
  Fpc = 'C:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe';
  FpcSource = 'C:\lazarus\fpc\3.2.2\source';

procedure TPathConfigTests.GetLazBuildPath_NoOverride_IsLazarusInstall;
begin
  AssertEquals(LazBuild, GetLazBuildPath);
end;

procedure TPathConfigTests.GetFPCPath_NoOverride_IsBundledCompiler;
begin
  AssertEquals(Fpc, GetFPCPath);
end;

procedure TPathConfigTests.GetFPCBinDir_Always_IsFolderOfCompiler;
begin
  AssertEquals(ExtractFileDir(GetFPCPath), GetFPCBinDir);
end;

procedure TPathConfigTests.GetEnvironmentPath_Always_StartsWithCompilerFolder;
var
  Expected: string;
begin
  Expected := GetFPCBinDir + PathSeparator;
  AssertEquals(Expected, Copy(GetEnvironmentPath, 1, Length(Expected)));
end;

procedure TPathConfigTests.DefaultPaths_OnThisMachine_Exist;
begin
  AssertTrue('lazbuild not found: ' + GetLazBuildPath, FileExists(GetLazBuildPath));
  AssertTrue('fpc not found: ' + GetFPCPath, FileExists(GetFPCPath));
  AssertTrue('FPC sources not found: ' + GetFPCSourceDir, DirectoryExists(GetFPCSourceDir));
end;

procedure TPathConfigTests.GetFPCSourceDir_NoOverride_IsBundledSources;
begin
  AssertEquals(FpcSource, GetFPCSourceDir);
end;

procedure TPathConfigTests.ChooseSetting_WithOverride_ReturnsTrimmedOverride;
begin
  AssertEquals('D:\fpc\fpc.exe', ChooseSetting('  D:\fpc\fpc.exe ', Fpc));
end;

procedure TPathConfigTests.ChooseSetting_BlankOverride_ReturnsDefault;
begin
  AssertEquals(Fpc, ChooseSetting('   ', Fpc));
end;

procedure TPathConfigTests.PrependToSearchPath_BothSet_JoinsWithSeparator;
begin
  AssertEquals('C:\fpc' + PathSeparator + 'C:\Windows', PrependToSearchPath('C:\fpc', 'C:\Windows'));
end;

procedure TPathConfigTests.PrependToSearchPath_EmptySearchPath_ReturnsDir;
begin
  AssertEquals('C:\fpc', PrependToSearchPath('C:\fpc', ''));
end;

procedure TPathConfigTests.PrependToSearchPath_EmptyDir_ReturnsSearchPathUnchanged;
begin
  AssertEquals('C:\Windows', PrependToSearchPath('', 'C:\Windows'));
end;

initialization
  RegisterTest(TPathConfigTests);

end.
