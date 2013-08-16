#########################################
  #rake in=inputfile project:pullmedlinepluspatientreviews
  #########################################
  #desc "go throught A-Z pull ask a patient reviews"
  #task :pullaskapatientreviews =>:environment do
    require 'open-uri'
    require 'action_view'
    require 'iconv'
    require 'hpricot'
    #include ActionView::Helpers::SanitizeHelper

    #root="http://www.askapatient.com/"
    #input=ENV['in']
    if ARGV.count <2
       abort("\n\tUsage: ruby #{$0} <medlineplus.druglist> <outputdirectoy>\n\n")
    end

    input = ARGV[0]
    outdir = ARGV[1]
    Dir.mkdir(outdir) unless File.exists?(outdir)
    File.open(input,"r") do |filereader|
      filereader.each do |line|
        if line=~/^#/
          puts "skipping #{line}"
          next
        end
        entry=line.chomp.split(/\t/)
        url=entry[2]
        filename=entry[0].gsub(/\s/,"+")
        for_windows_file= filename.gsub(/\//,"").gsub(/"/,"")
        #doc = Hpricot(open(url))
        #doc = open("test.html") { |f| Hpricot(f) }
        ic = Iconv.new("UTF-8//IGNORE", "UTF-8")
        doc = open(url) {|f| Hpricot(ic.iconv(f.read)) }
        OUT=File.new("#{outdir}/#{for_windows_file}_reviews.tsv","w")
        if doc.at("div#boxed-warning")
           OUT.write(doc.at("div#boxed-warning"))
        end

        doc2 = doc.search("html body div#wrap div#pbody").inner_html.split("<div class=\"hblock group\">")
        doc2[1..-1].each do |r1|
          r=r1.gsub("</div>","")
          OUT.write("<div id=hgroup")
          OUT.write(r)
          OUT.write("</div>\n")
        end
        OUT.close
        sleeptime=10+rand(20)
        print "Sleeping Time : #{sleeptime}\n"
        sleep(sleeptime)
     end
  end
