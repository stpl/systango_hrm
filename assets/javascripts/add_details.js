$(document).ready(function(){
   $(function() {
		$( "#record_date_of_joining" ).datepicker({
    dateFormat: "yy-mm-dd",
		changeMonth: true,
		changeYear: true,
		showOn: 'button',
    buttonImage: '/images/calendar.png',
    buttonImageOnly: true
		});
	});
});

$(document).ready(function(){
   $(function() {
 		$( "#employee_leave_account_date_of_joining" ).datepicker({
    dateFormat: "yy-mm-dd",
		changeMonth: true,
		changeYear: true,
		showOn: 'button',
    buttonImage: '/images/calendar.png',
    buttonImageOnly: true
		});
	});
});

$(document).ready(function(){
   $(function() {
 		$( "#designation_history_applicable_from" ).datepicker({
    dateFormat: "yy-mm-dd",
		changeMonth: true,
		changeYear: true,
		showOn: 'button',
    buttonImage: '/images/calendar.png',
    buttonImageOnly: true
		});
	});
});
