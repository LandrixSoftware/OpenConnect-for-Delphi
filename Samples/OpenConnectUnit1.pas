unit OpenConnectUnit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, System.IniFiles,Winapi.ShellAPI,
  Vcl.ExtCtrls, System.UITypes, Vcl.Clipbrd,
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
    Button3: TButton;
    CheckBox1: TCheckBox;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Edit6: TEdit;
    Edit7: TEdit;
    Label16: TLabel;
    Edit8: TEdit;
    Label17: TLabel;
    Edit9: TEdit;
    Label18: TLabel;
    Button4: TButton;
    Button5: TButton;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    edSearchSupplier: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure Button2Click(Sender: TObject);
    procedure Label10Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Label20Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure edSearchSupplierChange(Sender: TObject);
    procedure ListView1CustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      var DefaultDraw: Boolean);
  public
    Suppliers: TOpenConnectBusinessList;
    Configuration : TMemIniFile;
    Editable : Boolean;
    OpenMasterdataConfigurationAsText : String;
    IDSConnectConfigurationAsText : String;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
var
  configurationFilename : String;
begin
  Suppliers:= TOpenConnectBusinessList.Create;

  if (Pos('Samples\Win32',Application.ExeName)>0) or (Pos('Samples\Win64',Application.ExeName)>0) then
    configurationFilename := ExtractFilePath(ExtractFileDir(ExtractFileDir(Application.ExeName)))
  else
    configurationFilename := ExtractFilePath(Application.ExeName);

  configurationFilename := configurationFilename + 'configuration.ini';

  Configuration := TMemIniFile.Create(configurationFilename);
  Editable := false;

  Left := 50;
  Top := 50;
  Width := Screen.WorkAreaWidth-100;
  Height := Screen.WorkAreaHeight-100;

  with ListView1.Columns.Add do
  begin
    Caption := 'Service-Name';
    Alignment := taLeftJustify;
    Width := MulDiv(80,Screen.PixelsPerInch,96);
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'Service-ID';
    Alignment := taLeftJustify;
    Width := MulDiv(71,Screen.PixelsPerInch,96);
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'ServiceURL';
    Alignment := taLeftJustify;
    Width := MulDiv(200,Screen.PixelsPerInch,96);
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'Supplier-Name';
    Alignment := taLeftJustify;
    Width := MulDiv(270,Screen.PixelsPerInch,96);
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'Supplier-ID';
    Alignment := taLeftJustify;
    Width := MulDiv(65,Screen.PixelsPerInch,96);
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'Street';
    Alignment := taLeftJustify;
    Width := MulDiv(125,Screen.PixelsPerInch,96);
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'Zip';
    Alignment := taLeftJustify;
    Width := MulDiv(60,Screen.PixelsPerInch,96);
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'City';
    Alignment := taLeftJustify;
    Width := MulDiv(133,Screen.PixelsPerInch,96);
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'Country';
    Alignment := taLeftJustify;
    Width := MulDiv(100,Screen.PixelsPerInch,96);
  end;
  with ListView1.Columns.Add do
  begin
    Caption := 'Configuration';
    Alignment := taLeftJustify;
    Width := MulDiv(78,Screen.PixelsPerInch,96);
  end;
  //for var i : Integer := 0 to ListView1.Columns.Count-1 do
  //  ListView1.Columns[i].Width := Configuration.ReadInteger(ListView1.Name,i.ToString,ListView1.Columns[i].Width);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //for var i : Integer := 0 to ListView1.Columns.Count-1 do
  //  Configuration.WriteInteger(ListView1.Name,i.ToString,ListView1.Columns[i].Width);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(Configuration) then
  begin
    if not CheckBox1.Checked then
      Configuration.UpdateFile;
    Configuration.Free;
    Configuration := nil;
  end;
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
    if Configuration.SectionExists(Suppliers[i].ServiceURL+'-'+IntToStr(Suppliers[i].ID)+'-'+IntToStr(Suppliers[i].Supplier[j].ID)) then
      SubItems.Add('vorhanden')
    else
      SubItems.Add('');
  end;
end;

procedure TMainForm.Edit3Change(Sender: TObject);
var
  section : String;
  i : Integer;
begin
  if ListView1.Selected = nil then
    exit;
  if not Editable then
    exit;

  section := ListView1.Selected.SubItems[1]+'-'+ListView1.Selected.SubItems[0]+'-'+ListView1.Selected.SubItems[3];

  if //Trim(Edit1.Text).IsEmpty and Trim(Edit2.Text).IsEmpty and
     Trim(Edit3.Text).IsEmpty and Trim(Edit4.Text).IsEmpty and Trim(Edit5.Text).IsEmpty  then
  begin
    Configuration.EraseSection(section);
  end else
  begin
    Configuration.WriteString(section,'idsconnectprocesses',Edit1.Text);
    Configuration.WriteString(section,'idsconnecturl',Edit2.Text);
    Configuration.WriteString(section,'customerno',Edit3.Text);
    Configuration.WriteString(section,'username',Edit4.Text);
    Configuration.WriteString(section,'password',Edit5.Text);
  end;

  for i := 0 to ListView1.Items.Count-1 do
  if Configuration.SectionExists(ListView1.Items[i].SubItems[1]+'-'+ListView1.Items[i].SubItems[0]+'-'+ListView1.Items[i].SubItems[3]) then
    ListView1.Items[i].SubItems[ListView1.Selected.SubItems.Count-1] := 'vorhanden'
  else
    ListView1.Items[i].SubItems[ListView1.Selected.SubItems.Count-1] := '';
end;

procedure TMainForm.edSearchSupplierChange(Sender: TObject);
begin
  ListView1.Repaint;
end;

procedure TMainForm.ListView1CustomDrawSubItem(Sender: TCustomListView;
  Item: TListItem; SubItem: Integer; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  DefaultDraw := true;

  if edSearchSupplier.Text = '' then
    exit;

  if ((SubItem = 3) and (Item.SubItems.Count > 1)) then
  begin
    if Pos(LowerCase(edSearchSupplier.Text),LowerCase(Item.SubItems.Strings[2])) > 0 then
      Sender.Canvas.Font.Style := [fsBold];
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
    section := Item.SubItems[1]+'-'+Item.SubItems[0]+'-'+Item.SubItems[3];
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
  connectivity: TOpenConnectConnectivityOptions;
begin
  Label12.Caption := '';
  Label7.Caption := '';
  Edit1.Text := '';
  Edit2.Text := '';
  Label14.Caption := '';
  Edit6.Text := '';
  Edit7.Text := '';
  Edit8.Text := '';
  Edit9.Text := '';
  OpenMasterdataConfigurationAsText := '';
  IDSConnectConfigurationAsText := '';

  if ListView1.Selected = nil then
    exit;

  loginOptions.CustomerNo := Edit3.Text;
  loginOptions.Username := Edit4.Text;
  loginOptions.Password := Edit5.Text;
  loginOptions.ServiceURL := ListView1.Selected.SubItems[1];
  loginOptions.SupplierID := StrToInt(ListView1.Selected.SubItems[3]);

  Screen.Cursor := crHourGlass;
  try
    if not TOpenConnectHelper.CheckConnectivitiy(loginOptions,connectivity) then
      exit;

    if connectivity.DatanormOnlineAvailable then
      Label12.Caption := 'verfuegbar'
    else
      Label12.Caption := 'nicht verfuegbar';

    if connectivity.IDSConnectAvailable then
      Label7.Caption := 'verfuegbar'
    else
      Label7.Caption := 'nicht verfuegbar';

    Edit1.Text := connectivity.IDSConnectSupportedProcesses;

    if Edit2.Text <> '' then
    begin
      if not SameText(Edit2.Text,connectivity.IDSConnectURL) then
      if (MessageDlg('Die IDSConnect-ServiceURL hat sich geaendert.'+#10+
          'Soll die neue URL eingetragen werden?'+#10+
          'Alt: '+Edit2.Text+#10+
          'Neu: '+connectivity.IDSConnectURL, mtWarning, [mbYes, mbNo], 0) = mrYes) then
        Edit2.Text := connectivity.IDSConnectURL;
    end else
      Edit2.Text := connectivity.IDSConnectURL;

    var section : String := ListView1.Selected.SubItems[1]+'-'+ListView1.Selected.SubItems[0]+'-'+ListView1.Selected.SubItems[3];
    Configuration.WriteString(section,'idsconnectprocesses',Edit1.Text);
    Configuration.WriteString(section,'idsconnecturl',Edit2.Text);

    IDSConnectConfigurationAsText  := '['+ListView1.Selected.SubItems[2]+']'+#13#10+
             'Username='+Edit4.Text+#13#10+
             'Password='+Edit5.Text+#13#10+
             'Customernumber='+Edit3.Text+#13#10+
             'IDSConnectUrl='+Edit2.Text;

    if connectivity.OpenMasterdataAvailable then
    begin
      Label14.Caption := 'verfuegbar';
      if connectivity.OpenMasterdata_OAuthCustomernumberRequired then
        Label14.Caption := Label14.Caption +' +CN';
      if connectivity.OpenMasterdata_OAuthUsernameRequired then
        Label14.Caption := Label14.Caption +' +UN';
      if connectivity.OpenMasterdata_OAuthClientSecretRequired then
        Label14.Caption := Label14.Caption +' +CS';

      Edit6.Text := connectivity.OpenMasterdata_OAuthURL;
      Edit7.Text := connectivity.OpenMasterdata_bySupplierPIDURL;
      Edit8.Text := connectivity.OpenMasterdata_byManufacturerDataURL;
      Edit9.Text := connectivity.OpenMasterdata_byGTINURL;

      OpenMasterdataConfigurationAsText := '['+ListView1.Selected.SubItems[2]+']'+#13#10+
               'Username='+Edit4.Text+#13#10+
               'Password='+Edit5.Text+#13#10+
               'Customernumber='+Edit3.Text+#13#10+
               'ClientID='+#13#10+
               'ClientSecret='+#13#10+
               'ClientScope='+#13#10+
               'GrantType='+#13#10+
               'UsernameRequired='+BoolToStr(connectivity.OpenMasterdata_OAuthUsernameRequired,true)+#13#10+
               'CustomernumberRequired='+BoolToStr(connectivity.OpenMasterdata_OAuthCustomernumberRequired,true)+#13#10+
               'ClientSecretRequired='+BoolToStr(connectivity.OpenMasterdata_OAuthClientSecretRequired,true)+#13#10+
               'OAuthURL='+connectivity.OpenMasterdata_OAuthURL+#13#10+
               'BySupplierPIDURL='+connectivity.OpenMasterdata_bySupplierPIDURL+#13#10+
               'ByManufacturerDataURL='+connectivity.OpenMasterdata_byManufacturerDataURL+#13#10+
               'ByGTINURL='+connectivity.OpenMasterdata_byGTINURL+#13#10+
               'ArtNoAsCommatext=';
    end else
      Label14.Caption := 'nicht verfuegbar';

  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.Button4Click(Sender: TObject);
begin
  Clipboard.AsText := OpenMasterdataConfigurationAsText;
  ShowMessage(OpenMasterdataConfigurationAsText);
end;

procedure TMainForm.Button5Click(Sender: TObject);
begin
  Clipboard.AsText := IDSConnectConfigurationAsText;
  ShowMessage(IDSConnectConfigurationAsText);
end;

procedure TMainForm.Label10Click(Sender: TObject);
begin
  ShellExecute(0,'open',PChar('https://github.com/LandrixSoftware/IDSConnect-for-Delphi'),'','',SW_SHOWNORMAL);
end;

procedure TMainForm.Label20Click(Sender: TObject);
begin
  ShellExecute(0,'open',PChar('https://github.com/LandrixSoftware/OpenMasterdata-for-Delphi'),'','',SW_SHOWNORMAL);
end;

end.
