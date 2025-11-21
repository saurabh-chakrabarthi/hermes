module MyApplication
  class << self
    def root
      File.dirname(__FILE__) + '/..'
    end

    def views_path
      root + '/app/views'
    end

    def public_folder
      root + '/public'
    end
  end
end
