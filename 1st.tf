provider "aws" {
  region     = "ap-south-1"
  profile = "praneeth"
}



resource "tls_private_key" "firstkey" {
  algorithm   = "RSA"
  
  
}


output "firstop"{
        value=tls_private_key.firstkey
}


module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "key123"
  public_key = tls_private_key.firstkey.public_key_openssh

}



resource "aws_security_group" "first_security" {
  name        = "first"
  description = "for http server"
  

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }
 
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "second"
  }
}

resource "aws_instance" "first" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  security_groups = ["first"]
  key_name = "key123"

  tags = {
    Name = "9th os"
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = tls_private_key.firstkey.private_key_pem
    host     = aws_instance.first.public_ip
  }
    provisioner "remote-exec" {
    inline = [
      "sudo yum install git php httpd -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
    ]
   }
}

output "secondop"{
        value=aws_instance.first.availability_zone
}



resource "aws_ebs_volume" "firstvol" {
  availability_zone = aws_instance.first.availability_zone
  size              = 1

  tags = {
    Name = "firstvol"
  }
}


output "thirdop" {
        value=aws_ebs_volume.firstvol.id
}

output "fourthop"{
        value=aws_instance.first.id
}

output "eightop"{
        value=aws_instance.first.public_ip
}


resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   =aws_ebs_volume.firstvol.id 
  instance_id =aws_instance.first.id 
  force_detach = true
}

resource "null_resource" "null1" {
  provisioner "local-exec" {
    command = "echo ${aws_instance.first.public_ip} > publicip.txt"
    
  }
}

resource "null_resource" "null2" {
 depends_on = [aws_volume_attachment.ebs_att]
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = tls_private_key.firstkey.private_key_pem
    host     = aws_instance.first.public_ip
  }
 provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdh",
      "sudo mount /dev/xvdh /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/Praneeth102/cloud.git /var/www/html/",
    ]
   }
}
output "ninthop"{
        value=aws_instance.first 

}
resource "null_resource" "null3" {
   depends_on = [null_resource.null2]
  provisioner "local-exec" {
    command = "start chrome ${aws_instance.first.public_ip}/index.php"
    
  }
}


resource "aws_s3_bucket" "firsts3" {
  bucket = "firsts8897"
  acl    = "public-read"
  

  tags = {
    Name        = "firsts8897"
    
  }

  versioning{
      enabled=true
 }
} 


output "fifthop"{
        value=aws_s3_bucket.firsts3.id
}





resource "aws_cloudfront_distribution" "cloudfrount_s3" {
  origin {
    domain_name = "firsts8897.s3.amazonaws.com"
    origin_id   = "S3-firsts8897"
}

  enabled             = true
  
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-firsts8897"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    } 
      viewer_protocol_policy = "allow-all"  
      min_ttl                = 0
      default_ttl            = 3600
      max_ttl                = 86400
   }

   
    restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["IN", "CA", "US"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}







  

  

   

  

      

    
  

    
  

    
      
  

