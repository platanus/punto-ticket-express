// prettyCheckable: customize styles of the checkboxes and radios
$().ready(function(){
	$('input.custom-check').prettyCheckable({
		color: 'yellow'
	});

	$(':file').filestyle({buttonText: 'Subir logo'});

	if($('.persistent-header').is('*'))
		$(window).scroll(function() {
			if($(window).scrollTop() > 58) {
				$('.persistent-header').addClass('navbar-fixed-top');
				$('body').css('paddingTop', '59px');
			}else{
				$('.persistent-header').removeClass('navbar-fixed-top');
				$('body').css('paddingTop', '0px');
			}
		});
});