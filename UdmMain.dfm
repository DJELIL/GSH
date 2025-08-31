object dmMain: TdmMain
  Height = 480
  Width = 640
  object FDConnection1: TFDConnection
    Params.Strings = (
      'DriverID=IB'
      'User_Name=sysdba'
      'Password=masterkey')
    LoginPrompt = False
    Transaction = FDTransaction1
    UpdateTransaction = FDTransaction1
    Left = 32
    Top = 16
  end
  object FDTransaction1: TFDTransaction
    Connection = FDConnection1
    Left = 176
    Top = 16
  end
end
