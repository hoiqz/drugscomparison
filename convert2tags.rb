ARGV[0]=~/(.*?)_reviews/
brandname=$1
brandname=brandname.gsub(/\+/,' ')
maxsize=20
File.open(ARGV[0],"r") do |filereader|

    wordline=Array.new
    counter=1

   filereader.each do |line|
     if counter == maxsize
       break
     end
     # i want to check that if the count is 1 then dont print it. do some normalization
     arr=line.split(/\t/)
     #if arr[1].to_i <=5
     #  next
     #else
       newvalue=arr[1].to_i
       line2="#{arr[0]}=>#{newvalue}"
       tag=line2.gsub(/,/,'').chomp

       wordline << "#{tag}"
     #end
             counter=counter+1
   end
    wordlist_stringify=wordline.join(',')
    #puts wordlist_stringify

    OUT=File.new("#{brandname}.tags","w")
    OUT.write("Tag.create!(brand_name: \"#{brandname}\", word_list: \"#{wordlist_stringify}\")\n")
end