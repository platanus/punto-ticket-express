// prettyCheckable: customize styles of the checkboxes and radios
$().ready(function(){
  $('input.custom-check').each(function() {
    $(this).prettyCheckable({color: 'yellow'});
  });

	$(':file').filestyle({buttonText: 'Subir logo'});

	if($('.persistent-header').is('*'))
		$(window).scroll(function() {
			if($(window).scrollTop() > 58) {
				$('.persistent-header').addClass('navbar-fixed-top');
				$('body').css('paddingTop', '79px');
			}else{
				$('.persistent-header').removeClass('navbar-fixed-top');
				$('body').css('paddingTop', '0px');
			}
		});
});
