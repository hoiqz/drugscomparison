# usage rake source=webmd in=input project:initializeseed
namespace :project do
  desc "Get the source id and current reviews count; then call convert2seed.rb"
  task :initializeseed =>:environment do
    puts "getting source_id"
    source = ENV["source"] ? ENV["source"] : "webmd"
    puts "Source detected: webmd"
    inputdir=ENV["in"]
    OUT=File.new("tmp1","w")
    Dir.mkdir("out_tmp") unless Dir.exist?("out_tmp")
    #open input directory and glob all file
    Dir.glob(inputdir+"/*") {|file|
#      puts file
#do a system call to get the first line of the file and get its name
#firstline=`head -n1 #{file}`
#arr=firstline.chomp.split(/\t/)
#name=arr[0]

# do preprocessing needed for convert2seed.rb
      basename=File.basename("#{file}")

      if basename=~/^(.*)?_reviews/
        name=$1
      end

      system("sed '1!G;h;$!d' #{file} > out_tmp/#{basename}")
      if source == "webmd"
        found= Webmd.find_by_brand_name(name)
        if found
          sourceid=found.source_id
          number_reviews=found.current_reviews
          source_reviews=found.latest_reviews
        else
          name2=name.gsub(/%252/,"%2")   # some names have error in them
          found= Webmd.find_by_brand_name(name2)
          if found
            sourceid=found.source_id
            number_reviews=found.current_reviews
            source_reviews=found.latest_reviews

          else
            OUT.write("#{name} and #{name2} not found! please check\n")
          end
        end

      elsif source == "askapatient"
        found= Askapatient.find_by_brand_name(name)
        if found
          sourceid=found.source_id
          number_reviews=found.current_reviews
        end
      else                # everydayhealth

      end

      #after getting source, time  to pass it to the convert2seed.rb script
      OUT.write("calling convert2seed.rb script for out_tmp/#{basename} #{source} #{sourceid} #{number_reviews} #{source_reviews}\n")
      system("ruby convert2seed.rb out_tmp/#{basename} #{source} #{sourceid} #{number_reviews} #{source_reviews}")
      OUT.write("completed seeding #{name}\n")
    }
    #Dir.delete("out")
  end


  ##############
  ## NEW TASK
  ##############
  # usage rake source=webmd in=input project:loaddata
  desc "task to dump reviews into database"
  task :loaddata =>:environment do
    puts "getting source_id"
    web_source = ENV["source"] ? ENV["source"] : "webmd"
    puts "Source detected: webmd"
    inputdir=ENV["in"]
    OUT=File.new("tmp1","w")
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
               "%2f"=>"/",
               "%5B"=>"[",
               "%5C"=>"\\",
               "%5D"=>"]",
               "%5E"=>"^",
               "%5F"=>"_",
               "%60"=>"`"
    }


    header=nil

    Dir.mkdir("out_tmp") unless Dir.exist?("out_tmp")
    #open input directory and glob all file
    Dir.glob(inputdir+"/*") {|file|
# do preprocessing needed for convert2seed.rb
      basename=File.basename("#{file}")
      if basename=~/^(.*)?_reviews/
        name2=$1
        name=name2.gsub(/%252/,"%2")
      end

      system("sed '1!G;h;$!d' #{file} > out_tmp/#{basename}")
      if web_source == "webmd"
        found= Webmd.find_by_brand_name(name)
        if found
          source_id=found.source_id
          total_reviews=found.current_reviews
          source_reviews=found.latest_reviews
        else
            OUT.write("#{name} and #{name2} not found! please check\n")
        end

      elsif web_source == "askapatient"
        found= Askapatient.find_by_brand_name(name)
        if found
          source_id=found.source_id
          total_reviews=found.current_reviews
        end
      else                # everydayhealth

      end

      #after getting source, time  to pass it to the convert2seed.rb script
      OUT.write("seeding data for out_tmp/#{basename} #{web_source} #{source_id} #{total_reviews} #{source_reviews}\n")
      #system("ruby convert2seed.rb out_tmp/#{basename} #{source} #{sourceid} #{number_reviews} #{source_reviews}")

      # Here begins the main code for  seeding

      tablename1="Drug"
      tablename2="Condition"
      tablename3="Review"
      generic_name=""

      caregiver="true"

      brand_name=urldecode(name)
      Dir.mkdir("out_tmp")
      File.open("out_tmp/#{basename}","r") do |filereader|
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
            #            OUT.write("#. . .\n")

            values=line.chomp.split(/\t/)
            size=((values.size) -1 )
            # puts "size of array is #{size}"
=begin            OUT.write("#{tablename1}.where(brand_name: \"#{brand_name}\").first_or_create(generic_name: \"#{generic_name}\", brand_name: \"#{brand_name}\", source_id: \"#{source_id}\")\n")
            OUT.write("newdrug=Drug.find_by_brand_name(\"#{brand_name}\")\n")
            OUT.write("Condition.where(name: \"#{values[0]}\").first_or_create(name: \"#{values[0]}\")\n")
            OUT.write("if newdrug.conditions.find_by_name(\"#{values[0]}\").nil?\n")
            OUT.write("newdrug.conditions << Condition.find_by_name(\"#{values[0]}\")\n")
            OUT.write("end\n")
=end
            puts "Loading data: #{brand_name} line #{i}"
            newdrug= Drug.find_by_brand_name("#{brand_name}")
            newdrug=Drug.create(generic_name: "#{generic_name}", brand_name: "#{brand_name}", source_id: "#{source_id}") if newdrug.nil?
            newcondition=Condition.find_by_name("#{values[0]}")
            newcondition=Condition.create(name: "#{values[0]}") if newcondition.nil?
            newdrug.conditions << newcondition if   newdrug.conditions.find_by_name("#{values[0]}").nil?

            if !values[1].blank? && values[1]=~/^(.*)?,/
              userinfo=escape_characters_in_string($1)  if $1
              #OUT.write("User.where(username: \"#{userinfo}\").first_or_create(username: \"#{userinfo}\",")

              if userinfo=~/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
                email=userinfo
                #print "has email detected #{email}"
                #OUT.write("email_address: '#{userinfo}',")
                #OUT.write("")
              end
            else
              dateTime=Time.new
              timestamp=dateTime.to_time.to_i
              #userinfo="visitor"+"#{timestamp}"
              userinfo="guest"
              #OUT.write("User.where(username: \"#{userinfo}\").first_or_create(username: \"#{userinfo}\", ")
            end

            dosage=nil

            if !values[1].blank? && values[1]=~/(Caregiver|Patient)/
              patient_type=$1
              #puts patient_type
              dosage=values[1].gsub(/\(#{patient_type}\)/,"")
              # puts "is a #{patient_type}, has take drug for #{dosage}"
              if patient_type ==  "" || patient_type == "Patient"
                #OUT.write("caregiver:false, ")
                caregiver="false"
              else
                #OUT.write("caregiver:true, ")
                caregiver="true"
              end

            end
            gend=values[5]
            gend="Unknown" if gend.blank?
            #puts gend
            weight=0
            userinfo="guest" if userinfo.blank?

            newuser=User.find_by_username("#{userinfo}")
            newuser=User.create(username: "#{userinfo}",email_address: "#{userinfo}",age: "#{values[6]}",gender: "#{gend}",caregiver: "#{caregiver}",weight:weight) if newuser.nil?
            puts "creating user username: #{userinfo},email_address: #{userinfo},age: #{values[6]},gender: #{gend},caregiver: #{caregiver},weight:#{weight}"
            #OUT.write("age: '#{values[6]}',gender: '#{values[5]}') {|user| newuser=user}\n")

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
            puts $1 +$2 +$3 +$4 +$5 +$6 +$7
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
              review_url="http://www.webmd.com/drugs/drugreview-#{source_id}-#{name}.aspx?drugid=#{source_id}&drugname=#{name}&pageIndex=#{page_to_link}&sortby=3&conditionFilter=-1"
              newcomments=escape_characters_in_string(values[8])  if values[8]
              newreview=newuser.reviews.create(comments: "#{newcomments}",effectiveness: values[2], ease_of_use: values[3], satisfactory: values[4], created_at: "#{formateddate}", review_url: "#{review_url}", drug_id: newdrug.id) if newuser.save!
            elsif web_source=="askapatient"
              reviews_per_page=60
              target_review=i
              page_to_link=generate_url(web_source,reviews_per_page,target_review,total_reviews,source_reviews)
              review_url="http://www.askapatient.com/viewrating.asp?drug=#{source_id}&name=#{name}&page=#{page_to_link}"
            elsif web_source=="everydayhealth"


            end
            #OUT.write("newuser=User.last\n")
            #OUT.write("newuser.reviews.create(comments: \"#{newcomments}\",effectiveness: #{values[2]}, ease_of_use: #{values[3]}, satisfactory: #{values[4]}, created_at: '#{formateddate}', review_url: \"#{review_url}\", drug_id:newdrug.id)\n")
          end
          i=i+1
        }
      end


      OUT.write("completed seeding #{name}\n")
    }
  end


  ##############
  ## NEW TASK
  ##############
  # usage rake project:initDruginfographs
  desc "task to initialize Druginfographs for all drugs in database"
  task :initDruginfographs =>:environment do
    drugs=Drug.all
    drugs.map do |drug|
      attributehash=get_infograph_attributes(drug.brand_name)
      druginfograph = Druginfograph.new(attributehash)
      if druginfograph.save
        next
      else
        druginfograph = Druginfograph.find_by_brand_name(drug.brand_name)
        druginfograph.update_attributes(attributehash)
      end
    end
  end

  ########################
  # CLASS METHODS
  ########################

  def escape_characters_in_string(string)
    pattern = /(\'|\"|\*|\/|\-|\\|\#|\@|\$|\%|\&)/
    string.gsub(pattern){|match|"\\"  + match} # <-- Trying to take the currently found match and add a \ before it I have no idea how to do that).
  end

  def urldecode(str)
    # always  first replace the + with space . then do the urldecode method  if not the encoded "+" will be gone
    str2=str.gsub(/\+/," ")
    #puts "#{str2}"
    str2.to_enum(:scan,  /%../i ).map {
      matched=Regexp.last_match.to_s.upcase
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

  def generate_url(source,page_constant,target_review,total_rev,source_reviews)
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
end