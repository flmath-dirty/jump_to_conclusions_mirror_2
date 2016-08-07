// taken from http://bootsnipp.com/snippets/WPBZj
$(document).ready( function() {
    $('#myCarousel').carousel({
	
        interval: false
    });
    
    var clickEvent = false;
    $('#myCarousel')
	.on('click', '.nav a', function() {
	    clickEvent = true;
	    $('.nav li').removeClass('active');
	    $(this).parent().addClass('active');		
	})
	.on('slid.bs.carousel', function(e) {
	    if(!clickEvent) {
		var count = $('.nav').children().length -1;
		var current = $('.nav li.active');
		
	//	console.log(current)
	//	console.log(count)
		var id = parseInt(current.data('slide-to'));
	//	console.log(id)
		
		if(e.direction=="left"){
		    if(count == id) {
			$('.nav li').first().addClass('active');
			current.removeClass('active')
		    } else{
			current.removeClass('active').next().addClass('active');
		    }
		}
		else{
		    if(0 == id) {
			$('.nav li').last().addClass('active');
			current.removeClass('active')	
		    } else{
			current.removeClass('active').prev().addClass('active');}
		}
	    }
	    clickEvent = false;
	});
});
