module FormHelper
  def control_group form, attr, control
    haml_tag :div, class: "control-group #{error_for(form, attr)}" do
    	haml_concat(form.label attr, class: 'control-label')
      haml_tag :div, class: 'controls' do
      	haml_concat(control)
      	haml_concat(error_label(form, attr))
    	end
    end
  end

  def error_for form, field
    form.object.errors.include?(field.to_sym)? "error" : ""
  end

  def error_label form, field
    errors = ""

    form.object.errors.each do |attr, msg|
      if attr.to_sym == field.to_sym
        errors += "#{msg}<br/>"
      end
    end

    return "" if errors.empty?

    content_tag :span, class: 'help-inline' do
      errors.html_safe
    end
  end
end
