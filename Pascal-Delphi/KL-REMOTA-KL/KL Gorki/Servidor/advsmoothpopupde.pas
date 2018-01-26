{**************************************************************************}
{ TAdvSmoothPopup DESIGN TIME EDITOR                                       }
{ for Delphi & C++Builder                                                  }
{                                                                          }
{ written by TMS Software                                                  }
{            copyright © 2010                                              }
{            Email : info@tmssoftware.com                                  }
{            Web : http://www.tmssoftware.com                              }
{                                                                          }
{ The source code is given as is. The author is not responsible            }
{ for any possible damage done due to the use of this code.                }
{ The component can be freely used in any application. The complete        }
{ source code remains property of the author and may not be distributed,   }
{ published, given or sold in any form as such. No parts of the source     }
{ code can be included in any other component or application without       }
{ written authorization of the author.                                     }
{**************************************************************************}

unit AdvSmoothPopupDE;

interface

{$I TMSDEFS.INC}

uses
  Classes, AdvSmoothPopup,
  {$IFDEF DELPHI6_LVL}
  DesignIntf, DesignEditors
  {$ELSE}
  DsgnIntf
  {$ENDIF}
  ;

type
  TAdvSmoothPopupEditor = class(TDefaultEditor)
  public
    function GetVerb(index:integer):string; override;
    function GetVerbCount:integer; override;
    procedure ExecuteVerb(Index:integer); override;
  end;


implementation

uses
  SysUtils, Forms, Windows, AdvSmoothStyles, Dialogs, Controls, AdvStyleIF;

procedure TAdvSmoothPopupEditor.ExecuteVerb(Index: integer);
var
  psf: TAdvSmoothStyleForm;
  style: TTMSStyle;
  l, t: Integer;
  p: TPoint;
begin
  inherited;
  case Index of
  0:begin
      if (Component is TAdvSmoothPopup) then
      begin
        l := LongRec(Component.DesignInfo).Lo;
        t := LongRec(Component.DesignInfo).Hi;
        p := Point(l, t);

        if (Component.Owner is TControl) then
          if Assigned((Component.Owner as TControl).Parent) then
            p := (Component.Owner as TControl).Parent.ClientToScreen(p);

       (Component as TAdvSmoothPopup).PopupAt(p.X, p.Y);
      end;
    end;
  1:begin
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
        if (Component is TAdvSmoothPopup) then
           (Component as TAdvSmoothPopup).SetComponentStyle(style);
           Designer.Modified;
      end;
      psf.Free;
    end;
    2:
    begin
      if (Component is TAdvSmoothPopup) then
           (Component as TAdvSmoothPopup).SetDefaultStyle;
      Designer.Modified;
    end;
  end;
end;

function TAdvSmoothPopupEditor.GetVerb(index: integer): string;
begin
  case Index of
  0: Result := 'Preview';
  1: Result := 'Styles';
  2: Result := 'Default Style';
  end;
end;

function TAdvSmoothPopupEditor.GetVerbCount: integer;
begin
  Result := 3;
end;



end.







