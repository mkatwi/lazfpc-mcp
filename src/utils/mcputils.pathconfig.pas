unit mcputils.pathconfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  // Environment variables that override the default tool locations.
  LazBuildEnvVar = 'LAZFPC_LAZBUILD';
  FPCEnvVar = 'LAZFPC_FPC';
  FPCSourceEnvVar = 'LAZFPC_FPC_SOURCE';

{$IFDEF MSWINDOWS}
  // A standard Lazarus install on Windows bundles FPC and its sources.
  DefaultLazBuildPath = 'C:\lazarus\lazbuild.exe';
  DefaultFPCPath = 'C:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe';
  DefaultFPCSourceDir = 'C:\lazarus\fpc\3.2.2\source';
{$ELSE}
  DefaultWorkspaceRoot = '/Users/worajedt/Lazarus';
  DefaultLazBuildPath = DefaultWorkspaceRoot + '/lazarus/lazbuild';
  DefaultFPCPath = DefaultWorkspaceRoot + '/fpc/bin/fpc';
  DefaultFPCSourceDir = DefaultWorkspaceRoot + '/fpc-src';
{$ENDIF}

function ChooseSetting(const aOverride, aDefault: string): string;
function PrependToSearchPath(const aDir, aSearchPath: string): string;
function GetFPCPath: string;
function GetFPCVersion: string;
function GetLazBuildPath: string;
function GetFPCBinDir: string;
function GetFPCSourceDir: string;
function BuildFPCPath: string;
function GetEnvironmentPath: string;

implementation

uses
  Process;

function ChooseSetting(const aOverride, aDefault: string): string;
begin
  Result := Trim(aOverride);
  if Result = '' then
    Result := aDefault;
end;

function PrependToSearchPath(const aDir, aSearchPath: string): string;
begin
  if aDir = '' then
    Result := aSearchPath
  else if aSearchPath = '' then
    Result := aDir
  else
    Result := aDir + PathSeparator + aSearchPath;
end;

function GetFPCBinDir: string;
begin
  Result := ExtractFileDir(GetFPCPath);
end;

function GetFPCPath: string;
begin
  Result := ChooseSetting(GetEnvironmentVariable(FPCEnvVar), DefaultFPCPath);
end;

function GetLazBuildPath: string;
begin
  Result := ChooseSetting(GetEnvironmentVariable(LazBuildEnvVar), DefaultLazBuildPath);
end;

function GetFPCSourceDir: string;
begin
  Result := ChooseSetting(GetEnvironmentVariable(FPCSourceEnvVar), DefaultFPCSourceDir);
end;

function GetFPCVersion: string;
var
  lProc: TProcess;
  lStream: TMemoryStream;
  lBuf: string;
  lLine: string;
  lPos: Integer;
begin
  Result := '3.2.2';
  lProc := TProcess.Create(nil);
  lStream := TMemoryStream.Create;
  try
    lProc.Executable := GetFPCPath;
    lProc.Parameters.Add('-iV');
    lProc.Options := [poUsePipes, poNoConsole, poWaitOnExit];
    try
      lProc.Execute;
    except
      on E: Exception do
        Exit;
    end;
    while lProc.Output.NumBytesAvailable > 0 do
    begin
      SetLength(lBuf, lProc.Output.NumBytesAvailable);
      lProc.Output.Read(lBuf[1], Length(lBuf));
      lStream.Write(lBuf[1], Length(lBuf));
    end;
    if lStream.Size > 0 then
    begin
      SetLength(lLine, lStream.Size);
      lStream.Position := 0;
      lStream.Read(lLine[1], lStream.Size);
      lLine := Trim(lLine);
      lPos := Pos(#10, lLine);
      if lPos > 0 then
        lLine := Trim(Copy(lLine, 1, lPos - 1));
      if lLine <> '' then
        Result := lLine;
    end;
  finally
    lStream.Free;
    lProc.Free;
  end;
end;

// The unit directory of an FPC install with the Unix layout (lib/fpc/<version>).
// The Windows install keeps its units next to the compiler, so this is empty there.
function BuildFPCPath: string;
begin
{$IFDEF MSWINDOWS}
  Result := '';
{$ELSE}
  Result := ExtractFileDir(GetFPCBinDir) + '/lib/fpc/' + GetFPCVersion;
{$ENDIF}
end;

function GetEnvironmentPath: string;
begin
  Result := PrependToSearchPath(BuildFPCPath, GetEnvironmentVariable('PATH'));
  Result := PrependToSearchPath(GetFPCBinDir, Result);
end;

end.
