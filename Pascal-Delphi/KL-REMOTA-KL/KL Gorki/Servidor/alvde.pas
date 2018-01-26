{*************************************************************************}
{ TADVLISTVIEW DESIGN TIME EDITOR                                         }
{ for Delphi & C++Builder                                                 }
{                                                                         }
{ written by TMS Software                                                 }
{            copyright © 1998-2010                                        }
{            Email : info@tmssoftware.com                                 }
{            Web : http://www.tmssoftware.com                             }
{                                                                         }
{ The source code is given as is. The author is not responsible           }
{ for any possible damage done due to the use of this code.               }
{ The component can be freely used in any application. The complete       }
{ source code remains property of the author and may not be distributed,  }
{ published, given or sold in any form as such. No parts of the source    }
{ code can be included in any other component or application without      }
{ written authorization of the author.                                    }
{*************************************************************************}

unit AlvDE;

interface
{$I TMSDEFS.INC}
uses
  Classes,AdvListV,
{$IFDEF DELPHI6_LVL}
  DesignIntf, DesignEditors
{$ELSE}
  DsgnIntf
{$ENDIF}
  ;


type
  TAdvListViewEditor = class(TComponentEditor)
  public
    function GetVerb(index:integer):string; override;
    function GetVerbCount:integer; override;
    procedure ExecuteVerb(Index:integer); override;
  end;

implementation

uses
 Dialogs;

procedure TAdvListViewEditor.ExecuteVerb(Index: integer);
var
  compiler: string;
  od: TOpenDialog;
begin
  case Index of
  0:
  begin
    {$IFDEF VER90}
    Compiler := 'Delphi 2';
    {$ENDIF}
    {$IFDEF VER93}
    Compiler := 'C++Builder 1';
    {$ENDIF}
    {$IFDEF VER100}
    Compiler := 'Delphi 3';
    {$ENDIF}
    {$IFDEF VER110}
    Compiler := 'C++Builder 3';
    {$ENDIF}
    {$IFDEF VER120}
    Compiler := 'Delphi 4';
    {$ENDIF}
    {$IFDEF VER125}
    Compiler := 'C++Builder 4';
    {$ENDIF}
    {$IFDEF VER130}
    {$IFDEF BCB}
    Compiler := 'C++Builder 5';
    {$ELSE}
    Compiler := 'Delphi 5';
    {$ENDIF}
    {$ENDIF}
    {$IFDEF VER140}
    {$IFDEF BCB}
    Compiler := 'C++Builder 6';
    {$ELSE}
    Compiler := 'Delphi 6';
    {$ENDIF}
    {$ENDIF}
    {$IFDEF VER150}
    Compiler := 'Delphi 7';
    {$ENDIF}
    {$IFDEF VER170}
    Compiler := 'Delphi 2005';
    {$ENDIF}
    {$IFDEF VER180}
      {$IFDEF BCB}
      compiler := 'C++Builder 2006';
      {$ELSE}
      compiler := 'Delphi 2006';
      {$ENDIF}
    {$ENDIF}
    {$IFDEF VER185}
      {$IFDEF BCB}
      compiler := 'C++Builder 2007';
      {$ELSE}
      compiler := 'Delphi 2007';
      {$ENDIF}
    {$ENDIF}
    {$IFDEF VER200}
      {$IFDEF BCB}
      compiler := 'C++Builder 2009';
      {$ELSE}
      compiler := 'Delphi 2009';
      {$ENDIF}
    {$ENDIF}

    {$IFDEF VER200}
      {$IFDEF BCB}
      compiler := 'C++Builder 2010';
      {$ELSE}
      compiler := 'Delphi 2010';
      {$ENDIF}
    {$ENDIF}

    {$IFDEF VER220}
      {$IFDEF BCB}
      compiler := 'C++Builder XE';
      {$ELSE}
      compiler := 'Delphi XE';
      {$ENDIF}
    {$ENDIF}

    {$IFDEF VER230}
      {$IFDEF BCB}
      compiler := 'C++Builder XE2';
      {$ELSE}
      compiler := 'Delphi XE2';
      {$ENDIF}
    {$ENDIF}


    MessageDlg(Component.ClassName+' version '+(Component as TAdvListView).VersionString+' for '+Compiler+#13#10'© 1998-2011 by TMS software',
               mtInformation,[mbOK],0);
  end;
  1:
  begin
    od := TOpenDialog.Create(nil);
    od.DefaultExt := '*.CSV';
    od.Filter := 'CSV files (*.csv)|*.csv|All files (*.*)|*.*';
    if od.Execute then
    begin
      (Component as TAdvListView).LoadHeader := False;
      (Component as TAdvListView).LoadFromCSV(od.FileName);
    end;
    od.Free;
 end;
 2:
 begin
   (Component as TAdvListView).Clear;
 end;
 end;
end;

function TAdvListViewEditor.GetVerb(index: integer): string;
begin
  case index of
  0:result := '&Version';
  1:result := '&Load CSV file';
  2:result := '&Clear';
  end;
end;

function TAdvListViewEditor.GetVerbCount: integer;
begin
  Result := 3;
end;


end.

