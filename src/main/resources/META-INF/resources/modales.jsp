<div class="modal fade" id="modalDetalle" tabindex="-1" role="dialog" aria-labelledby="modalDetalle"
  aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="modalDetalleLabel">Detalle de la Solicitud</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
       <div id="modalMsg"></div>
       <div class="row">
       		<div class="col">
       			 <label>Usuario Solicitante</label>
       			 <div class="md-form">
       			 	<input type="text" id="txtUsuarioSol" class="form-control" readonly>
       			 </div>
       		</div>
       		<div class="col">
       			 <label>Correo</label>
       			 <div class="md-form">
       			 	<input type="text" id="txtCorreo" class="form-control" readonly>
       			 </div>
       		</div>
       	</div>
       	<div class="row">
       		<div class="col">
       			 <label>Tipo Cambio</label>
       			 <div class="md-form">
       			 	<input type="text" id="txtTipoCambio" class="form-control" readonly>
       			 </div>
       		</div>
       		<div class="col"> 
       		 	<label>Estatus</label>
       			<div class="md-form">      			
       				<span class="badge badge-pill" id="divEstatus" style="font-size:12px;"></span>
       			</div>
       		</div>
       </div><!-- row -->
       <div id="divDet">
	       <table class="table table-sm table-striped" id="tablaDetalle">
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
			</table>
		</div>
      </div>
      <div class="modal-footer">
        
        <div style="width:100%;" class="d-flex justify-content-end">
        	<button type="button" class="btn btn-primary" data-dismiss="modal">Cerrar</button>
        	<div id="btnAcciones">		       
			</div>
		</div>
      </div>
    </div>
  </div>
</div>