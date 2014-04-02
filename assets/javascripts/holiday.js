$(document).ready(function(){
   $(function() {
 		$( "#leave_date" ).datepicker({
    dateFormat: "yy-mm-dd",
		changeMonth: true,
		changeYear: true,
		minDate: "-12M",
		showOn: 'button',
    buttonImage: '/images/calendar.png',
    buttonImageOnly: true
    });
	});
});

$(document).ready(function(){
   $(function() {
 		$( "#holiday_holiday_date" ).datepicker({
    dateFormat: "yy-mm-dd",
		changeMonth: true,
		changeYear: true,
		minDate: "0",
		showOn: 'button',
    buttonImage: '/images/calendar.png',
    buttonImageOnly: true
    });
	});
});
