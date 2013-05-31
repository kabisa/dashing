require 'net/http'
require 'json'

class TwitterSearch < Dashing::Job

  protected

  def do_execute
    search_term = URI::encode(config[:search_term])

    http = Net::HTTP.new('search.twitter.com')
    response = http.request(Net::HTTP::Get.new("/search.json?q=#{search_term}"))
    tweets = JSON.parse(response.body)["results"]
    if tweets
      tweets.map! do |tweet|
        { name: tweet['from_user'], body: tweet['text'], avatar: tweet['profile_image_url_https'] }
      end

      return { comments: tweets }
    end
  end
end

search_term = URI::encode('#todayilearned')
job = TwitterSearch.new('twitter_mentions', {search_term: search_term})
SCHEDULER.every '10m', :first_in => 0 do
  job.execute
end
