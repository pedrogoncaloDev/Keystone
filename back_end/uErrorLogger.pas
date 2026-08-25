unit uErrorLogger;

interface

uses
  System.SysUtils;

procedure LogError(const MethodName: string; const E: Exception); overload;
procedure LogError(const MethodName: string; const ErrorMessage: string); overload;

implementation

uses
  System.Classes, System.IOUtils, System.SyncObjs;

var
  GLogLock: TCriticalSection;

function LogFilePath: string;
var
  LogDir: string;
begin
  LogDir := TPath.Combine(ExtractFilePath(ParamStr(0)), 'logs');
  if not TDirectory.Exists(LogDir) then
    TDirectory.CreateDirectory(LogDir);
  Result := TPath.Combine(LogDir, FormatDateTime('yyyy-mm-dd', Now) + '.log');
end;

procedure LogError(const MethodName: string; const ErrorMessage: string);
var
  LogLine: string;
  Writer: TStreamWriter;
begin
  LogLine := Format('[%s] [%s] %s',
    [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now), MethodName, ErrorMessage]);

  GLogLock.Enter;
  try
    try
      Writer := TStreamWriter.Create(LogFilePath, True, TEncoding.UTF8);
      try
        Writer.WriteLine(LogLine);
      finally
        Writer.Free;
      end;
    except
      // Falha ao gravar log não pode derrubar o fluxo que a chamou.
    end;
  finally
    GLogLock.Leave;
  end;
end;

procedure LogError(const MethodName: string; const E: Exception);
begin
  LogError(MethodName, E.ClassName + ': ' + E.Message);
end;

initialization
  GLogLock := TCriticalSection.Create;

finalization
  GLogLock.Free;

end.
