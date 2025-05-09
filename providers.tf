provider "aws" { 
  region                      = "us-east-1"  
  skip_credentials_validation = true        
  access_key                  = "test"       
  secret_key                  = "test"

  endpoints {
    dynamodb       = "http://localhost:4566"
    iam            = "http://localhost:4566" 
    lambda         = "http://localhost:4566" 
    s3             = "http://localhost:4566" 
  }

  s3_use_path_style           = true         
}
