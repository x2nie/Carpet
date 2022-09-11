unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BufDataset, db, Carpets, Carpet_Images;

type

  { TDataModule2 }

  TDataModule2 = class(TDataModule)
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
  DataModule2: TDataModule2;

implementation

{$R *.lfm}

end.

