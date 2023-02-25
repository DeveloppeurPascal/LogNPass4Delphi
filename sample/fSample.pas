unit fSample;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Layouts, FMX.Memo, FMX.ScrollBox,
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
    { Déclarations privées }
    api_key, api_num, api_sec: string;
    timer_en_cours: boolean;
    phrase_MD5: string;
    temps_restant: integer;
  public
    { Déclarations publiques }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

uses
  u_lognpass, u_ajax, u_md5, System.JSON;

procedure TForm2.btnCheckPasswordClick(Sender: TObject);
begin
  lblPasswordOkOrNot.Text := '';
  lognpass_check_password(lblPhraseMD5.Text, edtPassword.Text,
    procedure()
    begin
      lblPasswordOkOrNot.Text := 'Mot de passe ' + edtPassword.Text +
        ' accepté.';
    end,
    procedure()
    begin
      lblPasswordOkOrNot.Text := 'Mot de passe ' + edtPassword.Text +
        ' refusé.';
    end);
end;

procedure TForm2.edtPhraseChange(Sender: TObject);
begin
  phrase_MD5 := MD5(edtPhrase.Text);
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
      AjaxCall('http://api.lognpass.com/get/',
        procedure(aResponseContent: TStringStream)
        var
          JSON: TJSONObject;
        begin
          Memo1.Lines.Add(aResponseContent.DataString);
          try
            JSON := TJSONObject.Create;
            JSON.Parse(aResponseContent.Bytes, 0);
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
        end)
    else
      timer_en_cours := false;
  end;

end;

end.
