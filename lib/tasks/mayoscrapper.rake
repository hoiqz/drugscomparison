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
    #OUT=File.new("mayoclinic_conditions_info.tsv","a")
    OUT=File.new("rubbish.tsv","a")

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
      #puts row
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
      content1=b.inner_html.gsub("<br />",". ").delete!("\r")
      content2=content1.delete!("\n").delete!("\t")
      content=content2.gsub(/<\/li>/,"||")
      #clear_html_tag=content
      clear_html_tag=Hpricot(content).to_plain_text
      #puts "line now is #{clear_html_tag}"
      #clear_html_tag=clear_html_tag2.delete!("\n").delete!("\t")
     storage.push("#{header}::#{clear_html_tag}")
   end
        str=storage.join("\t")
        OUT.write("#{str}**END**")
        sleeptime=60+rand(60)
        #sleeptime=rand(60)
        sleep(sleeptime.seconds)

      end
    end
    OUT.close
  end

  #########################################
  # rake in=inputfile screenscrapper:changeFormat
  #########################################
  desc "formats the inputfile into one line one drug description."
  task :changeFormat =>:environment do
    require 'iconv'
    input=ENV['in']
    ic = Iconv.new("UTF-8//IGNORE", "UTF-8")
    OUT=File.new("#{input}.tmp","w")
    File.open(input,"r") do |filereader|
      filereader.each do |line_original|
        entry=ic.iconv(line_original)
        line=entry.gsub(/\[.*\]/,'').gsub(/http(.*?)\s/,'').gsub("\n",'||')
        line.gsub!(/Subscribe to .*\|\|/,"||")
        OUT.write(line)
        #print line
      end
    end
    OUT2=File.new("#{input}.formatted","w")
    File.open("#{input}.tmp","r") do |filereader|
      filereader.each do |line_original|
        entry=ic.iconv(line_original)
        line=entry.gsub("**END**","\n")
        OUT2.write(line)
        #print line
      end
    end
    OUT.close
    OUT2.close
  end


  #########################################
  # rake in=inputfile screenscrapper:parseConditionText
  #########################################
  desc "parse conditions_info.tsv file into db"
  task :parseConditionText =>:environment do
    require 'iconv'
    input=ENV['in']              # input file is the whole mayo conditions downloaded
    ic = Iconv.new("UTF-8//IGNORE", "UTF-8")
    OUT=File.new("xa.tsv","w")
    count=0
  Condition.all.each do |condition|
    #if condition.name != "High Blood Pressure"
    #  next
    #end
    File.open(input,"r") do |filereader|
      filereader.each do |line_original|
        entry=ic.iconv(line_original)
        line=entry.split(/\t/)
        line[0].strip!
        if condition.other_names
        if condition.other_names.upcase ==  line[0].upcase
          OUT.write "condition #{condition.name} : #{condition.other_names} matched #{line[0]}\n"
          loadinfo(condition,entry)
          count=count+1
          break
        else
          if line[1] != ""
            line[1].strip!
            if condition.other_names.upcase == line[1].upcase
              OUT.write "condition #{condition.name} : #{condition.other_names} matched #{line[1]}\n"
              loadinfo(condition,entry)
              count=count+1
              break
            end
          end
        end
        end
        #OUT.write "condition #{condition.name} no match #{line[0]} and #{line[1]}\n"
      end
      OUT.write "condition #{condition.name} no match!\n"
    end
  end
    puts count
    OUT.close
  end

  def loadinfo(match,text)
    #match_arr=shift
    #text=shift
    textarr=text.split(/\t/)
    textarr.shift(2)


    (information,symptoms,causes,risk_factors,treatment_and_medication,prevention,alternative_medication,complications,lifestyle,coping_with_disease)=""
    textarr.each do |element1|
      #element=element1.gsub(/\|+/,"\n")
      element=element1
      if element =~ /Definition::(.*)/
        information=$1.gsub(/\|+/,"\n")
        #puts "definition:#{information}"
        next
      end
      if element =~ /Symptoms::(.*)/
        symptoms=$1.gsub(/\|+/,"\n")
        #puts "symnptons:#{symptoms}"
        next
      end
      if element =~ /Causes::(.*)/
        causes=$1.gsub(/\|+/,"\n")
        #puts "causes:#{causes}"
        next
      end
      if element =~ /Risk factors::(.*)/
        risk_factors=$1.gsub(/\|+/,"\n")
        #puts "risks:#{risk_factors}"
        next
      end
      if element =~ /Complications::(.*)/
        complications=$1.gsub(/\|+/,"\n")
        #puts "complications:#{complications}"
        next
      end
      if element =~ /Treatments and drugs::(.*)/
        treatment_and_medication=$1.gsub(/\|+/,"\n")
        #puts "treatment:#{treatment_and_medication}"
        next
      end
      if element =~ /Lifestyle and home remedies::(.*)/
        lifestyle=$1.gsub(/\|+/,"\n")
        #puts "lifestyle:#{lifestyle}"
        next
      end
      if element =~ /Prevention::(.*)/
        prevention=$1.gsub(/\|+/,"\n")
        #puts "prevention:#{prevention}"
        next
      end
      if element =~ /Coping and support::(.*)/
        coping_with_disease=$1.gsub(/\|+/,"\n")
        #puts "coping with disease:#{coping_with_disease}"
        next
      end
      if element =~ /Alternative medicine::(.*)/
        alternative_medication=$1.gsub(/\|+/,"\n")
        #puts "alt med:#{alternative_medication}"
        next
      end
    end

      match.update_attributes(:information=>information,
                                :symptoms=>symptoms,
                                :causes=>causes,
                                :risk_factors=>risk_factors,
                                :complications=>complications,
                                :treatment_and_medication=>treatment_and_medication,
                                :lifestyle=>lifestyle,
                                :prevention=>prevention,
                                :coping_with_disease=>coping_with_disease,
                                :alternative_medication=>alternative_medication
      )
      puts "#{match.name} updated"
  end

  #########################################
  # rake in=inputfile screenscrapper:addGeneralNameToConditions
  #########################################
  desc "add in the common conditions name to those weird looking conditions from webmd"
  task :addGeneralNameToConditions =>:environment do
    require 'iconv'
    input=ENV['in']
    File.open(input,"r") do |filereader|
      filereader.each do |line_original|
        next if line_original=~/^#/
        line=line_original.split(/\t/)
        original=line[0].gsub(/\"/,'').gsub(/\n/,'')
        alternative=line[1].gsub(/\"/,'').gsub(/\n/,'')  if line[1]
        if alternative=~/-/
          next
          puts "#{line_original} has no alternative name"
        else
          puts "#{line_original} has alternative #{alternative}"
          original_con=Condition.find_by_name(original)
            puts "found #{original_con}"
          original_con.update_attributes(:other_names=>alternative)  if original_con
        end
      end
    end
  end

  #########################################
  # rake in=inputfile screenscrapper:reformatMyConditionFile
  #########################################
  desc "add in the common conditions name to those weird looking conditions from webmd"
  task :reformatMyConditionFile =>:environment do
    require 'iconv'
    input=ENV['in']
    OUT=File.new("#{input}.reformatted","w")
    File.open(input,"r") do |filereader|
      filereader.each do |line_original|
        if line_original=~/^#/
          OUT.write "#{line_original}\n"
        end
        line=line_original.split(/\t/)
        original=line[0].gsub(/\"/,'').gsub(/\n/,'')
        alternative=line[1].gsub(/\"/,'').gsub(/\n/,'').gsub(/,(.*)/,'')
        OUT.write "#{original}\t#{alternative}\n"
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

