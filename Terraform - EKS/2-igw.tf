resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.exam-vpc.id

  tags = {
    Name = "igw"
  }
}