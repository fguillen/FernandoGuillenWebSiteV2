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
    elsif capitalized == "Dates"
      "<li class=\"list-group-item\"><strong>#{capitalized}:</strong> #{badge(value)} </li>"
    elsif capitalized == "Technology"
      badges = value.split(",").map { |e| badge_unstyled(e.strip, StylePalette.brush(e.strip, :tags3).style) }
      "<li class=\"list-group-item\"><strong>#{capitalized}:</strong> #{badges.join(" ") } </li>"
    else
      "<li class=\"list-group-item\"><strong>#{capitalized}:</strong> #{markdown(value)}</li>"
    end
  end

  def badge(text)
    "<span class=\"badge rounded-pill bg-warning text-dark\">#{text}</span>"
  end

  def badge_unstyled(text, style)
    "<span class=\"badge rounded-pill\" style=\"#{style}\">#{text}</span>"
  end

  def random_icon
    ICONS.sample
  end
end
