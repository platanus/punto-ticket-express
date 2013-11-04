module FormHelper
  def control_group form, attr, control, options = {}
    haml_tag :div, class: "control-group #{error_for(form, attr)}" do
    	haml_concat(render_label(form, attr, options))
      haml_tag :div, class: 'controls' do
      	haml_concat(control)
      	haml_concat(error_label(form, attr))
        if options.has_key? :help
          haml_tag :span, class: 'help-block' do
            haml_concat(options[:help])
          end
        end
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

  def build_control f, name, type, html_options = {}
    type = type.to_sym

    if type == :integer
      return f.text_field name, html_options.merge(:type => 'number')

    elsif type == :boolean
      # The following returs NestedResource.genders_to_a if:
      # name param equals to gender
      # f.object.class.name equals to NestedResource
      # We need to have the genders_to_a method defined into NestedResource model.
      return f.select name,
        eval("#{f.object.class.name}.#{name.to_s.pluralize}_to_a"),
        { :include_blank => true }, html_options

    elsif name.to_s.include? 'rut'
      return f.text_field name, html_options.merge('rut' => '', 'render-on-blue' => '', 'ng-model' => 'rut')
    end

    f.text_field name, html_options
  end

  def show_item label, value
    return if value.nil? or value.to_s.empty?
    content_tag :p do
      haml_concat(content_tag(:b){ label })
      haml_concat(value)
    end
  end
end
