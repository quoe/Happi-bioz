unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, ToolWin, Buttons, Grids, DateUtils,
  Calendar, ActnList, Menus, IniFiles, Registry, ShellApi;

type
  HBB_TYPE = record
    Name: String;
    Date: TDateTime;
    DTB: Double;  //DaysToBirth
    Age: Double;
  end;
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
    StatusBar1: TStatusBar;
    ToolButton4: TToolButton;
    StringGrid1: TStringGrid;
    Panel2: TPanel;
    RadioGroup1: TRadioGroup;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    Panel3: TPanel;
    Edit1: TEdit;
    CheckBox1: TCheckBox;
    Panel4: TPanel;
    Panel5: TPanel;
    CheckBox2: TCheckBox;
    Panel6: TPanel;
    TrackBar1: TTrackBar;
    BitBtn3: TBitBtn;
    CheckBox3: TCheckBox;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    Panel7: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    BitBtn4: TBitBtn;
    Timer1: TTimer;
    Label3: TLabel;
    Label4: TLabel;
    Splitter1: TSplitter;
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
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Panel3Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure SGWidth;
    procedure Label4Click(Sender: TObject);
  private
    { Private declarations }
    procedure OnMinimize(var Msg: TWMSysCommand); message WM_SysCommand;
  public
    { Public declarations }
    HBB: array of HBB_TYPE;
    AD: integer;  //AlarmDays
    procedure IconCallBackMessage( var Mess : TMessage ); message WM_USER + 100;
  end;

function DB(Date1, Date2: TDateTime): Double; stdcall; external 'Hbb_.dll';
function CD(A: HBB_TYPE; Today: TDateTime): Double; stdcall; external 'Hbb_.dll';
procedure SM_DTB(var A: array of HBB_TYPE);
var
  Form1: TForm1;
  IniFile: TIniFile;

implementation

uses Unit2;

function Today(A: HBB_TYPE; Today: TDateTime): TDateTime; stdcall; external 'Hbb_.dll';
function HBBVS(HBB: array of HBB_TYPE): HBB_TYPE; stdcall; external 'Hbb_.dll';
function CY(A, Today: TDateTime): integer; stdcall; external 'Hbb_.dll';

const Form_Height_Default = 250;  //Высота по умолчанию 250
      Form_Width_Default = 465;   //Ширина по умолчанию

      GroupBox_Height_Default = 129;  //Высота GroupBox по умолчанию
      GroupBox_Width_Default = 457;  //Ширина GroupBox по умолчанию
      GroupBox_Height_More = 257;  //Высота GroupBox при подробностях
      GroupBox_Height_Options = 143;  //Высота GroupBox при настройках
      GroupBox_Height_Info = 180;     //Высота GroupBox при справке

      Form_Height_New = 379;      //Высота при добавлении
      Form_Height_Edit = Form_Height_New; //Высота при изменении
      Form_Height_More = 507;  //Высота при подробностях
      Form_Height_Options = 393;  //Высота при настройках
      Form_Height_Info = 430;     //Высота при справке
      File_Name = 'data.hbb';
      Options_File_Name = 'hbb.ini';
      Help_File_Dir = 'Help\';
      Help_File_Name = 'Руководство Пользователя.htm';
      Change_File_Name = 'Изменения.txt';

      Timer = 1000;

var new, edit, more, options, info: boolean;
    names: integer;
    File_HBB: TextFile;
    M2: array of HBB_TYPE;  //HappyBirthDay, WeekToBirth

{function DB(Date1, Date2: TDateTime): Double;  //DaysBetween
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
var S, S1, T: String;
    User_Year, Now_Year: integer;
begin
  T := DateToStr(Today);
  S := DateToStr(A);
  S1 := S;
  Year := StrToInt(Copy(T, Length(T) - 3, Length(T)));
  Delete(S1, Length(S1) - 3, Length(S1));
  S1 := S1 + IntToStr(Year);
  if Round(DB(StrToDate(S1), Today)) = 0 then
  begin
    User_Year := StrToInt(Copy(S, Length(S) - 3, Length(S)));
    Now_Year := StrToInt(Copy(T, Length(T) - 3, Length(T)));
    Result := Now_Year - User_Year;
  end;
  if DB(StrToDate(S1), Today) > 0 then
  begin
    User_Year := StrToInt(Copy(S, Length(S) - 3, Length(S)));
    Now_Year := StrToInt(Copy(T, Length(T) - 3, Length(T)));
    Result := Now_Year - User_Year - 1;
  end
  else
  begin
    User_Year := StrToInt(Copy(S, Length(S) - 3, Length(S)));
    Now_Year := StrToInt(Copy(T, Length(T) - 3, Length(T)));
    Result := Now_Year - User_Year;
  end
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
  if Round(DB(StrToDate(S), Today)) = 0 then
  begin
    Result := 0;
    exit;
  end;
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
end;}

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
    OptionsFilePath: String;
    nid : TNotifyIconData;
begin
  OptionsFilePath := ExtractFilePath(Application.ExeName);
  IniFile:=TIniFile.Create(OptionsFilePath + '\' + Options_File_Name);
  if FileExists(OptionsFilePath + '\' + Options_File_Name) then
  begin
    CheckBox3.Checked := IniFile.ReadBool('НАСТРОЙКИ', 'НО', TRUE);  //Нужно Оповещать
    Edit1.Text := IniFile.ReadString('НАСТРОЙКИ', 'ДДО', '7');  //Дней До Оповещения
    CheckBox1.Checked := IniFile.ReadBool('НАСТРОЙКИ', 'ЗВСС', TRUE);   //Загружать Вместе Со Системой
    CheckBox2.Checked := IniFile.ReadBool('НАСТРОЙКИ', 'СВТПЗ', TRUE);  //Сворачивать В Трей При Запуске
    TrackBar1.Position := IniFile.ReadInteger('НАСТРОЙКИ', 'ПГФ', 255);  //Прозрачность Главной Формы
  end
  else
  begin
    IniFile.WriteBool('НАСТРОЙКИ', 'НО', TRUE);  //Нужно Оповещать
    IniFile.WriteString('НАСТРОЙКИ', 'ДДО', '7');  //Дней До Оповещения
    IniFile.WriteBool('НАСТРОЙКИ', 'ЗВСС', TRUE);   //Загружать Вместе Со Системой
    IniFile.WriteBool('НАСТРОЙКИ', 'СВТПЗ', TRUE);  //Сворачивать В Трей При Запуске
    IniFile.WriteInteger('НАСТРОЙКИ', 'ПГФ', 255);  //Прозрачность Главной Формы

    CheckBox3.Checked := IniFile.ReadBool('НАСТРОЙКИ', 'НО', TRUE);  //Нужно Оповещать
    Edit1.Text := IniFile.ReadString('НАСТРОЙКИ', 'ДДО', '7');  //Дней До Оповещения
    CheckBox1.Checked := IniFile.ReadBool('НАСТРОЙКИ', 'ЗВСС', TRUE);   //Загружать Вместе Со Системой
    CheckBox2.Checked := IniFile.ReadBool('НАСТРОЙКИ', 'СВТПЗ', TRUE);  //Сворачивать В Трей При Запуске
    TrackBar1.Position := IniFile.ReadInteger('НАСТРОЙКИ', 'ПГФ', 255);  //Прозрачность Главной Формы
    //AssignFile(File_CFG, Options_File_Name);
    //ReWrite(File_CFG);
    //CloseFile(File_CFG);
  end;
  AD := StrToInt(Edit1.Text);
  Form1.AlphaBlendValue := TrackBar1.Position;
  CheckBox1Click(Sender);
  //Form2.AlphaBlendValue := TrackBar2.Position;
  //ShowMessage('Сегодня ' + DateToStr(Date));
  Form1.Height := Form_Height_Default;  //Высота
  Form1.Width := Form_Width_Default;    //Ширина
  GroupBox1.Width := GroupBox_Width_Default;
  GroupBox2.Width := GroupBox_Width_Default;
  new := FALSE;
  edit := FALSE;
  more := FALSE;
  options := FALSE;
  info := FALSE;
  ToolButton1.Down := FALSE;
  ToolButton2.Down := FALSE;
  DateTimePicker1.Date := Date;
  if FileExists(ExtractFilePath(Application.ExeName) + '\' + File_Name) then
  begin
    ListBox1.Items.LoadFromFile(ExtractFilePath(Application.ExeName) + '\' + File_Name);
    names := ListBox1.Items.Count;
    SetLength(HBB, names);
    for i := 0 to names - 1 do FM(ListBox1.Items[i], HBB[i])
  end
  else
  begin
    AssignFile(File_HBB, ExtractFilePath(Application.ExeName) + '\' + File_Name);
    ReWrite(File_HBB);
    CloseFile(File_HBB);
  end;
  if ListBox1.Items.Count = 0 then
  begin
    StatusBar1.Panels[0].Text := 'Данных о днях рождения пока не обнаружено!';
    ListBox1.Hint := StatusBar1.Panels[0].Text;
    ToolButton2.Enabled := FALSE;
    ToolButton3.Enabled := FALSE;
    ToolButton4.Enabled := FALSE;
    BitBtn4.Enabled := FALSE;
    //PopupMenu1.Items[2].Enabled := FALSE;
    PopupMenu1.Items[3].Enabled := FALSE;
    PopupMenu1.Items[4].Enabled := FALSE;
  end;
  if ListBox1.Items.Count > 0 then
  begin
    FM(ListBox1.Items[0], HBB[0]);
    if HBBVS(HBB).DTB = 0 then
    StatusBar1.Panels[0].Text := 'ДР уже сегодня празднует ' +
                                  HBBVS(HBB).Name + '!'
    else
    if HBBVS(HBB).DTB = 1 then
    StatusBar1.Panels[0].Text := 'Ближайший ДР будет праздновать ' +
                                  HBBVS(HBB).Name + ' уже завтра!'
    else
    StatusBar1.Panels[0].Text := 'Ближайший ДР будет праздновать ' +
                                  HBBVS(HBB).Name + ' через ' +
                                  FloatToStr(CD(HBBVS(HBB), Date)) + ' дня(дней)!';
    ListBox1.Selected[0] := TRUE;
    ListBox1.Hint := ListBox1.Items[ListBox1.ItemIndex];
  end;
  StatusBar1.Panels[0].Width := Length(StatusBar1.Panels[0].Text)*6; //Length(StatusBar1.Panels[0].Text)*8
  MonthCalendar1.Date := Today(HBBVS(HBB), Date);
  GroupBox2.Visible := FALSE;
  StatusBar1.Hint := StatusBar1.Panels[0].Text;

  //Добавляем иконку в трей при старте программы:
  with nid do  //Указываем параметры иконки, для чего используем структуру
               //TNotifyIconData.
  begin
    cbSize := SizeOf( TNotifyIconData ); //Размер все структуры
    Wnd := Form1.Handle; //Здесь мы указывает Handle нашей главной формы
                         //которая будет получать сообщения от иконки.
    uID := 1;            //Идентификатор иконки
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP; //Обозначаем то, что в
                                                  //параметры входят:
                                                  //Иконка, сообщение и текст
                                                  //подсказки (хинта).
    uCallbackMessage := WM_USER + 100;            //Здесь мы указываем, какое
                                                  //сообщение должна  высылать
                                                  //иконочка нашей главной форме,
                                                  //в тот момент, когда на ней
                                                  //(иконке)  происходят
                                                  //какие-либо события
    hIcon := Application.Icon.Handle;             //Указываем на Handle
                                                  //иконки (изображения)
                                                  //(в данной случае берем
                                                  //иконку основной формы
                                                  //приложения. Ниже Вы увидите
                                                  //как можно ее изменить)
    StrPCopy(szTip, Form1.Caption);                //Указываем текст всплывающей
                                                  //посдказки, который берем из
                                                  //компонента ToolTip,
                                                  //расположенного на главной
                                                  //форме.
  end;
  Shell_NotifyIcon( NIM_ADD, @nid );
  //Собственно добавляем иконку в трей:)
  //Обратите внимание, что здесь мы исползуем константу
  //NIM_ADD (добавление иконки).
  //IconFile.Text:=Application.ExeName;
  //Выводим на главной форме пусть к файлу, который содержит
  //иконку (изображение):)
  //Icon.Picture.Icon:=Application.Icon;
  //Теперь выводим на главной форме изображение
  //иконки (изображения) в увеличенном виде
end;

procedure TForm1.ToolButton1Click(Sender: TObject);
begin
  GroupBox2.Visible := TRUE;
  Panel1.Visible := TRUE;
  Panel2.Visible := FALSE;
  Panel3.Visible := FALSE;
  Panel7.Visible := FALSE;
  GroupBox2.Height := GroupBox_Height_Default;
  ToolButton3.Caption := 'Удалить';
  BitBtn1.Kind := bkOK;
  BitBtn1.Caption := '&Добавить';
  BitBtn1.Hint := 'Добавить в список';
  GroupBox2.Caption := 'Добавление дня рождения';
  LabeledEdit1.EditLabel.Caption := 'Введите ФИО';
  LabeledEdit1.Enabled := TRUE;
  LabeledEdit1.Text := '';
  DateTimePicker1.Enabled := TRUE;
  DateTimePicker1.Date := Date;
  BitBtn1.Enabled := TRUE;
  BitBtn2.Enabled := TRUE;
  if new then
  begin
    Form1.Height := Form_Height_Default;
    ToolButton1.Down := FALSE;
    ToolButton2.Down := FALSE;
    ToolButton3.Down := FALSE;
    ToolButton4.Down := FALSE;
    ToolButton5.Down := FALSE;
    ToolButton6.Down := FALSE;
    new := FALSE;
    edit := FALSE;
    more := FALSE;
    options := FALSE;
    info := FALSE;
    GroupBox2.Visible := FALSE;
  end
  else
  begin
    new := TRUE;
    edit := FALSE;
    more := FALSE;
    options := FALSE;
    info := FALSE;
    Form1.Height := Form_Height_New;  //Высота при добавлении
    ToolButton1.Down := TRUE;
    ToolButton2.Down := FALSE;
    ToolButton3.Down := FALSE;
    ToolButton4.Down := FALSE;
    ToolButton5.Down := FALSE;
    ToolButton6.Down := FALSE;
    Panel1.Visible := TRUE;
    Panel2.Visible := FALSE;
    LabeledEdit1.SetFocus;
  end;
  Form1.Show; //Application.ShowMainForm := TRUE;
  Form1.Show;
end;

procedure TForm1.ToolButton2Click(Sender: TObject);
begin
  GroupBox2.Visible := TRUE;
  Panel2.Visible := FALSE;
  Panel1.Visible := TRUE;
  Panel3.Visible := FALSE;
  Panel7.Visible := FALSE;
  GroupBox2.Height := GroupBox_Height_Default;
  ToolButton3.Caption := 'Удалить';
  BitBtn1.Kind := bkRetry;
  BitBtn1.Caption := '&Изменить';
  BitBtn1.Hint := 'Применить изменения';
  GroupBox2.Caption := 'Изменение дня рождения';
  LabeledEdit1.EditLabel.Caption := 'ФИО';
  LabeledEdit1.Enabled := FALSE;
  LabeledEdit1.Text := 'Сначала выберите кого изменять';
  DateTimePicker1.Enabled := FALSE;
  BitBtn1.Enabled := FALSE;
  //BitBtn2.Enabled := FALSE;
  if edit then
  begin
    Form1.Height := Form_Height_Default;
    ToolButton1.Down := FALSE;
    ToolButton2.Down := FALSE;
    ToolButton3.Down := FALSE;
    ToolButton4.Down := FALSE;
    ToolButton5.Down := FALSE;
    ToolButton6.Down := FALSE;
    edit := FALSE;
    new := FALSE;
    more := FALSE;
    options := FALSE;
    info := FALSE;
    GroupBox2.Visible := FALSE;
  end
  else
  begin
    edit := TRUE;
    new := FALSE;
    more := FALSE;
    options := FALSE;
    info := FALSE;
    Form1.Height := Form_Height_Edit;  //Высота при изменении
    ToolButton1.Down := FALSE;
    ToolButton2.Down := TRUE;
    ToolButton3.Down := FALSE;
    ToolButton4.Down := FALSE;
    ToolButton5.Down := FALSE;
    ToolButton6.Down := FALSE;
    Panel1.Visible := TRUE;
    Panel2.Visible := FALSE;
  end;
  Form1.Show; //Application.ShowMainForm := TRUE;
  Form1.Show;
end;

procedure TForm1.ToolButton5Click(Sender: TObject);
begin
  GroupBox2.Visible := TRUE;
  Panel2.Visible := FALSE;
  Panel1.Visible := FALSE;
  Panel3.Visible := TRUE;
  Panel7.Visible := FALSE;
  Panel3.Left := 8;
  Panel3.Top := 16;
  GroupBox2.Caption := 'Настройки';
  ToolButton3.Caption := 'Удалить';
  GroupBox2.Height := GroupBox_Height_Options;
  if options then
  begin
    ToolButton1.Down := FALSE;
    ToolButton2.Down := FALSE;
    ToolButton3.Down := FALSE;
    ToolButton4.Down := FALSE;
    ToolButton5.Down := FALSE;
    ToolButton6.Down := FALSE;
    Form1.Height := Form_Height_Default;
    edit := FALSE;
    new := FALSE;
    more := FALSE;
    options := FALSE;
    info := FALSE;
    GroupBox2.Visible := FALSE;
  end
  else
  begin
    more := FALSE;
    edit := FALSE;
    new := FALSE;
    options := TRUE;
    info := FALSE;
    ToolButton1.Down := FALSE;
    ToolButton2.Down := FALSE;
    ToolButton3.Down := FALSE;
    ToolButton4.Down := FALSE;
    ToolButton5.Down := TRUE;
    ToolButton6.Down := FALSE;
    Form1.Height := Form_Height_Options;  //Высота при настройках
    Panel1.Visible := FALSE;
    Panel2.Visible := FALSE;
  end;
  Form1.Show; //Application.ShowMainForm := TRUE;
  Form1.Show;
end;

procedure TForm1.ToolButton6Click(Sender: TObject);
begin
  GroupBox2.Visible := TRUE;
  Panel2.Visible := FALSE;
  Panel1.Visible := FALSE;
  Panel3.Visible := FALSE;
  Panel7.Visible := TRUE;
  GroupBox2.Caption := 'Справка';
  ToolButton3.Caption := 'Удалить';
  Label1.Caption := 'Программа напоминаний "' + Form1.Caption + '"';  //' + #13#10 + '
  Label2.Caption := 'Версия 1.1' + #13#10 + #13#10 + 'Авторское право © 2012 Кучеров Р. М.' + #13#10 +
                    'Надеюсь, большинство прав защищено.' + #13#10 + #13#10 +
                    'Любую критику, вопросы, предложения - ' + #13#10 +
                    'с радостью почитаю по адресу quoe@mail.ru';
  Label3.Caption := 'А всем вам советую же почитать' + #13#10 +
                    'документацию. Не зря же я её писал...';
  Panel7.Left := 8;
  Panel7.Top := 16;
  GroupBox2.Height := GroupBox_Height_Info;
  if info then
  begin
    ToolButton1.Down := FALSE;
    ToolButton2.Down := FALSE;
    ToolButton3.Down := FALSE;
    ToolButton4.Down := FALSE;
    ToolButton5.Down := FALSE;
    ToolButton6.Down := FALSE;
    Form1.Height := Form_Height_Default;
    edit := FALSE;
    new := FALSE;
    more := FALSE;
    options := FALSE;
    info := FALSE;
    GroupBox2.Visible := FALSE;
  end
  else
  begin
    more := FALSE;
    edit := FALSE;
    new := FALSE;
    options := FALSE;
    info := TRUE;
    ToolButton1.Down := FALSE;
    ToolButton2.Down := FALSE;
    ToolButton3.Down := FALSE;
    ToolButton4.Down := FALSE;
    ToolButton5.Down := FALSE;
    ToolButton6.Down := TRUE;
    Form1.Height := Form_Height_Info;  //Высота при настройках
    Panel1.Visible := FALSE;
    Panel2.Visible := FALSE;
  end;
  Form1.Show; //Application.ShowMainForm := TRUE;
  Form1.Show;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var i, k: integer;
    S: string;
begin
  S := DatetoStr(Round(DateTimePicker1.Date)) + ' - ' + LabeledEdit1.Text;
  if (LabeledEdit1.Text = '') then
  begin
    ShowMessage('Вы ничего не ввели!');
    exit;
  end;
  if (AnsiLowerCase(LabeledEdit1.Text) = 'showmeform2_please') then
  begin
    Form2.Show;
    exit;
  end;
  if (AnsiLowerCase(LabeledEdit1.Text) = 'автор этой программы') or
     (AnsiLowerCase(LabeledEdit1.Text) = 'quoe@mail.ru')  then
  begin
    LabeledEdit1.Text := 'Кучеров Р. М';
    DateTimePicker1.Date := StrToDate('11.01.1994');
  end;
  if (ListBox1.Items.Count < names + 2) and not edit then
  begin
    ListBox1.Items[names] := Trim(DateToStr(DateTimePicker1.Date) + ' - ' + LabeledEdit1.Text);
  end;
  if new then
  begin
    BitBtn1.Caption := '&Добавлено!';
    Timer1.Interval := Timer;
    inc(names);
    SetLength(HBB, names);
    FM(ListBox1.Items[names - 1], HBB[names - 1]);
    //ListBox1.Selected[ListBox1.Items.Count - 1] := TRUE;

    {for i := 0 to High(HBB) - 1 do
    if (HBB[i].Name = HBB[ListBox1.ItemIndex].Name) and
       (HBB[i].Date = HBB[ListBox1.ItemIndex].Date) then
    begin
      ListBox1.Items.Delete(ListBox1.ItemIndex);
      SetLength(HBB, names - 1);
      dec(names);
      ShowMessage('Такой человек уже есть!');
      exit;
    end;}

    for i := 0 to ListBox1.ItemIndex - 1 do
    if (HBB[i].Name = HBB[ListBox1.ItemIndex].Name) and
       (HBB[i].Date = HBB[ListBox1.ItemIndex].Date) then
    begin
      ListBox1.Items.Delete(ListBox1.ItemIndex);
      SetLength(HBB, names - 1);
      dec(names);
      ShowMessage('Такой человек уже есть!');
      exit;
    end;
    LabeledEdit1.Text := '';
    LabeledEdit1.SetFocus;
  end;
  if edit then
  begin
    BitBtn1.Caption := '&Изменено!';
    Timer1.Interval := Timer;
    HBB[ListBox1.ItemIndex].Name := LabeledEdit1.Text;  //LabeledEdit1.Text
    HBB[ListBox1.ItemIndex].Date := DateTimePicker1.Date;
    ListBox1.Items[ListBox1.ItemIndex] := RLB(HBB[ListBox1.ItemIndex]);
    FM(ListBox1.Items[ListBox1.ItemIndex], HBB[ListBox1.ItemIndex]);
    LabeledEdit1.Enabled := FALSE;
    DateTimePicker1.Enabled := FALSE;
    BitBtn1.Enabled := FALSE;
    //BitBtn2.Enabled := FALSE;
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
    BitBtn4.Enabled := TRUE;
    //PopupMenu1.Items[2].Enabled := TRUE;
    PopupMenu1.Items[3].Enabled := TRUE;
    PopupMenu1.Items[4].Enabled := TRUE;
  end;
    if HBBVS(HBB).DTB = 0 then
    StatusBar1.Panels[0].Text := 'ДР уже сегодня празднует ' +
                                  HBBVS(HBB).Name + '!'
    else
    if HBBVS(HBB).DTB = 1 then
    StatusBar1.Panels[0].Text := 'Ближайший ДР будет праздновать ' +
                                  HBBVS(HBB).Name + ' уже завтра!'
    else
    StatusBar1.Panels[0].Text := 'Ближайший ДР будет праздновать ' +
                                  HBBVS(HBB).Name + ' через ' +
                                  FloatToStr(CD(HBBVS(HBB), Date)) + ' дня(дней)!';
  StatusBar1.Panels[0].Width := Length(StatusBar1.Panels[0].Text)*6; //FloatToStr(CD(HBB[0], Date));
  MonthCalendar1.Date := Today(HBBVS(HBB), Date);
  DateTimePicker1.Date := Date;
  ListBox1.Hint := ListBox1.Items[ListBox1.ItemIndex];
  StatusBar1.Hint := StatusBar1.Panels[0].Text;
  k := listbox1.Items.IndexOf(S);
  ListBox1.Selected[k] := TRUE;
  {for i := 0 to High(HBB) do
    if listbox1.Items[i] = S then k := i;
    ListBox1.Selected[k] := TRUE;}
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
  if (ListBox1.Items.Count > 0) and edit then
  begin
    LabeledEdit1.Enabled := TRUE;
    DateTimePicker1.Enabled := TRUE;
    BitBtn1.Enabled := TRUE;
    BitBtn2.Enabled := TRUE;
    BitBtn4.Enabled := TRUE;
    //PopupMenu1.Items[2].Enabled := TRUE;
    PopupMenu1.Items[3].Enabled := TRUE;
    PopupMenu1.Items[4].Enabled := TRUE;
    LabeledEdit1.Text := HBB[ListBox1.ItemIndex].Name;  //ListBox1.Items[ListBox1.ItemIndex
    DateTimePicker1.Date := HBB[ListBox1.ItemIndex].Date;
  end;
  if (ListBox1.Items.Count > 0) then MonthCalendar1.Date := HBB[ListBox1.ItemIndex].Date;
  ToolButton3.Caption := 'Удалить';
  ListBox1.Hint := ListBox1.Items[ListBox1.ItemIndex];
  StatusBar1.Hint := StatusBar1.Panels[0].Text;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
  if FileExists(ExtractFilePath(Application.ExeName) + '\' + File_Name) then
  begin
    ListBox1.Items.SaveToFile(ExtractFilePath(Application.ExeName) + '\' + File_Name);
  end
  else
  begin
    AssignFile(File_HBB, ExtractFilePath(Application.ExeName) + '\' + File_Name);
    ReWrite(File_HBB);
    CloseFile(File_HBB);
    ListBox1.Items.SaveToFile(ExtractFilePath(Application.ExeName) + '\' + File_Name);
  end;
  BitBtn2.Caption := '&Сохранено!';
  Timer1.Interval := Timer;
end;

procedure TForm1.MonthCalendar1GetMonthInfo(Sender: TObject;
  Month: Cardinal; var MonthBoldInfo: Cardinal);
begin
  if ListBox1.Items.Count = 0 then MonthCalendar1.Date := Date;
end;

procedure TForm1.SGWidth;
begin
    if ListBox1.Items.Count < 7 then
    begin
      StringGrid1.ColWidths[0] := 60;
      StringGrid1.ColWidths[1] := 228;
      StringGrid1.ColWidths[2] := 47;
      StringGrid1.ColWidths[3] := 66;
      //StringGrid1.DefaultColWidth := 90
    end
    else
    begin
      StringGrid1.ColWidths[0] := 60;
      StringGrid1.ColWidths[1] := 210;
      StringGrid1.ColWidths[2] := 47;
      StringGrid1.ColWidths[3] := 66;
      //StringGrid1.DefaultColWidth := 86;
    end;
end;

procedure TForm1.ToolButton3Click(Sender: TObject);
var i: integer;
begin
  if ListBox1.Items.Count = 0 then
  begin
    StatusBar1.Panels[0].Text := 'Данных о днях рождения пока не обнаружено!';
    ListBox1.Hint := StatusBar1.Panels[0].Text;
    ToolButton2.Enabled := FALSE;
    ToolButton3.Enabled := FALSE;
    ToolButton4.Enabled := FALSE;
    BitBtn4.Enabled := FALSE;
    //PopupMenu1.Items[2].Enabled := FALSE;
    PopupMenu1.Items[3].Enabled := FALSE;
    PopupMenu1.Items[4].Enabled := FALSE;
    exit;
  end;
  if ToolButton3.Caption = 'Удалить' then ToolButton3.Caption := 'Уверены?'
  else
  if (ToolButton3.Caption = 'Уверены?') and (ListBox1.Items.Count <> 0) then
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
      //PopupMenu1.Items[2].Enabled := FALSE;
      PopupMenu1.Items[3].Enabled := FALSE;
      PopupMenu1.Items[4].Enabled := FALSE;
      ToolButton1.Down := FALSE;
      ToolButton2.Down := FALSE;
      ToolButton4.Down := FALSE;
      BitBtn4.Enabled := FALSE;
      new := FALSE;
      edit := FALSE;
      more := FALSE;
      ToolButton2.Enabled := FALSE;
      ToolButton3.Enabled := FALSE;
      ToolButton4.Enabled := FALSE;
      Form1.Height := Form_Height_Default;
      StatusBar1.Panels[0].Text := 'Данных о днях рождения пока не обнаружено!';
      ListBox1.Hint := StatusBar1.Panels[0].Text;
      StatusBar1.Hint := StatusBar1.Panels[0].Text;
      exit;
    end;
    ListBox1.Selected[ListBox1.Items.Count - 1] := TRUE;
    if ListBox1.Items.Count > 0 then
    begin
      ToolButton2.Enabled := TRUE;
      ToolButton3.Enabled := TRUE;
      ToolButton4.Enabled := TRUE;
      BitBtn4.Enabled := TRUE;
      //PopupMenu1.Items[2].Enabled := TRUE;
      PopupMenu1.Items[3].Enabled := TRUE;
      PopupMenu1.Items[4].Enabled := TRUE;
    end;
    if HBBVS(HBB).DTB = 0 then
    StatusBar1.Panels[0].Text := 'ДР уже сегодня празднует ' +
                                  HBBVS(HBB).Name + '!'
    else
    if HBBVS(HBB).DTB = 1 then
    StatusBar1.Panels[0].Text := 'Ближайший ДР будет праздновать ' +
                                  HBBVS(HBB).Name + ' уже завтра!'
    else
    StatusBar1.Panels[0].Text := 'Ближайший ДР будет праздновать ' +
                                  HBBVS(HBB).Name + ' через ' +
                                  FloatToStr(CD(HBBVS(HBB), Date)) + ' дня(дней)!';
    StatusBar1.Panels[0].Width := Length(StatusBar1.Panels[0].Text)*6;
    SGWidth;
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
        StringGrid1.Cells[0, i + 1] := DateToStr(M2[i].Date);
        StringGrid1.Cells[1, i + 1] := M2[i].Name;
        StringGrid1.Cells[2, i + 1] := FloatToStr(M2[i].Age);
        StringGrid1.Cells[3, i + 1] := FloatToStr(M2[i].DTB);
      end;
      ListBox1.Hint := ListBox1.Items[ListBox1.ItemIndex];
      StatusBar1.Hint := StatusBar1.Panels[0].Text;
    end;
    end;
end;

procedure TForm1.StatusBar1Click(Sender: TObject);
begin
  ToolButton3.Caption := 'Удалить';
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
  GroupBox2.Visible := TRUE;
  Panel2.Visible := TRUE;
  Panel1.Visible := FALSE;
  Panel3.Visible := FALSE;
  Panel7.Visible := FALSE;
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
  {StringGrid1.Cells[0, 0] := 'Номер';
  StringGrid1.Cells[1, 0] := 'ДР';
  StringGrid1.Cells[2, 0] := 'Имя';
  StringGrid1.Cells[3, 0] := 'Возраст';
  StringGrid1.Cells[4, 0] := 'Дней до ДР';}

  StringGrid1.Cells[0, 0] := 'ДР';
  StringGrid1.Cells[1, 0] := 'Имя';
  StringGrid1.Cells[2, 0] := 'Возраст';
  StringGrid1.Cells[3, 0] := 'Дней до ДР';

  //GroupBox2.Visible := FALSE;
  if more then
  begin
    ToolButton1.Down := FALSE;
    ToolButton2.Down := FALSE;
    ToolButton3.Down := FALSE;
    ToolButton4.Down := FALSE;
    ToolButton5.Down := FALSE;
    ToolButton6.Down := FALSE;
    Form1.Height := Form_Height_Default;
    edit := FALSE;
    new := FALSE;
    more := FALSE;
    options := FALSE;
    info := FALSE;
    GroupBox2.Visible := FALSE;
  end
  else
  begin
    more := TRUE;
    edit := FALSE;
    new := FALSE;
    options := FALSE;
    info := FALSE;
    ToolButton1.Down := FALSE;
    ToolButton2.Down := FALSE;
    ToolButton3.Down := FALSE;
    ToolButton4.Down := TRUE;
    ToolButton5.Down := FALSE;
    ToolButton6.Down := FALSE;
    Form1.Height := Form_Height_More;  //Высота при подробностях
    Panel1.Visible := FALSE;
    Panel2.Visible := TRUE;
    SGWidth;
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
        {StringGrid1.Cells[0, i + 1] := IntToStr(i + 1);
        StringGrid1.Cells[1, i + 1] := DateToStr(M2[i].Date);
        StringGrid1.Cells[2, i + 1] := M2[i].Name;
        StringGrid1.Cells[3, i + 1] := FloatToStr(M2[i].Age);
        StringGrid1.Cells[4, i + 1] := FloatToStr(M2[i].DTB);}

        StringGrid1.Cells[0, i + 1] := DateToStr(M2[i].Date);
        StringGrid1.Cells[1, i + 1] := M2[i].Name;
        StringGrid1.Cells[2, i + 1] := FloatToStr(M2[i].Age);
        StringGrid1.Cells[3, i + 1] := FloatToStr(M2[i].DTB);
      end;
    end;
  end;
  Form1.Show; //Application.ShowMainForm := TRUE;
  Form1.Show;
end;

procedure TForm1.RadioButton1Click(Sender: TObject);
var i: integer;
begin
  for i := 0 to High(HBB) do
  begin
    SetLength(M2, i + 1);
    M2[i] := HBB[i];
  end;
  SGWidth;
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
    StringGrid1.Cells[0, i + 1] := DateToStr(M2[i].Date);
    StringGrid1.Cells[1, i + 1] := M2[i].Name;
    StringGrid1.Cells[2, i + 1] := FloatToStr(M2[i].Age);
    StringGrid1.Cells[3, i + 1] := FloatToStr(M2[i].DTB);
  end;
end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Form2.Show;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var nid : TNotifyIconData;
begin
  with nid do
  begin
    cbSize := SizeOf( TNotifyIconData );
    Wnd := Form1.Handle;
    uID := 1;
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
    uCallbackMessage := WM_USER + 100;
    hIcon := Application.Icon.Handle;
    StrPCopy(szTip, Form1.Caption);
  end;
  Shell_NotifyIcon( NIM_DELETE, @nid );
  //Удаляем иконку из трея. Параметры мы вводим для того,
  //чтобы функция точно знала, какую именно иконку надо удалять.
  //Обратите внимание, что здесь мы исползуем константу
  //NIM_DELETE (удаление иконки)
end;

procedure TForm1.IconCallBackMessage( var Mess : TMessage );
var P: TPoint;
begin
  GetCursorPos(P);
  case Mess.lParam of
    //Здесь Вы можете обрабатывать все события, происходящие на иконке:)
    //На главнй форме я специально расположил две метки, в которых,
    //при возникновении какого-либо события будет писаться что именно произошло:)
    //Но, теперь во второй части во время некоторых событий будут происходит
    //реальные процессы.
    //WM_LBUTTONDBLCLK  : TI_DC.Caption   := 'Двойной щелчок левой кнопкой'       ;
    //WM_LBUTTONDOWN    : TI_Event.Caption:= 'Нажатие левой кнопки мыши'          ;
    WM_LBUTTONUP: //'Отжатие левой кнопки мыши'
    begin
      Form1.Show; //Application.ShowMainForm := TRUE;
      Form1.Show;
      PopupMenu1.FreeOnRelease;
      //Form1.WindowState := wsNormal;
    end;
    //WM_RBUTTONDOWN    : TI_Event.Caption:= 'Нажатие правой кнопки мыши'         ;
    WM_RBUTTONUP: PopupMenu1.Popup(P.X, P.Y);//'Отжатие правой кнопки мыши'         ;
  end;
end;


procedure TForm1.OnMinimize(var Msg: TWMSysCommand);
begin
 if Msg.CmdType = SC_MINIMIZE then
 begin
   Form1.Hide;
   //Form1.Visible := FALSE;
   //Application.ShowMainForm := FALSE;
 end
 else inherited;
end;

procedure TForm1.N1Click(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.N2Click(Sender: TObject);
begin
  Form1.Show; //Application.ShowMainForm := TRUE;
  Form1.Show;
end;

procedure TForm1.BitBtn3Click(Sender: TObject);
begin
  IniFile.WriteBool('НАСТРОЙКИ', 'НО', CheckBox3.Checked);  //Нужно Оповещать
  IniFile.WriteString('НАСТРОЙКИ', 'ДДО', Edit1.Text);  //Дней До Оповещения
  IniFile.WriteBool('НАСТРОЙКИ', 'ЗВСС', CheckBox1.Checked);   //Загружать Вместе Со Системой
  IniFile.WriteBool('НАСТРОЙКИ', 'СВТПЗ', CheckBox2.Checked);  //Сворачивать В Трей При Запуске
  IniFile.WriteInteger('НАСТРОЙКИ', 'ПГФ', TrackBar1.Position);  //Прозрачность Главной Формы
  BitBtn3.Caption := '&Применено!';
  Timer1.Interval := Timer;
  CheckBox1Click(Sender);
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  Form1.AlphaBlendValue := TrackBar1.Position;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
var Reg: TRegistry;
begin
  if CheckBox1.Checked then
  begin
     Reg := TRegistry.Create;
     Reg.RootKey := HKEY_CURRENT_USER;
     Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', false);
     Reg.WriteString(Form1.Caption, Application.ExeName);
     Reg.Free;
  end
  else
  begin
     Reg := TRegistry.Create;
     Reg.RootKey := HKEY_CURRENT_USER;
     Reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',false);
     Reg.DeleteValue(Form1.Caption);
     Reg.Free;
  end;
end;

procedure TForm1.BitBtn4Click(Sender: TObject);
begin
  if BitBtn4.Caption = '&Очистить список' then BitBtn4.Caption := '&Уверены?'
  else
  if (BitBtn4.Caption = '&Уверены?') and (ListBox1.Items.Count <> 0) then
  begin
    SetLength(HBB, 0);
    ListBox1.Clear;
    ToolButton3.Click;
    names := 0;
    BitBtn4.Caption := '&Список чист!';
    Timer1.Interval := Timer;
    BitBtn4.Enabled := FALSE;
  end;
  ListBox1.Hint := StatusBar1.Panels[0].Text;
  StatusBar1.Hint := StatusBar1.Panels[0].Text;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if BitBtn3.Caption = '&Применено!' then BitBtn3.Caption := '&Применить всё';
  if BitBtn4.Caption = '&Список чист!' then BitBtn4.Caption := '&Очистить список';
  if BitBtn2.Caption = '&Сохранено!' then BitBtn2.Caption := '&Сохранить';
  if new then BitBtn1.Caption := '&Добавить';
  if edit then BitBtn1.Caption := '&Изменить';
end;

procedure TForm1.Panel3Click(Sender: TObject);
begin
  BitBtn4.Caption := '&Очистить список'
end;

procedure TForm1.Label3Click(Sender: TObject);
var ExeFilePath: String;
    FullHelpFilePath: PansiChar;
begin
  ExeFilePath := ExtractFilePath(Application.ExeName);
  FullHelpFilePath := PAnsiChar(ExeFilePath + Help_File_Dir + Help_File_Name);
  if FileExists(FullHelpFilePath) then
  ShellExecute(0, nil, FullHelpFilePath, nil, nil, SW_SHOWNORMAL)
  else
  ShowMessage('Упс, неувязочки.. Руководство пользователя не найдено!' + #13 + 'Кто забрал просьба вернуть на место, я на самом деле старался его чепятать!');
end;

procedure TForm1.FormClick(Sender: TObject);
begin
  ToolButton3.Caption := 'Удалить';
end;

procedure TForm1.Label4Click(Sender: TObject);
var ExeFilePath: String;
    FullChangeFilePath: PansiChar;
begin
  ExeFilePath := ExtractFilePath(Application.ExeName);
  FullChangeFilePath := PAnsiChar(ExeFilePath + Change_File_Name);
  if FileExists(FullChangeFilePath) then
  ShellExecute(0, nil, FullChangeFilePath, nil, nil, SW_SHOWNORMAL)
  else
  ShowMessage('Упс, неувязочки.. Список изменений не найден!' + #13 + 'Кто забрал просьба вернуть на место, его я тоже старался чепятать!');
end;

end.
