program GSH;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {FMain},
  ULogin in 'ULogin.pas' {FrmLogin: TFrame},
  UdmMain in 'UdmMain.pas' {dmMain: TDataModule},
  UServerLuncher in 'UServerLuncher.pas' {FrmServerLuncher: TFrame},
  USrvLunch in 'USrvLunch.pas' {FSrvLunch},
  PluginInterface in 'PluginInterface.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TFSrvLunch, FSrvLunch);
  Application.Run;
end.
