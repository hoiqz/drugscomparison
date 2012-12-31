##***********IMPORTANT!!**************
# before running this script. you need to sort the review file in ascending order by time.
## do sed '1!G;h;$!d' <filename> >outfilefile

tablename1="Drug"
tablename2="Condition"
tablename3="Review"
generic_name="amphetamine and dextroamphetamine"
source_id="63164"
total_reviews=578
webmd=true
askapatient=false
everydayhealth=false

OUT=File.new("seeds.txt","w")
#OUT.write("#{tablename}.delete_all\n")
header=nil

def generate_url(source,page_constant,target_review,total_reviews)
  reviews_to_skip=total_reviews-target_review
  pages_to_skip=(reviews_to_skip/page_constant).floor
  if source=='webmd'
    page_to_link=pages_to_skip        # webmd starts from zero page onwards!
    return page_to_link
  elsif source=='askapatient'

  elsif source=='everydayhealth'
  else
  end
end

File.open(ARGV[0],"r") do |filereader|
  i=1
  filereader.each {|line|

    if line=~/^#/
      #puts line
      edited=line.sub(/^#/,"")
      header=edited.chomp.split(/\t/)
      # puts defined?header
      next
    else
      # create the drug table
      OUT.write("#. . .\n")

      values=line.chomp.split(/\t/)
      size=((values.size) -1 )
      # puts "size of array is #{size}"
      brand_name=values[0].gsub(/\+/," ")
      OUT.write("#{tablename1}.where(brand_name: '#{brand_name}').first_or_create(generic_name: '#{generic_name}', brand_name: '#{brand_name}', source_id: '#{source_id}')\n")
      OUT.write("newdrug=Drug.last\n")
      OUT.write("Condition.where(name: '#{values[1]}').first_or_create(name: '#{values[1]}')\n")
      OUT.write("newdrug.conditions << Condition.find_by_name(\"#{values[1]}\")\n")

      if values[2]=~/^(.*)?,/
      userinfo=$1
      OUT.write("User.where(username: \"#{userinfo}\").first_or_create(username: \"#{userinfo}\",")
        if userinfo=~/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
          email=userinfo
          print "has email detected #{email}"
          OUT.write("email_address: '#{userinfo}',")
        else
          OUT.write("")
        end
      else
        dateTime=Time.new
        timestamp=dateTime.to_time.to_i
        userinfo="visitor"+"#{timestamp}"
        OUT.write("User.where(username: \"#{userinfo}\").first_or_create(username: \"#{userinfo}\", ")
      end
      print "\n"

      dosage=nil

      if values[2]=~/(Caregiver|Patient)/
        patient_type=$1
        puts patient_type
        dosage=values[2].gsub(/\(#{patient_type}\)/,"")
        puts "is a #{patient_type}, has take drug for #{dosage}"
        if patient_type ==  "" || patient_type == "Patient"
        OUT.write("caregiver:false, ")
        else
          OUT.write("caregiver:true, ")
        end

      end

      OUT.write("age: '#{values[7]}',gender: '#{values[6]}')\n")

      #fix the date time  into rails time format : 2012-12-21 06:11:53
      mydatetime=values[8]
      mydatetime=~/(\d+)\/(\d+)\/(\d+)\s(\d+):(\d+):(\d+)\s([A|P]M)/
        month=$1
        month="0#{month}" if month.length <2
        date=$2
        date="0#{date}" if date.length <2
        year=$3
        hour=$4.to_i
        min=$5
        sec=$6
        type=$7
      if type == 'PM'
        hour=hour+12
      else
        hour="0#{hour}"
      end
      formateddate="#{year}-#{month}-#{date} #{hour}:#{min}:#{sec}"
      #puts formateddate

      #formats the path for web md
      if webmd
        reviews_per_page=5
        target_review=i
        page_to_link=generate_url('webmd',reviews_per_page,target_review,total_reviews)
        review_url="http://www.webmd.com/drugs/drugreview-#{source_id}-#{values[0]}.aspx?drugid=#{source_id}&drugname=#{values[0]}&pageIndex=#{page_to_link}&sortby=3&conditionFilter=-1"
      elsif askapatient
        reviews_per_page=60
        target_review=i
        page_to_link=generate_url('askapatient',reviews_per_page,target_review,total_reviews)
        review_url="http://www.askapatient.com/viewrating.asp?drug=#{source_id}&name=#{values[0]}&page=#{page_to_link}"
      elsif everydayhealth


      end
      #clean the comments
      newcomments=values[9]#.gsub(/'/,"\\'") if values[9]
      OUT.write("newuser=User.last\n")
      # create review
      OUT.write("newuser.reviews.create(comments: \"#{newcomments}\",effectiveness: #{values[3]}, ease_of_use: #{values[4]}, satisfactory: #{values[5]}, created_at: '#{formateddate}', review_url: '#{review_url}', drug_id:newdrug.id)\n")
    end
    i=i+1
  }
end

