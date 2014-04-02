$(document).ready(function(){
	$('#have_account').hide();
	$('#not_have_account').hide();
	if($('#record_employee_have_account').is(':checked')) {
  		$('#have_account').show();
   	}
  if($('#record_employee_not_have_account').is(':checked')) {
  		$('#not_have_account').show();
   	}
	$('input[name="record[employee]"]').change(function() {
    var isRevision = $('input:checked[name="record[employee]"]').val() == "not_have_account";
	    $('#have_account').toggle(!isRevision);
	    $('#not_have_account').toggle(isRevision);
	});
});
