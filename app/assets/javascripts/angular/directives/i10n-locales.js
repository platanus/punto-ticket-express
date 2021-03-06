//= require ./i10n

angular.module('puntoTicketApp.directives')
	.config(['$i10nProvider', function($i10nProvider) {
		$i10nProvider.register({
			es: {
				common: {
					error: {
						invalid: {
							required: 'Este campo es obligatorio',
							rut: 'El RUT ingresado es inválido',
							email: 'El email ingresado es inválido',
							phone: 'El teléfono ingresado es inválido',
							chilean_mobile: 'El teléfono móvil ingresado es inválido',
							job_start_today: 'La fecha de inicio debe ser mayor o igual a la fecha actual',
							job_end_after_start: 'La fecha de termino debe ser mayor o igual a la de inicio.',
							min: 'Debe ingresar un valor mayor',
							url: 'La url ingesada es inválida',
              date_greater_than_today: 'Debe ser mayor que el día de hoy',
              event_end_after_start: 'La fecha de inicio debe ser menor que la de fin',
              event_end_time_after_start: 'La hora de inicio debe ser menor que la de fin',
              invalid_promo_config: 'El valor ingresado es inválido para el tipo de descuento'
						}
					}
				},
			},
			en: {
				common: {
					error: {
						invalid: {
							required: 'Required field',
							rut: 'RUT invalid',
							email: 'E-mail invalid',
							phone: 'Phone invalid',
							chilean_mobile: 'Mobile phone invalid',
							job_start_today: 'Date must be grater than today',
							job_end_after_start: 'End date must be grater than start date'
						}
					}
				}
			}
		});
	}]);
