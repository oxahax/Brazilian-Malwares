{*************************************************************************}
{ TMS AdvExplorerTreeview component                                       }
{ for Delphi & C++Builder                                                 }
{                                                                         }
{ written by TMS Software                                                 }
{           copyright © 2008 - 2010                                       }
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

{$I TMSDEFS.INC}

unit AdvExplorerTreeviewDE;

interface

uses
  Classes, Controls, AdvExplorerTreeview, AdvExplorerTreeviewEditor, Forms, dialogs
  {$IFDEF DELPHI6_LVL}
  , DesignIntf, DesignEditors
  {$ELSE}
  , DsgnIntf
  {$ENDIF}
  ;

type

  TAdvExplorerTreeviewEditor = class(TDefaultEditor)
  protected
  {$IFNDEF DELPHI6_LVL}
    procedure EditProperty(PropertyEditor: TPropertyEditor; var Continue, FreeEditor: Boolean); override;
  {$ELSE}
    procedure EditProperty(const PropertyEditor:IProperty; var Continue:Boolean); override;
  {$ENDIF}
  public
    function GetVerb(index:integer):string; override;
    function GetVerbCount:integer; override;
    procedure ExecuteVerb(Index:integer); override;
  end;

  TTreeviewPropEditor = class(TClassProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
    procedure SetValue(const Value: String); override;
    function GetValue: String; override;
  end;


implementation

uses
  SysUtils, TypInfo, AdvExplorerTreeviewStyles, AdvStyleIF;

//------------------------------------------------------------------------------
{ TAdvExplorerTreeviewEditor }

{$IFNDEF DELPHI6_LVL}
procedure TAdvExplorerTreeviewEditor.EditProperty(PropertyEditor: TPropertyEditor;
  var Continue, FreeEditor: Boolean); 
{$ELSE}
procedure TAdvExplorerTreeviewEditor.EditProperty(const PropertyEditor:IProperty; var Continue:Boolean);
{$ENDIF}
var
  PropName: string;
begin
  //ExecuteVerb(0);
  //Continue := False;
  PropName := PropertyEditor.GetName;
  if (CompareText(PropName, 'ITEMS') = 0) then
  begin
    PropertyEditor.Edit;
    Continue := False;
  end;
end;

//------------------------------------------------------------------------------

function GetParentForm(AComponent: TComponent): TComponent;
begin
  Result := AComponent.Owner;
end;

//------------------------------------------------------------------------------

procedure TAdvExplorerTreeviewEditor.ExecuteVerb(Index: integer);
var
  TreeViewEditor: TExpTreeviewEditor;
  ExplorerTreeview: TAdvExplorerTreeview;
  psf: TAdvExplorerTreeViewStyleForm;
  style: TTMSStyle;
begin
  if (Index = 0) then
  begin
    if (Component is TAdvExplorerTreeview) then
    begin
      ExplorerTreeview := TAdvExplorerTreeview(Component);
      TreeviewEditor := TExpTreeviewEditor.Create(Application);
      TreeviewEditor.ExplorerTreeview := ExplorerTreeview;
      try
        if TreeviewEditor.Showmodal = mrOK then
          Designer.Modified;
      finally
        TreeviewEditor.Free;
      end;
    end;
  end
  else if (Index = 1) then
  begin
    psf := TAdvExplorerTreeViewStyleForm.Create(Application);
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
      11: style := tsOffice2010Blue;
      12: style := tsOffice2010Silver;
      13: style := tsOffice2010Black;
      end;
      if (Component is TAdvExplorerTreeview) then
         (Component as TAdvExplorerTreeview).SetComponentStyle(style);
         Designer.Modified;
    end;
    psf.Free;
  end;
end;

//------------------------------------------------------------------------------

function TAdvExplorerTreeviewEditor.GetVerb(index: integer): string;
begin
  Result := '';
  case Index of
    0: Result := 'AdvExplorerTreeview Editor';
    1: Result := 'Styles';
  end;
end;

//------------------------------------------------------------------------------

function TAdvExplorerTreeviewEditor.GetVerbCount: integer;
begin
 Result := 2;
end;

//------------------------------------------------------------------------------

{ TTreeviewPropEditor }

function TTreeviewPropEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

//------------------------------------------------------------------------------

procedure TTreeviewPropEditor.Edit;
var
  TreeViewEditor: TExpTreeviewEditor;
  ExplorerTreeview: TAdvExplorerTreeview;
begin
  if (GetComponent(0) is TAdvExplorerTreeview) then
  begin
    ExplorerTreeview := TAdvExplorerTreeview(GetComponent(0));
    TreeviewEditor := TExpTreeviewEditor.Create(Application);
    TreeviewEditor.ExplorerTreeview := ExplorerTreeview;
    try
      if TreeviewEditor.Showmodal = mrOK then
      begin
        //SetObjectProp(ExplorerTreeview, 'Items', ExplorerTreeview.Items);
        Modified;
        //SetStrValue(s);
      end;
    finally
      TreeviewEditor.Free;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TTreeviewPropEditor.SetValue(const Value: String);
begin
end;

//------------------------------------------------------------------------------

function TTreeviewPropEditor.GetValue: String;
begin
  Result:='(ExplorerTreeviewItems)';
end;

//------------------------------------------------------------------------------

end.