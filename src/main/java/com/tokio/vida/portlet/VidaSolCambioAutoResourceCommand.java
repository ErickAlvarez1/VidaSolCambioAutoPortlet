package com.tokio.vida.portlet;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.liferay.portal.kernel.model.User;
import com.liferay.portal.kernel.portlet.bridges.mvc.BaseMVCResourceCommand;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCResourceCommand;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.PortalUtil;
import com.liferay.portal.kernel.util.WebKeys;
import com.tokio.pa.cotizadorModularServices.Bean.SolAutoCatalogo;
import com.tokio.pa.cotizadorModularServices.Bean.VidaSolCambio;
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
	        "mvc.command.name=/obtenerDetalle"
	    },
	    service = MVCResourceCommand.class
	)


/*
 * Ernaes Antonio Trujillo Vizuet 11/09/2022
 * Obtiene una Solicitud de Cambio a utorizar
 */
public class VidaSolCambioAutoResourceCommand extends  BaseMVCResourceCommand{
	@Reference
	VidaSolCambioAuto vidaSolCambioAuto;
	
	@Override
	protected void doServeResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse)
			throws Exception {
		int idSol=ParamUtil.getInteger(resourceRequest,"idSol");	
		
		HttpServletRequest originalRequest = PortalUtil.getOriginalServletRequest(PortalUtil.getHttpServletRequest(resourceRequest));
		List<VidaTablasPerfilesPermisos> lstPermisos=(List<VidaTablasPerfilesPermisos>)resourceRequest.getPortletSession(true).getAttribute("VidaTabPer",PortletSession.APPLICATION_SCOPE);
		
		User user = (User) resourceRequest.getAttribute(WebKeys.USER);
		String usuario = user.getScreenName();
		
		JsonObject respuesta = new JsonObject();
		PrintWriter writer = resourceResponse.getWriter();
		
		int idPerfilUser =0;
		if(originalRequest.getSession().getAttribute("idPerfil")!=null) {
			idPerfilUser= (int) originalRequest.getSession().getAttribute("idPerfil");
		}
		
		if(lstPermisos.size()>0) {		
			try {
				VidaSolCambio vida =vidaSolCambioAuto.obtenerSolicitud(idSol, idPerfilUser, usuario, VidaSolCambioAutoPortletKeys.VIDASOLCAMBIOAUTO);
				System.out.println(vida.getCode());
				if(vida.getCode()==0) {
					Gson gson = new Gson();					
					String jsonString = gson.toJson(vida);	
					System.out.println(jsonString);
					respuesta.addProperty("solicitud", jsonString);
					respuesta.addProperty("code", 0);
					respuesta.addProperty("msg", "ok");
				}else {
					respuesta.addProperty("code", vida.getCode());
					respuesta.addProperty("msg", vida.getMsg());
				}
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
