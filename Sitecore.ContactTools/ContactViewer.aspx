﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContactViewer.aspx.cs" Inherits="Sitecore.ContactTools.ContactViewer" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Contact Viewer</title>
    <!-- JSON parsing and formatting taken from http://www.bodurov.com/JsonFormatter/ -->
<script>
// we need tabs as spaces and not CSS magin-left 
// in order to ratain format when coping and pasing the code
window.SINGLE_TAB = "  ";
window.ImgCollapsed = "Collapsed.gif";
window.ImgExpanded = "Expanded.gif";
window.QuoteKeys = true;
function $id(id){ return document.getElementById(id); }
function IsArray(obj) {
  return obj && 
          typeof obj === 'object' && 
          typeof obj.length === 'number' &&
          !(obj.propertyIsEnumerable('length'));
}
function Process(){
  SetTab();
  window.IsCollapsible = true;
  var json = $id("RawJson").value;
  var html = "";
  try{
    if(json == "") json = "\"\"";
    var obj = eval("["+json+"]");
    html = ProcessObject(obj[0], 0, false, false, false);
    $id("Canvas").innerHTML = "<PRE class='CodeContainer'>"+html+"</PRE>";
  }catch(e){
    alert("JSON is not well formated:\n"+e.message);
    $id("Canvas").innerHTML = "";
  }
}
function Destringify(){
  $id("RawJson").value = $id("RawJson").value.trim().replace(/^["]+|["]+$/g, "").replace(/\\"/g,'"');
}
window._dateObj = new Date();
window._regexpObj = new RegExp();
function ProcessObject(obj, indent, addComma, isArray, isPropertyContent){
  var html = "";
  var comma = (addComma) ? "<span class='Comma'>,</span> " : ""; 
  var type = typeof obj;
  var clpsHtml ="";
  if(IsArray(obj)){
    if(obj.length == 0){
      html += GetRow(indent, "<span class='ArrayBrace'>[ ]</span>"+comma, isPropertyContent);
    }else{
      clpsHtml = window.IsCollapsible ? "<span><img src=\""+window.ImgExpanded+"\" onClick=\"ExpImgClicked(this)\" /></span><span class='collapsible'>" : "";
      html += GetRow(indent, "<span class='ArrayBrace'>[</span>"+clpsHtml, isPropertyContent);
      for(var i = 0; i < obj.length; i++){
        html += ProcessObject(obj[i], indent + 1, i < (obj.length - 1), true, false);
      }
      clpsHtml = window.IsCollapsible ? "</span>" : "";
      html += GetRow(indent, clpsHtml+"<span class='ArrayBrace'>]</span>"+comma);
    }
  }else if(type == 'object'){
    if (obj == null){
        html += FormatLiteral("null", "", comma, indent, isArray, "Null");
    }else if (obj.constructor == window._dateObj.constructor) { 
        html += FormatLiteral("new Date(" + obj.getTime() + ") /*" + obj.toLocaleString()+"*/", "", comma, indent, isArray, "Date"); 
    }else if (obj.constructor == window._regexpObj.constructor) {
        html += FormatLiteral("new RegExp(" + obj + ")", "", comma, indent, isArray, "RegExp"); 
    }else{
      var numProps = 0;
      for(var prop in obj) numProps++;
      if(numProps == 0){
        html += GetRow(indent, "<span class='ObjectBrace'>{ }</span>"+comma, isPropertyContent);
      }else{
        clpsHtml = window.IsCollapsible ? "<span><img src=\""+window.ImgExpanded+"\" onClick=\"ExpImgClicked(this)\" /></span><span class='collapsible'>" : "";
        html += GetRow(indent, "<span class='ObjectBrace'>{</span>"+clpsHtml, isPropertyContent);
        var j = 0;
        for(var prop in obj){
          var quote = window.QuoteKeys ? "\"" : "";
          html += GetRow(indent + 1, "<span class='PropertyName'>"+quote+prop+quote+"</span>: "+ProcessObject(obj[prop], indent + 1, ++j < numProps, false, true));
        }
        clpsHtml = window.IsCollapsible ? "</span>" : "";
        html += GetRow(indent, clpsHtml+"<span class='ObjectBrace'>}</span>"+comma);
      }
    }
  }else if(type == 'number'){
    html += FormatLiteral(obj, "", comma, indent, isArray, "Number");
  }else if(type == 'boolean'){
    html += FormatLiteral(obj, "", comma, indent, isArray, "Boolean");
  }else if(type == 'function'){
    if (obj.constructor == window._regexpObj.constructor) {
        html += FormatLiteral("new RegExp(" + obj + ")", "", comma, indent, isArray, "RegExp"); 
    }else{
        obj = FormatFunction(indent, obj);
        html += FormatLiteral(obj, "", comma, indent, isArray, "Function");
    }
  }else if(type == 'undefined'){
    html += FormatLiteral("undefined", "", comma, indent, isArray, "Null");
  }else{
    html += FormatLiteral(obj.toString().split("\\").join("\\\\").split('"').join('\\"'), "\"", comma, indent, isArray, "String");
  }
  return html;
}
function FormatLiteral(literal, quote, comma, indent, isArray, style){
  if(typeof literal == 'string')
    literal = literal.split("<").join("&lt;").split(">").join("&gt;");
  var str = "<span class='"+style+"'>"+quote+literal+quote+comma+"</span>";
  if(isArray) str = GetRow(indent, str);
  return str;
}
function FormatFunction(indent, obj){
  var tabs = "";
  for(var i = 0; i < indent; i++) tabs += window.TAB;
  var funcStrArray = obj.toString().split("\n");
  var str = "";
  for(var i = 0; i < funcStrArray.length; i++){
    str += ((i==0)?"":tabs) + funcStrArray[i] + "\n";
  }
  return str;
}
function GetRow(indent, data, isPropertyContent){
  var tabs = "";
  for(var i = 0; i < indent && !isPropertyContent; i++) tabs += window.TAB;
  if(data != null && data.length > 0 && data.charAt(data.length-1) != "\n")
    data = data+"\n";
  return tabs+data;                       
}
function CollapsibleViewClicked(){
  $id("CollapsibleViewDetail").style.visibility = true ? "visible" : "hidden";
  Process();
}

function QuoteKeysClicked(){
  window.QuoteKeys = $id("QuoteKeys").checked;
  Process();
}

function CollapseAllClicked(){
  EnsureIsPopulated();
  TraverseChildren($id("Canvas"), function(element){
    if(element.className == 'collapsible'){
      MakeContentVisible(element, false);
    }
  }, 0);
}
function ExpandAllClicked(){
  EnsureIsPopulated();
  TraverseChildren($id("Canvas"), function(element){
    if(element.className == 'collapsible'){
      MakeContentVisible(element, true);
    }
  }, 0);
}
function MakeContentVisible(element, visible){
  var img = element.previousSibling.firstChild;
  if(!!img.tagName && img.tagName.toLowerCase() == "img"){
    element.style.display = visible ? 'inline' : 'none';
    element.previousSibling.firstChild.src = visible ? window.ImgExpanded : window.ImgCollapsed;
  }
}
function TraverseChildren(element, func, depth){
  for(var i = 0; i < element.childNodes.length; i++){
    TraverseChildren(element.childNodes[i], func, depth + 1);
  }
  func(element, depth);
}
function ExpImgClicked(img){
  var container = img.parentNode.nextSibling;
  if(!container) return;
  var disp = "none";
  var src = window.ImgCollapsed;
  if(container.style.display == "none"){
      disp = "inline";
      src = window.ImgExpanded;
  }
  container.style.display = disp;
  img.src = src;
}
function CollapseLevel(level){
  EnsureIsPopulated();
  TraverseChildren($id("Canvas"), function(element, depth){
    if(element.className == 'collapsible'){
      if(depth >= level){
        MakeContentVisible(element, false);
      }else{
        MakeContentVisible(element, true);  
      }
    }
  }, 0);
}
function TabSizeChanged(){
  Process();
}
function SetTab(){
  var select = 2;
  window.TAB = MultiplyString(2, window.SINGLE_TAB);
}
function EnsureIsPopulated(){
  if(!$id("Canvas").innerHTML && !!$id("RawJson").value) Process();
}
function MultiplyString(num, str){
  var sb =[];
  for(var i = 0; i < num; i++){
    sb.push(str);
  }
  return sb.join("");
}
function SelectAllClicked(){

  if(!!document.selection && !!document.selection.empty) {
    document.selection.empty();
  } else if(window.getSelection) {
    var sel = window.getSelection();
    if(sel.removeAllRanges) {
      window.getSelection().removeAllRanges();
    }
  }

  var range = 
      (!!document.body && !!document.body.createTextRange)
          ? document.body.createTextRange()
          : document.createRange();
  
  if(!!range.selectNode)
    range.selectNode($id("Canvas"));
  else if(range.moveToElementText)
    range.moveToElementText($id("Canvas"));
  
  if(!!range.select)
    range.select($id("Canvas"));
  else
    window.getSelection().addRange(range);
}
function LinkToJson(){
  var val = $id("RawJson").value;
  val = escape(val.split('/n').join(' ').split('/r').join(' '));
  $id("InvisibleLinkUrl").value = val;
  $id("InvisibleLink").submit();
}
</script>
<style>
div.ControlsRow, div.HeadersRow {
	font-size: 14pt; font-family: Lucida Console;
}
div.AdRow{
  font-size: 14pt; font-family: Lucida Console;
}
div.Canvas
{
  font-family: Lucida Console;
  font-size: 14pt;
	background-color:#ECECEC;
	color:#000000;
	border:solid 1px #CECECE;
}
.ObjectBrace
{
	color:#00AA00;
	font-weight:bold;
}
.ArrayBrace
{
	color:#0033FF;
	font-weight:bold;
}
.PropertyName
{
	color:#CC0000;
	font-weight:bold;
}
.String
{
	color:#007777;
}
.Number
{
	color:#AA00AA;
}
.Boolean
{
  color:#0000FF;
}
.Function
{
  color:#AA6633;
  text-decoration:italic;
}
.Null
{
  color:#0000FF;
}
.Comma
{
  color:#000000;
  font-weight:bold;
}
PRE.CodeContainer{
  margin-top:0px;
  margin-bottom:0px;
}
PRE.CodeContainer img{
  cursor:pointer;
  border:none;
  margin-bottom:-1px;
}
#CollapsibleViewDetail a{
  padding-left:10px;
}
#ControlsRow{
  white-space:nowrap;
  font-size: 14pt; font-family: Lucida Console;
}
#TabSizeHolder{
  padding-left:10px;
  padding-right:10px;
}
#HeaderTitle{
  text-align:right;
  font-size:11px;
}
#HeaderSubTitle{
  margin-bottom:2px;
  margin-top:0px
}
#RawJson{
  width:99%;
  height:130px;
}
.unstringify{ padding-left: 30px; font-size: 11px; }
A.OtherToolsLink { color:#555;text-decoration:none; }
A.OtherToolsLink:hover { text-decoration:underline; }
</style>

</head>
<body>
    <form id="form1" runat="server">
    <div>
        <p>
          <table>
            <tr>
              <td>Contact identifier:</td>
              <td><asp:TextBox runat="server" id="tbContactIdentifierValue" Width="400px" /></td>
            </tr>
            <tr>
              <td style="vertical-align: top;">Facets:</td>
              <td><asp:ListBox runat="server" ID="lbFacets" SelectionMode="Multiple" Height="155" /></td>
            </tr>
            <tr>
              <td>Include facets:</td>
              <td><asp:CheckBox runat="server" id="chkIncludeFacets" Checked="True" /></td>
            </tr>
            <tr>
              <td>Include interactions:</td>
              <td><asp:CheckBox runat="server" id="chkIncludeInteractions" /></td>
            </tr>
            <tr>
              <td>&nbsp;</td>
              <td><asp:Button Text="Load contact" runat="server" OnClick="OnClick_LoadContact"/></td>
            </tr>
          </table>
          <pre id="json"></pre>
          <div id="Canvas" class="Canvas"></div>
          <asp:Label runat="server" id="lblError" ForeColor="Red" />
        </p>
        <textarea id="RawJson" style="visibility: hidden;"><%#Json%></textarea>
        <script>
        Process();
        </script>
    </div>
    </form>
</body>
</html>
