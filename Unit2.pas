unit Unit2;

interface

uses
  Unit1, {Windows,} Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, {jpeg,} ExtCtrls;

type
  TForm2 = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation


const Form2_Height_Default = 193;  //������ �� ���������  333
      Form2_Width_Default = 385;   //������ �� ���������  487

var WTB: array of HBB_TYPE;  //WeekToBirth

function FutureDate(AD: integer; Date: TDateTime): String;
var S: String;
    FD: TDateTime;
begin
  FD := Date + AD;
  Result := DateToStr(FD);
end;

procedure TForm2.FormCreate(Sender: TObject);
var i: integer;
begin
  if not Form1.CheckBox3.Checked then exit;
  //Form1.AD := 8;  //8 - week
  //Form2.AlphaBlendValue := Form1.TrackBar2.Position;
  if Form1.AD = 1 then Label1.Caption := '������ �����(�.�. ' +
                       FutureDate(Form1.AD, Date) + ')' + #13 +
                       '���� ���� �������� �������: ';
  if (Form1.AD = 2) or (Form1.AD = 3) or (Form1.AD = 4) then Label1.Caption := '� ��������� ' +
                      IntToStr(Form1.AD) + ' ����(�.�. �� ' +
                      FutureDate(Form1.AD, Date) + ' ������������)' + #13 +
                      '���� ���� �������� �������: ';
  if Form1.AD > 4 then Label1.Caption := '� ��������� ' +
                      IntToStr(Form1.AD) + ' ����(�.�. �� ' +
                      FutureDate(Form1.AD, Date) + ' ������������)' + #13 +
                       '���� ���� �������� �������: ';
  Form2.Height := Form2_Height_Default;  //������
  Form2.Width := Form2_Width_Default;    //������
  Image1.Visible := FALSE;
  //ListBox1.Left := 2;
  //ListBox1.Width := 564;
  for i := 0 to High(Form1.HBB) do
  begin
    SetLength(WTB, i + 1);
    WTB[i] := Form1.HBB[i];
  end;
  SM_DTB(WTB);
  for i := 0 to High(WTB) do
  begin
    if CD(WTB[i], Date) = 0 then
    begin
      Memo1.Lines.Add('������� ' + WTB[i].Name + ' ��������� ��� ' +
                        FloatToStr(WTB[i].Age) + '-�����!');
      Image1.Visible := TRUE;
      Memo1.Lines.Add('');
    end
    else
    if CD(WTB[i], Date) = 1 then
    begin
      Memo1.Lines.Add('������ ' + WTB[i].Name + ' ��������� ��� ' +
                        FloatToStr(WTB[i].Age + 1) + '-�����!');
      Memo1.Lines.Add('');
    end
    else
    if CD(WTB[i], Date) < Form1.AD + 1 then
    begin
      Memo1.Lines.Add('����� ' + FloatToStr(WTB[i].DTB) +
                        ' ���(����)(�.�. ' + Copy(DateToStr(WTB[i].Date), 1, 5) + ') ' + WTB[i].Name + ' ��������� ��� ' +
                        FloatToStr(WTB[i].Age + 1) + '-�����!');
      Memo1.Lines.Add('');
    end;
    memo1.ScrollBars := ssVertical;
    Memo1.SelStart := 0;
    Memo1.SelLength := 0;
  //for i := 0 to High(Form1.HBB) do List
  if Memo1.Lines.Count > 0 then
  begin
    Form2.Show;
  end;
end;
end;

end.
