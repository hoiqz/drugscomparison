OUT=File.new("seedwebmd.txt","w")
File.open(ARGV[0],"r") do |filereader|
  i=1
  filereader.each do |line|
    values=line.chomp.split(/\t/)
    if values[1]=~/drugid=(.*?)&/
      source_id=$1
    end
    OUT.write("Webmd.create!(source_id:'#{source_id}', brand_name:'#{values[0]}' current_reviews: #{values[2]}, latest_reviews: #{values[2]})\n")

  end
end
