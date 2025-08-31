object FormWizardDiagnostic: TFormWizardDiagnostic
  Left = 0
  Top = 0
  Caption = 'Diagnostic de Connexion Serveur'
  ClientHeight = 450
  ClientWidth = 600
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 600
    Height = 400
    ActivePage = tsTypeConnexion
    Align = alClient
    TabOrder = 0
    object tsTypeConnexion: TTabSheet
      Caption = 'Type de Connexion'
      object Label1: TLabel
        Left = 24
        Top = 24
        Width = 537
        Height = 33
        AutoSize = False
        Caption = 
          'S'#233'lectionnez le type de connexion '#224' diagnostiquer :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        WordWrap = True
      end
      object rgTypeConnexion: TRadioGroup
        Left = 24
        Top = 72
        Width = 537
        Height = 145
        Caption = ' Type de Service '
        Items.Strings = (
          'InterBase/Firebird (Port 3050)'
          'PostgreSQL (Port 5432)'
          'MySQL (Port 3306)'
          'Web Server HTTP (Port 80)'
          'Web Server HTTPS (Port 443)'
          'Service Personnalis'#233' (Port sp'#233'cifique)')
        TabOrder = 0
      end
    end
    object tsParametres: TTabSheet
      Caption = 'Param'#232'tres'
      ImageIndex = 1
      object Label2: TLabel
        Left = 24
        Top = 24
        Width = 537
        Height = 33
        AutoSize = False
        Caption = 'Veuillez sp'#233'cifier les param'#232'tres de connexion :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        WordWrap = True
      end
      object Label3: TLabel
        Left = 24
        Top = 80
        Width = 76
        Height = 13
        Caption = 'Adresse Serveur:'
      end
      object Label4: TLabel
        Left = 24
        Top = 120
        Width = 24
        Height = 13
        Caption = 'Port:'
      end
      object edtServeur: TEdit
        Left = 120
        Top = 77
        Width = 200
        Height = 21
        TabOrder = 0
        Text = 'localhost'
      end
      object edtPort: TEdit
        Left = 120
        Top = 117
        Width = 100
        Height = 21
        NumbersOnly = True
        TabOrder = 1
      end
      object GroupBox1: TGroupBox
        Left = 24
        Top = 160
        Width = 537
        Height = 105
        Caption = ' Options de Test '
        TabOrder = 2
        object cbPing: TCheckBox
          Left = 16
          Top = 24
          Width = 200
          Height = 17
          Caption = 'Test Ping (ICMP)'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object cbPort: TCheckBox
          Left = 16
          Top = 47
          Width = 200
          Height = 17
          Caption = 'Test Port TCP'
          Checked = True
          State = cbChecked
          TabOrder = 1
        end
        object cbTimeout: TCheckBox
          Left = 16
          Top = 70
          Width = 200
          Height = 17
          Caption = 'Test Timeout'
          Checked = True
          State = cbChecked
          TabOrder = 2
        end
        object edtTimeout: TEdit
          Left = 240
          Top = 68
          Width = 80
          Height = 21
          NumbersOnly = True
          TabOrder = 3
          Text = '3000'
        end
        object Label5: TLabel
          Left = 326
          Top = 71
          Width = 20
          Height = 13
          Caption = 'ms'
        end
      end
    end
    object tsResultats: TTabSheet
      Caption = 'R'#233'sultats'
      ImageIndex = 2
      object Label6: TLabel
        Left = 24
        Top = 24
        Width = 537
        Height = 33
        AutoSize = False
        Caption = 'R'#233'sultats du diagnostic de connexion :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        WordWrap = True
      end
      object MemoResultats: TMemo
        Left = 24
        Top = 72
        Width = 537
        Height = 249
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
  object PanelBoutons: TPanel
    Left = 0
    Top = 400
    Width = 600
    Height = 50
    Align = alBottom
    TabOrder = 1
    object btnPrecedent: TButton
      Left = 24
      Top = 12
      Width = 75
      Height = 25
      Caption = 'Pr'#233'c'#233'dent'
      TabOrder = 0
      OnClick = btnPrecedentClick
    end
    object btnSuivant: TButton
      Left = 416
      Top = 12
      Width = 75
      Height = 25
      Caption = 'Suivant'
      TabOrder = 1
      OnClick = btnSuivantClick
    end
    object btnAnnuler: TButton
      Left = 497
      Top = 12
      Width = 75
      Height = 25
      Caption = 'Annuler'
      TabOrder = 2
      OnClick = btnAnnulerClick
    end
    object btnTester: TButton
      Left = 320
      Top = 12
      Width = 75
      Height = 25
      Caption = 'Tester'
      TabOrder = 3
      OnClick = btnTesterClick
    end
  end
end