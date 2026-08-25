unit uUserService;

interface

uses uUserRepository;

type
  IUserService = interface
    ['{8A6B6E9B-A56B-4C3E-9C2E-8D8B2C5A0B9A}']
    function Login(const EmailAddress, PasswordValue: string; out AuthenticatedUser: TUserRecord): Boolean;
    procedure RegisterUser(const NewUser: TUserRecord);
    procedure UpdateUser(const WhereEmail, WherePassword: string; const NewUser: TUserRecord);
    procedure DeleteUser(const EmailAddress, PasswordValue: string);
  end;

  TUserService = class(TInterfacedObject, IUserService)
  private
    FRepository: IUserRepository;
  public
    constructor Create(const Repository: IUserRepository);
    function Login(const EmailAddress, PasswordValue: string; out AuthenticatedUser: TUserRecord): Boolean;
    procedure RegisterUser(const NewUser: TUserRecord);
    procedure UpdateUser(const WhereEmail, WherePassword: string; const NewUser: TUserRecord);
    procedure DeleteUser(const EmailAddress, PasswordValue: string);
  end;

implementation

uses System.SysUtils;

constructor TUserService.Create(const Repository: IUserRepository);
begin
  FRepository := Repository;
end;

function TUserService.Login(const EmailAddress, PasswordValue: string; out AuthenticatedUser: TUserRecord): Boolean;
begin
  Result := FRepository.FindByEmail(EmailAddress, AuthenticatedUser) and
            (AuthenticatedUser.Password = PasswordValue);
end;

procedure TUserService.RegisterUser(const NewUser: TUserRecord);
var
  ExistingUser: TUserRecord;
begin
  if NewUser.Email.Trim = '' then
    raise Exception.Create('Email é obrigatório');
  if FRepository.FindByEmail(NewUser.Email, ExistingUser) then
    raise Exception.Create('Já existe usuário para este email');
  FRepository.InsertUser(NewUser);
end;

procedure TUserService.UpdateUser(const WhereEmail, WherePassword: string; const NewUser: TUserRecord);
begin
  if (WhereEmail = '') or (WherePassword = '') then
    raise Exception.Create('Credenciais de origem obrigatórias');
  FRepository.UpdateUserByCredentials(WhereEmail, WherePassword, NewUser);
end;

procedure TUserService.DeleteUser(const EmailAddress, PasswordValue: string);
begin
  if (EmailAddress = '') or (PasswordValue = '') then
    raise Exception.Create('Email e senha obrigatórios');
  FRepository.DeleteUserByCredentials(EmailAddress, PasswordValue);
end;

end.