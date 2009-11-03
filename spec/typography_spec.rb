require File.dirname(__FILE__) + '/spec_helper'

describe TypographyHelper, 'with typography' do
  include TypographyHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper

  it "should have t helper" do
    ty('typography me please').should == 'typography me&nbsp;please'
  end

  it "should typography output of h helper" do
    h('Typography & &amp;').should == 'Typography &amp; &amp;amp;'
  end

  it "should typography output of simple_format helper" do
    simple_format("I'm first\n\nAnd I&nbsp;am&nbsp;second").should == "<p>I&#146;m first</p>\n\n<p>And I&nbsp;am&nbsp;second</p>"
  end

  it "should return '<p></p>' (simple_format of empty string) on simple_format(nil)" do
    simple_format(nil).should == "<p></p>"
  end
end

describe String, 'with typography' do

  it "should make russian quotes for quotes with first russian letter" do
    '"текст"'.typography.should == '&#171;текст&#187;'
    'Text "текст" text'.typography.should == 'Text &#171;текст&#187; text'
    'Text "текст" text "Другой текст" '.typography.should == 'Text &#171;текст&#187; text &#171;Другой текст&#187; '
  end

  it "should do the same with single quotes" do
    '\'текст\''.typography.should == '&#171;текст&#187;'
    'Text \'текст\' text'.typography.should == 'Text &#171;текст&#187; text'
    'Text \'текст\' text \'Другой текст\' '.typography.should == 'Text &#171;текст&#187; text &#171;Другой текст&#187; '
  end


  it "should create second-level russian quotes" do
    'Текст "в кавычках "второго уровня""'.typography.should == 'Текст &#171;в&nbsp;кавычках &#132;второго уровня&#147;&#187;'
  end


  it "should make english quotes for quotes with first non-russian letter" do
    '"text"'.typography.should == '&#147;text&#148;'
    'Text "text" text'.typography.should == 'Text &#147;text&#148; text'
    'Text "text" text "Another text" '.typography.should == 'Text &#147;text&#148; text &#147;Another text&#148; '
  end

  it "should do the same with single quotes" do
    '\'text\''.typography.should == '&#147;text&#148;'
    'Text \'text\' text'.typography.should == 'Text &#147;text&#148; text'
    'Text \'text\' text \'Another text\' '.typography.should == 'Text &#147;text&#148; text &#147;Another text&#148; '
  end

  it "should create second-level english quotes" do
    'Text "in quotes "second level""'.typography.should == 'Text &#147;in&nbsp;quotes &#145;second level&#146;&#148;'
  end


  it "should not replace quotes inside html tags" do
    '<a href="ссылка">ссылка</a>'.typography.should == '<a href="ссылка">ссылка</a>'
    '<a href=\'ссылка\'>"ссылка"</a>'.typography.should == '<a href=\'ссылка\'>&#171;ссылка&#187;</a>'

    '<a href=\'link\'>link</a>'.typography.should == '<a href=\'link\'>link</a>'
    '<a href="link">"link"</a>'.typography.should == '<a href="link">&#147;link&#148;</a>'

    ' one">One</a> <a href="two"></a> <a href="three" '.typography.should == ' one">One</a> <a href="two"></a> <a href="three" '
  end
  
  it "should make english and russian quotes in the same string" do
    '"Кавычки" and "Quotes"'.typography.should == '&#171;Кавычки&#187; and &#147;Quotes&#148;'
    '"Quotes" и "Кавычки"'.typography.should == '&#147;Quotes&#148; и&nbsp;&#171;Кавычки&#187;'

    '"Кавычки "второго уровня"" and "Quotes "second level""'.typography.should == '&#171;Кавычки &#132;второго уровня&#147;&#187; and &#147;Quotes &#145;second level&#146;&#148;'
    '"Quotes "second level"" и "Кавычки "второго уровня""'.typography.should == '&#147;Quotes &#145;second level&#146;&#148; и&nbsp;&#171;Кавычки &#132;второго уровня&#147;&#187;'
  end

  it "should replace -- to &mdash;" do
    'Replace -- to mdash please'.typography.should == 'Replace&nbsp;&mdash; to&nbsp;mdash please'
  end

  it "should replace \"word - word\" to \"word&nbsp;&mdash; word\"" do
    'word - word'.typography.should == 'word&nbsp;&mdash; word'
  end

  it "should insert &nbsp; before each &mdash; if it has empty space before" do
    'Before &mdash; after'.typography.should == 'Before&nbsp;&mdash; after'
    'Before	 &mdash; after'.typography.should == 'Before&nbsp;&mdash; after'
    'Before&mdash;after'.typography.should == 'Before&mdash;after'
  end


  it "should insert &nbsp; after small words" do
    'an apple'.typography.should == 'an&nbsp;apple'
  end

  it "should insert &nbsp; after small words" do
    'I want to be a scientist'.typography.should == 'I&nbsp;want to&nbsp;be&nbsp;a&nbsp;scientist'
  end

  it "should insert &nbsp; after small words with ( or dash before it" do
    'Apple (an orange)'.typography.should == 'Apple (an&nbsp;orange)'
  end

  it "should not insert &nbsp; after small words if it has not space after" do
    'Хорошо бы.'.typography.should == 'Хорошо бы.'
    'Хорошо бы'.typography.should == 'Хорошо бы'
    'Хорошо бы. Иногда'.typography.should == 'Хорошо бы. Иногда'
  end

  it "should insert <span class=\"nobr\"></span> around small words separated by dash" do
    'Мне фигово что-то'.typography.should == 'Мне фигово <span class="nobr">что-то</span>'
    'Как-то мне плохо'.typography.should == '<span class="nobr">Как-то</span> мне плохо'
    'хуе-мое'.typography.should == '<span class="nobr">хуе-мое</span>'
  end

  it "should not insert <span class=\"nobr\"></span> around words separated by dash if both of them are bigger than 3 letters" do
    'мальчик-девочка'.typography.should == 'мальчик-девочка'
  end


  it "should escape html if :escape_html => true is passed" do
    '< & >'.typography(:escape_html => true).should == '&lt; &amp; &gt;'
  end

  it "should replace single quote between letters to apostrophe" do
    'I\'m here'.typography.should == 'I&#146;m here'
  end


  it "should typography real world examples" do
    '"Читаешь -- "Прокопьев любил солянку" -- и долго не можешь понять, почему солянка написана с маленькой буквы, ведь "Солянка" -- известный московский клуб."'.typography.should == '&#171;Читаешь&nbsp;&mdash; &#132;Прокопьев любил солянку&#147;&nbsp;&mdash; и&nbsp;долго не&nbsp;можешь понять, почему солянка написана с&nbsp;маленькой буквы, ведь &#132;Солянка&#147;&nbsp;&mdash; известный московский клуб.&#187;'
  end

  it "should typography real world examples" do
    '"Заебалоооооо" противостояние образует сет, в частности, "тюремные психозы", индуцируемые при различных психопатологических типологиях.'.typography(:escape_html => true).should == '&#171;Заебалоооооо&#187; противостояние образует сет, в&nbsp;частности, &#171;тюремные психозы&#187;, индуцируемые при различных психопатологических типологиях.'
  end

  it "should typography real world examples" do
    '"They are the most likely habitat that we\'re going to get to in the foreseeable future," said NASA Ames Research Center\'s Aaron Zent, the lead scientist for the probe being used to look for unfrozen water.'.typography.should == '&#147;They are the most likely habitat that we&#146;re going to&nbsp;get to&nbsp;in&nbsp;the foreseeable future,&#148; said NASA Ames Research Center&#146;s Aaron Zent, the lead scientist for the probe being used to&nbsp;look for unfrozen water.'
  end
  
  it "should typography real wordl examples" do
    'Фирменный стиль: от полиграфии к интернет-решениям (в рамках выставки «Дизайн и Реклама 2009»)'.typography.should == 'Фирменный стиль: от&nbsp;полиграфии к&nbsp;интернет-решениям (в&nbsp;рамках выставки «Дизайн и&nbsp;Реклама 2009»)'
  end

  it "should typography real world examples" do
    'решениям (в рамках выставки'.typography.should == 'решениям (в&nbsp;рамках выставки'
  end

  it "should typography real world examples" do
    'Реанимация живописи: «новые дикие» и «трансавангард» в ситуации арт-рынка 1980-х'.typography.should == 'Реанимация живописи: «новые дикие» и&nbsp;«трансавангард» в&nbsp;ситуации арт-рынка <span class="nobr">1980-х</span>'
  end
  
  it "should typography real world examples" do
    '«Искусство после философии&#187; – концептуальные стратегии Джозефа Кошута и Харальда Зеемана'.typography.should == '«Искусство после философии&#187;&nbsp;&mdash; концептуальные стратегии Джозефа Кошута и&nbsp;Харальда Зеемана'
  end
  
  it "should typography real world examples" do
    'Испанцы говорят, что целовать мужчину без усов, - всё равно что есть яйцо без соли'.typography.should == 'Испанцы говорят, что целовать мужчину без усов,&nbsp;&mdash; всё равно что есть яйцо без соли'
  end

  
  
  # it "should fail" do
  #   1.should == 2
  # end

end
