unit uUserRepository;

interface

uses
  System.SysUtils,
  FireDAC.Comp.Client;

type
  TUserRecord = record
    FirstName: string;
    LastName: string;
    Email: string;
    Password: string;
  end;

  IUserRepository = interface
    ['{2A1AA4C0-2A06-4F0C-9A7D-75C1F1C30F3F}']
    function FindByEmail(const EmailAddress: string; out FoundUser: TUserRecord): Boolean;
    procedure InsertUser(const NewUser: TUserRecord);
    procedure UpdateUserByEmail(const WhereEmail: string; const NewUser: TUserRecord);
    procedure DeleteUserByEmail(const EmailAddress: string);
  end;

  TUserRepositoryFD = class(TInterfacedObject, IUserRepository)
  private
    FConnection: TFDConnection; // owned
  public
    constructor Create(AConnected: TFDConnection);
    destructor Destroy; override;

    function FindByEmail(const EmailAddress: string; out FoundUser: TUserRecord): Boolean;
    procedure InsertUser(const NewUser: TUserRecord);
    procedure UpdateUserByEmail(const WhereEmail: string; const NewUser: TUserRecord);
    procedure DeleteUserByEmail(const EmailAddress: string);
  end;

implementation

uses Data.DB;

constructor TUserRepositoryFD.Create(AConnected: TFDConnection);
begin
  FConnection := AConnected;
end;

destructor TUserRepositoryFD.Destroy;
begin
  FConnection.Free;
  inherited;
end;

function TUserRepositoryFD.FindByEmail(const EmailAddress: string; out FoundUser: TUserRecord): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT first_name, last_name, email, password FROM users WHERE email = :email';
    Query.ParamByName('email').AsWideString := EmailAddress;
    Query.Open;

    if not Query.Eof then
    begin
      FoundUser.FirstName := Query.FieldByName('first_name').AsString;
      FoundUser.LastName  := Query.FieldByName('last_name').AsString;
      FoundUser.Email     := Query.FieldByName('email').AsString;
      FoundUser.Password  := Query.FieldByName('password').AsString;
      Result := True;
    end;
  finally
    Query.Free;
  end;
end;

procedure TUserRepositoryFD.InsertUser(const NewUser: TUserRecord);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'INSERT INTO users (first_name, last_name, email, password) ' +
      'VALUES (:first_name, :last_name, :email, :password)';
    Query.ParamByName('first_name').AsWideString := NewUser.FirstName;
    Query.ParamByName('last_name').AsWideString  := NewUser.LastName;
    Query.ParamByName('email').AsWideString      := NewUser.Email;
    Query.ParamByName('password').AsWideString   := NewUser.Password;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TUserRepositoryFD.UpdateUserByEmail(const WhereEmail: string; const NewUser: TUserRecord);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'UPDATE users ' + // updation_date é mantido por trigger (trg_users_updation_date)
      'SET first_name = :first_name, last_name = :last_name, email = :email, password = :password ' +
      'WHERE email = :email_where';
    Query.ParamByName('first_name').AsWideString  := NewUser.FirstName;
    Query.ParamByName('last_name').AsWideString   := NewUser.LastName;
    Query.ParamByName('email').AsWideString       := NewUser.Email;
    Query.ParamByName('password').AsWideString    := NewUser.Password;
    Query.ParamByName('email_where').AsWideString := WhereEmail;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TUserRepositoryFD.DeleteUserByEmail(const EmailAddress: string);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'DELETE FROM users WHERE email = :email';
    Query.ParamByName('email').AsWideString := EmailAddress;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

end.