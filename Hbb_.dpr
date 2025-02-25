library Hbb_;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Classes;
type
  HBB_TYPE = record
    Name: String;
    Date: TDateTime;
    DTB: Double;  //DaysToBirth
    Age: Double;
  end;

{$R *.res}
function DB(Date1, Date2: TDateTime): Double; stdcall; export;  //DaysBetween
begin
  Result := Date1 - Date2;
end;

function Today(A: HBB_TYPE; Today: TDateTime): TDateTime; stdcall; export;
var S, T: String;
    Year: integer;
begin
  T := DateToStr(Today);
  S := DateToStr(A.Date);
  Year := StrToInt(Copy(T, Length(T) - 3, Length(T)));
  Delete(S, Length(S) - 3, Length(S));
  S := S + IntToStr(Year);
  Result := StrToDate(S);
end;

function HBBVS(HBB: array of HBB_TYPE): HBB_TYPE; stdcall; export;//HBB_VerySoon
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

function CY(A, Today: TDateTime): integer; stdcall; export; //CountYears
var S, S1, T: String;
    User_Year, Now_Year, Year: integer;
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

function CD(A: HBB_TYPE; Today: TDateTime): Double; stdcall; export; //CountDays
var S, T: String;
    Year: integer;
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
end;

Exports DB, Today, HBBVS, CY, CD;
begin
end.
 