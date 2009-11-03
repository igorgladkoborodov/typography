class String
  def typography(options = {})
    str = String.new(self)

    #html_escape
    str.gsub!(/[&><]/) { |special| { '&' => '&amp;', '>' => '&gt;', '<' => '&lt;' }[special] } if options[:escape_html]

    #apostrophe
    str.gsub!(/(\w)'(\w)/, '\1&#146;\2')

    #russian quotes
    str.replace_quotes! '&#171;', '&#187;', '&#132;', '&#147;', 'а-яА-Я'

    #english quotes
    str.replace_quotes!

    #mdash
    str.gsub!(/--/, '&mdash;')
    str.gsub!(/(\w|;)\s+(—|–|-)\s*(\w)/, '\1&nbsp;&mdash; \3')
    #todo Испанцы говорят, что целовать мужчину без усов, - всё равно что есть яйцо без соли
    str.gsub!(/\s+&mdash;/, '&nbsp;&mdash;')

    #nobr
    #around dash-separated words (что-то)
    str.gsub!(/(^|\s)((\w|0-9){1,3})-((\w|0-9){1,3})($|\s)/, '\1<span class="nobr">\2-\4</span>\6')
    #1980-x почему-то
    str.gsub!(/(^|\s)((\w|0-9)+)-((\w|0-9){1,3})($|\s)/, '\1<span class="nobr">\2-\4</span>\6')

    #non brake space
    str.gsub!(/(^|\s|\()(\w{1,2})\s+([^\s])/i, '\1\2&nbsp;\3')
    str.gsub!(/(^|\s|\()&([A-Za-z0-9]{2,8}|#[\d]*);(\w{1,2})\s+([^\s])/i, '\1&\2;\3&nbsp;\4') #entities
    str.gsub!(/(&nbsp;|&#161;)(\w{1,2})\s+([^\s])/i, '\1\2&nbsp;\3\4')
  
    str.to_s
  end


  def replace_quotes!(*args)
    self.replace self.replace_quotes(*args)
  end

  def replace_quotes(left1 = '&#147;', right1 = '&#148;', left2 = '&#145;', right2 = '&#146;', letters = 'a-zA-Z')
    str = String.new(self)
    replace_quotes = lambda do
      old_str = String.new(str)
      str.gsub!(Regexp.new("(\"|\')([#{letters}].*?[^\\s])\\1", Regexp::MULTILINE | Regexp::IGNORECASE)) do |match|
        inside, before, after = $2, $`, $'
        if after.match(/^([^<]+>|>)/) || before.match(/<[^>]+$/) #inside tag
          match
        else
          "#{left1}#{inside}#{right1}"
        end
      end
      old_str != str
    end
    while replace_quotes.call do end

    # second level
    replace_second_level_quotes = lambda do
      str.gsub! Regexp.new("#{left1}(.*)#{left1}(.*)#{right1}(.*)#{right1}", Regexp::MULTILINE | Regexp::IGNORECASE) do |match|
        "#{left1}#{$1}#{left2}#{$2}#{right2}#{$3}#{right1}"
      end
    end
    while replace_second_level_quotes.call do end

    str
  end
end

