#! /usr/bin/env ruby

require "nokogiri"
require "open-uri"
require "json"
require "yaml"

class Scraper
  def initialize(url, data_path, images_path)
    @url = url
    @data_path = data_path
    @images_path = images_path
  end

  def run
    projects = extract_projects(@url)
    save_projects(projects, @data_path)
    save_images(projects, @images_path)
  end

  def extract_projects(url)
    doc = Nokogiri::HTML(URI.open(url))
    projects = []

    doc.css(".proyecto").each do |project|
      image = project.css(".imagen a")[0]["href"].split("/").last
      name = project.css("h4")[0].text

      text = project.css(".texto > p:not(.quote-sign)").select { |e| e.css("b").length.zero? }.map{ |e| e.text.split("\n").map(&:strip).join(" ") }.join("\n\n")

      quotes = extract_quotes(project)
      details = extract_details(project)

      project = {
        name: name,
        image: image,
        text: text,
        details: details
      }

      project[:quotes] = quotes unless quotes.empty?

      projects.push(project)
    end

    projects
  end

  def extract_quotes(project)
    project.css("blockquote").each_with_index.map do |quote, index|
      author = {}
      author[:name] = project.css(".quote-sign a", ".quote-sign strong")[index].text
      author[:link] = project.css(".quote-sign a")[index]["href"] unless project.css(".quote-sign a").empty?
      author[:description] = project.css(".quote-sign")[index].text.split(",").last.gsub(/\.$/, "").strip

      {
        text: quote.css("p")[0].inner_html.split("\n").map(&:strip).join(" ").strip,
        author: author
      }
    end
  end

  def extract_details(project)
    details_raw = project.css(".texto > p:not(.quote-sign)").reject { |e| e.css("b").length.zero? }

    details = {}
    details[:status] = details_raw.find { |e| e.css("b").text == "Status:" }.text.gsub("Status:", "").strip.gsub(/\.$/, "") if details_raw.find { |e| e.css("b").text == "Status:" }
    details[:dates] = details_raw.find { |e| e.css("b").text == "Dates:" }.text.gsub("Dates:", "").strip.gsub(/\.$/, "")
    details[:client] = details_raw.find { |e| e.css("b").text == "Client:" }.text.gsub("Client:", "").strip.gsub(/\.$/, "")
    details[:responsibilities] = details_raw.find { |e| e.css("b").text == "Tasks:" }.text.gsub("Tasks:", "").split("\n").map(&:strip).join(" ").strip.gsub(/\.$/, "")
    details[:participation_as] = details_raw.find { |e| e.css("b").text == "Participation as:" }.text.gsub("Participation as:", "").split("\n").map(&:strip).join(" ").strip.gsub(/\.$/, "")
    details[:technology] = details_raw.find { |e| e.css("b").text == "Technology:" }.text.gsub("Technology:", "").strip.gsub(/\.$/, "")
    details[:link] = details_raw.find { |e| e.css("b").text == "See:" }.text.gsub("See:", "").strip.gsub(/\.$/, "") if details_raw.find { |e| e.css("b").text == "See:" }
    details[:code] = details_raw.find { |e| e.css("b").text == "Code:" }.text.gsub("Code:", "").strip.gsub(/\.$/, "") if details_raw.find { |e| e.css("b").text == "Code:" }

    details
  end

  def save_projects(projects, data_path)
    # File.open("#{data_path}/projects.json", "w") { |f| f.write JSON.pretty_generate(projects) }
    File.open(data_path, "w") { |f| f.write YAML.dump(JSON.parse(JSON.generate(projects))) }
  end

  def save_images(projects, images_path)
    projects.each do |project|
      File.open("#{images_path}/#{project[:image]}", "wb") do |f|
        f.write URI.open("http://about.fernandoguillen.info/images/#{project[:image]}").read
      end
    end
  end
end

URL = "http://about.fernandoguillen.info/petprojects.html".freeze
DATA_PATH = "#{__dir__}/../data/pet_projects.yaml".freeze
IMAGES_PATH = "#{__dir__}/../source/images/pet_projects".freeze

# URL = "http://about.fernandoguillen.info/projects.html".freeze
# DATA_PATH = "#{__dir__}/../data/projects.yaml".freeze
# IMAGES_PATH = "#{__dir__}/../source/images/projects".freeze

scraper = Scraper.new(URL, DATA_PATH, IMAGES_PATH)
scraper.run

puts "Done!"
