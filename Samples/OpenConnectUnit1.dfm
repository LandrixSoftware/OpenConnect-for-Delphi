object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'OpenConnect for Delphi'
  ClientHeight = 636
  ClientWidth = 1286
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TListView
    Left = 0
    Top = 0
    Width = 1024
    Height = 595
    Align = alClient
    Columns = <>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnSelectItem = ListView1SelectItem
  end
  object Panel1: TPanel
    Left = 1024
    Top = 0
    Width = 262
    Height = 595
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 17
      Top = 16
      Width = 109
      Height = 13
      Caption = 'Anbieter-Konfiguration'
    end
    object Label6: TLabel
      Left = 17
      Top = 169
      Width = 200
      Height = 13
      Caption = 'IDSConnect-Unterstuetzung (Onlineshop)'
    end
    object Label7: TLabel
      Left = 17
      Top = 185
      Width = 31
      Height = 13
      Caption = 'Label1'
    end
    object Label4: TLabel
      Left = 17
      Top = 206
      Width = 173
      Height = 13
      Caption = 'Unterstuetzte IDSConnect Prozesse'
    end
    object Label5: TLabel
      Left = 17
      Top = 248
      Width = 79
      Height = 13
      Caption = 'IDSConnect URL'
    end
    object Label2: TLabel
      Left = 17
      Top = 44
      Width = 74
      Height = 13
      Caption = 'Kundennummer'
    end
    object Label3: TLabel
      Left = 17
      Top = 69
      Width = 69
      Height = 13
      Caption = 'Benutzername'
    end
    object Label8: TLabel
      Left = 17
      Top = 95
      Width = 44
      Height = 13
      Caption = 'Passwort'
    end
    object Label9: TLabel
      Left = 17
      Top = 304
      Width = 149
      Height = 13
      Caption = 'Naeheres zu IDSConnect unter'
    end
    object Label10: TLabel
      Left = 17
      Top = 320
      Width = 230
      Height = 33
      Cursor = crHandPoint
      AutoSize = False
      Caption = 'https://github.com/ LandrixSoftware/IDSConnect-for-Delphi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      OnClick = Label10Click
    end
    object Button2: TButton
      Left = 128
      Top = 118
      Width = 121
      Height = 25
      Caption = 'Testen'
      TabOrder = 0
      OnClick = Button2Click
    end
    object Edit1: TEdit
      Left = 17
      Top = 222
      Width = 232
      Height = 21
      TabOrder = 1
      OnChange = Edit3Change
    end
    object Edit2: TEdit
      Left = 17
      Top = 264
      Width = 232
      Height = 21
      TabOrder = 2
      OnChange = Edit3Change
    end
    object Edit3: TEdit
      Left = 128
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 3
      OnChange = Edit3Change
    end
    object Edit4: TEdit
      Left = 128
      Top = 65
      Width = 121
      Height = 21
      TabOrder = 4
      OnChange = Edit3Change
    end
    object Edit5: TEdit
      Left = 128
      Top = 91
      Width = 121
      Height = 21
      TabOrder = 5
      OnChange = Edit3Change
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 595
    Width = 1286
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object Button1: TButton
      Left = 8
      Top = 6
      Width = 105
      Height = 25
      Caption = 'Anbieter laden'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
end
