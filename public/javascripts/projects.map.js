// Global variable
var map;
// Initialize Google Map
function init() {
	// Draw the map (blank)
	var map_focus = new google.maps.LatLng(35,-37);
	var myOptions = { zoom: 2,center: map_focus,mapTypeId: google.maps.MapTypeId.ROADMAP };  
	map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
	$('#map_overlay').hide();
	$('#map_overlay').css('visibility', 'visible');
}

// Parse XML of project locations to create map markers
function getMarkers() {
	// Check session variable 'parsed' to see if markers have already been parsed
  // $.ajax({
  //  url: "../get_status.php",
  //  success: function(status){
  //    eval(status);
  //    // If markers haven't been parsed, display loading overlay
  //    if( $.trim(parsed) != "true" ) {
  //      $('#map_overlay').fadeIn(500);
  //    }
  //  }
  // });
  // // Generate marker code
  // $.ajax({
  //  url: "../get_locations.php",
  //  success: function(markers){
  //    eval(markers);
  //    $('#map_overlay').fadeOut(500);
  //  }
  // });
}