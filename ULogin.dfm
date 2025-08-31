object FrmLogin: TFrmLogin
  Left = 0
  Top = 0
  Width = 640
  Height = 480
  TabOrder = 0
  object cxLabelStatus: TcxLabel
    AlignWithMargins = True
    Left = 3
    Top = 458
    Hint = '[BACKCOLOR=#FF0080]Information [/BACKCOLOR]'
    Align = alBottom
    Caption = 
      'Entrez votre nom d'#39'utilisateur et votre mot de passe pour passe ' +
      #224' vos services'
    Style.ReadOnly = False
    Properties.LabelEffect = cxleCool
    Transparent = True
  end
  object cxComboBox1: TcxComboBox
    Left = 192
    Top = 112
    Style.ButtonTransparency = ebtNone
    TabOrder = 1
    TextHint = 'Utilisateur'
    Width = 265
  end
  object cxButtonEdit1: TcxButtonEdit
    Left = 192
    Top = 141
    Properties.Buttons = <
      item
        Default = True
        Kind = bkEllipsis
      end>
    Properties.PasswordChar = '*'
    TabOrder = 2
    TextHint = 'Passsword'
    Width = 265
  end
  object cxButton1: TcxButton
    Left = 272
    Top = 170
    Width = 104
    Height = 25
    Caption = 'cxButton1'
    TabOrder = 3
    OnClick = cxButton1Click
  end
  object cxButton2: TcxButton
    Left = 382
    Top = 170
    Width = 75
    Height = 25
    Caption = 'cxButton1'
    TabOrder = 4
  end
end
