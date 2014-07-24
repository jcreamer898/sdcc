class WelcomeController < ApplicationController
    before_action :init_twitter

    def tweets
        @tweets = Array.new
        
        @client.search("#sdcc AND photo", :result_type => "recent").take(20).each do |tweet|
          @tweets.push tweet
        end
        
        respond_to do |format|
            format.html { render 'tweets' }
            format.json { render json: @tweets }
        end
    end
    
    private

    def init_twitter

        @client = Twitter::REST::Client.new do |config|
          config.consumer_key    = "RMIm7PREKRNaU3ZhutxNKlnvr"
          config.consumer_secret = "JQNFlmN7ilCdIRqRGbC9I369PyNqzz1IdD2BHmOb2e54HbgyJ6"
        end 
    
    end
end
