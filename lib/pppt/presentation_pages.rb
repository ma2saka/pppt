class PresentationPages
  attr_reader :data, :size
  def initialize(pages)
    @data = pages
    i = 0
    pages.each { |x| x['page'] = i += 1 unless x['action'] }
    @size = i
  end
end
