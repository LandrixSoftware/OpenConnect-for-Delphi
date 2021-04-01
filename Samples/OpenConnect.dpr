program OpenConnect;

uses
  Vcl.Forms,
  OpenConnectUnit1 in 'OpenConnectUnit1.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
