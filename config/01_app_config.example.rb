#Goes in initializers, and gets autoloaded
AWS_ACCESS_KEY_ID='KEY'
AWS_SECRET_ACCESS_KEY='SECRET_KEY'
POSTAGE_APP_API_KEY='APP_KEY'

APP_SECRET_TOKEN='SECRET_TOKEN'
APP_ACTION_MAILER_HOST='MAILER_HOST'

GIT_REPO='GIT_REPO'

WEB_SERVER='WEB_SERVER'
APP_SERVER='APP_SERVER'
DB_SERVER='DB_SERVER'
DEPLOY_DIR='DEPLOY_DIR'
S3_BACKUP_BUCKET='BACKUP_NAME'

PROD_DB_CONFIG= <<-YAML
    production:
      adapter: mysql2
      encoding: utf8
      reconnect: false
      database: livingtranscript_production
      pool: 5
      username: MY_USERNAME
      password: MY_PASSWORD
      host: localhost
    YAML
