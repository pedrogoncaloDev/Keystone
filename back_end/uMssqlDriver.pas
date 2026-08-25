unit uMssqlDriver;

interface

uses
  System.SysUtils,
  FireDAC.Comp.Client, FireDAC.DApt,
  FireDAC.Stan.Intf, FireDAC.Phys.Intf,
  FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef,
  FireDAC.Stan.Option, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  uIniConfigStore,
  uCreateDatabase; // IDatabaseDriver

const
  DEFAULT_DATABASE = 'master';

type
  TMssqlDriver = class(TInterfacedObject, IDatabaseDriver)
  private
    FConnection: TFDConnection;
    function InternalCheckDatabaseExists(const DatabaseName: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function DatabaseExists(const Params: TConnectionParams): Boolean;
    procedure ConfigureConnection(const Params: TConnectionParams; NameDatabase: string);
    procedure CreateDatabaseIfNotExists(const Params: TConnectionParams);
    procedure CreateUsersTableIfNotExists(const Params: TConnectionParams);
  end;

implementation

{ TMssqlDriver }

constructor TMssqlDriver.Create;
begin
  inherited;
  FConnection := TFDConnection.Create(nil);
end;

destructor TMssqlDriver.Destroy;
begin
  if Assigned(FConnection) then
  begin
    if FConnection.Connected then
      FConnection.Close;
    FreeAndNil(FConnection);
  end;
  inherited;
end;

procedure TMssqlDriver.ConfigureConnection(const Params: TConnectionParams; NameDatabase: string);
begin
  try
    FConnection.Params.Clear;
    with FConnection.Params do
    begin
      Add('DriverID=MSSQL');

      if Params.Port.IsEmpty then
        Add('Server=' + Params.Host)
      else
        Add('Server=' + Params.Host + ',' + Params.Port);

      // para verificar se o banco est� criado conecto no banco master do sql server
      // para criar as tabelas conecto no banco da aplica��o(nome no .ini)
      Add('Database=' + NameDatabase);
      Add('User_Name=' + Params.User);
      Add('Password=' + Params.Password);
    end;
    FConnection.LoginPrompt := False;
    FConnection.Open;
  except
    on E: Exception do
      raise Exception.Create('ConfigureConnection: ' + E.Message);
  end;
end;

function TMssqlDriver.InternalCheckDatabaseExists(const DatabaseName: string): Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT 1 FROM sys.databases WHERE name = :DatabaseName';
    Query.ParamByName('DatabaseName').AsString := DatabaseName;
    Query.Open;
    Result := not Query.IsEmpty;
  finally
    Query.Free;
  end;
end;

function TMssqlDriver.DatabaseExists(const Params: TConnectionParams): Boolean;
begin
  try
    ConfigureConnection(Params, DEFAULT_DATABASE); // Conecta ao master
    Result := InternalCheckDatabaseExists(Params.DatabaseName); // Verifica se o banco alvo existe
  except
    on E: Exception do
      raise Exception.Create('DatabaseExists: ' + E.Message);
  end;
end;

procedure TMssqlDriver.CreateDatabaseIfNotExists(const Params: TConnectionParams);
var
  Query: TFDQuery;
begin
  try
    ConfigureConnection(Params, DEFAULT_DATABASE); // Conecta ao master

    if not InternalCheckDatabaseExists(Params.DatabaseName) then
    begin
      Query := TFDQuery.Create(nil);
      try
        Query.Connection := FConnection;
        Query.SQL.Text := Format('CREATE DATABASE [%s]', [Params.DatabaseName]);
        Query.ExecSQL;
      finally
        Query.Free;
      end;
    end;
  except
    on E: Exception do
      raise Exception.Create('CreateDatabaseIfNotExists: ' + E.Message);
  end;
end;

procedure TMssqlDriver.CreateUsersTableIfNotExists(const Params: TConnectionParams);
var
  Query: TFDQuery;
begin
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConnection;
      Query.SQL.Text :=
        'IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = ''users'') ' +
        'BEGIN ' +
        '  CREATE TABLE users (' +
        '    id INT IDENTITY(1,1) PRIMARY KEY, ' +
        '    first_name NVARCHAR(100) NOT NULL, ' +
        '    last_name NVARCHAR(100) NOT NULL, ' +
        '    email NVARCHAR(255) UNIQUE NOT NULL, ' +
        '    password NVARCHAR(255) NOT NULL, ' +
        '    creation_date DATETIME NOT NULL DEFAULT GETDATE(), ' +
        '    updation_date DATETIME NOT NULL DEFAULT GETDATE()) ' +
        'END';
      Query.ExecSQL;

      // Migração para tabelas 'users' criadas antes de existir essa coluna.
      Query.SQL.Text :=
        'IF NOT EXISTS (SELECT * FROM sys.columns ' +
        '  WHERE object_id = OBJECT_ID(''users'') AND name = ''updation_date'') ' +
        'BEGIN ' +
        '  ALTER TABLE users ADD updation_date DATETIME NOT NULL DEFAULT GETDATE() ' +
        'END';
      Query.ExecSQL;

      // Trigger garante updation_date atualizado em QUALQUER UPDATE na tabela,
      // não só nos que passam pelo repositório Delphi. CREATE TRIGGER precisa
      // ser o único comando do batch, por isso vai via EXEC de SQL dinâmico.
      // TRIGGER_NESTLEVEL() > 1 evita recursão infinita: o UPDATE feito aqui
      // dentro dispararia a própria trigger de novo.
      Query.SQL.Text :=
        'IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = ''trg_users_updation_date'') ' +
        'BEGIN ' +
        '  EXEC(''' +
        '    CREATE TRIGGER trg_users_updation_date ' +
        '    ON users ' +
        '    AFTER UPDATE ' +
        '    AS ' +
        '    BEGIN ' +
        '      SET NOCOUNT ON; ' +
        '      IF TRIGGER_NESTLEVEL() > 1 RETURN; ' +
        '      UPDATE u SET updation_date = GETDATE() ' +
        '      FROM users u INNER JOIN inserted i ON u.id = i.id; ' +
        '    END' +
        ''') ' +
        'END';
      Query.ExecSQL;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
      raise Exception.Create('CreateUsersTableIfNotExists: ' + E.Message);
  end;
end;

end.
