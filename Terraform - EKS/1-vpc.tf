resource "aws_vpc" "exam-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "exam-vpc"
  }
}