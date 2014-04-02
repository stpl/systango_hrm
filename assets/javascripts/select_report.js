$(document).ready(function() {
	$('select#user_id').select2({
		allowClear: true,
		placeholder: "Select name",
		width: 'resolve'
		});
});

$(document).ready(function() {
	$('select#designation_id').select2({
		allowClear: true,
		placeholder: "Select name",
		width: 'resolve'
		});
});

$(document).ready(function(){
  $(function() {
   $( "#leave_leave_start_between" ).datepicker({
   	dateFormat: "yy-mm-dd",
   	changeMonth: true,
    changeYear: true,
    dateFormat: "yy-mm-dd",
		showOn: 'button',
    buttonImage: '/images/calendar.png',
    buttonImageOnly: true
   });
  });
});

$(document).ready(function(){
  $(function() {
		$( "#leave_leave_end_between" ).datepicker({
   		dateFormat: "yy-mm-dd",
      changeMonth: true,
      changeYear: true,
      dateFormat: "yy-mm-dd",
  		showOn: 'button',
      buttonImage: '/images/calendar.png',
      buttonImageOnly: true
   	});
  });
});
