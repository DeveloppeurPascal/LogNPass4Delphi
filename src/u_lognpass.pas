﻿(* C2PP
  ***************************************************************************

  Log'n Pass for Delphi

  Copyright 2016-2025 Patrick PREMARTIN under AGPL 3.0 license.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
  DEALINGS IN THE SOFTWARE.

  ***************************************************************************

  Delphi client library for the Log'n Pass OTP service.

  ***************************************************************************

  Author(s) :
  Patrick PREMARTIN

  Site :
  https://lognpass4delphi.developpeur-pascal.fr/

  Project site :
  https://github.com/DeveloppeurPascal/LogNPass4Delphi

  ***************************************************************************
  File last update : 2025-02-09T11:04:01.707+01:00
  Signature : 7fce9e946ef6910dfab0abcead83e9538573c4a0
  ***************************************************************************
*)

unit u_lognpass;

interface

uses
  system.Sysutils;

function lognpass_get_password(phrase_md5, api_key, api_num: string): string;

procedure lognpass_check_password(phrase_md5, password: string;
  succes_proc, fail_proc: TProc);

implementation

uses
  u_md5,
  u_ajax,
  system.Classes,
  system.JSON,
  system.Generics.Collections;

var
  lognpass_previous_password: TDictionary<string, string>;

function lognpass_get_password(phrase_md5, api_key, api_num: string): string;
var
  i: integer;
  c: char;
  phrase_codee, pass: string;
begin
  phrase_codee := MD5(phrase_md5 + api_key);
  pass := '';
  i := 0;
  for c in phrase_codee do
  begin
    if (('0' <= c) and (c <= '9')) then
    begin
      if (i < 9) then
        pass := pass + c;
      inc(i);
    end;
  end;
  i := 0;
  while (pass.Length < 5) do
  begin
    pass := pass + i.ToString;
    inc(i);
  end;
  result := pass.Length.ToString + pass + api_num;
end;

procedure lognpass_check_password(phrase_md5, password: string;
  succes_proc, fail_proc: TProc);
var
  password_ok: boolean;
  nb: integer;
  api_num: string;
begin
  password_ok := false;
  if (password.Length > 0) then
  begin
    try
      nb := password.Substring(0, 1).ToInteger;
    except
      nb := 0;
    end;
    if ((nb > 0) and (nb = password.Length - 2)) then
    begin
      api_num := password.Substring(nb + 1);
      try
        AjaxCall('http://' + api_num + '.lognpass.net/get/',
          procedure(aResponseContent: TStringStream)
          var
            JSON: tjsonobject;
            api_num2, api_key, password_old: string;
          begin
            JSON := tjsonobject.Create;
            try
              JSON.Parse(aResponseContent.Bytes, 0);
              try
                api_key := JSON.GetValue('key').ToString.Replace('"', '');
              except
                api_key := '';
              end;
              try
                api_num2 := JSON.GetValue('num').ToString;
              except
                api_num2 := '';
              end;
              if (api_num = api_num2) and
                (password = lognpass_get_password(phrase_md5, api_key, api_num))
              then
              begin
                password_ok := true;
                if (lognpass_previous_password.TryGetValue(phrase_md5,
                  password_old)) then
                begin
                  password_ok := not(password = password_old);
                end;
                lognpass_previous_password.AddOrSetValue(phrase_md5, password);
              end;
            finally
              JSON.Free;
              if (password_ok) then
                succes_proc
              else
                fail_proc;
            end;
          end);
      except
        fail_proc;
      end;
    end
    else
      fail_proc;
  end
  else
    fail_proc;
end;

initialization

lognpass_previous_password := TDictionary<string, string>.Create;

finalization

lognpass_previous_password.Free;

end.
