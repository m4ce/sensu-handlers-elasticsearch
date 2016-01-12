#
# handler-elasticsearch.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

require 'sensu-handler'
require 'net/http'
require 'time'

class HandlerElasticsearch < Sensu::Handler
  option :url,
         :description => "Elasticsearch URL",
         :short => "-u <URL>",
         :long => "--url <URL>",
         :default => "http://localhost:9200"

  option :index,
         :description => "Elasticsearch index (default: sensu-%{Y}.%{m}.%{d})",
         :short => "-i <INDEX>",
         :long => "--index <INDEX>",
         :default => "sensu-%{Y}.%{m}.%{d}"

  option :type,
         :description => "Elasticsearch index type (default: handler)",
         :short => "-t <TYPE>",
         :long => "--type <TYPE>",
         :default => "handler"

  def handle
    event = {
      :@timestamp => Time.at(@event['timestamp']).utc.iso8601,
      :action => @event['action'],
      :occurrences => @event['occurrences'],
      :client => {
        :name => @event['client']['name'],
        :address => @event['client']['address']
      },
      :check => {
        :name => @event['check']['name'],
        :interval => @event['check']['interval'],
        :command => @event['check']['command'],
        :duration => @event['check']['duration'],
        :output => @event['check']['output'].chomp,
        :status => @event['check']['status']
      }
    }

    # interpolate %Y, %m and %d with today's date
    now = Time.now
    index = config[:index] % {:Y => now.strftime('%Y'), :m => now.strftime('%m'), :d => now.strftime('%d')}

    uri = URI("#{config[:url]}/#{index}/#{config[:type]}/#{@event['id']}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
    request.body = JSON.dump(event)

    begin
      resp = http.request(request)
      if resp.code == '200' or resp.code == '201'
        puts "Event posted (Code: #{resp.code}, Reply: #{resp.body})"
      else
        puts "Failed to post event (Code: #{resp.code}, Reply: #{resp.body})"
      end
    rescue
      puts "Failed to post event - Caught exception (#{$!})"
    end
  end
end
