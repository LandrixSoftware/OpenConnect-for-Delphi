unit OpenConnectUnit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, System.IniFiles,Winapi.ShellAPI,
  Vcl.ExtCtrls, System.UITypes,
  intf.OpenConnect;

type
  TMainForm = class(TForm)
    ListView1: TListView;
    Button1: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label8: TLabel;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Label9: TLabel;
    Label10: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure Button2Click(Sender: TObject);
    procedure Label10Click(Sender: TObject);
  public
    Suppliers: TOpenConnectBusinessList;
    Configuration : TMemIniFile;
    Editable : Boolean;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Suppliers:= TOpenConnectBusinessList.Create;
  Configuration := TMemIniFile.Create(ExtractFilePath(ExtractFileDir(ExtractFileDir(Application.ExeName)))+'configuration.ini');
  Editable := false;
  
  with ListView1.Columns.Add do
  begin
    Caption := 'Service-Name';
    Alignment := taLeftJustify;
    Width := 80;
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
    Width := 100;
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
    Width := 100;
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
    Width := 100;
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'Country';
    Alignment := taLeftJustify;
    Width := 100;
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'Configuration';
    Alignment := taLeftJustify;
    Width := 50;
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(Configuration) then begin Configuration.UpdateFile; Configuration.Free; Configuration := nil; end;
  if Assigned( Suppliers) then begin ListView1.Clear; Suppliers.Free;  Suppliers := nil; end;
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  i,j : Integer;
begin
  ListView1.Clear;
  Suppliers.Clear;

  Screen.Cursor := crHourGlass;
  try
    if not TOpenConnectHelper.GetSupplierList(Suppliers) then
      exit;
  finally
    Screen.Cursor := crDefault;
  end;
  
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
    if Configuration.SectionExists(IntToStr(Suppliers[i].ID)+'-'+IntToStr(Suppliers[i].Supplier[j].ID)) then
      SubItems.Add('vorhanden')
    else
      SubItems.Add('');
  end;
end;

procedure TMainForm.Edit3Change(Sender: TObject);
var
  section : String;
begin
  if ListView1.Selected = nil then
    exit;
  if not Editable then
    exit;
  section := ListView1.Selected.SubItems[0]+'-'+ListView1.Selected.SubItems[3];
  if Trim(Edit1.Text).IsEmpty and Trim(Edit2.Text).IsEmpty and Trim(Edit3.Text).IsEmpty and 
     Trim(Edit4.Text).IsEmpty and Trim(Edit5.Text).IsEmpty  then
  begin   
    Configuration.EraseSection(section);
    ListView1.Selected.SubItems[ListView1.Selected.SubItems.Count-1] := '';
  end else
  begin
    Configuration.WriteString(section,'idsconnectprocesses',Edit1.Text);
    Configuration.WriteString(section,'idsconnecturl',Edit2.Text);
    Configuration.WriteString(section,'customerno',Edit3.Text);
    Configuration.WriteString(section,'username',Edit4.Text);
    Configuration.WriteString(section,'password',Edit5.Text);
    ListView1.Selected.SubItems[ListView1.Selected.SubItems.Count-1] := 'vorhanden';
  end;
end;

procedure TMainForm.ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  section : String;
begin
  if Item = nil then
    exit;
  if not Selected then
    exit;
  Editable := false;
  try
    section := Item.SubItems[0]+'-'+Item.SubItems[3];
    Edit1.Text := Configuration.ReadString(section,'idsconnectprocesses','');
    Edit2.Text := Configuration.ReadString(section,'idsconnecturl','');
    Edit3.Text := Configuration.ReadString(section,'customerno','');
    Edit4.Text := Configuration.ReadString(section,'username','');
    Edit5.Text := Configuration.ReadString(section,'password','');
  finally
    Editable := true;
  end;
end;

procedure TMainForm.Button2Click(Sender: TObject);
var
  loginOptions : TOpenConnectLoginOptions;
  IDSConnectivity: TOpenConnectIDSConnectivity;
begin
  if ListView1.Selected = nil then
    exit;

  loginOptions.CustomerNo := Edit3.Text;
  loginOptions.Username := Edit4.Text;
  loginOptions.Password := Edit5.Text;
  loginOptions.ServiceURL := ListView1.Selected.SubItems[1];
  loginOptions.SupplierID := StrToInt(ListView1.Selected.SubItems[3]);
    
  Screen.Cursor := crHourGlass;
  try
    if not TOpenConnectHelper.CheckIDSConnectivitiy(loginOptions,IDSConnectivity) then
      exit;
    if IDSConnectivity.IDSConnectAvailable then
      Label7.Caption := 'verfuegbar'
    else
      Label7.Caption := 'nicht verfuegbar';

    Edit1.Text := IDSConnectivity.IDSConnectSupportedProcesses;

    if Edit2.Text <> '' then
    if not SameText(Edit2.Text,IDSConnectivity.IDSConnectURL) then
    if (MessageDlg('Die IDSConnect-ServiceURL hat sich geaendert.'+#10+
        'Soll die neue URL eingetragen werden?'+#10+
        IDSConnectivity.IDSConnectURL, mtWarning, [mbYes, mbNo], 0) = mrNo) then
      exit;
    
    Edit2.Text := IDSConnectivity.IDSConnectURL;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMainForm.Label10Click(Sender: TObject);
begin
  ShellExecute(0,'open',PChar('https://github.com/LandrixSoftware/IDSConnect-for-Delphi'),'','',SW_SHOWNORMAL);
end;

end.
