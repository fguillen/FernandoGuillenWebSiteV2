#! /usr/bin/env ruby

require "nokogiri"
require "open-uri"
require "json"

# Fetch and parse HTML document
doc = Nokogiri::HTML(URI.open("http://about.fernandoguillen.info/projects.html"))

# Search for nodes by css
doc.css(".proyecto").each do |project|
  image = project.css(".imagen a")[0]["href"]
  name = project.css("h4")[0].text

  text = project.css("p").select { |e| e.css("b").length.zero? }.map{ |e| e.text.split("\n").map(&:strip).join(" ") }.join("\n")
  details_raw = project.css("p").reject { |e| e.css("b").length.zero? }

  quotes = project.css("blockquote").each_with_index.map do |quote, index|
    author = {}
    author[:name] = project.css(".quote-sign a", ".quote-sign strong")[index].text
    author[:link] = project.css(".quote-sign a")[index]["href"] unless project.css(".quote-sign a").empty?
    author[:description] = project.css(".quote-sign")[index].text.split(",").last.gsub(/\.$/, "").strip

    {
      text: quote.css("p")[0].inner_html.split("\n").map(&:strip).join(" ").strip,
      author: author
    }
  end

  details = {}
  details[:dates] = details_raw.find { |e| e.css("b").text == "Dates:" }.text.gsub("Dates:", "").strip.gsub(/\.$/, "")
  details[:client] = details_raw.find { |e| e.css("b").text == "Client:" }.text.gsub("Client:", "").strip.gsub(/\.$/, "")
  details[:responsibilities] = details_raw.find { |e| e.css("b").text == "Tasks:" }.text.gsub("Tasks:", "").split("\n").map(&:strip).join(" ").strip.gsub(/\.$/, "")
  details[:participation_as] = details_raw.find { |e| e.css("b").text == "Participation as:" }.text.gsub("Participation as:", "").split("\n").map(&:strip).join(" ").strip.gsub(/\.$/, "")
  details[:technology] = details_raw.find { |e| e.css("b").text == "Technology:" }.text.gsub("Technology:", "").strip.gsub(/\.$/, "")
  details[:link] = details_raw.find { |e| e.css("b").text == "See:" }.text.gsub("See:", "").strip.gsub(/\.$/, "") if details_raw.find { |e| e.css("b").text == "See:" }
  details[:code] = details_raw.find { |e| e.css("b").text == "Code:" }.text.gsub("Code:", "").strip.gsub(/\.$/, "") if details_raw.find { |e| e.css("b").text == "Code:" }

  result = {
    name: name,
    image: image,
    text: text,
    details: details,
    quotes: quotes
  }

  puts JSON.pretty_generate(result)
end
