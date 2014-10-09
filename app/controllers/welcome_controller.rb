class WelcomeController < ApplicationController
    before_action :init_twitter

    # get 'welcome/index'
    def index
        recent_media = Instagram.tag_recent_media('nycc')
        @images = Array.new

        recent_media.map do |image|
            img = Hash.new

            img[:text] = image.caption.text if image.caption?
            img[:image_url] = image.images.standard_resolution.url
            
            @images << {
                text: image.caption? ? image.caption.text : nil,
                image_url: image.images.standard_resolution.url,
                timestamp: image.created_time.to_i,
                link: image.link,
                source: 'instagram',
                user: image.user.username
            }
        end

        tweets = @client.search("#nycc AND photo +exclude:retweets", :result_type => "recent").take(20)

        tweets.each do |tweet|
            if tweet.media.count > 0 && tweet.media[0].media_uri?
                @images << { 
                    text: tweet.text,
                    image_url: tweet.media[0].media_uri.to_s,
                    timestamp: tweet.created_at.strftime('%s').to_i,
                    link: tweet.uri,
                    source: 'twitter',
                    user: tweet.user.screen_name
                }
            end
        end

        FlickRaw.api_key="2ddad46edede61633126a2a5ba14ed8d"
        FlickRaw.shared_secret="8e1feee7136867fd"

        
        flickrImages = flickr.photos.search(text: "nycc", privacy_filter: 1, extras: "owner_name, date_upload").take(20)

        flickrImages = flickrImages.map do |image|
            { 
                image_url: "https://farm#{image.farm}.staticflickr.com/#{image.server}/#{image.id}_#{image.secret}_m.jpg",
                text: image.title,
                timestamp: image.dateupload.to_i,
                link: "https://www.flickr.com/photos/#{image.owner}/#{image.id}",
                source: "flickr",
                user: image.ownername
            }
        end

        flickrImages.each { |img| @images << img }

        @images.sort! do |x,y|
            x[:timestamp] <=> y[:timestamp]
        end

        respond_to do |format|
            format.html
            format.json { render json: @images }
        end
    end    

    # get 'welcome/sandbox'
    def sandbox
        FlickRaw.api_key="2ddad46edede61633126a2a5ba14ed8d"
        FlickRaw.shared_secret="8e1feee7136867fd"

        
        @images = flickr.photos.search(text: "nycc", privacy_filter: 1, extras: "owner_name, date_upload").take(100)

        @images = @images.map do |image|
            { 
                image_url: "https://farm#{image.farm}.staticflickr.com/#{image.server}/#{image.id}_#{image.secret}_m.jpg",
                text: image.title,
                timestamp: image.dateupload.to_i,
                link: "https://www.flickr.com/photos/#{image.owner}/#{image.id}",
                source: "flickr",
                user: image.ownername
            }
        end


        respond_to do |format|
            format.html
            format.json { render json: @images }
        end
    end

    # get 'welcome/tweets'
    def tweets
        tweets = @client.search("#nycc AND photo +exclude:retweets", :result_type => "recent").take(20)

        @tweets = Array.new

        p tweets

        tweets.each do |tweet|
            p tweet
            if tweet.media.count > 0 && tweet.media[0].media_uri?
                @tweets.push({ 
                    text: tweet.text,
                    image_url: tweet.media[0].media_uri
                })
            end
        end

        respond_to do |format|
            format.html { render 'tweets' }
            format.json { render json: tweets }
        end
    end
    
    # get 'welcome/instagram'
    def instagram

        @tags = Instagram.tag_recent_media('nycc')

        respond_to do |format|
            format.html { render 'tweets' }
            format.json { render json: @tags }
        end
    end

    private

    # Initialize the twitter API
    def init_twitter
        @client = Twitter::REST::Client.new do |config|
            config.consumer_key    = "RMIm7PREKRNaU3ZhutxNKlnvr"
            config.consumer_secret = "JQNFlmN7ilCdIRqRGbC9I369PyNqzz1IdD2BHmOb2e54HbgyJ6"
        end 
    end
end
