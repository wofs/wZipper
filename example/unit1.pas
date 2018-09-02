unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls,
  wZipperU,
  Zipper, LazUTF8
  ;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    ListBox1: TListBox;
    Memo1: TMemo;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
  private
    _ZipFile: String;
    _UnPackPath: String;

    wZipper: TwZipper;

    procedure OpenFile(aFileName: string);
    procedure UnzipFileFromZip(aZipFile, aFileExtract, aUnpackPatch: string);

  public

  end;

var
  Form1: TForm1;

implementation


{$R *.lfm}

{ TForm1 }

procedure TForm1.UnzipFileFromZip(aZipFile,aFileExtract,aUnpackPatch: string);
var
  UnZipper: TUnZipper; //PasZLib
  _Files: TStringList;
begin
  UnZipper      :=TUnZipper.Create;
  try
     UnZipper.FileName   := aZipFile;
     UnZipper.OutputPath := aUnpackPatch;
     UnZipper.Examine;
     _Files:= TStringList.Create;
     _Files.Add(aFileExtract);

     UnZipper.UnZipFiles(_Files);
     //UnZipper.UnZipAllFiles;


     //for i:=UnZipper.Entries.Count-1 downto 0 do
     //begin
     //    //AArchiveFileName:=EndPathCP866ToUTF8(AArchiveFileName);
     //    //AArchiveFileName:=UTF8ToSys(AArchiveFileName);
     //    //ANewDiskFileName:=UnPackFileDir+AArchiveFileName;
     //    //ADiskFileName   :=UnPackFileDir+UnZipper.Entries.Entries[i].DiskFileName;
     //    //Memo1.Lines.Add('Extract '+ADiskFileName);
     //    //
     //    //if FileExists(ADiskFileName) then
     //    //begin
     //    //   RenameFile(ADiskFileName, ANewDiskFileName);
     //    //end
     //    //else if DirectoryExists(ADiskFileName) then
     //    //begin
     //    //   ADiskFileName    :=SysUtils.IncludeTrailingPathDelimiter(ADiskFileName);
     //    //   ANewDiskFileName :=SysUtils.IncludeTrailingPathDelimiter(ANewDiskFileName);
     //    //   RenameFile(ADiskFileName, ANewDiskFileName);
     //    //end;
     //end;

  finally
     _Files.Free;
     UnZipper.Free;
  end;
end;

procedure TForm1.OpenFile(aFileName: string);
begin
  try
      _ZipFile:= aFileName;
      Edit1.Text:= _ZipFile;
      Memo1.Lines.Add('Open file '+Edit1.Text);
      _UnPackPath:= includeTrailingPathDelimiter(ExtractFileDir(Application.ExeName));
      _UnPackPath:= _UnPackPath+'tmp';
      if not DirectoryExists(_UnPackPath) then ForceDirectories(_UnPackPath);

      ListBox1.Items:=wZipper.ReadFileList(_ZipFile);

  except
    on E: Exception do
      begin
        Memo1.Lines.Add('"' + E.Message + '"');
      end;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    OpenFile(OpenDialog1.FileName);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i: integer;
begin
  wZipper:= TwZipper.Create;
  for i := 1 to ParamCount do
  begin
    OpenFile(ParamStr(i));
    Break;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  wZipper.Destroy;
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin

end;

procedure TForm1.ListBox1DblClick(Sender: TObject);
begin
  if TListBox(Sender).Items.Count>0 then
  begin
    Memo1.Lines.Add('Unpacking '+ExtractFileName(TListBox(Sender).Items[TListBox(Sender).ItemIndex])+' in '+includeTrailingPathDelimiter(_UnPackPath));

    try
      wZipper.ExtractOneFile(_ZipFile,TListBox(Sender).Items[TListBox(Sender).ItemIndex],_UnPackPath);
      Memo1.Lines.Add('Unpacking OK');
    except
      on E: Exception do
      begin
         Memo1.Lines.Add('"' + E.Message + '"');
      end;
    end;
  end;
end;

end.

