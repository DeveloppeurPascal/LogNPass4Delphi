(* C2PP
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
  Signature : 7e735ece0171d2538d3a0361c2825f760e5fa7d3
  ***************************************************************************
*)

unit u_ajax;

interface

uses
  Classes,
  SysUtils,
  StrUtils,
  IdHttp;

type
  TAjaxCallback = reference to procedure(aResponseContent: TStringStream);

  TAjaxThread = class(TThread)
  private
    fIdHttp: TIdHttp;
    fURL: string;
    fAjaxCallback: TAjaxCallback;
  protected
    procedure Execute; override;
  public
    constructor Create(const strUrl: string; ajaxCallback: TAjaxCallback);
    destructor Destroy; override;
  end;

procedure AjaxCall(const strUrl: string; ajaxCallback: TAjaxCallback);

implementation

procedure AjaxCall(const strUrl: string; ajaxCallback: TAjaxCallback);
begin
  TAjaxThread.Create(strUrl, ajaxCallback);
end;

constructor TAjaxThread.Create(const strUrl: string;
  ajaxCallback: TAjaxCallback);
begin
  fIdHttp := TIdHttp.Create(nil);
  fURL := strUrl;
  fAjaxCallback := ajaxCallback;
  inherited Create(False);
  FreeOnTerminate := True;
end;

destructor TAjaxThread.Destroy;
begin
  fIdHttp.Free;
  inherited;
end;

procedure TAjaxThread.Execute;
var
  aResponseContent: TStringStream;
begin
  aResponseContent := TStringStream.Create;
  try
    try
      fIdHttp.Get(fURL, aResponseContent);
    except
    end;
    aResponseContent.Position := 0;
    synchronize(
      procedure
      begin
        fAjaxCallback(aResponseContent);
      end);
  finally
    aResponseContent.Free;
  end;
end;

end.
