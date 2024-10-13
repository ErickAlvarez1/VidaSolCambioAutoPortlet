<%@ include file="/init.jsp" %>
<jsp:include page="modales.jsp" />
<portlet:resourceURL id="/obtenerDetalle" var="detalleURL" cacheability="FULL" />
<portlet:resourceURL id="/cambioEstatus" var="cambioEstatusURL" cacheability="FULL" />
<style>

.site-wrapper .md-form {
    position: relative;
    margin-top: 0;
    margin-bottom: 0;

}
</style>
<div class="section-heading">
	<div class="container-fluid">
		<h1 class="title text-primary text-center">
			Solicitud de Cambios (Perfiles, Tablas Auto Administrables y Catálogos SA)
		</h1>
	</div>
</div>
<div class="container">
<table id="dtSolCambioAuto" class="table table-striped table-bordered table-sm" cellspacing="0" width="100%">
    <thead>
      <tr>
        <th class="th-sm" style="width:100px;">No</th>
        <th class="th-sm">Fecha</th>
        <th class="th-sm">Usuario Solicitante</th>
        <th class="th-sm">Correo</th>
        <th class="th-sm">Tipo de Cambio</th>
        <th class="th-sm">Estatus</th>
        <th class="th-sm">Acciones</th>     
      </tr>
    </thead>
    <tbody>
    <c:forEach items="${lista}" var="curr">
    	<tr>
    		<td>${curr.idSol }</td>
    	    <td><fmt:formatDate value="${curr.fecha}" pattern="dd/MM/yy HH:mm" /></td>
    		<td>${curr.usuarioSolicita }</td>
    		<td>${curr.correo }</td>
    		<td><strong>${curr.tipoCambio }</strong></td>
    		<td>
    			<c:if test="${ curr.estatus =='PENDIENTE' }">
    				<span class="badge badge-pill badge-warning" style="font-size:12px;">${curr.estatus }</span>
    			</c:if>
    			
    			<c:if test="${ curr.estatus =='AUTORIZADA' }">
    				<span class="badge badge-pill badge-success" style="font-size:12px;">${curr.estatus }</span>
    			</c:if>
    			
    			<c:if test="${ curr.estatus =='RECHAZADA' }">
    				<span class="badge badge-pill badge-danger" style="font-size:12px;">${curr.estatus }</span>
    			</c:if>
    		</td>
    		<td><a href="javascript:void(0);" onclick="abrirDetalle(${curr.idSol});" class="btn btn-blue">Detalle</a></td>
    	</tr>
    </c:forEach>
    </tbody>
    <tfoot>
      <tr>
      	<th style="width:100px;">No</th>
      	<th>Fecha</th>
        <th>Usuario Solicitante</th>
        <th>Correo</th>       
        <th>Tipo de Cambio</th>
        <th>Estatus</th>
        <th>Acciones</th>
      </tr>
    </tfoot>
  </table>
 </div>
 
 <script>
 var detalleURL="${detalleURL}";
 var cambioEstatusURL="${cambioEstatusURL}";
 
 function cambioEstatus(idSol,nEstatus){
	 showLoader();
		$.get( cambioEstatusURL,{idSol,nEstatus}).done( function(data) {
			if(data!=""){
				var response = JSON.parse(data);			
				if(response.code==0){	
					 $("#modalMsg").html(info('Exito','El estatus se cambio con exito'));
					 location.reload();
				}else{
					 hideLoader();	 
					 $("#modalMsg").html(alert('Error',response.msg));
				}	
			}else{
				 hideLoader();	 
				 $("#modalMsg").html(alert('Error','No hay datos de respuesta'));
			}
		});	
 }
 
 function agregaAcciones(id,idSol){
	var autorizar = $('<input/>').attr({
         type: "button",
         class:"btn btn-success",
         value: "Autorizar",
         onclick: "cambioEstatus("+idSol+",1);"
    });
	
	var rechazar = $('<input/>').attr({
        type: "button",
        class:"btn btn-danger",
        value: "Rechazar",
        onclick: "cambioEstatus("+idSol+",2);"
   });
	 
	 $("#"+id).append(autorizar);
	 $("#"+id).append(rechazar);
 }
 
 function abrirDetalle(idSol){
	showLoader();
	$.get( detalleURL,{idSol}).done( function(data) {
		if(data!=""){
			var response = JSON.parse(data);				
			if(response.code==0){					
				 var solicitud=JSON.parse(response.solicitud.replaceAll('\\','').replaceAll('"[','[').replaceAll(']"',']'));				
				 $("#txtUsuarioSol").val(solicitud.usuarioSolicita);
				 $("#txtCorreo").val(solicitud.correo);
				 $("#txtTipoCambio").val(solicitud.tipoCambio);
				 $("#divEstatus").removeClass("badge-warning");
				 $("#divEstatus").removeClass("badge-success");
				 $("#divEstatus").removeClass("badge-danger");
				 $("#btnAcciones").html("");
				 $("#modalMsg").html("");
				 if(solicitud.estatus=='PENDIENTE'){
					 $("#divEstatus").addClass("badge-warning");
					 agregaAcciones("btnAcciones",idSol);
				 }
				 if(solicitud.estatus=='AUTORIZADA'){					
					 $("#divEstatus").addClass("badge-success");
				 }
				 if(solicitud.estatus=='RECHAZADA'){				
					 $("#divEstatus").addClass("badge-danger");
				 }
				 
				 $("#divEstatus").html(solicitud.estatus);
				 $('#tablaDetalleBody').html("");				
				 if(solicitud.idSolTipo>=6 && solicitud.idSolTipo<=10){
					 GeneraTablaCatalogoSA(solicitud);					 
				 }else{
					 var tabla=` <table class="table table-sm table-striped" id="tablaDetalle">
						  <thead>
						    <tr>
						      <th scope="col"><strong>#</strong></th>
						      <th scope="col"><strong>Parámetro</strong></th>
						      <th scope="col"><strong>Valor Actual</strong></th>
						      <th scope="col"><strong>Valor Nuevo</strong></th>
						    </tr>
						  </thead>
						  <tbody id="tablaDetalleBody">
						   
						  </tbody>
						</table>`;
					 $("#divDet").html(tabla); 
					 solicitud.parametrosMod.forEach(function(it){
						 $('#tablaDetalleBody').append('<tr><td>'+it.num+'</td><td>'+it.parametro+'</td><td>'+it.valorActual+'</td><td>'+it.valorNuevo+'</td></tr>');				 
					 });
				 }
				 
				 hideLoader();	 
				 $("#modalDetalle").modal("show");
			}else{
				 hideLoader();	 
				 $("#modalMsg").html(alert('Error',response.msg));
			}	
		}else{
			 hideLoader();	 
			 $("#modalMsg").html(alert('Error','No hay datos de respuesta'));
		}
	});	
 }
 
 function GeneraTablaCatalogoSA(solicitud){
	 $("#divDet").html(""); 
	 var tableHead='';					      
	 var tableFood='';
	 var tableRow='';
	 
	 if(solicitud.idSolTipo==6){
		 tableHead=`<table class="table table-bordered table-responsive-md table-striped text-center">
	  	        <thead>
			        <tr>
			         
			          <th class="text-center" data-override="descripcion">Es el producto</th>
			          <th class="text-center" data-override="pruestaDeCambioDes">Propuesta de cambio</th>
			          <th class="text-center" data-override="codigo">SAProducto</th>
			          <th class="text-center" data-override="pruestaDeCambioValors">Propuesta de cambio</th>					          
			        </tr>
			      </thead>
			      <tbody>`;   
		
			tableFood=`</tbody></table>`;
			      
			solicitud.detalleSA.forEach(function(ele,index){
				tableRow+=`<tr>								
								<td class="pt-3-half">\${ele.descripcion==undefined?'':ele.descripcion}</td>
								<td class="pt-3-half">\${ele.pruestaDeCambioDes==undefined?'':ele.pruestaDeCambioDes}</td>
								<td class="pt-3-half">\${ele.codigo==undefined?'':ele.codigo}</td>
								<td class="pt-3-half">\${ele.pruestaDeCambioValors==undefined?'':ele.pruestaDeCambioValors}</td>
							  </tr>`;  			    
				
			});
	 }
	 
	 if(solicitud.idSolTipo==7){
		 tableHead=`<table class="table table-bordered table-responsive-md table-striped text-center">
	  	        <thead>
			        <tr>			         
			          <th class="text-center" data-override="descripcion1">SATipEnd</th>
			          <th class="text-center" data-override="pruestaDeCambioValors1">Propuesta de cambio</th>			         
			          <th class="text-center" data-override="descripcion2">SATipEnd</th>
			          <th class="text-center"  data-override="pruestaDeCambioValors2">Propuesta de cambio</th>					          
			        </tr>
			      </thead>
			      <tbody>`;   
			      
			      solicitud.detalleSA.forEach(function(ele,index){
					 if(ele.codigo=="1"){			 	
						 tableRow+='<tr>';
			  				tableRow+=`		  							
			  							<td class="pt-3-half">\${ele.descripcion}</td>
			  							<td class="pt-3-half">\${ele.pruestaDeCambioValors===undefined?'':ele.pruestaDeCambioValors}</td>`;  	
					    	
					    	
							var result = solicitud.detalleSA.find(obj => {
							    return obj.idCatalogoPadreId === ele.idCatalogoDetalle;
							});							
							if(result!=undefined){
								tableRow+=`							
										<td class="pt-3-half">\${result.descripcion}</td>
										<td class="pt-3-half">\${result.pruestaDeCambioValors===undefined?'':result.pruestaDeCambioValors}</td>`; 
							}  				
							tableRow+='</tr>'; 	
				     }
			      });
	 }
	 
	 if(solicitud.idSolTipo==8){
		 
		 var tabPaqHFam='';
		 var tabPaqBFam='';
		 var tabPaqFFam='';
		
		 var tabProdHead='';
		 var tabProdBody='';
		 var tabProdFood='';
		 
		 tabPaqHFam=`<table class="table table-bordered table-responsive-md  text-center"><tbody>`;  
		 
		 solicitud.detalleSA.filter(e=>e.codigo=='-3').forEach(function(ele,index){
			 tabPaqBFam+=`<tr>			    			
						<td class="pt-3-half">\${ele.descripcion}</td>
						<td class="pt-3-half">\${ele.pruestaDeCambioCod}</td>
						<td class="pt-3-half" style="width:300px;">\${ele.pruestaDeCambioDes==undefined?'':ele.pruestaDeCambioDes}</td>							
					  </tr>`; 
		 });
		 
		 tabPaqFFam=`</tbody></table><p></p>`;
		 
		 tableHead=`<table class="table table-bordered table-responsive-md table-striped text-center">
	  	        <thead>
			        <tr>	  			      
			          <th class="text-center" data-override="descripcion">Validaciones suma asegurada </th>
			          <th class="text-center" data-override="valors">Importes vigentes<br/>suma asegurada (USD)</th>
			          <th class="text-center" data-override="pruestaDeCambioValors">Propuesta de cambio</th>  			          				          
			        </tr>
			      </thead>
			      <tbody>`;   
			
	      solicitud.detalleSA.filter(e=>e.codigo=='-1').forEach(function(ele,index){
	    	tableRow+=`<tr>			    			
					<td class="pt-3-half">\${ele.descripcion}</td>
					<td class="pt-3-half">\${ele.valors}</td>
					<td class="pt-3-half">\${ele.pruestaDeCambioValors==undefined?'':ele.pruestaDeCambioValors}</td>							
				  </tr>`; 
 			  });
		      
		tableFood=`</tbody></table>`;
		
		tabProdHead=`<table class="table table-bordered table-responsive-md table-striped text-center">
			 	       <thead>
				        <tr>	  			      
				          <th class="text-center" data-override="descripcion">Criterio de selecion de cotizador por max<br/>suma asegurada (USD)</th>
				          <th class="text-center" data-override="valors">Propuesta de cambio</th>
				          <th class="text-center" data-override="valors">SACritSACot</th>
				          <th class="text-center" data-override="pruestaDeCambioValors">Propuesta de cambio</th>  			          				          
				        </tr>
				      </thead>
				      <tbody>`; 
				      
	      solicitud.detalleSA.filter(e=>e.codigo=='-2').forEach(function(ele,index){
	    	 tabProdBody+=`<tr>			    			
					<td class="pt-3-half">\${ele.descripcion}</td>
					<td class="pt-3-half">\${ele.pruestaDeCambioDes}</td>
					<td class="pt-3-half">\${ele.valors}</td>
					<td class="pt-3-half">\${ele.pruestaDeCambioValors==undefined?'':ele.pruestaDeCambioValors}</td>							
				  </tr>`; 
 			  });
				      
		tabProdFood=`</tbody></table>`;
		
		tableHead=(tabPaqHFam+tabPaqBFam+tabPaqFFam)+tableHead;
		tableFood+=(tabProdHead+tabProdBody+tabProdFood);
	 }
	 
	 if(solicitud.idSolTipo==9){
		 tableHead=`<table class="table table-bordered table-responsive-md table-striped text-center">
	  	        <thead>
			        <tr>	  			      
			          <th class="text-center" data-override="valors">Criterio de avance de obra</th>
			          <th class="text-center" data-override="pruestaDeCambioValors">Propuesta de cambio</th>  			          				          
			        </tr>
			      </thead>
			      <tbody>`;   
			
			      solicitud.detalleSA.forEach(function(ele,index){
			    	 
			    	if(ele.descripcion==="SI") {
	  			    	tableRow+=`<tr>	  			    								
								<td class="pt-3-half">\${ele.valors}</td>
								<td class="pt-3-half">\${ele.pruestaDeCambioValors}</td>							
							  </tr>`; 
	  			    	}
	  				});			    
				      
				tableFood=`</tbody></table>`;
	 }
	 
	 if(solicitud.idSolTipo==10){
		 tableHead=`<table class="table table-bordered table-responsive-md table-striped text-center">
	  	        <thead>
			        <tr>	  			     
			          <th class="text-left" data-override="valors">Tipo de Obra</th>
			          <th class="text-left" data-override="pruestaDeCambioValors">Propuesta de cambio</th>  			          				          
			        </tr>
			      </thead>
			      <tbody>`;   
			
			      solicitud.detalleSA.forEach(function(ele,index){
			    	tableRow+=`<tr>			    			
							<td class="pt-3-half">\${ele.valors}</td>
							<td class="pt-3-half">\${ele.pruestaDeCambioValors==undefined?'':ele.pruestaDeCambioValors}</td>							
						  </tr>`; 
	  			});
				      
				tableFood=`</tbody></table>`;	 
				
	 }
	 
	 $("#divDet").html(tableHead+tableRow+tableFood);
	 
 }
 
 function info(titulo,mensage){
		return `<p><div class="alert alert-primary alert-dismissible fade show" role="alert">
		  <strong>\${titulo}</strong> \${mensage}<button type="button" class="close" data-dismiss="alert" aria-label="Close">
		    <span aria-hidden="true">&times;</span>
		    </button></div></p>`;
 }
 
 function alert(titulo,mensage){
		return `<p><div class="alert alert-warning alert-dismissible fade show" role="alert">
		  <strong>\${titulo}</strong> \${mensage}<button type="button" class="close" data-dismiss="alert" aria-label="Close">
		    <span aria-hidden="true">&times;</span>
		    </button></div></p>`;
  }
 
 $(document).ready(function () {
	  $('#dtSolCambioAuto').DataTable({
		  "order": [[ 0, "desc" ]],
		  "language": {
		      "search": "Buscar:",
		      "lengthMenu": "Mostrar _MENU_ registros por página",
		      "zeroRecords": "Nada encontrado - lo siento",
		      "info": "Mostrar página _PAGE_ de _PAGES_",
		      "infoEmpty": "No hay registros disponibles.",
		      "infoFiltered": "(filtered from _MAX_ total records)",
		      "paginate": {
		        "next": "Próximo",
		        "previous": "Previo"
		      },
		  }
	  });
	  $('.dataTables_length').addClass('bs-select');
	});
 </script>