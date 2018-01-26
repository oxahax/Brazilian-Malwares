{***************************************************************************}
{ TAdvMetroScrollBox component                                              }
{ for Delphi & C++Builder                                                   }
{                                                                           }
{ written by TMS Software                                                   }
{            copyright © 2012 - 2013                                        }
{            Email : info@tmssoftware.com                                   }
{            Web : http://www.tmssoftware.com                               }
{                                                                           }
{ The source code is given as is. The author is not responsible             }
{ for any possible damage done due to the use of this code.                 }
{ The component can be freely used in any application. The complete         }
{ source code remains property of the author and may not be distributed,    }
{ published, given or sold in any form as such. No parts of the source      }
{ code can be included in any other component or application without        }
{ written authorization of the author.                                      }
{***************************************************************************}

unit AdvMetroScrollBox;

{$I TMSDEFS.INC}

interface

uses
  Windows, SysUtils, CommCtrl, Classes, Controls, Forms,
  Graphics, ImgList, Messages, Math, Dialogs, AdvGDIP, AdvStyleIF, Types;

const

  MAJ_VER = 1; // Major version nr.
  MIN_VER = 0; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 1; // Build nr.

  // version history
  // 1.0.0.0 : First release
  // 1.0.0.1 : Fixed issue with activation of forms shown from form holding TScrollBox

  WM_USERACTIVATE = WM_USER + 120;
  SCROLLDELTA = 6;

type
  TWinCtrl = class(TWinControl)
  public
    procedure PaintCtrls(DC: HDC; First: TControl);
  end;

  TAdvMetroScrollBox = class;

  {$IFDEF DELPHIXE2_LVL}
  [ComponentPlatformsAttribute(pidWin32 or pidWin64)]
  {$ENDIF}
  TMetroScrollControl = class(TForm)
  private
    FScrollBox: TAdvMetroScrollBox;
    FDownOnScroller: Boolean;
    FDownPos: Integer;
    OldWndProc, NewWndProc: Pointer;
    FMainBuffer: TGPBitmap;
    FNewRange, FPageSize: Integer;
    FKind: TScrollBarKind;
    FScrollColor: TColor;
    FScrollWidth: Integer;
    FPosition: Integer;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMMouseActivate(var Msg: TWMMouseActivate); message WM_MOUSEACTIVATE;
    procedure WMActivate(var Message: TMessage); message WM_ACTIVATE;
    function ScrollBox: TAdvMetroScrollBox;
  protected
    procedure FormHookInit;
    procedure FormHookDone;
    procedure CreateWnd; override;
    procedure DoCreate; override;
    procedure DoDestroy; override;
    procedure Paint; override;
    procedure DblClick; override;
    procedure CalcRange;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;

    // ---- Paint proc
    procedure Draw(graphics: TGPGraphics);

    // ---- Paint buffer
    procedure CreateMainBuffer;
    procedure DestroyMainBuffer;
    procedure ClearBuffer(graphics: TGPGraphics);
    function CreateGraphics: TGPGraphics;

    //---- Layered window
    procedure SetLayeredWindow;
    procedure UpdateLayered;
    procedure UpdateMainWindow;
    procedure UpdateWindow;
    procedure WndProc(var Message: TMessage); override;
    procedure HookWndProc(var Msg: TMessage);
  public
    procedure Init;
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    property Kind: TScrollBarKind read FKind write FKind default sbVertical;
    property ScrollWidth: Integer read FScrollWidth write FScrollWidth default 4;
    property ScrollColor: TColor read FScrollColor write FScrollColor;
  end;


  TAdvMetroScrollBox = class(TScrollBox, ITMSTones)
  private
    FOldAutoScroll: Boolean;
    vscrlctrl, hscrlctrl: TMetroScrollControl;
    FCanvas: TCanvas;
    FOnVScroll: TNotifyEvent;
    FOnHScroll: TNotifyEvent;
    FOnHScrollEnd: TNotifyEvent;
    FOnVScrollEnd: TNotifyEvent;
    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    function GetVersion: string;
    procedure SetVersion(const Value: string);
  protected
    procedure CreateMetroScrollers;
    procedure DestroyMetroScrollers;
    procedure CreateWnd; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure UpdateSize;
    property Canvas: TCanvas read FCanvas;
    procedure AutoScrollInView(AControl: TControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Resize; override;
    procedure SetColorTones(ATones: TColorTones);
    function GetVersionNr: integer;
    property MetroVerticalScrollBar: TMetroScrollControl read vscrlctrl write vscrlctrl;
    property MetroHorizontalScrollBar: TMetroScrollControl read hscrlctrl write hscrlctrl;
  published
    property AutoScroll default false;
    property Ctl3D default false;
    property DoubleBuffered default true;
    property Version: string read GetVersion write SetVersion stored false;
    property OnVScroll: TNotifyEvent read FOnVScroll write FOnVScroll;
    property OnHScroll: TNotifyEvent read FOnHScroll write FOnHScroll;
    property OnVScrollEnd: TNotifyEvent read FOnVScrollEnd write FOnVScrollEnd;
    property OnHScrollEnd: TNotifyEvent read FOnHScrollEnd write FOnHScrollEnd;
  end;

implementation

//------------------------------------------------------------------------------

{TWinCtrl}

procedure TWinCtrl.PaintCtrls(DC: HDC; First: TControl);
begin
  PaintControls(DC, First);
end;

//------------------------------------------------------------------------------

{ TAdvMetroScrollBox }

procedure TAdvMetroScrollBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
   //Params.ExStyle := Params.ExStyle + WS_EX_TRANSPARENT;
end;

procedure TAdvMetroScrollBox.CreateWnd;
begin
  if (csDestroying in Componentstate) then
    Exit;

  inherited CreateWnd;

  if not Assigned(Parent) or not (Parent is TWinControl) then
    Exit;

  if not (csDesigning in ComponentState) then
    CreateMetroScrollers;

  FOldAutoScroll := AutoScroll;
  AutoScroll := False;

  if Assigned(MetroVerticalScrollBar) and Assigned(MetroHorizontalScrollBar) then
  begin
    MetroVerticalScrollBar.CalcRange;
    MetroHorizontalScrollBar.CalcRange;
    vscrlctrl.Visible := vscrlctrl.FNewRange > Height;
    hscrlctrl.Visible := hscrlctrl.FNewRange > Width;
  end;
end;

//------------------------------------------------------------------------------

constructor TAdvMetroScrollBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;
  DoubleBuffered := True;
  ParentCtl3D := False;
  Ctl3D := false;
  Width := 350;
  Height := 250;
end;

procedure TAdvMetroScrollBox.CreateMetroScrollers;
begin
  if not Assigned(vscrlctrl) then
  begin
    vscrlctrl := TMetroScrollControl.CreateNew(Self);
    vscrlctrl.FScrollBox := Self;
    vscrlctrl.Init;
    vscrlctrl.Kind := sbVertical;
    vscrlctrl.ScrollWidth := 4;
    vscrlctrl.Width := vscrlctrl.ScrollWidth + SCROLLDELTA;

    SetWindowPos(vscrlctrl.Handle, 0, vscrlctrl.Left, vscrlctrl.Top,
      vscrlctrl.Width, vscrlctrl.Height, SWP_SHOWWINDOW or SWP_NOACTIVATE);
  end;

  if not Assigned(hscrlctrl) then
  begin
    hscrlctrl := TMetroScrollControl.CreateNew(Self);
    hscrlctrl.FScrollBox := Self;
    hscrlctrl.Init;
    hscrlctrl.Kind := sbHorizontal;
    hscrlctrl.ScrollWidth := 4;
    hscrlctrl.Height := hscrlctrl.ScrollWidth + SCROLLDELTA;
    SetWindowPos(hscrlctrl.Handle, 0, hscrlctrl.Left, hscrlctrl.Top,
      hscrlctrl.Width, hscrlctrl.Height, SWP_SHOWWINDOW or SWP_NOACTIVATE);
  end;
end;

//------------------------------------------------------------------------------

destructor TAdvMetroScrollBox.Destroy;
begin
  DestroyMetroScrollers;
  FCanvas.Free;
  inherited;
end;

procedure TAdvMetroScrollBox.DestroyMetroScrollers;
begin
  if Assigned(vscrlctrl) then
  begin
    vscrlctrl.Free;
    vscrlctrl := nil;
  end;

  if Assigned(hscrlctrl) then
  begin
    hscrlctrl.Free;
    hscrlctrl := nil;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvMetroScrollBox.Resize;
begin
  inherited;
  if Assigned(vscrlctrl) and Assigned(hscrlctrl) then
  begin
    vscrlctrl.CalcRange;
    hscrlctrl.CalcRange;

    vscrlctrl.Visible := vscrlctrl.FNewRange > Height;
    hscrlctrl.Visible := hscrlctrl.FNewRange > Width;

    vscrlctrl.Invalidate;
    hscrlctrl.Invalidate;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvMetroScrollBox.WMHScroll(var Message: TWMHScroll);
begin
  inherited;
  Invalidate;

  if (Message.ScrollCode <> SB_ENDSCROLL) and Assigned(FOnHScroll) then
  begin
    FOnHScroll(Self);
  end;

  if (Message.ScrollCode = SB_ENDSCROLL) and Assigned(FOnHScrollEnd) then
  begin
    FOnHScrollEnd(Self);
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvMetroScrollBox.WMVScroll(var Message: TWMVScroll);
begin
  inherited;
  Invalidate;

  if (Message.ScrollCode <> SB_ENDSCROLL) and Assigned(FOnVScroll) then
  begin
    FOnVScroll(Self);
  end;

  if (Message.ScrollCode = SB_ENDSCROLL) and Assigned(FOnVScrollEnd) then
  begin
    FOnVScrollEnd(Self);
  end;
end;

//------------------------------------------------------------------------------

function TAdvMetroScrollBox.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

//------------------------------------------------------------------------------

function TAdvMetroScrollBox.GetVersionNr: integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

//------------------------------------------------------------------------------

procedure TAdvMetroScrollBox.SetColorTones(ATones: TColorTones);
begin
  Color := ATones.Background.BrushColor;
end;

procedure TAdvMetroScrollBox.SetVersion(const Value: string);
begin

end;

procedure TAdvMetroScrollBox.UpdateSize;
var
  x, y: Integer;
begin
  if Assigned(Parent) then
  begin
    x := Parent.ClientOrigin.X + Self.Left;
    y := Parent.ClientOrigin.Y + Self.Top;
    if Assigned(vscrlctrl) then
      vscrlctrl.SetBounds(x + self.Width - vscrlctrl.Width, y, vscrlctrl.Width, self.Height - SCROLLDELTA);

    if Assigned(hscrlctrl) then
      hscrlctrl.SetBounds(x, y + self.Height - hscrlctrl.Height, self.Width - SCROLLDELTA, hscrlctrl.Height);
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvMetroScrollBox.AutoScrollInView(AControl: TControl);
begin
  if AutoScroll then
    inherited;
end;

procedure TMetroScrollControl.FormHookDone;
var
  f: TCustomForm;
begin
  if Assigned(FScrollBox) then
  begin
    f := GetParentForm(ScrollBox);
    if Assigned(f) and f.HandleAllocated then
    begin
      SetWindowLong(f.Handle, GWL_WNDPROC, LongInt(OldWndProc));
    end;
  end;
end;

procedure TMetroScrollControl.FormHookInit;
var
  f: TCustomForm;
begin
  if Assigned(FScrollBox) then
  begin
    f := GetParentForm(ScrollBox);
    if Assigned(f) then
    begin
       { Hook parent }
      OldWndProc := TFarProc(GetWindowLong(f.Handle, GWL_WNDPROC));
      {$IFDEF DELPHI9_LVL}
      NewWndProc := Classes.MakeObjectInstance(HookWndProc);
      {$ELSE}
      NewWndProc := MakeObjectInstance(HookWndProc);
      {$ENDIF}

      SetWindowLong(f.Handle, GWL_WNDPROC, LongInt(NewWndProc));
    end;
  end;
end;

procedure TMetroScrollControl.ClearBuffer(graphics: TGPGraphics);
var
  g: TGPGraphics;
begin
  g := graphics;
  if not Assigned(g) then
    g := CreateGraphics;
  g.Clear($00000000);
  if not Assigned(graphics) then
    g.Free;
end;

function TMetroScrollControl.CreateGraphics: TGPGraphics;
begin
  Result := nil;
  if Assigned(FMainBuffer) then
    Result := TGPGraphics.Create(FMainBuffer);
end;

procedure TMetroScrollControl.CreateMainBuffer;
begin
  if Assigned(FMainBuffer) then
  begin
    FMainBuffer.Free;
    FMainBuffer := nil;
  end;

  FMainBuffer := TGPBitmap.Create(Width, Height, PixelFormat32bppARGB);
end;

constructor TMetroScrollControl.CreateNew(AOwner: TComponent;
  Dummy: Integer);
begin
  inherited;
end;

procedure TMetroScrollControl.CreateParams(var Params: TCreateParams);
begin
  inherited;
end;

procedure TMetroScrollControl.CreateWnd;
begin
  inherited;
  FormHookInit;
  UpdateWindow;
end;

procedure TMetroScrollControl.DblClick;
begin
  inherited;
end;

procedure TMetroScrollControl.DestroyMainBuffer;
begin
  if Assigned(FMainBuffer) then
  begin
    FMainBuffer.Free;
    FMainBuffer := nil;
  end;
end;

procedure TMetroScrollControl.DoCreate;
begin
  inherited;
  FMainBuffer := nil;
end;

procedure TMetroScrollControl.DoDestroy;
begin
  inherited;
  DestroyMainBuffer;
end;

procedure TMetroScrollControl.DragDrop(Source: TObject; X, Y: Integer);
begin
  inherited;

end;

procedure TMetroScrollControl.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  inherited;

end;

procedure TMetroScrollControl.Draw(graphics: TGPGraphics);
var
  g: TGPGraphics;
  sz, szh: integer;
  b: TGPSolidBrush;
begin
  g := graphics;
  if not Assigned(g) then
    g := CreateGraphics;

  if Assigned(FScrollBox) then
  begin
    if (FNewRange > 0) then
    begin
      szh := FPosition;
      sz := FPageSize;

      b := TGPSolidBrush.Create(MakeColor(255, FScrollColor));

      if FKind = sbVertical then
        g.FillRectangle(b, MakeRect((Width - FScrollWidth) / 2, szh,FScrollWidth, sz))
      else
        g.FillRectangle(b, MakeRect(szh, Round((Height - FScrollWidth) / 2), sz, FScrollWidth));

      b.Free;
    end;
  end;

  if not Assigned(graphics) then
    g.Free;
end;

procedure TMetroScrollControl.HookWndProc(var Msg: TMessage);
var
  f: TCustomForm;
begin
  inherited;
  if csDestroying in ComponentState then
    Exit;

  if Assigned(FScrollBox) then
  begin
    f := GetParentForm(ScrollBox);
    if Assigned(f) then
    begin
      Msg.Result := CallWindowProc(OldWndProc, f.Handle, Msg.Msg , Msg.wParam, Msg.lParam);

      case Msg.Msg of
       WM_ACTIVATE:
       begin
         if ScrollBox.Visible and (Msg.WParam <> 0) then
           PostMessage(Self.Handle, WM_USERACTIVATE, MSG.WParam, 0);
       end;
       WM_SIZE, WM_WINDOWPOSCHANGING: ScrollBox.UpdateSize;
      end;

    end;
  end;
end;

procedure TMetroScrollControl.Init;
begin
  FScrollWidth := 4;
  FKind := sbVertical;

  Visible := False;
  BorderIcons := [];
  BorderStyle := bsNone;
  Ctl3D := false;
  FormStyle := fsStayOnTop;
  Color := clWhite;
  FScrollColor := clSilver;
  Position := poScreenCenter;
  CreateMainBuffer;
  SetLayeredWindow;
  UpdateLayered;
end;

procedure TMetroScrollControl.Paint;
begin
  inherited;
  UpdateWindow;
end;

procedure TMetroScrollControl.SetLayeredWindow;
begin
  if GetWindowLong(Handle, GWL_EXSTYLE) and WS_EX_LAYERED = 0 then
    SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_LAYERED);

  UpdateLayered;
end;

procedure TMetroScrollControl.UpdateLayered;
begin
  ClearBuffer(nil);

  SetWindowPos(Self.Handle, HWND_TOPMOST, 0, 0, 0, 0,
    SWP_NOMOVE or SWP_NOSIZE or SWP_FRAMECHANGED or SWP_NOACTIVATE);

  Draw(nil);

  UpdateMainWindow;
end;

procedure TMetroScrollControl.UpdateMainWindow;
var
  ScrDC, MemDC: HDC;
  BitmapHandle, PrevBitmap: HBITMAP;
  BlendFunc: _BLENDFUNCTION;
  Size: TSize;
  P, S: TPoint;
begin
//  while BlendFunc.SourceConstantAlpha < 255 do
//  begin
    ScrDC := CreateCompatibleDC(0);
    MemDC := CreateCompatibleDC(ScrDC);

    FMainBuffer.GetHBITMAP(0, BitmapHandle);
    PrevBitmap := SelectObject(MemDC, BitmapHandle);
    Size.cx := Width;
    Size.cy := Height;
    P := Point(Left, Top);
    S := Point(0, 0);

    with BlendFunc do
    begin
      BlendOp := AC_SRC_OVER;
      BlendFlags := 0;
      SourceConstantAlpha := 255;
      AlphaFormat := AC_SRC_ALPHA;
    end;

    UpdateLayeredWindow(Handle, ScrDC, @P, @Size, MemDC, @S, 0, @BlendFunc, ULW_ALPHA);

    SelectObject(MemDC, PrevBitmap);
    DeleteObject(BitmapHandle);

    DeleteDC(MemDC);
    DeleteDC(ScrDC);
//  end;
end;

procedure TMetroScrollControl.UpdateWindow;
begin
  CreateMainBuffer;
  UpdateLayered;
end;

procedure TMetroScrollControl.WMActivate(var Message: TMessage);
begin
  inherited;
  Message.Result := 1;
end;

procedure TMetroScrollControl.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
begin
  inherited;
end;

procedure TMetroScrollControl.WMMouseActivate(var msg: TWMMouseActivate);
begin
  msg.result := MA_NOACTIVATE;
end;

procedure TMetroScrollControl.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  DefaultHandler(Msg);
  if Msg.Result = HTCAPTION then
    Msg.Result := HTNOWHERE;
end;

procedure TMetroScrollControl.WMPaint(var Message: TWMPaint);
begin
  inherited;
end;

procedure TMetroScrollControl.WndProc(var Message: TMessage);
begin
  if Assigned(FScrollBox) and not (csDestroying in ComponentState) then
  begin
    if Message.Msg = WM_DESTROY then
    begin
      FormHookDone;
    end
    else if Message.Msg = WM_USERACTIVATE then
    begin
      ScrollBox.UpdateSize;
      UpdateWindow;
      case Message.WParam of
        0: ShowWindow(Self.Handle, SW_HIDE);
        1, 2: ShowWindow(Self.Handle, SW_SHOWNA);
      end;
    end;
  end;
  inherited;
end;


procedure TMetroScrollControl.CalcRange;
var
  I: Integer;
  AlignMargin: Integer;
  scrlbox: TAdvMetroScrollBox;
  scrh, scrw: Integer;

  procedure ProcessHorz(Control: TControl);
  begin
    if Control.Visible then
      case Control.Align of
        alLeft, alNone:
          if (Control.Align = alLeft) or (Control.Anchors * [akLeft, akRight] = [akLeft]) then
            FNewRange := Max(FNewRange, FPosition + Control.Left + Control.Width);
        alRight: Inc(AlignMargin, Control.Width);
      end;
  end;

  procedure ProcessVert(Control: TControl);
  begin
    if Control.Visible then
      case Control.Align of
        alTop, alNone:
          if (Control.Align = alTop) or (Control.Anchors * [akTop, akBottom] = [akTop]) then
            FNewRange := Max(FNewRange, FPosition + Control.Top + Control.Height);
        alBottom: Inc(AlignMargin, Control.Height);
      end;
  end;

begin
  FNewRange := 0;
  for I := 0 to ScrollBox.ControlCount - 1 do
  begin
    if Kind = sbHorizontal then
      ProcessHorz(ScrollBox.Controls[I])
    else
      ProcessVert(ScrollBox.Controls[I]);
  end;

  scrlbox := ScrollBox;

  if FNewRange > 0 then
  begin
    if Kind = sbVertical then
    begin
      scrh := scrlbox.Height - SCROLLDELTA;
      if FNewRange > scrh then
      begin
        FPageSize := Round(scrh * (scrh / FNewRange));
        if FPosition + FPageSize > scrh then
          FPosition := Max(0, scrh - FPageSize);
      end
      else
      begin
        FPosition := 0;
        FPageSize := 0;
      end;
    end
    else
    begin
      scrw := scrlbox.Width - SCROLLDELTA;
      if FNewRange > scrw then
      begin
        FPageSize := Round(scrw * (scrw / FNewRange));
        if FPosition + FPageSize > scrw then
          FPosition := Max(0, scrw - FPageSize);
      end
      else
      begin
        FPosition := 0;
        FPageSize := 0;
      end;
    end;
  end;
end;

function TMetroScrollControl.ScrollBox: TAdvMetroScrollBox;
begin
  Result := FScrollBox;
end;

procedure TMetroScrollControl.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  scrlbox: TAdvMetroScrollBox;
  scrw, scrh, delta: integer;

begin
  inherited;
  scrlbox := ScrollBox;
  if Assigned(scrlbox) and FDownOnScroller and (FNewRange > 0) then
  begin
    scrw := scrlbox.Width - SCROLLDELTA;
    scrh := scrlbox.Height - SCROLLDELTA;
    if Kind = sbVertical then
    begin
      delta := Y - FDownPos;
      FDownPos := Y;
      FPosition := FPosition + delta;
      if FPosition > scrh - FPageSize then
      begin
        FPosition := scrh - FPageSize;
        delta := 0;
      end;
      if FPosition < 0 then
      begin
        FPosition := 0;
        delta := 0;
      end;

      scrlbox.ScrollBy(0, -Round(delta * FNewRange / scrh));
      scrlbox.Repaint;
      Invalidate;
    end
    else
    begin
      delta := X - FDownPos;
      FDownPos := X;
      FPosition := FPosition + delta;
      if FPosition > scrw - FPageSize then
      begin
        FPosition := scrw - FPageSize;
        delta := 0;
      end;
      if FPosition < 0 then
      begin
        FPosition := 0;
        delta := 0;
      end;

      scrlbox.ScrollBy(-Round(delta * FNewRange / scrw), 0);
      scrlbox.Repaint;
      Invalidate;
    end;
  end;
end;

procedure TMetroScrollControl.MouseDown(Button:TMouseButton; Shift:TShiftState; X,Y:Integer);
var
  scrlbox: TAdvMetroScrollBox;
begin
  inherited;
  scrlbox := ScrollBox;
  if Assigned(scrlbox) then
  begin
    if Kind = sbVertical then
    begin
      FDownOnScroller := true;
      FDownPos := Y;
    end
    else
    begin
      FDownOnScroller := true;
      FDownPos := X;
    end;
  end;
end;

procedure TMetroScrollControl.MouseUp(Button:TMouseButton; Shift:TShiftState; X,Y:Integer);
begin
  inherited;
  FDownOnScroller := false;
end;


end.
