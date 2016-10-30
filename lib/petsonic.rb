require 'bundler/setup'

require "petsonic/version"

require 'uri'
require 'curb'
require 'nokogiri'
require 'csv'

require 'pry'

module Petsonic
  Item = Struct.new(:title, :picture, :price, :weight)

  class Reader
    attr_reader :url, :filename, :items, :domain

    def initialize(url, filename)
      uri = URI(url)
      @domain = "#{uri.scheme}://#{uri.host}"

      @url = url
      @filename = filename
      @items = []
    end

    def parse
      items.clear
      parse_page(url)
      items
    end

    def parse_page(page_url)
      puts "Parse page: #{page_url}"

      page = Curl.get(page_url)
      html = Nokogiri::HTML(page.body_str)
      links = html.xpath("//div[@class='productlist']//a[@class='product-name']").to_a

      links.each do |link|
        product_page = Curl.get(link['href'])
        section_html = Nokogiri::HTML(product_page.body_str)
        title = section_html.xpath("//div[@class='product-name']//h1//text()")[4]

        weight_section = section_html.xpath("//ul[@class='attribute_labels_lists']//li")
        weight_section.each do |node|
          picture = node.xpath("//img[@id='bigpic']//@src")
          price = node.xpath(".//span[@class='attribute_price']//text()")
          weight = node.xpath(".//span[@class='attribute_name']//text()")

          items << Item.new(title.to_s.strip,
                            picture.to_s.strip,
                            price.to_s.strip,
                            weight.to_s.strip)
        end
      end

      # relative next path
      next_page = html.xpath("//li[@id='pagination_next_bottom']//a//@href")
      return if next_page.empty?
      parse_page("#{domain}#{next_page.to_s.strip}")
    end

    def store!
      CSV.open(filename, "wb") do |csv|
        csv << ["Title", "Picture", "Price"]

        items.each do |item|
          csv << [item.title + " - " + item.weight, item.picture, item.price]
        end
      end
    end
  end

end
