unit Carpet_Canvas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Carpets, Graphics;

type

  { TLCLCarpetCanvas }

  TLCLCarpetCanvas = class(TCarpetCanvas)
  private
    FLCLcanvas: TCanvas;
  protected
    property LCLCanvas : TCanvas read FLCLcanvas write FLCLcanvas;
  public
    procedure FillRect(const X1,Y1,X2,Y2: Integer; const AColor: Cardinal); override;
    procedure Frame3D(var ARect: TRect; TopColor, BottomColor: Cardinal;
                      const FrameWidth: integer); override;
    procedure Rectangle(X1,Y1,X2,Y2: Integer; AColor: Cardinal); override;
    procedure StretchDraw(DestRect: TRect; SrcGraphic: TObject; Stretched:Boolean); override;
    procedure TextOut(X,Y: Integer; const Text: String; AColor: Cardinal = $20000000); override;
    procedure TextRect(ARect: TRect; const Text: string; Alignment: TAlignment); override;
    procedure PictureWriteStream(AGraphical:TGraphical; Stream:TStream); override;
    procedure PictureReadStream(AGraphical:TGraphical; Stream:TStream); override;
  end;



implementation

uses GraphicalEditors;

{ TLCLCarpetCanvas }

procedure TLCLCarpetCanvas.FillRect(const X1, Y1, X2, Y2: Integer;
  const AColor: Cardinal);
begin
  if not assigned(LCLCanvas) then exit;
  LCLCanvas.Brush.Color:=AColor;
  LCLCanvas.Brush.Style:=bsSolid;
  LCLCanvas.FillRect(x1,y1,x2,y2);
end;

procedure TLCLCarpetCanvas.Frame3D(var ARect: TRect; TopColor,
  BottomColor: Cardinal; const FrameWidth: integer);
begin
  if not assigned(LCLCanvas) then exit;
  LCLCanvas.Frame3D(ARect,TopColor,BottomColor,FrameWidth);
end;

procedure TLCLCarpetCanvas.Rectangle(X1, Y1, X2, Y2: Integer; AColor: Cardinal);
begin
  if not assigned(LCLCanvas) then exit;
  LCLCanvas.Pen.Color:=AColor;
  LCLCanvas.Rectangle(x1,y1,x2,y2);
end;

procedure TLCLCarpetCanvas.StretchDraw(DestRect: TRect;
  SrcGraphic: TObject; Stretched:Boolean);
begin
  if not assigned(LCLCanvas) then exit;
  if not assigned(SrcGraphic) then exit;
  if not stretched then
    with TGraphic(SrcGraphic) do
      DestRect := Bounds(0,0, width, height);
  LCLCanvas.StretchDraw(DestRect, TGraphic(SrcGraphic));
end;

procedure TLCLCarpetCanvas.TextOut(X, Y: Integer; const Text: String; AColor: Cardinal = $20000000);
var C : TColor;
begin
  if not assigned(LCLCanvas) then exit;
  C := LCLCanvas.Font.Color;
  if AColor <> $20000000 {clDefault} then
    LCLCanvas.Font.Color := TColor(AColor);
  LCLCanvas.Font.Style:= [fsBold];
  LCLCanvas.Brush.Style:=bsClear;
  LCLCanvas.TextOut(X,Y,Text);
  LCLCanvas.Font.Color := C

end;

procedure TLCLCarpetCanvas.TextRect(ARect: TRect; const Text: string;
  Alignment: TAlignment);
var style : TTextStyle;
begin
  style.Alignment:=Alignment;
  style.Wordbreak := True;
  style.EndEllipsis:=True;
  style.Clipping:=True;
  LCLCanvas.TextRect(ARect, ARect.Left, ARect.Top, text, style);
end;

procedure TLCLCarpetCanvas.PictureWriteStream(AGraphical:TGraphical; Stream: TStream
  );
begin
  TGraphic(AGraphical.Graphic).SaveToStream(Stream);
end;

procedure TLCLCarpetCanvas.PictureReadStream(AGraphical:TGraphical;Stream: TStream);
         //procedure TPicture.ReadData(Stream: TStream);
var
  Pict : TPicture;
  Graph: TGraphic;
begin
  Pict := TPicture.Create;
  Pict.LoadFromStream(Stream);
  if AGraphical is TLCLGraphical then
     TLCLGraphical(AGraphical).Graphic := Pict.Graphic
  else
     AGraphical.Graphic := Pict.Graphic;
  //Pict.Graphic := nil;
  Pict.Free;
end;


end.

