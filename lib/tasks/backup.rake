namespace :backup do
  desc "run database backup"
  task :db, :needs => :environment do
    require 'tempfile'
    require 'aws-sdk'

    backup_file_path = mysqldump
    upload_to_s3(backup_file_path)
  end

  def mysqldump
    tempfile = Tempfile.new(Time.now.gmtime.strftime('_%Y%m%d-%H:%m:%SZ'))
    db_config=Rails.configuration.database_configuration["production"]
    `mysqldump --quick --single-transaction --create-options -u #{db_config["username"]} -p#{db_config["password"]} -h #{db_config["host"]} #{db_config["database"]} > #{tempfile.path}`
    tempfile.path
  end

  def upload_to_s3(fp)
    s3 = AWS::S3.new
    bucket = s3.buckets[S3_BACKUP_BUCKET]
  end
end
