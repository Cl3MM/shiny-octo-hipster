# encoding: UTF-8

require 'rubygems'
require 'roo'
require 'nokogiri'
require 'digest/md5'

CONTACT_DIR = "/home/clem/Dropbox/Share/CERES/Communication/Client list"
EMAIL_PATERN = /(\b[A-Za-z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b)/
namespace :udb do


  def md5sum filename
      Digest::MD5.hexdigest open(filename,"rb"){|f| f.read}
  end

  def create_or_update_file_db(path = CONTACT_DIR)
    contact_dir_glob = path +  "/**/**/**/"
    @contact_files = ContactFile.all
    Dir.glob(contact_dir_glob + '*.{txt,csv}') do |filename|
      md5_checksum = md5sum(filename)

    end
  end

  desc "Create or Update Files from directory"
  task :create_or_update_files => :environment do
    create_or_update_file_db
  end

  def extract_emails file_path
    unsorted_emails = []
    File.open(file_path, 'r') do |f|
      while line = f.gets
        begin
          unsorted_emails << line.scan(EMAIL_PATERN)
        rescue
          puts "***" + filename
          puts "\t" + line[0,79]
        end
      end
    end
    return [unsorted_emails.flatten.compact, unsorted_emails.flatten.compact.size]
  end

  desc "Email expiring accounts to let them know"
  task :bidon => :environment do
    email_list = extract_emails_from_txt_and_csv(ENV["dir"] || CONTACT_DIR)
  end

  desc "Populate Country Database"
  task :populate_country_db => :environment do
    @countries = Country.all
    require 'open-uri'
    doc = Nokogiri::HTML(open("http://www.culture.gouv.fr/culture/dglf/ressources/pays/ANGLAIS.HTM"))
    countries = doc.css("a").map{|x| x.text unless x.text =~ /Index|page/}.compact
    countries.each do |country|
      unless @countries.map(&:name).include? country
        @country = Country.new(:name => country)
        @country.save
        puts @country.name
      end
    end
  end

  desc "Reset Database"
  task :db_reset => :environment do
    # RAILS_ENV=test ||
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['cc:create_or_update_files'].invoke
    Rake::Task['cc:populate_country_db'].invoke
  end

end
