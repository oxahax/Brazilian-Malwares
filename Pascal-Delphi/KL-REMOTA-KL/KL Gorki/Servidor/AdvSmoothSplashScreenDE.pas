{**************************************************************************}
{ TAdvSmoothSplashScreenDE DESIGN TIME EDITOR                              }
{ for Delphi & C++Builder                                                  }
{                                                                          }
{ written by TMS Software                                                  }
{            copyright © 2009                                              }
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

unit AdvSmoothSplashScreenDE;

interface

{$I TMSDEFS.INC}

uses
  Classes, AdvSmoothSplashscreen,
  {$IFDEF DELPHI6_LVL}
  DesignIntf, DesignEditors
  {$ELSE}
  DsgnIntf
  {$ENDIF}
  ;

type
  TAdvSmoothSplashScreenEditor = class(TDefaultEditor)
  protected
    {$IFNDEF DELPHI6_LVL}
    procedure EditProperty(PropertyEditor: TPropertyEditor;
                           var Continue, FreeEditor: Boolean); override;
    {$ELSE}
    procedure EditProperty(const PropertyEditor: IProperty; var Continue: Boolean); override;
    {$ENDIF}
  public
    function GetVerb(index:integer):string; override;
    function GetVerbCount:integer; override;
    procedure ExecuteVerb(Index:integer); override;
  end;

implementation

uses
  SysUtils, Forms, AdvSmoothStyles, Dialogs, Controls, AdvStyleIF;

{$IFDEF DELPHI6_LVL}
procedure TAdvSmoothSplashScreenEditor.EditProperty(const PropertyEditor: IProperty; var Continue: Boolean);
{$ELSE}
procedure TAdvSmoothSplashScreenEditor.EditProperty(PropertyEditor: TPropertyEditor;
  var Continue, FreeEditor: Boolean);
{$ENDIF}
var
  PropName: string;
begin
  PropName := PropertyEditor.GetName;
  if (CompareText(PropName, 'FILL') = 0) then
    begin
      PropertyEditor.Edit;
      Continue := False;
    end;
end;

procedure TAdvSmoothSplashScreenEditor.ExecuteVerb(Index: integer);
var
  psf: TAdvSmoothStyleForm;
  style: TTMSStyle;
  timeout: integer;
  closetimeout: boolean;
  closemainformshow: boolean;
begin
  inherited;

  case Index of
  0:begin
     if (Component is TAdvSmoothSplashScreen) then
     begin
       timeout := (Component as TAdvSmoothSplashScreen).TimeOut;
       closetimeout := (Component as TAdvSmoothSplashScreen).CloseOnTimeOut;
       closemainformshow := (Component as TAdvSmoothSplashScreen).CloseOnMainFormShow;

       // force settings to show on timeout
       (Component as TAdvSmoothSplashScreen).TimeOut := 2000;
       (Component as TAdvSmoothSplashScreen).CloseOnTimeOut := true;
       (Component as TAdvSmoothSplashScreen).CloseOnMainFormShow := false;

       (Component as TAdvSmoothSplashScreen).Show;

       // restore original settings 
       (Component as TAdvSmoothSplashScreen).TimeOut := timeout;
       (Component as TAdvSmoothSplashScreen).CloseOnTimeOut := closetimeout;
       (Component as TAdvSmoothSplashScreen).CloseOnMainFormShow := closemainformshow;
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
        if (Component is TAdvSmoothSplashScreen) then
           (Component as TAdvSmoothSplashScreen).SetComponentStyle(style);
           Designer.Modified;
      end;
      psf.Free;
    end;
  end;
end;

function TAdvSmoothSplashScreenEditor.GetVerb(index: integer): string;
begin
  case Index of
  0: Result := 'Preview';
  1: Result := 'Styles';
  end;
end;

function TAdvSmoothSplashScreenEditor.GetVerbCount: integer;
begin
  Result := 2;
end;

end.







