module CustomHelpers
  def markdown(text)
    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer)

    markdown.render(text)
  end

  def project_detail(name, value)
    capitalized = name.split('_').map{ |e| e.capitalize }.join(" ")
    "<li class=\"list-group-item\"><strong>#{capitalized}:</strong> #{value}</li>"
  end
end
