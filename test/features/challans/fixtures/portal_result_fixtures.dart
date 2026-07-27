/// Static HTML fixtures approximating the Bihar e-Pass "View Pass Details"
/// result page across the layouts the parser must tolerate.
///
/// These are hand-written approximations used purely to exercise the parser.
/// Tests never contact the live government portal.
class PortalFixtures {
  const PortalFixtures._();

  /// Layer 1 target: ASP.NET label controls with generated id prefixes.
  static const aspNetLabelIds = '''
<html><body>
<form id="form1">
  <div class="panel">
    <h3>e-Pass Details</h3>
    <table>
      <tr>
        <td><span id="ctl00_ContentPlaceHolder1_lblChallanNo">BR2026001234</span></td>
        <td><span id="ctl00_ContentPlaceHolder1_lblUIDNo">UID-88112</span></td>
      </tr>
      <tr>
        <td><span id="ctl00_ContentPlaceHolder1_lblChallanDate">12/05/2026 14:30</span></td>
        <td><span id="ctl00_ContentPlaceHolder1_lblValidity">13/05/2026 14:30</span></td>
      </tr>
      <tr>
        <td><span id="ctl00_ContentPlaceHolder1_lblVehicleNo">br 01 gh 4567</span></td>
        <td><span id="ctl00_ContentPlaceHolder1_lblVehicleType">Truck</span></td>
      </tr>
      <tr>
        <td><span id="ctl00_ContentPlaceHolder1_lblMineralName">Sand (Balu)</span></td>
        <td><span id="ctl00_ContentPlaceHolder1_lblQuantity">12.500 MT</span></td>
      </tr>
      <tr>
        <td><span id="ctl00_ContentPlaceHolder1_lblConsignorName">Bihar Minerals Pvt Ltd</span></td>
        <td><span id="ctl00_ContentPlaceHolder1_lblConsigneeName">Navdream Infra</span></td>
      </tr>
      <tr>
        <td><span id="ctl00_ContentPlaceHolder1_lblLocation">Patna Ghat 4</span></td>
        <td><span id="ctl00_ContentPlaceHolder1_lblDestination">Gaya Site</span></td>
      </tr>
    </table>
  </div>
</form>
</body></html>
''';

  /// Layer 2 target: English label/value table rows, no useful ids.
  static const englishLabelRows = '''
<html><body>
<h2>Challan Details</h2>
<table class="table table-bordered">
  <tr><td>Challan No.</td><td>:</td><td>BR2026009999</td></tr>
  <tr><td>UID No.</td><td>:</td><td>UID-55010</td></tr>
  <tr><td>Challan Date</td><td>:</td><td>01/07/2026 09:15 AM</td></tr>
  <tr><td>Challan Validity</td><td>:</td><td>02/07/2026 09:15 AM</td></tr>
  <tr><td>Consignor Name</td><td>:</td><td>Ganga   Stone   Works</td></tr>
  <tr><td>Challan Generate from</td><td>:</td><td>Mine Owner</td></tr>
  <tr><td>Location</td><td>:</td><td>Sone River Ghat</td></tr>
  <tr><td>Destination</td><td>:</td><td>Nalanda</td></tr>
  <tr><td>Vehicle Type</td><td>:</td><td>Hyva</td></tr>
  <tr><td>Vehicle No.</td><td>:</td><td>BR-02-XY-1122</td></tr>
  <tr><td>Mineral Name</td><td>:</td><td>Stone Chips</td></tr>
  <tr><td>Quantity</td><td>:</td><td>30 MT</td></tr>
  <tr><td>Consignee Name</td><td>:</td><td>Navdream Infra</td></tr>
</table>
</body></html>
''';

  /// Layer 2 target: Hindi labels only.
  static const hindiLabelRows = '''
<html><body>
<h2>ई-पास विवरण</h2>
<table>
  <tr><td>चालान नंबर</td><td>BR2026007777</td></tr>
  <tr><td>यूआईडी नंबर</td><td>UID-31415</td></tr>
  <tr><td>चालान की तिथि</td><td>15/06/2026</td></tr>
  <tr><td>चालान की वैधता</td><td>16/06/2026</td></tr>
  <tr><td>कंसाइनर का नाम</td><td>बिहार खनिज</td></tr>
  <tr><td>स्थान</td><td>सोन नदी</td></tr>
  <tr><td>गंतव्य</td><td>पटना</td></tr>
  <tr><td>वाहन का प्रकार</td><td>ट्रक</td></tr>
  <tr><td>वाहन नंबर</td><td>BR 03 AB 9090</td></tr>
  <tr><td>खनिज का नाम</td><td>बालू</td></tr>
  <tr><td>मात्रा</td><td>25.750 MT</td></tr>
  <tr><td>प्राप्तकर्ता का नाम</td><td>नवद्रीम इंफ्रा</td></tr>
</table>
</body></html>
''';

  /// Mixed bilingual markup with HTML entities and a Bootstrap-style layout.
  static const bilingualBootstrap = '''
<html><body>
<div class="card"><div class="card-header">e-Pass Details / ई-पास विवरण</div>
<div class="row"><label>Challan No. / चालान नंबर</label><span>BR2026005555</span></div>
<div class="row"><label>Challan Date / चालान की तिथि</label><span>20-06-2026</span></div>
<div class="row"><label>Vehicle No. / वाहन नंबर</label><span>BR&#45;04&nbsp;CD&nbsp;3344</span></div>
<div class="row"><label>Mineral Name / खनिज का नाम</label><span>Boulder &amp; Grit</span></div>
<div class="row"><label>Quantity / मात्रा</label><span>8.25 CUM</span></div>
<div class="row"><label>Consignee Name</label><span>Navdream&nbsp;Infra</span></div>
<div class="row"><label>Royalty Amount</label><span>&#8377; 1,250.50</span></div>
</div>
</body></html>
''';

  /// Layer 3 target: plain text pairs, no table or label markup at all.
  static const plainTextPairs = '''
<html><body>
<pre>
e-Pass Details
Challan No. : BR2026003333
Challan Date : 05/04/2026
Vehicle No. : BR05EF7788
Mineral Name : Brick
Quantity : 5000 Nos
Consignee Name : Navdream Infra
</pre>
</body></html>
''';

  /// Portal reported no record for the searched challan.
  static const noRecord = '''
<html><body>
<div class="alert alert-danger">No Record Found for the given Challan Number.</div>
</body></html>
''';

  /// The page before the user completed CAPTCHA and pressed Search.
  static const searchFormOnly = '''
<html><body>
<form>
  <h3>View Pass Details</h3>
  <label for="ddlFinYear">Financial Year</label>
  <select id="ctl00_ContentPlaceHolder1_ddlFinYear" name="ddlFinYear">
    <option value="2025-2026">2025-2026</option>
    <option value="2026-2027">2026-2027</option>
  </select>
  <label for="txtChallanNo">Challan Number</label>
  <input type="text" id="ctl00_ContentPlaceHolder1_txtChallanNo" name="txtChallanNo" value="" />
  <img id="imgCaptcha" src="Captcha.aspx" alt="captcha" />
  <input type="text" id="txtCaptcha" name="txtCaptcha" value="" />
  <input type="submit" id="btnSearch" value="Search" />
</form>
</body></html>
''';

  /// Result section present but the mandatory fields moved/renamed.
  static const layoutChangedPartial = '''
<html><body>
<h2>e-Pass Details</h2>
<table>
  <tr><td>Challan No.</td><td>BR2026001234</td></tr>
  <tr><td>Consignor Name</td><td>Bihar Minerals</td></tr>
  <tr><td>Destination</td><td>Gaya</td></tr>
  <tr><td>Some New Column</td><td>unexpected</td></tr>
</table>
</body></html>
''';

  /// A valid result for a *different* challan than the one requested.
  static const mismatchedChallan = '''
<html><body>
<h2>e-Pass Details</h2>
<table>
  <tr><td>Challan No.</td><td>BR2026000001</td></tr>
  <tr><td>Challan Date</td><td>12/05/2026</td></tr>
  <tr><td>Vehicle No.</td><td>BR01GH4567</td></tr>
  <tr><td>Mineral Name</td><td>Sand</td></tr>
  <tr><td>Quantity</td><td>10 MT</td></tr>
</table>
</body></html>
''';

  /// Quantity without any printed unit — the parser must not invent "MT".
  static const quantityWithoutUnit = '''
<html><body>
<h2>e-Pass Details</h2>
<table>
  <tr><td>Challan No.</td><td>BR2026004444</td></tr>
  <tr><td>Challan Date</td><td>10/05/2026</td></tr>
  <tr><td>Vehicle No.</td><td>BR06ZZ0001</td></tr>
  <tr><td>Mineral Name</td><td>Dust</td></tr>
  <tr><td>Quantity</td><td>18.400</td></tr>
</table>
</body></html>
''';

  /// Real page markup captured from the live portal, in its initial state.
  /// Every detail span ships with the literal text `NA`, which must be treated
  /// as absent — not as a value. This is the exact page that produced a
  /// misleading "missing challan date, quantity" error before the fix.
  static const realPortalUnsearched = '''
<html><body><div id="Panel1" style="color:Black;border-color:White;font-family:Verdana;font-size:11px;font-weight:bold;text-decoration:none;"><fieldset><legend> e-Pass Details </legend><table border="0" cellpadding="3" cellspacing="8"><tr><td> Challan No./चालान नंबर </td><td width="2px"> : </td><td><span id="lblchallanno" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td width="2px"> &nbsp; </td><td> &nbsp; </td></tr><tr><td> UID No./ यूआईडी नंबर</td><td width="2px"> :</td><td><span id="lblUIDNo" style="color:Blue;">NA</span></td><td class="style1"> &nbsp;</td><td width="2px"> &nbsp;</td><td> &nbsp;</td></tr><tr><td> Challan Date / चालान की तिथि </td><td width="2px"> : </td><td width="300px"><span id="lblchallandate" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td width="2px"> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Challan Validity/ चालान की वैधता</td><td width="2px"> :</td><td><span id="lblChallanValidity" style="color:Red;font-size:Medium;font-weight:bold;">NA</span></td><td class="style1"> &nbsp;</td><td width="2px"> &nbsp;</td><td> &nbsp;</td></tr><tr><td> Consigner Name / कंसाइनर का नाम </td><td width="10"> : </td><td><span id="lblconsignername" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Challan Generate from / चालान से उत्पन्न </td><td> : </td><td><span id="lbluser" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td width="10"> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Location / स्थान </td><td> : </td><td><span id="lbllocation" style="color:Blue;">NA</span></td><td class="style1"></td><td> &nbsp; </td><td></td></tr><tr><td> Destination / गंतव्य </td><td> : </td><td><span id="lbldestination" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Vehicle Type / वाहन का प्रकार </td><td> : </td><td><span id="lblVehicleType" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Vehicle No. / वाहन नंबर </td><td> : </td><td><span id="lblvehicleno" style="color:Red;font-size:Medium;font-weight:bold;">NA</span></td><td class="style1"></td><td> &nbsp; </td><td></td></tr><tr><td> Mineral Name / खनिज का नाम </td><td> : </td><td><span id="lblmineralname" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Quantity / मात्रा<span id="lblunit"></span></td><td> : </td><td><span id="lblquantity" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Consignee Name / प्राप्तकर्ता का नाम </td><td> : </td><td><span id="lblconsigneename" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr></table></fieldset></body></html>
''';

  /// The same real markup with a successful search result filled in.
  /// Note `lblunit` carries the quantity unit in a separate control, and
  /// "Challan Generate from" is rendered by `lbluser`.
  static const realPortalFilled = '''
<html><body><div id="Panel1" style="color:Black;border-color:White;font-family:Verdana;font-size:11px;font-weight:bold;text-decoration:none;"><fieldset><legend> e-Pass Details </legend><table border="0" cellpadding="3" cellspacing="8"><tr><td> Challan No./चालान नंबर </td><td width="2px"> : </td><td><span id="lblchallanno" style="color:Blue;">2413812606031238531</span></td><td class="style1"> &nbsp; </td><td width="2px"> &nbsp; </td><td> &nbsp; </td></tr><tr><td> UID No./ यूआईडी नंबर</td><td width="2px"> :</td><td><span id="lblUIDNo" style="color:Blue;">UID2026001</span></td><td class="style1"> &nbsp;</td><td width="2px"> &nbsp;</td><td> &nbsp;</td></tr><tr><td> Challan Date / चालान की तिथि </td><td width="2px"> : </td><td width="300px"><span id="lblchallandate" style="color:Blue;">26/07/2026 12:54:00 AM</span></td><td class="style1"> &nbsp; </td><td width="2px"> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Challan Validity/ चालान की वैधता</td><td width="2px"> :</td><td><span id="lblChallanValidity" style="color:Red;font-size:Medium;font-weight:bold;">27/07/2026 12:54:00 AM</span></td><td class="style1"> &nbsp;</td><td width="2px"> &nbsp;</td><td> &nbsp;</td></tr><tr><td> Consigner Name / कंसाइनर का नाम </td><td width="10"> : </td><td><span id="lblconsignername" style="color:Blue;">GANGA BALU SUPPLIERS</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Challan Generate from / चालान से उत्पन्न </td><td> : </td><td><span id="lbluser" style="color:Blue;">Mine Owner</span></td><td class="style1"> &nbsp; </td><td width="10"> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Location / स्थान </td><td> : </td><td><span id="lbllocation" style="color:Blue;">Madhubani Ghat 2</span></td><td class="style1"></td><td> &nbsp; </td><td></td></tr><tr><td> Destination / गंतव्य </td><td> : </td><td><span id="lbldestination" style="color:Blue;">Madhubani Bus Stand</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Vehicle Type / वाहन का प्रकार </td><td> : </td><td><span id="lblVehicleType" style="color:Blue;">Truck</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Vehicle No. / वाहन नंबर </td><td> : </td><td><span id="lblvehicleno" style="color:Red;font-size:Medium;font-weight:bold;">BR06GA1234</span></td><td class="style1"></td><td> &nbsp; </td><td></td></tr><tr><td> Mineral Name / खनिज का नाम </td><td> : </td><td><span id="lblmineralname" style="color:Blue;">sand</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Quantity / मात्रा<span id="lblunit">MT</span></td><td> : </td><td><span id="lblquantity" style="color:Blue;">2.000</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Consignee Name / प्राप्तकर्ता का नाम </td><td> : </td><td><span id="lblconsigneename" style="color:Blue;">NAVDREAM INFRA</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr></table></fieldset></body></html>
''';

  /// Real markup where the portal reports no record via its own `lblresult`
  /// message span while every detail span stays at `NA`.
  static const realPortalNoRecord = '''
<html><body><div align="center" class="mandatory"><span id="lblMsg" style="font-weight:bold;"></span></div><div align="center" style="color: red;"><span id="lblresult" style="font-size:11pt;font-weight:bold;">No Record Found</span></div><div id="Panel1" style="color:Black;border-color:White;font-family:Verdana;font-size:11px;font-weight:bold;text-decoration:none;"><fieldset><legend> e-Pass Details </legend><table border="0" cellpadding="3" cellspacing="8"><tr><td> Challan No./चालान नंबर </td><td width="2px"> : </td><td><span id="lblchallanno" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td width="2px"> &nbsp; </td><td> &nbsp; </td></tr><tr><td> UID No./ यूआईडी नंबर</td><td width="2px"> :</td><td><span id="lblUIDNo" style="color:Blue;">NA</span></td><td class="style1"> &nbsp;</td><td width="2px"> &nbsp;</td><td> &nbsp;</td></tr><tr><td> Challan Date / चालान की तिथि </td><td width="2px"> : </td><td width="300px"><span id="lblchallandate" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td width="2px"> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Challan Validity/ चालान की वैधता</td><td width="2px"> :</td><td><span id="lblChallanValidity" style="color:Red;font-size:Medium;font-weight:bold;">NA</span></td><td class="style1"> &nbsp;</td><td width="2px"> &nbsp;</td><td> &nbsp;</td></tr><tr><td> Consigner Name / कंसाइनर का नाम </td><td width="10"> : </td><td><span id="lblconsignername" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Challan Generate from / चालान से उत्पन्न </td><td> : </td><td><span id="lbluser" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td width="10"> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Location / स्थान </td><td> : </td><td><span id="lbllocation" style="color:Blue;">NA</span></td><td class="style1"></td><td> &nbsp; </td><td></td></tr><tr><td> Destination / गंतव्य </td><td> : </td><td><span id="lbldestination" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Vehicle Type / वाहन का प्रकार </td><td> : </td><td><span id="lblVehicleType" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Vehicle No. / वाहन नंबर </td><td> : </td><td><span id="lblvehicleno" style="color:Red;font-size:Medium;font-weight:bold;">NA</span></td><td class="style1"></td><td> &nbsp; </td><td></td></tr><tr><td> Mineral Name / खनिज का नाम </td><td> : </td><td><span id="lblmineralname" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Quantity / मात्रा<span id="lblunit"></span></td><td> : </td><td><span id="lblquantity" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr><tr><td> Consignee Name / प्राप्तकर्ता का नाम </td><td> : </td><td><span id="lblconsigneename" style="color:Blue;">NA</span></td><td class="style1"> &nbsp; </td><td> &nbsp; </td><td> &nbsp; </td></tr></table></fieldset></body></html>
''';

  /// Real Jharkhand Minerals Portal markup in its initial state: a Bootstrap grid
  /// (label and value live in SIBLING containers, not adjacent elements) with
  /// every value spans reading `NA`, plus the CAPTCHA controls.
  static const jharkhandUnsearched = '''
<html><body><div class="col-6"><input name="txtPassNo" type="text" id="txtPassNo" class="form-control" /><input name="txtCaptcha" type="text" id="txtCaptcha" class="form-control" /><img id="imgCaptcha" class="mt-3" src="../../GenerateCaptcha.aspx?Val=RNXQ89" /><input type="submit" name="btnRefresh" value="Refresh" id="btnRefresh" /><input type="submit" name="btnSearch" value="Search" id="btnSearch" /></div><div class="addTable"><div class="row"><div class="col-xl-2 form-group"><label class="form-label">Pass No. </label></div><div class="col-xl-4 form-group"><span id="lblchallanno">NA</span></div><div class="col-xl-2 form-group"><label class="form-label">Permit No. </label></div><div class="col-xl-4 form-group"><span id="lblPermitNo">NA</span></div><div class="col-xl-2 form-group"><label class="form-label">Challan Date </label></div><div class="col-xl-4 form-group"><span id="lblchallandate">NA</span></div><div class="col-xl-2 form-group"><label class="form-label">Consigner Name </label></div><div class="col-xl-4 form-group"><span id="lblconsigneename">NA</span></div><div class="col-xl-2 form-group"><label class="form-label">Challan Generate from </label></div><div class="col-xl-4 form-group"><span id="lbluser">NA</span></div><div class="col-xl-2 form-group"><label class="form-label">Location </label></div><div class="col-xl-4 form-group"><span id="lbllocation">NA</span></div><div class="col-xl-2 form-group"><label class="form-label">Destination </label></div><div class="col-xl-4 form-group"><span id="lbldestination">NA</span></div><div class="col-xl-2 form-group"><label class="form-label">Vehicle No. </label></div><div class="col-xl-4 form-group"><span id="lblvehicleno">NA</span></div><div class="col-xl-2 form-group"><label class="form-label">Mineral Name </label></div><div class="col-xl-4 form-group"><span id="lblmineralname">NA</span></div><div class="col-xl-2 form-group"><label class="form-label">Quantity </label></div><div class="col-xl-4 form-group"><span id="lblquantity">NA</span></div><div class="col-xl-2 form-group"><label class="form-label">Pass Validity </label></div><div class="col-xl-4 form-group"><span id="lblPassValidity">NA</span></div></div></div></div></div> </body></html>
''';

  /// The same real Jharkhand markup with a successful result filled in.
  ///
  /// Note the portal quirk: the "Consigner Name" value is rendered by a span
  /// called `lblconsigneename`, so a shared id map would file the consignor as
  /// the consignee.
  /// Real MP e-Khanij `Verify_eTP.aspx` form markup, captured from the live page
  /// after the "eTP No" search mode was selected.
  ///
  /// Everything here is verified against the portal: the `rbsearchtype` radio
  /// group (value 1 = eTP No, value 2 = Vehicle No), the numeric `txtetp` input
  /// capped at 10 characters, the `txtCaptcha` box beside `captcha.aspx`, the
  /// "Verify" submit button and the empty `pnlgridvehicle` result panel. On the
  /// very first load neither radio is checked and `txtetp` does not exist at
  /// all, which is why the prefill has to pick the mode first.
  static const mpEtpFormMarkup = '''
<html><body><div id="ctl00_ContentPlaceHolder1_Panel1"><div class="MultiPanel"><div class="row"><div class="col-lg-12 col-md-12"><div class="d-flex"><div class="col-lg-4 col-md-4"><span id="ctl00_ContentPlaceHolder1_lbletp" class="lbl">Search by:</span></div><div class="col-lg-8 col-md-8"><table id="ctl00_ContentPlaceHolder1_rbsearchtype" border="0"><tr><td><input id="ctl00_ContentPlaceHolder1_rbsearchtype_0" type="radio" name="ctl00\$ContentPlaceHolder1\$rbsearchtype" value="1" checked="checked" /><label for="ctl00_ContentPlaceHolder1_rbsearchtype_0">eTP No:</label></td><td><input id="ctl00_ContentPlaceHolder1_rbsearchtype_1" type="radio" name="ctl00\$ContentPlaceHolder1\$rbsearchtype" value="2" /><label for="ctl00_ContentPlaceHolder1_rbsearchtype_1">Vehicle No:</label></td></tr></table></div></div></div></div><div class="row"><div class="col-lg-12 col-md-12"><div class="d-flex"><div class="col-lg-4 col-md-4"><span id="ctl00_ContentPlaceHolder1_Label1" class="lbl">Enter eTP No:</span></div><div class="col-lg-4 col-md-4"><div class="form-group"><input name="ctl00\$ContentPlaceHolder1\$txtetp" type="text" maxlength="10" id="ctl00_ContentPlaceHolder1_txtetp" class="form-control" onkeypress="isNumber(this)" /></div></div><div id="ctl00_ContentPlaceHolder1_trcaptcha" class="col-lg-4 col-md-4"><div class="form-group"><input name="ctl00\$ContentPlaceHolder1\$txtCaptcha" type="text" id="ctl00_ContentPlaceHolder1_txtCaptcha" title="Enter Image Code!" class="form-control" placeholder="Enter Captcha" /><img alt="Catptcha Text" src="../AppPrevious/captcha.aspx" /></div></div></div></div></div><div class="row"><div class="col-lg-12"><div class="section-top-border"><input type="submit" name="ctl00\$ContentPlaceHolder1\$btn" value="Verify" id="ctl00_ContentPlaceHolder1_btn" class="btn-success" /><input type="submit" name="ctl00\$ContentPlaceHolder1\$btnreset" value="Reset" id="ctl00_ContentPlaceHolder1_btnreset" class="btn-danger" /><input type="hidden" name="ctl00\$ContentPlaceHolder1\$HiddenQtyInMT" id="ctl00_ContentPlaceHolder1_HiddenQtyInMT" /><input type="hidden" name="ctl00\$ContentPlaceHolder1\$HiddenCaptcha" id="ctl00_ContentPlaceHolder1_HiddenCaptcha" /></div></div></div><div id="ctl00_ContentPlaceHolder1_pnlgridvehicle" class="Panel"><div class="table-responsive-lg"><div></div></div></div></div></div></body></html>
''';

  /// A verified MP eTP rendered into the `pnlgridvehicle` GridView.
  ///
  /// The *shape* is what matters and what MP is known to use: a header row of
  /// column names followed by the data row, which no label/value layer can read.
  /// The column names and values here are representative, not captured — MP only
  /// renders this grid behind a CAPTCHA, so the live text could not be observed.
  /// The parser therefore treats them as one of three layers, and anything it
  /// cannot recognize surfaces as "portal layout changed" rather than as data.
  static const mpEtpGridFilled = '''
<html><body><div id="ctl00_ContentPlaceHolder1_pnlgridvehicle" class="Panel"><div class="table-responsive-lg"><table class="table" id="ctl00_ContentPlaceHolder1_gvetp" rules="all" border="1"><tr class="GridHeader"><th scope="col">eTP No</th><th scope="col">eTP Date</th><th scope="col">Valid Up To</th><th scope="col">Lessee Name</th><th scope="col">Mineral</th><th scope="col">Quantity</th><th scope="col">Unit</th><th scope="col">Vehicle No</th><th scope="col">Source District</th><th scope="col">Destination District</th></tr><tr class="GridRow"><td>1234567890</td><td>22-Jul-2026 10:05 AM</td><td>24-Jul-2026 10:05 AM</td><td>NARMADA SAND MINES</td><td>Sand</td><td>18.500</td><td>MT</td><td>MP09GH4455</td><td>Hoshangabad</td><td>Bhopal</td></tr></table></div></div></body></html>
''';

  /// MP page after a search for an eTP the portal does not know.
  static const mpEtpNoRecord = '''
<html><body><div id="ctl00_ContentPlaceHolder1_Panel1"><span id="ctl00_ContentPlaceHolder1_lblMsg" style="color:Red;">Invalid eTP No. Details not found.</span></div><div id="ctl00_ContentPlaceHolder1_pnlgridvehicle" class="Panel"><div class="table-responsive-lg"><div></div></div></div></body></html>
''';

  static const jharkhandFilled = '''
<html><body><div class="addTable"><div class="row"><div class="col-xl-2 form-group"><label class="form-label">Pass No. </label></div><div class="col-xl-4 form-group"><span id="lblchallanno">JH/2026/0012345</span></div><div class="col-xl-2 form-group"><label class="form-label">Permit No. </label></div><div class="col-xl-4 form-group"><span id="lblPermitNo">PMT-JH-778</span></div><div class="col-xl-2 form-group"><label class="form-label">Challan Date </label></div><div class="col-xl-4 form-group"><span id="lblchallandate">20/07/2026 09:15:00 AM</span></div><div class="col-xl-2 form-group"><label class="form-label">Consigner Name </label></div><div class="col-xl-4 form-group"><span id="lblconsigneename">JHARKHAND STONE WORKS</span></div><div class="col-xl-2 form-group"><label class="form-label">Challan Generate from </label></div><div class="col-xl-4 form-group"><span id="lbluser">Lessee</span></div><div class="col-xl-2 form-group"><label class="form-label">Location </label></div><div class="col-xl-4 form-group"><span id="lbllocation">Ranchi Quarry 5</span></div><div class="col-xl-2 form-group"><label class="form-label">Destination </label></div><div class="col-xl-4 form-group"><span id="lbldestination">Bokaro Site</span></div><div class="col-xl-2 form-group"><label class="form-label">Vehicle No. </label></div><div class="col-xl-4 form-group"><span id="lblvehicleno">JH05BC7788</span></div><div class="col-xl-2 form-group"><label class="form-label">Mineral Name </label></div><div class="col-xl-4 form-group"><span id="lblmineralname">Stone Chips</span></div><div class="col-xl-2 form-group"><label class="form-label">Quantity </label></div><div class="col-xl-4 form-group"><span id="lblquantity">14.500 MT</span></div><div class="col-xl-2 form-group"><label class="form-label">Pass Validity </label></div><div class="col-xl-4 form-group"><span id="lblPassValidity">21/07/2026 09:15:00 AM</span></div></div></div></div></div> </body></html>
''';
}
