<%@ include file="../imports.jsp"%>

<jsp:useBean id="context" class="org.openxava.controller.ModuleContext" scope="session"/>
<jsp:useBean id="style" class="org.openxava.web.style.Style" scope="request"/>

<%@ page import="org.openxava.filters.IFilter"%>
<%@ page import="org.openxava.filters.IRequestFilter"%>
<%@ page import="org.openxava.component.MetaComponent"%>
<%@ page import="org.openxava.tab.Tab"%>
<%@ page import="org.openxava.tab.meta.MetaTab"%>
<%@ page import="org.openxava.util.KeyAndDescription" %>
<%@ page import="org.openxava.util.Is" %>
<%@ page import="org.openxava.util.XavaResources" %>
<%@ page import="org.openxava.model.meta.MetaProperty" %>
<%@ page import="org.openxava.calculators.DescriptionsCalculator" %>
<%@ page import="org.openxava.formatters.IFormatter" %>

<%
String propertyKey = request.getParameter("propertyKey");
int index = Integer.parseInt(request.getParameter("index"));
String prefix = request.getParameter("prefix");
if (prefix == null) prefix = "";
String value = index < 0?(String) request.getAttribute(propertyKey + ".fvalue"):request.getParameter("value"); 
IFormatter formatter = null;
String descriptionsFormatterClass=request.getParameter("descriptionsFormatter");
if (descriptionsFormatterClass == null) {
	descriptionsFormatterClass=request.getParameter("formateadorDescripciones");
}
if (descriptionsFormatterClass != null) {
	String descriptionsFormatterKey = propertyKey + ".descriptionsFormatter";
	formatter = (IFormatter) request.getSession().getAttribute(descriptionsFormatterKey);	
	if (formatter == null) {
		try {
			formatter = (IFormatter) Class.forName(descriptionsFormatterClass).newInstance();
			request.getSession().setAttribute(descriptionsFormatterKey, formatter);	
		}
		catch (Exception ex) {
			ex.printStackTrace();
			System.err.println(XavaResources.getString("descriptionsEditor_descriptions_formatter_warning", propertyKey));
		}
	}
}

DescriptionsCalculator calculator = new DescriptionsCalculator();
// The arguments in English and Spanish for compatibility with
// a big amount of stereotypes made in spanish using this editor
String model = request.getParameter("model");
if (model == null) model = request.getParameter("modelo");
MetaTab metaTab = MetaComponent.get(model).getMetaTab();
String filterClass = request.getParameter("filter");
IFilter filter = Is.emptyString(filterClass)?null:(IFilter) Class.forName(filterClass).newInstance();
if (filter == null && metaTab.getMetaFilter() != null && metaTab.getMetaFilter().getFilter() != null) {
	filter = metaTab.getMetaFilter().getFilter();
}
if (filter != null) {
	if (filter instanceof IRequestFilter) {
		((IRequestFilter) filter).setRequest(request);
	}
	calculator.setParameters(null, filter);
}
calculator.setModel(model);
String condition = metaTab.getBaseCondition();
if (!Is.empty(condition) && !Is.empty(request.getParameter("condition"))) condition = condition + " AND ";
condition = condition + request.getParameter("condition");
calculator.setCondition(condition);
String order = request.getParameter("order");
calculator.setOrder(order == null?metaTab.getDefaultOrder():order);
calculator.setUseConvertersInKeys(true);
String keyProperty = request.getParameter("keyProperty");
if (keyProperty == null) keyProperty = request.getParameter("propiedadClave");
calculator.setKeyProperty(keyProperty);
String keyProperties = request.getParameter("keyProperties");
if (keyProperties == null) keyProperties = request.getParameter("propiedadesClave");
calculator.setKeyProperties(keyProperties);
String descriptionProperty = request.getParameter("descriptionProperty");
if (descriptionProperty == null) descriptionProperty = request.getParameter("propiedadDescripcion");
calculator.setDescriptionProperty(descriptionProperty);
String descriptionProperties = request.getParameter("descriptionProperties");
if (descriptionProperties == null) descriptionProperties = request.getParameter("propiedadesDescripcion");
calculator.setDescriptionProperties(descriptionProperties);
calculator.setOrderByKey(true); 
calculator.setDistinct(true); 

java.util.Collection descriptions = calculator.getDescriptions();
MetaProperty p = (MetaProperty) request.getAttribute(propertyKey);
boolean filterOnChange = org.openxava.util.XavaPreferences.getInstance().isFilterOnChange();
String collection = request.getParameter("collection"); 
String collectionArgv = Is.emptyString(collection)?"":"collection="+collection;
%>
<div>
	<%-- id needed in order openxava.renumberListColumns() works  --%>
	<input id="<xava:id name='<%=prefix  + "conditionComparator."  + index%>'/>" type="hidden" name="<xava:id name='<%=prefix  + "conditionComparator."  + index%>'/>" value="<%=Tab.EQ_COMPARATOR%>">
	<input id="<xava:id name='<%=prefix  + "conditionValueTo."  + index%>'/>" type="hidden" name="<xava:id name='<%=prefix  + "conditionValueTo."  + index%>'/>" >
	<%-- conditionValueTo: we need all indexes to implement the range filters --%>
</div>
<% if (index < 0) { %>
<select id="<%=propertyKey%>" name="<%=propertyKey%>" tabindex="1" class=<%=style.getEditor()%>>
<% } else {  %>
<select name="<xava:id name='<%=prefix + "conditionValue." + index%>'/>" class=<%=style.getEditor()%>
<% if(filterOnChange) { %>
	onchange="openxava.executeAction('<%=request.getParameter("application")%>', '<%=request.getParameter("module")%>', '', false, 'List.filter','<%=collectionArgv%>')"
<% } %>
>

<% } %>
	<option value=""></option>
<%
	java.util.Iterator it = descriptions.iterator();
	String selectedDescription = "";	
	while (it.hasNext()) {
		KeyAndDescription cl = (KeyAndDescription) it.next();	
		String selected = "";
		String description = formatter==null?cl.getDescription().toString():formatter.format(request, cl.getDescription());
		// Intead of asking index < 0 it would better to use a specific parameter such as descriptionInKey or so
		String key = cl.getKey().toString(); 
		if (key.equals(value)) { 
			selected = "selected"; 
			selectedDescription = description;
		} 		
%>
	<option value="<%=key%>" <%=selected%>><%=description%></option>
<%
	} // del while
%>
</select>
<% if (index < 0) { %>
<input type="hidden" name="<%=propertyKey%>__DESCRIPTION__" value="<%=selectedDescription%>"/>
<% } %>
