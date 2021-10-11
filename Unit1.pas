unit Unit1;

interface

uses
  Windows, SysUtils, Controls, Forms,  Messages, Dialogs, Grids,
  Clipbrd,  Digit, ExtCtrls, Menus, StdCtrls, Classes, Graphics;

type
  TForm1 = class(TForm)
    Menu: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Save: TSaveDialog;
    Panel1: TPanel;
    Button1: TButton;
    FileGrid: TStringGrid;
    N4: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    Copypaths: TCheckBox;
    Image1: TImage;
    CopySizes: TCheckBox;
    DoDirs: TCheckBox;
    AllSize: Tdigit;
    AllFiles: Tdigit;
    Label3: TLabel;
    AskDirs: TCheckBox;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    N5: TMenuItem;
    Timetodo: Tdigit;
    Bevel4: TBevel;
    Label4: TLabel;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure FileGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure Panel1CanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure Panel1Resize(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    procedure WMDROPFILES(var Message: TWMDROPFILES);
      message WM_DROPFILES;
    { Private declarations }
  public
    { Public declarations }
  end;
{  Tfilelist = object
   private
   buffp: array of Pchar;
   buffn: array of Pchar;
   buffs: array of Integer;
   fcnt:integer;
   Function ReadName(Index: Integer): String;
   Function ReadPath(Index: Integer): String;
   Function ReadSize(Index: Integer): Integer;
   public
   Property count: integer read fcnt;
    // Index from 1 to Count !!!
   Property Name[Index:integer]:string read Readname;
   Property Path[Index:integer]:string read ReadPath;
   Property Size[Index:integer]:Integer read ReadSize;
   Constructor Init;
   Procedure Add(fullfilename: string);
   Procedure Delete(Index:integer);
   Procedure Clear;
  end;}
var
  Form1: TForm1;
//  filelist: Tfilelist;

implementation

uses ShellApi;
Var  All_sizes: INT64;
     All_Files: integer;
{$R *.dfm}
Procedure findlastmath(str1,str2:string; var findtopos:integer);
// функция возвращает длину строки совпадающей
// в обеих подстроках начиная с первого символа
// и заканчивая указанным
Var a: integer;
 begin
  if length(str1) < findtopos then findtopos :=length(str1);
  if length(str2) < findtopos then findtopos :=length(str2);
  For a:=1 to findtopos do
    if str1[a] <> str2[a] then break;
  findtopos := a-1;
 end;

Procedure Addtolist(Filename:string);
Procedure AddtoNewrow(path,nam,size:string);
VAR Rowtoadd :integer;
begin
With Form1 do
begin
//Memo1.Lines.Add(Path+'#'+nam+'#'+size);
  // Filegrid.RowCount = 1 - вообще ненормальная ситуация, исправляем.
If (Filegrid.RowCount = 1) then Filegrid.RowCount := Filegrid.RowCount + 1;
If (Filegrid.RowCount = 2) and
   (Filegrid.Cells[0,1]='') then Rowtoadd := 1
                            else
                            begin
                             Rowtoadd := Filegrid.RowCount;
                             Filegrid.RowCount := Filegrid.RowCount + 1;
                            end;
 Filegrid.Cells[0,RowToadd] := inttostr(RowToadd);
 Filegrid.Cells[1,RowToadd] :=path;
 Filegrid.Cells[2,RowToadd] :=nam;
 Filegrid.Cells[3,RowToadd] :=size;
end; // With
end;
Procedure ScanDir(path:string);
var srs      :TSearchRec;
    filefound: boolean;
 begin
  Form1.AllSize.Value := All_sizes div 1024;
  Form1.AllFiles.Value := All_Files;
  application.ProcessMessages;
  filefound := false;
  if FindFirst(path+'\*.*',faAnyFile,srs) = 0 then
   begin
   While findnext(srs) = 0 do
    begin
     if srs.Name = '..' then continue;
     filefound := true;
     if (srs.Attr and faDirectory) <> 0 then // сканируем подкаталог
         Scandir(path+'\'+srs.Name)
      ELSE // Обрабатываем как файл
       begin
        AddtoNewrow(path+'\',srs.name,inttostr(srs.Size));
        All_sizes := All_sizes + srs.Size;
        Inc(All_files);
       end;
    end; // Цикл FindNext
   end;
   findclose(srs);
   if not filefound then AddtoNewrow(Extractfilepath(path),Extractfilename(path),'Папка');
 end;

var sr       :TSearchRec;
//    Newrow   :boolean;
 begin // BEGIN OF Addtolist(Filename:string);
With Form1 do
begin
 if FindFirst(filename,faAnyFile,sr) = 0 then
  begin
    if (sr.Attr and faDirectory) <> 0 then
       begin // Добавляем ПАПКУ в список
        If Dodirs.Checked then // Добавляем подветку
          scandir(filename)
         else // Иначе - добавляем запись о том что это папка и все тут.
          addtonewrow(Extractfilepath(filename),extractfilename(filename),'Папка');
       end
      else
      Begin // добавляем ФАЙЛ в список
       addtonewrow(Extractfilepath(filename),extractfilename(filename),inttostr(sr.Size));
       All_sizes := All_sizes + sr.Size;
       Inc(All_files);
      end;
  end
    else // Какая-то ошибка, кто знает, когда-нибудь да возикнет
         // типа файла-то нету уже пока там перетаскивали ...
     addtonewrow(Extractfilepath(filename),extractfilename(filename),'Н/Д');
 findclose(sr);
end; {With ...}
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
// HotKeyctrlC:=HotKey.AddHotKey(TextToHotKey('Ctrl+C',false));
 DragAcceptFiles(Form1.Handle, True);
 FileGrid.Cells[0,0]:='*';
 FileGrid.Cells[1,0]:='Путь';
 FileGrid.Cells[2,0]:='Файл';
 FileGrid.Cells[3,0]:='Размер';
 panel1.Constraints.MinWidth := button1.Left + button1.Width + 6 + timetodo.Width;
end;

procedure TForm1.WMDROPFILES(var Message: TWMDROPFILES);
var
  NumFiles : longint;
  i : longint;
  buffer : array[0..1024] of char;
  strt : Tdatetime;
  hr, min, sec, msec : word;
  st: string;
begin
 {How many files are being dropped}
 If AskDirs.Checked then
   begin
    DoDirs.Checked := application.MessageBox('Сканировать подкаталоги?',
                              'Список файлов',MB_YESNO) = IDYes;
   end;
 strt:=now;
  NumFiles := DragQueryFile(Message.Drop,
                            cardinal(-1),
                            nil,
                            0);
 {Accept the dropped files}
  for i := 0 to (NumFiles - 1) do begin
    DragQueryFile(Message.Drop,
                  i,
                  @buffer,
                  sizeof(buffer));
    Addtolist(buffer);
  end;
  decodetime(now - strt, hr, min, sec, msec);
  Timetodo.Caption := format('%2d:%2d:%3d',[min, sec, msec]);
  st:=Timetodo.Caption;
  for sec := 1 to length (st) do
   if st[sec] = ' ' then st[sec]:='0';
  Timetodo.Caption:=st;
  Allsize.Value := All_sizes div 1024;
  Allfiles.Value := All_Files;
end;

procedure TForm1.N1Click(Sender: TObject);
Var fs:Tfilestream;
    st:Pchar;
    a: integer;
begin
 Save.Filter:='*.txt';
 Save.DefaultExt:='*.txt';
 Save.Title:='Сохранение списка файлов';
 if save.FileName = '' then save.filename:='*.txt';
 If Save.Execute then
  begin
  fs := TFileStream.Create(Save.filename, fmCreate or fmOpenWrite);
  With Form1.FileGrid do
   begin
    for a:=1 to RowCount -1 do
     begin
      st := Pchar(Cells[1,a]+ Cells[2,a]+ #09 + Cells[3,a] + #13 + #10);
      fs.Write(st^, Length(st));
     end;
   end;
  fs.Free;
 end;
end;

procedure TForm1.N2Click(Sender: TObject);
begin
 {Filelist.Clear;}
 FileGrid.RowCount := 2;
 All_sizes := 0;
 All_files := 0;
 allfiles.Value:=0;
 allsize.Value:=0;
 Filegrid.Cells[0,1]:='';
 Filegrid.Cells[1,1]:='';
 Filegrid.Cells[2,1]:='';
 Filegrid.Cells[3,1]:='';
end;

procedure TForm1.N3Click(Sender: TObject);
begin
 application.Terminate;
end;

procedure TForm1.FileGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
Var a: integer;
begin
  if key = 46 {delete} then
    begin
     for a:=FileGrid.Row to Filegrid.RowCount-2 do
      Filegrid.Rows[a] := Filegrid.Rows[a+1];
      if Filegrid.RowCount>2 then Filegrid.RowCount:=Filegrid.RowCount-1
                             else
                              begin
                               Filegrid.Cells[0,1]:='';
                               Filegrid.Cells[1,1]:='';
                               Filegrid.Cells[2,1]:='';
                               Filegrid.Cells[3,1]:='';
                              end;
    end;
end;

procedure TForm1.N4Click(Sender: TObject);
{В буффер все}
Var buff :Pchar;
    a    :integer;
    strs: Tstrings;
begin
    strs:=TstringList.Create;
   try
    for a:=1 to Filegrid.RowCount -1 do
      strs.Add(Filegrid.Cells[1,a] + Filegrid.Cells[2,a] + #09 + Filegrid.Cells[3,a]);
    buff:=Pchar(strs.text);
    Clipboard.SetTextBuf(buff);
   finally strs.Free;
   end;

end;

procedure TForm1.N5Click(Sender: TObject);
{В буффер только имена}
Var buff :Pchar;
    a    :integer;
    strs: Tstrings;
begin
    strs:=TstringList.Create;
   try
    for a:=1 to Filegrid.RowCount -1 do
     begin
      strs.Add(Filegrid.Cells[2,a]);
     end;
    buff:=Pchar(strs.text);
    Clipboard.SetTextBuf(buff);
   finally strs.Free;
   end;

end;

procedure TForm1.Panel1CanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
 Resize := (NewWidth - button1.Left - button1.Width - 5 - timetodo.Width) > 0;
end;

procedure TForm1.Panel1Resize(Sender: TObject);
begin
 Timetodo.Left := panel1.Width - Timetodo.Width - 2;
 bevel3.Width := panel1.Width - 3;
end;
Var step: integer;
procedure TForm1.Image1Click(Sender: TObject);
begin
 if step <0 then step := 4 else step := -10;
 timer1.Enabled := true;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
 if step < 0 then
   if panel1.Height <= (bevel3.Top) then
    begin Panel1.Height := bevel3.Top + 2;Timer1.Enabled := false end
    else panel1.Height := panel1.Height + step;
 if step > 0 then
   if panel1.Height >= (Bevel4.Top + Bevel4.Height) then
    begin Panel1.Height := Bevel4.Top + Bevel4.Height;Timer1.Enabled := false end
    else panel1.Height := panel1.Height + step;
end;

procedure TForm1.Button1Click(Sender: TObject);
Var buff :Pchar;
    st   :string;
    a    :integer;
    strs: Tstrings;
begin
    strs:=TstringList.Create;
   try
    for a:=1 to Filegrid.RowCount -1 do
     begin
      st:='';
      If Copypaths.Checked then st := Filegrid.Cells[1,a] + Filegrid.Cells[2,a]
                           else st := Filegrid.Cells[2,a];
      If Copysizes.Checked then st := st + #09 + Filegrid.Cells[3,a] {+ #13 + #10}
                           else st := st {+ #13 + #10};
      strs.Add(st);

//      GetMem(Buff,strLen(buff) + Length(st) + 1);
//      buff:=strcat(buff, Pchar(st));
     end;
    buff:=Pchar(strs.text);
    Clipboard.SetTextBuf(buff);
   finally strs.Free;
   end;

end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If ( (key = ord('c')) or (key = ord('C')) ) and (Shift = [ssCtrl]) then
   Button1Click(Sender); {Кнопка "В буффер"}
end;

end.
