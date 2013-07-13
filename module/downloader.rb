require 'net/http'
require 'uri'
class Downloader < HomeModule
    def setup
        download_threads = {}
        action :download, {:parameters => {:url => {:type => :string}}},
            Proc.new { |name, url|
            url = URI url
            redirected = true
            while redirected
                Net::HTTP.start(url.host) do |http|
                    http.request_get(url.request_uri) do |resp|
                        if resp.header.code.to_i != 302
                            name = resp.header['Content-Disposition'].scan(/filename="([^"]+)"/)[0][0]
                            Thread.kill(download_threads[name]) if not download_threads[name].nil?
                            download_threads[name] = Thread.new do
                                redirected = false
                                Thread.current.instance_variable_set("@csize", 0)
                                Thread.current.instance_variable_set("@size", resp.header.content_length)
                                begin
                                    path = "#{@params}/#{name}"
                                    f = open path, "w"
                                    resp.read_body do |segment|
                                        Thread.current.instance_variable_set("@csize", Thread.current.instance_variable_get("@csize") + segment.size)
                                        f.write segment
                                    end
                                ensure
                                    f.close
                                end
                                download_threads[name] = nil
                            end
                        else
                            url = URI resp.header['Location']
                        end
                    end
                end
            end
        }
    end
end

