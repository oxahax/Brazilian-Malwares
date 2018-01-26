unit AdvPolyPagerDE;

interface

{$I TMSDEFS.INC}

uses
  Classes, Graphics, Comctrls, Windows, Forms, TypInfo, Dialogs, ExtCtrls,
  Controls, ExtDlgs, AdvPolyPager
{$IFDEF DELPHI6_LVL}
  {$IFNDEF TMSDOTNET}
  , DesignIntf, DesignEditors, ContNrs
  {$ENDIF}
  {$IFDEF TMSDOTNET}
  , Borland.Vcl.design.DesignIntf, Borland.Vcl.design.DesignEditors, ContNrs
  {$ENDIF}
{$ELSE}
  , DsgnIntf
{$ENDIF}
  ;

type

  TAdvPolyPagerEditor = class(TDefaultEditor)
  public
    function GetVerb(Index: Integer):string; override;
    function GetVerbCount: Integer; override;
    procedure ExecuteVerb(Index: Integer); override;
  {$IFNDEF DELPHI6_LVL}
    procedure EditProperty(PropertyEditor: TPropertyEditor;
      var Continue, FreeEditor: Boolean); override;
  {$ELSE}
    procedure EditProperty(const PropertyEditor: IProperty; var Continue:
      Boolean); override;
  {$ENDIF}
  end;

  TAdvPolyPageEditor = class(TDefaultEditor)
  public
    function GetVerb(Index: Integer):string; override;
    function GetVerbCount: Integer; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

implementation

uses
  SysUtils, AdvStyles, AdvStyleIF;

function HTMLToRgb(color: tcolor): tcolor;
var
  r,g,b: integer;
begin
  r := (Color and $0000FF);
  g := (Color and $00FF00);
  b := (Color and $FF0000) shr 16;
  Result := b or g or (r shl 16);
end;

function BrightnessColor(Col: TColor; Brightness: integer): TColor; overload;
var
  r1,g1,b1: Integer;
begin
  Col := Longint(ColorToRGB(Col));
  r1 := GetRValue(Col);
  g1 := GetGValue(Col);
  b1 := GetBValue(Col);

  r1 := Round( (100 + Brightness)/100 * r1 );
  g1 := Round( (100 + Brightness)/100 * g1 );
  b1 := Round( (100 + Brightness)/100 * b1 );

  Result := RGB(r1,g1,b1);
end;


function BrightnessColor(Col: TColor; BR,BG,BB: integer): TColor; overload;
var
  r1,g1,b1: Integer;
begin
  Col := Longint(ColorToRGB(Col));
  r1 := GetRValue(Col);
  g1 := GetGValue(Col);
  b1 := GetBValue(Col);

  r1 := Round( (100 + BR)/100 * r1 );
  g1 := Round( (100 + BG)/100 * g1 );
  b1 := Round( (100 + BB)/100 * b1 );

  Result := RGB(r1,g1,b1);
end;


{ TAdvToolBarPagerEditor }

{$IFDEF DELPHI6_LVL}
procedure TAdvPolyPagerEditor.EditProperty(const PropertyEditor:
IProperty; var Continue: Boolean);
{$ELSE}
procedure TAdvPolyPagerEditor.EditProperty(PropertyEditor:
TPropertyEditor;
  var Continue, FreeEditor: Boolean);
{$ENDIF}
var
  PropName: string;
begin
  PropName := PropertyEditor.GetName;
  if (CompareText(PropName, 'LIST') = 0) then
  begin
    PropertyEditor.Edit;
    Continue := False;
  end;
end;

procedure TAdvPolyPagerEditor.ExecuteVerb(Index: Integer);
var
  AdvPage : TAdvPolyPage;
  psf: TAdvStyleForm;
  style: TTMSStyle;
begin
  inherited;
  if (Index = 0) then
  begin
    psf := TAdvStyleForm.Create(Application);
    if psf.ShowModal = mrOK then
    begin
      if (Component is TAdvPolyPager) then
      begin
        style := tsOffice2003Blue;
        case psf.RadioGroup1.ItemIndex of
        1: style := tsOffice2003Olive;
        2: style := tsOffice2003Silver;
        3: style := tsOffice2003Classic;
        4: style := tsOffice2007Luna;
        5: style := tsOffice2007Obsidian;
        6: style := tsOffice2007Silver;
        7: style := tsOffice2010Blue;
        8: style := tsOffice2010Silver;
        9: style := tsOffice2010Black;
        10: style := tsWindowsXP;
        11: style := tsWindowsVista;
        12: style := tsWindows7;
        13: style := tsTerminal;
        end;
        (Component as TAdvPolyPager).SetComponentStyle(style);

        Designer.Modified;
      end;
    end;
    psf.Free;
  end;
  case Index of
  1:
    begin
      AdvPage := TAdvPolyPage(Designer.CreateComponent(TAdvPolyPage,Component,23,0,100,100));
      AdvPage.Parent := TAdvPolyPager(Component);
      AdvPage.AdvPolyPager := TAdvPolyPager(Component);
      AdvPage.Caption := AdvPage.name;
      TAdvPolypager(component).ActivePage:= AdvPage;
    end;
  2: TAdvPolyPager(Component).SelectNextPage(false);
  3: TAdvPolyPager(Component).SelectNextPage(True);
  end;
end;

function TAdvPolyPagerEditor.GetVerb(Index: Integer): string;
begin
  case Index of
  0: Result := 'Styles';
  1: Result := 'New Page';
  2: Result := 'Previous Page';
  3: Result := 'Next Page';
  end;
end;

function TAdvPolyPagerEditor.GetVerbCount: Integer;
begin
  Result := 3;
end;

{ TAdvPageEditor }

procedure TAdvPolyPageEditor.ExecuteVerb(Index: Integer);
var
  AdvPage : TAdvPolyPage;
  psf: TAdvStyleForm;
  style: TTMSStyle;
begin
  inherited;
  if (Index = 0) then
  begin
    psf := TAdvStyleForm.Create(Application);
    if psf.ShowModal = mrOK then
    begin
      //ShowMessage(inttostr(psf.RadioGroup1.ItemIndex));
      style := tsOffice2003Blue;
      case psf.RadioGroup1.ItemIndex of
      1: style := tsOffice2003Olive;
      2: style := tsOffice2003Silver;
      3: style := tsOffice2003Classic;
      4: style := tsOffice2007Luna;
      5: style := tsOffice2007Obsidian;
      6: style := tsOffice2007Silver;
      7: style := tsWindowsXP;
      8: style := tsWindowsVista;
      9: style := tsWindows7;
      10: style := tsTerminal;
      end;
      if (Component is TAdvPolyPage) then
         (Component as TAdvPolyPage).SetComponentStyle(style);
         Designer.Modified;
    end;
    psf.Free;
  end;

  case Index of
  1:
    begin
      AdvPage := TAdvPolyPage(Designer.CreateComponent(TAdvPolyPage,TWinControl(Component).Parent,23,0,100,100));
      AdvPage.Parent := TWinControl(Component).Parent;
      AdvPage.AdvPolyPager := TAdvPolyPager(TWinControl(Component).Parent);
      AdvPage.Caption := AdvPage.Name;
      TAdvPolyPager(TWinControl(Component).Parent).ActivePage:= AdvPage;
    end;
  2: TAdvPolyPager(TAdvPolyPage(Component).Parent).SelectNextPage(false);
  3: TAdvPolyPager(TAdvPolyPage(Component).Parent).SelectNextPage(true);
  4:
    begin
    TAdvPolyPage(Component).AdvPolyPager := nil;
    Component.Free;
    end;
  end;
end;

function TAdvPolyPageEditor.GetVerb(Index: Integer): string;
begin
  case Index of
  0: Result := 'Styles';
  1: Result := 'New Page';
  2: Result := 'Previous Page';
  3: Result := 'Next Page';
  4: Result := 'Delete Page';
  end;
end;

function TAdvPolyPageEditor.GetVerbCount: Integer;
begin
  Result := 5;
end;



end.
