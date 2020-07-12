unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, XPMan, ToolWin, Buttons, Grids,
  DateUtils, Calendar, ShellApi;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    ListBox1: TListBox;
    MonthCalendar1: TMonthCalendar;
    GroupBox1: TGroupBox;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ToolButton2: TToolButton;
    GroupBox2: TGroupBox;
    ToolButton5: TToolButton;
    ToolButton7: TToolButton;
    ToolButton6: TToolButton;
    LabeledEdit1: TLabeledEdit;
    DateTimePicker1: TDateTimePicker;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    XPManifest1: TXPManifest;
    StatusBar1: TStatusBar;
    ToolButton4: TToolButton;
    StringGrid1: TStringGrid;
    Panel2: TPanel;
    RadioGroup1: TRadioGroup;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure MonthCalendar1GetMonthInfo(Sender: TObject; Month: Cardinal;
      var MonthBoldInfo: Cardinal);
    procedure ToolButton3Click(Sender: TObject);
    procedure StatusBar1Click(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
const Form_Height_Default = 250;  //Высота по умолчанию
      Form_Width_Default = 407;   //Ширина по умолчанию

      GroupBox_Height_Default = 129;  //Высота GroupBox по умолчанию
      GroupBox_Width_Default = Form_Width_Default;  //Ширина GroupBox по умолчанию
      GroupBox_Height_More = 250;  //Высота GroupBox при подробностях

      Form_Height_New = 378;      //Высота при добавлении
      Form_Height_Edit = Form_Height_New; //Высота при изменении
      Form_Height_More = 500;  //Высота при подробностях
      Form_Height_Options = 380;  //Высота при настройках
      Form_Height_Info = 380;     //Высота при справке
      File_Name = 'data.hbb';

type
  HBB_TYPE = record
    Name: String;
    Date: TDateTime;
    DTB: Double;  //DaysToBirth
    Age: Double;
  end;

var new, edit, more: boolean;
    names: integer;
    File_HBB: TextFile;
    HBB, M2, WTB: array of HBB_TYPE;  //HappyBirthDay, WeekToBirth
    Index_Name: integer;
    HBB_Near: Double;
    Year: integer;

function DB(Date1, Date2: TDateTime): Double;  //DaysBetween
begin
  Result := Date1 - Date2;
end;

function Today(A: HBB_TYPE; Today: TDateTime): TDateTime;
var S, T: String;
begin
  T := DateToStr(Today);
  S := DateToStr(A.Date);
  Year := StrToInt(Copy(T, Length(T) - 3, Length(T)));
  Delete(S, Length(S) - 3, Length(S));
  S := S + IntToStr(Year);
  Result := StrToDate(S);
end;

function HBBVS(HBB: array of HBB_TYPE): HBB_TYPE; //HBB_VerySoon
var i, min_days: integer;
begin
  if High(HBB) = 0 then
  begin
    Result := HBB[0];
    exit;
  end;
  if High(HBB) > 0 then
  begin
    min_days := 0;
    Result := HBB[0];
    for i := 0 to High(HBB) - 1 do
    begin
      if HBB[min_days].DTB < HBB[i + 1].DTB then
      begin
        Result := HBB[min_days];
        //Index_Name := i;
      end
      else
      begin
        Result := HBB[i + 1];
        min_days := i + 1;
      end;
    end;
  end;
end;

function CY(A, Today: TDateTime): integer;  //CountYears
var S, T: String;
    User_Year, Now_Year: integer;
begin
  T := DateToStr(Today);
  S := DateToStr(A);
  User_Year := StrToInt(Copy(S, Length(S) - 3, Length(S)));
  Now_Year := StrToInt(Copy(T, Length(T) - 3, Length(T)));
  Result := Now_Year - User_Year;
end;

function CD(A: HBB_TYPE; Today: TDateTime): Double;  //CountDays
var S, T: String;
    //year: integer;
begin
  T := DateToStr(Today);
  S := DateToStr(A.Date);
  Year := StrToInt(Copy(T, Length(T) - 3, Length(T)));
  Delete(S, Length(S) - 3, Length(S));
  S := S + IntToStr(Year);
  if DB(StrToDate(S), Today) > 0 then
  Result := abs(StrToDate(S) - Today)
  else
  begin
    //S := DateToStr(A.Date);
    //year := StrToInt(Copy(S, Length(S) - 3, Length(S)));
    Delete(S, Length(S) - 3, Length(S));
    S := S + IntToStr(Year + 1);
    Result := StrToDate(S) - Today;
  end;
end;

function RLB(var A: HBB_TYPE): String; //RefreshListBox
begin

  Result := DateToStr(A.Date) + ' - ' + A.Name;

end;

procedure Delete_HBB(Index: integer; var A: array of HBB_TYPE);
var i: integer;
begin
  for i := Index - 1 to High(A) - 1 do
  begin
    A[i] := A[i + 1];
  end;
end;

procedure FM(Lines: String; var HBB: HBB_TYPE); //FillMassive
begin
  HBB.Date := StrToDate(Copy(Lines, 1, Pos('-', Lines) - 2));
  HBB.Name := Copy(Lines, Pos('-', Lines) + 2, Length(Lines));
  HBB.DTB := CD(HBB, Date);
  HBB.Age := CY(HBB.Date, Date);
end;

procedure Swap(var a, b: HBB_TYPE);
var c: HBB_TYPE;
begin
c := a;
a := b;
b := c;
end;

procedure SM(var A: array of HBB_TYPE);  //SortMassive(Date)
var i, j: integer;
begin
for i := 0 to High(A) - 1 do
  for j := 0 to High(A) - 1 - i do
  if A[j].Date > A[j + 1].Date then
    begin
      Swap(A[j], A[j + 1]);
    end;
end;

procedure SM_DTB(var A: array of HBB_TYPE);  //SortMassive(DTB)
var i, j: integer;
begin
for i := 0 to High(A) - 1 do
  for j := 0 to High(A) - 1 - i do
  if A[j].DTB > A[j + 1].DTB then
    begin
      Swap(A[j], A[j + 1]);
    end;
end;

procedure SM_A(var A: array of HBB_TYPE);  //SortMassive(Age)
var i, j: integer;
begin
for i := 0 to High(A) - 1 do
  for j := 0 to High(A) - 1 - i do
  if A[j].Age > A[j + 1].Age then
    begin
      Swap(A[j], A[j + 1]);
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var i: integer;
begin
  //ShowMessage('Сегодня ' + DateToStr(Date));
  Form1.Height := Form_Height_Default;  //Высота
  Form1.Width := Form_Width_Default;    //Ширина
  new := FALSE;
  edit := FALSE;
  more := FALSE;
  ToolButton1.Down := FALSE;
  ToolButton2.Down := FALSE;
  DateTimePicker1.Date := Date;
  
  if FileExists(File_Name) then
  begin
    ListBox1.Items.LoadFromFile(File_Name);
    names := ListBox1.Items.Count;
    SetLength(HBB, names);
    for i := 0 to names - 1 do FM(ListBox1.Items[i], HBB[i])
  end
  else
  begin
    AssignFile(File_HBB, File_Name);
    ReWrite(File_HBB);
    CloseFile(File_HBB);
  end;
  if ListBox1.Items.Count = 0 then
  begin
    StatusBar1.Panels[0].Text := 'Данных о днях рождения пока не обнаружено!';
    ToolButton2.Enabled := FALSE;
    ToolButton3.Enabled := FALSE;
    ToolButton4.Enabled := FALSE;
  end;
  if ListBox1.Items.Count > 0 then
  begin
    FM(ListBox1.Items[0], HBB[0]);
    StatusBar1.Panels[0].Text := 'Ближайший день рождения будет у ' +
                                  HBBVS(HBB).Name + ' через ' +
                                  FloatToStr(CD(HBBVS(HBB), Date)) + ' дней!';
    ListBox1.Selected[0] := TRUE;
  end;
  StatusBar1.Panels[0].Width := Length(StatusBar1.Panels[0].Text)*6; //Length(StatusBar1.Panels[0].Text)*8
  MonthCalendar1.Date := Today(HBBVS(HBB), Date);
end;

procedure TForm1.ToolButton1Click(Sender: TObject);
begin
  Panel2.Visible := FALSE;
  Panel1.Visible := TRUE;
  GroupBox2.Height := GroupBox_Height_Default;
  ToolButton3.Caption := 'Удалить';
  BitBtn1.Kind := bkOK;
  BitBtn1.Caption := '&Добавить';
  GroupBox2.Caption := 'Добавление дня рождения';
  LabeledEdit1.EditLabel.Caption := 'Введите имя и инициалы';
  LabeledEdit1.Enabled := TRUE;
  LabeledEdit1.Text := '';
  DateTimePicker1.Enabled := TRUE;
  BitBtn1.Enabled := TRUE;
  BitBtn2.Enabled := TRUE;
  if new then
  begin
    Form1.Height := Form_Height_Default;
    ToolButton1.Down := FALSE;
    ToolButton2.Down := FALSE;
    ToolButton4.Down := FALSE;
    new := FALSE;
    edit := FALSE;
    more := FALSE;
  end
  else
  begin
    new := TRUE;
    edit := FALSE;
    more := FALSE;
    ToolButton1.Down := TRUE;
    Form1.Height := Form_Height_New;  //Высота при добавлении
    ToolButton2.Down := FALSE;
    ToolButton4.Down := FALSE;
    Panel1.Visible := TRUE;
    Panel2.Visible := FALSE;
    LabeledEdit1.SetFocus;
  end;
end;

procedure TForm1.ToolButton2Click(Sender: TObject);
begin
  Panel2.Visible := FALSE;
  Panel1.Visible := TRUE;
  GroupBox2.Height := GroupBox_Height_Default;
  ToolButton3.Caption := 'Удалить';
  BitBtn1.Kind := bkRetry;
  BitBtn1.Caption := '&Изменить';
  GroupBox2.Caption := 'Изменение дня рождения';
  LabeledEdit1.EditLabel.Caption := 'Имя и инициалы';
  LabeledEdit1.Enabled := FALSE;
  LabeledEdit1.Text := 'Сначала выберите кого изменять';
  DateTimePicker1.Enabled := FALSE;
  BitBtn1.Enabled := FALSE;
  BitBtn2.Enabled := FALSE;
  if edit then
  begin
    ToolButton2.Down := FALSE;
    Form1.Height := Form_Height_Default;
    ToolButton1.Down := FALSE;
    ToolButton4.Down := FALSE;
    edit := FALSE;
    new := FALSE;
    more := FALSE;
  end
  else
  begin
    edit := TRUE;
    new := FALSE;
    more := FALSE;
    ToolButton2.Down := TRUE;
    Form1.Height := Form_Height_Edit;  //Высота при изменении
    ToolButton1.Down := FALSE;
    ToolButton4.Down := FALSE;
    Panel1.Visible := TRUE;
    Panel2.Visible := FALSE;
  end;
end;

procedure TForm1.ToolButton5Click(Sender: TObject);
begin
  GroupBox2.Caption := 'Настройки';
end;

procedure TForm1.ToolButton6Click(Sender: TObject);
begin
  GroupBox2.Caption := 'Справка';
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var i: integer;
begin
  if (LabeledEdit1.Text = '') then
  begin
    ShowMessage('Вы ничего не ввели!');
    exit;
  end;
  if (ListBox1.Items.Count < names + 2) and not edit then
  begin
    ListBox1.Items[names] := Trim(DateToStr(DateTimePicker1.Date) + ' - ' + LabeledEdit1.Text);
  end;
  if new then
  begin
    BitBtn1.Caption := '&Добавлено!';
    inc(names);
    SetLength(HBB, names);
    FM(ListBox1.Items[names - 1], HBB[names - 1]);
    ListBox1.Selected[ListBox1.Items.Count - 1] := TRUE;
  end;
  if edit then
  begin
    BitBtn1.Caption := '&Изменено!';
    HBB[ListBox1.ItemIndex].Name := LabeledEdit1.Text;  //LabeledEdit1.Text
    HBB[ListBox1.ItemIndex].Date := DateTimePicker1.Date;
    ListBox1.Items[ListBox1.ItemIndex] := RLB(HBB[ListBox1.ItemIndex]);
    FM(ListBox1.Items[ListBox1.ItemIndex], HBB[ListBox1.ItemIndex]);
    LabeledEdit1.Enabled := FALSE;
    DateTimePicker1.Enabled := FALSE;
    BitBtn1.Enabled := FALSE;
    BitBtn2.Enabled := FALSE;
    LabeledEdit1.Text := 'Сначала выберите кого изменять';
  end;
  if High(HBB) > 0 then
  begin
    SM(HBB);
    for i := 0 to High(HBB) do ListBox1.Items[i] := RLB(HBB[i]);
  end;
  //LabeledEdit1.SetFocus;
  ListBox1.Selected[ListBox1.Items.Count - 1] := TRUE;

  if ListBox1.Items.Count > 0 then
  begin
    ToolButton2.Enabled := TRUE;
    ToolButton3.Enabled := TRUE;
    ToolButton4.Enabled := TRUE;
  end;
  StatusBar1.Panels[0].Text := 'Ближайший день рождения будет у ' +
                                    HBBVS(HBB).Name + ' через ' +
                                  FloatToStr(HBBVS(HBB).DTB) + ' дней!'; //FloatToStr(CD(HBB[0], Date));
  StatusBar1.Panels[0].Width := Length(StatusBar1.Panels[0].Text)*6; //FloatToStr(CD(HBB[0], Date));
  MonthCalendar1.Date := Today(HBBVS(HBB), Date);
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
  if (ListBox1.Items.Count > 0) and edit then
  begin
    LabeledEdit1.Enabled := TRUE;
    DateTimePicker1.Enabled := TRUE;
    BitBtn1.Enabled := TRUE;
    BitBtn2.Enabled := TRUE;
    LabeledEdit1.Text := HBB[ListBox1.ItemIndex].Name;  //ListBox1.Items[ListBox1.ItemIndex
    DateTimePicker1.Date := HBB[ListBox1.ItemIndex].Date;
  end;
  if (ListBox1.Items.Count > 0) then MonthCalendar1.Date := HBB[ListBox1.ItemIndex].Date;
  ToolButton3.Caption := 'Удалить';
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
  if FileExists(File_Name) then
  begin
    ListBox1.Items.SaveToFile(File_Name);
  end
  else
  begin
    AssignFile(File_HBB, File_Name);
    ReWrite(File_HBB);
    CloseFile(File_HBB);
    ListBox1.Items.SaveToFile(File_Name);
  end;
end;

procedure TForm1.MonthCalendar1GetMonthInfo(Sender: TObject;
  Month: Cardinal; var MonthBoldInfo: Cardinal);
begin
  if ListBox1.Items.Count = 0 then MonthCalendar1.Date := Date;
end;

procedure TForm1.ToolButton3Click(Sender: TObject);
var i: integer;
begin
  if ListBox1.Items.Count = 0 then
  begin
    StatusBar1.Panels[0].Text := 'Данных о днях рождения пока не обнаружено!';
    ToolButton2.Enabled := FALSE;
    ToolButton3.Enabled := FALSE;
    ToolButton4.Enabled := FALSE;
    exit;
  end;
  if ToolButton3.Caption = 'Удалить' then ToolButton3.Caption := 'Точно?'
  else
  if (ToolButton3.Caption = 'Точно?') and (ListBox1.Items.Count <> 0) then
  begin
    //ListBox1.Items[ListBox1.ItemIndex] := '';
    Delete_HBB(ListBox1.ItemIndex + 1, HBB);
    ListBox1.Items.Delete(ListBox1.ItemIndex);
    SetLength(HBB, names - 1);
    dec(names);
    for i := 0 to High(HBB) do
    begin
      SetLength(M2, i + 1);
      M2[i] := HBB[i];
    end;
    ToolButton3.Caption := 'Удалить';
    if ListBox1.Items.Count = 0 then  //and (edit or new)
    begin
      ToolButton1.Down := FALSE;
      ToolButton2.Down := FALSE;
      ToolButton4.Down := FALSE;
      new := FALSE;
      edit := FALSE;
      more := FALSE;
      ToolButton2.Enabled := FALSE;
      ToolButton3.Enabled := FALSE;
      ToolButton4.Enabled := FALSE;
      Form1.Height := Form_Height_Default;
      StatusBar1.Panels[0].Text := 'Данных о днях рождения пока не обнаружено!';
      exit;
    end;
    ListBox1.Selected[ListBox1.Items.Count - 1] := TRUE;
    if ListBox1.Items.Count > 0 then
    begin
      ToolButton2.Enabled := TRUE;
      ToolButton3.Enabled := TRUE;
      ToolButton4.Enabled := TRUE;
    end;
    StatusBar1.Panels[0].Text := 'Ближайший день рождения будет у ' +
                                  HBBVS(HBB).Name + ' через ' +
                                  FloatToStr(HBBVS(HBB).DTB) + ' дней!'; //FloatToStr(CD(HBB[0], Date));
    StatusBar1.Panels[0].Width := Length(StatusBar1.Panels[0].Text)*6;

    if ListBox1.Items.Count < 7 then StringGrid1.DefaultColWidth := 72
    else
    StringGrid1.DefaultColWidth := 68;
    if ListBox1.Items.Count > 0 then
    begin
      if RadioButton1.Checked then SM(M2);
      if RadioButton2.Checked then SM_DTB(M2);
      if RadioButton3.Checked then SM_A(M2);
      //SM_DTB(M2);
      //M2 := HBB;
      StringGrid1.RowCount := High(HBB) + 2;
      for i := 0 to High(M2) do
      begin
        StringGrid1.Cells[0, i + 1] := IntToStr(i + 1);
        StringGrid1.Cells[1, i + 1] := DateToStr(M2[i].Date);
        StringGrid1.Cells[2, i + 1] := M2[i].Name;
        StringGrid1.Cells[3, i + 1] := FloatToStr(M2[i].Age);
        StringGrid1.Cells[4, i + 1] := FloatToStr(M2[i].DTB);
      end;
    end;
    end;
end;

procedure TForm1.StatusBar1Click(Sender: TObject);
begin
  if ListBox1.Items.Count = 1 then
  begin
    MonthCalendar1.Date := Today(HBBVS(HBB), Date);
    exit;
  end;
  if ListBox1.Items.Count > 0 then MonthCalendar1.Date := Today(HBBVS(HBB), Date);
end;

procedure TForm1.ToolButton4Click(Sender: TObject);
var i: integer;
    //M2: array of HBB_TYPE
begin

  for i := 0 to High(HBB) do
  begin
    SetLength(M2, i + 1);
    M2[i] := HBB[i];
  end;
  ToolButton3.Caption := 'Удалить';
  GroupBox2.Caption := 'Подробная информация';
  GroupBox2.Height := GroupBox_Height_More;
  Panel2.Top := 16;
  StringGrid1.Visible := TRUE;
  StringGrid1.Cells[0, 0] := 'Номер';
  StringGrid1.Cells[1, 0] := 'ДР';
  StringGrid1.Cells[2, 0] := 'Имя';
  StringGrid1.Cells[3, 0] := 'Возраст';
  StringGrid1.Cells[4, 0] := 'Дней до ДР';
  //GroupBox2.Visible := FALSE;
  if more then
  begin
    ToolButton4.Down := FALSE;
    Form1.Height := Form_Height_Default;
    ToolButton1.Down := FALSE;
    ToolButton2.Down := FALSE;
    edit := FALSE;
    new := FALSE;
    more := FALSE;
  end
  else
  begin
    more := TRUE;
    edit := FALSE;
    new := FALSE;
    ToolButton4.Down := TRUE;
    Form1.Height := Form_Height_More;  //Высота при подробностях
    ToolButton1.Down := FALSE;
    ToolButton2.Down := FALSE;
    Panel1.Visible := FALSE;
    Panel2.Visible := TRUE;
    if ListBox1.Items.Count < 7 then StringGrid1.DefaultColWidth := 72
    else
    StringGrid1.DefaultColWidth := 68;
    if ListBox1.Items.Count > 0 then
    begin
      if RadioButton1.Checked then SM(M2);
      if RadioButton2.Checked then SM_DTB(M2);
      if RadioButton3.Checked then SM_A(M2);
      //SM_DTB(M2);
      //M2 := HBB;
      StringGrid1.RowCount := High(HBB) + 2;
      for i := 0 to High(M2) do
      begin
        StringGrid1.Cells[0, i + 1] := IntToStr(i + 1);
        StringGrid1.Cells[1, i + 1] := DateToStr(M2[i].Date);
        StringGrid1.Cells[2, i + 1] := M2[i].Name;
        StringGrid1.Cells[3, i + 1] := FloatToStr(M2[i].Age);
        StringGrid1.Cells[4, i + 1] := FloatToStr(M2[i].DTB);
      end;
    end;
  end;
end;

procedure TForm1.RadioButton1Click(Sender: TObject);
var i: integer;
begin
  for i := 0 to High(HBB) do
  begin
    SetLength(M2, i + 1);
    M2[i] := HBB[i];
  end;
  if ListBox1.Items.Count < 7 then StringGrid1.DefaultColWidth := 72
  else
  StringGrid1.DefaultColWidth := 68;
  if ListBox1.Items.Count > 0 then
  begin
  if RadioButton1.Checked then SM(M2);
  if RadioButton2.Checked then SM_DTB(M2);
  if RadioButton3.Checked then SM_A(M2);
  //SM_DTB(M2);
  //M2 := HBB;
  StringGrid1.RowCount := High(HBB) + 2;
  for i := 0 to High(M2) do
  begin
    StringGrid1.Cells[0, i + 1] := IntToStr(i + 1);
    StringGrid1.Cells[1, i + 1] := DateToStr(M2[i].Date);
    StringGrid1.Cells[2, i + 1] := M2[i].Name;
    StringGrid1.Cells[3, i + 1] := FloatToStr(M2[i].Age);
    StringGrid1.Cells[4, i + 1] := FloatToStr(M2[i].DTB);
  end;
end;
end;

end.
