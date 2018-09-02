unit wZipperU;

{
 wofs(c)2018 [wofssirius@yandex.ru]
 GNU LESSER GENERAL PUBLIC LICENSE v.2.1
 Git: https://github.com/wofs/wZipper
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazUTF8, Forms, Dialogs,
  Zipper, LConvEncoding
  ;
type
    ArrayOfString = array of string;
    { TwZipper }

    TwZipper = class
    private
      fFileListInZip: TStringList;
      function EndPathCP866ToUTF8(AText: string): string;

    public
      constructor Create ();
      destructor Destroy ();

      function ReadFileList(aZipFile: string): TStringList;
      procedure ExtractOneFile(aZipFile, aFileExtract, aUnpackPatch: string);
      procedure ExtractAllFiles(aZipFile, aUnpackPatch: string);

      function ParseComboFileName(aComboFileName: string): ArrayOfString;
      function GetUnPackPath(const aDirectoryName: string='tmp'): string;
    end;



implementation

function TwZipper.EndPathCP866ToUTF8(AText:string):string;
var
  c,i:integer;
  s,s1,s2,chr:string;
begin
  s:='';
  c:=UTF8Length(AText);
  for i:=c downto 1 do
  begin
       chr:=UTF8Copy(AText,i,1);
       if ((not(chr='/')) and (not(chr='\')))or(i=c) then
       begin
            s:=UTF8Copy(AText,i,1)+s;
       end
       else begin
            s:=UTF8Copy(AText,i,1)+s;
            break;
       end;
  end;
  dec(i);
  s1:=UTF8Copy(AText,1,i);
  s2:=CP866ToUTF8(s);
  Result:=s1+s2;
end;

function TwZipper.ReadFileList(aZipFile: string):TStringList;
var
   UnZipper: TUnZipper;
   i: Integer;
begin
  UnZipper      :=TUnZipper.Create;
  try
     UnZipper.FileName   := aZipFile;
     UnZipper.Examine;
     fFileListInZip.Clear;
     for i:=UnZipper.Entries.Count-1 downto 0 do
     begin
         fFileListInZip.Add(UTF8ToSys(EndPathCP866ToUTF8(UnZipper.Entries.Entries[i].ArchiveFileName)));
     end;

  finally
     UnZipper.Free;
  end;

  Result:= fFileListInZip;
end;

procedure TwZipper.ExtractOneFile(aZipFile, aFileExtract, aUnpackPatch: string
  );
var
  UnZipper: TUnZipper; //PasZLib
  _Files: TStringList;
  _ArchiveFileName, _NewDiskFileName, _DiskFileName: string;
  i: Integer;
begin
  try
    UnZipper      :=TUnZipper.Create;
    try
       UnZipper.FileName   := aZipFile;
       UnZipper.OutputPath := aUnpackPatch;
       UnZipper.Examine;
       _Files:= TStringList.Create;
       _Files.Add(UTF8ToCP866(aFileExtract));

       UnZipper.UnZipFiles(_Files);
       for i:=UnZipper.Entries.Count-1 downto 0 do
       begin
          _ArchiveFileName:= UTF8ToSys(EndPathCP866ToUTF8(UnZipper.Entries.Entries[i].ArchiveFileName));
          _NewDiskFileName:= SysUtils.IncludeTrailingPathDelimiter(aUnpackPatch)+_ArchiveFileName;
          _DiskFileName:= SysUtils.IncludeTrailingPathDelimiter(aUnpackPatch)+UnZipper.Entries.Entries[i].DiskFileName;
            if FileExists(_DiskFileName) then
               RenameFile(_DiskFileName, _NewDiskFileName);
            //else
            //     if DirectoryExists(_DiskFileName) then
            //     begin
            //       _DiskFileName:=SysUtils.IncludeTrailingPathDelimiter(_DiskFileName);
            //       _NewDiskFileName:=SysUtils.IncludeTrailingPathDelimiter(_NewDiskFileName);
            //       RenameFile(_DiskFileName, _NewDiskFileName);
            //     end;
       end;

       //UnZipper.UnZipAllFiles;
    finally
       _Files.Free;
       UnZipper.Free;
    end;
  except
    raise;
  end;

end;

procedure TwZipper.ExtractAllFiles(aZipFile, aUnpackPatch: string);
var
  UnZipper: TUnZipper; //PasZLib
begin

  try
    UnZipper      :=TUnZipper.Create;
    try
       UnZipper.FileName   := aZipFile;
       UnZipper.OutputPath := aUnpackPatch;
       UnZipper.Examine;
       UnZipper.UnZipAllFiles;
    finally
       UnZipper.Free;
    end;
  except
     raise;
  end;

end;

function TwZipper.ParseComboFileName(aComboFileName: string):ArrayOfString;
var
  _Pos: integer;
begin
  SetLength(Result,2);
  _Pos:= UTF8Pos('|',aComboFileName);
  if _Pos>0 then
  begin
   Result[0]:= UTF8Copy(aComboFileName,1,_Pos-1); // path to zip
   Result[1]:= UTF8Copy(aComboFileName,_Pos+1,Length(aComboFileName)); // filename in zip
  end else
  begin
   Result:=nil;
  end;
end;

function TwZipper.GetUnPackPath(const aDirectoryName: string = 'tmp'):string;
begin
  Result:= includeTrailingPathDelimiter(ExtractFileDir(Application.ExeName));
  Result:= Result+aDirectoryName;
  if not DirectoryExists(Result) then ForceDirectories(Result);
end;

constructor TwZipper.Create();
begin
  fFileListInZip:= TStringList.Create;
end;

destructor TwZipper.Destroy();
begin
  fFileListInZip.Free;
end;

end.

