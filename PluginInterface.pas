unit PluginInterface;

interface

type
  IConnexionPlugin = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function GetName: string;
    function GetVersion: string;
    function ShowWizard: Boolean;
  end;

  TConnexionPluginProc = function: IConnexionPlugin; stdcall;

implementation

end.
