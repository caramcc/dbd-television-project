require 'capybara'
require 'capybara/poltergeist'

include Capybara::DSL
Capybara.default_driver = :poltergeist


Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {js_errors: false})
end

output_file = '../caramcc_twitter_handles.json'

show_data = {}
network_data = {}
networks = []

# 20 pages of data
(1..20).each do |pagenum|
  url = "http://fanpagelist.com/category/tv-shows/view/list/sort/followers/page#{pagenum}"

  visit url

  all('.listing_profile').each do |listing|

    show_title = listing.find('.title').text


    network = ''
    begin
      listing.all('.description a').each do |link|
        if link.text != 'TV Show'
          network = link.text
          networks.push network
        end
      end
    rescue Capybara::ElementNotFound
      puts "no network or description for #{show_title}"
    end

    begin
      twitter_link = listing.find('.profile_follow_action a')['href']
      twitter_handle = twitter_link.sub('http://twitter.com/intent/user?screen_name=', '@')

      if networks.include? show_title
        network_data[show_title] = {
            network: network,
            twitter_handle: twitter_handle
        }
      else
        show_data[show_title] = {
            network: network,
            twitter_handle: twitter_handle
        }
      end

    rescue Capybara::ElementNotFound
      puts "no twitter handle for #{show_title}, skipping"
    end

  end
end

# go over show data once more to make sure no networks got in
show_data.each do |key, value|
  if networks.include? show_data[key]
    network_data[key] = value
    show_data.delete key
  end
end

out_data = {
    show_data: show_data,
    network_data: network_data
}

File.open(output_file, 'w') { |file| file.write(JSON.pretty_generate(out_data)) }