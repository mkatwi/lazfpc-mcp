unit mcptools.docs.Tests;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, fpcunit, testregistry;

type
  { Searches the FPC sources that ship with the Lazarus install. }
  TSearchFPCHelpToolTests = class(TTestCase)
  published
    procedure DoExecute_KnownRtlIdentifier_FindsMatches;
  end;

implementation

uses
  fpjson, mcptools.docs;

procedure TSearchFPCHelpToolTests.DoExecute_KnownRtlIdentifier_FindsMatches;
var
  Tool: TSearchFPCHelpTool;
  Input, Output: TJSONObject;
begin
  Tool := TSearchFPCHelpTool.create('search_fpc_help', 'test');
  Input := TJSONObject.Create(['query', 'IntToStr', 'max_results', 3]);
  Output := TJSONObject.Create;
  try
    Tool.DoExecute(Input, Output);

    AssertTrue('no source files scanned', Output.Get('files_scanned', 0) > 0);
    AssertTrue('no matches for IntToStr', Output.Get('total_matches', 0) > 0);
  finally
    Output.Free;
    Input.Free;
    Tool.Free;
  end;
end;

initialization
  RegisterTest(TSearchFPCHelpToolTests);

end.
