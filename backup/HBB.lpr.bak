program HBB;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.HelpFile := '';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  if Form1.CheckBox2.Checked then Application.ShowMainForm := FALSE
  else
  Application.ShowMainForm := TRUE;
  Application.Run;
end.
