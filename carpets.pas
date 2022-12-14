{ Example widgetset.
  It does not have any useful implementation, it only provides the classes
  and published properties to define a child-parent relationship and some
  coordinates. The Lazarus designer will do the rest:
  Opening, closing, editing forms of this example widgetset.
  At designtime the TMyWidgetMediator will paint.


  Copyright (C) 2009 Mattias Gaertner mattias@freepascal.org

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version with the following modification:

  As a special exception, the copyright holders of this library give you
  permission to link this library with independent modules to produce an
  executable, regardless of the license terms of these independent modules,and
  to copy and distribute the resulting executable under terms of your choice,
  provided that you also meet, for each linked independent module, the terms
  and conditions of the license of that module. An independent module is a
  module which is not derived from or based on this library. If you modify
  this library, you may extend this exception to your version of the library,
  but you are not obligated to do so. If you do not wish to do so, delete this
  exception statement from your version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}
unit Carpets;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, types;

type
  ICarpetDesigner = interface(IUnknown)
    procedure InvalidateRect(Sender: TObject; ARect: TRect; Erase: boolean);
  end;

  { forward }
  TCarpetCanvas = class;

const
  clTransparentCarpet = $1FFFFFFF; //identic with clNone

type
  { TCustomCarpet }

  TCustomCarpet = class(TComponent)
  private
    FAlignment: TAlignment;
    FBorderBottom: integer;
    FBorderLeft: integer;
    FBorderRight: integer;
    FBorderTop: integer;
    FCanvas: TCarpetCanvas;
    FCaption: string;
    FChilds: TFPList; // list of TCarpet
    FDesigner: ICarpetDesigner;
    FHeight: integer;
    FLeft: integer;
    FParent: TCustomCarpet;
    FTop: integer;
    FWidth: integer;
    function GetChilds(Index: integer): TCustomCarpet;
    procedure SetAlignment(AValue: TAlignment);
    procedure SetBorderBottom(const AValue: integer);
    procedure SetBorderLeft(const AValue: integer);
    procedure SetBorderRight(const AValue: integer);
    procedure SetBorderTop(const AValue: integer);
    procedure SetCaption(const AValue: string);
    procedure SetColor(AValue: Cardinal);
    procedure SetHeight(const AValue: integer);
    procedure SetLeft(const AValue: integer);
    procedure SetParent(const AValue: TCustomCarpet);
    procedure SetTop(const AValue: integer);
    procedure SetWidth(const AValue: integer);
  protected
    FAcceptChildrenAtDesignTime: boolean;
    FColor: Cardinal;
    procedure InternalInvalidateRect({%H-}ARect: TRect; {%H-}Erase: boolean); virtual;
    procedure SetName(const NewName: TComponentName); override;
    procedure SetParentComponent(Value: TComponent); override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure RemoveCarpet(AChild: TCustomCarpet);
    procedure Paint; virtual;
    property Caption: string read FCaption write SetCaption;
    property Alignment : TAlignment read FAlignment write SetAlignment;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Parent: TCustomCarpet read FParent write SetParent;
    function ChildCount: integer;
    property Children[Index: integer]: TCustomCarpet read GetChilds;
    function HasParent: Boolean; override;
    function GetParentComponent: TComponent; override;
    procedure SetBounds(NewLeft, NewTop, NewWidth, NewHeight: integer); virtual;
    function GetBounds: TRect; virtual;
    procedure InvalidateRect(ARect: TRect; Erase: boolean);
    procedure Invalidate;
    procedure Click(p:TPoint; var Handled : Boolean); virtual;
    property Designer: ICarpetDesigner read FDesigner write FDesigner;
    property AcceptChildrenAtDesignTime: boolean read FAcceptChildrenAtDesignTime;
    property Canvas : TCarpetCanvas read FCanvas write FCanvas;
    property BorderLeft: integer read FBorderLeft write SetBorderLeft;
    property BorderRight: integer read FBorderRight write SetBorderRight;
    property BorderTop: integer read FBorderTop write SetBorderTop;
    property BorderBottom: integer read FBorderBottom write SetBorderBottom;
  published
    property Left: integer read FLeft write SetLeft;
    property Top: integer read FTop write SetTop;
    property Width: integer read FWidth write SetWidth;
    property Height: integer read FHeight write SetHeight;
    property Color : Cardinal read FColor write SetColor;
  end;
  TCarpetClass = class of TCustomCarpet;


  { TMyGroupBox
    A widget that does allow children at design time }

  { TCarpet }

  TCarpet = class(TCustomCarpet)
  private
    FMoveChildren: Boolean;
    procedure SetMoveChildren(AValue: Boolean);
  protected
    procedure Paint; override;
    function IfNotMoveChildren: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Click(p:TPoint; var Handled : Boolean); override;
  published
    property Caption;
    property BorderLeft default 5;
    property BorderRight default 5;
    property BorderTop default 20;
    property BorderBottom default 5;
    property MoveChildren: Boolean read FMoveChildren write SetMoveChildren stored IfNotMoveChildren;
  end;


  { TCarpetLabel
    A widget that does not allow children at design time }

  TCarpetLabel = class(TCustomCarpet)
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Caption;
    property Color default clTransparentCarpet;
    property Alignment;
  end;


  { TGraphical }

  TGraphical = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    procedure ReadData(Stream: TStream);
    procedure WriteData(Stream: TStream);
  protected
    FCarpet :TCustomCarpet;
    FGraphic: TObject;
    procedure DefineProperties(Filer: TFiler); override;
    procedure Changed;
  public
    constructor Create(ACarpet:TCustomCarpet);
    function Width: integer; virtual;
    function Height: integer; virtual;
    property Graphic : TObject read FGraphic write FGraphic;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;
  TGraphicalClass = class of TGraphical;

  { TCarpetImage }
  TCarpetImage = class(TCustomCarpet)
  private
    FAutoSize: Boolean;
    FPicture: TGraphical;
    FStretch: Boolean;
    procedure SetAutoSize(AValue: Boolean);
    procedure SetPicture(AValue: TGraphical);
    procedure SetStretch(AValue: Boolean);
  protected
    procedure Paint; override;
    procedure PictureChanged(Sender:TObject);
    procedure CalcAutoSize;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property AutoSize: Boolean read FAutoSize write SetAutoSize default False;
    property Stretch: Boolean read FStretch write SetStretch default False;
    property Picture: TGraphical read FPicture write SetPicture;
  end;

  { TCarpetCanvas }

  TCarpetCanvas = class(TPersistent)
  public
    procedure FillRect(const X1,Y1,X2,Y2: Integer; const AColor: Cardinal); virtual;
    procedure Frame3D(var ARect: TRect; TopColor, BottomColor: Cardinal;
                      const FrameWidth: integer); virtual;
    procedure Rectangle(X1,Y1,X2,Y2: Integer; AColor: Cardinal); virtual;
    procedure StretchDraw(DestRect: TRect; SrcGraphic: TObject; Stretched:Boolean); virtual;
    procedure TextOut(X,Y: Integer; const Text: String; AColor: Cardinal = $20000000); virtual;
    procedure TextRect(ARect: TRect; const Text: string; Alignment: TAlignment); virtual;
    procedure PictureWriteStream(AGraphical:TGraphical; Stream:TStream); virtual;
    procedure  PictureReadStream(AGraphical:TGraphical; Stream:TStream); virtual;
  end;
  TCarpetCanvasClass = class of TCarpetCanvas;



  { assumed funcs & var below is taken from external lib }
type
  TGetBorderColorProc = function(const AColor: Cardinal): Cardinal;
  TShiftColorProc = function(BaseColor: Cardinal; Value: byte): Cardinal;


var
  DefaultCanvasClass : TCarpetCanvasClass;
  RealTPictureClass: TPersistentClass = nil;
  TDefaultGraphicalClass : TGraphicalClass = TGraphical;
  GetBorderColor : TGetBorderColorProc;
  DarkenColor : TShiftColorProc;
  LightenColor : TShiftColorProc;

implementation

{ Misc funcs }

function GetBorderColorDummyProc(const AColor: Cardinal): Cardinal;
// it should be replaced by designtime func
begin
  result := AColor;
end;

{ TCarpetImage }

procedure TCarpetImage.SetPicture(AValue: TGraphical);
begin
  if FPicture=AValue then Exit;
  FPicture.Assign(AValue);
  invalidate;
end;

procedure TCarpetImage.SetAutoSize(AValue: Boolean);
begin
  if FAutoSize=AValue then Exit;
  FAutoSize:=AValue;
  CalcAutoSize;
end;

procedure TCarpetImage.SetStretch(AValue: Boolean);
begin
  if FStretch=AValue then Exit;
  FStretch:=AValue;
  invalidate;
end;

procedure TCarpetImage.Paint;
var R : TRect;
begin
  inherited Paint;
  if Picture.Graphic = nil then
     Exit;

  R := Rect(BorderLeft, BorderTop, Width-BorderRight, Height-BorderBottom);
  Canvas.StretchDraw(R, Picture.Graphic, Stretch);
end;

procedure TCarpetImage.PictureChanged(Sender: TObject);
begin
  invalidate;
end;

procedure TCarpetImage.CalcAutoSize;
begin
  if FAutoSize and (Picture.Graphic <> nil) then
  with Picture do
  begin
    if (Width <> self.Width) and (Height <> self.Height) then
       SetBounds(left, top, Width, Height);
  end;
  invalidate;
end;

constructor TCarpetImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColor := clTransparentCarpet;
  FPicture:= TDefaultGraphicalClass.Create(self);
  FPicture.OnChange:= @PictureChanged;
end;

{ TGraphical }

procedure TGraphical.ReadData(Stream: TStream);
begin
  FCarpet.Canvas.PictureReadStream(self, Stream);
end;

procedure TGraphical.WriteData(Stream: TStream);
begin
  FCarpet.Canvas.PictureWriteStream(self, Stream);
end;

procedure TGraphical.DefineProperties(Filer: TFiler);
  function DoWrite: Boolean;
  begin
    result := assigned(FGraphic);
  end;

begin
  Filer.DefineBinaryProperty('Data', @ReadData, @WriteData, DoWrite);
end;

procedure TGraphical.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

constructor TGraphical.Create(ACarpet:TCustomCarpet);
begin
  inherited Create;
  FCarpet := ACarpet;
  //if assigned(RealTPictureClass) then
    //FPicture := RealTPictureClass.Create;
end;

function TGraphical.Width: integer;
begin
  result := FCarpet.Width;
end;

function TGraphical.Height: integer;
begin
  result := FCarpet.Height;
end;

{ TCarpetCanvas }

procedure TCarpetCanvas.FillRect(const X1, Y1, X2, Y2: Integer;
  const AColor: Cardinal);
begin

end;

procedure TCarpetCanvas.Frame3D(var ARect: TRect; TopColor,
  BottomColor: Cardinal; const FrameWidth: integer);
begin

end;

procedure TCarpetCanvas.Rectangle(X1, Y1, X2, Y2: Integer; AColor: Cardinal);
begin

end;

procedure TCarpetCanvas.StretchDraw(DestRect: TRect; SrcGraphic: TObject; Stretched:Boolean);
begin

end;

procedure TCarpetCanvas.TextOut(X, Y: Integer; const Text: String; AColor: Cardinal );
begin

end;

procedure TCarpetCanvas.TextRect(ARect: TRect; const Text: string; Alignment: TAlignment);
begin

end;

procedure TCarpetCanvas.PictureWriteStream(AGraphical:TGraphical; Stream: TStream);
begin

end;

procedure TCarpetCanvas.PictureReadStream(AGraphical:TGraphical;Stream: TStream);
begin

end;


{ TCarpet }

procedure TCarpet.SetMoveChildren(AValue: Boolean);
begin
  if FMoveChildren=AValue then Exit;
  FMoveChildren:=AValue;
  invalidate;
end;

procedure TCarpet.Paint;
begin
  inherited Paint;
  with Canvas do begin
    Rectangle(0,0,Width,Height, GetBorderColor(Color));
    // inner frame
    Rectangle(BorderLeft-1,BorderTop-1,
                Width-BorderRight+1,
                Height-BorderBottom+1, GetBorderColor(Color));

    // caption
    //Font.Style:=[fsBold];
    TextOut(5,2,Caption);

    //icons
    if FMoveChildren then
      TextOut(width - 24, 2, utf8encode(#$1F03C)) //domino 1:5
    else
    begin
      TextOut(width - 24 +1, 2+1, utf8encode(#$1F03C), LightenColor(self.Color, 64) ); //domino 1:5
      TextOut(width - 24, 2, utf8encode(#$1F03C), DarkenColor(self.Color, 48) ); //domino 1:5
    end;

  end;
end;

function TCarpet.IfNotMoveChildren: Boolean;
begin
  result := not FMoveChildren;
end;

constructor TCarpet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBorderLeft:=5;
  FBorderRight:=5;
  FBorderBottom:=5;
  FBorderTop:=20;
  FMoveChildren:=True;
end;

procedure TCarpet.Click(p: TPoint; var Handled: Boolean);
var r : TRect;
begin
  r := Bounds(width - 24, 0, 24, 20);
  if ptInRect(r, p) then
  begin
    handled := true;
    MoveChildren := not MoveChildren;
  end;
end;

{ TCarpet }

function TCustomCarpet.GetChilds(Index: integer): TCustomCarpet;
begin
  Result:=TCustomCarpet(FChilds[Index]);
end;

procedure TCustomCarpet.SetAlignment(AValue: TAlignment);
begin
  if FAlignment=AValue then Exit;
  FAlignment:=AValue;
  Invalidate;
end;

procedure TCustomCarpet.SetBorderBottom(const AValue: integer);
begin
  if FBorderBottom=AValue then exit;
  FBorderBottom:=AValue;
  Invalidate;
end;

procedure TCustomCarpet.SetBorderLeft(const AValue: integer);
begin
  if FBorderLeft=AValue then exit;
  FBorderLeft:=AValue;
  Invalidate;
end;

procedure TCustomCarpet.SetBorderRight(const AValue: integer);
begin
  if FBorderRight=AValue then exit;
  FBorderRight:=AValue;
  Invalidate;
end;

procedure TCustomCarpet.SetBorderTop(const AValue: integer);
begin
  if FBorderTop=AValue then exit;
  FBorderTop:=AValue;
  Invalidate;
end;

procedure TCustomCarpet.SetCaption(const AValue: string);
begin
  if FCaption=AValue then exit;
  FCaption:=AValue;
  Invalidate;
end;

procedure TCustomCarpet.SetColor(AValue: Cardinal);
begin
  if FColor=AValue then Exit;
  FColor:=AValue;
  Invalidate;
end;

procedure TCustomCarpet.SetHeight(const AValue: integer);
begin
  SetBounds(Left,Top,Width,AValue);
end;

procedure TCustomCarpet.SetLeft(const AValue: integer);
begin
  SetBounds(AValue,Top,Width,Height);
end;

procedure TCustomCarpet.SetParent(const AValue: TCustomCarpet);
begin
  if FParent=AValue then exit;
  if FParent<>nil then begin
    //Invalidate;
    FParent.RemoveCarpet(Self);
  end;
  if (AValue is TCustomCarpet) or (AValue = nil) then //allowed to use outside dataroom (such form, datamodule)
    FParent:=AValue;
  if FParent<>nil then begin
    FParent.FChilds.Add(Self);
  end;
  Invalidate;
end;

procedure TCustomCarpet.SetTop(const AValue: integer);
begin
  SetBounds(Left,AValue,Width,Height);
end;

procedure TCustomCarpet.SetWidth(const AValue: integer);
begin
  SetBounds(Left,Top,AValue,Height);
end;

procedure TCustomCarpet.InternalInvalidateRect(ARect: TRect; Erase: boolean);
begin
  if {(Parent=nil) and} (Designer<>nil) then
    Designer.InvalidateRect(Self,ARect,Erase);
end;

procedure TCustomCarpet.SetName(const NewName: TComponentName);
begin
  if Name=Caption then Caption:=NewName;
  inherited SetName(NewName);
end;

procedure TCustomCarpet.SetParentComponent(Value: TComponent);
begin
  if (Value is TCustomCarpet) or (Value = nil) then
    Parent:=TCustomCarpet(Value);
end;

function TCustomCarpet.HasParent: Boolean;
begin
  Result:=Parent<>nil;
end;

function TCustomCarpet.GetParentComponent: TComponent;
begin
  Result:=Parent;
  //NEEDED FOR GET ORIGIN_ON_FORM. Because our root is TDataModule
  if parent = nil then
    result := self.Owner;
end;

procedure TCustomCarpet.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  i: Integer;
begin
  for i:=0 to ChildCount-1 do
    if Children[i].Owner=Root then
      Proc(Children[i]);

  if Root = self then
    for i:=0 to ComponentCount-1 do
      if Components[i].GetParentComponent = nil then
        Proc(Components[i]);
end;

constructor TCustomCarpet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FChilds:=TFPList.Create;
  FColor := $00BAFECB;
  FWidth :=136;
  FHeight := 112;
  FAcceptChildrenAtDesignTime:=true;
  if DefaultCanvasClass <> nil then
    FCanvas := DefaultCanvasClass.Create;
end;

destructor TCustomCarpet.Destroy;
var i : integer;
begin
  Parent:=nil;
  for i := ChildCount-1 downto 0 do
    Children[i].Free;
  FreeAndNil(FChilds);
  if assigned(FCanvas) then
     FCanvas.Free;
  inherited Destroy;
end;

function TCustomCarpet.ChildCount: integer;
begin
  Result:=FChilds.Count;
end;

procedure TCustomCarpet.RemoveCarpet(AChild: TCustomCarpet);
begin
  if FChilds.IndexOf(AChild) >= 0 then
  begin
    FChilds.Remove(AChild);
    AChild.Parent := nil;
  end;
end;

procedure TCustomCarpet.Paint;
begin
  if Color <> clTransparentCarpet then
    FCanvas.FillRect(0,0,Width,Height, self.Color);
end;

procedure TCustomCarpet.SetBounds(NewLeft, NewTop, NewWidth, NewHeight: integer);
begin
  if (Left=NewLeft) and (Top=NewTop) and (Width=NewWidth) and (Height=NewHeight) then
    exit;
  Invalidate;
  FLeft:=NewLeft;
  FTop:=NewTop;
  FWidth:=NewWidth;
  FHeight:=NewHeight;
  Invalidate;
end;

function TCustomCarpet.GetBounds: TRect;
begin
  result := Bounds(left,top,Width, Height);
end;

procedure TCustomCarpet.InvalidateRect(ARect: TRect; Erase: boolean);
begin
  ARect.Left:=Max(0,ARect.Left);
  ARect.Top:=Max(0,ARect.Top);
  ARect.Right:=Min(Width,ARect.Right);
  ARect.Bottom:=Max(Height,ARect.Bottom);
  if Parent<>nil then begin
    OffsetRect(ARect,Left+Parent.BorderLeft,Top+Parent.BorderTop);
    Parent.InvalidateRect(ARect,Erase);
  end else begin
    OffsetRect(ARect,Left,Top);
    InternalInvalidateRect(ARect,Erase);
  end;
end;

procedure TCustomCarpet.Invalidate;
begin
  if not (csDestroying in ComponentState) then
    InvalidateRect(Rect(0,0,Width,Height),false);
end;

procedure TCustomCarpet.Click(p: TPoint; var Handled: Boolean);
begin

end;


{ TCarpetLabel }

procedure TCarpetLabel.Paint;
begin
  inherited Paint;
  Canvas.TextRect(Rect(BorderLeft, BorderTop, Width-BorderRight, Height-BorderBottom), Caption, self.Alignment);
end;

constructor TCarpetLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColor := clTransparentCarpet;
  FAcceptChildrenAtDesignTime:=false;
end;


initialization
  DefaultCanvasClass := TCarpetCanvas; //it will replaced by real implemented method
  GetBorderColor := @GetBorderColorDummyProc;

end.

