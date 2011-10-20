// Initialize datepickers
$(function() {
	$("#datepicker_start").datepicker();
	$("#datepicker_end").datepicker();
	// Set the default end date to 2 months from current date
	$("#datepicker_end").datepicker("setDate", "+2m");
	// Initialize the input/submit button
	$(".dp_button").button();
});
// Process dates when button is clicked
$(function() {
	$(".dp_button").click(function() {
		// Get dates from both datepickers
		var startDate = $("#datepicker_start").datepicker("getDate");
		var endDate = $("#datepicker_end").datepicker("getDate");
		// Add 1 to month number because it is originally 0-relative (i.e. 0 = January)
		var startMonth = startDate.getMonth() + 1;
		var endMonth = endDate.getMonth() + 1;
		// Create string for requested timeframe
		var dataString = 'start_month=' + startMonth + '&start_day=' + startDate.getDate()
			+ '&end_month=' + endMonth + '&end_day=' + endDate.getDate();
		// Call locations.php with query data
		window.location.assign("/projects?" + dataString);
	});
});