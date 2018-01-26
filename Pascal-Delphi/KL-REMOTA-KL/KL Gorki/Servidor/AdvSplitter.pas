{*************************************************************************}
{ TMS TAdvSplitter component                                              }
{ for Delphi & C++Builder                                                 }
{                                                                         }
{ written by TMS Software                                                 }
{           copyright ©  2007 - 2013                                      }
{           Email : info@tmssoftware.com                                  }
{           Web : http://www.tmssoftware.com                              }
{                                                                         }
{ The source code is given as is. The author is not responsible           }
{ for any possible damage done due to the use of this code.               }
{ The component can be freely used in any application. The complete       }
{ source code remains property of the author and may not be distributed,  }
{ published, given or sold in any form as such. No parts of the source    }
{ code can be included in any other component or application without      }
{ written authorization of the author.                                    }
{*************************************************************************}

unit AdvSplitter;

{$I TMSDEFS.INC}

interface

uses
  Classes, Windows, Controls, Graphics, Messages, ExtCtrls,
  SysUtils, AdvStyleIF
  {$IFDEF DELPHIXE3_LVL}
  , System.UITypes
  {$ENDIF}
  ;

const

  MAJ_VER = 1; // Major version nr.
  MIN_VER = 3; // Minor version nr.
  REL_VER = 1; // Release nr.
  BLD_VER = 0; // Build nr.

  // version history
  // 1.0.0.0 : First release
  // 1.1.0.0 : New : OnDblClick event added
  //         : New : property DefaultSize added
  // 1.1.1.0 : New : OnClick event exposed
  // 1.1.2.0 : New : Exposed FindControl method as public method
  // 1.1.2.1 : Improved : force repainting of controls when default size is set
  // 1.1.3.0 : Fixed : issue with splitter making other aligned controls too small
  // 1.2.0.0 : New : Terminal, Vista & Windows 7 styles
  // 1.3.0.0 : New : Built in support for Office 2010 colors
  // 1.3.1.0 : New : Windows 8, Office 2013 styles added

type
  TGradientDirection = (gdHorizontal, gdVertical);

  TDirectionType = (dtFixed, dtAuto, dtAutoInvers);

  TSplitterGripStyle = (sgDots, sgSingleLine, sgDoubleLine, sgFlatDots, sgNone);

  TSplitterAppearance = class(TPersistent)
  private
    FSteps: Integer;
    FColor: TColor;
    FColorTo: TColor;
    FDirection: TGradientDirection;
    FOnChange: TNotifyEvent;
    FBorderColor: TColor;
    FColorHotTo: TColor;
    FColorHot: TColor;
    FBorderColorHot: TColor;
    FDirectionType: TDirectionType;
    procedure SetColor(const Value: TColor);
    procedure SetColorTo(const Value: TColor);
    procedure SetDirection(const Value: TGradientDirection);
    procedure SetSteps(const Value: Integer);
    procedure Changed;
    procedure SetBorderColor(const Value: TColor);
    procedure SetBorderColorHot(const Value: TColor);
    procedure SetColorHot(const Value: TColor);
    procedure SetColorHotTo(const Value: TColor);
    procedure SetDirectionType(const Value: TDirectionType);
  protected
    property Steps: Integer read FSteps write SetSteps default 64;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property BorderColorHot: TColor read FBorderColorHot write SetBorderColorHot;
    property Color: TColor read FColor write SetColor;
    property ColorTo: TColor read FColorTo write SetColorTo;
    property ColorHot: TColor read FColorHot write SetColorHot;
    property ColorHotTo: TColor read FColorHotTo write SetColorHotTo;
    property Direction: TGradientDirection read FDirection write SetDirection default gdHorizontal;
    property DirectionType: TDirectionType read FDirectionType write SetDirectionType default dtAuto;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TAdvCustomSplitter = class(TSplitter, ITMSStyle)
  private
    FAppearance: TSplitterAppearance;
    FGlyph: TBitmap;
    FMouseInControl: Boolean;
    FGripStyle: TSplitterGripStyle;
    FDefaultSize: integer;
    Procedure WMEraseBkGnd( Var msg: TWMEraseBkGnd ); message WM_ERASEBKGND;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure OnAppearanceChanged(Sender: TObject);
    procedure OnGlyphChanged(Sender: TObject);
    procedure AdjustNeighbourControl;
    procedure SetAppearance(const Value: TSplitterAppearance);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    procedure SetGlyph(const Value: TBitmap);
    procedure SetGripStyle(const Value: TSplitterGripStyle);
  protected
    procedure Loaded; override;
    procedure Paint; override;
    procedure DblClick; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    property Appearance: TSplitterAppearance read FAppearance write SetAppearance;
    property Version: string read GetVersion write SetVersion stored false;
    property Glyph: TBitmap read FGlyph write SetGlyph;
    property GripStyle: TSplitterGripStyle read FGripStyle write SetGripStyle;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function FindControl: TControl;
    procedure SetComponentStyle(AStyle: TTMSStyle);
    function GetVersionNr: integer;
    property DefaultSize: integer read FDefaultSize write FDefaultSize default 0;
  end;

  {$IFDEF DELPHIXE2_LVL}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  {$ENDIF}
  TAdvSplitter = class(TAdvCustomSplitter)
  published
    property Appearance;
    property DefaultSize;
    property Glyph;
    property GripStyle;
    property ShowHint;
    property Version;
    property OnClick;
    property OnDblClick;
  end;

implementation

{$IFDEF DELPHI6_LVL}
uses
  Types;
{$ENDIF}

//----------------------------------------------------------------- DrawGradient

procedure DrawGradient(Canvas: TCanvas; FromColor, ToColor: TColor; Steps: Integer; R: TRect; Direction: Boolean);
var
  diffr, startr, endr: Integer;
  diffg, startg, endg: Integer;
  diffb, startb, endb: Integer;
  rstepr, rstepg, rstepb, rstepw: Real;
  i, stepw: Word;

begin
  if Direction then
    R.Right := R.Right - 1
  else
    R.Bottom := R.Bottom - 1;

  if Steps = 0 then
    Steps := 1;

  FromColor := ColorToRGB(FromColor);
  ToColor := ColorToRGB(ToColor);

  startr := (FromColor and $0000FF);
  startg := (FromColor and $00FF00) shr 8;
  startb := (FromColor and $FF0000) shr 16;
  endr := (ToColor and $0000FF);
  endg := (ToColor and $00FF00) shr 8;
  endb := (ToColor and $FF0000) shr 16;

  diffr := endr - startr;
  diffg := endg - startg;
  diffb := endb - startb;

  rstepr := diffr / steps;
  rstepg := diffg / steps;
  rstepb := diffb / steps;

  if Direction then
    rstepw := (R.Right - R.Left) / Steps
  else
    rstepw := (R.Bottom - R.Top) / Steps;

  with Canvas do
  begin
    for i := 0 to steps - 1 do
    begin
      endr := startr + Round(rstepr * i);
      endg := startg + Round(rstepg * i);
      endb := startb + Round(rstepb * i);
      stepw := Round(i * rstepw);
      Pen.Color := endr + (endg shl 8) + (endb shl 16);
      Brush.Color := Pen.Color;
      if Direction then
        Rectangle(R.Left + stepw, R.Top, R.Left + stepw + Round(rstepw) + 1, R.Bottom)
      else
        Rectangle(R.Left, R.Top + stepw, R.Right, R.Top + stepw + Round(rstepw) + 1);
    end;
  end;
end;

//------------------------------------------------------------------------------

{ TSplitterAppearance }

constructor TSplitterAppearance.Create;
begin
  inherited;
  FColor := clWhite;
  FColorTo := clSilver;
  FColorHot := clWhite;
  FColorHotTo := clGray;
  FBorderColor := clNone;
  FBorderColorHot := clNone;
  FSteps := 64;
  FDirection := gdHorizontal;
  FDirectionType := dtAuto;
end;

//------------------------------------------------------------------------------

procedure TSplitterAppearance.Assign(Source: TPersistent);
begin
  if (Source is TSplitterAppearance) then
  begin
    FBorderColor := (Source as TSplitterAppearance).BorderColor;
    FColor := (Source as TSplitterAppearance).Color;
    FColorTo := (Source as TSplitterAppearance).ColorTo;
    FBorderColorHot := (Source as TSplitterAppearance).BorderColorHot;
    FColorHot := (Source as TSplitterAppearance).ColorHot;
    FColorHotTo := (Source as TSplitterAppearance).ColorHotTo;
    FDirection := (Source as TSplitterAppearance).Direction;
    FSteps := (Source as TSplitterAppearance).Steps;
  end;
end;

//------------------------------------------------------------------------------

procedure TSplitterAppearance.Changed;
begin
  if Assigned(OnChange) then
    OnChange(Self);
end;

//------------------------------------------------------------------------------

procedure TSplitterAppearance.SetColor(const Value: TColor);
begin
  if (FColor <> Value) then
  begin
    FColor := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TSplitterAppearance.SetColorTo(const Value: TColor);
begin
  if (FColorTo <> Value) then
  begin
    FColorTo := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TSplitterAppearance.SetDirection(
  const Value: TGradientDirection);
begin
  if (FDirection <> Value) then
  begin
    FDirection := Value;
    Changed;
  end;
end;

procedure TSplitterAppearance.SetDirectionType(const Value: TDirectionType);
begin
  FDirectionType := Value;
end;

//------------------------------------------------------------------------------

procedure TSplitterAppearance.SetSteps(const Value: Integer);
begin
  if (FSteps <> Value) then
  begin
    FSteps := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TSplitterAppearance.SetBorderColor(const Value: TColor);
begin
  if (FBorderColor <> Value) then
  begin
    FBorderColor := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TSplitterAppearance.SetBorderColorHot(const Value: TColor);
begin
  if (FBorderColorHot <> Value) then
  begin
    FBorderColorHot := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TSplitterAppearance.SetColorHot(const Value: TColor);
begin
  if (FColorHot <> Value) then
  begin
    FColorHot := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TSplitterAppearance.SetColorHotTo(const Value: TColor);
begin
  if (FColorHotTo <> Value) then
  begin
    FColorHotTo := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

{ TAdvCustomSplitter }

constructor TAdvCustomSplitter.Create(AOwner: TComponent);
begin
  inherited;
  FAppearance := TSplitterAppearance.Create;
  FAppearance.OnChange := OnAppearanceChanged;
  FGlyph := TBitmap.Create;
  FGlyph.OnChange := OnGlyphChanged;
  FMouseInControl := False;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomSplitter.DblClick;
var
  FControl: TControl;
begin
  inherited;

  if FDefaultSize <= 0 then
    Exit;


  case Align of
    alTop:
      begin
        if DoCanResize(FDefaultSize) then
        begin
          FControl := FindControl;
          if Assigned(FControl) then
          begin
            FControl.Height := FDefaultSize;
            FControl.Repaint;
          end;
        end;
      end;
    alBottom:
      begin
        if DoCanResize(FDefaultSize) then
        begin
          Parent.DisableAlign;
          try
            FControl := FindControl;
            if Assigned(FControl) then
            begin
            FControl.Top := FControl.Top + (FControl.Height - FDefaultSize);
            FControl.Height := FDefaultSize;
            FControl.Repaint;
            end;
          finally
            Parent.EnableAlign;
          end;
        end;
      end;

    alLeft:
      begin
        if DoCanResize(FDefaultSize) then
        begin
          FControl := FindControl;
          if Assigned(FControl) then
          begin
            FControl.Width := FDefaultSize;
            FControl.Repaint;
          end;
        end;
      end;
    alRight:
      begin
        if DoCanResize(FDefaultSize) then
        begin
          Parent.DisableAlign;
          FControl := FindControl;
          try
            if Assigned(FControl) then
            begin
            FControl.Left := FControl.Left + (FControl.Width - FDefaultSize);
            FControl.Width := FDefaultSize;
            FControl.Repaint;            
            end;
          finally
            Parent.EnableAlign;
          end;
        end;
      end;
  end;
end;

//------------------------------------------------------------------------------

destructor TAdvCustomSplitter.Destroy;
begin
  FAppearance.Free;
  FGlyph.Free;
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomSplitter.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if (csDesigning in ComponentState) then
    Exit;

  FMouseInControl := True;
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomSplitter.AdjustNeighbourControl;
var
  p: TPoint;
  i, sz: Integer;
  Ctrl: TControl;
  R: TRect;
begin
  if AutoSnap and (Self.Left <= MinSize) and (Self.Top <= MinSize) and Assigned(Parent) then
  begin
    Ctrl := nil;

    if (Align in [alLeft, alRight]) then
      p := Point(Left + Width - 1, Top)
    else
      p := Point(Left, Top + Height - 1);

    for i := 0 to Parent.ControlCount - 1 do
    begin
      Ctrl := Parent.Controls[i];
      R := Ctrl.BoundsRect;
      if (Align in [alLeft, alRight]) then
        sz := (R.Right - R.Left)
      else
        sz := (R.Bottom - R.Top);

      if (sz = 0) and Ctrl.Visible and Ctrl.Enabled then
      begin
        if (Align in [alLeft, alRight]) then
          R.Left := R.Left - 1
        else
          R.Top := R.Top - 1;

        if PtInRect(R, p) then
        begin
          Break;
        end;
      end;
      Ctrl := nil;
    end;

    if Assigned(Ctrl) then
    begin
      if (Align in [alLeft, alRight]) then
        Ctrl.Left := Self.Left - 1
      else
        Ctrl.Top := Self.Top - 1;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomSplitter.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  AdjustNeighbourControl;
  inherited;
end;

//------------------------------------------------------------------------------

function TAdvCustomSplitter.FindControl: TControl;
var
  P: TPoint;
  I: Integer;
  R: TRect;
begin
  Result := nil;
  P := Point(Left, Top);
  case Align of
    alLeft: Dec(P.X);
    alRight: Inc(P.X, Width);
    alTop: Dec(P.Y);
    alBottom: Inc(P.Y, Height);
  else
    Exit;
  end;
  for I := 0 to Parent.ControlCount - 1 do
  begin
    Result := Parent.Controls[I];
    if Result.Visible and Result.Enabled then
    begin
      R := Result.BoundsRect;
      if (R.Right - R.Left) = 0 then
        if Align in [alTop, alLeft] then
          Dec(R.Left)
        else
          Inc(R.Right);
      if (R.Bottom - R.Top) = 0 then
        if Align in [alTop, alLeft] then
          Dec(R.Top)
        else
          Inc(R.Bottom);
      if PtInRect(R, P) then Exit;
    end;
  end;
  Result := nil;
end;


//------------------------------------------------------------------------------

procedure TAdvCustomSplitter.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if (csDesigning in ComponentState) then
    Exit;

  FMouseInControl := False;
  Invalidate;
end;

//------------------------------------------------------------------------------

function TAdvCustomSplitter.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

//------------------------------------------------------------------------------

function TAdvCustomSplitter.GetVersionNr: integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

//------------------------------------------------------------------------------

procedure TAdvCustomSplitter.Loaded;
begin
  inherited;

end;

//------------------------------------------------------------------------------

procedure TAdvCustomSplitter.OnAppearanceChanged(Sender: TObject);
begin
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomSplitter.OnGlyphChanged(Sender: TObject);
begin
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure Draw3DLine(Canvas: TCanvas; FromPoint, ToPoint: TPoint; Embossed: Boolean; VerticalLine: Boolean = true);
begin
  with Canvas do
  begin
    if Embossed then
      Pen.Color := clWhite
    else
      Pen.Color := clBtnShadow;

    if VerticalLine then
    begin
      MoveTo(FromPoint.X - 1, FromPoint.Y - 1);
      LineTo(ToPoint.X - 1, ToPoint.Y);
      LineTo(ToPoint.X + 1, ToPoint.Y);
    end
    else
    begin
      MoveTo(FromPoint.X - 1, FromPoint.Y + 1);
      LineTo(FromPoint.X - 1, FromPoint.Y - 1);
      LineTo(ToPoint.X + 1, ToPoint.Y - 1);
    end;

    if Embossed then
      Pen.Color := clBtnShadow
    else
      Pen.Color := clWhite;

    if VerticalLine then
    begin
      MoveTo(ToPoint.X + 1, ToPoint.Y);
      LineTo(ToPoint.X + 1, FromPoint.Y);
      LineTo(ToPoint.X - 1, FromPoint.Y);
    end
    else
    begin
      MoveTo(ToPoint.X + 1, ToPoint.Y - 1);
      LineTo(ToPoint.X + 1, ToPoint.Y + 1);
      LineTo(FromPoint.X, FromPoint.Y + 1);
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomSplitter.Paint;
var
  R: TRect;
  PS: integer;
  i: integer;
  brClr: TColor;
  dir: boolean;
begin
  R := ClientRect;

  dir := false;
  
  if Appearance.DirectionType = dtFixed then
  begin
    dir := Appearance.Direction = gdHorizontal;
  end
  else
  begin
    if (Align in [alTop, alBottom]) then
    begin
      dir := Appearance.DirectionType <> dtAuto;
    end
    else if (Align in [alLeft, alRight]) then
    begin
      dir := Appearance.DirectionType = dtAuto;
    end;
  end;

  if FMouseInControl then
  begin
    brClr := Appearance.BorderColorHot;
    DrawGradient(Canvas, Appearance.ColorHot, Appearance.ColorHotTo, Appearance.Steps, R, dir);
  end
  else
  begin
    brClr := Appearance.BorderColor;
    DrawGradient(Canvas, Appearance.Color, Appearance.ColorTo, Appearance.Steps, R, dir);
  end;

  if Assigned(FGlyph) and not (FGlyph.Empty) then
  begin
    i := R.Top + 1 + (R.Bottom - R.Top - FGlyph.Height) div 2;
    ps := R.Left + 1 + (R.Right - R.Left - FGlyph.Width) div 2;
    FGlyph.Transparent := True;
    Canvas.Draw(ps, i, FGlyph);
  end
  else
  begin
    case FGripStyle of
    sgDots:       //--- draw dots grip
      begin
        if (Align in [alTop, alBottom]) then
        begin
          Canvas.Pen.Color := clWhite;
          Canvas.Brush.Color := clWhite;
          R.Top := R.Top + (R.Bottom - R.Top) div 2;
          //R.Top := R.Top + 2;
          PS := (Width - 34 {Dots Length}) div 2;
          R.Left := PS + 1;
          for i := 1 to 9 do
          begin
            Canvas.Rectangle(R.Left, R.Top, R.Left + 2, R.Top + 2);
            R.Left := R.Left + 4;
          end;

          Canvas.Pen.Color := clBlack;
          Canvas.Brush.Color := clBlack;
          R.Top := R.Top - 1;
          R.Left := PS;
          for i := 1 to 9 do
          begin
            Canvas.Rectangle(R.Left, R.Top, R.Left + 2, R.Top + 2);
            R.Left := R.Left + 4;
          end;

          R.Top := R.Top + 1;
          R.Left := PS + 1;
          for i := 1 to 9 do
          begin
            Canvas.Pixels[R.Left, R.Top] := Appearance.ColorTo;
            R.Left := R.Left + 4;
          end;
        end
        else if (Align in [alLeft, alRight]) then
        begin
          Canvas.Pen.Color := clWhite;
          Canvas.Brush.Color := clWhite;
          R.Left := R.Left + (R.Right - R.Left) div 2;
          PS := (Height - 34 {Dots Length}) div 2;
          R.Top := PS + 1;
          for i := 1 to 9 do
          begin
            Canvas.Rectangle(R.Left, R.Top, R.Left + 2, R.Top + 2);
            R.Top := R.Top + 4;
          end;

          Canvas.Pen.Color := clBlack;
          Canvas.Brush.Color := clBlack;
          R.Left := R.Left - 1;
          R.Top := PS;
          for i := 1 to 9 do
          begin
            Canvas.Rectangle(R.Left, R.Top, R.Left + 2, R.Top + 2);
            R.Top := R.Top + 4;
          end;

          R.Left := R.Left + 1;
          R.Top := PS + 1;
          for i := 1 to 9 do
          begin
            Canvas.Pixels[R.Left, R.Top] := Appearance.ColorTo;
            R.Top := R.Top + 4;
          end;
        end;
      end;
    sgFlatDots:
      begin
        if (Align in [alTop, alBottom]) then
        begin
          Canvas.Pen.Color := RGB(165, 165, 165);
          Canvas.Brush.Color := RGB(165, 165, 165);
          R.Top := R.Top - 1 + (R.Bottom - R.Top) div 2;
          //R.Top := R.Top + 2;
          PS := (Width - 34 {Dots Length}) div 2;
          R.Left := PS + 1;
          for i := 1 to 9 do
          begin
            Canvas.Rectangle(R.Left, R.Top, R.Left + 2, R.Top + 2);
            R.Left := R.Left + 4;
          end;
        end
        else if (Align in [alLeft, alRight]) then
        begin
          Canvas.Pen.Color := RGB(165, 165, 165);
          Canvas.Brush.Color := RGB(165, 165, 165);
          R.Left := R.Left - 1 + (R.Right - R.Left) div 2 ;
          PS := (Height - 34 {Dots Length}) div 2;
          R.Top := PS + 1;
          for i := 1 to 9 do
          begin
            Canvas.Rectangle(R.Left, R.Top, R.Left + 2, R.Top + 2);
            R.Top := R.Top + 4;
          end;
        end;
      end;
    sgSingleLine:
      begin
        if (Align in [alTop, alBottom]) then
        begin
          PS := (Width - 34 {Dots Length}) div 2;
          R.Left := PS + 1;
          R.Top := R.Top  + (R.Bottom - R.Top) div 2;
          Draw3DLine(Canvas, Point(R.Left, R.Top), Point(R.Left + 36, R.Top), true, false);
        end
        else
        begin
          R.Left := R.Left - 1 + (R.Right - R.Left) div 2 ;
          PS := (Height - 34 {Dots Length}) div 2;
          R.Top := PS + 1;
          Draw3DLine(Canvas, Point(R.Left, R.Top), Point(R.Left, R.Top + 36), true);
        end;
      end;
    sgDoubleLine:
      begin
        if (Align in [alTop, alBottom]) then
        begin
          PS := (Width - 34 {Dots Length}) div 2;
          R.Left := PS + 1;
          R.Top := R.Top  + (R.Bottom - R.Top) div 2;
          Canvas.Pen.Color := RGB(165, 165, 165);
          Canvas.MoveTo(R.Left, R.Top - 1);
          Canvas.LineTo(R.Left + 36, R.Top - 1);
          Canvas.MoveTo(R.Left, R.Top + 1);
          Canvas.LineTo(R.Left + 36, R.Top + 1);
        end
        else
        begin
          R.Left := R.Left - 1 + (R.Right - R.Left) div 2 ;
          PS := (Height - 34 {Dots Length}) div 2;
          R.Top := PS + 1;
          Canvas.Pen.Color := RGB(165, 165, 165);
          Canvas.MoveTo(R.Left - 1, R.Top);
          Canvas.LineTo(R.Left - 1, R.Top + 36);
          Canvas.MoveTo(R.Left + 1, R.Top);
          Canvas.LineTo(R.Left + 1, R.Top + 36);
        end;
      end;
    end;
  end;  // else

  //---- Borders
  if (brClr <> clNone) then
  begin
    R := ClientRect;
    Canvas.Pen.Color := BrClr;
    Canvas.Brush.Style := bsClear;
    Canvas.Rectangle(R);
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomSplitter.SetAppearance(
  const Value: TSplitterAppearance);
begin
  FAppearance.Assign(Value);
end;

procedure TAdvCustomSplitter.SetComponentStyle(AStyle: TTMSStyle);
begin
  case AStyle of
    tsOffice2003Blue:
      begin
        Appearance.Color := $FDEADA;
        Appearance.ColorTo := $E4AE88;
        Appearance.ColorHot := $00D3F8FF;
        Appearance.ColorHotTo := $0076C1FF;
        Appearance.DirectionType := dtAuto;
      end;
    tsOffice2003Silver:
      begin
        Appearance.Color := $ECE2E1;
        Appearance.ColorTo := $B39698;
        Appearance.ColorHot := $00D3F8FF;
        Appearance.ColorHotTo := $0076C1FF;
        Appearance.DirectionType := dtAuto;
      end;
    tsOffice2003Olive:
      begin
        Appearance.Color := $CFF0EA;
        Appearance.ColorTo := $8CC0B1;
        Appearance.ColorHot := $00D3F8FF;
        Appearance.ColorHotTo := $0076C1FF;
        Appearance.DirectionType := dtAuto;
      end;
    tsOffice2003Classic:
      begin
        Appearance.Color := clBtnFace;
        Appearance.ColorTo := clNone;
        Appearance.ColorHot := $00D2BDB6;
        Appearance.ColorHotTo := clNone;
        Appearance.DirectionType := dtAuto;
      end;
    tsOffice2007Luna:
      begin
        Appearance.Color := $FAF1E9;
        Appearance.ColorTo := $EDD8C7;
        Appearance.ColorHot := $00D3F8FF;
        Appearance.ColorHotTo := $0076C1FF;
        Appearance.DirectionType := dtAuto;
      end;
    tsOffice2007Obsidian:
      begin
        Appearance.Color := $CFC6C1;
        Appearance.ColorTo := $C5BBB4;
        Appearance.ColorHot := $00D3F8FF;
        Appearance.ColorHotTo := $0076C1FF;
        Appearance.DirectionType := dtAuto;
      end;
    tsWindowsXP:
      begin
        Appearance.Color := clBtnFace;
        Appearance.ColorTo := clNone;
        Appearance.ColorHot := $00D2BDB6;
        Appearance.ColorHotTo := clNone;
        Appearance.DirectionType := dtAuto;
      end;
    tsWindowsVista:
      begin
        Appearance.Color := $FFFDF9;
        Appearance.ColorTo := $FFFAF0;
        Appearance.ColorHot := $FEF9F0;
        Appearance.ColorHotTo := $FDF0D7;
        Appearance.DirectionType := dtAuto;
      end;
    tsWindows7:
      begin
        Appearance.Color := $FDFBFA;
        Appearance.ColorTo := $FDF3EB;
        Appearance.ColorHot := $FCEBDC;
        Appearance.ColorHotTo := $FCDBC1;
        Appearance.DirectionType := dtAuto;
      end;
    tsTerminal:
      begin
        Appearance.Color := clSilver;
        Appearance.ColorTo := clSilver;
        Appearance.ColorHot := clHighLight;
        Appearance.ColorHotTo := clHighLight;
        Appearance.DirectionType := dtAuto;
      end;
    tsWhidbey:
      begin
        Appearance.Color := clWhite;
        Appearance.ColorTo := $00E3F0F2;
        Appearance.ColorHot := $00D3F8FF;
        Appearance.ColorHotTo := $0076C1FF;
        Appearance.DirectionType := dtAuto;
      end;
    tsCustom:
      begin
      end;
    tsOffice2007Silver:
      begin
        Appearance.Color := $F9F5F3;
        Appearance.ColorTo := $E7DCD5;
        Appearance.ColorHot := $00D3F8FF;
        Appearance.ColorHotTo := $0076C1FF;
        Appearance.DirectionType := dtAuto;
      end;
      tsOffice2010Blue:
      begin
        Appearance.Color := $FDF6EF;
        Appearance.ColorTo := $F0DAC7;
        Appearance.ColorHot := $7BEEFF;
        Appearance.ColorHotTo := $6CD0FF;
        Appearance.DirectionType := dtAuto;
      end;
      tsOffice2010Silver:
      begin
        Appearance.Color := $FFFFFF;
        Appearance.ColorTo := $EDE5E0;
         Appearance.ColorHot := $7BEEFF;
        Appearance.ColorHotTo := $6CD0FF;
        Appearance.DirectionType := dtAuto;
      end;
      tsOffice2010Black:
      begin
        Appearance.Color := $BFBFBF;
        Appearance.ColorTo := $919191;
        Appearance.ColorHot := $7BEEFF;
        Appearance.ColorHotTo := $6CD0FF;
        Appearance.DirectionType := dtAuto;
      end;
      tsWindows8:
      begin
        Appearance.Color := $F7F6F5;
        Appearance.ColorTo := $F7F6F5;
        Appearance.ColorHot := $F7EFE8;
        Appearance.ColorHotTo := $F7EFE8;
        Appearance.DirectionType := dtAuto;
      end;
      tsOffice2013White:
      begin
        Appearance.Color := $EEEEEE;
        Appearance.ColorTo := $EEEEEE;
        Appearance.ColorHot := $FCF0E4;
        Appearance.ColorHotTo := $FCF0E4;
        Appearance.DirectionType := dtAuto;
      end;
      tsOffice2013LightGray:
      begin
        Appearance.Color := $F6F6F6;
        Appearance.ColorTo := $F6F6F6;
        Appearance.ColorHot := $FCF0E4;
        Appearance.ColorHotTo := $FCF0E4;
        Appearance.DirectionType := dtAuto;
      end;
      tsOffice2013Gray:
      begin
        Appearance.Color := $E5E5E5;
        Appearance.ColorTo := $E5E5E5;
        Appearance.ColorHot := $FCF0E4;
        Appearance.ColorHotTo := $FCF0E4;
        Appearance.DirectionType := dtAuto;
      end;


  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomSplitter.SetGlyph(const Value: TBitmap);
begin
  FGlyph.Assign(Value);
end;

procedure TAdvCustomSplitter.SetGripStyle(const Value: TSplitterGripStyle);
begin
  if (FGripStyle <> Value) then
  begin
    FGripStyle := Value;
    Invalidate;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomSplitter.SetVersion(const Value: string);
begin

end;

//------------------------------------------------------------------------------

procedure TAdvCustomSplitter.WMEraseBkGnd(var msg: TWMEraseBkGnd);
begin
  inherited;
end;

//------------------------------------------------------------------------------

end.
