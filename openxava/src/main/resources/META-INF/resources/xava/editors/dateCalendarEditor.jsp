<%-- WARNING: IF YOU CHANGE THIS CODE PASS THE MANUAL TEST ON DateCalendarTest.txt --%>

<%@ page import="org.openxava.model.meta.MetaProperty" %>

<jsp:useBean id="style" class="org.openxava.web.style.Style" scope="request"/>
  
<%
String propertyKey = request.getParameter("propertyKey");
MetaProperty p = (MetaProperty) request.getAttribute(propertyKey);
String fvalue = (String) request.getAttribute(propertyKey + ".fvalue");
String align = p.isNumber()?"right":"left";
boolean editable="true".equals(request.getParameter("editable"));
String disabled=editable?"":"disabled";
String script = request.getParameter("script");
boolean label = org.openxava.util.XavaPreferences.getInstance().isReadOnlyAsLabel();
String browser = request.getHeader("user-agent");
int sizeIncrement = browser.contains("Chrome")?0:2; 
if (editable || !label) {
	String dateClass = editable?"xava_date":""; 
%>
<span class="<%=dateClass%> ox-date-calendar" data-date-format="<%=org.openxava.util.Dates.dateFormatForJSCalendar()%>">
<input type="text" name="<%=propertyKey%>" id="<%=propertyKey%>" class="<%=style.getEditor()%>" title="<%=p.getDescription(request)%>"
	tabindex="1" 
	align='<%=align%>'
	maxlength="<%=p.getSize()%>"
	data-input
	size="<%=p.getSize() + sizeIncrement%>" 
	value="<%=fvalue%>" <%=disabled%> <%=script%>><%if (editable) {%><a data-toggle><i class="mdi mdi-calendar"></i></a><%} %>
</span> 
<%
} else {
%>
<%=fvalue%>&nbsp;	
<%
}
%>
<% if (!editable) { %>
	<input type="hidden" name="<%=propertyKey%>" value="<%=fvalue%>">
<% } %>			
