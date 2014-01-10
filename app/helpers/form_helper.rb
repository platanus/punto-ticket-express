module FormHelper
  def control_group form, attr, control, options = {}
    content_tag :div, class: "control-group #{error_for(form, attr)}" do
    	concat(render_label(form, attr, options))
      concat(content_tag(:div, class: 'controls'){
      	concat(control)
      	concat(error_label(form, attr))
        if options.has_key? :help
          concat(content_tag(:span, class: 'help-block'){
            concat(options[:help].html_safe) })
        end
    	})
    end
  end

  def render_label form, attr, options
    if !options.has_key? :ignore_required and
      ((options.has_key? :required and options[:required]) or
      form.object.class.required? attr)
      label = "* #{form.object.class.human_attribute_name(attr)}"
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
    end

    f.text_field name, html_options
  end

  def show_item label, value
    return if value.nil? or value.to_s.empty?
    content_tag :p do
      concat(content_tag(:b){ label })
      concat(" ")
      concat(value)
    end
  end

  # CONTROL GROUP FOR CONTROLS WITHOUT FORM
  def control_group_tag label, control, options = {}
    content_tag :div, class: "control-group #{get_error_class(options[:errors])}" do
      concat(render_label_tag(label, options))
      concat(content_tag(:div, class: 'controls'){
        concat(control)
        concat(error_label_tag(options[:errors]))
      })
    end
  end

  def get_error_class errors
    !errors or errors.size.zero? ? "" : "error"
  end

  def error_label_tag errors
    return if !errors or errors.size.zero?
    messages = errors.join("<br/>")
    content_tag :span, class: 'help-inline' do
      messages.html_safe
    end
  end

  def render_label_tag label, options
    if !options.has_key? :ignore_required and options[:required]
      label = "#{label} *"
    end

    label_tag(nil, label, class: 'control-label')
  end

  def build_control_tag attr, value, type, html_options = {}, options = {}
    type = type.to_sym
    attr = "#{options[:name_prefix]}[#{attr}]" if options[:name_prefix]

    if type == :integer
      return text_field_tag(attr, value, html_options.merge(:type => 'number'))

    elsif type == :boolean
      return select_tag(attr, options_for_select(options[:select_values], value),
        html_options.merge({ :include_blank => true }))
    end

    return text_field_tag(attr, value, html_options)
  end
end
