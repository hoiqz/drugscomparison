##***********IMPORTANT!!**************
# before running this script. you need to sort the review file from oldest to newest.
## do sed '1!G;h;$!d' <filename> >outfilefile
## also edit the source id  with the drug id from webmd
## edit the total reviews number
## edit the generic name

#ARGV[0]= input file path
#ARGV[1]=  source. eg webmd askapatient..
#ARGV[2]=  source_id. for each db they have a different source id. we need them
#ARGV[3]=  total_reviews. integer
class Convert2seed


tablename1="Drug"
tablename2="Condition"
tablename3="Review"
generic_name=""
web_source= ARGV[1] #edit this if you are running for other sources. current accepts askapatient  everydayhealth webmd
source_id=ARGV[2] # declare empty first. if empty we will check the db for it.
total_reviews=ARGV[3].to_i  # our total reviews
source_reviews=ARGV[4].to_i  # number of review the source have
#webmd=true
#askapatient=false
#everydayhealth=false

@urltable=Hash.new
@urltable={"%21"=>"!",
           "%22"=>"\"",
           "%23"=>"#",
           "%24"=>"$",
           "%25"=>"%",
           "%26"=>"&",
           "%27"=>"'",
           "%28"=>"(",
           "%29"=>")",
           "%2A"=>"*",
           "%2B"=>"+",
           "%2C"=>",",
           "%2D"=>"-",
           "%2E"=>".",
           "%2F"=>"/",
           "%5B"=>"[",
           "%5C"=>"\\",
           "%5D"=>"]",
           "%5E"=>"^",
           "%5F"=>"_",
           "%60"=>"`"
}

OUT=File.new("webmd_seeds.txt","a+")
#OUT.write("#{tablename}.delete_all\n")
header=nil

def self.escape_characters_in_string(string)
  pattern = /(\'|\"|\*|\/|\-|\\|\#|\@|\$|\%|\&)/
  string.gsub(pattern){|match|"\\"  + match} # <-- Trying to take the currently found match and add a \ before it I have no idea how to do that).
end

def self.urldecode(str)
  # always  first replace the + with space . then do the urldecode method  if not the encoded "+" will be gone
  str2=str.gsub(/\+/," ")
  #puts "#{str2}"
  str2.to_enum(:scan,  /%../i ).map {
    matched=Regexp.last_match.to_s
    pattern=matched
    replace=@urltable["#{matched}"]
    #puts replace
    if replace
      str2=str2.gsub(/#{Regexp.escape(pattern)}/,"#{replace}")
      #  puts "check ->#{str2} pattern -> #{pattern}"
    end
  }
  #print "#{str}=> #{str2}"
  return str2
end

def self.generate_url(source,page_constant,target_review,total_rev,source_reviews)
  total_reviews=total_rev+1
  offset=source_reviews-total_reviews
  pageoffset=(offset/page_constant).ceil
  pageindex=((total_reviews-target_review)/page_constant).floor
  pagelink=pageoffset+pageindex
  #reviews_to_skip=total_reviews-target_review
  #pages_to_skip=(reviews_to_skip/page_constant).floor
  if source=='webmd'
    page_to_link=pagelink        # webmd starts from zero page onwards!
    return page_to_link
  elsif source=='askapatient'

  elsif source=='everydayhealth'
  else
  end
end
filebasename=File.basename(ARGV[0])
if filebasename=~/^(.*)?_reviews/
  extracted_name=$1
end
brand_name=urldecode(extracted_name)
File.open(ARGV[0],"r") do |filereader|
  i=0
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
      #brand_name=urldecode(values[0])

      OUT.write("#{tablename1}.where(brand_name: \"#{brand_name}\").first_or_create(generic_name: \"#{generic_name}\", brand_name: \"#{brand_name}\", source_id: \"#{source_id}\")\n")
      OUT.write("newdrug=Drug.find_by_brand_name(\"#{brand_name}\")\n")
      OUT.write("Condition.where(name: \"#{values[0]}\").first_or_create(name: \"#{values[0]}\")\n")
      OUT.write("if newdrug.conditions.find_by_name(\"#{values[0]}\").nil?\n")
      OUT.write("newdrug.conditions << Condition.find_by_name(\"#{values[0]}\")\n")
      OUT.write("end\n")

      if values[1]=~/^(.*)?,/
      userinfo=escape_characters_in_string($1)  if $1
      OUT.write("User.where(username: \"#{userinfo}\").first_or_create(username: \"#{userinfo}\",")
        if userinfo=~/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
          email=userinfo
          #print "has email detected #{email}"
          OUT.write("email_address: '#{userinfo}',")
        else
          OUT.write("")
        end
      else
        dateTime=Time.new
        timestamp=dateTime.to_time.to_i
        #userinfo="visitor"+"#{timestamp}"
        userinfo="guest"
        OUT.write("User.where(username: \"#{userinfo}\").first_or_create(username: \"#{userinfo}\", ")
      end
      print "\n"

      dosage=nil

      if values[1]=~/(Caregiver|Patient)/
        patient_type=$1
        #puts patient_type
        dosage=values[1].gsub(/\(#{patient_type}\)/,"")
       # puts "is a #{patient_type}, has take drug for #{dosage}"
        if patient_type ==  "" || patient_type == "Patient"
        OUT.write("caregiver:false, ")
        else
          OUT.write("caregiver:true, ")
        end

      end

      OUT.write("age: '#{values[6]}',gender: '#{values[5]}') {|user| newuser=user}\n")

      #fix the date time  into rails time format : 2012-12-21 06:11:53
      mydatetime=values[7]
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
      if web_source=="webmd"
        reviews_per_page=5
        target_review=i
        page_to_link=generate_url(web_source,reviews_per_page,target_review,total_reviews,source_reviews)
        review_url="http://www.webmd.com/drugs/drugreview-#{source_id}-#{extracted_name}.aspx?drugid=#{source_id}&drugname=#{extracted_name}&pageIndex=#{page_to_link}&sortby=3&conditionFilter=-1"
      elsif web_source=="askapatient"
        reviews_per_page=60
        target_review=i
        page_to_link=generate_url(web_source,reviews_per_page,target_review,total_reviews,source_reviews)
        review_url="http://www.askapatient.com/viewrating.asp?drug=#{source_id}&name=#{extracted_name}&page=#{page_to_link}"
      elsif web_source=="everydayhealth"


      end
      #clean the comments
      newcomments=escape_characters_in_string(values[8])  if values[8]
      #OUT.write("newuser=User.last\n")
      # create review
      OUT.write("newuser.reviews.create(comments: \"#{newcomments}\",effectiveness: #{values[2]}, ease_of_use: #{values[3]}, satisfactory: #{values[4]}, created_at: '#{formateddate}', review_url: \"#{review_url}\", drug_id:newdrug.id)\n")
    end
    i=i+1
  }
end

   end