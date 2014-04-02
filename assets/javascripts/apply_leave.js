$(document).ready(function(){
   $(function() {
 		$( "#systango_hrm_employee_leave_leave_start_date" ).datetimepicker({
    dateFormat: "yy-mm-dd",
		changeMonth: true,
		changeYear: true,
    minDate: '0',
    timeFormat: 'hh:mm tt',
	  currentText: "Current",
		showOn: 'button',
    buttonImage: '/images/calendar.png',
    buttonImageOnly: true
		});
	});
});

$(document).ready(function(){
   $(function() {
 		$( "#systango_hrm_employee_leave_leave_end_date" ).datetimepicker({
    dateFormat: "yy-mm-dd",
		changeMonth: true,
		changeYear: true,
    minDate: '0',
		timeFormat: 'hh:mm tt',
	  currentText: "Current",
		showOn: 'button',
    buttonImage: '/images/calendar.png',
    buttonImageOnly: true
		});
	});
});

$(document).ready(function(){
	$(function() {
		$(".relat__atu").on("change", function(){
	  	$("#referral_apply").toggle($(this).hasClass("relat__atu_yes"));
		});
	});
});


$(document).ready(function() {  
	$("#half_day").click(function() {
		if($(this).is(':checked'))
		{
			alert('Do not forget to select time.');    
		}
	});
});

$(document).ready(function(){
	if ($("#apply_leave_refer").is(':checked') == true) {
		$("#referral_apply").show();
		$("#show_hr_if_referral").show();
		$('#maternity_leave').hide();
	}
	else{
		$("#show_hr_if_referral").hide();
		$('#maternity_leave').show();
	}
	$(function() {
		$(".relat__atu").on("change", function(){
	  		$("#referral_apply").toggle($(this).hasClass("relat__atu_yes"));
	  		if ($("#apply_leave_refer").is(':checked') == true) {
	  			$("#show_hr_if_referral").show();
	  			$('#maternity_leave').hide();
  			}
  			else{
  				$("#show_hr_if_referral").hide();
  				$('#maternity_leave').show();
  			}
		});
	});
});
