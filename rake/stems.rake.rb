require 'nokogiri'
require_relative 'helpers/morpheus_xml_reader.rb'
require_relative 'helpers/morpheus_lemma_reader.rb'

namespace :stems do
  STEMS_DIR = "#{SRC_DIR}/stems"

  NOUN_STEM_XML = "#{STEMS_DIR}/morpheus_nouns.xml"
  VERB_STEM_XML = "#{STEMS_DIR}/morpheus_verbs.xml"
  NOUN_STEM_LEX = "#{STEMS_DIR}/nouns.lex"
  VERB_STEM_LEX = "#{STEMS_DIR}/verbs.lex"

  LEMMA_LEX = "#{STEMS_DIR}/lemmas.lex"
  LEMMA_SRC = "#{OBJ_DIR}/lemmas.fst"
  LEMMA_OBJ = "#{OBJ_DIR}/lemmas.a"
  LEMMA_ATT = "#{OBJ_DIR}/lemmas.att"
  LEMMA_ATS = "#{OBJ_DIR}/lemmas.ats"
  LEMMA_ATE = "#{OBJ_DIR}/lemmas.ate"

  STEMS_SRC = "#{OBJ_DIR}/stems.fst"
  STEMS_OBJ = "#{OBJ_DIR}/stems.a"

  CLEAN.include(NOUN_STEM_LEX)
  CLEAN.include(VERB_STEM_LEX)
  CLEAN.include(LEMMA_LEX)

  CLOBBER.include(LEMMA_SRC)
  CLOBBER.include(LEMMA_OBJ)
  CLOBBER.include(LEMMA_ATT)
  CLOBBER.include(LEMMA_ATE)
  CLOBBER.include(LEMMA_ATS)

  CLOBBER.include(STEMS_SRC)
  CLOBBER.include(STEMS_OBJ)
 
  file STEMS_OBJ => STEMS_SRC  
  file STEMS_SRC => [NOUN_STEM_LEX, VERB_STEM_LEX] do
    out = File.open(STEMS_SRC, "w")
    out.puts "\"#{NOUN_STEM_LEX}\" | \"#{VERB_STEM_LEX}\""
    out.close
  end

  file NOUN_STEM_LEX => NOUN_STEM_XML do
    parser = Nokogiri::XML::SAX::Parser.new(MorpheusXMLReader.new NOUN_STEM_LEX)
    parser.parse(File.open(NOUN_STEM_XML))
  end

  file VERB_STEM_LEX => VERB_STEM_XML do
    parser = Nokogiri::XML::SAX::Parser.new(MorpheusXMLReader.new VERB_STEM_LEX)
    parser.parse(File.open(VERB_STEM_XML))
  end

  file LEMMA_LEX => [NOUN_STEM_XML, VERB_STEM_XML] do
    parser = Nokogiri::XML::SAX::Parser.new(MorpheusLemmaReader.new LEMMA_LEX)
    parser.parse(File.open(NOUN_STEM_XML))
    parser.parse(File.open(VERB_STEM_XML))
  end 

  file LEMMA_SRC => LEMMA_LEX do
    out = File.open(LEMMA_SRC, "w")
    out.puts "\"#{LEMMA_LEX}\""
    out.close
  end

  file LEMMA_OBJ => LEMMA_SRC
  file LEMMA_ATT => LEMMA_OBJ
  file LEMMA_ATS => LEMMA_ATT

  desc "Build the AT&T format FSTs required for Parsley."
  task :lemmas => [STEMS_OBJ, LEMMA_ATT, LEMMA_ATS]

  task :default => :lemmas
end
