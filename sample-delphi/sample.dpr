program sample;

uses
  System.StartUpCopy,
  FMX.Forms,
  fSample in 'fSample.pas' {Form2},
  u_lognpass in 'u_lognpass.pas',
  u_ajax in 'u_ajax.pas',
  u_md5 in 'u_md5.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
