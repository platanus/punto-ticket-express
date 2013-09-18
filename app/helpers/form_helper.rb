module FormHelper
  def control_group form, attr, control
    haml_tag :div, class: 'control-group' do
    	haml_concat(form.label attr, class: 'control-label')
      haml_tag :div, class: 'controls' do
      	haml_concat(control)
    	end
    end
  end
end