// prettyCheckable: customize styles of the checkboxes and radios
$().ready(function(){
	$('input.custom-check').prettyCheckable({
		color: 'yellow'
	});

	$(":file").filestyle({buttonText: "Subir logo"});
});