{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit CarpetsPack_Designer;

{$warn 5023 off : no warning about unused units}
interface

uses
  Carpet_Designer, CarpetPropEdits, Carpet_Canvas, GraphicalEditors, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('Carpet_Designer', @Carpet_Designer.Register);
end;

initialization
  RegisterPackage('CarpetsPack_Designer', @Register);
end.
