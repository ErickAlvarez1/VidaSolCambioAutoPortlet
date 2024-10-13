package com.tokio.vida.portlet;

import com.tokio.pa.cotizadorModularServices.Bean.VidaSolCambio;
import com.tokio.pa.cotizadorModularServices.Bean.VidaSolCambioResponse;
import com.tokio.pa.cotizadorModularServices.Bean.VidaTablasAutoAdministrablesResponse;
import com.tokio.pa.cotizadorModularServices.Bean.VidaTablasPerfilesPermisos;
import com.tokio.pa.cotizadorModularServices.Interface.VidaSolCambioAuto;
import com.tokio.pa.cotizadorModularServices.Interface.VidaTablasAutoAdmin;
import com.tokio.vida.constants.VidaSolCambioAutoPortletKeys;

import java.util.List;

import com.liferay.portal.kernel.model.User;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;
import com.liferay.portal.kernel.servlet.SessionErrors;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.WebKeys;

import javax.portlet.Portlet;
import javax.portlet.PortletException;
import javax.portlet.PortletSession;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

/**
 * @author ERNAES TRUJILLO
 */
@Component(
	immediate = true,
	property = {
		"com.liferay.portlet.display-category=category.sample",
		"com.liferay.portlet.header-portlet-css=/css/main.css",
		"com.liferay.portlet.instanceable=true",
		"javax.portlet.display-name=VidaSolCambioAuto",
		"javax.portlet.init-param.template-path=/",
		"javax.portlet.init-param.view-template=/view.jsp",
		"javax.portlet.name=" + VidaSolCambioAutoPortletKeys.VIDASOLCAMBIOAUTO,
		"javax.portlet.resource-bundle=content.Language",
		"javax.portlet.init-param.add-process-action-success-action=false",
		"com.liferay.portlet.requires-namespaced-parameters=false",
		"javax.portlet.security-role-ref=power-user,user"
	},
	service = Portlet.class
)
public class VidaSolCambioAutoPortlet extends MVCPortlet {
	@Reference
	VidaTablasAutoAdmin vidaTablasAutoAdmin; 
	@Reference
	VidaSolCambioAuto vidaSolCambioAuto;
	
	
	/*
	 * Ernaes Antonio Trujillo Vizuet 11/09/2022
	 * Enlista las solicitudes de cambio a autorizar
	 */
	
	@Override
	public void doView( RenderRequest renderRequest, RenderResponse renderResponse) 
			throws  PortletException, java.io.IOException {
		HttpServletRequest originalRequest = PortalUtil.getOriginalServletRequest(PortalUtil.getHttpServletRequest(renderRequest));
		
		
		User user = (User) renderRequest.getAttribute(WebKeys.USER);
		String usuario = user.getScreenName();
		
		int idPerfilUser =0;
		int rowNum=0;
		
		if(originalRequest.getSession().getAttribute("idPerfil")!=null) {
			idPerfilUser= (int) originalRequest.getSession().getAttribute("idPerfil");
		}
		
		try {
			VidaTablasAutoAdministrablesResponse permisos=vidaTablasAutoAdmin.obtenerPermisos(user.getEmailAddress(), VidaSolCambioAutoPortletKeys.TIPOPERMISO);
			if(permisos.getCode()==0) {
				List<VidaTablasPerfilesPermisos> lstPermisos=permisos.getPermisos();
				renderRequest.getPortletSession(true).setAttribute("VidaTabPer", lstPermisos, PortletSession.APPLICATION_SCOPE);	
				
				if(lstPermisos.size()>0) {
					VidaTablasPerfilesPermisos permiso=lstPermisos.get(0);
					renderRequest.setAttribute("accesoLectura", 1);
					VidaSolCambioResponse respuesta=vidaSolCambioAuto.obtenerSolicitudes(rowNum, permiso.getIdTipo(), user.getEmailAddress(),  VidaSolCambioAutoPortletKeys.VIDASOLCAMBIOAUTO);
					
					if( respuesta.getCode()==0 ){
						List<VidaSolCambio> lista=respuesta.getLista();						
						renderRequest.setAttribute("lista", lista);
					}else {
						renderRequest.setAttribute("error", 1);
						renderRequest.setAttribute("errorMsg",  respuesta.getMsg() );
						SessionErrors.add(renderRequest, "errorConocido", respuesta.getMsg() );
					}
					
				}else {
					renderRequest.setAttribute("accesoLectura", 0);
					renderRequest.setAttribute("error", 3);
					renderRequest.setAttribute("errorMsg", "No tiene permisos de acceso");
					SessionErrors.add(renderRequest, "errorConocido");
				}
			}else {
				renderRequest.setAttribute("accesoLectura", 0);
				renderRequest.setAttribute("error", 1);
				renderRequest.setAttribute("errorMsg", "Error al Obtener los Permisos del Usuario");
				SessionErrors.add(renderRequest, "errorConocido");
			}
				
		}catch(Exception ex) {
			ex.printStackTrace();
			System.out.println("error");
			System.out.println( ex.getLocalizedMessage() );
			renderRequest.setAttribute("errorMsg",  "Error al consultar la tabla" );
			SessionErrors.add(renderRequest, "errorConocido" );
		}
		
		super.doView(renderRequest, renderResponse);
	}
}