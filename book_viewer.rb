require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"
require "yaml"

helpers do
  def highlight(text, term)
    text.gsub(term, %(<strong>#{term}</strong>))
  end
  
  def in_paragraph(text)
    text = text.split("\n\n").map.with_index do |string, index|
      "<p id='#{index + 1}'> #{string} </p>"
    end
    text.join
  end

  # Calls the block for each chapter, passing that chapter's number, name, and
  # contents.
  def each_chapter
    @contents.each_with_index do |name, index|
     number = index + 1
     contents = File.read("data/chp#{number}.txt")
      yield number, name, contents
    end
  end

  # This method returns an Array of Hashes representing chapters that match the
  # specified query. Each Hash contain values for its :name and :number keys.
  def chapters_matching(query)
    results = []

    return results if !query || query.empty?

    each_chapter do |number, name, contents|
      results << {number: number, name: name, contents: contents} if contents.include?(query)
    end

    results
  end

  def matching_paragraphs(chapter, query)
    # numbered_paragraphs = chapter[contents].split("\n\n").map.with_index do |paragraph, index|
    #   {contents: paragraph, number: index + 1}
    # end
    # chapter[matching_paragraphs] = numbered_paragraphs.select do |paragraph|
    #   paragraph[contents].include?(query)
    # end
    chapter[:matching_paragraphs] = chapter[:contents].split("\n\n").each_with_object([]).with_index do |(paragraph, arr), index|
      arr << (index + 1 ) if paragraph.include?(query)
      end

    chapter
  end
end

before do 
  @contents = (File.readlines("data/toc.txt"))
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]
  @title = "Chapter #{number}: #{chapter_name}"

  redirect "/" unless (1..@contents.size).cover?(number)

  @chapter = in_paragraph(File.read("data/chp#{number}.txt"))

  erb :chapter
end


get "/search" do
  @results = chapters_matching(params[:query]).map do |chapter|
    matching_paragraphs(chapter, params[:query])
  end
  erb :search
end


# get "/search" do
#   @query_present = params.key?(:query)
#   @query_results = []
  
#   if @query_present
#     arr_of_textfiles = Dir.glob("data/chp*.txt")
#     @query_results = arr_of_textfiles.select { |text| File.read(text).include?(params[:query]) }
#   end

#   erb :search
# end

not_found do
  redirect "/"
end

# get "/:letter" do
#   @title = "Page #{:letter.uppercase}"
#   @contents = (File.readlines("data/toc.txt"))
#   @text = File.read("public/#{:letter}.txt")
#   erb :page
# end

# get "/show/:name" do
#   @title = "The Adventures of Sherlock Holmes"
#   @contents = (File.readlines("data/toc.txt"))
#   @text = params[:name]
#   erb :show
# end

# get "/b" do
#   @title = "Page b"
#   @contents = (File.readlines("data/toc.txt"))
#   @text = File.read("public/b.txt")
#   erb :page
# end
# get "/c" do
#   @title = "Page c"
#   @contents = (File.readlines("data/toc.txt"))
#   @text = File.read("public/c.txt")
#   erb :page
# end
# get "/d" do
#   @title = "Page d"
#   @contents = (File.readlines("data/toc.txt"))
#   @text = File.read("public/d.txt")
#   erb :page
# end
# get "/e" do
#   @title = "Page e"
#   @contents = (File.readlines("data/toc.txt"))
#   @text = File.read("public/e.txt")
#   erb :page
# end