{* Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.}

unit intf.OpenConnect;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  TOpenConnectSupplier = class(TObject)
  public
    ID        : Integer;
    Name      : string;
    Street    : string;
    Zip       : string;
    City      : string;
    Country   : string;
    ServiceURL: String;
    CustomerNumberRequired : Boolean;
    UsernameRequired : Boolean;
    PasswordRequired : Boolean;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
	  procedure AssignTo(_Dest : TOpenConnectSupplier);
  	function  Duplicate : TOpenConnectSupplier;
  end;

  TOpenConnectSupplierList = class(TObjectList<TOpenConnectSupplier>)
	  procedure AssignTo(_Dest : TOpenConnectSupplierList);
  	function  Duplicate : TOpenConnectSupplierList;
    function  GetItemBySupplierID(const _ID : Integer) : TOpenConnectSupplier;
  end;

  TOpenConnectBusiness = class(TObject)
  public
    ID : Integer;
    Description : String;
    ServiceURL : String;
    Supplier : TOpenConnectSupplierList;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
	  procedure AssignTo(_Dest : TOpenConnectBusiness);
  	function  Duplicate : TOpenConnectBusiness;
  end;

  TOpenConnectBusinessList = class(TObjectList<TOpenConnectBusiness>)
	  procedure AssignTo(_Dest : TOpenConnectBusinessList);
  	function  Duplicate : TOpenConnectBusinessList;
    function  GetItemByBusiness(const _ID : Integer;const _ServiceURL : String; _CreateIfNotExists : Boolean = false) : TOpenConnectBusiness;
  end;

  TOpenConnectLoginOptions = record
    SupplierID : Integer;
    CustomerNo : String;
    Username : String;
    Password : String;
    ServiceURL : String;
  end;

  TOpenConnectConnectivityOptions = record
    DatanormOnlineAvailable : Boolean;
    IDSConnectAvailable : Boolean;
    IDSConnectURL : String;
    IDSConnectSupportedProcesses : String;
    OpenMasterdataAvailable : Boolean;
    OpenMasterdata_OAuthURL : String;
    OpenMasterdata_OAuthCustomernumberRequired : Boolean;
    OpenMasterdata_OAuthUsernameRequired : Boolean;
    OpenMasterdata_OAuthClientSecretRequired : Boolean;
    OpenMasterdata_bySupplierPIDURL : String;
    OpenMasterdata_byManufacturerDataURL : String;
    OpenMasterdata_byGTINURL : String;
  public
    procedure Clear;
    function Support_IDSConnectWKEProcess : Boolean;
    function Support_IDSConnectWKSProcess : Boolean;
    function Support_IDSConnectADLProcess : Boolean;
  end;

  TOpenConnectDatanormFile = class
  public
    Text : String;
    FileID : Cardinal;
    FileURL : String;
    FileSize : Int64;
    FileName : String;
    FileDate : TDateTime;
    HttpAuthActiv    : Boolean;
    HttpAuthUsername : String;
    HttpAuthPassword : String;
    CookieActiv : Boolean;
    Cookie : TStringList;
  public
    procedure Clear;
    constructor Create;
    destructor Destroy; override;
  end;

  TOpenConnectDatanormFileList = class(TObjectList<TOpenConnectDatanormFile>)
  end;

  TOpenConnectSOAPRequestCapture = class(TObject)
  public
    RequestBody : String;
    procedure BeforeExecute(const MethodName: string; SOAPRequest: TStream);
  end;

  TOpenConnectHelper = class(TObject)
  public const
    SHKCONNECT_VERSION = '2.0';

    SHKCONNECT_SERVICE_ARGE  = 'https://arge20.shk-connect.de';
    SHKCONNECT_SERVICE_SHKGH = 'https://shkgh20.shk-connect.de';
    SHKCONNECT_SERVICE_OC    = 'https://o-connect.de';

    SHKCONNECT_SERVICE_PROC_BL  = '/services/Branchenliste';
    SHKCONNECT_SERVICE_PROC_AA  = '/services/AllgemeineAuskuenfte';
    SHKCONNECT_SERVICE_PROC_AIA = '/services/AnwenderIndividuelleAuskuenfte';
  strict private
    class var FLastSOAPRequest : String;
    class var FLastSOAPRequestLock : TObject;
    class function GetLastSOAPRequest : String; static;
    class procedure SetLastSOAPRequest(const _Value : String); static;
  public
    //HTTP-Timeouts in Millisekunden fuer alle SOAP-Aufrufe
    class var HTTPConnectTimeout : Integer;
    class var HTTPSendTimeout : Integer;
    class var HTTPReceiveTimeout : Integer;

    class constructor Create;
    class destructor Destroy;
    //Request-Body des letzten AnwenderIndividuelleAuskuenfte-Aufrufs,
    //Passwoerter maskiert - zur Fehlersuche bei Authentifizierungsproblemen
    class property LastSOAPRequest : String read GetLastSOAPRequest write SetLastSOAPRequest;
    //Fehler werden nicht mehr angezeigt, sondern an _Errors angehaengt (falls uebergeben)
    class function GetSupplierList(_ResultList : TOpenConnectBusinessList; _Errors : TStrings = nil) : Boolean;
    class function GetDatanormFileList(_LoginOptions : TOpenConnectLoginOptions; _ResultList : TOpenConnectDatanormFileList; _Errors : TStrings = nil) : Boolean;
    class function CheckConnectivitiy(_LoginOptions : TOpenConnectLoginOptions; out _Connectivity : TOpenConnectConnectivityOptions; _Errors : TStrings = nil) : Boolean;
    class function GetErrorCodeAsString(_ErrorNumber : Integer) : String;
    class function MaskPasswords(const _SOAPBody : String) : String;
  end;

implementation

uses
  Soap.SOAPHTTPClient, System.RegularExpressions
  ,intf.OpenConnectAllgemeineAuskuenfte
  ,intf.OpenConnectAnwenderIndividuelleAuskuenfte
  ,intf.OpenConnectBranchenliste;

{$I intf.OpenConnect.inc}

//Prozesscodes werden durch Leerzeichen getrennt gespeichert - tokenweiser
//Vergleich statt Substring-Suche, damit z.B. 'WK' nicht in 'WKE' matcht
function ContainsProcessToken(const _List, _Token : String) : Boolean;
var
  part : String;
begin
  Result := false;
  for part in _List.Split([' ']) do
  if SameText(part,_Token) then
    exit(true);
end;

//Serverdatum unabhaengig von den Systemeinstellungen parsen
//(ISO 8601 und deutsches Format, danach Fallback auf Systemeinstellungen)
function ParseServerDate(const _Value : String) : TDateTime;
var
  fs : TFormatSettings;
begin
  Result := 0;
  if _Value.Trim.IsEmpty then
    exit;
  fs := TFormatSettings.Create;
  fs.DateSeparator := '-';
  fs.ShortDateFormat := 'yyyy-mm-dd';
  if TryStrToDate(_Value,Result,fs) then
    exit;
  fs.DateSeparator := '.';
  fs.ShortDateFormat := 'dd.mm.yyyy';
  if TryStrToDate(_Value,Result,fs) then
    exit;
  Result := StrToDateDef(_Value,0);
end;

procedure AddError(_Errors : TStrings; const _Message : String);
begin
  if _Errors <> nil then
    _Errors.Add(_Message);
end;

//THTTPRIO mit den konfigurierten Timeouts; gibt sich bei Owner=nil selbst
//frei, sobald die letzte Interface-Referenz auf das Bean freigegeben wird
function CreateConfiguredRIO : THTTPRIO;
begin
  Result := THTTPRIO.Create(nil);
  Result.HTTPWebNode.ConnectTimeout := TOpenConnectHelper.HTTPConnectTimeout;
  Result.HTTPWebNode.SendTimeout := TOpenConnectHelper.HTTPSendTimeout;
  Result.HTTPWebNode.ReceiveTimeout := TOpenConnectHelper.HTTPReceiveTimeout;
end;

//Status ist laut Schema optional und kann nil sein
function StatusText(_Status : intf.OpenConnectAnwenderIndividuelleAuskuenfte.Status) : String; overload;
begin
  if _Status <> nil then
    Result := _Status.Meldung
  else
    Result := 'Antwort ohne Statusinformation';
end;

function StatusText(_Status : intf.OpenConnectBranchenliste.Status) : String; overload;
begin
  if _Status <> nil then
    Result := _Status.Meldung
  else
    Result := 'Antwort ohne Statusinformation';
end;

function StatusText(_Status : intf.OpenConnectAllgemeineAuskuenfte.Status) : String; overload;
begin
  if _Status <> nil then
    Result := _Status.Meldung
  else
    Result := 'Antwort ohne Statusinformation';
end;

{ TOpenConnectSupplier }

procedure TOpenConnectSupplier.AssignTo(_Dest: TOpenConnectSupplier);
begin
  _Dest.ID := ID;
  _Dest.Name := Name;
  _Dest.Street := Street;
  _Dest.Zip :=  Zip;
  _Dest.City :=  City;
  _Dest.Country :=  Country;
  _Dest.ServiceURL := ServiceURL;
  _Dest.CustomerNumberRequired := CustomerNumberRequired;
  _Dest.UsernameRequired := UsernameRequired;
  _Dest.PasswordRequired := PasswordRequired;
end;

procedure TOpenConnectSupplier.Clear;
begin
  ID := -1;
  Name := '';
  Street := '';
  Zip := '';
  City := '';
  Country := '';
  ServiceURL := '';
  CustomerNumberRequired := false;
  UsernameRequired := false;
  PasswordRequired := false;
end;

function TOpenConnectSupplier.Duplicate: TOpenConnectSupplier;
begin
  Result := TOpenConnectSupplier.Create;
  AssignTo(Result);
end;

constructor TOpenConnectSupplier.Create;
begin
  Clear;
end;

destructor TOpenConnectSupplier.Destroy;
begin
  inherited;
end;

{ TOpenConnectSupplierList }

function TOpenConnectSupplierList.GetItemBySupplierID(
  const _ID: Integer): TOpenConnectSupplier;
var
  i : Integer;
begin
  for i := 0 to Count-1 do
  if Items[i].ID = _ID then
    exit(Items[i]);
  Result := TOpenConnectSupplier.Create;
  Result.ID := _ID;
  Add(Result);
end;

procedure TOpenConnectSupplierList.AssignTo(_Dest: TOpenConnectSupplierList);
var
  i : Integer;
begin
  _Dest.Clear;
  for i := 0 to Count-1 do
    _Dest.Add(Items[i].Duplicate);
end;

function TOpenConnectSupplierList.Duplicate : TOpenConnectSupplierList;
begin
  Result := TOpenConnectSupplierList.Create;
  AssignTo(Result);
end;

{ TOpenConnectBusiness }

constructor TOpenConnectBusiness.Create;
begin
  Supplier := TOpenConnectSupplierList.Create;
  Clear;
end;

destructor TOpenConnectBusiness.Destroy;
begin
  if Assigned(Supplier) then begin Supplier.Free; Supplier := nil; end;
  inherited;
end;

procedure TOpenConnectBusiness.AssignTo(_Dest: TOpenConnectBusiness);
begin
  _Dest.ID := ID;
  _Dest.Description := Description;
  _Dest.ServiceURL := ServiceURL;
  Supplier.AssignTo(_Dest.Supplier);
end;

procedure TOpenConnectBusiness.Clear;
begin
  ID := -1;
  Description := '';
  ServiceURL := '';
  Supplier.Clear;
end;

function TOpenConnectBusiness.Duplicate: TOpenConnectBusiness;
begin
  Result := TOpenConnectBusiness.Create;
  AssignTo(Result);
end;

{ TOpenConnectBusinessList }

function TOpenConnectBusinessList.GetItemByBusiness(const _ID: Integer;
  const _ServiceURL : String; _CreateIfNotExists: Boolean): TOpenConnectBusiness;
var
  i : Integer;
begin
  REsult := nil;
  for I := 0 to Count - 1 do
  if (Items[i].ID = _ID) and SameText(Items[i].ServiceURL,_ServiceURL) then
  begin
    Result := Items[i];
    break;
  end;
  if (Result = nil) and (_CreateIfNotExists) then
  begin
    Result := TOpenConnectBusiness.Create;
    Result.ID := _ID;
    Result.ServiceURL := _ServiceURL;
    Add(Result);
  end;
end;

procedure TOpenConnectBusinessList.AssignTo(_Dest: TOpenConnectBusinessList);
var
  i : Integer;
begin
  _Dest.Clear;
  for i := 0 to Count-1 do
    _Dest.Add(Items[i].Duplicate);
end;

function TOpenConnectBusinessList.Duplicate : TOpenConnectBusinessList;
begin
  Result := TOpenConnectBusinessList.Create;
  AssignTo(Result);
end;

{ TOpenConnectSOAPRequestCapture }

procedure TOpenConnectSOAPRequestCapture.BeforeExecute(const MethodName: string; SOAPRequest: TStream);
var
  ss : TStringStream;
begin
  ss := TStringStream.Create('',TEncoding.UTF8);
  try
    SOAPRequest.Position := 0;
    ss.CopyFrom(SOAPRequest,0);
    RequestBody := ss.DataString;
  finally
    ss.Free;
  end;
  SOAPRequest.Position := 0;
end;

{ TOpenConnectHelper }

class constructor TOpenConnectHelper.Create;
begin
  FLastSOAPRequestLock := TObject.Create;
  HTTPConnectTimeout := 30000;
  HTTPSendTimeout := 60000;
  HTTPReceiveTimeout := 60000;
end;

class destructor TOpenConnectHelper.Destroy;
begin
  FreeAndNil(FLastSOAPRequestLock);
end;

class function TOpenConnectHelper.GetLastSOAPRequest: String;
begin
  System.TMonitor.Enter(FLastSOAPRequestLock);
  try
    Result := FLastSOAPRequest;
    UniqueString(Result);
  finally
    System.TMonitor.Exit(FLastSOAPRequestLock);
  end;
end;

class procedure TOpenConnectHelper.SetLastSOAPRequest(const _Value: String);
begin
  System.TMonitor.Enter(FLastSOAPRequestLock);
  try
    FLastSOAPRequest := _Value;
    UniqueString(FLastSOAPRequest);
  finally
    System.TMonitor.Exit(FLastSOAPRequestLock);
  end;
end;

class function TOpenConnectHelper.MaskPasswords(const _SOAPBody: String): String;

  //maskiert alle Vorkommen, auch mit Namespace-Praefix oder Attributen
  function MaskTag(const _Body, _TagName : String) : String;
  begin
    Result := TRegEx.Replace(_Body,
      '(<(?:[A-Za-z0-9_.-]+:)?'+_TagName+'(?:\s[^>]*)?>).*?(</(?:[A-Za-z0-9_.-]+:)?'+_TagName+'>)',
      '$1***$2',[roSingleLine]);
  end;

begin
  Result := MaskTag(_SOAPBody,'Softwarepasswort');
  Result := MaskTag(Result,'Passwort');
end;

class function TOpenConnectHelper.GetDatanormFileList(
  _LoginOptions: TOpenConnectLoginOptions;
  _ResultList: TOpenConnectDatanormFileList; _Errors : TStrings): Boolean;
var
  aia_gb : GetIndividuelleAuskunft;
  aia_b : AnwenderIndividuelleAuskuenfteBean;
  aia_resp : GetIndividuelleAuskunftAntwort;
  aia_p : Prozess;
  aia_l : Link;
  aia_c : String;//Cookie;
  serviceURL : String;
  dof : TOpenConnectDatanormFile;
  rio : THTTPRIO;
  soapCapture : TOpenConnectSOAPRequestCapture;
begin
  Result := false;

  if _ResultList = nil then
    exit;

  try
    serviceURL := _LoginOptions.ServiceURL;
    if String.StartsText('http://',serviceURL) then
      serviceURL := serviceURL.Insert(4,'s');

    aia_gb := GetIndividuelleAuskunft.Create;
    soapCapture := TOpenConnectSOAPRequestCapture.Create;
    aia_b := nil;
    aia_resp := nil;
    try
      aia_gb.Schnittstellenversion := TOpenConnectHelper.SHKCONNECT_VERSION;
      aia_gb.Softwarename := OPENCONNECT_LOGIN;
      aia_gb.Softwarepasswort := OPENCONNECT_PASSWORD;
      aia_gb.UnternehmensID := _LoginOptions.SupplierID;
      //Leere Felder nicht als leere XML-Elemente uebertragen, da einige
      //Unternehmen vorhandene, aber leere Zugangsdaten-Elemente ablehnen
      if not _LoginOptions.CustomerNo.Trim.IsEmpty then
        aia_gb.Kundennummer := _LoginOptions.CustomerNo.Trim;
      if not _LoginOptions.Username.Trim.IsEmpty then
        aia_gb.Benutzername := _LoginOptions.Username.Trim;
      if not _LoginOptions.Password.Trim.IsEmpty then
        aia_gb.Passwort := _LoginOptions.Password.Trim;

      rio := CreateConfiguredRIO;
      rio.OnBeforeExecute := soapCapture.BeforeExecute;
      aia_b := GetAnwenderIndividuelleAuskuenfteBean(false,serviceURL+SHKCONNECT_SERVICE_PROC_AIA,rio);
      aia_resp := aia_b.GetIndividuelleAuskunft(aia_gb);
      LastSOAPRequest := MaskPasswords(soapCapture.RequestBody);

      if (aia_resp.Status <> nil) and (aia_resp.Status.Code = '0') then
      begin
        for aia_p in aia_resp.Prozessliste do
        if SameText(aia_p.Prozesscode,'STD') then
        begin
          for aia_l in aia_p.Link do
          begin
            dof := TOpenConnectDatanormFile.Create;
            _ResultList.Add(dof);
            dof.Text := aia_l.Beschreibung + ' '+aia_l.AenderungsInfo;
            //dof.FileID := aia_l.Beschreibung;
            dof.FileURL := aia_l.URL;
            dof.FileName := aia_l.Dateiname_org;
            dof.FileDate := ParseServerDate(aia_l.DatenDatum);
            dof.FileSize := aia_l.Groesse;
            if aia_l.Authentifizierungsmethode = Authentifizierungsmethode.HTTPAUTH then
            begin
              dof.HttpAuthActiv := true;
              dof.HttpAuthUsername := _LoginOptions.Username.Trim;
              dof.HttpAuthPassword := _LoginOptions.Password.Trim;
            end
            else
            if aia_l.Authentifizierungsmethode = Authentifizierungsmethode.URL then
            begin
              dof.HttpAuthActiv := false;
            end
            else
            if aia_l.Authentifizierungsmethode = Authentifizierungsmethode.COOKIE then
            begin
              dof.CookieActiv := true;
              for aia_c in aia_l.CookieList do
              begin
                dof.Cookie.Add(aia_c);
              end;
              //URL, , KEINE,
            end;
          end;
        end;
        //_ResultList.SortByDate;
        Result := true;
      end else
        AddError(_Errors,serviceURL+SHKCONNECT_SERVICE_PROC_AIA+#10+StatusText(aia_resp.Status)+#10#10+
          'Gesendeter SOAP-Request (Passwort maskiert):'+#10+LastSOAPRequest);
    finally
      aia_resp.Free;
      aia_b := nil; //gibt das RIO frei, danach darf erst soapCapture freigegeben werden
      soapCapture.Free;
      aia_gb.Free;
    end;
  except
    on E:Exception do begin AddError(_Errors,serviceURL+SHKCONNECT_SERVICE_PROC_AIA+#10+e.Message+' ('+e.ClassName+')'); exit; end;
  end;
end;

class function TOpenConnectHelper.GetErrorCodeAsString(
  _ErrorNumber: Integer): String;
begin
  case _ErrorNumber of
    0 : Result := 'Es ist kein Fehler aufgetreten.';
    1 : Result := 'Fehler bei der Authentifizierung der anfragenden Software.';
    2 : Result := 'Der angefragte Prozess existiert nicht im SHK Connect Server.';
    3 : Result := 'Das angefragte Unternehmen existiert nicht im SHK Connect Server.';
    4 : Result := 'Fehler bei der Authentifizierung des Anwenders beim Unternehmen.';
    5 : Result := 'Angefragte Branche existiert nicht.';
    6 : Result := 'Angefragte PLZ aus der Umkreissuche existiert nicht.';
    7 : Result := 'Fehler bei der Kommunikation mit dem angefragten Unternehmen.';
    9 : Result := 'Fehlerhafte Anfrage (z.B. Pflichtfelder in der Anfrage fehlen)';
    10 : Result := 'Testantwort';
    else Result := 'Unbekannter Fehler (Code '+IntToStr(_ErrorNumber)+').';
  end;
end;

class function TOpenConnectHelper.GetSupplierList(_ResultList: TOpenConnectBusinessList; _Errors : TStrings): Boolean;
var
  aa_gb : GetAllgemeineAuskunft;
  aa_b : AllgemeineAuskuenfteBean;
  aa_resp : GetAllgemeineAuskunftAntwort;
  aa_u : Unternehmen;

  i : Integer;

  supplierItm : TOpenConnectSupplier;
  anySuccess : Boolean;

  procedure LoadBranchenliste(const _ServiceURL : String);
  var
    bl_gb : GetBranchenListe;
    bl_b : BranchenlisteBean;
    bl_resp : GetBranchenListeAntwort;
    bl_br : Branche;
    businessItm : TOpenConnectBusiness;
  begin
    try
      bl_gb := GetBranchenListe.Create;
      bl_b := nil;
      bl_resp := nil;
      try
        bl_gb.Schnittstellenversion := TOpenConnectHelper.SHKCONNECT_VERSION;
        bl_gb.Softwarename := OPENCONNECT_LOGIN;
        bl_gb.Softwarepasswort := OPENCONNECT_PASSWORD;

        bl_b := GetBranchenlisteBean(false,_ServiceURL+SHKCONNECT_SERVICE_PROC_BL,CreateConfiguredRIO);
        bl_resp := bl_b.GetBranchenListe(bl_gb);

        if (bl_resp.Status <> nil) and (bl_resp.Status.Code = '0') then
        begin
          for bl_br in bl_resp.Branche do
          begin
            businessItm := _ResultList.GetItemByBusiness(bl_br.ID,_ServiceURL,true);
            businessItm.Description := bl_br.Name_;
          end;
          anySuccess := true;
        end else
          AddError(_Errors,_ServiceURL+SHKCONNECT_SERVICE_PROC_BL+#10+StatusText(bl_resp.Status));
      finally
        bl_resp.Free;
        bl_b := nil;
        bl_gb.Free;
      end;
    except
      //Server nicht erreichbar - restliche Dienste trotzdem abfragen
      on E:Exception do
        AddError(_Errors,_ServiceURL+SHKCONNECT_SERVICE_PROC_BL+#10+E.Message+' ('+E.ClassName+')');
    end;
  end;

begin
  Result := false;

  if _ResultList = nil then
    exit;

  anySuccess := false;

  LoadBranchenliste(SHKCONNECT_SERVICE_ARGE);
  LoadBranchenliste(SHKCONNECT_SERVICE_SHKGH);
  LoadBranchenliste(SHKCONNECT_SERVICE_OC);

  try
    aa_gb := GetAllgemeineAuskunft.Create;
    try
      aa_gb.Schnittstellenversion := TOpenConnectHelper.SHKCONNECT_VERSION;

      aa_gb.Softwarename := OPENCONNECT_LOGIN;
      aa_gb.Softwarepasswort := OPENCONNECT_PASSWORD;

      for i := 0 to _ResultList.Count - 1 do
      begin
        aa_gb.BrancheID := IntToStr(_ResultList[i].ID);

        try
          aa_b := nil;
          aa_resp := nil;
          try
            aa_b := GetAllgemeineAuskuenfteBean(false,_ResultList[i].ServiceURL+SHKCONNECT_SERVICE_PROC_AA,CreateConfiguredRIO);
            aa_resp := aa_b.GetAllgemeineAuskunft(aa_gb);

            if (aa_resp.Status <> nil) and (aa_resp.Status.Code = '0') then
            begin
              for aa_u in aa_resp.Unternehmen do
              begin
                supplierItm := _ResultList[i].Supplier.GetItemBySupplierID(aa_u.ID);
                supplierItm.Name := aa_u.Name_;
                supplierItm.Street := aa_u.Strasse;
                supplierItm.Zip := aa_u.PLZ;
                supplierItm.City := aa_u.Ort;
                supplierItm.Country := aa_u.Land;
                supplierItm.ServiceURL := _ResultList[i].ServiceURL;
                supplierItm.CustomerNumberRequired := aa_u.Kundennummer_erforderlich;
                supplierItm.UsernameRequired := aa_u.Benutzername_erforderlich;
                supplierItm.PasswordRequired := aa_u.Passwort_erforderlich;
              end;
            end else
              AddError(_Errors,_ResultList[i].ServiceURL+SHKCONNECT_SERVICE_PROC_AA+#10+StatusText(aa_resp.Status));
          finally
            aa_resp.Free;
            aa_b := nil;
          end;
        except
          //einzelner Dienst nicht erreichbar - restliche trotzdem abfragen
          on E:Exception do
            AddError(_Errors,_ResultList[i].ServiceURL+SHKCONNECT_SERVICE_PROC_AA+#10+E.Message+' ('+E.ClassName+')');
        end;
      end;
    finally
      aa_gb.Free;
    end;
  except
    on E:Exception do
      AddError(_Errors,'GetAllgemeineAuskunft'+#10+E.Message+' ('+E.ClassName+')');
  end;

  //true nur, wenn mindestens eine Branchenliste erfolgreich geladen wurde
  Result := anySuccess;
end;

class function TOpenConnectHelper.CheckConnectivitiy(_LoginOptions: TOpenConnectLoginOptions;
  out _Connectivity : TOpenConnectConnectivityOptions; _Errors : TStrings): Boolean;
var
  aia_gb : GetIndividuelleAuskunft;
  aia_b : AnwenderIndividuelleAuskuenfteBean;
  aia_resp : GetIndividuelleAuskunftAntwort;
  aia_p : Prozess;
  aia_tp : String;//Teilprozess
  rio : THTTPRIO;
  soapCapture : TOpenConnectSOAPRequestCapture;
  serviceURL : String;
begin
  Result := false;

  _Connectivity.Clear;

  //Zugangsdaten duerfen komplett leer sein - es gibt Unternehmen, bei denen
  //weder Kundennummer noch Benutzername noch Passwort erforderlich sind
  if _LoginOptions.ServiceURL.IsEmpty then
    exit;
  if _LoginOptions.SupplierID = 0 then
    exit;

  serviceURL := _LoginOptions.ServiceURL;
  if String.StartsText('http://',serviceURL) then
    serviceURL := serviceURL.Insert(4,'s');

  aia_gb := GetIndividuelleAuskunft.Create;
  soapCapture := TOpenConnectSOAPRequestCapture.Create;
  aia_b := nil;
  aia_resp := nil;
  try
  try
    aia_gb.Schnittstellenversion := TOpenConnectHelper.SHKCONNECT_VERSION;
    aia_gb.Softwarename := OPENCONNECT_LOGIN;
    aia_gb.Softwarepasswort := OPENCONNECT_PASSWORD;
    aia_gb.UnternehmensID := _LoginOptions.SupplierID;
    //Leere Felder nicht als leere XML-Elemente uebertragen, da einige
    //Unternehmen vorhandene, aber leere Zugangsdaten-Elemente ablehnen
    if not _LoginOptions.CustomerNo.Trim.IsEmpty then
      aia_gb.Kundennummer := _LoginOptions.CustomerNo.Trim;
    if not _LoginOptions.Username.Trim.IsEmpty then
      aia_gb.Benutzername := _LoginOptions.Username.Trim;
    if not _LoginOptions.Password.Trim.IsEmpty then
      aia_gb.Passwort := _LoginOptions.Password.Trim;

    rio := CreateConfiguredRIO;
    rio.OnBeforeExecute := soapCapture.BeforeExecute;
    aia_b := GetAnwenderIndividuelleAuskuenfteBean(false,serviceURL+SHKCONNECT_SERVICE_PROC_AIA,rio);
    aia_resp := aia_b.GetIndividuelleAuskunft(aia_gb);
    LastSOAPRequest := MaskPasswords(soapCapture.RequestBody);

    if (aia_resp.Status <> nil) and (aia_resp.Status.Code = '0') then
    begin
      for aia_p in aia_resp.Prozessliste do
        if SameText(aia_p.Prozesscode,'STD') then
        begin
          _Connectivity.DatanormOnlineAvailable := true;
        end else
        if SameText(aia_p.Prozesscode,'SHA') then
        begin
          //Viele liefern mehrere SHA, je nachdem, welche IDS-Connect-Version
          //unterst�tzt werden. Allerdings geben sie keine Versionsnummer an
          _Connectivity.IDSConnectAvailable := true;
          _Connectivity.IDSConnectURL := aia_p.URL;

          for aia_tp in aia_p.Teilprozesse do
          if not ContainsProcessToken(_Connectivity.IDSConnectSupportedProcesses,aia_tp) then
            _Connectivity.IDSConnectSupportedProcesses := Trim(_Connectivity.IDSConnectSupportedProcesses+' '+aia_tp);
        end else
        if SameText(aia_p.Prozesscode,'OMD-oauth') then
        begin
          _Connectivity.OpenMasterdataAvailable := true;
          _Connectivity.OpenMasterdata_OAuthURL := aia_p.URL;
          for aia_tp in aia_p.Teilprozesse do
          if SameText(aia_tp,'OMD-oauth-Username') then
            _Connectivity.OpenMasterdata_OAuthUsernameRequired := true
          else
          if SameText(aia_tp,'OMD-oauth-Customernumber') then
            _Connectivity.OpenMasterdata_OAuthCustomernumberRequired := true
          else
          if SameText(aia_tp,'OMD-oauth-ClientSecret') then
            _Connectivity.OpenMasterdata_OAuthClientSecretRequired := true;
        end else
        if SameText(aia_p.Prozesscode,'OMD-1-0-5-bySupplierPID') then
        begin
          _Connectivity.OpenMasterdata_bySupplierPIDURL := aia_p.URL;
        end else
        if SameText(aia_p.Prozesscode,'OMD-1-0-5-byManufacturerData') then
        begin
          _Connectivity.OpenMasterdata_byManufacturerDataURL := aia_p.URL;
        end else
        if SameText(aia_p.Prozesscode,'OMD-1-0-5-byGtin') then
        begin
          _Connectivity.OpenMasterdata_byGTINURL := aia_p.URL;
        end;
      Result := true;
    end else
      AddError(_Errors,serviceURL+SHKCONNECT_SERVICE_PROC_AIA+#10+StatusText(aia_resp.Status)+#10#10+
        'Gesendeter SOAP-Request (Passwort maskiert):'+#10+LastSOAPRequest);
  finally
    aia_resp.Free;
    aia_b := nil; //gibt das RIO frei, danach darf erst soapCapture freigegeben werden
    soapCapture.Free;
    aia_gb.Free;
  end;
  except
    on E:Exception do
      AddError(_Errors,serviceURL+SHKCONNECT_SERVICE_PROC_AIA+#10+E.Message+' ('+E.ClassName+')');
  end;
end;

{ TOpenConnectConnectivityOptions }

procedure TOpenConnectConnectivityOptions.Clear;
begin
  DatanormOnlineAvailable := false;
  IDSConnectAvailable := false;
  IDSConnectURL := '';
  IDSConnectSupportedProcesses := '';
  OpenMasterdataAvailable := false;
  OpenMasterdata_OAuthURL := '';
  OpenMasterdata_OAuthCustomernumberRequired := false;
  OpenMasterdata_OAuthUsernameRequired := false;
  OpenMasterdata_OAuthClientSecretRequired := false;
  OpenMasterdata_bySupplierPIDURL := '';
  OpenMasterdata_byManufacturerDataURL := '';
  OpenMasterdata_byGTINURL := '';
end;

function TOpenConnectConnectivityOptions.Support_IDSConnectADLProcess: Boolean;
begin
  Result := IDSConnectAvailable and ContainsProcessToken(IDSConnectSupportedProcesses,'ADL');
end;

function TOpenConnectConnectivityOptions.Support_IDSConnectWKEProcess: Boolean;
begin
  Result := IDSConnectAvailable and ContainsProcessToken(IDSConnectSupportedProcesses,'WKE');
end;

function TOpenConnectConnectivityOptions.Support_IDSConnectWKSProcess: Boolean;
begin
  Result := IDSConnectAvailable and ContainsProcessToken(IDSConnectSupportedProcesses,'WKS');
end;

{ TOpenConnectDatanormFile }

constructor TOpenConnectDatanormFile.Create;
begin
  Cookie := TStringList.Create;
  Clear;
end;

destructor TOpenConnectDatanormFile.Destroy;
begin
  if Assigned(Cookie) then begin Cookie.Free; Cookie := nil; end;
  inherited;
end;

procedure TOpenConnectDatanormFile.Clear;
begin
  FileID := 0;
  FileURL := '';
  FileSize := 0;
  FileName := '';
  FileDate := 0;
  Text := '';
  HttpAuthActiv := false;
  HttpAuthUsername := '';
  HttpAuthPassword := '';
  CookieActiv := false;
  Cookie.Clear;
end;

end.

