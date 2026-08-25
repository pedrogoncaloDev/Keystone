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

uses System.SysUtils, uPasswordHasher;

constructor TUserService.Create(const Repository: IUserRepository);
begin
  FRepository := Repository;
end;

function TUserService.Login(const EmailAddress, PasswordValue: string; out AuthenticatedUser: TUserRecord): Boolean;
begin
  // Senha não é trimada: precisa bater exatamente com o que foi cadastrado.
  Result := FRepository.FindByEmail(EmailAddress.Trim, AuthenticatedUser) and
            VerifyPassword(PasswordValue, AuthenticatedUser.Password);
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
  if NewUser.Password.Trim = '' then
    raise Exception.Create('Senha é obrigatória');
  if FRepository.FindByEmail(TrimmedUser.Email, ExistingUser) then
    raise Exception.Create('Já existe usuário para este email');

  TrimmedUser.Password := HashPassword(NewUser.Password);
  FRepository.InsertUser(TrimmedUser);
end;

procedure TUserService.UpdateUser(const WhereEmail, WherePassword: string; const NewUser: TUserRecord);
var
  ExistingUser: TUserRecord;
  TrimmedUser: TUserRecord;
begin
  if (WhereEmail.Trim = '') or (WherePassword.Trim = '') then
    raise Exception.Create('Credenciais de origem obrigatórias');

  if not FRepository.FindByEmail(WhereEmail.Trim, ExistingUser) then
    raise Exception.Create('Credenciais inválidas');
  if not VerifyPassword(WherePassword, ExistingUser.Password) then
    raise Exception.Create('Credenciais inválidas');

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
  if NewUser.Password.Trim = '' then
    raise Exception.Create('Senha é obrigatória');

  TrimmedUser.Password := HashPassword(NewUser.Password);
  FRepository.UpdateUserByEmail(WhereEmail.Trim, TrimmedUser);
end;

procedure TUserService.DeleteUser(const EmailAddress, PasswordValue: string);
var
  ExistingUser: TUserRecord;
begin
  if (EmailAddress.Trim = '') or (PasswordValue.Trim = '') then
    raise Exception.Create('Email e senha obrigatórios');

  if not FRepository.FindByEmail(EmailAddress.Trim, ExistingUser) then
    raise Exception.Create('Credenciais inválidas');
  if not VerifyPassword(PasswordValue, ExistingUser.Password) then
    raise Exception.Create('Credenciais inválidas');

  FRepository.DeleteUserByEmail(EmailAddress.Trim);
end;

end.