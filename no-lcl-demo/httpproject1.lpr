program httpproject1;

{$mode objfpc}{$H+}

uses
  fphttpapp, Unit1, carpetspack;

begin
  Application.Title:='httpproject1';
  Application.Port:=8080;
  Application.Initialize;
  Application.Run;
end.

