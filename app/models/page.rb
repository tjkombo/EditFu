require 'hpricot'

class Page < ActiveRecord::Base
  IMAGE_ATTRIBUTES = ['src', 'alt']

  belongs_to :site
  validates_presence_of :path
  validates_uniqueness_of :path, :scope => :site_id

  named_scope :enabled, :conditions => { :enabled => true }

  def url
    File.join(site.http_url, path)
  end

  def sections
    elements(false).map { |element| element.inner_html }
  end

  def sections=(htmls)
    update_elements(false, htmls) do |element, html| 
      element.inner_html = html
    end
  end

  def images
    elements(true).map do |element| 
      result = {}
      IMAGE_ATTRIBUTES.each { |k| result[k] = element[k] || '' }
      result
    end
  end

  def images=(elements)
    update_elements(true, elements) do |img, attributes| 
      attributes.each { |k,v| img.attributes[k.to_s] = v }
    end
  end

  def has_suspicious_sections?
    elements(false).any? { |e| !['div', 'span'].include?(e.pathname) }
  end

  protected

  def before_save
    self.path = self.path.strip.sub(/^\//, '').sub(/\/$/, '')
  end

  private

  def document
    @document ||= Hpricot(content) 
  end

  def elements(img)
    nodes = (document / '.editfu')
    nodes.select do |e| 
      !nested_node?(e, nodes) && (e.pathname == 'img') == img
    end
  end

  def nested_node?(node, nodes)
    p = node.parent
    while p do
      return true if nodes.include?(p)
      p = p.parent
    end
  end

  def update_elements(img, values)
    elements(img).each_with_index do |element, index|
      yield element, values[index]
    end
    self.content = document.to_html
  end
end
