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
  # rake druglist=druglist_all_new_to_old input_dir=/c/Documents\ and\ Settings/hoiqz/RubymineProjects/everydayhealth/reviews/tmp project:initalize_everydayhealth_table >>tmp1
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
                sleeptime=150+rand(150)
                sleep(sleeptime.seconds)
                doc_comment = open(href) {|f| Hpricot(ic.iconv(f.read)) }
              end
                (doc_comment/"meta").remove
              comments=doc_comment.inner_html.gsub(/^\n/,"").gsub(/<wbr \/>/,"")
                puts comments
              sleeptime=180+rand(160)
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
  #rake in=inputfile project:pullaskapatientreviews eg rake in=askapatient.druglist project:pullaskapatientreviews
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
         OUT=File.new("askapatient_reviews/#{for_windows_file}_reviews.tsv","a")

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
            sleeptime=300+rand(255)
            sleep(sleeptime.seconds)
          end
        end
        sleeptime=500+rand(400)
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
  #rake project:generateCommondrugContent
  #########################################
  desc "generate content in Commondrug table."
  task :generateCommondrugContent =>:environment do
    #if Commondrug.all.empty?
    commonlist=["Levothyroxine","Lisinopril","Lipitor","Simvastatin","Plavix","Singulair",
                "Azithromycin","Crestor","Nexium","Metoprolol Tartrate","Synthroid","Lexapro","ProAir HFA",
                "Ibuprofen","Trazodone","Amoxicillin","Glucophage","Advair Diskus","Abilify","Seroquel","Actos","Epogen",
                "Xanax","Tramadol","Vicodin","Ultram"]
    temp=Array.new
    commonlist.each do |common|
      found=Drug.where("brand_name LIKE ?","%#{common}%").first
      if found
        involved_in=Array.new
        found.conditions.each do |con|
          involved_in << con.name
        end
        conditions_involved=involved_in.join(",")
        a=Commondrug.create!(:brand_name=>found.brand_name, :conditions=>conditions_involved, :drug_id=>found.id)
      end
    end

  end

  #########################################
  #rake project:generateCommonConditionContent
  #########################################
  desc "generate content in Commondrug table."
  task :generateCommonConditionContent =>:environment do
    #if Commoncondition.all.empty?
      commonlist=["hepatitis A","type 1 diabetes","type 2 diabetes","stomach ulcer","Bronchitis","middle ear infection","hepatitis B","malaria","Anemia"]
      daytodayillness=["Constipation","diarrhea","irritable bowel syndrome","Migraine Headache","Sinus Irritation and Congestion","cold","acne"]
      elderlyillness=["high blood pressure","Osteoporosis","angina","arthritis","Rheumatism"]
      kidsillness=["Eczema","Chickenpox","Whooping cough"]
      mentalillness=["Repeated Episodes of Anxiety","Obsessive Compulsive Disorder","Bipolar Disorder","Panic Disorder","Depression"]

      commonlist.each do |common|
        category="Common Health Conditions"
        found=Condition.where("name LIKE ?","%#{common}%").first
          a=Commoncondition.create!(:name=>found.name, :condition_id=>found.id, :category=>category) if found
      end

      daytodayillness.each do |common|
        category="Day To Day Health"
        found=Condition.where("name LIKE ?","%#{common}%").first
        a=Commoncondition.create!(:name=>found.name, :condition_id=>found.id, :category=>category) if found
      end
      elderlyillness.each do |common|
        category="Elderly Related Conditions"
        found=Condition.where("name LIKE ?","%#{common}%").first
        a=Commoncondition.create!(:name=>found.name, :condition_id=>found.id, :category=>category) if found
      end
      kidsillness.each do |common|
        category="Kids Related Conditions"
        found=Condition.where("name LIKE ?","%#{common}%").first
        a=Commoncondition.create!(:name=>found.name, :condition_id=>found.id, :category=>category) if found
      end
      mentalillness.each do |common|
        category="Mental Conditions"
        found=Condition.where("name LIKE ?","%#{common}%").first
        a=Commoncondition.create!(:name=>found.name, :condition_id=>found.id, :category=>category) if found
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
      #d.update_attribute(:reviews_count, d.reviews.count)
      d.reviews_count=d.reviews.count
      d.save!
    end
  end

  #########################################
  #rake project:uploadwordcountfreq
  #########################################
  desc "upload the word count for each drug"
  task :uploadwordcountfreq =>:environment do
    Drug.all.each do |d|
      d.update_attribute(:reviews_count, d.reviews.count)
    end
  end



  ##############
  ## task to upload word cloud to the drugs
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
  ## task to upload the side effects
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
  # usage rake project:cleanReviews
  desc "task to clean reviews and remove weird encodings inserted by me inside database"
  task :cleanReviews =>:environment do
    Review.all.each do |review|
      #if review.id < 94491
      puts "#{review.id}\n"
      old=review.comments
      cleaned=old.gsub(/\\/,'')
      review.comments=cleaned
      review.save!
      #end
    end
  end

  ###############
  #parse out general information from downloaded files // rake inputfolder=../medline_original/ project:parseGeneralInformation
  ##############
  # usage rake project:cleanReviews
  desc "task to parse out general information from downloaded files"
  task :parseGeneralInformation =>:environment do
    require 'open-uri'
    require 'action_view'
    require 'iconv'
    inputfolder=ENV['inputfolder']
    parsed_file="#{inputfolder}/all.parsed.cleaned"
    #puts parsed_file
    PARSE=File.new(parsed_file,"a")
    PARSE.write "drug\tprescribed\thowtouse\totheruses\tprecaution\tdietary_precaution\tside_effects\tstorage\tother_info\tbrand_names\tother_names\n"
    files=Dir.glob("#{inputfolder}/*")
    files.each do|filename|
      if filename !~ /_reviews.tsv$/
        puts filename

        next
      end
      tmp_file="#{inputfolder}/test/tmp.txt"
      #tmp_file="#{inputfolder}tmp.txt"
      #puts tmp_file
      OUT=File.new(tmp_file,"w")
      File.open(filename,"r") do |filereader|
        filereader.each do |line|
          if (line=~/hgroup\n/)
            tmpline=line.gsub(/hgroup/,"hgroup>")
            OUT.write(tmpline)
          else
            OUT.write line
            end
        end
        end
        OUT.close
      drugname=File.basename(filename).gsub(/_reviews.*/,"").gsub(/^_/,"").gsub(/_$/,"")
      drugnamesplit=drugname.split(/\+/).join " "

          doc = open(tmp_file) { |f| Hpricot(f) }
      prescribed=""
      howtouse=""
      otheruses=""
      precaution=""
      dietary_precaution=""
      side_effects=""
      storage=""
      other_info=""
      brands=""
      other_names=""

          (doc/"div#hgroup").each do |h2elements|
            content=h2elements.search("h2").inner_html
            #puts "h2 is  #{content}\n"
            content_p_tag=""
            case
              when content.match(/medication prescribed/i)
                h2elements.search("a").remove # remove ahrefs

                if h2elements.search("#hgroup > p").any?
                  content_p_tag += h2elements.search("#hgroup > p").inner_html
                end
                if h2elements.search("#hgroup > h3").any?
                  content_p_tag += h2elements.search("#hgroup > h3").first.inner_html
                end
                if h2elements.search("li p").any?
                  content_p_tag += h2elements.search("li p").inner_html
                elsif h2elements.search("li").any?
                  content_p_tag += h2elements.search("li").inner_html
                else
                  #content_p_tag += h2elements.search("p").inner_html
                end
                prescribed=clean_p_tags_and_newline(content_p_tag)
              when content.match(/medicine be used/i)
                h2elements.search("a").remove # remove ahrefs
                if h2elements.search("#hgroup > p").any?
                  content_p_tag += h2elements.search("#hgroup > p").inner_html
                end
                if h2elements.search("#hgroup > h3").any?
                content_p_tag += h2elements.search("#hgroup > h3").first.inner_html
                 end
                if h2elements.search("li p").any?
                  content_p_tag += h2elements.search("li p").inner_html
                elsif h2elements.search("li").any?
                  content_p_tag += h2elements.search("li").inner_html
                else
                  #content_p_tag += h2elements.search("p").inner_html
                end
                howtouse=clean_p_tags_and_newline(content_p_tag)
              when content.match(/Other uses for this medicine/i)
                h2elements.search("a").remove # remove ahrefs
                if h2elements.search("#hgroup > p").any?
                  content_p_tag += h2elements.search("#hgroup > p").inner_html
                end
                if h2elements.search("#hgroup > h3").any?
                content_p_tag += h2elements.search("#hgroup > h3").first.inner_html
            end
                if h2elements.search("li p").any?
                  content_p_tag += h2elements.search("li p").inner_html
                elsif h2elements.search("li").any?
                  content_p_tag += h2elements.search("li").inner_html
                else
                  #content_p_tag += h2elements.search("p").inner_html
                end
                otheruses=clean_p_tags_and_newline(content_p_tag)
              when content.match(/special precautions/i)
                h2elements.search("a").remove # remove ahrefs
                if h2elements.search("#hgroup > p").any?
                  content_p_tag += h2elements.search("#hgroup > p").inner_html
                  end
                if h2elements.search("#hgroup > h3").any?
                  content_p_tag += h2elements.search("#hgroup > h3").first.inner_html
                end
                if h2elements.search("li p").any?
                  content_p_tag += h2elements.search("li p").inner_html
                elsif h2elements.search("li").any?
                  content_p_tag += h2elements.search("li").inner_html
                else
                  #content_p_tag += h2elements.search("p").inner_html
                end
                precaution=clean_p_tags_and_newline(content_p_tag)
              when content.match(/special dietary instructions/i)
                h2elements.search("a").remove # remove ahrefs
                if h2elements.search("#hgroup > p").any?
                  content_p_tag += h2elements.search("#hgroup > p").inner_html
                end
                if h2elements.search("#hgroup > h3").any?
                  content_p_tag += h2elements.search("#hgroup > h3").first.inner_html
                end
                if h2elements.search("li p").any?
                  content_p_tag += h2elements.search("li p").inner_html
                elsif h2elements.search("li").any?
                  content_p_tag += h2elements.search("li").inner_html
                else
                  #content_p_tag += h2elements.search("p").inner_html
                end
                dietary_precaution=clean_p_tags_and_newline(content_p_tag)
              when content.match(/side effects/i)
                h2elements.search("a").remove # remove ahrefs
                if h2elements.search("#hgroup > p").any?
                  content_p_tag += h2elements.search("#hgroup > p").inner_html
                end
                if h2elements.search("#hgroup > h3").any?
                  content_p_tag += h2elements.search("#hgroup > h3").first.inner_html
                end
                if h2elements.search("li p").any?
                  temp=Array.new
                  h2elements.search("li p").each do |ele|
                    temp.push(ele.inner_html)
                  end
                  joinlist=temp.join(", ")
                  content_p_tag += joinlist
                elsif h2elements.search("li").any?
                  content_p_tag += h2elements.search("li").inner_html
                else
                  #content_p_tag += h2elements.search("p").inner_html
                end
                side_effects=clean_p_tags_and_newline(content_p_tag)

              when content.match(/storage and disposal/i)
                h2elements.search("a").remove # remove ahrefs
                if h2elements.search("#hgroup > p").any?
                  content_p_tag += h2elements.search("#hgroup > p").inner_html
                end
                if h2elements.search("#hgroup > h3").any?
                  content_p_tag += h2elements.search("#hgroup > h3").first.inner_html
                end
                if h2elements.search("li p").any?
                  content_p_tag += h2elements.search("li p").inner_html
                elsif h2elements.search("li").any?
                  content_p_tag += h2elements.search("li").inner_html
                else
                  #content_p_tag += h2elements.search("p").inner_html
                end
                storage=clean_p_tags_and_newline(content_p_tag)
              when content.match(/other information should/i)
                h2elements.search("a").remove # remove ahrefs
                if h2elements.search("#hgroup > p").any?
                  content_p_tag += h2elements.search("#hgroup > p").inner_html
                end
                if h2elements.search("#hgroup > h3").any?
                  content_p_tag += h2elements.search("#hgroup > h3").first.inner_html
                end
                if h2elements.search("li p").any?
                  content_p_tag += h2elements.search("li p").inner_html
                elsif h2elements.search("li").any?
                  content_p_tag += h2elements.search("li").inner_html
                else
                  #content_p_tag += h2elements.search("p").inner_html
                end
                other_info=clean_p_tags_and_newline(content_p_tag)
              when content.match(/Brand names/i)
                next
              when content.match(/Other names/i)
                next
                h2elements.search("a").remove # remove ahrefs
                if h2elements.search("#hgroup > p").any?
                  content_p_tag += h2elements.search("#hgroup > p").inner_html
                end
                if h2elements.search("#hgroup > h3").any?
                  content_p_tag += h2elements.search("#hgroup > h3").first.inner_html
                end

                if h2elements.search("li p").any?
                  content_p_tag += h2elements.search("li p").inner_html
                elsif h2elements.search("li").any?
                  temp=Array.new
                  h2elements.search("li p").each do |ele|
                    temp.push(ele.inner_html)
                  end
                  joinlist=temp.join(";")
                  content_p_tag += joinlist
                  #content_p_tag += h2elements.search("li").inner_html
                else
                  #content_p_tag += h2elements.search("p").inner_html
                end
                other_names=clean_p_tags_and_newline(content_p_tag)
              else
                puts "#{content} didn't match any cases"
            end
          end

      # i'm handling brand names and other names seperately. this is due to the  tags not closing properly
      temp=Array.new
      contents=""
       if (doc/"div#brand-name")
         found=(doc/"div#brand-name")
         found.search("a").remove
         found.search("sup").remove
         if found.search("li").any?
           found.search("li").each do |ele|
             if !ele.inner_html.empty?
               ele_content= to_ascii_iconv (ele.inner_html)
               temp.push(ele_content)
             end
           end
         end
       end

      if (doc/"div#other-name-id")
        found=(doc/"div#other-name-id")
        found.search("a").remove
        found.search("sup").remove
        if found.search("li").any?
          found.search("li").each do |ele|
            if !ele.inner_html.empty?
              ele_content= to_ascii_iconv (ele.inner_html)
              temp.push(ele_content)
            end
          end
        end
      end
      temp.push(drugnamesplit)
      joinlist=temp.join(",")
      contents += joinlist
      brands=clean_p_tags_and_newline(contents)

      arr=Array.new
      arr.push(drugnamesplit,prescribed,howtouse,otheruses,precaution,dietary_precaution,side_effects,storage,other_info,brands,other_names)
      outstring=arr.join("||")
      PARSE.write("#{outstring}\n")

      #File.unlink(tmp_file)
      puts "#{filename} completed\n"
    end
    PARSE.close
  end


  ###############
  #find drugs name and upload general infomation into them usage: rake inputfile=medline_original/all.parsed.cleaned project:loadDrugsGeneralInfo
  ##############

  desc "task to clean reviews and remove weird encodings inserted by me inside database"
  task :loadDrugsGeneralInfo =>:environment do
    inputfile=ENV['inputfile']
    count=0
    tmp_file="load_drug_info.log"
    OUT=File.new tmp_file,"w"
    File.open(inputfile,"r") do |filereader|
      filereader.each do |line|
        next if line =~ /^drug/
        line.chomp!

        # get each column information
        line_arr=line.split(/\|\|/)
        name=line_arr[0].gsub(/Injection/,"Inj")
        prescription=line_arr[1]
        howtouse=line_arr[2]
        otheruses=line_arr[3]
        precaution=line_arr[4]
        dietary_precaution=line_arr[5]
        side_effect=line_arr[6]
        storage=line_arr[7]
        other_info=line_arr[8]
        other_known_names=line_arr[9].split(/,/)
        other_known_names_stringify=other_known_names.join(',')
        OUT.write "searching for #{name} other names:#{other_known_names}\n"

        #for each known brand names of medline file, we try to load the general info
        other_known_names.each do |known_name|
          knowns=known_name.gsub(/Injection/,"Inj")
          if knowns.length < 4    # throw out names that are really too short eg 'DM' such that it doesnt match everything
            puts "throwing out #{knowns} as it is too short\n"
            OUT.write "throwing out #{knowns} as it is too short\n"
            next
          end

          # match medline knwon names to the brandname
          otherknown_match=Drug.where("brand_name LIKE ?","%#{knowns}%")
          if otherknown_match.any?
            count+=1
            otherknown_match.each do |match|
              puts "case 1 #{match.brand_name} matched with #{knowns}\n"
              OUT.write "case 1 #{match.brand_name} matched with #{knowns}\n"
              clear_old_drug_info match
              OUT.write "clear older info.. checking: #{match.other_known_names}\n"
              match.update_attributes(prescription_for: prescription, how_to_use:howtouse, other_uses:otheruses, precaution: precaution,
                                      dietary_precaution:dietary_precaution, side_effect:side_effect, storage:storage,other_info:other_info, other_known_names: other_known_names_stringify)
              OUT.write "checking updated value: #{match.other_known_names}\n"
            end
          else

          #match  other_names
          otherknown_match_other_names=Drug.where("other_names LIKE ?","%#{knowns}%")
          if otherknown_match_other_names.any?
            count+=1
            otherknown_match_other_names.each do |match|
              puts "case 2 #{match.brand_name} matched with #{knowns}\n"
              OUT.write "case 2 #{match.brand_name} matched with #{knowns}\n"
              clear_old_drug_info match
              match.update_attributes(prescription_for: prescription, how_to_use:howtouse, other_uses:otheruses, precaution: precaution,
                                      dietary_precaution:dietary_precaution, side_effect:side_effect, storage:storage,other_info:other_info, other_known_names: other_known_names_stringify)
            end
          end
          end
        end
      end
    end
    puts "#{count} matched\n"
    OUT.write "#{count} matched\n"
    OUT.close
  end

    ###############
  #trying to pull more drugname alias usage: rake inputfile=medline_original/all.parsed.cleaned project:pulldrugalias
  ##############

  desc "task to pull drug alias from medline text"
  task :pulldrugalias =>:environment do
    inputfile=ENV['inputfile']
    count=0
    File.open(inputfile,"r") do |filereader|
      filereader.each do |line|
        next if line =~ /^drug/
        line.chomp!
        if line =~ //

        end

      end
    end
  end

  ###############
  #new task  rake project:fillDruginfoWithEmptyString
  ##############

  desc "fill drug info other know names with its own name"
  task :fillDruginfoWithEmptyString =>:environment do
    Drug.all.each do |drug|
        if drug.other_known_names
          puts "other know names : #{drug.other_known_names}\n"
          if drug.other_known_names !~ /#{drug.brand_name}/
            puts "no brand name in other known names\n"
            arr= drug.other_known_names.split(/,/)
            arr.push drug.brand_name
            other_known=arr.join(',')
            drug.other_known_names=other_known
            drug.save!
            puts "known names added : #{drug.other_known_names}\n"
          end
          #puts "other known names is not declared!"
          #drug.other_known_names=""
          #drug.save!
        end
    end

  end


  ########################
  # CLASS METHODS
  ########################
  def to_ascii_iconv str
    converter = Iconv.new('ASCII//IGNORE//TRANSLIT', 'UTF-8')
    converter.iconv(str).unpack('U*').select{ |cp| cp < 127 }.pack('U*')
  end

  def clear_old_drug_info obj
    obj.update_attributes(prescription_for: "", how_to_use: "",other_uses: "",precaution: "",dietary_precaution: "", side_effect: "", storage: "",other_info: "", other_known_names: "")
  end

  def clean_p_tags_and_newline(str)
    tempArray=Array.new
    str.each_line do |line|
      line.chomp!
      if line.blank?
        next
      end
      newstr=line.gsub(/\n/,"").gsub(/<p>/,"").gsub(/<\/p>/,"")
      tempArray.push(newstr)
    end
    cleaned_str=tempArray.join(" ")

    #title=""
    #inner_content=""
    #str.each_line do |line|
    #  #puts "this is a line #{line}\n"
    #  if line.match(/<li>/)
    #
    #    inner_content+=""
    #  elsif line.match(/<h3>/)
    #
    #  else
    #    next
    #  end
    #
    #  if line.match (/<p>/)
    #
    #  end
    #end
  end

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


  def format2hash(string)
    stringhash={}
    string.split(",").map { |keyvalue|
      arr=keyvalue.split("=>",2)
      stringhash[arr[0]]=arr[1].to_i
    }
    return stringhash
  end

  # self declared methods to get the values



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
