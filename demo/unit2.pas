unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BufDataset, db, Carpets, Carpet_Images;

type

  { TDataRoom1 }

  TDataRoom1 = class(TDataModule)
    BufDataset1: TBufDataset;
    Carpet1: TCarpet;
    Carpet2: TCarpet;
    Carpet3: TCarpet;
    Carpet4: TCarpet;
    Carpet5: TCarpet;
    Carpet6: TCarpet;
    Carpet7: TCarpet;
    Carpet8: TCarpet;
    CarpetImage1: TCarpetImage;
    CarpetLabel1: TCarpetLabel;
    DataSource1: TDataSource;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  DataRoom1: TDataRoom1;

implementation

{$R *.lfm}

end.

