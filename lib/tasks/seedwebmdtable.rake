       # run with rake in=list_of_all_drugs project:updatereviewcount
namespace :project do
  desc "update number of reviews counts for webmd table use rake in=<inputfile> project:updatereviewcount"
  task :updatereviewcount =>:environment do
    require 'open-uri'
    #OUT=File.new("seedwebmd.txt","w")
    inputfile=ENV["in"]
    File.open(inputfile,"r") do |filereader|
      i=1
      filereader.each do |line|
        values=line.chomp.split(/\t/)
        if values[1]=~/drugid=(.*?)&/
          source_id=$1
        end
        brand=values[0]
        # use values[3] the part with out the source
        baseurl="http://www.webmd.com"
        if values.size <3 || values[3].nil?
          # size < 3 means they have zero reviews
          next
        end

        pagelookup=baseurl+values[3]
        puts pagelookup

        doc = Hpricot(open("#{pagelookup}"))
        latest_count=(doc/"span.totalreviews").inner_html.chomp
        if latest_count=~/^(\d+)/
          puts latest_count
          formatted_count=$1.chomp.to_i
          puts "#{formatted_count} found"
        end
        #OUT.write("Webmd.create!(source_id:'#{source_id}', brand_name:\"#{values[0]}\", current_reviews: #{values[2]}, latest_reviews: #{formatted_count})\n")
        if found=Webmd.find_by_brand_name("#{brand}")
          found.update_attributes(:latest_reviews=> formatted_count)
        else
          Webmd.create!(brand_name:"#{brand}",source_id:"#{source_id}", current_reviews: values[2], latest_reviews: formatted_count)
        end
      end
    end

  end

  ###########################################
  # rake druglist=druglist_all_new_to_old input_dir=/c/Documents\ and\ Settings/hoiqz/RubymineProjects/everydayhealth/reviews/tmp project:initalize_everydayhealth_table
  ###########################################
  desc "get data from pages scrapped off everyday health"
  task :initalize_everydayhealth_table =>:environment do
    require 'open-uri'
    require 'iconv'

    #inputdir=ENV["in"]
    druglist=ENV['druglist']
    reviews_folder=ENV['input_dir']
    Dir.mkdir("everydayhealth_reviews") if !File.exists?("everydayhealth_reviews")
    Dir.mkdir("../everydayhealth/reviews/done") unless Dir.exist?("../everydayhealth/reviews/done")
    OUT=File.new("everydayhealth_reviews/all.merged.reviews","a+")
    File.open(druglist,"r") do |filereader|
      filereader.each do |line|
        if line=~/^#/
          puts "skipping #{line} with #"
          next
        end
        drug=line.chomp

        puts drug
       # for each drug open its drug file
        drug_review=reviews_folder+"/#{drug}"

        doc = open(drug_review) { |f| Hpricot(f) }
        #doc = Hpricot(open("http://www.everydayhealth.com/drugs/search?browse_type=m&q=#{drug}&src=ww_ctsearch"))

        #first we check the number of reviews there are

        found=(doc/"html body#htmBody div#Drugs.tools div div#container div#content div#template div#outer div#inner div#twocolumn.template div.col1 div#browsable.detail-browsable div div.tabbed div.tabbed-outer div.tabbed_skinny div.tabbed_skinny_content div.bvr-tab-container p").inner_html
         if found=~/No ratings found/
           source_reviews=0

         end
        #puts found if found
        found2=(doc/"html body#htmBody div#Drugs.tools div div#container div#content div#template div#outer div#inner div#twocolumn.template div.col1 div#browsable.detail-browsable div div.tabbed div.tabbed-outer div.tabbed_skinny div.tabbed_skinny_content div.bvr-tab-container div#treatment_ratings.user_ratings div.pagination div.pagination_left").inner_html
        if found2=~/\((.*)? results found\)/
          source_reviews= $1.to_i
         # get the drug name
          drugname=""
          condition=""
          address="-"
          recommend=""
          date=""
          comments=""
          if drug=~/(.*)?.page/
            drugname=$1
            puts drugname
          end
          # get the condition
          doc.search("div#treatment_ratings.user_ratings div.hreview").each do |finder|
            scores=""
            conditionfinder=finder.search("span.rated.min-pad a")
            conditionfinder.inner_html=~/for (.*)?\./
            condition=$1

            # get date
            datefinder=finder.search("div.under_comment p.min-pad cite")
            if datefinder.empty?
              date="2000-01-01 00:00:00"
            else
            unformatteddate=$1 if datefinder.inner_html=~/\((.*)?\)/
            unformatteddate=~/(\d+)\/(\d+)\/(\d+)/
            month=$1
            date=$2
            year="20"+$3
            date="#{year}-#{month}-#{date} 00:00:00"
            end

            #get the ratings
            finder.search("table.rating-sideways span.value").each do |s|
              scores << "\t#{s.inner_html}"
            end

            #get comments
            comments=finder.search("div p:not(.min-pad)").inner_html.gsub(/<wbr \/>/,"")
            if comments.empty?
              puts "comments empty. trying to see if theres a link"
              finder.search("div h3 a").each do |commentsfinder|
              href= commentsfinder.attributes['href']
              #puts commentsfinder.inner_html

              if href
              puts href
              address=href
              ic = Iconv.new("UTF-8//IGNORE", "UTF-8")
              doc_comment = open(href) {|f| Hpricot(ic.iconv(f.read)) }
            #  doc_comment = Hpricot(open("#{href}"))
              while doc_comment.nil?
                sleeptime=rand(120)+rand(150)
                sleep(sleeptime.seconds)
                doc_comment = open(href) {|f| Hpricot(ic.iconv(f.read)) }
              end
                (doc_comment/"meta").remove
              comments=doc_comment.inner_html.gsub(/^\n/,"").gsub(/<wbr \/>/,"")
                puts comments
              sleeptime=rand(225)+rand(160)
              sleep(sleeptime.seconds)
              end
                end
            end

            # get recommended
           # recommend=finder.search("div p.rating-helpfulness").inner_html
            puts "#{drugname}\t#{condition}\t#{date}\t#{scores}\t#{comments}\n"
            OUT.write("#{drugname}\t#{condition}\t#{date}\t#{scores}\t#{comments}\t#{address}\n")

          end
        end

        #if existing=Everydayhealth.find_by_name("#{drug}")
        #  existing.update_attributes(:latest_reviews=> source_reviews, :current_reviews=>source_reviews)
        #else
        #  Everydayhealth.create(:name=>"#{drug}",:latest_reviews=> source_reviews, :current_reviews=>source_reviews)
        #end
        File.rename("#{reviews_folder}/#{drug}","../everydayhealth/reviews/done/#{drug}")
      end
      end
=begin
    Dir.glob(inputdir+"/*") {|file|
     doc = open(file) { |f| Hpricot(f) }

    }
    # open the fiel stream
=end
  end
  #######################################
  #rake project:getaskapatientdruglist
  #######################################
  desc "go throught A-Z get askapatient druglist drug id and page URL"
  task :getaskapatientdruglist =>:environment do
    require 'open-uri'
    address="http://www.askapatient.com/drugalpha.asp?letter="
    root="http://www.askapatient.com/"
    OUT=File.new("askapatient.druglist","a+")
    ("K".."Z").each do |letter|
      puts address+letter
      doc = Hpricot(open(address+letter))
      #doc = Hpricot(open("http://www.askapatient.com/drugalpha.asp?letter=A"))

     #doc.search("html body div#wrapper div#contentWrapper div#mainContent div div table tbody tr td small font a")
     doc.search("html body div#wrapper div#contentWrapper div#mainContent div div table tr a").each do |row|
      puts row
      name=row.inner_html
      href= row.attributes['href']
      location=root+href
       if href=~/drug=(.*)?&/
         drugid=$1
       end
      puts name
      puts location
       OUT.write("#{name}\t#{drugid}\t#{location}\n")

       end
       sleeptime=50+rand(50)
      sleep(sleeptime.seconds)
    end
  end


  #########################################
  #rake in=inputfile project:pullaskapatientreviews
  #########################################
  desc "go throught A-Z pull ask a patient reviews"
  task :pullaskapatientreviews =>:environment do
    require 'open-uri'
    require 'action_view'
    require 'iconv'
    include ActionView::Helpers::SanitizeHelper

    root="http://www.askapatient.com/"
    input=ENV['in']
    reviews_per_page=60.0

    File.open(input,"r") do |filereader|
      filereader.each do |line|
        if line=~/^#/
          puts "skipping #{line}"
          next
        end
        entry=line.chomp.split(/\t/)
        url=entry[2]
        filename=entry[0].gsub(/\s/,"+")
        for_windows_file= filename.gsub(/\//,"")
        #doc = Hpricot(open(url))
        #doc = open("test.html") { |f| Hpricot(f) }
        ic = Iconv.new("UTF-8//IGNORE", "UTF-8")
        doc = open(url) {|f| Hpricot(ic.iconv(f.read)) }
         OUT=File.new("askapatient_reviews/#{for_windows_file}_reviews.tsv","w")

        # OUT.write(doc.inner_html)
        # exit

        no_of_reviews= (doc/"html body div#wrapper div#contentWrapper div#mainContent table tr h3").inner_html
        abort("you have exceeded the requestif you see this error") if  no_of_reviews.nil?
        if !no_of_reviews.nil? && no_of_reviews=~/\((.*)? Ratings\)/
          total_rev=$1.to_f
          end

        number_of_pages=(total_rev/reviews_per_page).ceil
        puts "#{total_rev} reviews for #{filename}. Number of page - #{number_of_pages}"
        if number_of_pages >= 1
          (1..number_of_pages).each do |number|
            puts "On #{filename} page #{number}"
            if(number==1)
              # when its page 1, it is the page in the current "doc"
              OUT.write("#{filename}\t")
              parse_page(doc)
            else
              # page 2 onwards have this url syntax
              pageurl="http://www.askapatient.com/viewrating.asp?drug=21436&name=ABILIFY&page=#{number}&PerPage=60"
               #doc2=Hpricot(open(pageurl))
              ic = Iconv.new("UTF-8//IGNORE", "UTF-8")
              doc2 = open(pageurl) {|f| Hpricot(ic.iconv(f.read)) }
              OUT.write("#{filename}\t")
              parse_page(doc2)
            end
            sleeptime=rand(139)+rand(205)
            sleep(sleeptime.seconds)
          end
        end
        sleeptime=rand(300)+rand(370)
        sleep(sleeptime.seconds)
        OUT.close
      end
    end

  end


  #########################################
  #rake in=../everydayhealth/druglist.tsv.original project:matchdrugtowebmd
  #########################################
  desc "get the list of drugs in webmb and try to match a the input file drug to it."
  task :matchdrugtowebmd =>:environment do
    input=ENV['in']
    OUT=File.new("matchings","w+")
    exactcounter=0
    similarcounter=0
    File.open(input,"r") do |filereader|
      filereader.each do |line|
        indrug=line.chomp.downcase
        #see if any exact match

        exactmatch=Drug.where("brand_name LIKE ?","#{indrug}%")
        exactmatchstr=""
        byspacematchstr=""
        closematchstr=""
        if exactmatch
          exactcounter +=1
        exactmatch.each do |exact|
          exactmatchstr << " #{exact.brand_name}"
        end
        end

        if exactmatch.blank?
          #indrugsplit=indrug.split("-")  #for everydayhealth druglist it is linked by '-'
          indrugsplit=indrug.split(/\s/) # for sideeffects drug list it is separated by '\s'
          searchbyspace=indrugsplit.join(" ")
          byspacematch=Drug.where("brand_name LIKE ?","%#{searchbyspace}%")
          byspacematch.each do |match|
            byspacematchstr << " #{match.brand_name}"

          end
          #closematch=Drug.where("brand_name LIKE ? OR brand_name LIKE ?","%#{indrugsplit[0]}%","%#{indrugsplit[1]}%")
          if indrugsplit[0].length > 4
          closematch=Drug.where("brand_name LIKE ?","%#{indrugsplit[0]}%")
          closematchstr=""
          closematch.each do |match|
               closematchstr << " #{match.brand_name}"
          end
          end

        end
        OUT.write "#{indrug}\tE:#{exactmatchstr}\tS:#{byspacematchstr}\tC:#{closematchstr}\n"
      end
      "#{exactcounter} hits were matched exactly"
    end

  end


  #########################################
  #rake in=../everydayhealth/druglist.tsv.original project:findsideeffects
  #########################################
  desc "find the side effect for a list of drug."
  task :findsideeffects =>:environment do
    input=ENV['in']
    OUT=File.new("matchings","w+")
    exactcounter=0
    similarcounter=0
    Drug.all.each do |drug|
      File.open(input,"r") do |filereader|
        found=0
        OUT.write("#{drug.brand_name} ")
        filereader.each do |line|
          if found ==1
            break
          end
          if line=~/#{drug}/
               OUT.write("has side effect #{line}\n")
               found=1
          end
        end
      end
    end
  end
  #########################################
  #rake project:generatemostcommon
  #########################################
  desc "get the list of drugs that are most common and put in in mostcommondrugs table."
  task :generatemostcommon =>:environment do
    Drug.all.each do |drug|
      size=drug.reviews.count
      if size >200
        found=Mostcommondrug.find_by_drug_id(drug.id)
        if found
          found.update_attributes(:count=>size)
        else
          Mostcommondrug.create(:brand_name=>drug.brand_name, :count=>size,:drug_id=>drug.id)
        end
      end

    end
  end
  #########################################
  #rake project:generatereviewcounts
  #########################################
  desc "count number of reviews for each drug and stores it"
  task :generatereviewcounts =>:environment do
    Drug.reset_column_information
    Drug.all.each do |d|
      d.update_attributes(:reviews_count=>d.reviews.count)
    end
  end

  #########################################
  #rake project:uploadwordcountfreq
  #########################################
  desc "upload the word count for each drug"
  task :uploadwordcountfreq =>:environment do
    Drug.all.each do |d|
      d.update_attributes(:reviews_count=>d.reviews.count)
    end
  end


  #########################################
  #rake project:rename_and_getrepeats
  #########################################
  desc "get the list of drugs are not unique after removing the suffix. generates a tofix file consisting of all the duplicates to use
with the next rake task:fix_other_records"
  task :rename_and_getrepeats =>:environment do
    h=Hash.new
    OUT=File.new("tofix","w+")
    Drug.all.each do |drug|
      edited_drug=drug.brand_name.gsub(/\s(Oral|IV|IM|Top|Inj|SubQ|Vagl|Opht|Impl|Nasl|Misc|Rect)$/,"")

      if h.has_key?(edited_drug)
        h[edited_drug]=h[edited_drug]+";"+drug.brand_name
        puts "#{edited_drug} already exist. original name was #{h[edited_drug]}"
        OUT.write(h[edited_drug]+"\n")
      else
        h[edited_drug]=drug.brand_name
        end
      drug.update_attributes(:brand_name => edited_drug)
    end
    puts "#{Drug.all.count} records reduced to #{h.size}"
  end


  #########################################
  #rake in=tofix project:fix_other_records
  #########################################
  desc "lots of steps to rename the drugs and fix the others tables."
  task :fix_other_records =>:environment do
    input=ENV['in']
    toupdate=Array.new
    File.open(input,"r") do |filereader|
      filereader.each do |line|
      next if line=~/^#/
         drugs=Array.new
         drugs=line.split(";")
      # the first drug is always the one that we want to retain. So we pop it and store as retain
        retain=drugs.pop.chomp
         newname=retain.gsub(/\s(Oral|IV|IM|Top|Inj|SubQ|Vagl|Opht|Impl|Nasl|Misc|Rect)$/,"")
      #rename the new drug we want to keep and push it into toupdate array
         toupdate.push newname
         retain_drug=Drug.where("other_names LIKE ?","%#{retain}%").first
      #drugs array now contains all the drugs from tofix file that are to be destroyed / merged into another record
         drugs.each do |drug|
           puts "working on #{drug} now"
           # change the reviews drugid to the merged drug id
            oldrecord=Drug.where("other_names LIKE ?","%#{drug}%").first
           found=oldrecord.reviews
           unless (found.nil?)
           found.each do |rev|
             rev.update_attributes(:drug_id=>retain_drug.id)
             #destroy the drug. conditions will get destroyed too.
             #oldrecord.destroy
           end
           end
           # remove the druginfograph entry
           Druginfograph.find_by_brand_name(drug).destroy       if Druginfograph.find_by_brand_name(drug)

         end
         #update the other_names to include both
         update_alias=line
         #update the review counts
         retain_drug.update_attributes(:other_names=>update_alias,:reviews_count=>retain_drug.reviews.count)

       end
    end
       puts toupdate
       toupdate.each do |entry|
         Drug.find_all_by_brand_name(entry).each do |repeats|
           #we  have shifted the reviews to the retain drugs. so duplicate drugs shld have >1 reviews
           if repeats.reviews.count < 1 && repeats.other_names !~ /;/
              puts "entries to be deleted : #{repeats.other_names} #{repeats.id}"
             repeats.destroy
           else
             puts "Not deleted: #{repeats.other_names} #{repeats.id}"
           end
         end
       end

    #update the name on Druginforgraphs
    Druginfograph.all.each do |drug|
    edited_drug=drug.brand_name.gsub(/\s(Oral|IV|IM|Top|Inj|SubQ|Vagl|Opht|Impl|Nasl|Misc|Rect)$/,"")
    drug.update_attributes(:brand_name=>edited_drug)
    end
      #after that run initdruginfographs for those
      toupdate.each do |drug|
        if Druginfograph.find_by_brand_name(drug)
        attributehash=get_infograph_attributes(drug)
        druginfograph = Druginfograph.find_by_brand_name(drug)
        druginfograph.update_attributes(attributehash)
        puts "#{druginfograph.brand_name} updated"
          end
      end

  end

  ##############
  ## NEW TASK
  ##############
  # usage rake inputdir=../wordfreq project:uploadwordcloud
  desc "task to upload word cloud to the drugs"
  task :uploadwordcloud =>:environment do
    inputdir=ENV['inputdir']
    workingdir=Dir.open inputdir
    workingdir.each do |filename|
      if filename=~/^\./
        next
      end
       #print "working on #{filename} now : "
      filename=~/(.*?)_reviews.tsv.words.freq/
      brandname=$1
      brandname=brandname.gsub(/\+/,' ').gsub(/\s(Oral|IV|IM|Top|Inj|SubQ|Vagl|Opht|Impl|Nasl|Misc|Rect)$/,"").gsub(/%252f/,"/").gsub(/%26/,"&")
      #puts brandname
      maxsize=20
      found=Drug.find_by_brand_name(brandname)
      if found
        #print "match #{found.brand_name}\n"
        File.open("#{inputdir}/#{filename}","r") do |filereader|
          wordline=Array.new
          counter=1
          filereader.each do |line|
            if counter == maxsize
              break
            end
            # i want to check that if the count is 1 then dont print it. do some normalization
            arr=line.split(/\t/)
            newvalue=arr[1].to_i
            line2="#{arr[0]}=>#{newvalue}"
            tag=line2.gsub(/,/,'').chomp

            wordline << "#{tag}"
            #end
            counter=counter+1
          end
          wordlist_stringify=wordline.join(',')
          #print "#{wordlist_stringify}\n"
          Tag.create(:brand_name=>brandname,:word_list=>wordlist_stringify)
          end
      else
        print "working on #{filename} now. Searchword #{brandname}: "
        print "\n"
      end
    end
  end

  ##############
  ## NEW TASK
  ##############
  # usage rake inputfile=../sideeffects/combined_new_format project:uploadsideeffects
  desc "task to upload the side effects"
  task :uploadsideeffects =>:environment do
    inputfile=ENV['inputfile']
    OUT=File.new("matchings","w+")
      exactcounter=0
      similarcounter=0
      indrug=""
      wordline=Hash.new
      wordlist_stringify=""
      File.open(inputfile,"r") do |filereader|
        filereader.each do |line|
          ## IF header line
          if line=~/^#/

            unless indrug.blank?
              #filter the values in the array
              temp=wordline.sort_by {|k,v| v}.reverse
              toptwenty=temp[0..19]
              wordlist_stringify=toptwenty.map {|k,v| "#{k}=>#{v}"}.join(",")
             # a=Drug.find(indrug.id).update_attributes(:side_effects=>wordlist_stringify)

              OUT.write("#{indrug.brand_name} -- Drug.find(#{indrug.id}).update_attributes(:side_effects=>'#{wordlist_stringify}')\n")
              wordline.clear
            end
            indrug=line.gsub(/^#/,"").sub(/\s$/,"").chomp
            #OUT.write "working on #{indrug} : Drug.where(\"brand_name LIKE ?\",\"#{indrug}%\")\n"
            exactmatch=Drug.where("brand_name LIKE ?","#{indrug}%")

            if !exactmatch.empty?
              exactcounter +=1
              indrug=exactmatch.first
            else
              #OUT.write("no match for #{indrug}\n")
              indrug=""
              next
            end

          else
            # NOT header line
            arr=line.split(/\t/)
            if arr.size < 2
              newvalue=0.0
            else
              newvalue=arr[1].to_f
            end
            #line2="#{arr[0]}=>#{newvalue}"
            wordline[arr[0].chomp]=newvalue

          end


        end
      end
    end

  ##############
  ## NEW TASK
  ##############
  # usage rake inputfile=../sideeffects/combined_new_format project:sideeffectmatchingtest
  desc "another way to match the side effects to the drugs. for testing"
  task :sideeffectmatchingtest =>:environment do
    inputfile=ENV['inputfile']
    OUT=File.new("matchings","w+")
    exactcounter=0
    similarcounter=0
    indrug=""
    prev_drug=""
    wordline=Hash.new
    storage_hash=Hash.new
    wordlist_stringify=""
    File.open(inputfile,"r") do |filereader|
      filereader.each do |line|
        ## IF header line
        if line=~/^#/
          prev_drug=indrug
          indrug=line.gsub(/^#/,"").sub(/\s$/,"").chomp
          if !prev_drug.blank? && prev_drug != indrug
            #filter the values in the array
            temp=wordline.sort_by {|k,v| v}.reverse
            toptwenty=temp[0..19]
            wordlist_stringify=toptwenty.map {|k,v| "#{k}=>#{v}"}.join(",")
            # a=Drug.find(indrug.id).update_attributes(:side_effects=>wordlist_stringify)
            storage_hash[indrug]=wordlist_stringify
            wordline.clear
          end

          #OUT.write "working on #{indrug} : Drug.where(\"brand_name LIKE ?\",\"#{indrug}%\")\n"

        else
          # NOT header line
          arr=line.split(/\t/)
          if arr.size < 2
            newvalue=0.0
          else
            newvalue=arr[1].to_f
          end
          #line2="#{arr[0]}=>#{newvalue}"
          wordline[arr[0].chomp]=newvalue

        end

      end
    end
    #check hash
    #storage_hash.map {|k,v| OUT.write "#{k} =>  #{v}\n"}
    Drug.all.each do |drug|
      puts drug
      if storage_hash[drug.brand_name]
        OUT.write "#{drug.brand_name}=>#{storage_hash[drug.brand_name]}\n"
      end
    end
  end
###############
#NEW TASK
  ##############
  # usage rake project:initconditioninfographs
  desc "task to initialize initconditioninfographs for all conditions in database"
  task :initconditioninfographs =>:environment do
    @conditions=Condition.all
    @conditions.map do |condition|
      @attributehash=get_infograph_attributes(condition)
      @conditioninfograph = Conditioninfograph.new(@attributehash)
      if @conditioninfograph.save
        puts "#{condition} saved"
        next

      else
        @conditioninfograph = Conditioninfograph.find_by_condition_id(condition.id)
        @conditioninfograph.update_attributes(@attributehash)
        puts "#{condition} updated"
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

  def get_infograph_attributes(drug) #drug is the brand_name not drug id
    att_hash={}
    att_hash[:brand_name]=drug
    att_hash[:avg_sat_male]=get_satisfactory(drug,"Male")
    att_hash[:avg_sat_female]=get_satisfactory(drug,"Female")
    att_hash[:top_used_words]=get_top_used_words(drug)

    total_reviewer_for_this= total_reviewers(drug).to_f
    count_age_group1=get_user_age_group(drug,">55")
    count_age_group2=get_user_age_group(drug,"<18")
    count_age_group3=total_reviewer_for_this - count_age_group1 - count_age_group2
    att_hash[:age_more_50]=(count_age_group1/total_reviewer_for_this) *100
    att_hash[:age_less_18]= (count_age_group2/total_reviewer_for_this) *100
    att_hash[:age_btw_18_50]= (count_age_group3/total_reviewer_for_this) *100

    att_hash[:no_of_males] =(total_reviewers(drug,"Male") /total_reviewer_for_this)*100
    att_hash[:no_of_females]=(total_reviewers(drug,"Female")/total_reviewer_for_this)*100

    total_reviews_for_this= total_reviews(drug).to_f
    eff_over_3=statistic_get_more_or_equal(drug,"effectiveness",3)
    eff_less_3=statistic_get_less(drug,"effectiveness",3)
    att_hash[:effective_over_3]=(eff_over_3/ total_reviews_for_this)*10
    att_hash[:effective_less_3]  =(eff_less_3/ total_reviews_for_this) *10

    eou_over_3=statistic_get_more_or_equal(drug,"ease_of_use",3)
    eou_less_3=statistic_get_less(drug,"ease_of_use",3)
    att_hash[:eou_over_3] =(eou_over_3/ total_reviews_for_this) *10
    att_hash[:eou_less_3]=(eou_less_3/ total_reviews_for_this) *10

    return att_hash
  end

  def total_reviews(drug)
    mydrugid=Drug.find_by_brand_name(drug).id
    query_record=Review.joins(:drug,:user).where("drug_id=?",mydrugid).count
  end

  def statistic_get_more_or_equal(drug,type,score)
    mydrugid=Drug.find_by_brand_name(drug).id
    query_record=Review.joins(:drug,:user).where("drug_id=? AND #{type} >= ?",mydrugid,score).count
  end

  def statistic_get_less(drug,type,score)
    mydrugid=Drug.find_by_brand_name(drug).id
    query_record=Review.joins(:drug,:user).where("drug_id=? AND #{type} < ?",mydrugid,score).count
  end

  def total_reviewers(drug,*gender)
    drugid=Drug.find_by_brand_name(drug).id

    if gender.empty?

      user_record_count=User.joins(:reviews=>:drug).where(:reviews=>{:drug_id=>drugid}).count
    else
      if gender.shift == 'Male'
        user_record_count=User.joins(:reviews=>:drug).where(:reviews=>{:drug_id=>drugid},:gender=>"Male").count
      else
        #if gender.shift =='Female'
        user_record_count=User.joins(:reviews=>:drug).where(:reviews=>{:drug_id=>drugid},:gender=>"Female").count
      end
    end
    return user_record_count
  end

  def get_user_age_group(drug,age_range)
    drugid=Drug.find_by_brand_name(drug).id
    user_record=User.joins(:reviews=>:drug).where(:reviews=>{:drug_id=>drugid})
    count=0
    if age_range == "<18"
      count=count+user_record.where("age=?","3-6").count
      count=count+user_record.where("age=?","7-12").count
      count=count+user_record.where("age=?","12-18").count
    end
    if age_range == ">55"
      count=count+user_record.where("age=?","55-64").count
      count=count+user_record.where("age=?","65-74").count
      count=count+user_record.where("age=?","75 or over").count
    end
    return count
  end

  def get_satisfactory(drug,gender)
    mydrugid=Drug.find_by_brand_name(drug).id
    query_record=Review.joins(:drug,:user).where(:drug_id=>mydrugid).where(:users=>{:gender=>gender})

    score1=query_record.where("satisfactory=?",1).count
    score2=query_record.where("satisfactory=?",2).count
    score3=query_record.where("satisfactory=?",3).count
    score4=query_record.where("satisfactory=?",4).count
    score5=query_record.where("satisfactory=?",5).count
    sum=Float(query_record.count)

    weighted_average=((1*score1)+(2*score2)+(3*score3)+(4*score4)+(5*score5))/sum
    puts "#{score1} #{score2} #{score3} #{score4} #{score5} #{sum} #{weighted_average}"
  end

  def get_top_used_words(drug)
    @tags=Tag.find_by_brand_name(drug)
    if @tags.nil?
      string=""
    else
      @tagshash=format2hash(@tags.word_list)
      temp=@tagshash.sort_by {|k,v| v}.reverse.shift(3)
      string=''
      arr=temp.collect { |x| x[0]}
      string  =arr.join(",")
    end

  end

  def format2hash(string)
    stringhash={}
    string.split(",").map { |keyvalue|
      arr=keyvalue.split("=>",2)
      stringhash[arr[0]]=arr[1].to_i
    }
    return stringhash
  end

  # self declared methods to get the values


  def get_most_bad_reviews(condition,score)
    highest_count=0.0
    total=0.0
    winner='Insufficient Data'
    condition.drugs.map do |drug|
      query_record_count=Review.joins(:drug,:user).where("drug_id=? AND effectiveness <= ? AND ease_of_use <= ? AND satisfactory <= ?",drug.id,score,score,score).count
      total=total+query_record_count
      if query_record_count > highest_count
        highest_count=query_record_count
        winner=drug.brand_name
      end
    end
    freq=highest_count/total
    return "winner=>#{winner},frequency=>#{freq.round(2)}"
  end

  def get_all_reviews(condition)
    count=0
    condition.drugs.map do |drug|
      count=count+ user_record_count=User.joins(:reviews=>:drug).where(:reviews=>{:drug_id=>drug.id}).count
    end
    return count
  end

  def get_most_kids_using(condition)
    highest_count=0.0
    total=0.0
    winner='Insufficient Data'
    condition.drugs.map do |drug|
      user_record_count=0
      user_record=User.joins(:reviews=>:drug).where(:reviews=>{:drug_id=>drug.id})
      user_record_count=user_record_count+user_record.where("age=?","3-6").count
      user_record_count=user_record_count+user_record.where("age=?","7-12").count
      user_record_count=user_record_count+user_record.where("age=?","12-18").count
      total=total+user_record_count
      if user_record_count > highest_count
        highest_count=user_record_count
        winner=drug.brand_name
      end
    end
    freq=highest_count/total
    return "winner=>#{winner},frequency=>#{freq.round(2)}"
  end

  def get_most(condition,score,type)
    highest_count=0.0
    total=0.0
    winner='Insufficient Data'
    condition.drugs.map do |drug|
      query_record_count=Review.joins(:drug,:user).where("drug_id=? AND #{type} >= ?",drug.id,score).count
      total=total+query_record_count
      if query_record_count > highest_count
        highest_count=query_record_count
        winner=drug.brand_name
      end
    end
    freq=highest_count/total
    return "winner=>#{winner},frequency=>#{freq.round(2)}"
  end

  def get_most_reviewed_drug(condition)
    highest_count=0.0
    total=get_all_reviews(condition).to_f
    winner='Insufficient Data'
    ranking=""
    newhash=Hash.new
    condition.drugs.map do |drug|
      query_record_count=Review.joins(:drug,:user).where("drug_id=?",drug.id).count
      newhash[drug.brand_name]=((query_record_count/total)*10).round(2)
    end
    newhash=newhash.sort_by {|k,v| v}.reverse        #reverse sort the hash according to the hash value
    ranking=newhash.collect {|k,v| "#{k}=>#{v}"}.join(',')
    return "#{ranking}" #store as a eg       Adderall Oral=>473,Focalin Oral=>129,Ritalin Oral=>123
  end

  def parse_page(doc)
    abort("no table found. You make have overloaded") if  doc.search("html body table.ratingsTable").nil?
    doc.search("html body table.ratingsTable").each do |tablerow|
=begin
                  col=tablerow.search("td")
                  sat=col[0].inner_html
                  condition=col[1].inner_html
                  comment1=col[2].inner_html
                  comment2=col[3].inner_html
                  gender=col[4].inner_html
                  age=col[5].inner_html
                  durationdosage= col[6].inner_html
                  date=col[7].inner_html
=end
      temparr=Array.new
      i=0
      tablerow.search("td").each do |data|
        cleaned=strip_tags(data.inner_html).gsub(/&nbsp;/,"").gsub(/\n/,"")
        #puts cleaned
        temparr.push(cleaned)
        if i==7
          temparrstring=temparr.join("\t")
          OUT.write("#{temparrstring}\n")
         # puts temparrstring
          i=0
          temparr.clear
          next
        end
        i=i+1
      end

    end
  end

  end
