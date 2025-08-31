unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, 
  dxBar, dxRibbon, dxRibbonForm, dxRibbonSkins, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxClasses, dxRibbonBackstageView, cxBarEditItem,
  dxSkinsCore, dxSkinBasic, dxSkinBlack, dxSkinBlue, dxSkinBlueprint,
  dxSkinCaramel, dxSkinCoffee, dxSkinDarkroom, dxSkinDarkSide,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy,
  dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinOffice2019Black, dxSkinOffice2019Colorful, dxSkinOffice2019DarkGray,
  dxSkinOffice2019White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic,
  dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringtime, dxSkinStardust,
  dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinTheBezier, dxSkinValentine,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint, dxSkinWXI,
  dxSkinXmas2008Blue, dxCore, dxRibbonCustomizationForm, cxTextEdit,
  cxContainer, cxEdit, dxSkinsForm, dxStatusBar, dxRibbonStatusBar, cxLabel,
  dxGallery, dxGalleryControl, dxRibbonBackstageViewGalleryControl, ULogin, Winapi.WinSvc, PluginInterface,
  Vcl.Menus, System.Actions, Vcl.ActnList, Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnMan;

type
  TFMain = class(TdxRibbonForm)
    dxBarManager1: TdxBarManager;
    dxBarManager1Bar1: TdxBar;
    dxRibbon1: TdxRibbon;
    Rbn1Tb1bienvenue: TdxRibbonTab;
    dxRibbonBackstageView1: TdxRibbonBackstageView;
    dxRibbonBackstageViewTabSheet1: TdxRibbonBackstageViewTabSheet;
    dxRibbonStatusBar1: TdxRibbonStatusBar;
    dxRibbonBackstageViewGalleryControl1: TdxRibbonBackstageViewGalleryControl;
    cxLabel1: TcxLabel;
    dxRibbonBackstageViewGalleryControl1Group1: TdxRibbonBackstageViewGalleryGroup;
    dxSkinController1: TdxSkinController;
    dxRibbonBackstageViewGalleryControl1Group1Item1: TdxRibbonBackstageViewGalleryItem;
    dxBarManager1Bar2: TdxBar;
    cxBarEditItem1: TcxBarEditItem;
    PopupMenu1: TPopupMenu;
    ChargerPlugin1: TMenuItem;
    Diagnostic2: TMenuItem;
    ActionManager1: TActionManager;
    ActionList1: TActionList;
    ActVerrouillage: TAction;
    dxBarLargeButton1: TdxBarLargeButton;
    procedure FormCreate(Sender: TObject);
    function ServiceRunning(const ServiceName: string): Boolean;
    procedure FormShow(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure Diagnostic2Click(Sender: TObject);
    procedure ChargerPlugin1Click(Sender: TObject);
    procedure ActVerrouillageExecute(Sender: TObject);
  private
    { Private declarations }
    FLoginFrame: TFrmLogin;
    FPluginHandle: THandle;
    FConnexionPlugin: IConnexionPlugin;
    function ChargerPlugin: Boolean;
    procedure DechargerPlugin;
  public
    destructor Destroy; override;
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

{$R *.dfm}

{ TForm1 }

Uses USrvLunch, UnitWizardDiagnostic;

destructor TFMain.Destroy;
begin
  DechargerPlugin;
  inherited;
end;

procedure TFMain.Diagnostic2Click(Sender: TObject);
begin
  if Assigned(FConnexionPlugin) then
    FConnexionPlugin.ShowWizard
  else
    ShowMessage('Plugin non chargé');
end;

procedure TFMain.ActVerrouillageExecute(Sender: TObject);
begin
  dxRibbon1.ActiveTab := Rbn1Tb1bienvenue;
  dxRibbon1.Enabled := False;
  dxRibbon1.Visible := False;
  try
    if Assigned(FLoginFrame) then
      FreeAndNil(FLoginFrame);

    // Créer et charger le frame dans le form
    FLoginFrame := TFrmLogin.Create(Self);   // <-- même nom que dans ULogin
    FLoginFrame.Parent := Self;
    FLoginFrame.Align := alClient;
    FLoginFrame.cxButtonEdit1.Properties.ShowPasswordRevealButton := true;
    FLoginFrame.cxButtonEdit1.Properties.PasswordChar := '*';
    FLoginFrame.cxLabelStatus.Caption := 'En attente...';
    except
      on E: Exception do
         ShowMessage('Erreur lors du chargement du frame : ' + E.Message);
  end;

end;

function TFMain.ChargerPlugin: Boolean;
var
  GetPluginProc: TConnexionPluginProc;
begin
  Result := False;

  // Charger la DLL
  FPluginHandle := LoadLibrary('ConnexionPlugin.dll');
  if FPluginHandle = 0 then
  begin
    ShowMessage('Impossible de charger le plugin');
    Exit;
  end;

  // Obtenir la fonction d'exportation
  @GetPluginProc := GetProcAddress(FPluginHandle, 'GetConnexionPlugin');
  if not Assigned(GetPluginProc) then
  begin
    ShowMessage('Fonction exportée non trouvée');
    FreeLibrary(FPluginHandle);
    FPluginHandle := 0;
    Exit;
  end;

  // Obtenir l'interface du plugin
  FConnexionPlugin := GetPluginProc();
  Result := Assigned(FConnexionPlugin);
end;

procedure TFMain.ChargerPlugin1Click(Sender: TObject);
begin
  if ChargerPlugin then
  begin
    ShowMessage('Plugin chargé: ' + FConnexionPlugin.GetName +
                ' v' + FConnexionPlugin.GetVersion);
    Diagnostic2.Enabled := True;
  end;
end;

procedure TFMain.DechargerPlugin;
begin
  if FPluginHandle <> 0 then
  begin
    FConnexionPlugin := nil;
    FreeLibrary(FPluginHandle);
    FPluginHandle := 0;
  end;
end;


procedure TFMain.FormCreate(Sender: TObject);
begin
  DisableAero := True;
  dxRibbon1.ActiveTab := Rbn1Tb1bienvenue;
  dxRibbon1.Enabled := False;
  dxRibbon1.Visible := False;
  if ServiceRunning('IBS_gds_db') then
  begin
  dxRibbonStatusBar1.Panels.Items[1].Text:= '✅ Service InterBase serveur démarré' ;
   try
    if Assigned(FLoginFrame) then
      FreeAndNil(FLoginFrame);

    // Créer et charger le frame dans le form
    FLoginFrame := TFrmLogin.Create(Self);   // <-- même nom que dans ULogin
    FLoginFrame.Parent := Self;
    FLoginFrame.Align := alClient;
    except
      on E: Exception do
         ShowMessage('Erreur lors du chargement du frame : ' + E.Message);
   end;
  end
else
  begin
  ShowMessage('❌ Service InterBase arrêté');
  dxRibbonStatusBar1.Panels.Items[1].Text:= '❌ Service InterBase arrêté' ;

  end;
  {
  FrmLogin.cxButtonEdit1.PasswordChar := '*';
  FrmLogin.cxLabelStatus.Caption := 'En attente...';
  TFrmLogin.InitFDConnection;
  }

end;

procedure TFMain.FormDblClick(Sender: TObject);
begin
  // Pour appeler le wizard depuis votre application principale :
  FormWizardDiagnostic := TFormWizardDiagnostic.Create(Application);
  try
    FormWizardDiagnostic.ShowModal;
  finally
    FormWizardDiagnostic.Free;
  end;
end;

procedure TFMain.FormShow(Sender: TObject);
begin
   if dxRibbonStatusBar1.Panels.Items[1].Text = '❌ Service InterBase arrêté' then
   FSrvLunch.ShowModal;
end;

function TFMain.ServiceRunning(const ServiceName: string): Boolean;
var
  SCM, Svc: SC_HANDLE;
  Status: TServiceStatus;
begin
  Result := False;
  SCM := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
  if SCM <> 0 then
  try
    Svc := OpenService(SCM, PChar(ServiceName), SERVICE_QUERY_STATUS);
    if Svc <> 0 then
    try
      if QueryServiceStatus(Svc, Status) then
        Result := (Status.dwCurrentState = SERVICE_RUNNING);
    finally
      CloseServiceHandle(Svc);
    end;
  finally
    CloseServiceHandle(SCM);
  end;
end;

end.
