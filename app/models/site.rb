class Site < ActiveRecord::Base
  SITES_DIR = 'tmp/sites'
  has_many :pages

  def init
    FtpClient.download self
    create_pages
  end

  def dirname
    File.join SITES_DIR, name
  end

  def mkdir
    FileUtils.mkdir_p dirname
  end

  private

  def create_pages(path=dirname)
    Dir.new(path).each do |filename|
      unless filename == '.' or filename == '..'
        filepath = File.join(path, filename)
        if File.directory?(filepath)
          create_pages filepath
        else
          relpath = filepath[dirname.length + 1, filepath.length]
          page = Page.new(:site => self, :path => relpath)
          pages << page unless page.sections.empty?
        end
      end
    end
  end
end
