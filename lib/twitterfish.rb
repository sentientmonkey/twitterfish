#!/usr/bin/env ruby

require 'rubygems'
require 'twitter'
require 'google_translate'

class Twitterfish
  include GoogleTranslate

  def initialize(twitter)
    @twitter = twitter
  end

  def go_fish(user_name, options={})
    puts "fishing for #{user_name}"
    user = @twitter.user(user_name)
    statuses = @twitter.user_timeline(:id => user_name)

    from = options[:from]
    to = options[:to] || "en"
    from ||= LanguageDetect.detect(user.status.text)

    translator = Translator.new(from, to)
    statuses.each do |status|
      status.text = translator.translate(status.text)
    end
    [user, statuses]
  end
end
