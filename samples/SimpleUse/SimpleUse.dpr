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
  Signature : 3cd291e399b3eefda990257e3097f5e54bde7892
  ***************************************************************************
*)

program SimpleUse;

uses
  System.StartUpCopy,
  FMX.Forms,
  fMain in 'fMain.pas' {Form2},
  u_ajax in 'u_ajax.pas',
  u_lognpass in '..\..\src\u_lognpass.pas',
  u_md5 in '..\..\lib-externes\librairies\src\u_md5.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
