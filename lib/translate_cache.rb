#!/usr/bin/env ruby

require 'rubygems'
require 'google_translate'
require 'memcache'
require 'digest/md5'

class TranslateCache
  include GoogleTranslate

  def initialize(from, to, options = {})
    @from = from
    @to = to
    host = options[:host] || 'localhost:11211'
    namespace = options[:namespace] || 'translatecache'
    @expiration = options[:expiration] || 0
    @translator = Translator.new(@from, @to)
    @cache = MemCache.new host, :namespace => namespace
  end

  def method_missing(m, *args)
    if m.to_s == 'translate'
      d = Digest::MD5.new
      d << args.first
      checksum = d.hexdigest
      key = "#{@from}_#{@to}_#{checksum}"
      puts "key is #{key}"
      result = @cache.get(key)
      result ||= (
        puts "cache miss for #{key}"
        @cache.set(key, @translator.send(m, *args), @expiration)
      )
      result
    else
      super
    end
  end
end
