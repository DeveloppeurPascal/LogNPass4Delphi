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
  File last update : 2025-07-11T14:08:40.000+02:00
  Signature : 7df784f2ec66df792b379ebb823f4825cf90e747
  ***************************************************************************
*)

unit fMain;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.Layouts,
  FMX.Memo,
  FMX.ScrollBox,
  FMX.Memo.Types;

type
  TForm2 = class(TForm)
    Label1: TLabel;
    edtPhrase: TEdit;
    Label2: TLabel;
    lblPhraseMD5: TLabel;
    Label3: TLabel;
    lblPassword: TLabel;
    Timer1: TTimer;
    ProgressBar1: TProgressBar;
    Memo1: TMemo;
    Label4: TLabel;
    edtPassword: TEdit;
    btnCheckPassword: TButton;
    Layout1: TLayout;
    lblPasswordOkOrNot: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure edtPhraseChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnCheckPasswordClick(Sender: TObject);
  private
    { D�clarations priv�es }
    api_key, api_num, api_sec: string;
    timer_en_cours: boolean;
    phrase_MD5: string;
    temps_restant: integer;
  public
    { D�clarations publiques }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

uses
  u_lognpass,
  System.Hash,
  System.Net.HttpClient,
  System.Net.URLClient,
  System.JSON;

procedure TForm2.btnCheckPasswordClick(Sender: TObject);
begin
  lblPasswordOkOrNot.Text := '';
  lognpass_check_password(lblPhraseMD5.Text, edtPassword.Text,
    procedure()
    begin
      lblPasswordOkOrNot.Text := 'Mot de passe ' + edtPassword.Text +
        ' accept�.';
    end,
    procedure()
    begin
      lblPasswordOkOrNot.Text := 'Mot de passe ' + edtPassword.Text +
        ' refus�.';
    end);
end;

procedure TForm2.edtPhraseChange(Sender: TObject);
begin
  phrase_MD5 := THashMD5.GetHashString(edtPhrase.Text);
  lblPhraseMD5.Text := phrase_MD5;
  if (api_key <> '') then
  begin
    lblPassword.Text := lognpass_get_password(lblPhraseMD5.Text,
      api_key, api_num);
    Memo1.Lines.Add(lblPassword.Text);
  end;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  edtPhrase.Text := '';
  lblPhraseMD5.Text := '';
  phrase_MD5 := '';
  lblPassword.Text := '';
  api_key := '';
  api_num := '';
  api_sec := '0';
  temps_restant := 0;
  ProgressBar1.Value := api_sec.ToInteger;
  timer_en_cours := false;
  Timer1.Enabled := true;
  edtPassword.Text := '';
  lblPasswordOkOrNot.Text := '';
end;

procedure TForm2.Timer1Timer(Sender: TObject);
begin
  if (not timer_en_cours) then
  begin
    timer_en_cours := true;
    dec(temps_restant);
    ProgressBar1.Value := temps_restant;
    if (temps_restant < 1) then
      turlstream.create('http://api.lognpass.com/get/',
        procedure(AStream: TStream)
        var
          SS: TStringStream;
          JSON: TJSONObject;
        begin
          SS := TStringStream.create;
          try
            AStream.Position := 0;
            SS.CopyFrom(AStream);
            Memo1.Lines.Add(SS.DataString);
            JSON := TJSONObject.ParseJSONValue(SS.DataString) as TJSONObject;
            try
              try
                api_key := JSON.GetValue('key').ToString.Replace('"', '');
              except
                api_key := '';
              end;
              try
                api_num := JSON.GetValue('num').ToString;
              except
                api_num := '';
              end;
              try
                api_sec := JSON.GetValue('sec').ToString;
              except
                api_sec := '1';
              end;
              temps_restant := api_sec.ToInteger;
              if (api_key.Length > 0) then
                lblPassword.Text := lognpass_get_password(phrase_MD5,
                  api_key, api_num)
              else
                lblPassword.Text := '-';
              Memo1.Lines.Add(lblPassword.Text);
            finally
              JSON.Free;
              timer_en_cours := false;
            end;
          finally
            SS.Free;
          end;
        end)
    else
      timer_en_cours := false;
  end;

end;

end.
