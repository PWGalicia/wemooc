<%--
/**
 * Copyright (c) 2000-2012 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@page import="java.util.Arrays"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.ArrayList"%>
<%@ include file="/html/portlet/portlet_configuration/init.jsp" %>
<%
String tabs2 = ParamUtil.getString(request, "tabs2", "regular-roles");

String redirect = ParamUtil.getString(request, "redirect");
String returnToFullPageURL = ParamUtil.getString(request, "returnToFullPageURL");

String modelResource = ParamUtil.getString(request, "modelResource");
String modelResourceDescription = ParamUtil.getString(request, "modelResourceDescription");
String modelResourceName = ResourceActionsUtil.getModelResource(pageContext, modelResource);

long resourceGroupId = ParamUtil.getLong(request, "resourceGroupId");

String resourcePrimKey = ParamUtil.getString(request, "resourcePrimKey");

/*Hook modification*/
String[] actionsParam = null;
String brute = ParamUtil.getString(request, "brute");

if(modelResourceDescription.contains("----")||!brute.isEmpty()){
	if(!brute.isEmpty()){
		actionsParam = brute.split(",");
	}else{
		String [] splited = modelResourceDescription.split("----");
		if(splited.length>=2){
			modelResourceDescription = splited[0];
			actionsParam = splited[1].split(",");
			brute = splited[1];
		}
	}
}
/*End Hook modification*/

if (Validator.isNull(resourcePrimKey)) {
	throw new ResourcePrimKeyException();
}

String selResource = modelResource;
String selResourceDescription = modelResourceDescription;
String selResourceName = modelResourceName;

if (Validator.isNull(modelResource)) {
	PortletURL portletURL = new PortletURLImpl(request, portletResource, plid, PortletRequest.ACTION_PHASE);

	portletURL.setWindowState(WindowState.NORMAL);
	portletURL.setPortletMode(PortletMode.VIEW);

	redirect = portletURL.toString();

	Portlet portlet = PortletLocalServiceUtil.getPortletById(company.getCompanyId(), portletResource);

	selResource = portlet.getRootPortletId();
	selResourceDescription = PortalUtil.getPortletTitle(portlet, application, locale);
	selResourceName = LanguageUtil.get(pageContext, "portlet");
}
else {
	PortalUtil.addPortletBreadcrumbEntry(request, HtmlUtil.unescape(selResourceDescription), null);
	PortalUtil.addPortletBreadcrumbEntry(request, LanguageUtil.get(pageContext, "permissions"), currentURL);
}

Group group = themeDisplay.getScopeGroup();
long groupId = group.getGroupId();

Layout selLayout = null;

if (modelResource.equals(Layout.class.getName())) {
	selLayout = LayoutLocalServiceUtil.getLayout(GetterUtil.getLong(resourcePrimKey));

	group = selLayout.getGroup();
	groupId = group.getGroupId();
}

Resource resource = null;

try {
	if (PropsValues.PERMISSIONS_USER_CHECK_ALGORITHM == 6) {
		if (ResourceBlockLocalServiceUtil.isSupported(selResource)) {
			ResourceBlockLocalServiceUtil.verifyResourceBlockId(company.getCompanyId(), selResource, Long.valueOf(resourcePrimKey));
		}
		else {
			if (ResourcePermissionLocalServiceUtil.getResourcePermissionsCount(company.getCompanyId(), selResource, ResourceConstants.SCOPE_INDIVIDUAL, resourcePrimKey) == 0) {
				throw new NoSuchResourceException();
			}
		}
	}

	resource = ResourceLocalServiceUtil.getResource(company.getCompanyId(), selResource, ResourceConstants.SCOPE_INDIVIDUAL, resourcePrimKey);
}
catch (NoSuchResourceException nsre) {
	boolean portletActions = Validator.isNull(modelResource);

	ResourceLocalServiceUtil.addResources(company.getCompanyId(), groupId, 0, selResource, resourcePrimKey, portletActions, true, true);

	resource = ResourceLocalServiceUtil.getResource(company.getCompanyId(), selResource, ResourceConstants.SCOPE_INDIVIDUAL, resourcePrimKey);
}

String roleTypesParam = ParamUtil.getString(request, "roleTypes");

int[] roleTypes = null;

if (Validator.isNotNull(roleTypesParam)) {
	roleTypes = StringUtil.split(roleTypesParam, 0);
}

if (group.isCompany()) {
	roleTypes = new int[] {RoleConstants.TYPE_REGULAR};
}

PortletURL actionPortletURL = renderResponse.createActionURL();

actionPortletURL.setParameter("struts_action", "/portlet_configuration/edit_permissions");
actionPortletURL.setParameter("tabs2", tabs2);
actionPortletURL.setParameter("redirect", redirect);
actionPortletURL.setParameter("returnToFullPageURL", returnToFullPageURL);
actionPortletURL.setParameter("portletResource", portletResource);
actionPortletURL.setParameter("modelResource", modelResource);
actionPortletURL.setParameter("modelResourceDescription", modelResourceDescription);
actionPortletURL.setParameter("resourceGroupId", String.valueOf(resourceGroupId));
actionPortletURL.setParameter("resourcePrimKey", resourcePrimKey);
actionPortletURL.setParameter("roleTypes", roleTypesParam);
actionPortletURL.setParameter("brute", brute);

PortletURL renderPortletURL = renderResponse.createRenderURL();

renderPortletURL.setParameter("struts_action", "/portlet_configuration/edit_permissions");
renderPortletURL.setParameter("tabs2", tabs2);
renderPortletURL.setParameter("redirect", redirect);
renderPortletURL.setParameter("returnToFullPageURL", returnToFullPageURL);
renderPortletURL.setParameter("portletResource", portletResource);
renderPortletURL.setParameter("modelResource", modelResource);
renderPortletURL.setParameter("modelResourceDescription", modelResourceDescription);
renderPortletURL.setParameter("resourceGroupId", String.valueOf(resourceGroupId));
renderPortletURL.setParameter("resourcePrimKey", resourcePrimKey);
renderPortletURL.setParameter("roleTypes", roleTypesParam);
renderPortletURL.setParameter("brute", brute);

Group controlPanelGroup = GroupLocalServiceUtil.getGroup(company.getCompanyId(), GroupConstants.CONTROL_PANEL);

long controlPanelPlid = LayoutLocalServiceUtil.getDefaultPlid(controlPanelGroup.getGroupId(), true);

PortletURLImpl definePermissionsURL = new PortletURLImpl(request, PortletKeys.ROLES_ADMIN, controlPanelPlid, PortletRequest.RENDER_PHASE);

definePermissionsURL.setPortletMode(PortletMode.VIEW);

definePermissionsURL.setRefererPlid(plid);

definePermissionsURL.setParameter("struts_action", "/roles_admin/edit_role_permissions");
definePermissionsURL.setParameter(Constants.CMD, Constants.VIEW);
%>

<div class="edit-permissions">
	<aui:form action="<%= actionPortletURL.toString() %>" method="post" name="fm">
		<aui:input name="<%= Constants.CMD %>" type="hidden" value="role_permissions" />
		<aui:input name="resourceId" type="hidden" value="<%= resource.getResourceId() %>" />

		<c:choose>
			<c:when test="<%= Validator.isNull(modelResource) %>">
				<liferay-util:include page="/html/portlet/portlet_configuration/tabs1.jsp">
					<liferay-util:param name="tabs1" value="permissions" />
				</liferay-util:include>
			</c:when>
			<c:otherwise>
				<liferay-ui:header
					backURL="<%= redirect %>"
					localizeTitle="<%= false %>"
					title="<%= HtmlUtil.unescape(selResourceDescription) %>"
				/>
			</c:otherwise>
		</c:choose>

		<%
		List<String> actions = ResourceActionsUtil.getResourceActions(portletResource, modelResource);
		List<String> actionstmp = new ArrayList<String>();
		
		/* Hook modification */
		if(actionsParam!=null){
			//List<String> actionstmp = new ArrayList<String>(Arrays.asList(new String[actions.size()]));
			//Collections.copy(actionstmp, actions);
			
			for(int i = 0;i<actions.size();i++){
				String action = actions.get(i);
				boolean find=false;
				for(int j = 0;j<actionsParam.length;j++){
					if(action.equals(actionsParam[j])){
						find=true;
						break;
					}
				}
				if(find){
					actionstmp.add(action);
				}
			}
		}
		/*End Hook modification*/

		if (modelResource.equals(Group.class.getName())) {
			long modelResourceGroupId = GetterUtil.getLong(resourcePrimKey);

			Group modelResourceGroup = GroupLocalServiceUtil.getGroup(modelResourceGroupId);

			if (modelResourceGroup.isLayoutPrototype() || modelResourceGroup.isLayoutSetPrototype() || modelResourceGroup.isUserGroup()) {
				actions = new ArrayList(actions);

				actions.remove(ActionKeys.ADD_LAYOUT_BRANCH);
				actions.remove(ActionKeys.ADD_LAYOUT_SET_BRANCH);
				actions.remove(ActionKeys.ASSIGN_MEMBERS);
				actions.remove(ActionKeys.ASSIGN_USER_ROLES);
				actions.remove(ActionKeys.MANAGE_ANNOUNCEMENTS);
				actions.remove(ActionKeys.MANAGE_STAGING);
				actions.remove(ActionKeys.MANAGE_TEAMS);
				actions.remove(ActionKeys.PUBLISH_STAGING);
				actions.remove(ActionKeys.PUBLISH_TO_REMOTE);
				actions.remove(ActionKeys.VIEW_MEMBERS);
				actions.remove(ActionKeys.VIEW_STAGING);
			}
		}

		List<Role> roles = ResourceActionsUtil.getRoles(company.getCompanyId(), group, modelResource, roleTypes);

		Role administratorRole = RoleLocalServiceUtil.getRole(company.getCompanyId(), RoleConstants.ADMINISTRATOR);

		roles.remove(administratorRole);

		if (!ResourceActionsUtil.isPortalModelResource(modelResource)) {
			Role organizationAdministratorRole = RoleLocalServiceUtil.getRole(company.getCompanyId(), RoleConstants.ORGANIZATION_ADMINISTRATOR);

			roles.remove(organizationAdministratorRole);

			Role organizationOwnerRole = RoleLocalServiceUtil.getRole(company.getCompanyId(), RoleConstants.ORGANIZATION_OWNER);

			roles.remove(organizationOwnerRole);

			Role siteAdministratorRole = RoleLocalServiceUtil.getRole(company.getCompanyId(), RoleConstants.SITE_ADMINISTRATOR);

			roles.remove(siteAdministratorRole);

			Role siteOwnerRole = RoleLocalServiceUtil.getRole(company.getCompanyId(), RoleConstants.SITE_OWNER);

			roles.remove(siteOwnerRole);
		}

		long modelResourceRoleId = 0;

		if (modelResource.equals(Role.class.getName())) {
			modelResourceRoleId = GetterUtil.getLong(resourcePrimKey);

			Role role = RoleLocalServiceUtil.getRole(modelResourceRoleId);

			roles.remove(role);
		}

		List<Team> teams = null;

		if (group.isOrganization() || group.isRegularSite()) {
			teams = TeamLocalServiceUtil.getGroupTeams(groupId);
		}
		else if (group.isLayout()) {
			teams = TeamLocalServiceUtil.getGroupTeams(group.getParentGroupId());
		}

		if (teams != null) {
			for (Team team : teams) {
				Role role = RoleLocalServiceUtil.getTeamRole(team.getCompanyId(), team.getTeamId());

				if (role.getRoleId() == modelResourceRoleId) {
					continue;
				}

				roles.add(role);
			}
		}

		Iterator<Role> itr = roles.iterator();

		while (itr.hasNext()) {
			Role role = itr.next();

			String name = role.getName();

			if (!name.equals(RoleConstants.GUEST) && !RolePermissionUtil.contains(permissionChecker, groupId, role.getRoleId(), ActionKeys.VIEW) && (!role.isTeam() || !TeamPermissionUtil.contains(permissionChecker, role.getClassPK(), ActionKeys.PERMISSIONS))) {
				itr.remove();
			}

			if (name.equals(RoleConstants.GUEST) && modelResource.equals(Layout.class.getName())) {
				Layout resourceLayout = LayoutLocalServiceUtil.getLayout(GetterUtil.getLong(resourcePrimKey));

				if (resourceLayout.isPrivateLayout()) {
					Group resourceLayoutGroup = resourceLayout.getGroup();

					if (!resourceLayoutGroup.isLayoutSetPrototype()) {
						itr.remove();
					}
				}
			}

			if (name.equals(RoleConstants.GUEST) && Validator.isNotNull(portletResource)) {
				int pos = resourcePrimKey.indexOf(PortletConstants.LAYOUT_SEPARATOR);

				if (pos > 0) {
					long resourcePlid = GetterUtil.getLong(resourcePrimKey.substring(0, pos));

					Layout resourceLayout = LayoutLocalServiceUtil.getLayout(resourcePlid);

					if (resourceLayout.isPrivateLayout()) {
						Group resourceLayoutGroup = resourceLayout.getGroup();

						if (!resourceLayoutGroup.isLayoutSetPrototype()) {
							itr.remove();
						}
					}
				}
			}
		}
		%>

		<liferay-ui:search-container>
			<liferay-ui:search-container-results
				results="<%= roles %>"
				total="<%= roles.size() %>"
			/>

			<liferay-ui:search-container-row
				className="com.liferay.portal.model.Role"
				escapedModel="<%= true %>"
				keyProperty="roleId"
				modelVar="role"
			>
				<liferay-util:param name="className" value="<%= RolesAdminUtil.getCssClassName(role) %>" />
				<liferay-util:param name="classHoverName" value="<%= RolesAdminUtil.getCssClassName(role) %>" />

				<%
				String definePermissionsHREF = null;

				String name = role.getName();

				if (!name.equals(RoleConstants.ADMINISTRATOR) && !name.equals(RoleConstants.ORGANIZATION_ADMINISTRATOR) && !name.equals(RoleConstants.ORGANIZATION_OWNER) && !name.equals(RoleConstants.OWNER) && !name.equals(RoleConstants.SITE_ADMINISTRATOR) && !name.equals(RoleConstants.SITE_OWNER) && RolePermissionUtil.contains(permissionChecker, role.getRoleId(), ActionKeys.DEFINE_PERMISSIONS)) {
					definePermissionsURL.setParameter("roleId", String.valueOf(role.getRoleId()));

					definePermissionsHREF = definePermissionsURL.toString();
				}
				%>

				<liferay-ui:search-container-column-text
					href="<%= definePermissionsHREF %>"
					name="role"
					value="<%= role.getTitle(locale) %>"
				/>

				<%

				// Actions

				List<String> currentIndividualActions = null;
				List<String> currentGroupActions = null;
				List<String> currentGroupTemplateActions = null;
				List<String> currentCompanyActions = null;

				if (PropsValues.PERMISSIONS_USER_CHECK_ALGORITHM == 6) {
					if (ResourceBlockLocalServiceUtil.isSupported(resource.getName())) {
						ResourceBlock resourceBlock = ResourceBlockLocalServiceUtil.getResourceBlock(resource.getName(), Long.valueOf(resource.getPrimKey()));

						// Individual actions are not stored separately, so currentIndividualActions will include group and company actions as well

						currentIndividualActions = ResourceBlockLocalServiceUtil.getPermissions(resourceBlock, role.getRoleId());
						currentGroupActions = ResourceBlockLocalServiceUtil.getGroupScopePermissions(resourceBlock, role.getRoleId());

						// Resource blocks do not dinstinguish between company scope and group-template scope permissions, so the distinction must be simulated here

						if (role.getType() == RoleConstants.TYPE_REGULAR) {
							currentGroupTemplateActions = new ArrayList<String>();
							currentCompanyActions = ResourceBlockLocalServiceUtil.getCompanyScopePermissions(resourceBlock, role.getRoleId());
						}
						else {
							currentGroupTemplateActions = ResourceBlockLocalServiceUtil.getCompanyScopePermissions(resourceBlock, role.getRoleId());
							currentCompanyActions = new ArrayList<String>();
						}
					}
					else {
						currentIndividualActions = ResourcePermissionLocalServiceUtil.getAvailableResourcePermissionActionIds(resource.getCompanyId(), resource.getName(), resource.getScope(), resource.getPrimKey(), role.getRoleId(), actions);
						currentGroupActions = ResourcePermissionLocalServiceUtil.getAvailableResourcePermissionActionIds(resource.getCompanyId(), resource.getName(), ResourceConstants.SCOPE_GROUP, String.valueOf(groupId), role.getRoleId(), actions);
						currentGroupTemplateActions = ResourcePermissionLocalServiceUtil.getAvailableResourcePermissionActionIds(resource.getCompanyId(), resource.getName(), ResourceConstants.SCOPE_GROUP_TEMPLATE, "0", role.getRoleId(), actions);
						currentCompanyActions = ResourcePermissionLocalServiceUtil.getAvailableResourcePermissionActionIds(resource.getCompanyId(), resource.getName(), ResourceConstants.SCOPE_COMPANY, String.valueOf(resource.getCompanyId()), role.getRoleId(), actions);
					}
				}
				else {
					List<Permission> permissions = PermissionLocalServiceUtil.getRolePermissions(role.getRoleId(), resource.getResourceId());

					currentIndividualActions = ResourceActionsUtil.getActions(permissions);

					try {
						Resource groupResource = ResourceLocalServiceUtil.getResource(resource.getCompanyId(), resource.getName(), ResourceConstants.SCOPE_GROUP, String.valueOf(groupId));

						permissions = PermissionLocalServiceUtil.getRolePermissions(role.getRoleId(), groupResource.getResourceId());

						currentGroupActions = ResourceActionsUtil.getActions(permissions);
					}
					catch (NoSuchResourceException nsre) {
						currentGroupActions = new ArrayList<String>();
					}

					try {
						Resource groupTemplateResource = ResourceLocalServiceUtil.getResource(resource.getCompanyId(), resource.getName(), ResourceConstants.SCOPE_GROUP_TEMPLATE, "0");

						permissions = PermissionLocalServiceUtil.getRolePermissions(role.getRoleId(), groupTemplateResource.getResourceId());

						currentGroupTemplateActions = ResourceActionsUtil.getActions(permissions);
					}
					catch (NoSuchResourceException nsre) {
						currentGroupTemplateActions = new ArrayList<String>();
					}

					try {
						Resource companyResource = ResourceLocalServiceUtil.getResource(resource.getCompanyId(), resource.getName(), ResourceConstants.SCOPE_COMPANY, String.valueOf(resource.getCompanyId()));

						permissions = PermissionLocalServiceUtil.getRolePermissions(role.getRoleId(), companyResource.getResourceId());

						currentCompanyActions = ResourceActionsUtil.getActions(permissions);
					}
					catch (NoSuchResourceException nsre) {
						currentCompanyActions = new ArrayList<String>();
					}
				}

				List<String> currentActions = new ArrayList<String>();

				currentActions.addAll(currentIndividualActions);
				currentActions.addAll(currentGroupActions);
				currentActions.addAll(currentGroupTemplateActions);
				currentActions.addAll(currentCompanyActions);

				List<String> guestUnsupportedActions = ResourceActionsUtil.getResourceGuestUnsupportedActions(portletResource, modelResource);

				for (String action : actions) {
					boolean checked = false;
					boolean disabled = false;
					String preselectedMsg = StringPool.BLANK;

					if (currentIndividualActions.contains(action)) {
						checked = true;
					}

					if (currentGroupActions.contains(action) || currentGroupTemplateActions.contains(action)) {
						checked = true;
						preselectedMsg = "x-is-allowed-to-do-action-x-in-all-items-of-type-x-in-x";
					}

					if (currentCompanyActions.contains(action)) {
						checked = true;
						preselectedMsg = "x-is-allowed-to-do-action-x-in-all-items-of-type-x-in-this-portal-instance";
					}

					if (name.equals(RoleConstants.GUEST) && guestUnsupportedActions.contains(action)) {
						disabled = true;
					}

					if (action.equals(ActionKeys.ACCESS_IN_CONTROL_PANEL)) {
						disabled = true;
					}

					/*Hook modification*/	
					boolean present = true;
					if(actionsParam!=null){
						present = false;
						for(String actiontmp : actionstmp){
							if(actiontmp.equals(action)){
								present = true;
								break;
							}
						}
					}
					
					if(present){
				%>

					<liferay-ui:search-container-column-text
						buffer="buffer"
						name="<%= ResourceActionsUtil.getAction(pageContext, action) %>"
					>

						<%
						buffer.append("<input ");

						if (checked) {
							buffer.append("checked ");
						}

						if (Validator.isNotNull(preselectedMsg)) {
							buffer.append("class=\"lfr-checkbox-preselected\" ");
						}

						if (disabled) {
							buffer.append("disabled ");
						}

						buffer.append("id=\"");
						buffer.append(FriendlyURLNormalizerUtil.normalize(role.getName()));

						if (Validator.isNotNull(preselectedMsg)) {
							buffer.append("_PRESELECTED_");
						}
						else {
							buffer.append("_ACTION_");
						}

						buffer.append(action);
						buffer.append("\" ");

						buffer.append("name=\"");
						buffer.append(role.getRoleId());

						if (Validator.isNotNull(preselectedMsg)) {
							buffer.append("_PRESELECTED_");
						}
						else {
							buffer.append("_ACTION_");
						}

						buffer.append(action);
						buffer.append("\" ");

						if (Validator.isNotNull(preselectedMsg)) {
							buffer.append("onclick=\"return false;\" onmouseover=\"Liferay.Portal.ToolTip.show(this, '");
							buffer.append(UnicodeLanguageUtil.format(pageContext, preselectedMsg, new Object[] {role.getTitle(locale), ResourceActionsUtil.getAction(pageContext, action), Validator.isNull(modelResource) ? selResourceDescription : ResourceActionsUtil.getModelResource(locale, resource.getName()), HtmlUtil.escape(group.getDescriptiveName(locale))}));
							buffer.append("'); return false;\" ");
						}

						buffer.append("type=\"checkbox\" />");
						%>

					</liferay-ui:search-container-column-text>

				<%
					}else{
						if (checked) {
							StringBuilder sb = new StringBuilder();
							sb.append("<input ");
							
							sb.append("value=\"on\" ");
							
							sb.append("id=\"");
							sb.append(FriendlyURLNormalizerUtil.normalize(role.getName()));
							
							if (Validator.isNotNull(preselectedMsg)) {
								sb.append("_PRESELECTED_");
							}
							else {
								sb.append("_ACTION_");
							}
	
							sb.append(action);
							sb.append("\" ");
	
							sb.append("name=\"");
							sb.append(role.getRoleId());
	
							if (Validator.isNotNull(preselectedMsg)) {
								sb.append("_PRESELECTED_");
							}
							else {
								sb.append("_ACTION_");
							}
	
							sb.append(action);
							sb.append("\" ");
							
	
							sb.append("type=\"hidden\" />");
							%><%=sb.toString() %><%
						}
					}
				/*End Hook modification*/
				}
				%>

			</liferay-ui:search-container-row>

			<liferay-ui:search-iterator paginate="<%= false %>" searchContainer="<%= searchContainer %>" />
		</liferay-ui:search-container>

		<br />

		<aui:button-row>
			<aui:button type="submit" />
		</aui:button-row>
	</aui:form>
</div>