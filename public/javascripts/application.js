$(function(){
	// Set starting slide to 1
	var startSlide = 1;
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
	$('#faqAccordion').accordion({ autoHeight: false });
});
$(function(){
  	$(".tipTip").tipTip({delay: 1});
});
