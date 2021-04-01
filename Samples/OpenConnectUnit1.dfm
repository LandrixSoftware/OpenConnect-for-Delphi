object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'OpenConnect'
  ClientHeight = 636
  ClientWidth = 1286
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TListView
    Left = 8
    Top = 47
    Width = 761
    Height = 581
    Columns = <>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
  end
  object Button1: TButton
    Left = 8
    Top = 16
    Width = 105
    Height = 25
    Caption = 'Anbieter laden'
    TabOrder = 1
    OnClick = Button1Click
  end
end
