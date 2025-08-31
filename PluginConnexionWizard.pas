unit PluginConnexionWizard;

interface

uses
  System.SysUtils, System.Classes, Vcl.Forms, Vcl.Controls, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.ExtCtrls, Winapi.Winsock, Winapi.Windows;

type
  TPluginConnexionWizard = class(TForm)
    PageControl: TPageControl;
    tsTypeConnexion: TTabSheet;
    tsParametres: TTabSheet;
    tsResultats: TTabSheet;
    rgTypeConnexion: TRadioGroup;
    Label1: TLabel;
    PanelBoutons: TPanel;
    btnPrecedent: TButton;
    btnSuivant: TButton;
    btnAnnuler: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    edtServeur: TEdit;
    edtPort: TEdit;
    GroupBox1: TGroupBox;
    cbPing: TCheckBox;
    cbPort: TCheckBox;
    cbTimeout: TCheckBox;
    edtTimeout: TEdit;
    Label5: TLabel;
    MemoResultats: TMemo;
    btnTester: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnSuivantClick(Sender: TObject);
    procedure btnPrecedentClick(Sender: TObject);
    procedure btnAnnulerClick(Sender: TObject);
    procedure rgTypeConnexionClick(Sender: TObject);
    procedure btnTesterClick(Sender: TObject);
  private
    { Déclarations privées }
    function PortOpen(const Host: string; Port: Word; Timeout: Integer): Boolean;
    function PingHost(const Host: string): Boolean;
    procedure TesterConnexion;
    procedure AfficherResultat(const Message: string; Succes: Boolean = False);
  public
    { Déclarations publiques }
    class function Execute: Boolean;
  end;

// Interface du plugin
type
  IConnexionPlugin = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function GetName: string;
    function GetVersion: string;
    function ShowWizard: Boolean;
  end;

// Implémentation du plugin
  TConnexionPlugin = class(TInterfacedObject, IConnexionPlugin)
  private
    function GetName: string;
    function GetVersion: string;
    function ShowWizard: Boolean;
  public
    class function New: IConnexionPlugin;
  end;

// Fonction d'exportation du plugin
function GetConnexionPlugin: IConnexionPlugin; stdcall;

implementation

{$R *.dfm}

uses
  Vcl.Dialogs;

// Définition manuelle de MAKEWORD si nécessaire
function MakeWord(Low, High: Byte): Word;
begin
  Result := (High shl 8) or Low;
end;

{ TPluginConnexionWizard }

class function TPluginConnexionWizard.Execute: Boolean;
begin
  with TPluginConnexionWizard.Create(nil) do
  try
    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

procedure TPluginConnexionWizard.FormCreate(Sender: TObject);
begin
  PageControl.ActivePage := tsTypeConnexion;
  btnPrecedent.Enabled := False;
  btnTester.Visible := False;
  Caption := 'Diagnostic de Connexion - Plugin';

  // Valeurs par défaut
  edtServeur.Text := 'localhost';
  edtPort.Text := '3050';
  edtTimeout.Text := '3000';
end;

procedure TPluginConnexionWizard.btnSuivantClick(Sender: TObject);
begin
  case PageControl.ActivePageIndex of
    0:
    begin
      PageControl.ActivePage := tsParametres;
      btnPrecedent.Enabled := True;
      btnTester.Visible := True;
      btnSuivant.Caption := 'Terminer';
    end;
    1:
    begin
      PageControl.ActivePage := tsResultats;
      btnSuivant.Enabled := False;
      btnTester.Visible := False;
      TesterConnexion;
    end;
  end;
end;

procedure TPluginConnexionWizard.btnPrecedentClick(Sender: TObject);
begin
  case PageControl.ActivePageIndex of
    1:
    begin
      PageControl.ActivePage := tsTypeConnexion;
      btnPrecedent.Enabled := False;
      btnTester.Visible := False;
      btnSuivant.Caption := 'Suivant';
    end;
    2:
    begin
      PageControl.ActivePage := tsParametres;
      btnSuivant.Enabled := True;
      btnSuivant.Caption := 'Terminer';
      btnTester.Visible := True;
    end;
  end;
end;

procedure TPluginConnexionWizard.btnAnnulerClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TPluginConnexionWizard.rgTypeConnexionClick(Sender: TObject);
begin
  case rgTypeConnexion.ItemIndex of
    0: edtPort.Text := '3050';  // InterBase
    1: edtPort.Text := '5432';  // PostgreSQL
    2: edtPort.Text := '3306';  // MySQL
    3: edtPort.Text := '80';    // HTTP
    4: edtPort.Text := '443';   // HTTPS
    // 5: Personnalisé - l'utilisateur saisit le port
  end;
end;

procedure TPluginConnexionWizard.btnTesterClick(Sender: TObject);
begin
  TesterConnexion;
end;

function TPluginConnexionWizard.PortOpen(const Host: string; Port: Word; Timeout: Integer): Boolean;
var
  Client: TSocket;
  Addr: TSockAddrIn;
  WSAData: TWSAData;
  HostEnt: PHostEnt;
begin
  Result := False;

  if WSAStartup(MakeWord(2, 2), WSAData) <> 0 then
    Exit;

  Client := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if Client = INVALID_SOCKET then
  begin
    WSACleanup;
    Exit;
  end;

  try
    setsockopt(Client, SOL_SOCKET, SO_RCVTIMEO, @Timeout, SizeOf(Timeout));
    setsockopt(Client, SOL_SOCKET, SO_SNDTIMEO, @Timeout, SizeOf(Timeout));

    FillChar(Addr, SizeOf(Addr), 0);
    Addr.sin_family := AF_INET;
    Addr.sin_port := htons(Port);

    // Résolution de l'adresse IP
    Addr.sin_addr.S_addr := inet_addr(PAnsiChar(AnsiString(Host)));
    if Addr.sin_addr.S_addr = INADDR_NONE then
    begin
      HostEnt := gethostbyname(PAnsiChar(AnsiString(Host)));
      if (HostEnt = nil) or (HostEnt.h_addr_list = nil) then
        Exit;
      Addr.sin_addr.S_addr := PInAddr(HostEnt.h_addr_list^).S_addr;
    end;

    Result := connect(Client, Addr, SizeOf(Addr)) = 0;

  finally
    closesocket(Client);
    WSACleanup;
  end;
end;

function TPluginConnexionWizard.PingHost(const Host: string): Boolean;
var
  WSAData: TWSAData;
  HostEnt: PHostEnt;
begin
  Result := False;

  if WSAStartup(MakeWord(2, 2), WSAData) <> 0 then
    Exit;

  try
    HostEnt := gethostbyname(PAnsiChar(AnsiString(Host)));
    Result := (HostEnt <> nil) and (HostEnt.h_addr_list <> nil);
  finally
    WSACleanup;
  end;
end;

procedure TPluginConnexionWizard.TesterConnexion;
var
  Serveur: string;
  Port: Integer;
  Timeout: Integer;
  PortOuvert, PingReussi: Boolean;
begin
  MemoResultats.Lines.Clear;

  Serveur := edtServeur.Text;
  if Serveur = '' then
  begin
    ShowMessage('Veuillez saisir une adresse serveur');
    Exit;
  end;

  if not TryStrToInt(edtPort.Text, Port) or (Port <= 0) or (Port > 65535) then
  begin
    ShowMessage('Port invalide. Doit être entre 1 et 65535');
    Exit;
  end;

  if not TryStrToInt(edtTimeout.Text, Timeout) or (Timeout <= 0) then
    Timeout := 3000;

  AfficherResultat('Début du diagnostic de connexion...');
  AfficherResultat('Serveur: ' + Serveur);
  AfficherResultat('Port: ' + IntToStr(Port));
  AfficherResultat('Timeout: ' + IntToStr(Timeout) + ' ms');
  AfficherResultat('');

  // Test Ping
  PingReussi := False;
  if cbPing.Checked then
  begin
    AfficherResultat('Test Ping en cours...');
    PingReussi := PingHost(Serveur);
    if PingReussi then
      AfficherResultat('✅ Ping réussi - Hôte accessible', True)
    else
      AfficherResultat('❌ Ping échoué - Hôte inaccessible');
    AfficherResultat('');
  end;

  // Test Port
  PortOuvert := False;
  if cbPort.Checked then
  begin
    AfficherResultat('Test du port ' + IntToStr(Port) + ' en cours...');
    PortOuvert := PortOpen(Serveur, Port, Timeout);
    if PortOuvert then
      AfficherResultat('✅ Port ouvert - Service disponible', True)
    else
      AfficherResultat('❌ Port fermé - Service indisponible');
    AfficherResultat('');
  end;

  // Conclusion
  AfficherResultat('=== RÉSULTAT FINAL ===');
  if ((not cbPing.Checked) or PingReussi) and ((not cbPort.Checked) or PortOuvert) then
    AfficherResultat('✅ CONNEXION RÉUSSIE', True)
  else
    AfficherResultat('❌ CONNEXION ÉCHOUÉE');

  AfficherResultat('');
  AfficherResultat('Diagnostic terminé à ' + FormatDateTime('hh:nn:ss', Now));
end;

procedure TPluginConnexionWizard.AfficherResultat(const Message: string; Succes: Boolean);
begin
  if Succes then
    MemoResultats.Lines.Add('✅ ' + Message)
  else
    MemoResultats.Lines.Add(Message);
  Application.ProcessMessages;
end;

{ TConnexionPlugin }

function TConnexionPlugin.GetName: string;
begin
  Result := 'Diagnostic Connexion Wizard';
end;

function TConnexionPlugin.GetVersion: string;
begin
  Result := '1.0.0';
end;

function TConnexionPlugin.ShowWizard: Boolean;
begin
  Result := TPluginConnexionWizard.Execute;
end;

class function TConnexionPlugin.New: IConnexionPlugin;
begin
  Result := TConnexionPlugin.Create;
end;

{ Fonction d'exportation }

function GetConnexionPlugin: IConnexionPlugin; stdcall;
begin
  Result := TConnexionPlugin.New;
end;

exports
  GetConnexionPlugin;

end.
