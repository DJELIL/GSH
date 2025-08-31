unit USrvLunch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dxBarBuiltInMenu, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore, dxSkinBasic,
  dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee,
  dxSkinDarkroom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
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
  dxSkinWhiteprint, dxSkinWXI, dxSkinXmas2008Blue, cxGeometry, dxFramedControl,
  dxPanel, cxPC, AdvSmoothStepControl, dxGDIPlusClasses, Vcl.ExtCtrls,
  cxContainer, cxEdit, cxGroupBox, cxRadioGroup, Vcl.BaseImageCollection,
  Vcl.ImageCollection, Vcl.VirtualImage, Vcl.Menus, Vcl.StdCtrls, cxButtons,
  System.Net.Socket, System.NetConsts, Data.DB, Datasnap.DBClient,
  Datasnap.Win.MConnect, Datasnap.Win.SConnect, Winapi.Winsock, Winapi.WinSvc;

type
  TFSrvLunch = class(TForm)
    AdvSmoothStepControl1: TAdvSmoothStepControl;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxTabSheet2: TcxTabSheet;
    cxTabSheet3: TcxTabSheet;
    dxPanel1: TdxPanel;
    cxRadioGroup1: TcxRadioGroup;
    VirtualImage1: TVirtualImage;
    ImageCollection1: TImageCollection;
    cxButton1: TcxButton;
    cxButton2: TcxButton;
    SocketConnection1: TSocketConnection;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  FSrvLunch: TFSrvLunch;

implementation

{$R *.dfm}

procedure TFSrvLunch.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
//
end;

procedure TFSrvLunch.FormCreate(Sender: TObject);
begin
//
cxPageControl1.Properties.HideTabs := True;
end;

 function PortOpen(const Host: string; Port: Word; Timeout: Integer = 2000): Boolean;
var
  Client: TSocket;
  Addr: TSockAddrIn;
  WSAData: TWSAData;
  HostEnt: PHostEnt;
  LastError: Integer;
begin
  Result := False;

  // Initialiser Winsock
  if WSAStartup(MAKEWORD(2, 2), WSAData) <> 0 then
  begin
    //ShowMessage('Erreur WSAStartup: ' + IntToStr(WSAGetLastError));
    Exit;
  end;

  Client := socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if Client = INVALID_SOCKET then
  begin
    //ShowMessage('Erreur socket: ' + IntToStr(WSAGetLastError));
    WSACleanup;
    Exit;
  end;

  try
    // Définir les timeouts
    setsockopt(Client, SOL_SOCKET, SO_RCVTIMEO, @Timeout, SizeOf(Timeout));
    setsockopt(Client, SOL_SOCKET, SO_SNDTIMEO, @Timeout, SizeOf(Timeout));

    // Configurer l'adresse
    FillChar(Addr, SizeOf(Addr), 0);
    Addr.sin_family := AF_INET;
    Addr.sin_port := htons(Port);

    // Résolution DNS ou adresse IP directe
    Addr.sin_addr.S_addr := inet_addr(PAnsiChar(AnsiString(Host)));
    if Addr.sin_addr.S_addr = INADDR_NONE then
    begin
      HostEnt := gethostbyname(PAnsiChar(AnsiString(Host)));
      if HostEnt = nil then
      begin
        //ShowMessage('Erreur résolution DNS: ' + Host);
        Exit;
      end;
      Addr.sin_addr.S_addr := PInAddr(HostEnt.h_addr^).S_addr;
    end;

    // Tentative de connexion
    if connect(Client, Addr, SizeOf(Addr)) = SOCKET_ERROR then
    begin
      LastError := WSAGetLastError;
      // Les erreurs WSAETIMEDOUT ou WSAEWOULDBLOCK indiquent un timeout
      Result := False;
    end
    else
    begin
      Result := True;
    end;

  finally
    closesocket(Client);
    WSACleanup;
  end;
  {
  // Exemple d'utilisation :
  procedure TForm1.Button1Click(Sender: TObject);
  begin
    if PortOpen('127.0.0.1', 3050) then
      ShowMessage('✅ Port InterBase (3050) ouvert')
    else
      ShowMessage('❌ Port InterBase fermé');

    if PortOpen('localhost', 3050, 3000) then // Timeout de 3 secondes
      ShowMessage('✅ Service InterBase disponible')
    else
      ShowMessage('❌ Service InterBase indisponible');
  end;
  }
end;

function ServiceRunning(const ServiceName: string): Boolean;
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
  {
  // Exemple
  if ServiceRunning('IBS_gds_db') then
    ShowMessage('✅ Service InterBase démarré')
  else
    ShowMessage('❌ Service InterBase arrêté');
  }
end;

end.
