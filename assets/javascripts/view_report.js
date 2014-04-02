$(document).ready(function(){
$('#name_wise').hide();
$('#designation_wise').hide();
	if($('#leave_employee_name_wise').is(':checked')) {
  		$('#name_wise').show();
   	}
  if($('#leave_employee_designation_wise').is(':checked')) {
  		$('#designation_wise').show();
   	}
	$('input[name="leave[employee]"]').change(function() {
    var isRevision = $('input:checked[name="leave[employee]"]').val() == "designation_wise";
	    $('#name_wise').toggle(!isRevision);
	    $('#designation_wise').toggle(isRevision);
	});
  $('#user_id').change(function(){
    user_id = $(this).val();
    if(user_id == ""){
      $("a#view_report").hide();
    }
    else{
      $("a#view_report").show();
      var url = "/leave/report/"+$(this).val()+"?report=byhr%2Fadmin";
      $("a#view_report").attr("href",url);
    }
  });
});
