resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.exam-main.id

  tags = {
    Name = "igw"
  }
}
