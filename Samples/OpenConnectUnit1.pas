unit OpenConnectUnit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  intf.OpenConnect, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TMainForm = class(TForm)
    ListView1: TListView;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    Suppliers: TOpenConnectBusinessList;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Suppliers:= TOpenConnectBusinessList.Create;

  with ListView1.Columns.Add do
  begin
    Caption := 'Service-Name';
    Alignment := taLeftJustify;
    Width := 140;
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'Service-ID';
    Alignment := taLeftJustify;
    Width := 50;
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'ServiceURL';
    Alignment := taLeftJustify;
    Width := 140;
  end;

  with ListView1.Columns.Add do
  begin
    Caption := 'Supplier-Name';
    Alignment := taLeftJustify;
    Width := 140;
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'Supplier-ID';
    Alignment := taLeftJustify;
    Width := 50;
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'Street';
    Alignment := taLeftJustify;
    Width := 50;
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'Zip';
    Alignment := taLeftJustify;
    Width := 50;
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'City';
    Alignment := taLeftJustify;
    Width := 50;
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'Country';
    Alignment := taLeftJustify;
    Width := 50;
  end;
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  i,j : Integer;
begin
  ListView1.Clear;
  Suppliers.Clear;
  if not TOpenConnectHelper.GetSupplierList(Suppliers) then
    exit;
  for i := 0 to Suppliers.Count-1 do
  for j := 0 to Suppliers[i].Supplier.Count-1 do
  with ListView1.Items.Add do
  begin
    Caption := Suppliers[i].Description;
    SubItems.Add(IntToStr(Suppliers[i].ID));
    SubItems.Add(Suppliers[i].ServiceURL);
    SubItems.Add(Suppliers[i].Supplier[j].Name);
    SubItems.Add(IntToStr(Suppliers[i].Supplier[j].ID));
    SubItems.Add(Suppliers[i].Supplier[j].Street);
    SubItems.Add(Suppliers[i].Supplier[j].Zip);
    SubItems.Add(Suppliers[i].Supplier[j].City);
    SubItems.Add(Suppliers[i].Supplier[j].Country);
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned( Suppliers) then begin ListView1.Clear; Suppliers.Free;  Suppliers := nil; end;
end;

end.
