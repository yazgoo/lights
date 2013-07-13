class FileLister < HomeModule
    def setup
        sense "list", :period => {:seconds => 10} do |name|
            Dir.chdir(@params) { |p| Dir["*.mp4"] }
        end
    end
end
