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
  # rake druglist=test1 input_dir=/c/Documents\ and\ Settings/hoiqz/RubymineProjects/everydayhealth/reviews/tmp project:initalize_everydayhealth_table
  ###########################################
  desc "get data from pages scrapped off everyday health"
  task :initalize_everydayhealth_table =>:environment do
    require 'open-uri'
    #inputdir=ENV["in"]
    druglist=ENV['druglist']
    reviews_folder=ENV['input_dir']
    File.open(druglist,"r") do |filereader|
      filereader.each do |line|
        drug=line.chomp
        Dir.mkdir("everydayhealth_reviews")
        OUT=File.new("everydayhealth_reviews/#{drug}.reviews","w+")
        puts drug
       # for each drug open its drug file
        drug_review=reviews_folder+"/#{drug}"

        doc = open(drug_review) { |f| Hpricot(f) }
        #doc = Hpricot(open("http://www.everydayhealth.com/drugs/search?browse_type=m&q=#{drug}&src=ww_ctsearch"))

        #first we check the number of reviews there are

        found=(doc/"html body#htmBody div#Drugs.tools div div#container div#content div#template div#outer div#inner div#twocolumn.template div.col1 div#browsable.detail-browsable div div.tabbed div.tabbed-outer div.tabbed_skinny div.tabbed_skinny_content div.bvr-tab-container p").inner_html
         if found=~/No ratings found/
           source_reviews=0
           if existing=Everydayhealth.find_by_name("#{drug}")
             existing.update_attributes(:latest_reviews=> source_reviews, :current_reviews=>source_reviews)
           else
             Everydayhealth.create(:name=>"#{drug}",:latest_reviews=> source_reviews, :current_reviews=>source_reviews)
           end

         end
        #puts found if found
        found2=(doc/"html body#htmBody div#Drugs.tools div div#container div#content div#template div#outer div#inner div#twocolumn.template div.col1 div#browsable.detail-browsable div div.tabbed div.tabbed-outer div.tabbed_skinny div.tabbed_skinny_content div.bvr-tab-container div#treatment_ratings.user_ratings div.pagination div.pagination_left").inner_html
        if found2=~/\((.*)? results found\)/
          source_reviews= $1.to_i
        end
        #source_reviews

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
    OUT=File.new("askapatient.druglist2","w+")
    ("L".."Z").each do |letter|
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
       sleeptime=5+rand(10)
      sleep(sleeptime.minutes)
    end
  end


  #########################################
  #rake in=inputfile project:pullaskapatientreviews
  #########################################
  desc "go throught A-Z get askapatient druglist drug id and page URL"
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
            sleeptime=rand(10)+rand(15)
            sleep(sleeptime.minutes)
          end
        end
        sleeptime=7+rand(20)
        sleep(sleeptime.minutes)
        OUT.close
      end
    end

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
