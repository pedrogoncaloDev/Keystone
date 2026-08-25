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
      '    creation_date DATETIME DEFAULT GETDATE()) ' +
      'END';

    Query.ExecSQL;
  except
    on E: Exception do
      raise Exception.Create('CreateUsersTableIfNotExists: ' + E.Message);
  end;
end;

end.
