unit u_ajax;

interface

uses
  Classes, SysUtils, StrUtils, IdHttp;

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
