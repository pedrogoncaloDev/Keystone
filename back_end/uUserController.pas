unit uUserController;

interface

uses
  Horse, System.JSON, uUserService, uUserRepository;

type
  TUserController = class
  private
    FService: IUserService;
    function GetUtf8Body(const Request: THorseRequest): string;
    function JsonGetString(const JsonObject: TJSONObject; const Key: string; const DefaultValue: string = ''): string;
    function JsonToUser(const JsonObject: TJSONObject): TUserRecord;
  public
    constructor Create(const Service: IUserService);
    procedure RegisterRoutes;
  end;

implementation

uses
  System.SysUtils;

constructor TUserController.Create(const Service: IUserService);
begin
  FService := Service;
end;

function TUserController.GetUtf8Body(const Request: THorseRequest): string;
begin
  // O charset do Content-Type enviado pelo cliente nem sempre vem como utf-8;
  // JSON é sempre UTF-8 (RFC 8259), então decodificamos os bytes crus assim,
  // em vez de usar Request.Body (que usa TEncoding.ANSI quando falta o charset
  // no header, corrompendo caracteres acentuados).
  Result := TEncoding.UTF8.GetString(BytesOf(Request.RawWebRequest.RawContent));
end;

function TUserController.JsonGetString(const JsonObject: TJSONObject; const Key: string; const DefaultValue: string): string;
var
  JsonValue: TJSONValue;
begin
  JsonValue := JsonObject.GetValue(Key);
  if Assigned(JsonValue) then
    Result := JsonValue.Value
  else
    Result := DefaultValue;
end;

function TUserController.JsonToUser(const JsonObject: TJSONObject): TUserRecord;
begin
  Result.FirstName := JsonGetString(JsonObject, 'first_name', '');
  Result.LastName  := JsonGetString(JsonObject, 'last_name', '');
  Result.Email     := JsonGetString(JsonObject, 'email', '');
  Result.Password  := JsonGetString(JsonObject, 'password', '');
end;

procedure TUserController.RegisterRoutes;
begin
  // LOGIN
  THorse.Post('/users/login',
    procedure(Request: THorseRequest; Response: THorseResponse)
    var
      RequestBody: TJSONObject;
      EmailAddress, PasswordValue: string;
      AuthenticatedUser: TUserRecord;
      ResponseJson: TJSONObject;
    begin
      try
        if Request.Body.IsEmpty then
        begin
          Response.Status(THTTPStatus.BadRequest).Send('Body vazio');
          Exit;
        end;

        RequestBody := TJSONObject.ParseJSONValue(GetUtf8Body(Request)) as TJSONObject;
        if not Assigned(RequestBody) then
        begin
          Response.Status(THTTPStatus.BadRequest).Send('JSON inválido');
          Exit;
        end;

        try
          EmailAddress  := JsonGetString(RequestBody, 'email', '');
          PasswordValue := JsonGetString(RequestBody, 'password', '');

          if (EmailAddress = '') or (PasswordValue = '') then
          begin
            Response.Status(THTTPStatus.BadRequest).Send('Email e senha obrigatórios');
            Exit;
          end;

          if FService.Login(EmailAddress, PasswordValue, AuthenticatedUser) then
          begin
            ResponseJson := TJSONObject.Create
              .AddPair('message', 'Acesso liberado')
              .AddPair('first_name', AuthenticatedUser.FirstName)
              .AddPair('last_name',  AuthenticatedUser.LastName)
              .AddPair('email',      AuthenticatedUser.Email);
            try
              Response
                .Status(THTTPStatus.OK)
                .ContentType('application/json; charset=utf-8')
                .Send(ResponseJson.ToJSON);
            finally
              ResponseJson.Free;
            end;
          end
          else
            Response.Status(THTTPStatus.Unauthorized).Send('Acesso negado');
        finally
          RequestBody.Free;
        end;
      except
        on E: Exception do
        begin
          // Não re-raise! Converte para resposta HTTP
          Response.Status(THTTPStatus.BadRequest).Send(E.Message);
        end;
      end;
    end);

  // CADASTRO
  THorse.Post('/users/cadastro',
    procedure(Request: THorseRequest; Response: THorseResponse)
    var
      RequestBody: TJSONObject;
      NewUser: TUserRecord;
    begin
      try
        if Request.Body.IsEmpty then
        begin
          Response.Status(THTTPStatus.BadRequest).Send('Body vazio');
          Exit;
        end;

        RequestBody := TJSONObject.ParseJSONValue(GetUtf8Body(Request)) as TJSONObject;
        if not Assigned(RequestBody) then
        begin
          Response.Status(THTTPStatus.BadRequest).Send('JSON inválido');
          Exit;
        end;

        try
          NewUser := JsonToUser(RequestBody);
          FService.RegisterUser(NewUser);
          Response.Status(THTTPStatus.OK).Send('Cadastro concluído');
        finally
          RequestBody.Free;
        end;
      except
        on E: Exception do
        begin
          // Se quiser diferenciar conflitos (email já existe), use 409:
          // Response.Status(THTTPStatus.Conflict).Send(E.Message);
          Response.Status(THTTPStatus.BadRequest).Send(E.Message);
        end;
      end;
    end);

  // ATUALIZAR
  THorse.Put('/users/atualizar',
    procedure(Request: THorseRequest; Response: THorseResponse)
    var
      RequestBody: TJSONObject;
      WhereEmail, WherePassword: string;
      NewUser: TUserRecord;
    begin
      try
        if Request.Body.IsEmpty then
        begin
          Response.Status(THTTPStatus.BadRequest).Send('Body vazio');
          Exit;
        end;

        RequestBody := TJSONObject.ParseJSONValue(GetUtf8Body(Request)) as TJSONObject;
        if not Assigned(RequestBody) then
        begin
          Response.Status(THTTPStatus.BadRequest).Send('JSON inválido');
          Exit;
        end;

        try
          WhereEmail    := JsonGetString(RequestBody, 'email_where', '');
          WherePassword := JsonGetString(RequestBody, 'password_where', '');
          NewUser       := JsonToUser(RequestBody);

          FService.UpdateUser(WhereEmail, WherePassword, NewUser);
          Response.Status(THTTPStatus.OK).Send('Dados atualizados');
        finally
          RequestBody.Free;
        end;
      except
        on E: Exception do
          Response.Status(THTTPStatus.BadRequest).Send(E.Message);
      end;
    end);

  // DELETAR
  THorse.Delete('/users/deletar',
    procedure(Request: THorseRequest; Response: THorseResponse)
    var
      RequestBody: TJSONObject;
      EmailAddress, PasswordValue: string;
    begin
      try
        if Request.Body.IsEmpty then
        begin
          Response.Status(THTTPStatus.BadRequest).Send('Body vazio');
          Exit;
        end;

        RequestBody := TJSONObject.ParseJSONValue(GetUtf8Body(Request)) as TJSONObject;
        if not Assigned(RequestBody) then
        begin
          Response.Status(THTTPStatus.BadRequest).Send('JSON inválido');
          Exit;
        end;

        try
          EmailAddress  := JsonGetString(RequestBody, 'email', '');
          PasswordValue := JsonGetString(RequestBody, 'password', '');
          FService.DeleteUser(EmailAddress, PasswordValue);
          Response.Status(THTTPStatus.OK).Send('Usuário deletado');
        finally
          RequestBody.Free;
        end;
      except
        on E: Exception do
          Response.Status(THTTPStatus.BadRequest).Send(E.Message);
      end;
    end);
end;

end.


