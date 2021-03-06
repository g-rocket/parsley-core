require 'rubygems'

require 'rake/clean'

require 'google/api_client'
require 'yaml'

options = YAML.load_file "config.yml"

Fsts = FileList['**/*.att']
FstsToCompress = Fsts.ext("atz")

GrammarsToUpload = FileList['**/grammar.json']

CLEAN.include(GrammarsToUpload)
CLEAN.include(FstsToCompress)

rule '.atz' => ['.att'] do |t|
  sh "gzip -c #{t.source} > #{t.name}"
end

task :compress_parsers => FstsToCompress

desc "Upload final AT&T FSTs and grammars to Google Cloud Storage."
task :upload_parsers => :compress_parsers do
  key = Google::APIClient::KeyUtils.load_from_pkcs12(options['GoogleServiceCertFilename'], options['GoogleCertPassphrase'])

  authorization = Signet::OAuth2::Client.new(
    :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
    :audience => 'https://accounts.google.com/o/oauth2/token',
    :scope => 'https://www.googleapis.com/auth/devstorage.read_write',
    :issuer => options['GoogleCertIssuer'],
    :signing_key => key)
  authorization.fetch_access_token!
  client = Google::APIClient.new(
    :application_name => options['ApplicationName'],
    :application_version => options['ApplicationVersion'],
    :authorization => authorization
  )

  storage = client.discovered_api("storage", "v1beta2") 

  FstsToCompress.each do |fst|
    lang = File.dirname(fst).split(/\//)[0]
    media = Google::APIClient::UploadIO.new File.open(fst), "application/x-gzip"
    puts "uploading #{fst} as #{options['GCSBucketName']}:#{lang}/#{File.basename(fst)}"
    result = client.execute(
    :api_method => storage.objects.insert,
    :parameters => {
      :bucket => options['GCSBucketName'],
      :name => "#{lang}/#{File.basename(fst)}",
      :uploadType => "resumable"
    },
    :body_object => { :contentType => "application/x-gzip"},
    :media => media
  )
    upload = result.resumable_upload
    client.execute(upload)
  end

  GrammarsToUpload.each do |grammar|
    lang = File.dirname(grammar).split(/\//)[0]
    media = Google::APIClient::UploadIO.new File.open(grammar), "application/json"
    puts "uploading #{grammar} as #{options['GCSBucketName']}:#{lang}/#{File.basename(grammar)}"
    result = client.execute(
      :api_method => storage.objects.insert,
      :parameters => {
        :bucket => options['GCSBucketName'],
        :name => "#{lang}/#{File.basename(grammar)}",
        :uploadType => "resumable"
      },
      :body_object => { :contentType => "application/json"},
      :media => media
    )
    upload = result.resumable_upload
    client.execute(upload)
  end
end

task :default => :upload_parsers
