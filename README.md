## About
    This project aims in creating folders and uploading files so that we can have all files in one location.

## Technology stack
   - ruby 2.6.3
   - rails 6.0.0
   - Reddis server 5.0.6
   - Postgresql 9.6.5
   - AWS S3

## Steps for running locally
    1. Clone the project(`git clone https://github.com/ram619prasad/drive.git`)
    2. Open the code in your favourite code editor and rename `.env.development.local.sample` to `.env.development.local` and add all the values for the available env variables.
    3. Make Sure that your PostgreSQL service is running.
    4. Make sure that your redis server is up and running.
    5. Install all the required gems(`bundle install`)
    6. Setup the postgreSQL database(`bundle exec rake db:setup`)
    7. Create a bucket in S3 with some specific name and add the same as bucket value for Amazon section      in storage.yml
    8. For a root user in AWS, click on `create access key` button. This will generate `Access Key ID` and `Secret Access Key`. Add the `Access Key ID` value as value of `AWS_ACCESS_KEY_ID` and `Secret Access Key` as value of `AWS_SECRET_ACCESS_KEY` in .env.development.local file which you renamed in Step#2.
    9. Run the rails server(`rails s`)
