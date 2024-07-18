# Create VPC
resource "aws_vpc" "speeqr" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "speeqr-stage"
  }
}

# Create public subnets in each AZ
resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.speeqr.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index}"
  }
}

#  resource "aws_subnet" "private" {
#    count                   = length(data.aws_availability_zones.available.names)
#    vpc_id                  = aws_vpc.speeqr.id
#    cidr_block              = "10.0.${count.index + 100}.0/24"
#    availability_zone       = element(data.aws_availability_zones.available.names, count.index)
#    map_public_ip_on_launch = false
#    tags = {
#      Name = "private-subnet-${count.index}"
#    }
#  }

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.speeqr.id
}

# Create a Route Table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.speeqr.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate public route table with public subnets
resource "aws_route_table_association" "public_rta" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# # # Create a NAT Gateway and Elastic IP for each AZ
#  resource "aws_nat_gateway" "nat" {
#     count           = length(data.aws_availability_zones.available.names)
#     allocation_id   = aws_eip.nat[count.index].id
#     subnet_id       = aws_subnet.public[count.index].id

#    tags = {
#      Name = "nat-${count.index}"
#    }
#  }

# # # Allocate Elastic IPs for NAT Gateways
#  resource "aws_eip" "nat" {
#    count = length(data.aws_availability_zones.available.names)
#  }

# # # Create a Route Table for private subnets
#  resource "aws_route_table" "private" {
#    count  = length(data.aws_availability_zones.available.names)
#    vpc_id = aws_vpc.speeqr.id

#    route {
#      cidr_block        = "0.0.0.0/0"
#      nat_gateway_id    = aws_nat_gateway.nat[count.index].id
#    }
# }

# # # Associate private route table with private subnets
#  resource "aws_route_table_association" "private_rta" {
#    count          = length(aws_subnet.private)
#    subnet_id      = aws_subnet.private[count.index].id
#    route_table_id = aws_route_table.private[count.index].id
#  }
