module FormHelper
  def control_group form, attr, control, options = {}
    haml_tag :div, class: "control-group #{error_for(form, attr)}" do
    	haml_concat(render_label(form, attr, options))
      haml_tag :div, class: 'controls' do
      	haml_concat(control)
      	haml_concat(error_label(form, attr))
    	end
    end
  end

  def render_label form, attr, options
    if !options.has_key? :ignore_required and
      ((options.has_key? :required and options[:required]) or
      form.object.class.required? attr)
      label = "#{form.object.class.human_attribute_name(attr)} *"
      return label_tag(nil, label, class: 'control-label')
    end

    form.label(attr, class: 'control-label')
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

  def build_control f, name, type
    case type.to_s
    when 'string'
      return f.text_field name, :class => 'input-xlarge'
    when 'integer'
      return f.text_field name, :type => 'number', :class => 'input-xlarge'
    else
      return f.text_field name, :class => 'input-xlarge'
    end
  end
end
