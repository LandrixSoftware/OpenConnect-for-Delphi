object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'OpenConnect for Delphi'
  ClientHeight = 715
  ClientWidth = 1286
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object ListView1: TListView
    Left = 0
    Top = 0
    Width = 1024
    Height = 674
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
    Height = 674
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
      Top = 201
      Width = 200
      Height = 13
      Caption = 'IDSConnect-Unterstuetzung (Onlineshop)'
    end
    object Label7: TLabel
      Left = 17
      Top = 217
      Width = 31
      Height = 13
      Caption = 'Label1'
    end
    object Label4: TLabel
      Left = 17
      Top = 238
      Width = 173
      Height = 13
      Caption = 'Unterstuetzte IDSConnect Prozesse'
    end
    object Label5: TLabel
      Left = 17
      Top = 280
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
      Top = 320
      Width = 149
      Height = 13
      Caption = 'Naeheres zu IDSConnect unter'
    end
    object Label10: TLabel
      Left = 17
      Top = 336
      Width = 230
      Height = 33
      Cursor = crHandPoint
      AutoSize = False
      Caption = 'https://github.com/LandrixSoftware/ IDSConnect-for-Delphi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      OnClick = Label10Click
    end
    object Label11: TLabel
      Left = 17
      Top = 149
      Width = 160
      Height = 13
      Caption = 'Datanorm-Online-Unterstuetzung'
    end
    object Label12: TLabel
      Left = 17
      Top = 165
      Width = 31
      Height = 13
      Caption = 'Label1'
    end
    object Label13: TLabel
      Left = 17
      Top = 405
      Width = 163
      Height = 13
      Caption = 'Open Masterdata-Unterstuetzung'
    end
    object Label14: TLabel
      Left = 17
      Top = 421
      Width = 31
      Height = 13
      Caption = 'Label1'
    end
    object Label15: TLabel
      Left = 17
      Top = 440
      Width = 45
      Height = 13
      Caption = 'Auth URL'
    end
    object Label16: TLabel
      Left = 17
      Top = 480
      Width = 89
      Height = 13
      Caption = 'bySupplierPID URL'
    end
    object Label17: TLabel
      Left = 17
      Top = 520
      Width = 122
      Height = 13
      Caption = 'byManufacturerData URL'
    end
    object Label18: TLabel
      Left = 17
      Top = 560
      Width = 58
      Height = 13
      Caption = 'byGTIN URL'
    end
    object Label19: TLabel
      Left = 17
      Top = 600
      Width = 176
      Height = 13
      Caption = 'Naeheres zu Open Masterdata unter'
    end
    object Label20: TLabel
      Left = 17
      Top = 616
      Width = 230
      Height = 33
      Cursor = crHandPoint
      AutoSize = False
      Caption = 'https://github.com/LandrixSoftware/ OpenMasterdata-for-Delphi'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      OnClick = Label20Click
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
      Top = 254
      Width = 232
      Height = 21
      TabOrder = 1
      OnChange = Edit3Change
    end
    object Edit2: TEdit
      Left = 17
      Top = 296
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
    object Edit6: TEdit
      Left = 17
      Top = 456
      Width = 232
      Height = 21
      TabOrder = 6
      OnChange = Edit3Change
    end
    object Edit7: TEdit
      Left = 17
      Top = 496
      Width = 232
      Height = 21
      TabOrder = 7
      OnChange = Edit3Change
    end
    object Edit8: TEdit
      Left = 17
      Top = 536
      Width = 232
      Height = 21
      TabOrder = 8
      OnChange = Edit3Change
    end
    object Edit9: TEdit
      Left = 17
      Top = 576
      Width = 232
      Height = 21
      TabOrder = 9
      OnChange = Edit3Change
    end
    object Button4: TButton
      Left = 16
      Top = 649
      Width = 235
      Height = 25
      Caption = 'Kopiere OMD-Konfiguration in Zwischenablage'
      TabOrder = 10
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 16
      Top = 363
      Width = 235
      Height = 25
      Caption = 'Kopiere IDS-Konfiguration in Zwischenablage'
      TabOrder = 11
      OnClick = Button5Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 674
    Width = 1286
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      1286
      41)
    object Button1: TButton
      Left = 8
      Top = 6
      Width = 105
      Height = 25
      Caption = 'Anbieter laden'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button3: TButton
      Left = 1196
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Beenden'
      TabOrder = 1
      OnClick = Button3Click
    end
    object CheckBox1: TCheckBox
      Left = 1016
      Top = 10
      Width = 169
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Aenderungen nicht speichern'
      TabOrder = 2
    end
  end
end
