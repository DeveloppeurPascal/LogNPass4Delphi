unit u_md5;

interface

function MD5(S: String): String;

implementation

uses
  IdHashMessageDigest, u_ajax, System.SysUtils;

function MD5(S: String): String;
var
  ch: string;
begin
  with TIdHashMessageDigest5.Create do
  begin
    ch := HashStringAsHex(S);
    DisposeOf;
  end;
  result := ch.ToLower;
end;

end.
