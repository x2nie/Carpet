{ Example designer for the Lazarus IDE

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

unit Carpet_Designer;

{$mode objfpc}{$H+}

interface

uses
  LCLProc, LCLType, Classes, SysUtils, FormEditingIntf, LCLIntf, Graphics,
  ProjectIntf, Carpets;

type

  { TCarpetMediator }

  TCarpetMediator = class(TDesignerMediator,ICarpetDesigner)
  private
    FDataModule: TDataModule;
  public
    // needed by the lazarus form editor
    class function CreateMediator(TheOwner, aForm: TComponent): TDesignerMediator;
      override;
    class function FormClass: TComponentClass; override;
    procedure GetBounds(AComponent: TComponent; out CurBounds: TRect); override;
    procedure SetBounds(AComponent: TComponent; NewBounds: TRect); override;
    procedure GetClientArea(AComponent: TComponent; out
            CurClientArea: TRect; out ScrollOffset: TPoint); override;
    procedure Paint; override;
    function ComponentIsIcon(AComponent: TComponent): boolean; override;
    function ParentAcceptsChild(Parent: TComponent;
                Child: TComponentClass): boolean; override;
    function ComponentAtPos(p: TPoint; MinClass: TComponentClass;
             Flags: TDMCompAtPosFlags): TComponent; override;

  public
    // needed by TCarpet
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InvalidateRect(Sender: TObject; ARect: TRect; Erase: boolean);
    property DataModule: TDataModule read FDataModule;
  public
    procedure GetObjInspNodeImageIndex(APersistent: TPersistent; var AIndex: integer); override;
  end;



procedure Register;

implementation
uses Math, GraphType, LResources,
  PropEdits,GraphPropEdits, CarpetPropEdits, Carpet_Canvas;

procedure Register;
begin
  FormEditingHook.RegisterDesignerMediator(TCarpetMediator);
  RegisterComponents('Standard',[TCarpet, TCarpetLabel]);
  {RegisterProjectFileDescriptor(TFileDescPascalUnitWithDataModule.Create,
                                FileDescGroupName);}

  RegisterPropertyEditor(TypeInfo(Cardinal), TCustomCarpet, 'Color', TCarpetColorPropertyEditor);
end;

type
  TLCLCarpetCanvasAccess = class(TLCLCarpetCanvas);
  TCustomCarpetAccess = class(TCustomCarpet);

{ Misc funcs }
function ImpGetBorderColor(const AColor: Cardinal): Cardinal;
//implementation
begin
  Result := GetShadowColor(AColor);
end;

{ TCarpetMediator }

constructor TCarpetMediator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TCarpetMediator.Destroy;
begin
  //if FDataModule<>nil then FDataModule.Designer:=nil;
  FDataModule:=nil;
  inherited Destroy;
end;

class function TCarpetMediator.CreateMediator(TheOwner, aForm: TComponent
  ): TDesignerMediator;
var
  Mediator: TCarpetMediator;
begin
  Result:=inherited CreateMediator(TheOwner,aForm);
  Mediator:=TCarpetMediator(Result);
  Mediator.FDataModule:=aForm as TDataModule;
  //Mediator.FDataModule.Designer:=Mediator;
end;

class function TCarpetMediator.FormClass: TComponentClass;
begin
  Result:=TDataModule;
end;

procedure TCarpetMediator.GetBounds(AComponent: TComponent; out
  CurBounds: TRect);
var
  w: TCustomCarpet;
begin
  if AComponent is TCustomCarpet then begin
    w:=TCustomCarpet(AComponent);
    CurBounds:=Bounds(w.Left,w.Top,w.Width,w.Height);
  end else
    inherited GetBounds(AComponent,CurBounds);
end;

procedure TCarpetMediator.InvalidateRect(Sender: TObject; ARect: TRect;
  Erase: boolean);
begin
  if (LCLForm=nil) or (not LCLForm.HandleAllocated) then exit;
  LCLIntf.InvalidateRect(LCLForm.Handle,@ARect,Erase);
end;

procedure TCarpetMediator.GetObjInspNodeImageIndex(APersistent: TPersistent;
  var AIndex: integer);
begin
  if Assigned(APersistent) then
  begin
    if (APersistent is TCustomCarpet) and (TCustomCarpet(APersistent).AcceptChildrenAtDesignTime) then
      AIndex := FormEditingHook.GetCurrentObjectInspector.ComponentTree.ImgIndexBox
    else
    if (APersistent is TCustomCarpet) then
      AIndex := FormEditingHook.GetCurrentObjectInspector.ComponentTree.ImgIndexControl
    else
      inherited;
  end
end;

procedure TCarpetMediator.SetBounds(AComponent: TComponent; NewBounds: TRect);
begin
  if AComponent is TCustomCarpet then begin
    TCustomCarpet(AComponent).SetBounds(NewBounds.Left,NewBounds.Top,
      NewBounds.Right-NewBounds.Left,NewBounds.Bottom-NewBounds.Top);
  end else
    inherited SetBounds(AComponent,NewBounds);
end;

procedure TCarpetMediator.GetClientArea(AComponent: TComponent; out
  CurClientArea: TRect; out ScrollOffset: TPoint);
var
  Widget: TCustomCarpet;
begin
  if AComponent is TCustomCarpet then begin
    Widget:=TCustomCarpet(AComponent);
    CurClientArea:=Rect(Widget.BorderLeft,Widget.BorderTop,
                        Widget.Width-Widget.BorderRight,
                        Widget.Height-Widget.BorderBottom);
    ScrollOffset:=Point(0,0);
  end else
    inherited GetClientArea(AComponent, CurClientArea, ScrollOffset);
end;

procedure TCarpetMediator.Paint;

  procedure PaintWidget(AWidget: TCustomCarpet);
  var
    i: Integer;
    r : TRect;
    Child: TCustomCarpet;
  begin
    if AWidget.Canvas is TLCLCarpetCanvas then
       TLCLCarpetCanvasAccess(AWidget.Canvas).LCLCanvas := LCLForm.Canvas ;

    with LCLForm.Canvas do
    begin

      SaveHandleState;
      MoveWindowOrgEx(Handle,AWidget.Left,AWidget.Top);
      TCustomCarpetAccess(AWidget).Paint;

      // children
      if AWidget.ChildCount>0 then begin
        SaveHandleState;
        // clip client area
        MoveWindowOrgEx(Handle,AWidget.BorderLeft,AWidget.BorderTop);
        if IntersectClipRect(Handle, 0, 0, AWidget.Width-AWidget.BorderLeft-AWidget.BorderRight,
                             AWidget.Height-AWidget.BorderTop-AWidget.BorderBottom)<>NullRegion
        then begin
          for i:=0 to AWidget.ChildCount-1 do begin
            Child:=AWidget.Children[i];
            if csDestroying in Child.ComponentState then
               continue;
            //SaveHandleState;
            // clip child area
            //MoveWindowOrgEx(Handle,Child.Left,Child.Top);
            if IntersectClipRect(Handle,0,0,Child.Width,Child.Height)<>NullRegion then
              PaintWidget(Child);
            //RestoreHandleState;
          end;
        end;
        RestoreHandleState;
      end;


      RestoreHandleState;
    end;
  end;

var i : integer;
begin
  if not (csDestroying in DataModule.ComponentState) then
  begin
    for i := 0 to DataModule.ComponentCount -1 do
    begin
      if (DataModule.Components[i] is TCustomCarpet)
      and (not TCustomCarpet(DataModule.Components[i]).HasParent) then
      begin
        PaintWidget(TCustomCarpet(DataModule.Components[i]));
      end;
    end;
  end;
  inherited Paint;
end;

function TCarpetMediator.ComponentIsIcon(AComponent: TComponent): boolean;
begin
  Result:=not (AComponent is TCustomCarpet);
end;

function TCarpetMediator.ParentAcceptsChild(Parent: TComponent;
  Child: TComponentClass): boolean;
begin
  Result:=(Parent is TCustomCarpet) and ((Child = nil) or Child.InheritsFrom(TCustomCarpet))
    and (TCustomCarpet(Parent).AcceptChildrenAtDesignTime);
end;

function TCarpetMediator.ComponentAtPos(p: TPoint; MinClass: TComponentClass;
  Flags: TDMCompAtPosFlags): TComponent;

var i : integer;
  c : TCustomCarpet;
begin
  for i := 0 to DataModule.ComponentCount -1 do
  begin
    if (DataModule.Components[i] is TCustomCarpet) then
    begin
      c := TCustomCarpet(DataModule.Components[i]);
      if (not c.HasParent) and (PtInRect(c.GetBounds, p)) then
         //PaintWidget(TCustomCarpet(DataModule.Components[i]));
         //TODO: iterate children
         exit(c);
    end;
  end;

  result := inherited ComponentAtPos(p, MinClass, Flags);
end;


initialization
  Carpets.DefaultCanvasClass := Carpet_Canvas.TLCLCarpetCanvas;
  Carpets.GetBorderColor := @ImpGetBorderColor;
{$I carpets.lrs}
end.

