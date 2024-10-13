package com.tokio.vida.portlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.liferay.portal.kernel.model.User;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCResourceCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCResourceCommand;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.tokio.pa.cotizadorModularServices.Bean.VidaSolCambio;
import com.tokio.pa.cotizadorModularServices.Bean.VidaSolCambioResponse;
import com.tokio.pa.cotizadorModularServices.Bean.VidaTablasPerfilesPermisos;
import com.tokio.pa.cotizadorModularServices.Interface.VidaSolCambioAuto;
import com.tokio.vida.constants.VidaSolCambioAutoPortletKeys;

import java.io.PrintWriter;
import java.util.List;

import javax.portlet.PortletSession;
import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

@Component(
	    immediate = true,
	    property = {
	        "javax.portlet.name="+VidaSolCambioAutoPortletKeys.VIDASOLCAMBIOAUTO,
	        "mvc.command.name=/cambioEstatus"
	    },
	    service = MVCResourceCommand.class
	)

/*
 * Ernaes Antonio Trujillo Vizuet 11/09/2022
 * Cambia el estatus de la solicitud (nEstatus=1:Autorizada,nEstatus=2:Rechazada)
 */
public class VidaSolCambioAutoEstaResourceCommand extends  BaseMVCResourceCommand {
	@Reference
	VidaSolCambioAuto vidaSolCambioAuto;
	
	@Override
	protected void doServeResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
			throws Exception {
		
		int idSol=ParamUtil.getInteger(resourceRequest,"idSol");	
		int nEstatus=ParamUtil.getInteger(resourceRequest,"nEstatus");	
		
		HttpServletRequest originalRequest = PortalUtil.getOriginalServletRequest(PortalUtil.getHttpServletRequest(resourceRequest));
	
		
		List<VidaTablasPerfilesPermisos> lstPermisos=(List<VidaTablasPerfilesPermisos>)resourceRequest.getPortletSession(true).getAttribute("VidaTabPer",PortletSession.APPLICATION_SCOPE);
		
		JsonObject respuesta = new JsonObject();
		PrintWriter writer = resourceResponse.getWriter();
		
		
		User user = (User) resourceRequest.getAttribute(WebKeys.USER);
		String usuario = user.getScreenName();
		
		int idPerfilUser =0;
		if(originalRequest.getSession().getAttribute("idPerfil")!=null) {
			idPerfilUser= (int) originalRequest.getSession().getAttribute("idPerfil");
		}
		
		if(lstPermisos.size()>0) {	
			try {
				VidaSolCambioResponse vida =vidaSolCambioAuto.cambioEstatusSolicitud(idSol, nEstatus, idPerfilUser, usuario, VidaSolCambioAutoPortletKeys.VIDASOLCAMBIOAUTO);
				if(vida.getCode()==0) {
					//TODO Envio de email
					
				}
				respuesta.addProperty("code", vida.getCode());
				respuesta.addProperty("msg", vida.getMsg());				
				
			}catch(Exception ex) {
				respuesta.addProperty("code", 2);
				respuesta.addProperty("msg", "Error al consultar su información");
			}
		}else {
			respuesta.addProperty("code", 3);
			respuesta.addProperty("msg", "No tiene permisos de acceso");
		}
		
		writer.write(respuesta.toString());
		
	}

}
