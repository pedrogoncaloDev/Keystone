program API;

uses
  Vcl.Forms,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  uAPI in 'uAPI.pas' {Form1},
  uCreateDatabase in 'uCreateDatabase.pas',
  uIniConfigStore in 'uIniConfigStore.pas',
  uMssqlDriver in 'uMssqlDriver.pas',
  uConfigProvider in 'uConfigProvider.pas',
  uConnectionFactory in 'uConnectionFactory.pas',
  uUserController in 'uUserController.pas',
  uUserRepository in 'uUserRepository.pas',
  uUserService in 'uUserService.pas',
  uErrorLogger in 'uErrorLogger.pas',
  uApp in 'uApp.pas';

{$R *.res}

begin
  Application.Initialize;

//  ReportMemoryLeaksOnShutdown := (DebugHook <> 0);

  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
