# encoding: utf-8

##
# Backup Generated: postgres
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t postgres [-c <path_to_configuration_file>]
#
# For more information about Backup's components, see the documentation at:
# http://backup.github.io/backup
#
Model.new(:postgres, 'Backup PostgreSQL Database') do
  ##
  # Archive [Archive]
  #
  # Adding a file or directory (including sub-directories):
  #   archive.add "/path/to/a/file.rb"
  #   archive.add "/path/to/a/directory/"
  #
  # Excluding a file or directory (including sub-directories):
  #   archive.exclude "/path/to/an/excluded_file.rb"
  #   archive.exclude "/path/to/an/excluded_directory
  #
  # By default, relative paths will be relative to the directory
  # where `backup perform` is executed, and they will be expanded
  # to the root of the filesystem when added to the archive.
  #
  # If a `root` path is set, relative paths will be relative to the
  # given `root` path and will not be expanded when added to the archive.
  #
  #   archive.root '/path/to/archive/root'
  #
  # archive :my_archive do |archive|
  #   # Run the `tar` command using `sudo`
  #   # archive.use_sudo
  #   archive.add "/path/to/a/file.rb"
  #   archive.add "/path/to/a/folder/"
  #   archive.exclude "/path/to/a/excluded_file.rb"
  #   archive.exclude "/path/to/a/excluded_folder"
  # end

  ##
  # PostgreSQL [Database]
  #
  database PostgreSQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name               = ENV['DB_NAME']
    db.username           = ENV['DB_USERNAME']
    db.password           = ENV['DB_PWD']
    db.host               = ENV['DB_HOST']
    db.port               = ENV['DB_PORT']
    # db.socket             = "/tmp/pg.sock"
    # When dumping all databases, `skip_tables` and `only_tables` are ignored.
    # db.skip_tables        = ["skip", "these", "tables"]
    # db.only_tables        = ["only", "these", "tables"]
    db.additional_options = ["-xc", "-E=utf8"]
  end

  if ['production', 'prod'].include? ENV['ENVIRONMENT']
    store_with S3 do |s3|
      # AWS Credentials
      s3.access_key_id     = ENV['S3_ACCESS_KEY_ID']
      s3.secret_access_key = ENV['S3_SECRET_ACCESS_KEY']
      # Or, to use a IAM Profile:
      # s3.use_iam_profile = true

      s3.region             = ENV['S3_REGION']
      s3.bucket             = ENV['S3_BUCKET_NAME']
      # s3.path               = ENV['S3_BUCKET_DIR_PATH']

      s3.chunk_size = 10 # MiB by default 5 MB

      s3.max_retries = 10 # 10 times is the default
      s3.retry_waitsec = 30 # 30 second is the default
    end
  else
    ##
    # Local (Copy) [Storage]
    #
    store_with Local do |local|
      local.path       = "~/backups/"
      local.keep       = 5
      # local.keep       = Time.now - 2592000 # Remove all backups older than 1 month.
    end
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip

  ##
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the documentation for other delivery options.
  #
  if ['yes', 'true', 'on', '1'].include?(ENV['NOTIFIER_ENABLED'])
    notify_by Mail do |mail|
      # mail.on_success           = true
      mail.on_warning           = true
      mail.on_failure           = true

      mail.from                 = ENV['MAIL_SENDER']
      mail.to                   = ENV['MAIL_TO']
      mail.address              = ENV['MAIL_ADDRESS']
      mail.port                 = ENV['MAIL_PORT'].to_i
      mail.domain               = ENV['MAIL_DOMAIN']
      mail.user_name            = ENV['MAIL_USERNAME']
      mail.password             = ENV['MAIL_PASSWORD']
      mail.authentication       = ENV['MAIL_AUTHENTICATION']
      mail.encryption           = ENV['MAIL_ENCRYPTION'].to_sym
    end
  end

end
