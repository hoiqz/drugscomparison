class Testing
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
             "%2a"=>"*",
             "%2b"=>"+",
             "%2c"=>",",
             "%2d"=>"-",
             "%2e"=>".",
             "%2f"=>"/",
             "%5b"=>"[",
             "%5c"=>"\\",
             "%5d"=>"]",
             "%5e"=>"^",
             "%5f"=>"_",
             "%60"=>"`"
  }

  def self.urldecode(str)
  # always  first replace the + with space . then do the urldecode method  if not the encoded "+" will be gone
  str2=str.gsub(/\+/," ")
  puts "#{str2}"
  str2.to_enum(:scan,  /%../i ).map {
    matched=Regexp.last_match.to_s
    pattern=matched
    replace=@urltable["#{matched}"]
    puts replace
    if replace
      str2=str2.gsub(/#{Regexp.escape(pattern)}/,"#{replace}")
      puts "check ->#{str2} pattern -> #{pattern}"
    end
  }


  print "#{str}=> #{str2}"
  return str2
end

test=Array.new
test=['A+%26+D+Barrier+Top','A%2fT%2fS+Top']

test.each do |item|
  a=urldecode(item)
end

end
