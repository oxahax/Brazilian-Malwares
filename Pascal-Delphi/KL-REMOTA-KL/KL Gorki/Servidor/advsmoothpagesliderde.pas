unit AdvSmoothPageSliderDE;

interface

{$I TMSDEFS.INC}

uses
  Classes, Graphics, Comctrls, Windows, Forms, TypInfo, Dialogs, ExtCtrls,
  Controls, ExtDlgs, AdvSmoothPageSlider
{$IFDEF DELPHI6_LVL}
  , DesignIntf, DesignEditors, ContNrs
{$ELSE}
  , DsgnIntf
{$ENDIF}
  ;

type

  TAdvSmoothPageSliderEditor = class(TDefaultEditor)
  public
    function GetVerb(Index: Integer):string; override;
    function GetVerbCount: Integer; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

  TAdvSmoothTabPageEditor = class(TDefaultEditor)
  public
    function GetVerb(Index: Integer):string; override;
    function GetVerbCount: Integer; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

implementation

uses
  SysUtils, AdvSmoothStyles, AdvStyleIF;

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

procedure TAdvSmoothPageSliderEditor.ExecuteVerb(Index: Integer);
var
  AdvPage: TAdvSmoothPage;
  psf: TAdvSmoothStyleForm;
  style: TTMSStyle;
  i: integer;
begin
  inherited;
  if (Index = 0) then
  begin
    psf := TAdvSmoothStyleForm.Create(Application);
    if psf.ShowModal = mrOK then
    begin
      if (Component is TAdvSmoothPageSlider) then
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
        14: style := tsWindows8;
        15: style := tsOffice2013White;
        16: style := tsOffice2013LightGray;
        17: style := tsOffice2013Gray;
        end;
        (Component as TAdvSmoothPageSlider).SetComponentStyle(style);
        for I := 0 to (Component as TAdvSmoothPageSlider).PageCount - 1 do
          (Component as TAdvSmoothPageSlider).Pages[I].SetComponentStyle(style);

        Designer.Modified;
      end;
    end;
    psf.Free;
  end;
  case Index of
  1:
    begin
      AdvPage := TAdvSmoothPage(Designer.CreateComponent(TAdvSmoothPage,Component,23,0,100,100));
      AdvPage.Parent := TAdvSmoothPageSlider(Component);
      AdvPage.PageSlider := TAdvSmoothPageSlider(Component);
      AdvPage.Header := AdvPage.Name;
      TAdvSmoothPageSlider(component).ActivePage:= AdvPage;
    end;
  2: TAdvSmoothPageSlider(Component).SelectNextPage(false);
  3: TAdvSmoothPageSlider(Component).SelectNextPage(True);
  end;
end;

function TAdvSmoothPageSliderEditor.GetVerb(Index: Integer): string;
begin
  case Index of
  0: Result := 'Styles';
  1: Result := 'New Page';
  2: Result := 'Previous Page';
  3: Result := 'Next Page';
  end;
end;

function TAdvSmoothPageSliderEditor.GetVerbCount: Integer;
begin
  Result := 3;
end;

{ TAdvPageEditor }

procedure TAdvSmoothTabPageEditor.ExecuteVerb(Index: Integer);
var
  AdvPage : TAdvSmoothPage;
  psf: TAdvSmoothStyleForm;
  style: TTMSStyle;
begin
  inherited;
  if (Index = 0) then
  begin
    psf := TAdvSmoothStyleForm.Create(Application);
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
        7: style := tsOffice2010Blue;
        8: style := tsOffice2010Silver;
        9: style := tsOffice2010Black;
        10: style := tsWindowsXP;
        11: style := tsWindowsVista;
        12: style := tsWindows7;
        13: style := tsTerminal;
        14: style := tsWindows8;
        15: style := tsOffice2013White;
        16: style := tsOffice2013LightGray;
        17: style := tsOffice2013Gray;
      end;
      if (Component is TAdvSmoothPage) then
         (Component as TAdvSmoothPage).SetComponentStyle(style);
         Designer.Modified;
    end;
    psf.Free;
  end;

  case Index of
  1:
    begin
      AdvPage := TAdvSmoothPage(Designer.CreateComponent(TAdvSmoothPage,TWinControl(Component).Parent,23,0,100,100));
      AdvPage.Parent := TWinControl(Component).Parent;
      AdvPage.PageSlider := TAdvSmoothPageSlider(TWinControl(Component).Parent);
      AdvPage.Header := AdvPage.Name;
      TAdvSmoothPageSlider(TWinControl(Component).Parent).ActivePage:= AdvPage;
    end;
  2: TAdvSmoothPageSlider(TAdvSmoothPage(Component).Parent).SelectNextPage(false);
  3: TAdvSmoothPageSlider(TAdvSmoothPage(Component).Parent).SelectNextPage(true);
  4:
    begin
    TAdvSmoothPage(Component).PageSlider := nil;
    Component.Free;
    end;
  end;
end;

function TAdvSmoothTabPageEditor.GetVerb(Index: Integer): string;
begin
  case Index of
  0: Result := 'Styles';
  1: Result := 'New Page';
  2: Result := 'Previous Page';
  3: Result := 'Next Page';
  4: Result := 'Delete Page';
  end;
end;

function TAdvSmoothTabPageEditor.GetVerbCount: Integer;
begin
  Result := 5;
end;

end.
