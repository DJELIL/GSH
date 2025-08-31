unit ULogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinBasic, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkroom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMetropolis, dxSkinMetropolisDark, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinOffice2019Black, dxSkinOffice2019Colorful,
  dxSkinOffice2019DarkGray, dxSkinOffice2019White, dxSkinPumpkin, dxSkinSeven,
  dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver,
  dxSkinSpringtime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld,
  dxSkinTheBezier, dxSkinValentine, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinWXI, dxSkinXmas2008Blue, cxLabel, dxCoreGraphics,
  cxButtonEdit, cxTextEdit, cxMaskEdit, cxDropDownEdit, Vcl.Menus, Vcl.StdCtrls,
  cxButtons, System.Threading
  { // 🔑 FireDAC de base
  ,FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.Stan.Def, FireDAC.UI.Intf, FireDAC.VCLUI.Wait,
  FireDAC.Phys.IBDef, FireDAC.Phys, FireDAC.Phys.IBBase, FireDAC.Phys.IB
  }
  ;

type
  TFrmLogin = class(TFrame)
    cxLabelStatus: TcxLabel;
    cxComboBox1: TcxComboBox;
    cxButtonEdit1: TcxButtonEdit;
    cxButton1: TcxButton;
    cxButton2: TcxButton;
    procedure cxButton1Click(Sender: TObject);

  private
    { Déclarations privées }
    //FDConnection1: TFDConnection; // créé dynamiquement
    procedure UpdateStatus(const Msg: string);
    procedure InitFDConnection;
  public
    { Déclarations publiques }

  end;

implementation

{$R *.dfm}

Uses UMain, UdmMain;

procedure TFrmLogin.InitFDConnection;
begin
  //dmMain.FDConnection1 := TFDConnection.Create(Self);
  dmMain.FDConnection1.LoginPrompt := False;
end;

procedure TFrmLogin.cxButton1Click(Sender: TObject);
begin
  if (cxComboBox1.Text = '' ) then
  MessageBox(Application.Handle,'Entrez votre nom dutilisateur et votre mot de passe pour passe à vos services','Confirmation',MB_OK)
  else
  begin
  cxLabelStatus.Caption := 'Connexion en cours...';
  InitFDConnection;

  TTask.Run(
    procedure
    begin
      try
        dmMain.FDConnection1.Connected := False;
        dmMain.FDConnection1.Params.Clear;

        // Exemple pour InterBase
        dmMain.FDConnection1.Params.DriverID := 'IB';
        dmMain.FDConnection1.Params.Database := 'C:\HUSBANDRY\GSL.GDB';
        dmMain.FDConnection1.Params.UserName := cxComboBox1.Text;
        dmMain.FDConnection1.Params.Password := cxButtonEdit1.Text;

        dmMain.FDConnection1.Connected := True;

        TThread.Synchronize(nil,
          procedure
          begin
            UpdateStatus('✅ Connexion réussie');
            FMain.dxRibbon1.Enabled := True;
            FMain.dxRibbon1.Visible := True;
            // 🔥 Fermer le Frame de login
            Self.Free;
          end);
      except
        on E: Exception do
          TThread.Synchronize(nil,
            procedure
            begin
              UpdateStatus('❌ Erreur : ' + E.Message);
            end);
      end;
    end);
  end;
end;

procedure TFrmLogin.UpdateStatus(const Msg: string);
begin
  cxLabelStatus.Caption := Msg;
end;



end.
