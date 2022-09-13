unit CarpetPropEdits;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, PropEdits, GraphPropEdits, Graphics;

type

  { TCarpetColorPropertyEditor }

  TCarpetColorPropertyEditor = class(TColorPropertyEditor)
  public
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const NewValue: ansistring); override;
    function OrdValueToVisualValue(OrdValue: longint): string; override;
    procedure ListDrawValue(const CurValue: ansistring; Index: integer;
      ACanvas: TCanvas; const ARect:TRect; AState: TPropEditDrawState); override;
  end;

  { TGraphicalPropertyEditor0 }

  TGraphicalPropertyEditor0 = class(TGraphicPropertyEditor)
  public
    function GetObjectValue(MinClass: TClass): TObject;
    procedure SetPtrValue(const NewValue: Pointer);
    //procedure Edit; override;
  end;

function GetShadowColor(BaseColor: TColor): TColor;
function ShiftColor(BaseColor: TColor; Value: integer): TColor;

implementation
uses Math, LCLIntf, Carpets;

const
  CarpetColors: array[0..11] of TIdentMapEntry = (
  // carpet colors  : BbGgRr
  (Value: $00BAFECB; Name: 'clGreenCarpet'),
  (Value: $00FBC4FF; Name: 'clPinkCarpet'),
  (Value: $00FFFBC4; Name: 'clBlueCarpet'),

  (Value: $00C4FFFF; Name: 'clYellowCarpet'),
  (Value: $00E4DEDF; Name: 'clGrayCarpet'),
  (Value: $00FFC4CF; Name: 'clPurpleCarpet'),

  (Value: $00E1E1E1; Name: 'clWhiteCarpet'),
  (Value: $00BFBDC9; Name: 'clSandCarpet'),
  (Value: $005C73AE; Name: 'clBrownCarpet'),
  (Value: $005DD1FD; Name: 'clGoldCarpet'),
  (Value: $0067DBB2; Name: 'clAvocadoCarpet'),


  // must be the last
  (Value: clTransparentCarpet; Name: 'clTransparentCarpet')

  );

function CarpetColorToIdent(Color: Longint; out Ident: String): Boolean;
begin
  Result := IntToIdent(Color, Ident, CarpetColors);
end;

function IdentToCarpetColor(const Ident: string; var Color: Longint): boolean;
begin
  result := IdentToInt(Ident, Color, CarpetColors);
end;

function StringToCarpetColorDef(const S: shortstring; const DefaultValue: TColor): TColor;
begin
  if not IdentToCarpetColor(s, result) then
     result := StringToColorDef(s, DefaultValue);
end;

function GetShadowColor(BaseColor: TColor): TColor;
//taken from http://www.swissdelphicenter.ch/torry/showcode.php?id=1194
begin
  Result := RGB(
    Max(GetRValue(ColorToRGB(BaseColor)) - 64, 0),
    Max(GetGValue(ColorToRGB(BaseColor)) - 64, 0),
    Max(GetBValue(ColorToRGB(BaseColor)) - 64, 0));
end;

function ShiftColor(BaseColor: TColor; Value: integer): TColor;
var LColor : DWord;
begin
  LColor := ColorToRGB(BaseColor);
  Result := RGB(
    Min(255, Max(GetRValue(LColor) + Value, 0)),
    Min(255, Max(GetGValue(LColor) + Value, 0)),
    Min(255, Max(GetBValue(LColor) + Value, 0))
  );
end;

function DarkenColor(BaseColor: TColor; Value: integer): TColor;
begin
  result :=  ShiftColor(BaseColor, -Value);
end;

function LightenColor(BaseColor: TColor; Value: integer): TColor;
begin
  result :=  ShiftColor(BaseColor, Value);
end;

{ TGraphicalPropertyEditor0 }

function TGraphicalPropertyEditor0.GetObjectValue(MinClass: TClass): TObject;
var graphica : TGraphical;
begin
  graphica := TGraphical(GetObjectValueAt(0, TGraphical));
  result := TGraphic(graphica.Graphic);
end;

procedure TGraphicalPropertyEditor0.SetPtrValue(const NewValue: Pointer);
var graphica : TGraphical;
  agraphic,lgraphic : TGraphic;
begin
  graphica := TGraphical(GetObjectValueAt(0, TGraphical));
  if assigned(graphica.Graphic) then
     graphica.Graphic.Free;

  if newValue <> nil then
  begin
    agraphic := TGraphic(NewValue);

    LGraphic := TGraphicClass(agraphic.ClassType).Create;
    LGraphic.Assign(aGraphic);
    graphica.Graphic := lgraphic;
    lgraphic := nil;
  end;
end;

{ TCarpetColorPropertyEditor }

procedure TCarpetColorPropertyEditor.GetValues(Proc: TGetStrProc);
var
  CValue: Longint;
  i : integer;
begin
  if not IdentToInt(GetVisualValue, CValue, CarpetColors) then
     if not IdentToColor(GetVisualValue, CValue) then
        Proc(GetVisualValue);
  for i := 0 to Length(CarpetColors) -1 do
      Proc(CarpetColors[I].Name);
  //GetColorValues(Proc);
  //inherited GetValues(Proc);
end;

procedure TCarpetColorPropertyEditor.SetValue(const NewValue: ansistring);
var
  CValue: Longint;
begin
  if IdentToInt(NewValue, CValue, CarpetColors) then
    SetOrdValue(CValue)
  else
    inherited SetValue(NewValue);
end;

function TCarpetColorPropertyEditor.OrdValueToVisualValue(OrdValue: longint
  ): string;
begin
  Result := '';
  if not CarpetColorToIdent(OrdValue, Result) then
    Result:=inherited OrdValueToVisualValue(OrdValue);
end;

procedure TCarpetColorPropertyEditor.ListDrawValue(const CurValue: ansistring;
  Index: integer; ACanvas: TCanvas; const ARect: TRect;
  AState: TPropEditDrawState);
var
  vRight, vBottom: Integer;
  vOldPenColor, vOldBrushColor: TColor;
  vOldPenStyle: TPenStyle;
  R : TRect;
begin
  inherited ListDrawValue(CurValue, Index, ACanvas, ARect, AState);
  vRight := (ARect.Bottom - ARect.Top) + ARect.Left - 2;
  vBottom:=ARect.Bottom-2;
  R := Rect(ARect.Left, ARect.Top, ARect.Left+ (ARect.Bottom- ARect.Top), ARect.Bottom);
  with ACanvas do
  begin
    // save off things
    vOldPenStyle := Pen.Style;
    vOldPenColor := Pen.Color;
    vOldBrushColor := Brush.Color;

    // frame things
    if pedsInEdit in AState then
    begin
      if pedsSelected in AState then
        Brush.Color := clWindow
      else
        Brush.Color := ACanvas.Brush.Color;
    end
    else
    begin
      if pedsSelected in AState then
        Brush.Color := clHighlight
      else
       Brush.Color := clWindow;
    end;
    Pen.Color := Brush.Color;
    Pen.Style := psSolid;
    FillRect(R);
    Rectangle(R);//ARect.Left, ARect.Top, vRight, vBottom);


    // set things up and do the work
    Brush.Color := StringToCarpetColorDef(CurValue,clNone);
    Pen.Color := GetShadowColor(ColorToRGB(Brush.Color));
    Rectangle(ARect.Left + 1, ARect.Top + 1, vRight - 1, vBottom - 1);

    // restore the things we twiddled with
    Brush.Color := vOldBrushColor;
    Pen.Color := vOldPenColor;
    Pen.Style := vOldPenStyle;
  end;
  {inherited ListDrawValue(CurValue, Index, ACanvas,
                          Rect(vRight, ARect.Top, ARect.Right, ARect.Bottom),
                          AState);}

end;

end.

