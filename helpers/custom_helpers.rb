module CustomHelpers
  ICONS = [
    "box",
    "bucket",
    "circle",
    "diamond",
    "egg",
    "flower3",
    "flower1",
    "gear",
    "heart",
    "hexagon",
    "puzzle"
  ]

  def markdown(text)
    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer)

    markdown.render(text)
  end

  def project_detail(name, value)
    capitalized = name.split('_').map(&:capitalize).join(" ")

    if value =~ /^http/
      "<li class=\"list-group-item\"><strong>#{capitalized}:</strong> <a href=\"#{value}\">#{value}</a></li>"
    else
      "<li class=\"list-group-item\"><strong>#{capitalized}:</strong> #{markdown(value)}</li>"
    end
  end

  def random_icon
    ICONS.sample
  end
end
