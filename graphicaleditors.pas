unit GraphicalEditors;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, PropEdits, GraphPropEdits, Graphics, Carpets;

type

  { TLCLGraphical }

  TLCLGraphical = class(TGraphical)
  private
    function GetGraphic: TGraphic;
    procedure SetGraphic(AValue: TGraphic);
  protected
    //FCarpet :TCustomCarpet;
    //FGraphic: TObject;
  public
    procedure Assign(Source: TPersistent); override;
    property Graphic : TGraphic read GetGraphic write SetGraphic;
  end;

  { TGraphicalPropertyEditor }

  TGraphicalPropertyEditor = class(TGraphicPropertyEditor)
  public
    //function GetObjectValue(MinClass: TClass): TObject;
    //procedure SetPtrValue(const NewValue: Pointer);
    procedure Edit; override;
  end;


implementation

uses GraphicPropEdit, UITypes;

{ TLCLGraphical }

function TLCLGraphical.GetGraphic: TGraphic;
begin
  result := FGraphic as TGraphic;
end;

procedure TLCLGraphical.SetGraphic(AValue: TGraphic);
var
  NewGraphic: TGraphic;
  ok: boolean;
begin
  if (AValue=FGraphic) then exit;
  NewGraphic := nil;
  ok := False;
  try
    if AValue <> nil then
    begin
      NewGraphic := TGraphicClass(AValue.ClassType).Create;
      NewGraphic.Assign(AValue);
      //NewGraphic.OnChange := @Changed;
      //NewGraphic.OnProgress := @Progress;
    end;
    FGraphic.Free;
    FGraphic := NewGraphic;
    Changed();
    ok := True;
  finally
    // this try..finally construction will in case of an exception
    // not alter the error backtrace output
    if not ok then
      NewGraphic.Free;
  end;
end;

procedure TLCLGraphical.Assign(Source: TPersistent);
begin
  if Source = nil then
    SetGraphic(nil)
  else if Source is TLCLGraphical then
    SetGraphic(TLCLGraphical(Source).Graphic)
  else if Source is TGraphic then
    SetGraphic(TGraphic(Source))
  //else if Source is TFPCustomImage then
    //Bitmap.Assign(Source)
  else
    inherited Assign(Source);
end;

{ TGraphicalPropertyEditor }

procedure TGraphicalPropertyEditor.Edit;
var
  TheDialog: TGraphicPropertyEditorForm;
  Picture: TLCLGraphical;
  o : TObject;
begin
  o := GetObjectValue(TGraphical);
  if not (o is TLCLGraphical) then
    exit;
  Picture := TLCLGraphical(o);
  TheDialog := TGraphicPropertyEditorForm.Create(nil);
  try
    TheDialog.CaptionDetail := GetComponent(0).GetNamePath + '.' + GetName();
    if (Picture.Graphic <> nil) then
      TheDialog.Graphic := Picture.Graphic;
    if (TheDialog.ShowModal = mrOK) and TheDialog.Modified then
    begin
      if TheDialog.Graphic <> nil then
      begin
        Picture.Graphic := TheDialog.Graphic;
        {if not Picture.Graphic.Equals(TheDialog.Graphic) then
        begin
          if (TheDialog.FileName <> '') and FileExistsUTF8(TheDialog.FileName) then
          begin
//            Picture.LoadFromFile(TheDialog.FileName);
            //MessageDlg('Differences detected, file reloaded', mtInformation, [mbOK], 0);
          end
          else
            //MessageDlg('Image may be different', mtWarning, [mbOK], 0);
        end;
        //AddPackage(Picture);
        }
      end
      else
        Picture.Graphic := nil;
      Modified;
    end;
  finally
    TheDialog.Free;
  end;
end;

initialization
  Carpets.TDefaultGraphicalClass := TLCLGraphical;
end.

