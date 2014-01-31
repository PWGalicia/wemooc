<%@page import="com.liferay.lms.model.LmsPrefs"%>
<%@page import="com.liferay.lms.service.LmsPrefsLocalServiceUtil"%>
<%@page import="com.liferay.portal.model.RoleConstants"%>
<%@page import="com.liferay.portal.service.RoleLocalServiceUtil"%>
<%@page import="com.liferay.portal.model.Role"%>

<%@page import="com.liferay.portal.util.comparator.UserFirstNameComparator"%>
<%@page import="java.util.Comparator"%>
<%@page import="java.util.Collections"%>
<%@page import="com.liferay.portal.kernel.portlet.LiferayWindowState"%>
<%@page import="com.liferay.util.JS"%>
<%@page import="com.liferay.portal.kernel.util.ListUtil"%>
<%@page import="com.liferay.lms.service.CourseLocalServiceUtil"%>
<%@page import="com.liferay.lms.service.CourseServiceUtil"%>
<%@page import="com.liferay.lms.model.Course"%>
<%@page import="com.liferay.portal.model.UserGroupRole"%>
<%@page import="com.liferay.portal.model.User"%>
<%@page import="com.liferay.portal.model.Role"%>
<%@page import="com.liferay.portal.service.UserGroupRoleLocalServiceUtil"%>
<%@page import="com.liferay.portal.service.RoleLocalServiceUtil"%>
<%@page import="com.liferay.portal.model.RoleConstants"%>
<%@ include file="/init.jsp" %>

<%
String students = LanguageUtil.get(pageContext,"courseadmin.adminactions.students");
String tabs1 = ParamUtil.getString(request, "tabs1", students);
Long roleId = ParamUtil.getLong(request, "roleId",0);

LmsPrefs prefs=LmsPrefsLocalServiceUtil.getLmsPrefs(themeDisplay.getCompanyId());
String teacherName=RoleLocalServiceUtil.getRole(prefs.getTeacherRole()).getTitle(locale);
String editorName=RoleLocalServiceUtil.getRole(prefs.getEditorRole()).getTitle(locale);
Role commmanager=RoleLocalServiceUtil.getRole(themeDisplay.getCompanyId(), RoleConstants.SITE_MEMBER) ;


if(roleId!=null&&!roleId.equals(0L)){
	if(roleId==commmanager.getRoleId()){
		tabs1 = LanguageUtil.get(pageContext,"courseadmin.adminactions.students");
	}else if(roleId==prefs.getEditorRole()){
		tabs1 = editorName;
	}else{
		tabs1 = teacherName;
	}
}

long primKey=ParamUtil.getLong(request, "courseId",0);
String sPrimKey=ParamUtil.getString(request, "courseId","0");

Course course=CourseLocalServiceUtil.getCourse(primKey);
long createdGroupId=course.getGroupCreatedId();

%>
<liferay-portlet:renderURL var="backURL"></liferay-portlet:renderURL>
<liferay-ui:header title="<%=course.getTitle(themeDisplay.getLocale()) %>" backURL="<%=backURL %>"></liferay-ui:header>

<%
	StringBuffer menu = new StringBuffer(students);
	menu.append(",");
	menu.append(editorName);
	menu.append(",");
	menu.append(teacherName);
%>

<portlet:renderURL var="memebersURL">
	<portlet:param name="courseId" value="<%=String.valueOf(primKey) %>" />
	<portlet:param name="jspPage" value="/html/courseadmin/rolememberstab.jsp" />
</portlet:renderURL>

<liferay-ui:tabs names="<%=menu.toString() %>" url="<%=memebersURL %>" />
<c:if test='<%= tabs1.equals(students) %>'>
  <liferay-util:include page="/html/courseadmin/rolemembers.jsp" servletContext="<%=this.getServletContext() %>">
	<liferay-util:param value="<%=sPrimKey %>" name="courseId"/>
	<liferay-util:param value="<%=Long.toString(commmanager.getRoleId()) %>" name="roleId"/>
	<liferay-util:param value="1" name="tab"/>
  </liferay-util:include>
</c:if>
<c:if test='<%= tabs1.equals(editorName) %>'>
  <liferay-util:include page="/html/courseadmin/rolemembers.jsp" servletContext="<%=this.getServletContext() %>">
	<liferay-util:param value="<%=sPrimKey %>" name="courseId"/>
	<liferay-util:param value="<%=Long.toString(prefs.getEditorRole()) %>" name="roleId"/>
	<liferay-util:param value="2" name="tab"/>
  </liferay-util:include>
</c:if>
<c:if test='<%= tabs1.equals(teacherName) %>'>
  <liferay-util:include page="/html/courseadmin/rolemembers.jsp" servletContext="<%=this.getServletContext() %>">
	<liferay-util:param value="<%=sPrimKey %>" name="courseId"/>
	<liferay-util:param value="<%=Long.toString(prefs.getTeacherRole()) %>" name="roleId"/>
	<liferay-util:param value="3" name="tab"/>
  </liferay-util:include>
</c:if>