program sample;

uses
  System.StartUpCopy,
  FMX.Forms,
  fSample in 'fSample.pas' {Form2},
  u_ajax in 'u_ajax.pas',
  u_md5 in '..\lib-externes\librairies\u_md5.pas',
  u_lognpass in '..\src\u_lognpass.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
