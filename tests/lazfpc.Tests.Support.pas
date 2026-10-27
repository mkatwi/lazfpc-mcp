unit lazfpc.Tests.Support;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  { Creates small throw-away Lazarus projects in a temporary folder. }
  TTestProjects = class
  private
    class procedure WriteText(const FileName: string; const Lines: array of string); static;
    class procedure WriteLpi(const Dir: string; const Name: string); static;
  public
    class function NewTempDir: string; static;
    class procedure RemoveDir(const Dir: string); static;
    class function CreateConsoleProject(const Dir: string; const Name: string): string; static;
    class function CreateFpcUnitProject(const Dir: string; const Name: string): string; static;
  end;

implementation

const
  TempDirFormat = 'lazfpc-tests-%d-%d';

class procedure TTestProjects.WriteText(const FileName: string; const Lines: array of string);
var
  Text: TStringList;
  Line: string;
begin
  Text := TStringList.Create;
  try
    for Line in Lines do
      Text.Add(Line);
    Text.SaveToFile(FileName);
  finally
    Text.Free;
  end;
end;

class procedure TTestProjects.WriteLpi(const Dir: string; const Name: string);
begin
  WriteText(IncludeTrailingPathDelimiter(Dir) + Name + '.lpi', [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<CONFIG>',
    '  <ProjectOptions>',
    '    <Version Value="12"/>',
    '    <General>',
    '      <Flags>',
    '        <MainUnitHasCreateFormStatements Value="False"/>',
    '        <MainUnitHasTitleStatement Value="False"/>',
    '        <MainUnitHasScaledStatement Value="False"/>',
    '      </Flags>',
    '      <SessionStorage Value="InProjectDir"/>',
    '      <Title Value="' + Name + '"/>',
    '    </General>',
    '    <BuildModes>',
    '      <Item Name="Default" Default="True"/>',
    '    </BuildModes>',
    '    <Units>',
    '      <Unit>',
    '        <Filename Value="' + Name + '.lpr"/>',
    '        <IsPartOfProject Value="True"/>',
    '      </Unit>',
    '    </Units>',
    '  </ProjectOptions>',
    '  <CompilerOptions>',
    '    <Version Value="11"/>',
    '    <Target>',
    '      <Filename Value="' + Name + '"/>',
    '    </Target>',
    '    <SearchPaths>',
    '      <UnitOutputDirectory Value="lib\$(TargetCPU)-$(TargetOS)"/>',
    '    </SearchPaths>',
    '  </CompilerOptions>',
    '</CONFIG>']);
end;

class function TTestProjects.NewTempDir: string;
begin
  Result := IncludeTrailingPathDelimiter(GetTempDir(False)) +
            Format(TempDirFormat, [GetProcessID, Random(MaxInt)]);
  ForceDirectories(Result);
end;

class procedure TTestProjects.RemoveDir(const Dir: string);
var
  Search: TSearchRec;
  Path: string;
begin
  if FindFirst(IncludeTrailingPathDelimiter(Dir) + '*', faAnyFile, Search) = 0 then
  begin
    try
      repeat
        if (Search.Name = '.') or (Search.Name = '..') then
          Continue;
        Path := IncludeTrailingPathDelimiter(Dir) + Search.Name;
        if (Search.Attr and faDirectory) <> 0 then
          RemoveDir(Path)
        else
          DeleteFile(Path);
      until FindNext(Search) <> 0;
    finally
      FindClose(Search);
    end;
  end;
  SysUtils.RemoveDir(Dir);
end;

class function TTestProjects.CreateConsoleProject(const Dir: string; const Name: string): string;
begin
  ForceDirectories(Dir);
  WriteLpi(Dir, Name);
  WriteText(IncludeTrailingPathDelimiter(Dir) + Name + '.lpr', [
    'program ' + Name + ';',
    'begin',
    '  Writeln(''hello'');',
    'end.']);
  Result := IncludeTrailingPathDelimiter(Dir) + Name + '.lpi';
end;

class function TTestProjects.CreateFpcUnitProject(const Dir: string; const Name: string): string;
begin
  ForceDirectories(Dir);
  WriteLpi(Dir, Name);
  WriteText(IncludeTrailingPathDelimiter(Dir) + Name + '.lpr', [
    'program ' + Name + ';',
    '{$mode objfpc}{$H+}',
    'uses',
    '  Classes, consoletestrunner, fpcunit, testregistry;',
    'type',
    '  TSampleTests = class(TTestCase)',
    '  published',
    '    procedure OnePlusOne_IsTwo;',
    '  end;',
    'procedure TSampleTests.OnePlusOne_IsTwo;',
    'begin',
    '  AssertEquals(2, 1 + 1);',
    'end;',
    'var',
    '  App: TTestRunner;',
    'begin',
    '  RegisterTest(TSampleTests);',
    '  App := TTestRunner.Create(nil);',
    '  try',
    '    App.Initialize;',
    '    App.Run;',
    '  finally',
    '    App.Free;',
    '  end;',
    'end.']);
  Result := IncludeTrailingPathDelimiter(Dir) + Name + '.lpi';
end;

end.
