unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Carpets, httpdefs, fpHTTP, fpWeb;

type

  { TFPWebModule1 }

  TFPWebModule1 = class(TFPWebModule)
    Carpet1: TCarpet;
    Carpet2: TCarpet;
    CarpetImage1: TCarpetImage;
  private

  public

  end;

var
  FPWebModule1: TFPWebModule1;

implementation

{$R *.lfm}

initialization
  RegisterHTTPModule('TFPWebModule1', TFPWebModule1);
end.

