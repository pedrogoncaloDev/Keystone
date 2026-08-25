unit uApp;

interface

uses
  uIniConfigStore;

type
  TApp = class
  public
    class procedure Start(const ConnectionParams: TConnectionParams; const ListenPort: Integer = 9000);
  end;

implementation

uses
  Horse, Horse.Cors,
  uCreateDatabase, uMssqlDriver,
  uConnectionFactory, uUserRepository, uUserService, uUserController;

class procedure TApp.Start(const ConnectionParams: TConnectionParams; const ListenPort: Integer);
var
  DatabaseDriver: IDatabaseDriver;
  DatabaseManager: TDatabaseManager;
  ConnectionFactory: IDBConnectionFactory;
  UserRepository: IUserRepository;
  UserService: IUserService;
  UserController: TUserController;
begin
  // Ensure DB and tables using your existing driver/manager
  DatabaseDriver := TMssqlDriver.Create;
  DatabaseManager := TDatabaseManager.Create(DatabaseDriver);
  try
    DatabaseManager.SetConnectionParams(ConnectionParams.DatabaseName,
                                        ConnectionParams.User,
                                        ConnectionParams.Password,
                                        ConnectionParams.Host,
                                        ConnectionParams.Port);
    DatabaseManager.Initialize;
  finally
    DatabaseManager.Free;
  end;

  // DI wire-up for request-time operations
  ConnectionFactory := TMSSQLConnectionFactory.Create(ConnectionParams);
  UserRepository := TUserRepositoryFD.Create(ConnectionFactory.NewConnection);
  UserService := TUserService.Create(UserRepository);
  UserController := TUserController.Create(UserService);

  THorse.Use(
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.ContentType('text/plain; charset=utf-8');
      Next();
    end);
  THorse.Use(Cors);
  UserController.RegisterRoutes;
  THorse.Listen(ListenPort);
end;

end.