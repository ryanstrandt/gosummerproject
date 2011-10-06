$(function(){
	// Set starting slide to 1
	var startSlide = 1;
	// Get slide number if it exists
	if (window.location.hash) {
		startSlide = window.location.hash.replace('#','');
	}
	// Initialize Slides
	$('#slides').slides({
		preload: true,
		preloadImage: 'img/loading.gif',
		generatePagination: true,
		play: 5000,
		pause: 2500,
		hoverPause: true,
		// Get the starting slide
		start: startSlide,
	});
});

$(function(){
	$('#faqAccordion h2').click(function() {
		$(this).next().toggle('slow');
		return false;
	}).next().hide();
});
