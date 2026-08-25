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
  // Senha não é trimada: precisa bater exatamente com o que foi cadastrado.
  Result := FRepository.FindByEmail(EmailAddress.Trim, AuthenticatedUser) and
            (AuthenticatedUser.Password = PasswordValue);
end;

procedure TUserService.RegisterUser(const NewUser: TUserRecord);
var
  ExistingUser: TUserRecord;
  TrimmedUser: TUserRecord;
begin
  TrimmedUser := NewUser;
  TrimmedUser.FirstName := NewUser.FirstName.Trim;
  TrimmedUser.LastName  := NewUser.LastName.Trim;
  TrimmedUser.Email     := NewUser.Email.Trim;
  // Password propositalmente não é trimado: espaços podem ser parte intencional da senha.

  if TrimmedUser.FirstName = '' then
    raise Exception.Create('Nome é obrigatório');
  if TrimmedUser.LastName = '' then
    raise Exception.Create('Sobrenome é obrigatório');
  if TrimmedUser.Email = '' then
    raise Exception.Create('Email é obrigatório');
  if TrimmedUser.Password.Trim = '' then
    raise Exception.Create('Senha é obrigatória');
  if FRepository.FindByEmail(TrimmedUser.Email, ExistingUser) then
    raise Exception.Create('Já existe usuário para este email');
  FRepository.InsertUser(TrimmedUser);
end;

procedure TUserService.UpdateUser(const WhereEmail, WherePassword: string; const NewUser: TUserRecord);
var
  TrimmedUser: TUserRecord;
begin
  if (WhereEmail.Trim = '') or (WherePassword.Trim = '') then
    raise Exception.Create('Credenciais de origem obrigatórias');

  TrimmedUser := NewUser;
  TrimmedUser.FirstName := NewUser.FirstName.Trim;
  TrimmedUser.LastName  := NewUser.LastName.Trim;
  TrimmedUser.Email     := NewUser.Email.Trim;

  if TrimmedUser.FirstName = '' then
    raise Exception.Create('Nome é obrigatório');
  if TrimmedUser.LastName = '' then
    raise Exception.Create('Sobrenome é obrigatório');
  if TrimmedUser.Email = '' then
    raise Exception.Create('Email é obrigatório');
  if TrimmedUser.Password.Trim = '' then
    raise Exception.Create('Senha é obrigatória');

  FRepository.UpdateUserByCredentials(WhereEmail.Trim, WherePassword, TrimmedUser);
end;

procedure TUserService.DeleteUser(const EmailAddress, PasswordValue: string);
begin
  if (EmailAddress.Trim = '') or (PasswordValue.Trim = '') then
    raise Exception.Create('Email e senha obrigatórios');
  FRepository.DeleteUserByCredentials(EmailAddress.Trim, PasswordValue);
end;

end.