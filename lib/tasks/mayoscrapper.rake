namespace :screenscrapper do
  #########################################
  #rake screenscrapper:getMayoDrugList
  #########################################
  desc "get list of drugs from mayo clinic"
  task :getMayoDrugList =>:environment do
    require 'open-uri'
    address="http://www.mayoclinic.com/health/DiseasesIndex/DiseasesIndex/METHOD=displayAlphaList&LISTTYPE=mcDisease&LETTER="
    root="http://www.mayoclinic.com"
    OUT=File.new("mayoclinic_condition","a+")
    ("a".."z").each do |letter|
      puts address+letter
      doc = Hpricot(open(address+letter))
      #doc = Hpricot(open("http://www.askapatient.com/drugalpha.asp?letter=A"))
      #doc.search("/html/body/div[3]/div[2]/div[2]/div[2]/div/ul/li/a").each do |row|
      doc.search("html body div#wrapper div#main div#content div#b.tests div#letternav ul.list li").each do |row|
        puts row
        entry=row.inner_html
        if entry=~/See/
           name=entry.gsub(/\(See:(.*)\)/,'')
          puts name
          similar_conditions=row.search("a").inner_html
        else
          name=row.search("a").inner_html
          similar_conditions=""
        end
          newrow=row.search("a")
        #puts "newrow element is #{newrow}\n"
        href= newrow.first[:href]
        location=root+href
        url_array=href.split(/\//)
        drugid=url_array.last
        puts name
        puts location
        OUT.write("#{name}\t#{similar_conditions}\t#{drugid}\t#{location}\n")
      end
      #sleeptime=50+rand(50)
      #sleep(sleeptime.seconds)
    end
    # do for letter #
    letter='0'
    doc = Hpricot(open(address+letter))
    doc.search("html body div#wrapper div#main div#content div#b.tests div#letternav ul.list li").each do |row|
      puts row
      entry=row.inner_html
      if entry=~/See/
        name=entry.gsub(/\(See:(.*)\)/,'')
        puts name
        similar_conditions=row.search("a").inner_html
      else
        name=row.search("a").inner_html
        similar_conditions=""
      end
      newrow=row.search("a")
      #puts "newrow element is #{newrow}\n"
      href= newrow.first[:href]
      location=root+href
      url_array=href.split(/\//)
      drugid=url_array.last
      puts name
      puts location
      OUT.write("#{name}\t#{drugid}\t#{location}\n")
    end
  end

  #########################################
  #rake in=inputfile screenscrapper:pullMayoInfo eg rake in=mayoclinic_condition screenscrapper:pullMayoInfo
  #########################################
  desc "go throught A-Z pull Mayo Clinic condition information"
  task :pullMayoInfo =>:environment do
    require 'open-uri'
    require 'action_view'
    require 'iconv'
    include ActionView::Helpers::SanitizeHelper

    root="http://www.mayoclinic.com"
    input=ENV['in']
    OUT=File.new("mayoclinic_conditions_info.tsv","a")

    File.open(input,"r") do |filereader|
      filereader.each do |line|
        if line=~/^#/
          puts "skipping #{line}"
          next
        end
        storage=Array.new()
        entry=line.chomp.split(/\t/)
        condition_name=entry[0]
        other_condition_name=entry[1]
        url=entry[3]
        id=entry[2]
        #doc = Hpricot(open(url))
        #doc = open("test.html") { |f| Hpricot(f) }
        puts "working on #{condition_name}. URL : #{url}"
        ic = Iconv.new("UTF-8//IGNORE", "UTF-8")
        doc = open(url) {|f| Hpricot(ic.iconv(f.read)) }
        storage.push(condition_name,other_condition_name,url)
        #doc.search("html body div#wrapper div#main div#content div#b ul.related").remove
   doc.search("html body div#wrapper div#main div#content div#a ul#tabnav li").each do |row|
      puts row
      naventry=row.search("a")
     header=naventry.inner_html
     header_href=root+naventry.first[:href]
     submenu = open(header_href) {|f| Hpricot(ic.iconv(f.read)) }
      b=submenu.search("div[@id=b]")
      b.search("div[@class=pagenav]").remove
      b.search("div[@class=inset]").remove
      b.search("a").remove
      b.search("ul[@class=related]").remove
      b.search("span[@class=linkHeader]").remove
      b.search("span[@class=linkHeaderLineBreak]").remove
      b.search("div[@id=references_wrapper]").remove
      b.search("div[@id=contentfooter]").remove
      b.search("a[@id=staff]").remove
      b.search("h1").remove
    #puts b
      content=b.inner_html
      clear_html_tag=Hpricot(content).to_plain_text.gsub(/\n+/,"\n").gsub(/^\n/,'').gsub(/\n/,'||')
     storage.push("#{header}::#{clear_html_tag}")
   end
        str=storage.join("\t")
        OUT.write("#{str}\n")
        sleeptime=60+rand(60)
        sleep(sleeptime.seconds)

      end
    end
    OUT.close
  end

  #########################################
  # rake in=inputfile screenscrapper:parseConditionText
  #########################################
  desc "parse conditions_info.tsv file into db"
  task :parseConditionText =>:environment do
    input=ENV['in']
    File.open(input,"r") do |filereader|
      filereader.each do |line|
        entry=line.split(/\t/)
        entry.each do |test|
          puts test
        end
      end
    end
  end

  #########################################
  # rake in=inputfile screenscrapper:matchConditiontoDB
  #########################################
  desc "match conditions_info.tsv file into db conditions"
  task :matchConditiontoDB =>:environment do
    input=ENV['in']
    OUT=File.new("xa.txt","w")
    counter=0
    File.open(input,"r") do |filereader|
      filereader.each do |line|
        entry=line.split(/\t/)
        condition=entry[0]
        other_condition=entry[1]
        #url=entry[2]
        #definition=entry[3]
        #symptoms=entry[4]
        #causes=entry[5]
        #riskfactors=entry[6]
        #complications=entry[7]
        #preparingforappt=entry[8]
        #test_diagnostics=entry[9]
        #treamtment_drugs=entry[10]
        #lifestype=entry[11]
        #prevention=entry[12]
        ##puts condition
        #puts other_condition
        #puts url
        #puts "definition-#{definition}"
        #puts "symptoms-#{symptoms}"
        #puts "causes-#{causes}"
        #puts "riskfactors-#{riskfactors}"
        #puts "complications-#{complications}"
        #puts "preparingforappt-#{preparingforappt}"
        #puts "test_diagnostics-#{test_diagnostics}"
        #puts "treamtment_drugs-#{treamtment_drugs}"
        #puts "lifestype-#{lifestype}"
        #puts "prevention-#{prevention}"
        found=Condition.where("name LIKE ?","%#{condition}%")

        if ! found.blank?
          foundstrarr=Array.new()
          found.each do |con|
            foundstrarr.push(con.name)
          end
          foundstr=foundstrarr.join(',')
          OUT.write("condition #{condition} match to our DB #{foundstr}\n")
          counter+=1
        end

        if ! other_condition.empty?
          find2=  Condition.where("name LIKE ?","%#{other_condition}%")
          if ! find2.blank?
            foundstrarr2=Array.new()
            find2.each do |con|
              foundstrarr2.push(con.name)
            end
            foundstr=foundstrarr2.join(',')
            OUT.write("other condition #{other_condition} match to our DB #{foundstr}\n")
            counter+=1
          end
        end

      end
    end
    puts counter
    OUT.close
  end
end

