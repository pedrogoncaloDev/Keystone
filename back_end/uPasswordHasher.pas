unit uPasswordHasher;

interface

function HashPassword(const PlainPassword: string): string;
function VerifyPassword(const PlainPassword, StoredValue: string): Boolean;

implementation

uses
  System.SysUtils, System.Hash, System.NetEncoding;

const
  HASH_PREFIX = 'PBKDF2$SHA256$';
  PBKDF2_ITERATIONS = 100000;
  SALT_LENGTH_BYTES = 32;
  KEY_LENGTH_BYTES = 32;

function GenerateSalt: TBytes;
var
  G1, G2: TGUID;
begin
  CreateGUID(G1);
  CreateGUID(G2);
  SetLength(Result, SALT_LENGTH_BYTES);
  Move(G1, Result[0], SizeOf(TGUID));
  Move(G2, Result[SizeOf(TGUID)], SizeOf(TGUID));
end;

// PBKDF2 (RFC 2898) usando HMAC-SHA256 como PRF.
function DeriveKey(const Password: string; const Salt: TBytes; Iterations, KeyLength: Integer): TBytes;
var
  PasswordBytes: TBytes;
  BlockCount, BlockNum, IterationIndex, ByteIndex: Integer;
  SaltAndBlock: TBytes;
  Ux, Tx: TBytes;
  Derived: TBytes;
  Offset: Integer;
begin
  PasswordBytes := TEncoding.UTF8.GetBytes(Password);
  BlockCount := (KeyLength + 31) div 32; // SHA-256 produz blocos de 32 bytes
  SetLength(Derived, BlockCount * 32);
  Offset := 0;

  for BlockNum := 1 to BlockCount do
  begin
    SetLength(SaltAndBlock, Length(Salt) + 4);
    Move(Salt[0], SaltAndBlock[0], Length(Salt));
    SaltAndBlock[Length(Salt)]     := Byte(BlockNum shr 24);
    SaltAndBlock[Length(Salt) + 1] := Byte(BlockNum shr 16);
    SaltAndBlock[Length(Salt) + 2] := Byte(BlockNum shr 8);
    SaltAndBlock[Length(Salt) + 3] := Byte(BlockNum);

    Ux := THashSHA2.GetHMACAsBytes(SaltAndBlock, PasswordBytes);
    Tx := Copy(Ux);

    for IterationIndex := 2 to Iterations do
    begin
      Ux := THashSHA2.GetHMACAsBytes(Ux, PasswordBytes);
      for ByteIndex := 0 to High(Tx) do
        Tx[ByteIndex] := Tx[ByteIndex] xor Ux[ByteIndex];
    end;

    Move(Tx[0], Derived[Offset], Length(Tx));
    Inc(Offset, Length(Tx));
  end;

  SetLength(Derived, KeyLength);
  Result := Derived;
end;

function ConstantTimeEquals(const A, B: TBytes): Boolean;
var
  I: Integer;
  Diff: Byte;
begin
  if Length(A) <> Length(B) then
    Exit(False);
  Diff := 0;
  for I := 0 to High(A) do
    Diff := Diff or (A[I] xor B[I]);
  Result := Diff = 0;
end;

function HashPassword(const PlainPassword: string): string;
var
  Salt, DerivedKey: TBytes;
begin
  Salt := GenerateSalt;
  DerivedKey := DeriveKey(PlainPassword, Salt, PBKDF2_ITERATIONS, KEY_LENGTH_BYTES);
  Result := Format('%s%d$%s$%s',
    [HASH_PREFIX, PBKDF2_ITERATIONS,
     TNetEncoding.Base64.EncodeBytesToString(Salt),
     TNetEncoding.Base64.EncodeBytesToString(DerivedKey)]);
end;

function VerifyPassword(const PlainPassword, StoredValue: string): Boolean;
var
  Parts: TArray<string>;
  Iterations: Integer;
  Salt, ExpectedKey, ActualKey: TBytes;
begin
  if not StoredValue.StartsWith(HASH_PREFIX) then
    // Compatibilidade com registros antigos gravados em texto puro.
    Exit(StoredValue = PlainPassword);

  Parts := StoredValue.Split(['$']);
  if Length(Parts) <> 5 then
    Exit(False);

  Iterations := StrToIntDef(Parts[2], 0);
  if Iterations <= 0 then
    Exit(False);

  Salt := TNetEncoding.Base64.DecodeStringToBytes(Parts[3]);
  ExpectedKey := TNetEncoding.Base64.DecodeStringToBytes(Parts[4]);
  ActualKey := DeriveKey(PlainPassword, Salt, Iterations, Length(ExpectedKey));

  Result := ConstantTimeEquals(ActualKey, ExpectedKey);
end;

end.
