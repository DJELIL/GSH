unit UnitWizardDiagnostic;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, 
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Winapi.Winsock;

type
  TFormWizardDiagnostic = class(TForm)
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
  end;

var
  FormWizardDiagnostic: TFormWizardDiagnostic;

implementation

{$R *.dfm}

procedure TFormWizardDiagnostic.FormCreate(Sender: TObject);
begin
  PageControl.ActivePage := tsTypeConnexion;
  btnPrecedent.Enabled := False;
  btnTester.Visible := False;
end;

procedure TFormWizardDiagnostic.btnSuivantClick(Sender: TObject);
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

procedure TFormWizardDiagnostic.btnPrecedentClick(Sender: TObject);
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

procedure TFormWizardDiagnostic.btnAnnulerClick(Sender: TObject);
begin
  Close;
end;

procedure TFormWizardDiagnostic.rgTypeConnexionClick(Sender: TObject);
begin
  // Définir les ports par défaut selon le choix
  case rgTypeConnexion.ItemIndex of
    0: edtPort.Text := '3050';  // InterBase
    1: edtPort.Text := '5432';  // PostgreSQL
    2: edtPort.Text := '3306';  // MySQL
    3: edtPort.Text := '80';    // HTTP
    4: edtPort.Text := '443';   // HTTPS
    // 5: Personnalisé - l'utilisateur saisit le port
  end;
end;

procedure TFormWizardDiagnostic.btnTesterClick(Sender: TObject);
begin
  TesterConnexion;
end;

function TFormWizardDiagnostic.PortOpen(const Host: string; Port: Word; Timeout: Integer): Boolean;
var
  Client: TSocket;
  Addr: TSockAddrIn;
  WSAData: TWSAData;
  HostEnt: PHostEnt;
begin
  Result := False;
  
  if WSAStartup(MAKEWORD(2, 2), WSAData) <> 0 then
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
    
    Addr.sin_family := AF_INET;
    Addr.sin_port := htons(Port);
    
    Addr.sin_addr.S_addr := inet_addr(PAnsiChar(AnsiString(Host)));
    if Addr.sin_addr.S_addr = INADDR_NONE then
    begin
      HostEnt := gethostbyname(PAnsiChar(AnsiString(Host)));
      if HostEnt = nil then Exit;
      Addr.sin_addr.S_addr := PInAddr(HostEnt.h_addr^).S_addr;
    end;

    Result := connect(Client, Addr, SizeOf(Addr)) = 0;
    
  finally
    closesocket(Client);
    WSACleanup;
  end;
end;

function TFormWizardDiagnostic.PingHost(const Host: string): Boolean;
var
  WSAData: TWSAData;
  HostEnt: PHostEnt;
  Addr: TSockAddrIn;
begin
  Result := False;
  
  if WSAStartup(MAKEWORD(2, 2), WSAData) <> 0 then
    Exit;

  try
    // Résoudre le nom d'hôte
    HostEnt := gethostbyname(PAnsiChar(AnsiString(Host)));
    if HostEnt <> nil then
    begin
      Addr.sin_addr.S_addr := PInAddr(HostEnt.h_addr^).S_addr;
      Result := (Addr.sin_addr.S_addr <> INADDR_NONE);
    end;
  finally
    WSACleanup;
  end;
end;

procedure TFormWizardDiagnostic.TesterConnexion;
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
  
  if not TryStrToInt(edtPort.Text, Port) then
  begin
    ShowMessage('Port invalide');
    Exit;
  end;
  
  if not TryStrToInt(edtTimeout.Text, Timeout) then
    Timeout := 3000;

  AfficherResultat('Début du diagnostic de connexion...');
  AfficherResultat('Serveur: ' + Serveur);
  AfficherResultat('Port: ' + IntToStr(Port));
  AfficherResultat('Timeout: ' + IntToStr(Timeout) + ' ms');
  AfficherResultat('');

  // Test Ping
  if cbPing.Checked then
  begin
    AfficherResultat('Test Ping en cours...');
    PingReussi := PingHost(Serveur);
    if PingReussi then
      AfficherResultat('? Ping réussi - Hôte accessible', True)
    else
      AfficherResultat('? Ping échoué - Hôte inaccessible');
    AfficherResultat('');
  end;

  // Test Port
  if cbPort.Checked then
  begin
    AfficherResultat('Test du port ' + IntToStr(Port) + ' en cours...');
    PortOuvert := PortOpen(Serveur, Port, Timeout);
    if PortOuvert then
      AfficherResultat('? Port ouvert - Service disponible', True)
    else
      AfficherResultat('? Port fermé - Service indisponible');
    AfficherResultat('');
  end;

  // Conclusion
  AfficherResultat('=== RÉSULTAT FINAL ===');
  if (not cbPing.Checked or PingReussi) and (not cbPort.Checked or PortOuvert) then
    AfficherResultat('? CONNEXION RÉUSSIE', True)
  else
    AfficherResultat('? CONNEXION ÉCHOUÉE');

  AfficherResultat('');
  AfficherResultat('Diagnostic terminé à ' + FormatDateTime('hh:nn:ss', Now));
end;

procedure TFormWizardDiagnostic.AfficherResultat(const Message: string; Succes: Boolean);
begin
  if Succes then
    MemoResultats.Lines.Add('? ' + Message)
  else
    MemoResultats.Lines.Add(Message);
  Application.ProcessMessages;
end;

end.